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
	output [15:0]data_b,
	output [9:0]test
);

	wire ser_data_a;
	wire ser_data_b;
	wire clk160;

	deser400_sampling sampler
	(
		.clock(clock),
		.sclk(sclk[3:0]),
		.res(res),
		.input_data(input_data),
		.data_a(ser_data_a),
		.data_b(ser_data_b),
		.clk_160(clk160), //output
	  .test(test)
	);

	deser400_serpar serpar
	(
		//.clk(clock),
		.clk160(clk160),
		.reset(res),
		.run(run),
	
		.ser_a(ser_data_a),
		.ser_b(ser_data_b),
	
		.par_a(data_a),
		.par_b(data_b),
		.write(write)
		//.test(test[3:0])
	);

endmodule
