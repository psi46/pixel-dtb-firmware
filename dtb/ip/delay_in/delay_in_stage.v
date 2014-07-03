// delay_in_state.v

`timescale 1 ps / 1 ps


module delay_in_stage
(
	input clk,
	input reset,
	input select,
	input in,
	output reg out
);

	reg del;

	always @(posedge clk)
	begin
		if (reset)
		begin
			del <= 0;
			out <= 0;
		end
		else
		begin
			del <= in;
			out <= select ? del : in;
		end
	end

endmodule
