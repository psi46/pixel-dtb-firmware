// ethernet.cc

#include "system.h"
#include "io.h"

#include <altera_avalon_sgdma.h>
#include <altera_avalon_sgdma_descriptor.h>
#include <altera_avalon_sgdma_regs.h>

#include <sys/alt_stdio.h>
#include <sys/alt_irq.h>
#include <sys/alt_cache.h>
#include <stdio.h>

#include "ethernet.h"
#include "dtb_config.h"

template <class T>
inline volatile T* Uncache(T *x) { return (T*)(((unsigned long)x) | 0x80000000); }

const unsigned int FRAME_SIZE = 1024;
const unsigned int BUFFER_SIZE = 5*FRAME_SIZE;
// Create a transmit frame
unsigned char tx_frame[FRAME_SIZE] = {
	0x00,0x00, 						// for 32-bit alignment
	0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 	// destination address (broadcast)
	0x01,0x60,0x6E,0x11,0x02,0x0F, 	// source address //updated later
	0x08,0x01  						// length or type of the payload data
};

// Create a receive frame
unsigned char rx_frame[FRAME_SIZE] = { 0 };
unsigned char rx_buffer[BUFFER_SIZE] = { 0 };
unsigned int rx_buff_offset = 0;
unsigned int rx_buff_size   = 0;

// Create sgdma transmit and receive devices
alt_sgdma_dev * sgdma_tx_dev;
alt_sgdma_dev * sgdma_rx_dev;

// Allocate descriptors in the descriptor_memory (onchip memory)
alt_sgdma_descriptor tx_descriptor		__attribute__ (( section ( ".descriptor_memory" )));
alt_sgdma_descriptor tx_descriptor_end	__attribute__ (( section ( ".descriptor_memory" )));

alt_sgdma_descriptor rx_descriptor  	__attribute__ (( section ( ".descriptor_memory" )));
alt_sgdma_descriptor rx_descriptor_end  __attribute__ (( section ( ".descriptor_memory" )));

void buff_write(char c){
        rx_buffer[(rx_buff_offset + rx_buff_size) % BUFFER_SIZE] = c;
        rx_buff_size++;
}

char buff_read(){
        char c = rx_buffer[rx_buff_offset];
        rx_buff_size--;
        rx_buff_offset = (rx_buff_offset+1) % BUFFER_SIZE;
        return c;
}


unsigned char src_addr[6];
unsigned char dst_addr[6];
unsigned int message_size = 0;
/****************************************************************************************
 * Subroutine to read incoming Ethernet frames
****************************************************************************************/
unsigned int RX_MAX_PAYLOAD_SIZE = 5*FRAME_SIZE;
void rx_ethernet_isr (void *context)
{
	// Wait until receive descriptor transfer is complete
	while (alt_avalon_sgdma_check_descriptor_status(&rx_descriptor) != 0);
	alt_dcache_flush(rx_frame, 1024);
	// Create new receive sgdma descriptor
	alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor, &rx_descriptor_end, (alt_u32*)rx_frame, 0, 0 );
	// Set up non-blocking transfer of sgdma receive descriptor
	alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor );

	for(int k= 0; k<6; k++)
		dst_addr[k] = rx_frame[k+2];
	for(int k= 0; k<6; k++)
		src_addr[k] = rx_frame[k+8];

	message_size = rx_frame[14];
	message_size = (message_size << 8) | rx_frame[15];

	if(message_size > 1500) return; //packet not from psi46*
	for(unsigned int k = 0; k < message_size; k++){
		buff_write(rx_frame[16+k]);
	}

}

