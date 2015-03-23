// dtb_hal.h


#ifndef DTB_HAL_H
#define DTB_HAL_H

#include <unistd.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "io.h"
#include "rpc_io.h"
#include "sgdma.h"
#include "cstdint.h"


// basic I/O functions

inline void _SetLED(unsigned int value)
{ IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE, value); }


#define MAINCTRL_CLK_SEL_SMPL 0x0001
#define MAINCTRL_CLK_SEL_DAQ  0x0002
#define MAINCTRL_PWR_ON       0x0004
#define MAINCTRL_HV_ON        0x0008
#define MAINCTRL_DUT_nRES     0x0010
#define MAINCTRL_TERM         0x0020
#define MAINCTRL_ADCENA       0x0040
#define MAINCTRL_PLL_RESET    0x0080
#define MAINCTRL_DESER400_OLD 0x0100

inline void _MainControl(unsigned short value)
{ IOWR_ALTERA_AVALON_PIO_DATA(MAIN_CONTROL_BASE, value); }

#define MAINSTATUS_CLK_EXT_BAD     0x0001
#define MAINSTATUS_CLK_ACTIVE_SMPL 0x0002
#define MAINSTATUS_CLK_ACTIVE_DAQ  0x0004
#define MAINSTATUS_CLK_LOCKED_SMPL 0x0008
#define MAINSTATUS_CLK_LOCKED_DAQ  0x0010
#define MAINSTATUS_CRC_ERROR       0x0020
#define MAINSTATUS_SD_CARD_DET     0x0040
inline unsigned short _MainStatus()
{
	return IORD_ALTERA_AVALON_PIO_DATA(MAIN_STATUS_BASE);
}


inline void SetClkDiv(unsigned char value)
{ IOWR_ALTERA_AVALON_PIO_DATA(CLKDIV_BASE, value); }

inline void SetClockStretchReg(unsigned char reg, unsigned short value)
// { IOWR_16DIRECT(CLK_STRETCH_BASE, reg*2, value); }
{ __builtin_sthio (__IO_CALC_ADDRESS_DYNAMIC (CLK_STRETCH_BASE, reg*2), value); }

inline void SetToutRdbDelay(unsigned char value)
{ IOWR_ALTERA_AVALON_PIO_DATA(RDA_DELAY_BASE, value); }


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


// *3SDATA
extern const unsigned int DAQ_DMA_BASE[6];

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

inline void Trigger_Write(short reg, unsigned long value)
{IOWR_32DIRECT(TRIGGER_BASE, reg<<2, value); }

inline void _Probe1(unsigned char value) { IOWR_8DIRECT(PROBE_D1_BASE, 0, value); }
inline void _Probe2(unsigned char value) { IOWR_8DIRECT(PROBE_D2_BASE, 0, value); }
inline void _Probe1a(unsigned char value) { IOWR_8DIRECT(PROBE_ASYNC_D1_BASE, 0, value); }
inline void _Probe2a(unsigned char value) { IOWR_8DIRECT(PROBE_ASYNC_D2_BASE, 0, value); }

void Adv3224Init();

inline void SetI2cHs(unsigned char reg, unsigned int value)
{ IOWR_32DIRECT(PSI2C_BASE, reg<<2, value); }

inline unsigned int GetI2cHs(unsigned char reg)
{ return IORD_32DIRECT(PSI2C_BASE, reg<<2); }


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
void I2C_External_Init();

uint8_t I2C_EEPROM_Write(uint8_t addr, const uint8_t *data, uint8_t length);
uint8_t I2C_EEPROM_Read(uint8_t *data, uint8_t length);

// I2C EEPROM return codes
#define EEPROM_OK           0
#define EEPROM_NOT_PRESENT  1


// === USB ===============================================================

class CUSB : public CRpcIo
{
	CDma dma;
	bool ReadByte(unsigned char &value);
//	void WriteByte(unsigned char value);
public:
	CUSB() {}
	~CUSB() {}
	void Reset();
	bool RxFull() { return IORD_8DIRECT(USB2_BASE, 1) && 0x01; }
	bool Write(const void *buffer, uint32_t size);
	void Flush();
	bool Read(void *buffer, unsigned int size);
};


#endif //_ATB_BASE_H_
