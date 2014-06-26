// rpc.h

#pragma once


#include <vector>
#include <string>
#include "cstdint.h"

#include "rpc_io.h"
#include "dtb_hal.h"
#include "rpc_error.h"


using namespace std;

#define RPC_DTB_VERSION 0x0200

#define RPC_TYPE_ATB          0x8F
#define RPC_TYPE_DTB          0xC0
#define RPC_TYPE_DTB_DATA     0xC2
#define RPC_TYPE_DTB_DATA_OLD 0xC1

#define RPC_EXPORT


extern const char rpc_timestamp[];


// replacement for C++ throw
#define THROW(erx) { rpc_error.error = CRpcError::erx; return false; }
#define RETURN_OK rpc_error.error = CRpcError::OK; return true;
extern CRpcError rpc_error;

class rpcMessage;

struct CRpcCall
{
	bool (*call)(rpcMessage &);
	const char *name;
};

extern const uint16_t rpc_cmdListSize;
extern const CRpcCall rpc_cmdlist[];

inline uint16_t rpc_GetRpcVersion() { return RPC_DTB_VERSION; }
int32_t  rpc_GetRpcCallId(string &cmdName);

void rpc_Dispatcher(CRpcIo &rpc_io);




struct rpcMsgData
{
	uint32_t header;
	uint8_t  par[256];
};


class rpcMessage
{
	CRpcIo *io;
	rpcMsgData m_data;
	uint16_t m_pos;
public:
	void SetIo(CRpcIo &rpc_io) { io = &rpc_io; }
	CRpcIo& GetIo() { return *io; }
	// read header fields
	uint8_t  GetType() { return m_data.header & 0xff; }
	uint16_t GetCmd() { return (m_data.header >> 8) & 0xffff; }
	uint16_t GetCmdSize() { return (m_data.header >> 24) & 0xff; }
	uint32_t GetDatSize() { return m_data.header >> 8; }
	uint32_t GetOldDatSize() { return m_data.header >> 16; }

	// send command
	void CreateCmd(uint16_t cmd) { m_data.header = (cmd << 8) + RPC_TYPE_DTB; m_pos = 0; }
	void Put_INT8(int8_t x) { m_data.par[m_pos++] = int8_t(x); }
	void Put_UINT8(uint8_t x) { m_data.par[m_pos++] = x; }
	void Put_BOOL(bool x) { Put_UINT8(x ? 1 : 0); }
	void Put_INT16(int16_t x) { Put_UINT8(uint8_t(x)); Put_UINT8(uint8_t(x>>8)); }
	void Put_UINT16(uint16_t x) { Put_UINT8(uint8_t(x)); Put_UINT8(uint8_t(x>>8)); }
	void Put_INT32(int32_t x) { Put_UINT16(uint16_t(x)); Put_UINT16(uint16_t(x>>16)); }
	void Put_UINT32(int32_t x) { Put_UINT16(uint16_t(x)); Put_UINT16(uint16_t(x>>16)); }
	void Put_INT64(int64_t x) { Put_UINT32(uint32_t(x)); Put_UINT32(uint32_t(x>>32)); }
	void Put_UINT64(uint64_t x) { Put_UINT32(uint32_t(x)); Put_UINT32(uint32_t(x>>32)); }
	bool SendCmd();

	// receive command
	bool RecvCmd();
	bool CheckCmdSize(uint16_t size) // always call this function immediately after RecvCmd
	{ if (m_pos != size) THROW(CMD_PAR_SIZE) m_pos = 0; RETURN_OK }
	int8_t Get_INT8() { return int8_t(m_data.par[m_pos++]); }
	uint8_t Get_UINT8() { return uint8_t(m_data.par[m_pos++]); }
	bool Get_BOOL() { return Get_UINT8() != 0; }
	int16_t Get_INT16() { int16_t x = Get_UINT8(); x += (uint16_t)Get_UINT8() << 8; return x; }
	uint16_t Get_UINT16() { uint16_t x = Get_UINT8(); x += (uint16_t)Get_UINT8() << 8; return x; }
	int32_t Get_INT32() { int32_t x = Get_UINT16(); x += (uint32_t)Get_UINT16() << 16; return x; }
	uint32_t Get_UINT32() { uint32_t x = Get_UINT16(); x += (uint32_t)Get_UINT16() << 16; return x; }
 	int64_t Get_INT64() { int64_t x = Get_UINT32(); x += (uint64_t)Get_UINT32() << 32; return x; }
	uint64_t Get_UINT64() { uint64_t x = Get_UINT32(); x = (uint64_t)Get_UINT32() << 32; return x; }

	// send data
	bool SendDat(uint32_t &hdr, const void *buffer, uint32_t size);
	bool SendString(uint32_t &hdr, const string &x) { return SendDat(hdr, x.c_str(), x.length()); }

	// receive data
	bool RecvDat();
	bool RecvString(string &x);

	void Flush() { io->Flush(); }

	void DataSink(uint32_t size);
};



// === data messages templates ==============================================


#define HWvectorR HWvector
#define vectorR vector
#define stringR string


template <class T>
inline bool rpc_SendVector(rpcMessage &msg, uint32_t &hdr, const vector<T> &x)
{
	return msg.SendDat(hdr, &(x[0]), x.size()*sizeof(T));
}


template <class T>
bool rpc_RecvVector(rpcMessage &msg, vector<T> &x)
{
	if (!msg.RecvDat()) return false;
	uint32_t size = msg.GetDatSize();
	if ((size % sizeof(T)) != 0)
	{
		msg.DataSink(size);
		THROW(WRONG_DATA_SIZE);
	}
	x.assign(size/sizeof(T), 0);
	if (!msg.GetIo().Read(&(x[0]), size)) THROW(TIMEOUT)
	RETURN_OK
}

