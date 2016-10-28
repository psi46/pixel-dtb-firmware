// atb_base.cc
// 10.1.2006

#include <unistd.h>
#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "dtb_hal.h"


// === DAQ ==================================================================

const unsigned int DAQ_DMA_BASE[8] =
{
  DAQ_DMA_0_BASE,
  DAQ_DMA_1_BASE,
  DAQ_DMA_2_BASE,
  DAQ_DMA_3_BASE,
  DAQ_DMA_4_BASE,
  DAQ_DMA_5_BASE,
  DAQ_DMA_6_BASE,
  DAQ_DMA_7_BASE
};


// === I2C ==================================================================

void I2C_Main_Init()
{
  IOWR_8DIRECT(I2C_MAIN_BASE, CTR,     0);    // disable i2c controller
  IOWR_8DIRECT(I2C_MAIN_BASE, PRERlo, 79);    // prescaler = 79 (100kHz)
  IOWR_8DIRECT(I2C_MAIN_BASE, PRERhi,  0);
  IOWR_8DIRECT(I2C_MAIN_BASE, CTR,    EN);    // enable i2c controller
}


void I2C_External_Init()
{
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, CTR,     0);    // disable i2c controller
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, PRERlo, 79);    // prescaler = 79 (100kHz)
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, PRERhi,  0);
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, CTR,    EN);    // enable i2c controller
}


uint8_t I2C_EEPROM_Write(uint16_t addr, const uint8_t *data, uint8_t length)
{
  Enter_I2C_mode();

  uint8_t error = EEPROM_OK;
  int res, p = 0;
  // send device id
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, TXR, 0xAE);
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, STA|WR);
  while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
  if (res & RxACK) error = EEPROM_NOT_PRESENT;

  // send address 1
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, TXR, addr >> 8);
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, WR);
  while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);

  // send address 0
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, TXR, addr & 0xff);
  if (length > 0)
  {
	  IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, WR);
    while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
  }
  else
  {
    IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, WR|STO);
    while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
    return error;
  }

  // send data bytes
  do
  {
    length--;
    IOWR_8DIRECT(I2C_EXTERNAL_BASE, TXR, data[p++]);
    if (length != 0)
      IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, WR);
    else
      IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, WR|STO);
    while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
  } while (length > 0);
  return error;
}


uint8_t I2C_EEPROM_Read(uint8_t *data, uint8_t length)
{
  if (length == 0) return EEPROM_OK;
  Enter_I2C_mode();

  uint8_t error = EEPROM_OK;
  int res, p = 0;
  // send device id
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, TXR, 0xAF);
  IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, STA|WR);
  while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
  if (res & RxACK) error = EEPROM_NOT_PRESENT;

  // read data bytes
  while (length > 0)
  {
    length--;
    if (length != 0)
      IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, RD);
    else
      IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, RD|STO|ACK);
    while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
    data[p++] = IORD_8DIRECT(I2C_EXTERNAL_BASE, RXR);
  }
  return error;
}



void Adv3224Init()
{
	usleep(50);

	// all outputs 0V
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, 16); // ADC+ (x4)
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 1, 16); // ADC- (x4)
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 2, 15); // ADC+ (x2)
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 3, 15); // ADC- (x4)
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 4, 15); // A1+
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 5, 15); // A1-
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 6, 15); // A2+
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 7, 15); // A2-
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, 0xFF);
}


// === USB ==================================================================


bool CUSB::ReadByte(unsigned char &value)
{
	unsigned int timeout = 500000;
	while (!RxFull() && timeout) { timeout--; usleep(1); }
	if (RxFull())
	{
		value = IORD_8DIRECT(USB2_BASE, 0);
		return true;
	}
	value = 0;
	return false;
}


bool CUSB::Read(void *buffer, unsigned int size)
{
	unsigned int i;
	unsigned char *p = (unsigned char*)buffer;
	for (i=0; i<size; i++) if (!ReadByte(*(p++))) return false;
	return true;
}


