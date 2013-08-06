// dtb_main.cc
// 3.4.2013

#include "pixel_dtb.h"
#include "dtb_config.h"
#include "debug.h"
#include "ethernet.h"

//int Ethernet_test(void);


CTestboard tb;


int main()
{
	tb.Welcome();

	check_epcs();


	dtbConfig.Init();
	dtbConfig.Read("0:DTB.INI");
//	Ethernet_test();

//	eth_init();
//	while(1){
//		eth_write("abcdefg");
//		printf(eth_read());
//		usleep(50000);
//	}
	rpc_Dispatcher(*tb.GetIo());

	return 0;
}
