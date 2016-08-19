// trigger_sampling.v

module trigger_in_async
(
	input clk80,
	input clk400,
	input sync,
	input reset,
	
	input trigger_in,
	output [4:0]trigger_out,
	output [3:0]trigger_pos
);


	// --- noise filter (trigger_in -> trg_denoise)

	// oversampling shift register (trigger_in -> trg_in)
	reg [3:0]trg_in;
	always @(posedge clk400 or posedge reset)
	begin
		if (reset) trg_in <= 0;
		else trg_in <= {trg_in[2:0], trigger_in};
	end

	// noise filter (trg_in -> trg_denoise)
	reg trg_denoise;
	always @(posedge clk400 or posedge reset)
	begin
		if (reset) trg_denoise <= 0;
		else if (trg_in[3] && trg_in[0])
		begin
	    if (|trg_in[2:1]) trg_denoise <= 1;
		end
		else if (trg_in[2:0] == 0) trg_denoise <= 0;
	end


	// --- edge detector (trig_denoise -> trg_start, trg_stop)
	reg trg_delay;
	always @(posedge clk400 or posedge reset)
	begin
		if (reset) trg_delay <= 0;
		else trg_delay <= trg_denoise;
	end

	wire trg_start =  trg_denoise && !trg_delay;
	wire trg_stop  = !trg_denoise &&  trg_delay;


	// --- synch80: synchronization pulse rel to 80 Mhz (-> clear, stop)
	reg sync1;
	reg clear;
	reg stop;
	always @(posedge clk400 or posedge reset)
	begin
		if (reset)
		begin
			sync1 <= 0;
			clear <= 0;
			stop  <= 0;
		end
		else
		begin
			sync1 <= clk80;
			clear <= sync && clk80 && !sync1;
			stop  <= clear;
		end
	end


	// --- position counter (-> poscnt)
	reg [3:0]poscnt;
	always @(posedge clk400 or posedge reset)
	begin
		if (reset)
		begin
	    poscnt  <= 0;
	  end
		else
		begin
			if (clear) poscnt <= 4'd0;
			else poscnt <= poscnt + 4'd1;
		end
	end


	// --- trigger generator (trg_start, trg_stop, stop -> trg_reg, pos_reg)
	reg trg_reg;
	reg trg_reg1;
	reg [3:0]pos_reg;
	wire running = trg_reg || trg_reg1;
	
	always @(posedge clk400 or posedge reset)
	begin
		if (reset)
		begin
		  trg_reg  <= 0;
		  trg_reg1 <= 0;
			pos_reg  <= 0;
		end
		else if (running)
	  begin
	    if (stop)     trg_reg  <= 0;
	    if (trg_stop) trg_reg1 <= 0;
	  end
	  else if (trg_start)
		begin
		  trg_reg  <= 1;
		  trg_reg1 <= 1;
			pos_reg  <= poscnt;
		end
	end

	// (trg_reg, pos_reg -> trg400_out, trg400_pos)
	reg trg400_out;
	reg [3:0]trg400_pos;
	
	always @(posedge clk400 or posedge reset)
	begin
		if (reset)
		begin
			trg400_out <= 0;
			trg400_pos <= 0;
		end
		else if (stop)
		begin
			trg400_out <= trg_reg;
			trg400_pos <= pos_reg;
		end
	end


	// --- clock domain crossing clk400 -> clk80
	//  (trg400_out, trg400_pos -> trg40, trg40_pos)
	reg trg40;
	reg [3:0]trg40_pos;
	
	always @(posedge clk80 or posedge reset)
	begin
		if (reset)
		begin
			trg40     <= 0;
			trg40_pos <= 0;
		end
		else if (sync)
		begin
			trg40     <= trg400_out;
			trg40_pos <= trg400_pos;
		end
	end


	// --- skip triggers that follows to short (trg40, trg40_blk)
	reg [1:0]trg_veto_cnt;
	wire trg_veto = |trg_veto_cnt;
	
	always @(posedge clk80 or posedge reset)
	begin
	  if (reset) trg_veto_cnt <= 2'd0;
	  else if (sync)
	  begin
	  	if (trg_veto) trg_veto_cnt <= trg_veto_cnt - 2'd1;
	  	else if (trg40) trg_veto_cnt <= 2'd3;
	  end
	end
	
	wire trg40_blk = trg40 & !trg_veto;

	
	// --- create event output
	assign trigger_out = {3'b000, trg40_blk, 1'b0};
	assign trigger_pos = trg40_pos;


endmodule
