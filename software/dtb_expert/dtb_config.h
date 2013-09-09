// dtb_config.h

#pragma once

#include <string>

using namespace std;

#define fw_version 0x0101
#define sw_version 0x0107


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
