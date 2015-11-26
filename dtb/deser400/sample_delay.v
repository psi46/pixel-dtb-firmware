// sample_delay.v

`timescale 1 ns / 1 ps


module sample_delay
(
	input CLK400,
	input reset,
	
	input [7:0]din,
	output reg [7:0]dout
);

	always @(posedge CLK400 or posedge reset)
	begin
		if (reset) dout <= 0;
		else dout <= din;
	end

endmodule
