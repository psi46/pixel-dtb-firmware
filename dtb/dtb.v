// Copyright (C) 1991-2012 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 32-bit"
// VERSION		"Version 12.0 Build 263 08/02/2012 Service Pack 2.16 SJ Full Version"
// CREATED		"Thu Feb 07 14:48:08 2013"

/*
Warning (275043): Pin "ADC_clk" is missing source
Warning (275043): Pin "UI_GPIO1" is missing source
Warning (275043): Pin "ADC_pdwn" is missing source
Warning (275043): Pin "RAM_addr[12..0]" is missing source
Warning (275009): Pin "CPS_dataout" not connected
Warning (275009): Pin "LVDS2LCDS_sdo" not connected
Warning (275009): Pin "ADC_dco" not connected
Warning (275009): Pin "Ethernet_rx_clk" not connected
Warning (275009): Pin "Ethernet_rx_dv" not connected
Warning (275009): Pin "Ethernet_int_n" not connected
Warning (275009): Pin "SD_miso" not connected
Warning (275009): Pin "SD_cd" not connected
Warning (275009): Pin "clk40_2" not connected
Warning (275009): Pin "Ethernet_rxd" not connected
*/

module dtb
(

// --- EPCS
	output EPCS_DCLK,
	output EPCS_nCSO,
	output EPCS_ASDO,
	input  EPCS_DATA0,

// --- clock
  input clk50,
  input clk50_2,


  input CPS_dataout,
  input LVDS2LCDS_tout,
  input LVDS2LCDS_sdata_I,
  input LVDS2LCDS_sdo,
  input ADC_dco,
  input ADC_or,
  input USB_clk,
  input USB_rxf_n,
  input USB_txe_n,
  input Ethernet_rx_clk,
  input Ethernet_rx_dv,
  input Ethernet_int_n,
  input SD_miso,
  input SD_cd,
  input UI_clk,
  input LVDS2LCDS_sdata_II,
  input LVDS2LCDS_sdata_III,
  input LVDS2LCDS_sdata_IV,
  input CRC_error_in,
  input UI_GPIO0,
  input [11:0] ADC_data,
  input [3:0] Ethernet_rxd,
  input [1:0] Switches,
  output 	ADC_clk,
  output 	SD_clk,
  output 	SD_cs,
  output 	SD_mosi,
  output 	RAM_cke,
  output 	RAM_cs_n,
  output 	RAM_ras_n,
  output 	RAM_cas_n,
  output 	RAM_we_n,
  output 	RAM_odt,
  output 	Ethernet_tx_en,
  output 	Ethernet_mdc,
  output 	Ethernet_gtx_clk,
  output 	Ethernet_reset_n,
  output 	UI_GPIO1,
  output 	USB_rd_n,
  output 	USB_wr_n,
  output 	USB_siwua,
  output 	USB_oe_n,
  output 	LVDS2LCDS_reset_n,
  output 	LVDS2LCDS_scl,
  output 	LVDS2LCDS_sdi,
  output 	LVDS2LCDS_sld,
  output 	CPS_clk,
  output 	CPS_ce_n,
  output 	CPS_datain,
  output 	CPS_reset_n,
  output 	CPS_update_n,
  output 	ADC_pdwn,
  output 	LVDS2LCDS_clk,
  output 	LVDS2LCDS_ctr,
  output 	LVDS2LCDS_sda,
  output 	LVDS2LCDS_tin,
  output 	Power_run,
  output 	Chip_HV,
  output 	Chip_reset_n,
  output 	Chip_term,
  inout 	Plug_scl2,
  inout 	Plug_sda2,
  inout 	RAM_clk,
  inout 	RAM_clk_n,
  inout 	Ethernet_mdio,
  inout 	UI_GPIO2,
  inout 	Power_scl,
  inout 	Power_sda,
  output 	[3:0] Chip_addr,
  output 	[3:0] Ethernet_txd,
  output 	[3:0] LEDs,
  output 	[7:0] Plug_IOs,
  output 	[12:0] RAM_addr,
  output 	[1:0] RAM_ba,
  output 	[3:0] RAM_dm,
  inout 	[31:0] RAM_dq,
  inout 	[3:0] RAM_dqs,
  inout 	[15:0] UI_IOs,
  inout 	[7:0] USB_data
);

