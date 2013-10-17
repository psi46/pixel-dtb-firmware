// psi2c_control

`timescale 1 ps / 1 ps


/*
-- registers       b15 b14 b13 b12 b11 b10 b9  b8  b7  b6  b5  b4  b3  b2  b1  b0
--  0 w:                                                                   tbm go
--  0 r:                                                               ful tbm run
--  1 w: send raw                  S   P   D7  D6  D5  D4  !D4 D3  D2  D1  D0  !D0
--  2 w: send                                      D7  D6  D5  D4  D3  D2  D1  D0
--  3 w: send S                                    D7  D6  D5  D4  D3  D2  D1  D0
--  4 w: send  P                                   D7  D6  D5  D4  D3  D2  D1  D0
--  5 w: send SP                                   D7  D6  D5  D4  D3  D2  D1  D0
--  1 r: rdb raw   run 0   0   _s3 _rw _d4 _d0 S   ha4 ha3 ha2 ha1 ha0 pa2 pa1 pa0
--                 ra7 ra6 ra5 ra4 ra3 ra2 ra1 ra0 rd7 rd6 rd5 rd4 rd3 rd2 rd1 rd0
--
--  tbm = read back on
--  ful = fifo full
--  go  = start transmission
--  run = i2c running
--  S = Start Bit, P = Stop Bit
--  D   = Send Data
--  ha  = Hub Address
--  pa  = Port Address
--  ra  = Register Address
--  rd  = Register Data
*/



module i2c_control
(
	// avalon slave
	input clk,
	input reset,
	
	// avalon slave interface
	input   [2:0]address,
	input        write,
	input  [31:0]writedata,
	input        read,
	output reg [31:0]readdata,

	output go,
	input full,
	output reg [11:0]memd,
	output memw,
	input busy,
	output tbm,
	input [31:0]rda
);

	wire [9:0]i2c_data;
	reg rdbff;

	assign memw = write & (address>=1) & (address<=5);
	assign i2c_data = {writedata[7:4], !writedata[4],
	              writedata[3:0], !writedata[0]};
  always @(*)
	case (address)
		2: memd <= {2'b00, i2c_data};
		3: memd <= {2'b10, i2c_data}; // S
		4: memd <= {2'b01, i2c_data}; //  P
		5: memd <= {2'b11, i2c_data}; // SP
		default: memd <= writedata[11:0];
	endcase
	
	always @(*)
	case (address)
		1:      readdata <= rda;
		default readdata <= {1'b0, full, rdbff, busy || rda[31]};
	endcase

	// tbm mode
	always @(posedge clk or posedge reset)
	begin
		if (reset) rdbff <= 0;
		else if (write && (address == 0))
			rdbff = writedata[1];
	end
	
	assign tbm = rdbff;
	
	// go signal
	assign go = write & writedata[0] & (address == 0);
endmodule
