// psi2c_readback.v

`timescale 1 ps / 1 ps


module psi2c_readback
(
	input clk,
	input sync,
	input reset,

  input go,
	input rda,
	input sync2,
	input i2c_send,
	output [31:0]d
);

	reg rdaff;
	always @(posedge clk or posedge reset) rdaff <= reset ? 0 : rda;


	wire nto;  // not timeout
	wire last;
	wire running;

	srff_timeout ffto
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),
		.s(go),
		.r(running),
		.to_disable(i2c_send),
		.q(nto)
	);

	rda_bitcounter bitcounter
	(
		.aclr(reset),
		.clk_en(sync),
		.clock(clk),
		.cnt_en(running),
		.sset(sync && !rda && rdaff && nto),
		.cout(last),
		.q()
	);
	
	assign running = !last;
	
	// shift register
	reg [28:0]shiftreg;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset) shiftreg <= 0;
		else if (running && sync) shiftreg <= {shiftreg[28:0], rdaff};
	end
	
	// rda data mapper
	wire [4:0]ha = shiftreg[7:3];
	wire [2:0]pa = shiftreg[2:0];
	wire [7:0]ra = {shiftreg[28:25], shiftreg[23:20]};
	wire [7:0]rd = {shiftreg[18:15], shiftreg[13:10]};
	wire start = shiftreg[8];
	wire _s3 = shiftreg[24];
	wire _rw = shiftreg[19];
	wire _d4 = shiftreg[14];
	wire _d0 = shiftreg[9];
	
	assign d = {running || nto, 2'b00, _s3, _rw, _d4, _d0, start, ha, pa, ra, rd};
	
endmodule
