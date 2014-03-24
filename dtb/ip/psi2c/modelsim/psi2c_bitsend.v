// psi2c_bitsend.v

`timescale 1 ns / 1 ps


module psi2c_bitsend
(
	input clk,
	input sync,
	input reset,
	input phase,
	input go,
	input empty,
	output rd,
	output busy,
	input [11:0]d,
	output reg sda
);
  reg goff;
	wire hold;

  // latch = {empty, d[10]=p, d[1:0] = data[1:0]}
  reg [3:0]latch;
  always @(*) if (!hold) latch <= reset ? 4'b0000 : {!empty, d[10], d[1:0]};

  wire s = d[11];    // i2c start
  wire p = latch[2];  // i2c stop
  wire [9:0]data = {d[9:2], latch[1:0]}; // i2c data (10 bit)
  wire em = !latch[3]; // empty

  // state machine
	localparam sm_idle   = 6'b000000;  // idle
	localparam sm_load   = 6'b010000;  // read fifo
	localparam sm_wait   = 6'b010001;  // wait for go
	localparam sm_start1 = 6'b010010;  // generate i2c start
	localparam sm_start2 = 6'b010011;  // i2c start -> i2c stop
	localparam sm_bit0   = 6'b100000;  // send bit0 (last)
	localparam sm_bit1   = 6'b100001;
	localparam sm_bit2   = 6'b100010;
	localparam sm_bit3   = 6'b100011;
	localparam sm_bit4   = 6'b100100;
	localparam sm_bit5   = 6'b100101;
	localparam sm_bit6   = 6'b100110;
	localparam sm_bit7   = 6'b100111;
	localparam sm_bit8   = 6'b101000;
	localparam sm_bit9   = 6'b101001;  // send bit 9 (first)
	localparam sm_stop   = 6'b010100;  // generate i2c stop

  // sequencer
	reg [5:0]sm;
	always @(posedge clk or posedge reset)
	begin
		if (reset) sm <= sm_idle;
		else if (sync)
		case (sm)
			sm_idle:   if (goff && em) sm <= sm_start2; // start-stop sequence
			           else if (!em)  sm <= sm_load;   // regular data sequence
			sm_start2: sm <= sm_stop;

			sm_load:   sm <= sm_wait;
			sm_wait:   if (goff) sm <= s ? sm_start1 : sm_bit9;
			
			sm_start1: sm <= sm_bit9;
			sm_bit9:   sm <= sm_bit8;
			sm_bit8:   sm <= sm_bit7;
			sm_bit7:   sm <= sm_bit6;
			sm_bit6:   sm <= sm_bit5;
			sm_bit5:   sm <= sm_bit4;
			sm_bit4:   sm <= sm_bit3;
			sm_bit3:   sm <= sm_bit2;
			sm_bit2:   sm <= sm_bit1;
			sm_bit1:   sm <= sm_bit0;
			sm_bit0:   if (p) sm <= sm_stop;
			           else if (em) sm <= sm_idle;
			           else sm <= s ? sm_start1 : sm_bit9;
			sm_stop:   if (em) sm <= sm_idle;
			           else sm <= s ? sm_start1 : sm_bit9;
			default: sm <= sm_idle;
		endcase
	end

  // sda assignment	
	always @(*)
	begin
		case (sm)
			sm_start1: sda <= phase;
			sm_start2: sda <= phase;
			sm_bit0:   sda <= data[0];
			sm_bit1:   sda <= data[1];
			sm_bit2:   sda <= data[2];
			sm_bit3:   sda <= data[3];
			sm_bit4:   sda <= data[4];
			sm_bit5:   sda <= data[5];
			sm_bit6:   sda <= data[6];
			sm_bit7:   sda <= data[7];
			sm_bit8:   sda <= data[8];
			sm_bit9:   sda <= data[9];
			sm_stop:   sda <= !phase;
			default:   sda <= 1;
		endcase
	end

  assign hold = (sm == sm_bit1) || (sm == sm_bit0);
  assign busy = (sm != sm_idle) && (sm != sm_load) && (sm != sm_wait);

  // go srff
	always @(posedge clk or posedge reset)
	begin
		if (reset) goff <= 0;
		else if ((sm == sm_bit9) || (sm == sm_start2)) goff <= 0;
		else if (go) goff <= 1;
	end

  // fifo read ff
  reg rdff;
  always @(posedge clk or posedge reset)
  begin
    if (reset) rdff <= 0;
    else rdff <= (sm == sm_load) || (sm == sm_bit1);
  end
  assign rd = rdff && sync;

endmodule
