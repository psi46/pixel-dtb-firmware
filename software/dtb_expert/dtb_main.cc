// dtb_main.cc
// 3.4.2013

#include "pixel_dtb.h"
#include "dtb_config.h"
#include "debug.h"


int Ethernet_test(void);


CTestboard tb;


int main()
{
	tb.Welcome();

//	check_epcs();

	dtbConfig.Init();
	dtbConfig.Read("0:DTB.INI");

	tb.Ethernet_Init();

	rpc_Dispatcher(*tb.GetIo());

	return 0;
}
