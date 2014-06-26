// rpc.cpp

#include <cstring>

#include "pixel_dtb.h"
#include "rpc.h"
#include <string.h>

class CBuffer
{
	uint8_t *p;
public:
	CBuffer(uint32_t size) { p = new uint8_t[size]; }
	~CBuffer() { delete[] p; }
	uint8_t* operator&() { return p; }
};


CRpcError rpc_error;


int32_t rpc_GetRpcCallId(string &cmdName)
{
	for (uint16_t i = 0; i<rpc_cmdListSize; i++)
	{
		if (strcmp(cmdName.c_str(), rpc_cmdlist[i].name) == 0) return i;
	}
	return -1;
}



bool rpcMessage::SendCmd()
{
	uint32_t size = m_pos;
	m_data.header += size << 24; // set size field in header
	io->Write(&m_data, size+4);  // header + data field
	RETURN_OK
}


bool rpcMessage::RecvCmd()
{
	if (!io->Read(&m_data.header, sizeof(m_data.header))) THROW(TIMEOUT)
	if (GetType() == RPC_TYPE_DTB)
	{ // read command parameter
		m_pos = GetCmdSize();
		if (m_pos) if (!io->Read(&m_data.par, m_pos)) THROW(TIMEOUT)
	}
	else if (GetType() == RPC_TYPE_DTB_DATA)
	{ // discharge unexpected data fields
		uint32_t size = GetDatSize();
		DataSink(size);
		THROW(NO_CMD_MSG)
	}
	else if (GetType() == RPC_TYPE_DTB_DATA_OLD)
	{ // discharge unexpected old style data fields
		uint32_t size = GetOldDatSize();
		DataSink(size);
		THROW(NO_CMD_MSG)
	}
	else THROW(WRONG_MSG_TYPE)

	RETURN_OK
}


bool rpcMessage::SendDat(uint32_t &hdr, const void *buffer, uint32_t size)
{
	if (size > 0xffffff) size = 0xffffff;
	hdr = (size << 8) + RPC_TYPE_DTB_DATA;
	io->Write(&hdr, sizeof(uint32_t));
	io->Write(buffer, size);
	RETURN_OK
}


bool rpcMessage::RecvDat()
{
	if (!io->Read(&m_data.header, sizeof(m_data.header))) THROW(TIMEOUT)
	if (GetType() == RPC_TYPE_DTB_DATA)
	{

	}
	else if (GetType() == RPC_TYPE_DTB)
	{ // discharge unexpected command messages
		uint32_t size = GetCmdSize();
		DataSink(size);
		THROW(NO_DATA_MSG)
	}
	else if (GetType() == RPC_TYPE_DTB_DATA_OLD)
	{ // discharge unexpected old style data fields
		uint32_t size = GetOldDatSize();
		DataSink(size);
		THROW(WRONG_MSG_TYPE)
	}
	else THROW(WRONG_MSG_TYPE)

	RETURN_OK
}


bool rpcMessage::RecvString(string &x)
{
	if (!RecvDat()) return false;
	uint32_t size = GetDatSize();
	x.clear();
	x.reserve(size);
	char ch;
	for (uint8_t i=0; i<size; i++)
	{
		if (!io->Read(&ch, 1)) THROW(TIMEOUT)
		x.push_back(ch);
	}
	RETURN_OK
}


void rpcMessage::DataSink(uint32_t size)
{
	if (size == 0) return;
	CBuffer buffer(size);
	io->Read(&buffer, size);
}

