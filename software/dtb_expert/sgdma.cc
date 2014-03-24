// sgdma.cc

#include <stdio.h>
#include "sgdma.h"
#include "sys/alt_cache.h"


#define SGDMA_NDESCRIPTORS DESCRIPTOR_MEMORY_SIZE_VALUE/32 - 4

// descriptors in descriptor_memory
alt_sgdma_descriptor descriptor[SGDMA_NDESCRIPTORS] __attribute__ (( section ( ".descriptor_memory" )));


CDma::CDma()
{
	device = alt_avalon_sgdma_open("/dev/usb_tx_dma");
	DeleteAllDescriptors();
}


alt_sgdma_descriptor* CDma::CreateDescriptor()
{
	if (pos >= SGDMA_NDESCRIPTORS) return 0;

	// create new descriptor
	alt_sgdma_descriptor *descr = descriptor + pos;
	pos++;

	// initialize as end descriptor
	descr->read_addr         = 0;
	descr->read_addr_pad     = 0;
	descr->write_addr        = 0;
	descr->write_addr_pad    = 0;
	descr->next              = 0;
	descr->next_pad          = 0;
	descr->bytes_to_transfer = 0;
	descr->actual_bytes_transferred = 0;
	descr->status            = 0;
	descr->read_burst        = 0;
	descr->write_burst       = 0;
	descr->control           = 0; // OWNED_BY_HW=0

//	alt_remap_uncached(descr, sizeof(alt_sgdma_descriptor));
	alt_dcache_flush(descr, sizeof(alt_sgdma_descriptor));
	return descr;
}


void CDma::DeleteAllDescriptors()
{
	pos = 0;
	first = last = CreateDescriptor();
}


bool CDma::Add(const void *buffer, uint32_t byte_size)
{
//	alt_remap_uncached((void*)buffer, byte_size);
	alt_dcache_flush((void*)buffer, byte_size);

	while (byte_size)
	{
		uint16_t size = (byte_size > 0xffff) ? 0xffff : byte_size;
		byte_size -= size;

		// create new end descriptor
		alt_sgdma_descriptor *endDescr = CreateDescriptor();
		if (!endDescr)
		{
			Send();
			endDescr = CreateDescriptor();
		}

		last->read_addr         = (alt_u32 *) buffer;
		last->next              = (alt_u32 *) endDescr;
		last->bytes_to_transfer = size;
		last->control =
			ALTERA_AVALON_SGDMA_DESCRIPTOR_CONTROL_OWNED_BY_HW_MSK |
			ALTERA_AVALON_SGDMA_DESCRIPTOR_CONTROL_WRITE_FIXED_ADDRESS_MSK | // SOP
			ALTERA_AVALON_SGDMA_DESCRIPTOR_CONTROL_GENERATE_EOP_MSK;

//		alt_remap_uncached(last, sizeof(alt_sgdma_descriptor));
		alt_dcache_flush(last, sizeof(alt_sgdma_descriptor));
		last = endDescr;
	}
	return true;
}

/*
void CDma::DumpDescriptorChain()
{
	alt_sgdma_descriptor *p = first;
	int cnt = 0;
	while (p->control & ALTERA_AVALON_SGDMA_DESCRIPTOR_CONTROL_OWNED_BY_HW_MSK && cnt < 10)
	{
		unsigned char *buffer = (unsigned char *)p->read_addr;
		unsigned int size = p->bytes_to_transfer;
		printf("DMA descr %08X(%u) %02X:", (unsigned int)buffer, size, int(p->control));
		for (unsigned int i=0; i<size; i++) printf(" %02X", int(buffer[i]));
		printf("\n");
		p = (alt_sgdma_descriptor*)p->next;
		cnt++;
	}
}
*/


void CDma::Send()
{
	if (device && (pos >= 2)) alt_avalon_sgdma_do_sync_transfer(device, first);
	DeleteAllDescriptors();
}