wire	clk_daq;
wire	clk_good;
wire	clk_present;
wire	clk_select_ext;
wire	clk_sys;
reg	clkena;
wire	[2:0] daq_addr;
wire	daq_read;
wire	[31:0] daq_readdata;
wire	daq_write;
wire	[31:0] daq_writedata;
wire	[1:0] LEDs_ALTERA_SYNTHESIZED;
wire	res;
wire	res_n;
wire	[7:0] sclk;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	[3:0] SYNTHESIZED_WIRE_7;
wire	[4:0] SYNTHESIZED_WIRE_11;

assign	SD_clk = 0;
assign	SD_cs = 0;
assign	SD_mosi = 0;
assign	Ethernet_tx_en = 0;
assign	Ethernet_mdc = 0;
assign	Ethernet_gtx_clk = 0;
assign	Ethernet_reset_n = 0;
assign	Ethernet_txd = 4'b0000;
assign	Power_run = SYNTHESIZED_WIRE_11[1];
assign	Chip_HV = SYNTHESIZED_WIRE_11[2];
assign	Chip_reset_n = SYNTHESIZED_WIRE_11[3];
assign	Chip_term = SYNTHESIZED_WIRE_11[4];
assign	SYNTHESIZED_WIRE_6 = 1;
wire	[2:0] GDFX_TEMP_SIGNAL_0;


assign	GDFX_TEMP_SIGNAL_0 = {CRC_error_in,clk_good,clk_present};


dtb_system	b2v_inst(
	.clkin_50(clk_sys),
	.reset_n(res_n),
	.epcs_data0(EPCS_DATA0),
	.clk_clk(clk_daq),
	.usb_usb_clk(SYNTHESIZED_WIRE_0),
	.usb_usb_txe_n(USB_txe_n),
	.usb_usb_rxf_n(USB_rxf_n),
	.pg_clkena(clkena),
	.pg_trigger(SYNTHESIZED_WIRE_1),
	.sig_clk_sclk(sclk[0]),
	.sig_clk_sig_in(SYNTHESIZED_WIRE_2),
	.sig_sda_sclk(sclk[0]),
	.sig_sda_sig_in(SYNTHESIZED_WIRE_3),
	.sig_ctr_sclk(sclk[0]),
	.sig_ctr_sig_in(SYNTHESIZED_WIRE_4),
	.sig_tin_sclk(sclk[0]),
	.sig_tin_sig_in(SYNTHESIZED_WIRE_5),
	.mem_clk_to_and_from_the_sdram(RAM_clk),
	.mem_clk_n_to_and_from_the_sdram(RAM_clk_n),
	.i2c_pwr_sda(Power_sda),
	.i2c_pwr_scl(Power_scl),
	.i2c_hs_readdata(daq_readdata),
	.in_port_to_the_button_pio(Switches),
	.mem_dq_to_and_from_the_sdram(RAM_dq),
	.mem_dqs_to_and_from_the_sdram(RAM_dqs),
	.status_export(GDFX_TEMP_SIGNAL_0),
	.usb_usb_data(USB_data),
	.mem_odt_from_the_sdram(RAM_odt),
	.mem_cs_n_from_the_sdram(RAM_cs_n),
	.mem_cke_from_the_sdram(RAM_cke),
	.mem_ras_n_from_the_sdram(RAM_ras_n),
	.mem_cas_n_from_the_sdram(RAM_cas_n),
	.mem_we_n_from_the_sdram(RAM_we_n),
	.epcs_dclk(EPCS_DCLK),
	.epcs_sce(EPCS_nCSO),
	.epcs_sdo(EPCS_ASDO),
	
	
	
	
	.usb_usb_siwu_n(USB_siwua),
	.usb_usb_oe_n(USB_oe_n),
	.usb_usb_wr_n(USB_wr_n),
	.usb_usb_rd_n(USB_rd_n),
	.lvds2lcds_reset_n(LVDS2LCDS_reset_n),
	.lvds2lcds_scl(LVDS2LCDS_scl),
	.lvds2lcds_sdi(LVDS2LCDS_sdi),
	.lvds2lcds_sld(LVDS2LCDS_sld),
	.adv3224_reset_n(CPS_reset_n),
	.adv3224_ce_n(CPS_ce_n),
	.adv3224_update_n(CPS_update_n),
	.adv3224_clk(CPS_clk),
	.adv3224_datain(CPS_datain),
	.i2c_hs_read(daq_read),
	.i2c_hs_write(daq_write),
	.sig_clk_sig_out(LVDS2LCDS_clk),
	.sig_sda_sig_out(LVDS2LCDS_sda),
	.sig_ctr_sig_out(LVDS2LCDS_ctr),
	.sig_tin_sig_out(LVDS2LCDS_tin),
	
	
	
	
	.control_export(SYNTHESIZED_WIRE_11),
	.i2c_hs_addr(daq_addr),
	.i2c_hs_writedata(daq_writedata),
	
	.mem_ba_from_the_sdram(RAM_ba),
	.mem_dm_from_the_sdram(RAM_dm),
	
	
	.out_port_from_the_led_pio(LEDs),
	.pg_pgout(SYNTHESIZED_WIRE_7),
	.roc_id_export(Chip_addr)
	);




