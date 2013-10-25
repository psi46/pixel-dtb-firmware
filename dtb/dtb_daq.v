// dtb_daq.v

`timescale 1 ns / 1 ps


module dtb_daq
(
	input clk_daq,
	input clk_sys,
	input [7:0]sclk,
	input reset,
	input sync,

	// control
	input  [1:0]ctrl_adc_address,
	input  ctrl_adc_write,
	input  [15:0]ctrl_adc_writedata,
	input  ctrl_adc_read,
	output [15:0]ctrl_adc_readdata,

	input [3:0]ctrl_deser160,

	// pattern generator
	input [5:0]pg,
	
	input i2c_trigger,

	input tin,
	input tout,

	// adc input port
	input [11:0]adc_data,
	input adc_or,
	
	// data channels
	input sdata1,
	input sdata2,
	input sdata3,
	input sdata4,
	
	// data output channel 0
	output daq0_write,
	output reg [15:0]daq0_writedata,
	input daq0_running,
	
	// data output channel 1_a
	output daq1a_write,
	output [15:0]daq1a_writedata,
	input daq1_running,
	
	// data output channel 1_b
	output daq1b_write,
	output [15:0]daq1b_writedata,
	
	// data output channel 2_a
	output daq2a_write,
	output [15:0]daq2a_writedata,
	input daq2_running,
	
	// data output channel 2_b
	output daq2b_write,
	output [15:0]daq2b_writedata,
	
	// data output channel 3_a
	output daq3a_write,
	output [15:0]daq3a_writedata,
	input daq3_running,
	
	// data output channel 3_b
	output daq3b_write,
	output [15:0]daq3b_writedata,

	// data output channel 4_a
	output daq4a_write,
	output [15:0]daq4a_writedata,
	input daq4_running,
	
	// data output channel 4_b
	output daq4b_write,
	output [15:0]daq4b_writedata,

	output [5:0]TP
);

	// pattern generator signals
	wire pg_trigger; // trigger signal for probe
	wire pg_rest;    // TBM reset
	wire pg_res;     // ROC reset
	wire pg_cal;     // calibrate
	wire pg_trg;     // trigger
	wire pg_tok;     // token in
	assign {pg_trigger, pg_rest, pg_res, pg_cal, pg_trg, pg_tok} = pg;

	wire write_ana;
	wire [15:0]data_ana;
	wire write_roc;
	wire [15:0]data_roc;

	adc_readout adc_in
	(
		.clk(clk_daq),
		.sync(sync),
		.reset(reset),

		.avs_ctrl_address(ctrl_adc_address),
		.avs_ctrl_write(ctrl_adc_write),
		.avs_ctrl_writedata(ctrl_adc_writedata),
		.avs_ctrl_read(ctrl_adc_read),
		.avs_ctrl_readdata(ctrl_adc_readdata),

		.run(daq0_running),

		.trig1(pg_trigger),
		.trig2(i2c_trigger),
		.tin(tin),
		.tout(tout),

		.adc_data(adc_data),
		.adc_or(adc_or),

		.write(write_ana),
		.writedata(data_ana),
		
		.TP(TP)
	);

	deser160 channel1_roc
	(
		.clk(clk_daq),
		.sync(sync),
		.reset(reset),
		.sclk0(sclk[4]),
		.sclk180(sclk[0]),
		.ctrl(ctrl_deser160),
		.sdata(sdata1),
		.tin(tin),
		.tout(tout),
		.run(daq0_running),
		.write(write_roc),
		.data(data_roc)
	);
	
	deser400 channel1_module_400
	(
		.clock(clk_daq),
		.sclk(sclk[3:0]),
		.res(reset),
		.run(daq1_running),
		.input_data(sdata1),
		.write(daq1_write),
		.data_a(daq1a_writedata),
		.data_b(daq1b_writedata),
	);
	
	deser400 channel2_module_400
	(
		.clock(clk_daq),
		.sclk(sclk[3:0]),
		.res(reset),
		.input_data(sdata2),
		.run(daq2_running),
		.write(daq2_write),
		.data_a(daq2a_writedata),
		.data_b(daq2b_writedata),
	);
	
	deser400 channel3_module_400
	(
		.clock(clk_daq),
		.sclk(sclk[3:0]),
		.res(reset),
		.run(daq3_running),
		.input_data(sdata3),
		.write(daq1_write),
		.data_a(daq3a_writedata),
		.data_b(daq3b_writedata),
	);
	
		deser400 channel4_module_400
	(
		.clock(clk_daq),
		.sclk(sclk[3:0]),
		.res(reset),
		.run(daq4_running),
		.input_data(sdata4),
		.write(daq4_write),
		.data_a(daq4a_writedata),
		.data_b(daq4b_writedata),
	);
	
	

	always @(*)
	begin
		if (write_ana) daq0_writedata <= data_ana;
		else           daq0_writedata <= data_roc;
	end

	assign daq0_write = write_ana | write_roc;

endmodule
