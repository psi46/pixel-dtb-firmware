// deser400_tp_mux.v


module deser400_tp_mux
(
	input clk,
	input reset,
	
	input [5:0]sela,
	input [5:0]selb,
	
	input [12:0]tp1,
	input [12:0]tp2,
	input [12:0]tp3,
	input [12:0]tp4,
	
	output tpa,
	output tpb
);

	wire [3:0]a;
	tp_channel_mux mux_1a(clk, reset, sela[3:0], tp1, a[0]);
	tp_channel_mux mux_2a(clk, reset, sela[3:0], tp2, a[1]);
	tp_channel_mux mux_3a(clk, reset, sela[3:0], tp3, a[2]);
	tp_channel_mux mux_4a(clk, reset, sela[3:0], tp4, a[3]);
	tp_group_mux mux_a   (clk, reset, sela[5:4],   a, tpa );

	wire [3:0]b;
	tp_channel_mux mux_1b(clk, reset, selb[3:0], tp1, b[0]);
	tp_channel_mux mux_2b(clk, reset, selb[3:0], tp2, b[1]);
	tp_channel_mux mux_3b(clk, reset, selb[3:0], tp3, b[2]);
	tp_channel_mux mux_4b(clk, reset, selb[3:0], tp4, b[3]);
	tp_group_mux mux_b   (clk, reset, selb[5:4],   b, tpb);
	
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
	
	input [3:0]sel,

	input [12:0]in,
	output reg out
);

	always @(posedge clk or posedge reset)
	begin
		if (reset) out <= 0;
		else
		begin
			case (sel)
				4'd0:  out <= in[0];
				4'd1:  out <= in[1];
				4'd2:  out <= in[2];
				4'd3:  out <= in[3];
				4'd4:  out <= in[4];
				4'd5:  out <= in[5];
				4'd6:  out <= in[6];
				4'd7:  out <= in[7];
				4'd8:  out <= in[8];
				4'd9:  out <= in[9];
				4'd10: out <= in[10];
				4'd11: out <= in[11];
				4'd12: out <= in[12];
				default: out <= 0;
			endcase
		end
	end

endmodule
