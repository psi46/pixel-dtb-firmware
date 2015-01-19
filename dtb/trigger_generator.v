// trigger_generator.v

`timescale 1 ns / 1 ps


module trigger_generator
(
	input clk,
	input sync,
	input reset,

	input sel_random,
	input [31:0]rate,

	output reg [4:0]trg
);

	wire trg_rand;  // random trigger
	reg  trg_per;   // periodic trigger

	always @(posedge clk or posedge reset)
	begin
		if (reset) trg <= 0;
		else if (sync) trg <= {3'b000, sel_random ? trg_rand : trg_per, 1'b0};
	end

	// === periodic trigger generator =================================
	
	wire cnt_set;
	
	lpm_counter	cnt
	(
		.aclr (reset),
		.clk_en (sync),
		.clock (clk),
		.data (rate),
		.sload (cnt_set),
		.cout (cnt_set),
		.q (),
		.aload (1'b0),
		.aset (1'b0),
		.cin (1'b1),
		.cnt_en (1'b1),
		.eq (),
		.sclr (1'b0),
		.sset (1'b0),
		.updown (1'b1));
	defparam
		cnt.lpm_direction = "DOWN",
		cnt.lpm_port_updown = "PORT_UNUSED",
		cnt.lpm_type = "LPM_COUNTER",
		cnt.lpm_width = 32;

	always @(posedge clk or posedge reset)
	begin
		if (reset) trg_per <= 0;
		else if (sync) trg_per <= cnt_set;
	end


	// === pseudo random number generator =============================
	
	reg [31:0]sa;
	reg [31:0]sb;
	reg [31:0]sc;
	wire [31:0]s; // random number
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			sa <= 32'hffffffff;
			sb <= 32'hffffffff;
			sc <= 32'hffffffff;
		end
		else if (sync)
		begin
			sa <= {sa[19:1], sa[18:6]  ^ sa[31:19]};
			sb <= {sb[27:3], sb[29:23] ^ sb[31:25]};
			sc <= {sc[14:4], sc[28:8]  ^ sc[31:11]};
		end
	end
	assign s = sa ^ sb ^ sc;


	// === rate select comparator =====================================

	lpm_compare	comp
	(
		.aclr (reset),
		.clock (clk),
		.clken (sync),
		.dataa (s),
		.datab (rate),
		.aeb (),
		.agb (),
		.ageb (),
		.alb (trg_rand),
		.aleb (),
		.aneb ()
	);
	defparam
		comp.lpm_pipeline = 2,
		comp.lpm_representation = "UNSIGNED",
		comp.lpm_type = "LPM_COMPARE",
		comp.lpm_width = 32;


endmodule
