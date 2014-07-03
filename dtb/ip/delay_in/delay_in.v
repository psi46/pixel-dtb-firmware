// delay_in.v

`timescale 1 ns / 1 ps


/*  parameter  delay [ns]  sampling point position
		0_0000_0     0.00       19
		0_0000_1     1.25       18
		0_0001_0     2.50       17
		0_0001_1     3.75       16
		0_0011_0     5.00       15
		0_0011_1     6.25       14
		0_0111_0     7.50       13
		0_0111_1     8.75       12
		0_1111_0    10.00       11
		0_1111_1    11.25       10
		1_0000_0    12.50        9
		1_0000_1    13.75        8
		1_0001_0    15.00        7
		1_0001_1    16.25        6
		1_0011_0    17.50        5
		1_0011_1    18.75        4
		1_0111_0    20.00        3
		1_0111_1    21.25        2
		1_1111_0    22.50        1
		1_1111_1    23.75        0
*/

module delay_in
(
		// avalon clock interface
	input csi_clock_clk,
	input csi_clock_reset,
	
	// avalon mm slave: control
	input avs_ctrl_write,
	input [31:0]avs_ctrl_writedata,

	input sync,
	input clk400,
	
	input sig_in,
	output reg sig_out40,
	output sig_out80
);

	// avalon ctrl interface
	wire clk80 = csi_clock_clk;
	wire reset = csi_clock_reset;
	reg [5:0]delay;
	
	always @(posedge clk80 or posedge reset)
	begin
		if (reset) delay <= 0;
		else if (avs_ctrl_write) delay <= avs_ctrl_writedata[5:0];
	end

	
	wire [5:0]delout;

	// 1.25 ns delay step
	delay_ddrin half_stage
	(
		.clk(clk400),
		.reset(reset),
		.select(delay[0]),
		.in(sig_in),
		.out(delout[0])
	);

	// 4 x 2.5 ns delay step
	delay_in_stage d1(clk400, reset, delay[1], delout[0], delout[1]);
	delay_in_stage d2(clk400, reset, delay[2], delout[1], delout[2]);
	delay_in_stage d3(clk400, reset, delay[3], delout[2], delout[3]);
	delay_in_stage d4(clk400, reset, delay[4], delout[3], delout[4]);

	// clock crossing register	
	reg ccreg;
	always @(posedge clk80 or posedge reset)
	begin
		if (reset) ccreg <= 0;
		else ccreg <= delout[4];
	end

	// 12.5 ns delay stage
	delay_in_stage d5(clk80, reset, delay[5], ccreg, delout[5]);
	
	assign sig_out80 = delout[5];
	
	always @(posedge clk80 or posedge reset)
	begin
		if (reset) sig_out40 <= 0;
		else if (sync) sig_out40 <= delout[5];
	end
	
endmodule
