// dtb_config.cc

#include <string.h>
#include "dtb_config.h"
#include "fatfs.h"


DTB_CONFIG dtbConfig;


void DTB_CONFIG::Init()
{
	board = 0;
	hw_version = "";
	usb_id = "";
	mac_address = 0;
	hostname = "";
	comment = "";
}


int DTB_CONFIG::GetInt(char *s)
{
	return atoi(s);
}


unsigned long long DTB_CONFIG::GetULL(char *s, int base)
{
	return strtoull(s, 0, base);
}


char* DTB_CONFIG::GetString(char *s)
{
	char *str1 = strchr(s, '"'); if (str1 == 0) return "";
	str1++;
	char *str2 = strchr(str1, '"'); if (str2 == 0) return "";
	*str2 = 0;
	return str1;
}



FATFS fatFs;

bool DTB_CONFIG::Read(const char *filename)
{
	char line[256];

	FIL f;
	if (f_mount(0, &fatFs) != FR_OK)
	{
		printf("Mounting SD Card failed!\n");
		return false;
	}

	if (f_open(&f, filename, FA_OPEN_EXISTING | FA_READ) != FR_OK)
	{
		printf("Open file %s failed!\n", filename);
		return false;
	}

	char *tag, *par;
	while (f_gets(line, 255, &f))
	{
		tag = strchr(line, '['); if (tag == 0) continue;
		tag++;
		par = strchr(tag,  ']'); if (par == 0) continue;
		*par = 0; par++;

		// Check if Line is a known parameter (if so convert it to an appropiate value)
		if     (strcmp(tag, "BOARD")       == 0) board = GetInt(par);
		else if(strcmp(tag, "HW-VERSION")  == 0) hw_version = GetString(par);
		else if(strcmp(tag, "USB-ID")      == 0) usb_id = GetString(par);
		else if(strcmp(tag, "MAC-ADDRESS") == 0) mac_address = GetULL(par, 16);
		else if(strcmp(tag, "HOSTNAME")    == 0) hostname = GetString(par);
		else if(strcmp(tag, "COMMENT")     == 0) comment = GetString(par);
	}

	f_close(&f);
	return true;
}

