// cdc_state.v

`timescale 1 ns / 1 ps


module cdc_state
(
	input clk1,
	input clk2,
	input clk2ena,
	input reset,
	
	input in,
	output reg out
);

	reg a, b;
	
	always @(posedge clk1)
	begin
		if (reset) a <= 0;	else a <= in;
	end

		
	always @(posedge clk2)
	begin
		if (reset)
		begin
			b   <= 0;
			out <= 0;
		end
		else if (clk2ena)
		begin
			b   <= a;
			out <= b;
		end
	end

endmodule
