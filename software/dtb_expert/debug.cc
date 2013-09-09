// debug.cc

#include <stdio.h>
#include <sys\alt_flash.h>
#include "system.h"


void Dump(unsigned char *data, unsigned int size)
{
	unsigned int i, k = 0;
	for (i=0; i<size; i++)
	{
		printf(" %02X", data[i]);
		if (k<16) k++; else { printf("\n"); k = 0;  }
	}
	printf("\n");
}


void check_epcs()
{
	alt_flash_fd *epcs;
	flash_region *regions;
	int number_of_regions;

	printf("EPCS: ");

	epcs = alt_flash_open_dev(EPCS_CONTROLLER_NAME);
	if (epcs)
	{
		alt_get_flash_info(epcs, &regions, &number_of_regions);
		if (number_of_regions == 1 && regions->offset == 0)
		{
			printf("ok\n");
			unsigned char buffer[1024];
			alt_read_flash(epcs, 0x1000, buffer, 1024);
//			Dump(buffer, 1024);
		}
		else
			printf("ERROR (wrong geometry)\n");

		printf("#regions: %i\n", number_of_regions);
		if (number_of_regions > 0)
		{
			printf("region 0\n");
			printf("  block size:       %i\n", regions->block_size);
			printf("  number of blocks: %i\n", regions->number_of_blocks);
			printf("  offset:           %i\n", regions->offset);
			printf("  size:             %i\n", regions->region_size);
		}
	}
	else printf("ERROR (no access)\n");

	alt_flash_close_dev(epcs);
}


int epcs_write(unsigned char *buffer, unsigned int offset, unsigned int size)
{
	alt_flash_fd *epcs;
	flash_region *regions;
	int number_of_regions;

	epcs = alt_flash_open_dev(EPCS_CONTROLLER_NAME);
	if (!epcs) return 1;
	alt_get_flash_info(epcs, &regions, &number_of_regions);
	if (number_of_regions == 1 && regions->offset == 0)
	{
		alt_flash_close_dev(epcs);
		return 2;
	}

	// --- delete flash
	int p = (offset % regions->block_size) * regions->block_size;
	int memend = offset + size;
	if (memend >= regions->region_size)
	{
		alt_flash_close_dev(epcs);
		return 3;
	}

	while (p < memend)
	{
		alt_erase_flash_block(epcs, p, regions->block_size);
		p += regions->block_size;
	}

	// --- program flash
	alt_write_flash_block(epcs, p, offset, buffer, 256);

	return 0;
}
