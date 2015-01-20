// ctr_encoder.v
// cal-trg-res encoder

`timescale 1 ns / 1 ps


module ctr_encoder
(
	input clk,
	input sync,
	input reset,

	input cal,      // send calibrate
	input trg,      // send trigger (maskable by trg_veto)
	input res_roc,  // send ROC reset (maskable by res_veto)
	input res_tbm,  // send TBM reset (maskable by res_veto)
	input res_req,  // ROC reset request (delayed if res_veto)
	input nmr_req,  // ROC reset request (not delayed if res_veto)
	input trg_veto, // trigger veto
	input res_veto, // ROC/TBM reset veto

	output running,
	output ctr_out,
	output trg_out,
	output res_out
);

	// maskable reset request	SRFF
	reg res_req_ff;
	always @(posedge clk or posedge reset)
	begin
		if (reset) res_req_ff <= 0;
		else if (sync)
		begin
			if      (res_req) res_req_ff <= 1;
			else if (res_out) res_req_ff <= 0;
		end
	end

	// non maskable reset request SRFF
	reg nmr_req_ff;
	always @(posedge clk or posedge reset)
	begin
		if (reset) nmr_req_ff <= 0;
		else if (sync)
		begin
			if      (nmr_req) nmr_req_ff <= 1;
			else if (res_out) nmr_req_ff <= 0;
		end
	end

	wire res  = nmr_req_ff || ((res_roc || res_req_ff) && !res_veto);
	wire rtbm = res_tbm && !res_veto;
	wire trig = trg & !trg_veto;


	// state machine
	reg [6:0]ctrgen;
	localparam SM_IDLE = 7'b000_0000;
	localparam SM_CAL1 = 7'b000_1001;
	localparam SM_CAL2 = 7'b000_0001;
	localparam SM_CAL3 = 7'b001_0001;
	localparam SM_TRG1 = 7'b000_1101;
	localparam SM_TRG2 = 7'b001_1001;
	localparam SM_TRG3 = 7'b010_0001;
	localparam SM_RES1 = 7'b000_1011;
	localparam SM_RES2 = 7'b010_1001;
	localparam SM_RES3 = 7'b011_1001;
	localparam SM_TBM1 = 7'b001_1011;
	localparam SM_TBM2 = 7'b011_0001;
	localparam SM_TBM3 = 7'b100_1001;

	assign {ctr_out, trg_out, res_out, running} = ctrgen[3:0];

	always @(posedge clk or posedge reset)
	begin
		if (reset) ctrgen <= SM_IDLE;
		else if (sync)
		casex ({ctrgen,  res,  rtbm, trig, cal})
			// start (priority decoding)
			     {SM_IDLE, 1'b1, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_RES1;
			     {SM_IDLE, 1'b0, 1'b1, 1'bx, 1'bx}: ctrgen <= SM_TBM1;
			     {SM_IDLE, 1'b0, 1'b0, 1'b1, 1'bx}: ctrgen <= SM_TRG1;
			     {SM_IDLE, 1'b0, 1'b0, 1'b0, 1'b1}: ctrgen <= SM_CAL1;
			// process calibrate
			     {SM_CAL1, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_CAL2;
			     {SM_CAL2, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_CAL3;
			     {SM_CAL3, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_IDLE;
			// process trigger
			     {SM_TRG1, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_TRG2;
			     {SM_TRG2, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_TRG3;
			     {SM_TRG3, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_IDLE;
			// process ROC reset
			     {SM_RES1, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_RES2;
			     {SM_RES2, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_RES3;
			     {SM_RES3, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_IDLE;
			// process TBM reset
			     {SM_TBM1, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_TBM2;
			     {SM_TBM2, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_TBM3;
			     {SM_TBM3, 1'bx, 1'bx, 1'bx, 1'bx}: ctrgen <= SM_IDLE;
		endcase
	end

endmodule
