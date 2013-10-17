// deser160.v

`timescale 1ns / 1ps


module deser160
(
	input clk,
	input sync,
	input reset,
	
	input sclk0,
	input sclk180,
	
	input [3:0]ctrl,
	
	input sdata,

	input run,
	input tin,
	input tout,

	output write,
	output [15:0]data
);

	wire [3:0]d1;

	deser160_sampling cdr
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),
		.sclk0(sclk0),
		.sclk180(sclk180),
	
		.sdata(sdata),
		.data(d1)
	);

	deser160_serpar serpar
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),
		.ctrl(ctrl),
		.run(run),
		.tin(tin),
		.tout(tout),
	
		.din(d1),
	
		.write(write),
		.data(data)
	);

endmodule
