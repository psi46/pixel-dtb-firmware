// deser_2bit.v

`timescale 1 ns / 1 ps


module deser_2bit
(
	input clk160,
	input clk80,
	input reset,

	input sdata,
	output reg [1:0]pdata
);

	reg [1:0]s;
	
	always @(posedge clk160 or posedge reset)
	begin
		if (reset) s <= 0;
		else s <= {s[0], sdata};
	end

	always @(posedge clk80 or posedge reset)
	begin
		if (reset) pdata <= 0;
		else pdata <= s;
	end

endmodule
