// i2c.cc

#include "i2c.h"


void I2C_Init()
{
  IOWR_8DIRECT(I2C_BASE, CTR,     0);    // disable i2c controller
  IOWR_8DIRECT(I2C_BASE, PRERlo, 79);    // prescaler = 79 (100kHz)
  IOWR_8DIRECT(I2C_BASE, PRERhi,  0);
  IOWR_8DIRECT(I2C_BASE, CTR,    EN);    // enable i2c controller
}



void InitDac()
{
	int res;
	// --- 0111100(0) 1 11110000 1 00111100

	// send slave address 0x3c
	IOWR_8DIRECT(I2C_BASE, TXR, 0x78);
	IOWR_8DIRECT(I2C_BASE, CR,  STA|WR);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);

    // switch to extended command
	IOWR_8DIRECT(I2C_BASE, TXR, 0xf0);
	IOWR_8DIRECT(I2C_BASE, CR,  WR);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);

    // all channels power up
	IOWR_8DIRECT(I2C_BASE, TXR, 0x3c);
	IOWR_8DIRECT(I2C_BASE, CR,  WR|STO);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);
}


void SetDac(int channel, int value)
{
	int res;
	value &= 0x3ff;

	// send slave address 0x3d
	IOWR_8DIRECT(I2C_BASE, TXR, 0x78);
	IOWR_8DIRECT(I2C_BASE, CR,  STA|WR);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);

	// load dac addr and data D9...D6
	IOWR_8DIRECT(I2C_BASE, TXR, ((channel&3)<<4) | (value>>6));
	IOWR_8DIRECT(I2C_BASE, CR,  WR);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);

	// send data D5...D0
	IOWR_8DIRECT(I2C_BASE, TXR, value <<2);
	IOWR_8DIRECT(I2C_BASE, CR,  WR|STO);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);
}


unsigned int ReadADC(unsigned char channel)
{
	int res;
	// send slave address 0x35
	IOWR_8DIRECT(I2C_BASE, TXR, 0x6a);
	IOWR_8DIRECT(I2C_BASE, CR,  STA|WR);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);

	// setup 11010010: internal reference, internal clock, unipolar
	IOWR_8DIRECT(I2C_BASE, TXR, 0xd2);
	IOWR_8DIRECT(I2C_BASE, CR,  WR);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);

	// configuration 011aaaa1: single channel addr, single ended
	IOWR_8DIRECT(I2C_BASE, TXR, 0x61|((channel&0x0f)<<1));
	IOWR_8DIRECT(I2C_BASE, CR,  WR);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);

	// send slave address 0x35 (read)
	IOWR_8DIRECT(I2C_BASE, TXR, 0x6b);
	IOWR_8DIRECT(I2C_BASE, CR,  STA|WR);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);

	// read D11...D8
	IOWR_8DIRECT(I2C_BASE, CR,  RD);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);
	unsigned int value = IORD_8DIRECT(I2C_BASE, RXR) & 0x0f;

	// read D7...D0
	IOWR_8DIRECT(I2C_BASE, CR,  RD|ACK|STO);
	while ((res = IORD_8DIRECT(I2C_BASE, SR)) & TIP);
	value = (value << 8) | IORD_8DIRECT(I2C_BASE, RXR);

	return value;
}

