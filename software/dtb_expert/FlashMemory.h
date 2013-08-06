// FlashMemory.h

#pragma once


class CFlashMemory
{
	unsigned long size;
	unsigned long min;
	unsigned long max;
	unsigned char *mem;

public:
	CFlashMemory() : size(0), mem(0) {}
	~CFlashMemory() { Unassign(); }
	void Assign(unsigned long memsize);
	void Unassign() {  if (mem) delete[] mem; mem = 0; size = 0; }
	void Set(unsigned long addr, unsigned long value);
	void Set(unsigned long addr, unsigned long count, unsigned long value[]);
	void WriteFlash();
};

