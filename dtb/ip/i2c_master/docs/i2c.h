// i2c.h

#ifndef I2C_H
#define I2C_H


// I2C master register
#define PRERlo   0x00  // --- Clock Prescale register lo-byte -----
#define PRERhi   0x01  // --- Clock Prescale register hi-byte -----

#define CTR      0x02  // --- Control register --------------------
#define EN       0x80  // core enable
#define IEN      0x40  // interrupt enable

#define TXR      0x03  // --- Transmit register -------------------

#define RXR      0x03  // --- Receive register --------------------

#define CR       0x04  // --- Command register --------------------
#define STA      0x80  // generate (repeated) start condition
#define STO      0x40  // generate stop condition
#define RD       0x20  // read from slave
#define WR       0x10  // write to slave
#define ACK      0x08  // ACK=0: send ACK; ACK = 1: send NACK
#define IACK     0x01  // Interrupt acknowledge

#define SR       0x04  // --- Status register ---------------------
#define RxACK    0x80  // Received acknowledge from slave (RxACK=0)
#define BUSY     0x40  // I2C busy ( 1 after START detected)
#define AL       0x20  // Arbitration lost
#define TIP      0x02  // Transfer in Progress
#define IF       0x01  // Interrupt Flag


void I2C_Init();

void InitDac();
void SetDac(int channel, int value);  // channel = 0..3

unsigned int ReadADC(unsigned char channel);


#endif // I2C_H
