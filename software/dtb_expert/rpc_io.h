// rpc_io.h

#pragma once

class CRpcIo
{
protected:
	void Dump(const char *msg, const void *buffer, unsigned int size);
public:
	virtual ~CRpcIo() {}
	virtual bool RxFull() = 0;
	virtual bool Write(const void *buffer, unsigned int size) = 0;
	virtual void Flush() = 0;
	virtual bool Read(void *buffer, unsigned int size) = 0;
};
