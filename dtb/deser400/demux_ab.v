// demux_ab.v

`timescale 1 ns / 1 ps


module demux_ab
(
	input clk80,
	input reset,
	input enable,

	input [3:0]din,
	output reg [1:0]doutA,
	output reg [1:0]doutB
);

	always @(posedge clk80 or posedge reset)
	begin
		if (reset)
		begin
			doutA <= 2'b11;
			doutB <= 2'b11;
		end
		else if (enable)
		begin
			doutA <= { din[3],  din[1]};
			doutB <= {!din[2], !din[0]};
		end
		else
		begin
			doutA <= 2'b11;
			doutB <= 2'b11;
		end
	end

endmodule
