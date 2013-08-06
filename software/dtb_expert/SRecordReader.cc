// SRecordReader.cpp

#include <stdio.h>
#include "SRecordReader.h"
#include "ugerror.h"


unsigned long CSRecordReader::GetHeader(const char *&s)
{
	if (*s != 'S') THROW_UGR(ERR_HDR, 0)
	s++;
	char x = *s - '0';
	s++;
	if (x<0 || x>9) THROW_UGR(ERR_HDR, 0)
	return x;
}


unsigned long CSRecordReader::GetHex1(const char *&s)
{
	if (*s == 0 || *s == '\r' || *s == '\n') THROW_UGR(ERR_FORMAT, 0)

	char ch = *s - '0';
 	if (ch < 0) THROW_UGR(ERR_HEX, 0)
	if (ch <= 9) { s++; return ch; }
	ch += ('0' - 'A' + 10);
	if (ch < 10 || ch >= 16) THROW_UGR(ERR_HEX, 0)
	s++;
	return ch;
}


unsigned long CSRecordReader::GetHex2(const char *&s)
{
	unsigned long x = GetHex1(s) << 4;
	x += GetHex1(s);
	checksum += x;
	return x;
}


unsigned long CSRecordReader::GetHex4(const char *&s)
{
	unsigned long x = GetHex2(s) << 8;	
	return x + GetHex2(s);
}


unsigned long CSRecordReader::GetHex8(const char *&s)
{
	unsigned long x = GetHex4(s) << 16;	
	return x + GetHex4(s);
}


/* S-Records
S0 06 0000 2D 45 4C  3B

S3 25 00029008 B0 97 01 00 20 00 00 00 14 00 82 00 33 00 00 10
               04 FF BF 10 16 FD BF 00 34 00 C1 06 14 00 C0 DE  AE
*/

void CSRecordReader::Read(const char *s)
{
	checksum = 0;

	type = GetHeader(s); if (IS_ERROR_UG) return;
	size = GetHex2(s);   if (IS_ERROR_UG) return;

	switch (type)
	{
	case 0:
		if (size < 3) THROW_UG(ERR_SIZE)
		size -= 3;
		address = GetHex4(s);
		break;
	case 3:
		if (size < 5) THROW_UG(ERR_SIZE)
		size -= 5;
		address = GetHex8(s);
		break;
	case 7:
		break;
	default:  THROW_UG(ERR_ID)
	}

	if (size > 64) THROW_UG(ERR_SIZE)
	for (unsigned int i=0; i<size; i++)
	{
		data[i] = GetHex2(s);
		if (IS_ERROR_UG) return;
	}

	GetHex2(s); // complete checksum
	if ((checksum & 0xff) != 0xff) THROW_UG(ERR_CHKSUM)
}


void CSRecordReader::Translate(const char *s, CFlashMemory &memory)
{
	Read(s);
	if (IS_ERROR_UG) return;

	if (type == 3) memory.Set(address, size, data);
}
