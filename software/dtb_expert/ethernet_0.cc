// ethernet_0.cc

#include "system.h"
#include "io.h"

#include <sys/alt_irq.h>
#include <sys/alt_cache.h>

#include "pixel_dtb.h"




bool CTestboard::Ethernet_Init()
{
	return true;
}


void CTestboard::Ethernet_Send(string &message)
{
}


uint32_t CTestboard::Ethernet_RecvPackets()
{
	return 0;
}




