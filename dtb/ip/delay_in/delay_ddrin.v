// delay_ddrin.v

`timescale 1 ns / 1 ps


module delay_ddrin
(
	input clk,
	input reset,
	input select,
	input in,
	output reg out
);

	wire in0;
	wire in1;
	
	altddio_in	half_delay
	(
		.aclr (reset),
		.datain (in),
		.inclock (clk),
		.dataout_h (in0),
		.dataout_l (in1),
		.aset (1'b0),
		.inclocken (1'b1),
		.sclr (1'b0),
		.sset (1'b0)
	);
	defparam
		half_delay.intended_device_family = "Cyclone III",
		half_delay.invert_input_clocks = "OFF",
		half_delay.lpm_hint = "UNUSED",
		half_delay.lpm_type = "altddio_in",
		half_delay.power_up_high = "OFF",
		half_delay.width = 1;

	always @(posedge clk or posedge reset)
	begin
		if (reset) out <= 0;
		else out <= select ? in1 : in0;
	end

endmodule
