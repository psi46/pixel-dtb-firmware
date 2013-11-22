// dtb_main.cc
// 3.4.2013

#include "pixel_dtb.h"
#include "dtb_config.h"
#include "debug.h"

CTestboard tb;


int main()
{
	tb.Welcome();
	tb.SetLed(0x00);
	check_epcs();


	dtbConfig.Init();
	dtbConfig.Read("0:DTB.INI");

	rpc_Dispatcher(*tb.GetIo());

	return 0;
}
