/* delay_out.v
   Beat Meier
   6.2.2013


delay calculation:

short delay; // delay in steps of 1.25 ns
short duty;  // duty cycle corrections in 1.25 ns steps (range: -8 ... +8)

short delayC =  delay / 10;
short delayR = (delay % 10) + 8;
short delayF = delayR + duty;


delay register programming:

+-------+------+------+--------------------------------------------+
| offset| bit  | name | description                                |
+-------+------+------+--------------------------------------------+
|    0  | 12:0 | delf | fine delay of falling edge in 1.25ns steps |
|    2  | 12:0 | delr | fine delay of rising edge in 1.25ns steps  |
|    4  |  4:0 | delc | coarse delay in 12.5ns steps (0...31)      |
|    6  |    0 |  set | force output to state                      |
|    6  |    1 | state| define output level if force = 1           |
|    6  |  6:2 | ext  | select random mode                         |
|    6  |    7 | opt  | options for external signals               |
+-------+------+------+--------------------------------------------+

memory arrangement for 16 bit access
offset   6                4                2                0
+----------------+----------------+----------------+----------------+
|     state, set |      delc      |      delr      |      delf      |
+----------------+----------------+----------------+----------------+

memory arrangement for 32 bit access
offset           4                                 0
+----------------+----------------+----------------+----------------+
|     state, set        delc      |      delr             delf      |
+----------------+----------------+----------------+----------------+


delayR/delayF to delr, delf conversion:		

  # | delay step | binary value    | hex value
----+-----------+------------------+-----------
	0 |   0.00 ns | 0000_0000_0000_0 |   0000
	1 |   1.25 ns	| 0000_0000_0000_1 |   0001
  2 |   2.50 ns | 0000_0000_0001_0 |   0002
  3 |   3.75 ns | 0000_0000_0001_1 |   0003
  4 |   5.00 ns | 0000_0000_0011_0 |   0006
  5 |   6.25 ns | 0000_0000_0011_1 |   0007
  6 |   7.50 ns | 0000_0000_0111_0 |   000e
  7 |   8.75 ns | 0000_0000_0111_1 |   000f
  8 +  10.00 ns + 0000_0000_1111_0 +   001e
  9 |  11.25 ns | 0000_0000_1111_1 |   001f
 10 |  12.50 ns | 0000_0001_1111_0 |   003e
 11 |  13.75 ns | 0000_0001_1111_1 |   003f
 12 |  15.00 ns | 0000_0011_1111_0 |   007e
 13 |  16.25 ns | 0000_0011_1111_1 |   007f
 14 |  17.50 ns | 0000_0111_1111_0 |   00fe
 15 |  18.75 ns | 0000_0111_1111_1 |   00ff
 16 |  20.00 ns | 0000_1111_1111_0 |   01fe
 17 |  21.25 ns | 0000_1111_1111_1 |   01ff
 18 |  22.50 ns | 0001_1111_1111_0 |   03fe
 19 |  23.75 ns | 0001_1111_1111_1 |   03ff
 20 |  25.00 ns | 0011_1111_1111_0 |   07fe
 21 |  26.25 ns | 0011_1111_1111_1 |   07ff
 22 |  27.50 ns | 0111_1111_1111_0 |   0ffe
 23 |  28.75 ns | 0111_1111_1111_1 |   0fff
 24 |  30.00 ns | 1111_1111_1111_0 |   1ffe
 25 |  31.25 ns | 1111_1111_1111_1 |   1fff
----+-----------+------------------+-----------

*/

