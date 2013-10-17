// cdc_pulse.v

`timescale 1 ns / 1 ps


module cdc_pulse
(
	input clk1,
	input clk2,
	input clk2ena,
	input reset,
	
	input in,
	output reg out
);

	reg a, b;
	
	always @(posedge clk1 or posedge reset)
	begin
		if (reset) a <= 0;	else a <= in;
	end

	always @(posedge clk1 or posedge out or posedge reset)
	begin
		if (out || reset) b <= 0;
		else if (a)       b <= 1;
	end
		
	always @(posedge clk2)
	begin
		if (reset)
			out <= 0;
		else if (clk2ena)
			out <= !a && b;
	end

endmodule
