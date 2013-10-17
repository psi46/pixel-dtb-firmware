// adc_readout.v

`timescale 1 ns / 1 ps


module adc_delay
(
	input  clk,
	input  reset,
	input  sync,
	input  [5:0]del,
	input  in,
	output out
);
	reg running;
	reg [5:0]cnt;
	wire start = in && !running;
	wire stop  = cnt == 0;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			running <= 0;
			cnt <= 0;
		end
		else if (sync)
		begin
			if (start) running <= 1;
			else if (stop) running <= 0;

			if (start) cnt <= del;
			else if (!stop) cnt <= cnt - 1;
		end
	end

	assign out = running && stop;
endmodule



module adc_timeout
(
	input  clk,
	input  reset,
	input  sync,
	input  [15:0]len,
	output [15:0]size,
	input  start,
	input  stop,
	output reg running
);

	reg [15:0]cnt;
	wire timeout = cnt == len;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset) running <= 0;
		else if (sync)
		begin
			if (stop || timeout) running <= 0;
			else if (start) running <= 1;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if (reset) cnt <= 0;
		else if (sync)
		begin
			if (running)    cnt <= cnt + 1;
			else if (start) cnt <= 0;
		end
	end
	
	assign size = cnt;
endmodule



module adc_readout
(
	input clk,
	input sync,
	input reset,

	input  [1:0]avs_ctrl_address,
	input  avs_ctrl_write,
	input  [15:0]avs_ctrl_writedata,
	input  avs_ctrl_read,
	output [15:0]avs_ctrl_readdata,

	input run,
	
	input trig1,
	input trig2,
	input tin,
	input tout,

	// ADC port
	input [11:0]adc_data,
	input adc_or,
	
	// FIFO port
	output write,
	output [15:0]writedata,

	output [5:0]TP
);


	wire start;
	wire stop;
	wire running;

	// control registers
	reg single;
	reg cont;
	reg [1:0]ssel;
	reg psel;
	reg [5:0]sdel;
	reg [5:0]pdel;
	reg [15:0]len;
	wire [15:0]size;

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			single <= 0;
			cont   <= 0;
			ssel    <= 0;
			psel    <= 0;
			sdel    <= 0;
			pdel    <= 0;
			len     <= 0;
		end
		else if (avs_ctrl_write)
		begin
			if (avs_ctrl_address == 0)
			begin
				cont <= avs_ctrl_writedata[0];
				if (!(start || running)) single <= avs_ctrl_writedata[1];
			end
			if (avs_ctrl_address == 1) { ssel, sdel } <=
				{ avs_ctrl_writedata[15:14], avs_ctrl_writedata[5:0] };
			if (avs_ctrl_address == 2) { psel, pdel } <=
				{ avs_ctrl_writedata[15:14], avs_ctrl_writedata[5:0] };
			if (avs_ctrl_address == 3) len <= avs_ctrl_writedata;
		end
		else if (start) single <= 0;
	end

  assign avs_ctrl_readdata = (avs_ctrl_address == 3) ?
    size : {13'h0000, running, single, cont};

// start select
	reg s;
	always @(*)
	begin
		case (ssel)
			0: s <= 0;
			1: s <= trig1;
			2: s <= trig2;
			3: s <= tin;
		endcase
	end

	wire s_gated = s && run && (cont || single);
	adc_delay sdelay(clk, reset, sync, sdel, s_gated, start);

	// stop select
	wire p_gated = tout && psel;
	adc_delay pdelay(clk, reset, sync, pdel, p_gated, stop);

	// burst generator
	reg start_reg;
//	reg stop_reg;
	wire [12:0]adc_reg = { adc_or, adc_data };
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			start_reg <= 0;
		end
		else if (sync)
		begin
			start_reg <= start;
		end
	end
	
	adc_timeout tocnt(clk, reset, sync, len, size, start, stop, running);
	assign write = running && sync;
	assign writedata = { start_reg, stop, 1'b0, adc_reg };

	assign TP = {s, s_gated, start, p_gated, run, running};
endmodule
