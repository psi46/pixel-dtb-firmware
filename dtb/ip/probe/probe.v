// probeselect.v


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on


module probe_mux4
(
	input clk,
	input reset,

	input [1:0]select,

	input [3:0]sig_in,
	output reg sig_out
);
	always @(posedge clk or posedge reset)
	begin
		if (reset) sig_out <= 0;
		else
			case (select)
				0: sig_out <= sig_in[0];
				1: sig_out <= sig_in[1];
				2: sig_out <= sig_in[2];
				3: sig_out <= sig_in[3];
			endcase
	end
endmodule


module probe
(
	// avalon clock interface
	input csi_clock_clk,
	input csi_clock_reset,

	// avalon mm slave: control
	input avs_ctrl_write,
	input [7:0]avs_ctrl_writedata,
		
	// multiplexer	
	input [30:0]sig_in,
	output reg sig_out
);

	wire clk = csi_clock_clk;
	wire reset = csi_clock_reset;
	reg [4:0]sel;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset) sel <= 0;
		else if (avs_ctrl_write) sel <= avs_ctrl_writedata[4:0];
	end

	wire [7:0]d;
	probe_mux4 mux0(clk, reset, sel[1:0], {sig_in[2:0], 1'b0}, d[0]);
	probe_mux4 mux1(clk, reset, sel[1:0],  sig_in[6:3],   d[1]);
	probe_mux4 mux2(clk, reset, sel[1:0],  sig_in[10:7],  d[2]);
	probe_mux4 mux3(clk, reset, sel[1:0],  sig_in[14:11], d[3]);
	probe_mux4 mux4(clk, reset, sel[1:0],  sig_in[18:15], d[4]);
	probe_mux4 mux5(clk, reset, sel[1:0],  sig_in[22:19], d[5]);
	probe_mux4 mux6(clk, reset, sel[1:0],  sig_in[26:23], d[6]);
	probe_mux4 mux7(clk, reset, sel[1:0],  sig_in[30:27], d[7]);

	always @(posedge clk or posedge reset)
	begin
		if (reset) sig_out <= 0;
		else
			case (sel[4:2])
				0: sig_out <= d[0];
				1: sig_out <= d[1];
				2: sig_out <= d[2];
				3: sig_out <= d[3];
				4: sig_out <= d[4];
				5: sig_out <= d[5];
				6: sig_out <= d[6];
				7: sig_out <= d[7];
			endcase
	end

endmodule
