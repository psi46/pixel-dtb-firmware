// FlashMemory.cpp

#include <stdio.h>
#include <string.h>
#include "ugerror.h"
#include "FlashMemory.h"
#include "pixel_dtb.h"
#include <sys/alt_flash.h>


void CFlashMemory::Assign(unsigned long memsize)
{
	Unassign();
	mem = new unsigned char[memsize];
	if (!mem) THROW_UG(ERR_MEMASSIGN)

	memset(mem,0xff, memsize);
	size = memsize;
	min = memsize;
	max = 0;
}


void CFlashMemory::Set(unsigned long addr, unsigned long value)
{
	if (addr >= size) THROW_UG(ERR_ADDR_RANGE)
	if (addr < min) min = addr;
	if (addr > max) max = addr;
	mem[addr] = (unsigned char)(value);
}


void CFlashMemory::Set(unsigned long addr, unsigned long count, unsigned long value[])
{
	unsigned long i;
	for (i=0; i<count; i++)
	{
		Set(addr++, value[i]);
		if (IS_ERROR_UG) return;
	}
}


void CFlashMemory::WriteFlash()
{
	if (size == 0 || max < min) { tb.SetLed(1); THROW_UG(ERR_EMPTYWRITE) }

	unsigned long writeSize = max - min + 1;
	if (size >= 4000000) { tb.SetLed(2); THROW_UG(ERR_EMPTYWRITE) }

	alt_flash_fd *epcs = alt_flash_open_dev(EPCS_CONTROLLER_NAME);
	if (epcs)
	{
		tb.SetLed(15);

		if (alt_write_flash(epcs, min, &(mem[min]), writeSize) != 0)
		{
			printf("Error writing EPCS flash!\n");
			tb.SetLed(0x9);
		} else tb.SetLed(0);
		alt_flash_close_dev(epcs);
	}
	else printf("ERROR (no EPCS FLASH access)\n");
}
