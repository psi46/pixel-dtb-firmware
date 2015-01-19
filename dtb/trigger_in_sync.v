// trigger_in_sync.v
// trigger event decoder

`timescale 1 ns / 1 ps


module trigger_in_sync
(
	input clk,
	input sync,
	input reset,

	input din,
	
	output [4:0]trigger_out,
	output direct_in
);

	reg syn;
	reg trg;
	reg rsr;
	reg rst;


	reg [2:0]evreg;
	wire start = evreg[2];
	wire [1:0]code = evreg[1:0];
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			evreg <= 0;
			syn <= 0;
			trg <= 0;
			rsr <= 0;
			rst <= 0;
		end
		else if (sync)
		begin
			// read event
			if (start) evreg <= {2'b00, din};
			else       evreg <= {evreg[1:0], din};

			// decode event
			if (start)
			begin
				case (code)
					2'b00: syn <= 1;
					2'b01: rst <= 1;
					2'b10: trg <= 1;
					2'b11: rsr <= 1;
				endcase
			end
			else
			begin
				syn <= 0;
				trg <= 0;
				rsr <= 0;
				rst <= 0;
			end
		end
	end

	assign trigger_out = {1'b0, rst, rsr, trg, syn};

	assign direct_in = evreg[0];

endmodule
