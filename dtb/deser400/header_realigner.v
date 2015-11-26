// header_realigner.v

`timescale 1 ns / 1 ps


module header_realigner
(
	input clk80,
	input reset,
	
	input [1:0]din,
	output reg [3:0]dout,
	output reg davail,

	input start,
	output reg header
);

	reg ena;
	reg [15:0]s;
	wire [1:0]d;

	reg  cmp0;
	reg  cmp1;
	wire cmp = (cmp0 | cmp1) & ena;
	reg  pos;
	reg  [1:0]h;

	assign d = pos ? s[14:13] : s[15:14];

	always @(posedge clk80 or posedge reset)
	begin
		if (reset)
		begin
			s      <= 0;
			dout   <= 0;
			davail <= 0;
			ena    <= 0;
			cmp0   <= 0;
			cmp1   <= 0;
			pos    <= 0;
			h      <= 0;
			header <= 0;
		end
		else
		begin
			// data
			s  <= {s[13:0], din};
			if (davail) dout[3:2] <= d; else dout[1:0] <= d;
			davail <= cmp ? 1 : ~davail;
			
			// start stop
			if (start) ena <= 1; else if (cmp) ena <= 0;

			cmp0 <= {s[11:1]} == 11'b01111111110;
			cmp1 <= {s[10:0]} == 11'b01111111110;
			if (cmp) pos <= cmp1;
			h <= {h[0], cmp};
			header <= h[1];
		end
	end

endmodule
