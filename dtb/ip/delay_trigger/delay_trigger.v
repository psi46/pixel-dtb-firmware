
module delay_trigger
(
	input  clk,
	input  reset,
	input  sync,
	input  [3:0]trig_in,
	output pulse,
	
	input  clksys,
	input  write,
	input  [15:0] writedata,
	input  [1:0] address
);

	delay_trigger_core dt
	(
		.clk       (clk),
		.sync      (sync),
		.trig_in   (trig_in),
		.pulse     (pulse),
		.clksys    (clksys),
		.write     (write),
		.writedata (writedata),
		.address   (address)
	);

endmodule