void CUSB::Reset()
{
	dma.DeleteAllDescriptors();
}


bool CUSB::Write(const void *buffer, uint32_t size)
{
	dma.Add(buffer, size);
	return true;
}


void CUSB::Flush()
{
	dma.Send();
	IOWR_8DIRECT(USB2_BASE, 1, 1); // FT232 send immediate
}


// === Sector Test Board =================================================

uint8_t stbCtrlReg = 0;

#define SPI_ENA 0x10
#define SPI_
/* SPI control port
	bit 4:    spi_ena
	bit 3:    spi_pol
	bit 2..0: SPI slave address
*/

void SPI_send(uint8_t x)
{
	alt_u32 status;

	// wait for TXDATA empty
	do
	{
		status = IORD_ALTERA_AVALON_SPI_STATUS(SPI_EXTERNAL_BASE);
	}
	while ((status & ALTERA_AVALON_SPI_STATUS_TRDY_MSK) == 0);

	// start transfer (send/receive)
	IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_EXTERNAL_BASE, x);
}


uint8_t SPI_send_receive(uint8_t x)
{
	alt_u32 status;

	// wait for TXDATA empty
	do
	{
		status = IORD_ALTERA_AVALON_SPI_STATUS(SPI_EXTERNAL_BASE);
	}
	while ((status & ALTERA_AVALON_SPI_STATUS_TRDY_MSK) == 0);

	// start transfer (send/receive)
	IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_EXTERNAL_BASE, x);

	// wait for RXDATA
	do
	{
		status = IORD_ALTERA_AVALON_SPI_STATUS(SPI_EXTERNAL_BASE);
	}
	while ((status & ALTERA_AVALON_SPI_STATUS_RRDY_MSK) == 0);

	// read data
	return (alt_u8)IORD_ALTERA_AVALON_SPI_RXDATA(SPI_EXTERNAL_BASE);
}


// --- ADC LTC1863 -------------------------------------------------------

uint16_t STB_Send_Receive_LTC1863(uint8_t cmd)
{
	// force chip select (2 byte data)
	IOWR_ALTERA_AVALON_SPI_CONTROL(SPI_EXTERNAL_BASE, ALTERA_AVALON_SPI_CONTROL_SSO_MSK);

	// discharge any stale data
	IORD_ALTERA_AVALON_SPI_RXDATA(SPI_EXTERNAL_BASE);

	// send 16 bit data
	uint16_t value;
	value  = SPI_send_receive(cmd) << 8;
	value += SPI_send_receive(0);

	// release chipselect
	IOWR_ALTERA_AVALON_SPI_CONTROL(SPI_EXTERNAL_BASE, 0);

	// Wait until the interface has finished transmitting
	alt_u32 status;
	do { status = IORD_ALTERA_AVALON_SPI_STATUS(SPI_EXTERNAL_BASE); }
	while ((status & ALTERA_AVALON_SPI_STATUS_TMT_MSK) == 0);

	return value;
}


uint16_t STB_ReadADC(uint8_t adc, uint8_t channel)
{
	if (adc > 3 || channel > 7) return 0;

	// enter SPI mode and set slave address (CPHA=0)
	Enter_SPI_mode((adc == 3)? 0x1 : 0x5+adc);
	IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_EXTERNAL_BASE, 1);

	// SD=1, OS:S1:S0=channel, COM=0, UNI=1, SLP=0
	STB_Send_Receive_LTC1863(0x84 + (channel << 4));

	usleep(5); // max 3.5 us conversion time

	// SD=1, OS:S1:S0=000, COM=0, UNI=1, SLP=0
	uint16_t value = STB_Send_Receive_LTC1863(0x82);

	usleep(5); // wait dummy conversion

	return value;
}


// --- DAC AD5318 --------------------------------------------------------

