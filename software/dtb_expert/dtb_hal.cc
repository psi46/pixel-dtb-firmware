// atb_base.cc
// 10.1.2006

#include <unistd.h>
#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "dtb_hal.h"

// === I2C ==================================================================

void I2C_Main_Init()
{
  IOWR_8DIRECT(I2C_MAIN_BASE, CTR,     0);    // disable i2c controller
  IOWR_8DIRECT(I2C_MAIN_BASE, PRERlo, 79);    // prescaler = 79 (100kHz)
  IOWR_8DIRECT(I2C_MAIN_BASE, PRERhi,  0);
  IOWR_8DIRECT(I2C_MAIN_BASE, CTR,    EN);    // enable i2c controller
}


void Adv3224Init()
{
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

void CUSB::WriteByte(unsigned char value)
{
	if(IsTxFull()) IOWR_16DIRECT(USB_BASE, 0, write_buffer);
	write_buffer = value;
}


void CUSB::Flush()
{
	IOWR_16DIRECT(USB_BASE, 0, (0x8000|write_buffer));
	write_buffer = 0x8000;
}


bool CUSB::RxFull()
{
	if(!IsRxFull())
	{
		read_buffer = IORD_16DIRECT(USB_BASE, 0);
		return IsRxFull();
	}
	return true;
}


bool CUSB::ReadByte(unsigned char &value)
{
	if (IsRxFull())
	{
		value = (unsigned char)read_buffer;
		read_buffer = IORD_16DIRECT(USB_BASE, 0);
		return true;
	}

	for (int count = 500000; count > 0; count--)
	{
		read_buffer = IORD_16DIRECT(USB_BASE, 0);
		if (IsRxFull())
		{
			value = (unsigned char)read_buffer;
			read_buffer = IORD_16DIRECT(USB_BASE, 0);
			return true;
		}
		usleep(1);
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


bool CUSB::Write(const void *buffer, unsigned int size)
{
	unsigned int i;
	const unsigned char *p = (const unsigned char*)buffer;
	for (i=0; i<size; i++) WriteByte(*(p++));
	return true;
}

bool CUSB::IsOpen(){
	short status = IORD_16DIRECT(USB_BASE, 0);
	if((status & 0x8000)){
		return false;
	} else{
		read_buffer = status;
		return true;
	}
}

