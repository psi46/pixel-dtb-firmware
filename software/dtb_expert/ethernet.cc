// ethernet.cc

#include "system.h"
#include "io.h"

#include <altera_avalon_sgdma.h>
#include <altera_avalon_sgdma_descriptor.h>
#include <altera_avalon_sgdma_regs.h>

#include <sys/alt_irq.h>
#include <sys/alt_cache.h>

#include "pixel_dtb.h"


// === ETHERNET test ========================================================

template <class T>
inline volatile T* Uncache(T *x) { return (T*)(((unsigned long)x) | 0x80000000); }


// Function Prototypes
void rx_ethernet_isr (void *context);


// Global Variables
volatile unsigned int rx_frame_counter = 0;

// Create a transmit frame
unsigned char tx_frame[1024] =
{
	0x00,0x00, 						// for 32-bit alignment
	0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 	// destination address (broadcast)
	0x40,0xD8,0x55,0x11,0x80,0x00,  // source address
	0x00,0x2E, 						// length or type of the payload data
	'\0' 							// payload data (ended with termination character)
};

#define DATA_OFFSET 16


// Create a receive frame
unsigned char rx_frame[1024] = { 0 };

// Create sgdma transmit and receive devices
alt_sgdma_dev * sgdma_tx_dev;
alt_sgdma_dev * sgdma_rx_dev;

// Allocate descriptors in the descriptor_memory (onchip memory)
alt_sgdma_descriptor tx_descriptor		__attribute__ (( section ( ".descriptor_memory" )));
alt_sgdma_descriptor tx_descriptor_end	__attribute__ (( section ( ".descriptor_memory" )));

alt_sgdma_descriptor rx_descriptor  	__attribute__ (( section ( ".descriptor_memory" )));
alt_sgdma_descriptor rx_descriptor_end  __attribute__ (( section ( ".descriptor_memory" )));


bool CTestboard::Ethernet_Init()
{
	// Open the sgdma transmit device
	sgdma_tx_dev = alt_avalon_sgdma_open ("/dev/sgdma_tx");
	if (sgdma_tx_dev == NULL) return false;

	// Open the sgdma receive device
	sgdma_rx_dev = alt_avalon_sgdma_open ("/dev/sgdma_rx");
	if (sgdma_rx_dev == NULL) return false;

	// Set interrupts for the sgdma receive device
	alt_avalon_sgdma_register_callback( sgdma_rx_dev, (alt_avalon_sgdma_callback) rx_ethernet_isr, 0x00000014, NULL );

	// Create sgdma receive descriptor
	alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor, &rx_descriptor_end, (alt_u32*)rx_frame, 0, 0 );

	// Set up non-blocking transfer of sgdma receive descriptor
	alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor );

	// Triple-speed Ethernet MegaCore base address
	volatile int * tse = Uncache((int *) TSE_MAC_BASE);

	// Initialize the MAC address
	tse[3] = 0x55118000; // mac_0
	tse[4] = 0x000040D8; // mac_1

	// Specify the addresses of the PHY devices to be accessed through MDIO interface
	tse[0x0F] = 0x12; // mdio_addr0

	// Write to register 16 of the PHY chip for Ethernet port 1 to enable automatic crossover for all modes
	tse[0x90] |= 0x0060; // 0000 0000 0110 0000 Automatic crossover

	// Write to register 20 of the PHY chip for Ethernet port 2 to set up delay for input/output clk
	tse[0x94] |= 0x0082; // 0000 0000 1000 0010 RGMII Add delay to RX_CLK for RXD, Enable DTE detection

	// Software reset the PHY chip and wait
	tse[0x80] |= 0x8000;
	while ( tse[0x80] & 0x8000  );

	// Enable read and write transfers, gigabit Ethernet operation, and CRC forwarding
	tse[2] |= 0x0000004B; // 0100 1011 command config: CRC_FWD, ETH_SPEED, RX_ENA, TX_ENA

	return true;
}


void CTestboard::Ethernet_Send(string &message)
{
		unsigned int pos = 0;
		while (pos<45 && pos < message.size())
		{
			tx_frame[DATA_OFFSET+pos] = message[pos];
			pos++;
		}
		tx_frame[16+pos] = 0;

		alt_dcache_flush(tx_frame, 1024);

		// Create transmit sgdma descriptor
		alt_avalon_sgdma_construct_mem_to_stream_desc( &tx_descriptor, &tx_descriptor_end, (alt_u32*)tx_frame,
				62 , 0, 1, 1, 0 );

		// Set up non-blocking transfer of sgdma transmit descriptor
		alt_avalon_sgdma_do_async_transfer( sgdma_tx_dev, &tx_descriptor );

		// Wait until transmit descriptor transfer is complete
		while (alt_avalon_sgdma_check_descriptor_status(&tx_descriptor) != 0);
}


uint32_t CTestboard::Ethernet_RecvPackets()
{
	return rx_frame_counter;
}


void rx_ethernet_isr (void *context)
{
	rx_frame_counter++;

	// Wait until receive descriptor transfer is complete
	while (alt_avalon_sgdma_check_descriptor_status(&rx_descriptor) != 0);
	alt_dcache_flush(rx_frame, 1024);

	// Output received text
//	printf( "receive> %s\n", rx_frame + DATA_OFFSET );

	// Create new receive sgdma descriptor
	alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor, &rx_descriptor_end, (alt_u32*)rx_frame, 0, 0 );

	// Set up non-blocking transfer of sgdma receive descriptor
	alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor );
}




