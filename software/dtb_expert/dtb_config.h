// dtb_config.h

#pragma once

#include <string>

using namespace std;

#define VERSION(ver,subver) 256*ver+subver

#define fw_version VERSION(1,10)  // Quartus design version
#define sw_version VERSION(1,26)  // NIOS II software version


struct DTB_CONFIG
{
	int board;
	string hw_version;
	string usb_id;
	unsigned long long mac_address;
	string hostname;
	string comment;

	void Init();
	bool Read(const char *filename);
private:
	static int GetInt(char *s);
	static unsigned long long GetULL(char *s, int base = 10);
	static char * GetString(char *s);
};

extern DTB_CONFIG dtbConfig;
