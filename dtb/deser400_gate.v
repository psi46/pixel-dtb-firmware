// deser400_gate.v


// periode:     105 ms
// gate length: 13 ms
// @ 40 MHz

module deser400_gate
(
	input clk,
	input sync,
	input reset,
	output reg gate
);

	wire [21:0]cnt;

	always @(posedge clk or posedge reset)
	begin
		if (reset) gate <= 0;
		else gate <= &cnt[21:19]; 
	end


	lpm_counter	delay_cnt
	(
				.aclr (reset),
				.clock (clk),
				.q (cnt),
				.aload (1'b0),
				.aset (1'b0),
				.cin (1'b1),
				.clk_en (sync),
				.cnt_en (1'b1),
				.cout (),
				.data ({22{1'b0}}),
				.eq (),
				.sclr (1'b0),
				.sload (1'b0),
				.sset (1'b0),
				.updown (1'b1));
	defparam
		delay_cnt.lpm_direction = "UP",
		delay_cnt.lpm_port_updown = "PORT_UNUSED",
		delay_cnt.lpm_type = "LPM_COUNTER",
		delay_cnt.lpm_width = 22;
		
endmodule
