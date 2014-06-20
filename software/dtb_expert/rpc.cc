// rpc.cpp

#include <cstring>

#include "pixel_dtb.h"
#include "rpc.h"

CRpcError rpc_error;

void rpcMessage::Create(uint16_t cmd)
{
	m_type = RPC_TYPE_DTB;
	m_cmd = cmd;
	m_size = 0;
	m_pos = 0;
}


bool rpcMessage::Send(CRpcIo &rpc_io)
{
	rpc_io.Write(&m_type, 1);
	rpc_io.Write(&m_cmd,  2);
	rpc_io.Write(&m_size, 1);
	if (m_size) rpc_io.Write(m_par, m_size);
	RETURN_OK
}


bool rpcMessage::Receive(CRpcIo &rpc_io)
{
	m_pos = 0;
	if (!rpc_io.Read(&m_type, 1)) THROW(TIMEOUT)
	if ((m_type & 0xfe) != RPC_TYPE_DTB) THROW(WRONG_MSG_TYPE)
	if (m_type & 0x01)
	{ // remove unexpected data message from queue
		uint8_t  chn;
		uint16_t size;
		rpc_io.Read(&chn, 1);
		rpc_io.Read(&size, 2);
		rpc_DataSink(rpc_io, size);
		THROW(NO_CMD_MSG)
	}
	if (!rpc_io.Read(&m_cmd, 2)) THROW(TIMEOUT)
	if (!rpc_io.Read(&m_size, 1)) THROW(TIMEOUT)
	if (m_size)	if (!rpc_io.Read(m_par, m_size)) THROW(TIMEOUT)
	RETURN_OK
}


int32_t  rpc_GetRpcCallId(string &cmdName)
{
	for (uint16_t i = 0; i<rpc_cmdListSize; i++)
	{
		if (strcmp(cmdName.c_str(), rpc_cmdlist[i].name) == 0) return i;
	}
	return -1;
}


// === data =================================================================


bool CDataHeader::RecvHeader(CRpcIo &rpc_io)
{
	if (!rpc_io.Read(&m_type, 1)) THROW(TIMEOUT)
	if ((m_type & 0xfe) != RPC_TYPE_DTB) THROW(WRONG_MSG_TYPE)
	if ((m_type & 0x01) == 0)
	{ // remove unexpected command message from queue
		uint16_t cmd;
		uint8_t size;
		rpc_io.Read(&cmd, 2);
		rpc_io.Read(&size, 1);
		rpc_DataSink(rpc_io, size);
		THROW(NO_DATA_MSG)
	}
	rpc_io.Read(&m_chn, 1);
	if (!rpc_io.Read(&m_size, 2))    THROW(TIMEOUT)
	RETURN_OK
}



bool rpc_SendRaw(CRpcIo &rpc_io, uint8_t channel, const void *x, uint16_t size)
{
	uint8_t value = RPC_TYPE_DTB_DATA;
	rpc_io.Write(&value, 1);
	rpc_io.Write(&channel, 1);
	rpc_io.Write(&size, 2);
	if (size) rpc_io.Write(x, size);
	RETURN_OK
}


void rpc_DataSink(CRpcIo &rpc_io, uint16_t size)
{
	if (size == 0) return;
	CBuffer buffer(size);
	rpc_io.Read(&buffer, size);
}


bool rpc_Receive(CRpcIo &rpc_io, string &x)
{
	CDataHeader msg;
	if (!msg.RecvHeader(rpc_io)) return false;
	x.clear();
	x.reserve(msg.m_size);
	char ch;
	for (uint8_t i=0; i<msg.m_size; i++)
	{
		if (!rpc_io.Read(&ch, 1)) THROW(TIMEOUT)
		x.push_back(ch);
	}
	RETURN_OK
}



bool AtbMessage(CRpcIo &rpc_io)
{
	THROW(ATB_MSG)
}

bool UnknownMessage(CRpcIo &rpc_io, rpcMessage &msg)
{
	THROW(MSG_UNKNOWN)
}

bool CmdUnknown(CRpcIo &rpc_io, rpcMessage &msg)
{
	THROW(UNKNOWN_CMD)
}


void rpc_SendError(CRpcIo &rpc_io)
{
//	printf("ERROR(exec): %s\n", rpc_error.GetMsg());
/*	rpcMessage msg;
	msg.Create(31, 0); // error message
	msg.Put_INT16(rpc_error.error);
	msg.Send(rpc_io);
*/
}
