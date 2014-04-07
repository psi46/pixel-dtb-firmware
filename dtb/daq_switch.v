// daq_switch.v

`timescale 1 ns / 1 ps


module daq_switch
(
	input sel,
	
	input write0,
	input [15:0]din0,
	
	input write1,
	input [15:0]din1,
	
	output reg write,
	output reg [15:0]dout
);

	always @(*)
	begin
		if (sel)
		begin
			write = write1;
			dout = din1;
		end
		else
		begin
			write = write0;
			dout = din0;
		end
	end
endmodule
