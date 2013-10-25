// deser400.v

`timescale 1ns / 1ps


module deser400
(
	input clock,
	input [3:0]sclk,
	input res,
	input run,
	
	input input_data,

	output write,
	
	output [15:0]data_a,
	output [15:0]data_b
);

	wire ser_data_a;
	wire ser_data_b;
	wire clk400;

	deser400_sampling sampler
	(
		.clock(clock),
		.sclk(sclk[3:0]),
		.res(res),
		.input_data(input_data),
		.data_a(ser_data_a),
		.data_b(ser_data_b),
		.clk_400(clk400),
	);

	deser400_serpar serpar
	(
		.clk(clock),
		.clk400(clk400),
		.reset(reset),
		.run(run),
	
		.ser_a(ser_data_a),
		.ser_b(ser_data_b),
	
		.par_a(data_a),
		.par_b(data_b),
		.write(write)
	);

endmodule
