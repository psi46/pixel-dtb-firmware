// dtb_hal.h


#ifndef DTB_HAL_H
#define DTB_HAL_H

#include <unistd.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "io.h"
#include "rpc_io.h"

// basic I/O functions

inline void _SetLED(unsigned int value)
{ IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE, value); }


#define MAINCTRL_CLK_EXT   0x01
#define MAINCTRL_PWR_ON    0x02
#define MAINCTRL_HV_ON     0x04
#define MAINCTRL_DUT_nRES  0x08
#define MAINCTRL_TERM      0x10
#define MAINCTRL_ADCENA    0x20
#define MAINCTRL_PLL_RESET 0x40

inline void _MainControl(unsigned int value)
{ IOWR_ALTERA_AVALON_PIO_DATA(MAIN_CONTROL_BASE, value); }

inline unsigned char _MainStatus()
{
	return IORD_ALTERA_AVALON_PIO_DATA(MAIN_STATUS_BASE);
}

// === ADC ==================================================================

// -- adc register
#define ADC_CTRL 0
#define ADC_STATUS 0
#define ADC_START  2
#define ADC_STOP   4
#define ADC_LEN    6
#define ADC_SIZE   6

inline void ADC_WRITE(short reg, unsigned short value)
{IOWR_16DIRECT(ADC_0_BASE, reg, value); }

inline unsigned short ADC_READ(short reg)
{ return IORD_16DIRECT(ADC_0_BASE, reg); }


// === DAQ ==================================================================

#define DESER400_RESET      0x01
#define DESER400_REG_RESET  0x02
#define DESER400_SEL_MOD0   0x04

inline void _Deser400_Control(unsigned int value)
{ IOWR_ALTERA_AVALON_PIO_DATA(DESER400_BASE, value); }



extern const unsigned int DAQ_DMA_BASE[8];

// -- daq dma register
#define DAQ_MEM_BASE   0
#define DAQ_MEM_SIZE   4
#define DAQ_MEM_READ   8
#define DAQ_MEM_WRITE 12
#define DAQ_CONTROL   16
#define DAQ_STATUS    16

// -- status bits bitmask
#define DAQ_RUNNING   1
#define DAQ_MEM_OVFL  2
#define DAQ_FIFO_OVFL 4

inline void DAQ_WRITE(unsigned int daq_base, short reg, unsigned long value)
{IOWR_32DIRECT(daq_base, reg, value); }

inline unsigned long DAQ_READ(unsigned int daq_base, short reg)
{ return IORD_32DIRECT(daq_base, reg); }



inline void _Probe1(unsigned char value) { IOWR_8DIRECT(PROBE_D1_BASE, 0, value); }
inline void _Probe2(unsigned char value) { IOWR_8DIRECT(PROBE_D2_BASE, 0, value); }

void Adv3224Init();

inline void SetI2cHs(unsigned char reg, unsigned int value)
{ IOWR_32DIRECT(PSI2C_BASE, reg<<2, value); }

inline unsigned int GetI2cHs(unsigned char reg)
{ return IORD(PSI2C_BASE, reg<<2); }


// === I2C master ========================================================

// I2C master register
#define PRERlo   0x00  // --- Clock Prescale register lo-byte -----
#define PRERhi   0x01  // --- Clock Prescale register hi-byte -----

#define CTR      0x02  // --- Control register --------------------
#define EN       0x80  // core enable
#define IEN      0x40  // interrupt enable

#define TXR      0x03  // --- Transmit register -------------------

#define RXR      0x03  // --- Receive register --------------------

#define CR       0x04  // --- Command register --------------------
#define STA      0x80  // generate (repeated) start condition
#define STO      0x40  // generate stop condition
#define RD       0x20  // read from slave
#define WR       0x10  // write to slave
#define ACK      0x08  // ACK=0: send ACK; ACK = 1: send NACK
#define IACK     0x01  // Interrupt acknowledge

#define SR       0x04  // --- Status register ---------------------
#define RxACK    0x80  // Received acknowledge from slave (RxACK=0)
#define BUSY     0x40  // I2C busy ( 1 after START detected)
#define AL       0x20  // Arbitration lost
#define TIP      0x02  // Transfer in Progress
#define IF       0x01  // Interrupt Flag

void I2C_Main_Init();
// bool I2C_Master_Write(unsigned char data);
// bool I2C_Master_Read(unsigned char &data);



// === USB ===============================================================

class CUSB : public CRpcIo
{
	unsigned short write_buffer;
	unsigned short read_buffer;

	bool ReadByte(unsigned char &value);
	void WriteByte(unsigned char value);
	bool IsRxFull() { return (read_buffer & 0x8000) == 0; }
	bool IsTxFull() { return (write_buffer & 0x8000) == 0; }
public:
	CUSB() : write_buffer(0x8000), read_buffer(0x8000) {}
	bool RxFull();
	bool Write(const void *buffer, unsigned int size);
	void Flush();
	bool Read(void *buffer, unsigned int size);
};


#endif //_ATB_BASE_H_
