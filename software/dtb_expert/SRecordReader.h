// SRecordReader.h

#ifndef SRECORDREADER_H
#define SRECORDREADER_H

#include "ugerror.h"
#include "FlashMemory.h"


class CSRecordReader  
{
	unsigned long checksum;

	unsigned long GetHeader(const char *&s);
	unsigned long GetHex1(const char *&s);
	unsigned long GetHex2(const char *&s);
	unsigned long GetHex4(const char *&s);
	unsigned long GetHex8(const char *&s);
public:
	void Read(const char *s);
	void Translate(const char *s, CFlashMemory &memory);

	// S-Record data fields
	unsigned long type;
	unsigned long size;
	unsigned long address;
	unsigned long data[64];
};


#endif
