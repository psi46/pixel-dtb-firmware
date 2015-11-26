// phase_selector.v

`timescale 1 ns / 1 ps


module phase_selector
(
	input CLK400,
	input reset,
	
	input [7:0]sel,
	input [7:0]serin,
	output reg serout
);

	reg [7:0]sel1;
	reg [1:0]sel2;
	
	always @(posedge CLK400 or posedge reset)
	begin
		if (reset)
		begin
			sel1   <= 0;
			sel2   <= 0;
			serout <= 0;
		end
		else
		begin
			sel1   <= serin & sel;
			sel2   <= { |sel1[7:4], |sel1[3:0] };
			serout <= |sel2;
		end
	end

endmodule
