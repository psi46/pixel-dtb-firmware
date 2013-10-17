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
	
	// data channel 1
	input sdata1,

	// data output channel 1
	output daq0_write,
	output reg [15:0]daq0_writedata,
	input daq0_running,
	
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


	always @(*)
	begin
		if (write_ana) daq0_writedata <= data_ana;
		else           daq0_writedata <= data_roc;
	end

	assign daq0_write = write_ana | write_roc;

endmodule
