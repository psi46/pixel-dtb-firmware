// trigger_control.v

`timescale 1 ns / 1 ps


module trigger_control
(
	input  clk,
	input  sync,
	input  reset,

	// control
	input sel_async,      // select async input
	input sel_sync,       // select sync input
	input sel_single,     // select single trigger input
	input sel_gen,        // select trigger generator input
	input sel_pg,         // select pattern generator input

	input sel_dir_async,  // select async input for direct output
	input sel_dir_sync,   // select sync input for direct output
	input sel_dir_single, // select single trigger for direct output
	input sel_dir_gen,    // select trigger generator input for direct output
	input sel_dir_pg,     // select pattern generator for direct output

	input sel_chain,      // sync in -> sync out (fast desy chain)
	input sel_sync_out,   // send trigger data to sync output

	// === sources ====================================================
	
	// async trigger input
	input  [4:0]src_async,  // trg
	input  [3:0]src_async_pos,

	// data trigger input
	input  [4:0]src_sync, // syn trg rsr rst
	input  src_sync_direct,

	// software controlled single event input
	input  [4:0]src_single, // syn trg rsr rst cal

	// trigger generator input
	input  [4:0]src_gen, // trg

	// pattern generator input
	input  [4:0]src_pg, // trg rsr rst cal


	// === sinks ======================================================

	// soft TBM output
	output [4:0]dst_tbm, // syn trg rsr rst cal
	output [3:0]dst_tbm_pos,
	
	// data trigger output
	output [4:0]dst_sync, // syn trg rsr rst
	output dst_sync_direct,
	
	// direct roc/module trigger output
	output [4:0]dst_dir  // trg rsr rst cal
);

	localparam SYN = 0;
	localparam TRG = 1;
	localparam RSR = 2;
	localparam RST = 3;
	localparam CAL = 4;

	// switch
	wire [4:0]src_async_gated  = {5{sel_async}}  & src_async;
	wire [4:0]src_sync_gated   = {5{sel_sync}}   & src_sync;
	wire [4:0]src_single_gated = {5{sel_single}} & src_single;
	wire [4:0]src_gen_gated    = {5{sel_gen}}    & src_gen;
	wire [4:0]src_pg_gated     = {5{sel_pg}}     & src_pg;
	
	wire [4:0]sum = src_async_gated | src_sync_gated
		| src_single_gated | src_gen_gated | src_pg_gated;
	
	assign dst_sync_direct = sel_chain & src_sync_direct;
	
	assign dst_tbm = sum;
	assign dst_sync = {5{sel_sync_out & !sel_chain}} & sum;

	assign dst_tbm_pos = src_async_pos & {4{src_async_gated[1]}};

	//
	wire [4:0]src_dir_async_gated  = {5{sel_dir_async}}  & src_async;
	wire [4:0]src_dir_sync_gated   = {5{sel_dir_sync}}   & src_sync;
	wire [4:0]src_dir_single_gated = {5{sel_dir_single}} & src_single;
	wire [4:0]src_dir_gen_gated    = {5{sel_dir_gen}}    & src_gen;
	wire [4:0]src_dir_pg_gated     = {5{sel_dir_pg}}     & src_pg;

	wire [4:0]sum_dir = src_dir_async_gated | src_dir_sync_gated
		| src_dir_single_gated | src_dir_gen_gated | src_dir_pg_gated;
	
	assign dst_dir = sum_dir;

endmodule