always@(posedge clk_daq)
begin
	clkena <= clkena ^ SYNTHESIZED_WIRE_6;
end




FED	b2v_inst3(
	.clk(clk_daq),
	.res(res),
	.LVDS2LCDS_sdata_I(LVDS2LCDS_sdata_I),
	.LVDS2LCDS_sdata_II(LVDS2LCDS_sdata_II),
	.LVDS2LCDS_sdata_III(LVDS2LCDS_sdata_III),
	.LVDS2LCDS_sdata_IV(LVDS2LCDS_sdata_IV),
	.ADC_or(ADC_or),
	.clkena(clkena),
	.ADC_data(ADC_data),
	.sclk(sclk),
	.sel(LEDs_ALTERA_SYNTHESIZED),
	.dout(Plug_IOs));



FEC	b2v_inst5(
	.res(res),
	.TOUT(LVDS2LCDS_tout),
	.trigger(UI_GPIO0),
	.write(daq_write),
	.read(daq_read),
	.clkena(clkena),
	.clk_sys(clk_sys),
	.clk_daq(clk_daq),
	.address(daq_addr),
	.pg_data(SYNTHESIZED_WIRE_7),
	.sclk(sclk),
	.writedata(daq_writedata),
	.TIN(SYNTHESIZED_WIRE_5),
	.ROC_CLK(SYNTHESIZED_WIRE_2),
	.ROC_CTR(SYNTHESIZED_WIRE_4),
	.ROC_SDA(SYNTHESIZED_WIRE_3),
	.pg_trigger(SYNTHESIZED_WIRE_1),
	.readdata(daq_readdata));


global	b2v_inst6(
	.in(USB_clk),
	.out(SYNTHESIZED_WIRE_0));


clocks_no_ethernet	b2v_inst7(
	.clock_int(clk40),
	.clock_ext_select(clk_select_ext),
	.clock_ext(UI_clk),
	.sysclk(clk_sys),
	.reset_n(res_n),
	.clk(clk_daq),
	.clock_ext_present(clk_present),
	.clk_good(clk_good),
	.reset(res),
	.sclk(sclk));



assign	clk_select_ext = SYNTHESIZED_WIRE_11[0];

endmodule
