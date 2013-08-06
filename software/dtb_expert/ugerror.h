// Error.h

#ifndef ERROR_H
#define ERROR_H


class CUGError
{
public:
	enum ErrorNr
	{ 
	  ERR_OK=0, ERR_VERSION,
	  ERR_FORMAT, ERR_HDR, ERR_ID, ERR_HEX, ERR_CHKSUM, ERR_SIZE, ERR_RECCOUNT,
	  ERR_MEMASSIGN, ERR_EMPTYWRITE, ERR_ADDR_RANGE,
	  ERR_FLASHACCESS, ERR_FLASHWRITE,
	  ERR_USB
	};
	CUGError() : id(ERR_OK) {}
	CUGError(ErrorNr errorNr) : id(errorNr) {}
	void Reset() { id = ERR_OK; }
	bool IsError() { return id != ERR_OK; }
	ErrorNr GetErrorNr() { return id; }
	const char* GetErrorMsg();
private:
	ErrorNr id;
};

extern CUGError flash_error;
#define THROW_UG(error) { flash_error = CUGError(CUGError::error); return; }
#define THROW_UGR(error, ret) { flash_error = CUGError(CUGError::error); return ret; }
#define IS_ERROR_UG flash_error.IsError()

#endif
