// ethernet.h

#include "rpc_io.h"
#pragma once

class Ethernet : public CRpcIo
{
	bool initiated;
public:
	Ethernet();
	bool RxFull();
	bool RxEmpty();
	bool Write(const void *buffer, unsigned int size);
	void Flush();
	bool Read(void *buffer, unsigned int size);
};