`timescale 1 ps / 1 ps


module delay_select
(
	input clk,
	input reset,
	
	input dr,
	input df,
	
	input d,
	output reg q,
	output reg q2
);

	always @(posedge clk or posedge reset) q2 <= reset ? 1'b0 : d;

	always @(*)
	case ({dr, df, q2, d})
		4'b0000: q <= 0;
		4'b0001: q <= 1;
		4'b0010: q <= 0;
		4'b0011: q <= 1;
		4'b0100: q <= 0;
		4'b0101: q <= 1;
		4'b0110: q <= 1;
		4'b0111: q <= 1;
		4'b1000: q <= 0;
		4'b1001: q <= 0;
		4'b1010: q <= 0;
		4'b1011: q <= 1;
		4'b1100: q <= 0;
		4'b1101: q <= 0;
		4'b1110: q <= 1;
		4'b1111: q <= 1;
	endcase

endmodule


module delay_ddrout
(
	input clk,
	input reset,

	input dr,  // delay of rising edge
	input df,  // delay of falling edge

	input d,
	output q,

	input select_ddr_in,
	input [1:0]ddr_in
);

	wire lo, hi;
	reg [1:0]ddr_del;
	wire [1:0]ddr;
	
	reg d1;
	always @(posedge clk or posedge reset) d1 <= reset ? 1'b0 : d;

	delay_select dsel(clk, reset, dr, df, d1, lo, hi);

	always @(posedge clk or posedge reset) ddr_del <= reset ? 2'b00 : {hi, lo};
	assign ddr = select_ddr_in ? ddr_in : ddr_del;

	altddio_out
	#(
		.extend_oe_disable("OFF"),
		.intended_device_family("Cyclone III"),
		.invert_output("OFF"),
		.lpm_hint("UNUSED"),
		.lpm_type("altddio_out"),
		.oe_reg("UNREGISTERED"),
		.power_up_high("OFF"),
		.width(1)
	) ddrout
	(
		.aclr (reset),
		.datain_h (ddr[1]),
		.datain_l (ddr[0]),
		.outclock (clk),
		.dataout (q),
		.aset (1'b0),
		.oe (1'b1),
		.oe_out (),
		.outclocken (1'b1),
		.sclr (1'b0),
		.sset (1'b0)
	);

endmodule


module delay_stage
(
	input clk,
	input reset,

	input dr,  // delay of rising edge
	input df,  // delay of falling edge

	input d,
	output q
);

	wire q1;
	delay_select dsel(clk, reset, dr, df, d, q, q1);

endmodule


module delay_stageb
(
	input clk,
	input reset,

	input dr,  // delay of rising edge
	input df,  // delay of falling edge

	input d,
	output q
);

	reg d1;
	always @(posedge clk or posedge reset) d1 <= reset ? 1'b0 : d;

	wire q1;
	delay_select dsel(clk, reset, dr, df, d1, q, q1);

endmodule


module delay_out
(
	// avalon clock interface
	input csi_clock_clk,
	input csi_clock_reset,
	
	// avalon mm slave: control
	input avs_ctrl_write,
	input avs_ctrl_address,
	input [3:0]avs_ctrl_byteenable,
	input [31:0]avs_ctrl_writedata,
	
	input sclk,
	input sig_in,
	output sig_out
);

	wire clk             = csi_clock_clk;
	wire reset           = csi_clock_reset;
	wire write           = avs_ctrl_write;
	wire address         = avs_ctrl_address;
	wire [3:0]byteenable = avs_ctrl_byteenable;
	wire [31:0]data      = avs_ctrl_writedata;

	// --- register -------------------------------------------------

  reg set;           // force output to state
  reg state;         // output state if set = 1
  reg ext_sel;       // select external signal
	reg [4:0]ext_mode; // setup extern 
	reg [ 4:0]delc;    // coarse delay 0 ... 31
	reg [12:0]delr;    // delay of rising edge
	reg [12:0]delf;    // delay of falling edge

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			delc     <= 5'b00000;
			delr     <= 13'b0000_0000_1111_0;
			delf     <= 13'b0000_0000_1111_0;
			set      <= 0;
			state    <= 0;
			ext_sel  <= 0;
			ext_mode <= 5'b0000;
		end
		else if (write)
		begin
			if (address)
			begin
				if (byteenable[0]) delc <= data[4:0];
				if (byteenable[2]) {ext_sel, ext_mode, state, set} <= data[23:16];
			end
			else
			begin
				if (byteenable[0]) delf[ 7:0] <= data[7:0];
				if (byteenable[1]) delf[12:8] <= data[12:8];
				if (byteenable[2]) delr[ 7:0] <= data[23:16];
				if (byteenable[3]) delr[12:8] <= data[28:24];
			end
		end
	end

	wire [13:0]q;
	
	
	// --- output mode ----------------------------------------------
	
	wire delay_in = set ? state : sig_in;
	
	wire [1:0]ext_sig;
	
	PRBS31 randomgen
	(
		.CLK(sclk),
		.RESET(reset),
		.EN(ext_sel),
		.SPEED(ext_mode[1:0]),  // 5 control bits
		.Y(ext_sig)
	);
	
	
	// --- coarse delay ---------------------------------------------
	
	reg [31:0]del;
	genvar n;
	generate	for (n=1; n<=31; n=n+1)
		begin : delshift
			always @(posedge clk or posedge reset)
				del[n] <= reset ? 0 : (delc == (31-n)) ? delay_in : del[n-1];
		end
	endgenerate
	
	always @(posedge clk or posedge reset)
		del[0] <= reset ? 0 : (delc == 31) ? delay_in : 0;

	assign q[0] = del[31];


	// --- fine delay -----------------------------------------------

	delay_stageb  d1(sclk, reset, delr[12], delf[12], q[ 0], q[ 1] );
	delay_stage   d2(sclk, reset, delr[11], delf[11], q[ 1], q[ 2] );
	delay_stageb  d3(sclk, reset, delr[10], delf[10], q[ 2], q[ 3] );
	delay_stage   d4(sclk, reset, delr[ 9], delf[ 9], q[ 3], q[ 4] );
	delay_stageb  d5(sclk, reset, delr[ 8], delf[ 8], q[ 4], q[ 5] );
	delay_stage   d6(sclk, reset, delr[ 7], delf[ 7], q[ 5], q[ 6] );
	delay_stageb  d7(sclk, reset, delr[ 6], delf[ 6], q[ 6], q[ 7] );
	delay_stage   d8(sclk, reset, delr[ 5], delf[ 5], q[ 7], q[ 8] );
	delay_stageb  d9(sclk, reset, delr[ 4], delf[ 4], q[ 8], q[ 9] );
	delay_stage  d10(sclk, reset, delr[ 3], delf[ 3], q[ 9], q[10] );
	delay_stageb d11(sclk, reset, delr[ 2], delf[ 2], q[10], q[11] );
	delay_stage  d12(sclk, reset, delr[ 1], delf[ 1], q[11], q[12] );
	delay_ddrout d13(sclk, reset, delr[ 0], delf[ 0], q[12], sig_out, ext_sel, ext_sig);
	
endmodule