void STB_Send_AD5318(uint16_t data)
{
	// force chip select
	IOWR_ALTERA_AVALON_SPI_CONTROL(SPI_EXTERNAL_BASE, ALTERA_AVALON_SPI_CONTROL_SSO_MSK);

	// discharge any stale data
	IORD_ALTERA_AVALON_SPI_RXDATA(SPI_EXTERNAL_BASE);

	// send 16 bit data
	SPI_send((uint8_t)(data>>8));
	SPI_send((uint8_t)data);

	// Wait until the interface has finished transmitting
	alt_u32 status;
	do { status = IORD_ALTERA_AVALON_SPI_STATUS(SPI_EXTERNAL_BASE); }
	while ((status & ALTERA_AVALON_SPI_STATUS_TMT_MSK) == 0);

	// release chipselect
	IOWR_ALTERA_AVALON_SPI_CONTROL(SPI_EXTERNAL_BASE, 0);
	usleep(2);

}


void STB_InitDAC(uint8_t dac)
{
	if (dac > 2) return;

	// enter SPI mode and set slave address = 2 + dac (CPHA=1)
	Enter_SPI_mode(0xa + dac);
	IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_EXTERNAL_BASE, 1);

	STB_Send_AD5318(0x8000); // GAIN=00, BUF=00, VDD=00
	STB_Send_AD5318(0xa000); // LDAC Low (continous update)
	STB_Send_AD5318(0xc000); // all channels powered
}


void STB_SetDAC(uint8_t dac, uint8_t channel, uint16_t data)
{
	if (dac > 3 || channel > 7) return;

	// enter SPI mode and set slave address = 2 + dac (CPHA=1)
	Enter_SPI_mode(0xa+dac);
	IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_EXTERNAL_BASE, 1);

	// prepare data word
	uint16_t x = ((uint16_t)channel << 12) + ((data&0x3ff) << 2);
	STB_Send_AD5318(x);
}


// --- Relays Driver MAX4820 ---------------------------------------------

void STB_SetHV(uint8_t data)
{
	// enter SPI mode and set slave address = 0 (CPHA=0)
	Enter_SPI_mode(0x0);
	IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_EXTERNAL_BASE, 1);

	// discharge any stale data
	IORD_ALTERA_AVALON_SPI_RXDATA(SPI_EXTERNAL_BASE);

	// send 8 bit data
	SPI_send(data);
}


// --- Bus Expander PCA8575 ----------------------------------------------

uint8_t STB_WritePort(uint16_t data)
{
	Enter_I2C_mode();

	uint8_t error = STB_PORT_OK;
	int res;

	// send device id
	IOWR_8DIRECT(I2C_EXTERNAL_BASE, TXR, 0x40); // slave address = 0x20
	IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, STA|WR);
	while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
	if (res & RxACK) error = STB_PORT_NOT_PRESENT;

	// send port data P0x
	IOWR_8DIRECT(I2C_EXTERNAL_BASE, TXR, data);
	IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, WR);
	while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);

	// send port data P1x
	IOWR_8DIRECT(I2C_EXTERNAL_BASE, TXR, data>>8);
	IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, WR|STO);
	while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);

	return error;
}


uint8_t STB_ReadPort(uint16_t &data)
{
	Enter_I2C_mode();

	uint8_t error = STB_PORT_OK;
	int res;
	uint16_t d1, d2;

	// send device id
	IOWR_8DIRECT(I2C_EXTERNAL_BASE, TXR, 0x41); // slave address = 0x20
	IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, STA|WR);
	while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
	if (res & RxACK) error = STB_PORT_NOT_PRESENT;

	// read port data P0x
    IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, RD|ACK);
    while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
    d1 = IORD_8DIRECT(I2C_EXTERNAL_BASE, RXR);

	// read port data P1x
    IOWR_8DIRECT(I2C_EXTERNAL_BASE, CR, RD|STO);
    while ((res = IORD_8DIRECT(I2C_EXTERNAL_BASE, SR)) & TIP);
    d2 = IORD_8DIRECT(I2C_EXTERNAL_BASE, RXR);

    data = d1 + (d2 << 8);
	return error;
}
