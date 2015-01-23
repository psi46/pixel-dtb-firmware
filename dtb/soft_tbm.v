// soft_tbm.v

`timescale 1 ns / 1 ps

module soft_tbm
(
	input clk,
	input sync,
	input reset,
       
	input [4:0]trg_in_tbm,
	input [4:0]trg_in_ctr,
	input [3:0]trg_pos,

  output tin,
  input tout,
	output deser_ena,

  output ctr,

  output daq_write,
  output reg [15:0]daq_data,

	input [15:0]token_timeout
);

wire ro_enable; // a readout can be started
wire trg_pass;   // trigger sent to ROC/TBM

wire queue_read;
wire queue_clear;
wire queue_clear_token;
wire queue_empty;
wire queue_full;
wire [3:0]queue_size;

wire queue_tok;
wire [7:0]queue_trigger_counter;
wire [3:0]queue_trg_pos;
wire [5:0]queue_flags;

wire tout_missing;

wire syn;  // sync event
wire trg;  // trigger event
wire rsr;  // ROC reset event
wire rst;  // TBM reset event

reg set_rsr;
wire rsr_int = rsr || set_rsr;

assign queue_clear = rst;
assign queue_clear_token = rsr_int;
assign trg_pass = trg && !queue_full;


// === receive and decode events ====================================

assign syn = trg_in_tbm[0];
assign trg = trg_in_tbm[1];
assign rsr = trg_in_tbm[2];
assign rst = trg_in_tbm[3];
assign cal = trg_in_tbm[4];

wire trg_dir = trg_in_ctr[1];
wire rsr_dir = trg_in_ctr[2];
wire rst_dir = trg_in_ctr[3];
wire cal_dir = trg_in_ctr[4];


/* commands
	* cal 
		send cal to ROC
		set(flag_cal)
	  
	* syn
		clear(trigger_counter)
		set(flag_sync)
	
	* rsr
		queue_clear_token
		reset ROC
		set flag_resr
		if (read_in_progress)
		{
			stop running readout
			add trailer
		}
	
	* rst
		queue_clear
		reset ROC
		set flag_resr
		set flag_rest
		if (read_in_progress)
		{
			stop running readout
		}

	* trg
		queue_write
		if (!queue_full)
		{
			send ROC trigger
		}
		else set flag_stkf
*/



// === Send Event to ROC/MODULE (CTR Generator) =====================

ctr_encoder ctr_enc
(
	.clk(clk),
	.sync(sync),
	.reset(reset),

	.cal(cal || cal_dir),
	.trg(trg_pass || trg_dir),
	.res_roc(rsr_int || rst || rsr_dir),
	.res_tbm(rst || rst_dir),
	.res_req(1'b0),
	.nmr_req(1'b0),
	.trg_veto(1'b0),
	.res_veto(1'b0),

	.running(),
	.ctr_out(ctr),
	.trg_out(),
	.res_out()
);


// === Flags ========================================================

reg flag_rest;  // TBM reset occured
reg flag_resr;  // ROC reset occured
reg flag_cal;   // calibrate received
reg flag_sync;  // sync signal received
reg flag_stkf;  // stack full
reg flag_ares;  // auto reset sent
reg flag_pkam;  // PKAM reset (not queued)
wire [5:0]flags = {flag_ares, flag_stkf, flag_sync, flag_cal, flag_resr, flag_rest};

always @(posedge clk or posedge reset)
begin
	if (reset)
	begin
		flag_cal  <= 0;
		flag_sync <= 0;
		flag_resr <= 0;
		flag_rest <= 0;
		flag_stkf <= 0;

		flag_ares <= 0;
//	flag_pkam <= 0;
	end
	else if (sync)
	begin
		if (trg_pass)
		begin
			flag_cal  <= 0;
			flag_sync <= 0;
			flag_resr <= 0;
			flag_rest <= 0;
			flag_stkf <= 0;

			flag_ares <= 0;
//		flag_pkam <= 0;
		end
		else
		if (cal) flag_cal  <= 1;
		if (syn) flag_sync <= 1;
		if (rsr_int || rst) flag_resr <= 1;
		if (rst) flag_rest <= 1;
		if (trg && queue_full) flag_stkf <= 1;
	end
end

// === Trigger Counter ==============================================

reg [7:0]trigger_counter;
always @(posedge clk or posedge reset) begin
	if (reset) trigger_counter <= 0;
	else if (sync) begin
		if (syn) trigger_counter <= 0;
		else if (trg_pass) trigger_counter <= trigger_counter + 1;
	end
end


// === enables start of a new readout id data in trigger stack
// first readout after buffer empty must be delayed

reg [4:0]ro_delay;
assign ro_enable = ro_delay[4];

always @(posedge clk or posedge reset) begin
	if (reset) begin
		ro_delay <= 5'd0;
	end
	else if (sync) begin
		if (queue_empty) ro_delay = 5'd12;
		else if (!ro_enable) ro_delay = ro_delay - 5'd1;
	end
end


// === header/trailer generator =====================================

/*
  ** header format **
	A | 0 | ev7  ev6  ev5  ev4  ev3  ev2  ev1  ev0
	8 | 0 | 0    0    0    0    pos3 pos2 pos1 pos0
 
 ** trailer format **
	E | 0 | ntok rest resr 0    sync clt  cal  stkf
	C | 0 | ares pkam 0    0    stk3 stk2 stk1 stk0
*/

reg [16:0]token_timeout_counter;
assign tout_missing = token_timeout_counter[16];


reg [5:0]sm_readout;
localparam SM_IDLE  = 6'b00_0000;
localparam SM_HDR1  = 6'b00_0010;
localparam SM_HDR2  = 6'b01_0010;
localparam SM_TOUT  = 6'b00_1100;
localparam SM_WAIT  = 6'b00_1000;
localparam SM_PCAM1 = 6'b01_1000;
localparam SM_PCAM2 = 6'b01_0000;
localparam SM_TRL0  = 6'b11_1000;
localparam SM_TRL1  = 6'b10_0010;
localparam SM_TRL2  = 6'b00_0011;
localparam SM_TRL3  = 6'b10_0000;

assign queue_read  = sm_readout[0];
assign daq_write   = sm_readout[1] && sync;
assign tin         = sm_readout[2];
assign deser_ena   = sm_readout[3];

// trailer delay counter
reg [2:0]trldel;
wire trl_start = trldel[2];
always @(posedge clk or posedge reset)
begin
	if (reset) trldel <= 0;
	else if (sync)
	begin
		if (~&sm_readout[5:4]) trldel <= 0;
		else if (!trl_start) trldel <= trldel + 3'd1;
	end
end

always @(posedge clk or posedge reset)
begin
	if (reset)
	begin
		sm_readout <= SM_IDLE;
		token_timeout_counter <= 0;
		set_rsr <= 0;
		flag_pkam <= 0;
	end
	else if (sync)
	begin
		case (sm_readout)
			SM_IDLE:
				if (ro_enable) sm_readout <= SM_HDR1;
			SM_HDR1:
				sm_readout <= SM_HDR2;
			SM_HDR2:
				sm_readout <= queue_tok ? SM_TOUT : SM_TRL1;
			SM_TOUT:
				begin
					token_timeout_counter <= {1'b0, token_timeout};
					sm_readout <= SM_WAIT;
				end
			SM_WAIT:
				begin
					token_timeout_counter <= token_timeout_counter - 17'd1;
					if (tout_missing) sm_readout <= SM_PCAM1;
					else if (tout || flag_resr) sm_readout <= SM_TRL0;
				end
			SM_PCAM1:
				begin
					flag_pkam <= 1;
					set_rsr <= 1;
					sm_readout <= SM_PCAM2;
				end
			SM_PCAM2:
				begin
					set_rsr <= 0;
					sm_readout <= SM_TRL0;
				end
			SM_TRL0:
				if (trl_start) sm_readout <= SM_TRL1;
			SM_TRL1:
				sm_readout <= SM_TRL2;
			SM_TRL2:
				sm_readout <= SM_TRL3;
			SM_TRL3:
				begin
					flag_pkam <= 0;
					sm_readout <= SM_IDLE;
				end
			default: sm_readout <= SM_IDLE;
		endcase
	end
end

always @(*)
begin
	if      (sm_readout == SM_HDR1)
		daq_data <= {8'ha0, queue_trigger_counter};
	else if (sm_readout == SM_HDR2)
		daq_data <= {8'h80, 4'b0000, queue_trg_pos};
	else if (sm_readout == SM_TRL1)
		daq_data <= {8'he0, ~queue_tok, queue_flags[0],
			queue_flags[1], 1'b0, queue_flags[3], queue_flags[3], queue_flags[2], queue_flags[4]};
	else if (sm_readout == SM_TRL2)
		daq_data <= {8'hc0, queue_flags[5], flag_pkam, 2'b00, queue_size};
	else daq_data <= 16'd0;
end


soft_tbm_queue #(18) stack
(
	.clk(clk),
	.sync(sync),
	.reset(reset),
	.write(trg_pass),
	.read(queue_read),
	.clear(queue_clear),
	.clear_token(queue_clear_token),
	.empty(queue_empty),
	.full(queue_full),
	.size(queue_size),
	.din({flags, trg_pos, trigger_counter, 1'b1}),
	.dout({queue_flags, queue_trg_pos, queue_trigger_counter, queue_tok})
);

endmodule
