// rpc.h

#pragma once


#include <vector>
#include <string>
#include "cstdint.h"

#include "rpc_io.h"
#include "dtb_hal.h"
#include "rpc_error.h"

using namespace std;

#define RPC_DTB_VERSION 0x0100

#define RPC_TYPE_ATB      0x8F
#define RPC_TYPE_DTB      0xC0
#define RPC_TYPE_DTB_DATA 0xC1

#define RPC_EXPORT


extern const char rpc_timestamp[];


// replacement for C++ throw
#define THROW(erx) { rpc_error.error = CRpcError::erx; return false; }
#define RETURN_OK rpc_error.error = CRpcError::OK; return true;
extern CRpcError rpc_error;

class rpcMessage;

struct CRpcCall
{
	bool (*call)(CRpcIo &, rpcMessage &);
	char *name;
};

extern const uint16_t rpc_cmdListSize;
extern const CRpcCall rpc_cmdlist[];

inline uint16_t rpc_GetRpcVersion() { return RPC_DTB_VERSION; }
int32_t  rpc_GetRpcCallId(string &cmdName);

void rpc_Dispatcher(CRpcIo &rpc_io);


class CBuffer
{
	uint8_t *p;
public:
	CBuffer(uint16_t size) { p = new uint8_t[size]; }
	~CBuffer() { delete[] p; }
	uint8_t* operator&() { return p; }
};


// === message ==============================================================

class rpcMessage
{
	uint8_t m_pos;

	uint8_t  m_type;
	uint16_t m_cmd;
	uint8_t  m_size;
	uint8_t  m_par[256];
public:
	uint16_t GetCmd() { return m_cmd; }

	void Create(uint16_t cmd);
	void Put_INT8(int8_t x) { m_par[m_pos++] = int8_t(x); m_size++; }
	void Put_UINT8(uint8_t x) { m_par[m_pos++] = x; m_size++; }
	void Put_BOOL(bool x) { Put_UINT8(x ? 1 : 0); }
	void Put_INT16(int16_t x) { Put_UINT8(uint8_t(x)); Put_UINT8(uint8_t(x>>8)); }
	void Put_UINT16(uint16_t x) { Put_UINT8(uint8_t(x)); Put_UINT8(uint8_t(x>>8)); }
	void Put_INT32(int32_t x) { Put_UINT16(uint16_t(x)); Put_UINT16(uint16_t(x>>16)); }
	void Put_UINT32(int32_t x) { Put_UINT16(uint16_t(x)); Put_UINT16(uint16_t(x>>16)); }
	void Put_INT64(int64_t x) { Put_UINT32(uint32_t(x)); Put_UINT32(uint32_t(x>>32)); }
	void Put_UINT64(uint64_t x) { Put_UINT32(uint32_t(x)); Put_UINT32(uint32_t(x>>32)); }

	bool Send(CRpcIo &rpc_io);
	bool Receive(CRpcIo &rpc_io);
	bool CheckSize(uint8_t size)
	{ if (m_size != size) THROW(CMD_PAR_SIZE) RETURN_OK }

	int8_t Get_INT8() { return int8_t(m_par[m_pos++]); }
	uint8_t Get_UINT8() { return uint8_t(m_par[m_pos++]); }
	bool Get_BOOL() { return Get_UINT8() != 0; }
	int16_t Get_INT16() { int16_t x = Get_UINT8(); x += (uint16_t)Get_UINT8() << 8; return x; }
	uint16_t Get_UINT16() { uint16_t x = Get_UINT8(); x += (uint16_t)Get_UINT8() << 8; return x; }
	int32_t Get_INT32() { int32_t x = Get_UINT16(); x += (uint32_t)Get_UINT16() << 16; return x; }
	uint32_t Get_UINT32() { uint32_t x = Get_UINT16(); x += (uint32_t)Get_UINT16() << 16; return x; }
 	int64_t Get_INT64() { int64_t x = Get_UINT32(); x += (uint64_t)Get_UINT32() << 32; return x; }
	uint64_t Get_UINT64() { uint64_t x = Get_UINT32(); x = (uint64_t)Get_UINT32() << 32; return x; }
};


// === data =================================================================

#define vectorR vector
#define stringR string


class CDataHeader
{
public:
	uint8_t m_type;
	uint8_t m_chn;
	uint16_t m_size;

	bool RecvHeader(CRpcIo &rpc_io);
	bool RecvRaw(CRpcIo &rpc_io, void *x)
	{
		if (m_size) if (!rpc_io.Read(x, m_size)) THROW(CMD_PAR_SIZE)
		RETURN_OK;
	}
};

bool rpc_SendRaw(CRpcIo &rpc_io, uint8_t channel, const void *x, uint16_t size);

void rpc_DataSink(CRpcIo &rpc_io, uint16_t size);


template <class T>
inline bool rpc_Send(CRpcIo &rpc_io, const vector<T> &x)
{
	return rpc_SendRaw(rpc_io, 0, &(x[0]), sizeof(T)*x.size());
}


template <class T>
bool rpc_Receive(CRpcIo &rpc_io, vector<T> &x)
{
	CDataHeader msg;
	if (!msg.RecvHeader(rpc_io)) return false;
	if ((msg.m_size % sizeof(T)) != 0)
	{
		rpc_DataSink(rpc_io, msg.m_size);
		THROW(WRONG_DATA_SIZE);
	}
	x.assign(msg.m_size/sizeof(T), 0);
	if (!rpc_io.Read(&(x[0]), msg.m_size)) THROW(TIMEOUT)
	RETURN_OK
}


inline bool rpc_Send(CRpcIo &rpc_io, const string &x)
{
	return rpc_SendRaw(rpc_io, 0, x.c_str(), x.length());
}


bool rpc_Receive(CRpcIo &rpc_io, string &x);
