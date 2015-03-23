// trigger_top.v

`timescale 1 ns / 1 ps


module trigger
(
	input  clk,
	input  sclk,
	input  sync,
	input  reset,
	
	input ctrl_write,
	input [31:0]ctrl_writedata,
	input [3:0]ctrl_address,
	
	// async trigger input
	input  trigger_in,

	// trigger data in/out
	input  evin,
	output evout,
	
	// pattern generator input
	input  pg_trg,
	input  pg_rsr,
	input  pg_rst,
	input  pg_cal,

	input  pg_tin,

	output deser_ena,	
	
	// ROC/module
	output roc_ctr,
	output roc_tin,
	input  roc_tout,
	
	output daq_write,
	output [15:0]daq_data
);

	// --- control signals begin --------
	wire sel_async;
	wire sel_sync;
	wire sel_single;
	wire sel_gen;
	wire sel_pg;
	wire sel_dir_single;
	wire sel_dir_pg;
	wire sel_chain;
	wire sel_sync_out;
	
	wire [4:0]send_trig;
	
	wire gen_sel_random;
	wire [31:0]gen_rate;
	
	wire [7:0]trg_delay;
	wire [15:0]token_timeout;
	// --- control signals end ----------

	wire [22:0]dummy23;
	wire [26:0]dummy27;
	wire [30:0]dummy31;
	wire [23:0]dummy24;
	wire [15:0]dummy16;

	trigger_interface port
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),

		.write(ctrl_write),
		.writedata(ctrl_writedata),
		.address(ctrl_address),

		.reg0({dummy23, sel_async, sel_sync, sel_single, sel_gen,
			sel_pg, sel_dir_single, sel_dir_pg, sel_chain, sel_sync_out}),
		.reg1({dummy27, send_trig}),
		.reg2({dummy31, gen_sel_random}),
		.reg3(gen_rate),
		.reg4({dummy24, trg_delay}),
		.reg5({dummy16, token_timeout})
	);


	// === sources ====================================================

	wire [4:0]trig_async_in;
	wire [3:0]trig_async_pos;

	trigger_in_async trg_in_async
	(
		.clk80(clk),
		.clk400(sclk),
		.sync(sync),
		.reset(reset),
		.trigger_in(trigger_in),
		.trigger_out(trig_async_in),
		.trigger_pos(trig_async_pos)
	);


	wire trig_del_sig;
	wire [4:0]trig_del_out;
	wire [4:0]trig_del = trig_del_out & {5{trig_del_sig}};
	wire [3:0]trig_del_pos;

	trigger_delay #(9) trg_del
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),
		.delay(trg_delay),
		.trg_in(|trig_async_in),
		.data_in({trig_async_pos, trig_async_in}),
		.trg_out(trig_del_sig),
		.data_out({trig_del_pos, trig_del_out})
	);
	
	
	wire [4:0]trig_gen;

	trigger_generator trg_gen
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),
		.sel_random(gen_sel_random),
		.rate(gen_rate),
		.trg(trig_gen)
	);


	wire [4:0]trig_sync_in;
	wire sync_bridge_in;

	trigger_in_sync trg_data_in
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),
		.din(evin),
		.trigger_out(trig_sync_in),
		.direct_in(sync_bridge_in)
	);


	// === sinks ======================================================

	wire [4:0]trig_sync_out;
	wire sync_bridge_out;

	trigger_out_sync trg_data_out
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),
		.trigger_in(trig_sync_out),
		.direct_out(sync_bridge_out),
		.dout(evout)
	);


	wire [4:0]trig_tbm;
	wire [3:0]trig_tbm_pos;
	wire [4:0]trig_ctr;
	wire deser_ena_tbm;
	wire roc_tin_tbm;
	
	assign deser_ena = deser_ena_tbm
		|| !(sel_async || sel_sync || sel_single || sel_gen || sel_pg);
	
	soft_tbm tbm
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),
		.trg_in_tbm(trig_tbm),
		.trg_in_ctr(trig_ctr),
		.trg_pos(trig_tbm_pos),
		.tin(roc_tin_tbm),
		.tout(roc_tout),
		.deser_ena(deser_ena_tbm),
		.ctr(roc_ctr),
		.daq_write(daq_write),
		.daq_data(daq_data),
		.token_timeout(token_timeout)
	);

	assign roc_tin = roc_tin_tbm || (pg_tin && sel_dir_pg);
	

	// === switch =====================================================

	trigger_control switch
	(
		.clk(clk),
		.sync(sync),
		.reset(reset),

		// control
		.sel_async(sel_async),
		.sel_sync(sel_sync),
		.sel_single(sel_single),
		.sel_gen(sel_gen),
		.sel_pg(sel_pg),
		.sel_dir_single(sel_dir_single),
		.sel_dir_pg(sel_dir_pg),
		.sel_chain(sel_chain),
		.sel_sync_out(sel_sync_out),

		// sources
		.src_async(trig_del),
		.src_async_pos(trig_del_pos),
		
		.src_sync(trig_sync_in),
		.src_sync_direct(sync_bridge_in),
		
		.src_single(send_trig),
		
		.src_gen(trig_gen),
		
		.src_pg({pg_cal, pg_rst, pg_rsr, pg_trg, 1'b0}),
		
		// sinks
		.dst_tbm(trig_tbm),
		.dst_tbm_pos(trig_tbm_pos),
		
		.dst_sync(trig_sync_out),
		.dst_sync_direct(sync_bridge_out),

		.dst_dir(trig_ctr)
	);


endmodule
