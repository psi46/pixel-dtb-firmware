// ethernet.h

#pragma once

int eth_init();

void eth_write(const char* data);
void eth_flush();
char* eth_read();