int eth_init(bool& initiated){
	// Open the sgdma transmit device
	sgdma_tx_dev = alt_avalon_sgdma_open ("/dev/sgdma_tx");
	if (sgdma_tx_dev == NULL)
	{
		printf ("Error: could not open scatter-gather dma transmit device\n");
		return -1;
	} else printf ("Opened scatter-gather dma transmit device\n");

	// Open the sgdma receive device
	sgdma_rx_dev = alt_avalon_sgdma_open ("/dev/sgdma_rx");
	if (sgdma_rx_dev == NULL)
	{
		printf ("Error: could not open scatter-gather dma receive device\n");
		return -1;
	} else printf ("Opened scatter-gather dma receive device\n");

	// Set interrupts for the sgdma receive device
	alt_avalon_sgdma_register_callback( sgdma_rx_dev, (alt_avalon_sgdma_callback) rx_ethernet_isr, 0x00000014, NULL );

	// Create sgdma receive descriptor
	alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor, &rx_descriptor_end, (alt_u32*)rx_frame, 0, 0 );

	// Set up non-blocking transfer of sgdma receive descriptor
	alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor );

	// Triple-speed Ethernet MegaCore base address
	volatile int * tse = Uncache((int *) TSE_MAC_BASE);

	unsigned long long MAC = dtbConfig.mac_address;

	// Initialize the MAC address, requires some byte-shifting
	tse[3] = 0;
	tse[3] = tse[3] | ((MAC >> 40) & 0x000000FF);
	tse[3] = tse[3] | ((MAC >> 24) & 0x0000FF00);
	tse[3] = tse[3] | ((MAC >> 8)  & 0x00FF0000);
	tse[3] = tse[3] | ((MAC << 8)  & 0xFF000000);
	tse[4] = 0;
	tse[4] = tse[4] | ((MAC >> 8) & 0xFF);
	tse[4] = tse[4] | ((MAC << 8) & 0xFF00);

	tx_frame[8] =  (char)(MAC >> 40);
	tx_frame[9] =  (char)(MAC >> 32);
	tx_frame[10] = (char)(MAC >> 24);
	tx_frame[11] = (char)(MAC >> 16);
	tx_frame[12] = (char)(MAC >> 8);
	tx_frame[13] = (char)MAC;

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
	initiated = true;
	return 0;
}

bool eth_read(void* buffer, unsigned int size){
	unsigned int i = 0;

	int timeout = 10000000;
	while(i < size){
		if(rx_buff_size == 0){
			timeout--;
			if(!timeout) return false;
			continue;
		}
		timeout = 10000000;
		((unsigned char*)buffer)[i] = buff_read();
		i++;
	}
	return true;
}


unsigned int txPayloadSize = 0;
const unsigned int TX_MAX_PAYLOAD_SIZE = FRAME_SIZE - 17; //16 address bytes plus null terminator
void eth_flush(){
	tx_frame[14] = (char)(txPayloadSize >> 8);
	tx_frame[15] = (char)txPayloadSize;

	alt_dcache_flush(tx_frame, 1024);

	// Create transmit sgdma descriptor
	alt_avalon_sgdma_construct_mem_to_stream_desc( &tx_descriptor, &tx_descriptor_end, (alt_u32*)tx_frame,
			txPayloadSize+17 , 0, 1, 1, 0 );

	// Set up non-blocking transfer of sgdma transmit descriptor
	alt_avalon_sgdma_do_async_transfer( sgdma_tx_dev, &tx_descriptor );

	// Wait until transmit descriptor transfer is complete
	while (alt_avalon_sgdma_check_descriptor_status(&tx_descriptor) != 0);
	txPayloadSize = 0;
}

bool eth_write(const void* data, unsigned int size){
	for(unsigned int i = 0 ; i < size; i++){
		txPayloadSize++;
		if(txPayloadSize == TX_MAX_PAYLOAD_SIZE){
			eth_flush();
			txPayloadSize++;
		}
		tx_frame[15 + txPayloadSize] = ((char*)data)[i];
	}
	return true;
}




/* Ethernet
 * Object wrapper for Ethernet interface
 */
Ethernet::Ethernet(){
	initiated = false;
}
bool Ethernet::Read(void* buffer, unsigned int size){
	if(!initiated) eth_init(initiated);
	return eth_read(buffer, size);
}
bool Ethernet::Write(const void * buffer, unsigned int size){
	if(!initiated) eth_init(initiated);
	return eth_write(buffer,size);
}
void Ethernet::Flush(){
	if(!initiated) eth_init(initiated);
	eth_flush();
}
bool Ethernet::RxFull(){
	if(!initiated) eth_init(initiated);
	return rx_buff_size == BUFFER_SIZE;
}
bool Ethernet::RxEmpty(){
	if(!initiated) eth_init(initiated);
	return rx_buff_size == 0;
}
