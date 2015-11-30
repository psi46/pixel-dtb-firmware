// frame_decoder.v

`timescale 1 ns / 1 ps


module frame_detector
(
	input clk400,
	input clk80,
	input reset,
	input enable,
	
	input sdata,
	output reg [4:0]pdata,
	output reg error
);
	reg [5:0]s;  // shift register
	reg detect;  // 000001 pattern detected
	reg [2:0]c;  // frame pos counter
	wire sync = c[2]; // periodic frame sync signal
	reg [4:0]p;  // parallel data register
	reg e;       // error flag

	always @(posedge clk400)
	begin
		if (reset)
		begin
			s <= 0;
			detect <= 0;
			c <= 0;
			p <= 0;
			e <= 0;
		end
		else if (enable)
		begin
			s <= {s[4:0],sdata};
			detect <= (s[5:0] == 6'b100000) || (s[5:0] == 6'b011111);
			if (sync || detect) c <= 3'd0; else c <= c + 3'd1;
			if (sync) p <= s[5:1];
			if (sync) e <= 0; else if (detect) e <= 1;
		end
	end

	always @(posedge clk80 or posedge reset)
	begin
		if (reset)
		begin
			pdata <= 5'd0;
			error <= 0;
		end
		else if (enable)
		begin
			pdata <= p;
			error <= e;
		end
		else
		begin
			pdata <= 5'd0;
			error <= 0;
		end
	end

endmodule
