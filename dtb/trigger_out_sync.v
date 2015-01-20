// trigger_out_sync.v
// trigger event encoder

`timescale 1 ns / 1 ps


module trigger_out_sync
(
	input clk,
	input sync,
	input reset,

	input [4:0]trigger_in,
	input direct_out,
	
	output reg dout
);

	wire syn = trigger_in[0];
	wire trg = trigger_in[1];
	wire rsr = trigger_in[2];
	wire rst = trigger_in[3];

	reg [2:0]evreg;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			evreg <= 0;
		end
		else if (sync)
		begin
			if (|evreg[2:1]) evreg <= {evreg[1:0], 1'b0};
			else if (syn) evreg <= 3'b100;
			else if (trg) evreg <= 3'b110;
			else if (rsr) evreg <= 3'b111;
			else if (rst) evreg <= 3'b101;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if (reset) dout <= 0;
		else if (!sync) dout <= evreg[2] || direct_out;
	end

endmodule
