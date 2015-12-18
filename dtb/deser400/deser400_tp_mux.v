// deser400_tp_mux.v


module deser400_tp_mux
(
	input clk,
	input reset,
	
	input [6:0]sela,
	input [6:0]selb,
	
	input [31:0]tp1,
	input [31:0]tp2,
	input [31:0]tp3,
	input [31:0]tp4,
	
	output tpa,
	output tpb
);

	wire [3:0]a;
	tp_channel_mux mux_1a(clk, reset, sela[4:0], tp1, a[0]);
	tp_channel_mux mux_2a(clk, reset, sela[4:0], tp2, a[1]);
	tp_channel_mux mux_3a(clk, reset, sela[4:0], tp3, a[2]);
	tp_channel_mux mux_4a(clk, reset, sela[4:0], tp4, a[3]);
	tp_group_mux mux_a   (clk, reset, sela[6:5],   a, tpa );

	wire [3:0]b;
	tp_channel_mux mux_1b(clk, reset, selb[4:0], tp1, b[0]);
	tp_channel_mux mux_2b(clk, reset, selb[4:0], tp2, b[1]);
	tp_channel_mux mux_3b(clk, reset, selb[4:0], tp3, b[2]);
	tp_channel_mux mux_4b(clk, reset, selb[4:0], tp4, b[3]);
	tp_group_mux mux_b   (clk, reset, selb[6:5],   b, tpb);
	
endmodule


module tp_group_mux
(
	input clk,
	input reset,
	
	input [1:0]sel,

	input [3:0]in,
	output reg out
);

	always @(posedge clk or posedge reset)
	begin
		if (reset) out <= 0;
		else
		begin
			case (sel)
				2'd0:  out <= in[0];
				2'd1:  out <= in[1];
				2'd2:  out <= in[2];
				2'd3:  out <= in[3];
			endcase
		end
	end

endmodule


module tp_channel_mux
(
	input clk,
	input reset,
	
	input [4:0]sel,

	input [31:0]in,
	output reg out
);

	always @(posedge clk or posedge reset)
	begin
		if (reset) out <= 0;
		else
		begin
			case (sel)
				5'd0:  out <= in[0];
				5'd1:  out <= in[1];
				5'd2:  out <= in[2];
				5'd3:  out <= in[3];
				5'd4:  out <= in[4];
				5'd5:  out <= in[5];
				5'd6:  out <= in[6];
				5'd7:  out <= in[7];
				5'd8:  out <= in[8];
				5'd9:  out <= in[9];
				5'd10: out <= in[10];
				5'd11: out <= in[11];
				5'd12: out <= in[12];
				5'd13: out <= in[13];
				5'd14: out <= in[14];
				5'd15: out <= in[15];
				5'd16: out <= in[16];
				5'd17: out <= in[17];
				5'd18: out <= in[18];
				5'd19: out <= in[19];
				5'd20: out <= in[20];
				5'd21: out <= in[21];
				5'd22: out <= in[22];
				5'd23: out <= in[23];
				5'd24: out <= in[24];
				5'd25: out <= in[25];
				5'd26: out <= in[26];
				5'd27: out <= in[27];
				5'd28: out <= in[28];
				5'd29: out <= in[29];
				5'd30: out <= in[30];
				5'd31: out <= in[31];
			endcase
		end
	end

endmodule
