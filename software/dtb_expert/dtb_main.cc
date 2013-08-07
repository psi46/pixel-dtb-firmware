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

	Ethernet e;
	char* data = "abcdefg";
	char store[10];
	while(1){
		e.Write(data,strlen(data));
		e.Read(store, 10);
		printf("\n%s\n",store);
		usleep(50000);
	}
	rpc_Dispatcher(*tb.GetIo());

	return 0;
}
