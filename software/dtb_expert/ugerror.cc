// Error.cpp

#include "ugerror.h"

CUGError flash_error;

const char* CUGError::GetErrorMsg()
{
	switch (id)
	{
		case ERR_OK:          return "No error";
		case ERR_VERSION:     return "Wrong upgrade version";
		case ERR_HDR:         return "Wrong header";
		case ERR_FORMAT:      return "Missing hex number";
		case ERR_ID:          return "Wrong header id";
		case ERR_HEX:         return "Wrong hex number";
		case ERR_CHKSUM:      return "Wrong checksum";
		case ERR_SIZE:        return "Incorrect size";
		case ERR_RECCOUNT:    return "Wrong number of records";
		case ERR_MEMASSIGN:   return "Cannot assign memory space";
		case ERR_EMPTYWRITE:  return "No bytes to write";
		case ERR_ADDR_RANGE:  return "Address out of range";
		case ERR_FLASHACCESS: return "Cannot access flash memory";
		case ERR_FLASHWRITE:  return "Flash write";
		case ERR_USB:         return "USB remote call";
	}
	return "???";
}
