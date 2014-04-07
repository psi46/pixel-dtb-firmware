// sgdma.h


#ifndef SGDMA_H_
#define SGDMA_H_

#include "cstdint.h"
#include "altera_avalon_sgdma.h"


class CDma
{
	int pos;
	alt_sgdma_dev *device;
	alt_sgdma_descriptor *first;
	alt_sgdma_descriptor *last;
	alt_sgdma_descriptor* CreateDescriptor();
public:
	CDma();
	bool Add(const void *buffer, uint32_t byte_size);
	void Send();
	void DeleteAllDescriptors();
//	void DumpDescriptorChain();
};


#endif /* SGDMA_H_ */
