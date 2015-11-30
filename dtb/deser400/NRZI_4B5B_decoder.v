// nrzi_4b5b_decoder.v

`timescale 1 ns / 1 ps


module nrzi_4b5b_decoder
(
	input clk80,
	input reset,
	input enable,

	input [4:0]din,
	output reg [3:0]dout,
	output reg error
);

	reg [4:0]d;
	reg inv;
	
	always @(posedge clk80 or posedge reset)
	begin
		if (reset)
		begin
			d     <= 5'b00000;
			inv   <= 0;
			dout  <= 4'b1010;
			error <= 0;
		end
		else
		begin if (enable)
			d <= inv ? din : ~din;
			inv <= din[0];
			case (d)
				5'b01011: {dout,error} <= 5'b0000_0;
				5'b10001: {dout,error} <= 5'b0001_0;
				5'b00111: {dout,error} <= 5'b0010_0;
				5'b00110: {dout,error} <= 5'b0011_0;
				5'b10011: {dout,error} <= 5'b0100_0;
				5'b10010: {dout,error} <= 5'b0101_0;
				5'b10100: {dout,error} <= 5'b0110_0;
				5'b10101: {dout,error} <= 5'b0111_0;
				5'b00011: {dout,error} <= 5'b1000_0;
				5'b00010: {dout,error} <= 5'b1001_0;
				5'b00100: {dout,error} <= 5'b1010_0;
				5'b00000: {dout,error} <= 5'b1010_0;
				5'b00101: {dout,error} <= 5'b1011_0;
				5'b01100: {dout,error} <= 5'b1100_0;
				5'b01101: {dout,error} <= 5'b1101_0;
				5'b01000: {dout,error} <= 5'b1110_0;
				5'b01001: {dout,error} <= 5'b1111_0;
				default:  {dout,error} <= 5'b1010_1;
			endcase
		end
	end

endmodule
