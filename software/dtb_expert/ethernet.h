// ethernet.h

#include "rpc_io.h"
#pragma once

class CEthernet : public CRpcIo
{
public:
	CEthernet();
	~CEthernet();
	void Reset();
	bool RxFull();
	bool RxEmpty();
	bool Write(const void *buffer, unsigned int size);
	void Flush();
	bool Read(void *buffer, unsigned int size);
	bool IsOpen();
private:
	bool initiated; //Signals that hardware is properly initiated
};
