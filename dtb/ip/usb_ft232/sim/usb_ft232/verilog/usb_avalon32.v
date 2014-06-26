// usb_avalon.v

`timescale 1 ns / 1 ps


module usb_avalon_32bit
(
	input clk,
	input reset,

	// avs_ctrl
	input avs_ctrl_address,
	input avs_ctrl_write,
	input [7:0]avs_ctrl_writedata,
	input avs_ctrl_read,
	output [7:0]avs_ctrl_readdata,

	// asi_uplink
	output ready,
	input valid,
	input [31:0]data,
	input startofpacket,
	input endofpacket,
	input [1:0]empty,
	
	// tx fifo interface
	output tx_write,
	output [15:0]tx_data,
	output [1:0]tx_mask,
	input  tx_full,

	// rx fifo interface
	output rx_read,
	input  [15:0]rx_data,
	input  rx_mask,
	input  rx_empty
);

  // === avs_ctrl ===========================================================

	wire [7:0]readdata_fifo;
	wire [7:0]status = { 7'b0000000, !rx_empty };
	wire send;

	assign send	= avs_ctrl_write && avs_ctrl_address && avs_ctrl_writedata[0];
	assign avs_ctrl_readdata = avs_ctrl_read ?
		(avs_ctrl_address ? status : readdata_fifo) : 0;

	// --- data register
	reg rx_upper;
	assign readdata_fifo = rx_upper ? rx_data[15:8] : rx_data[7:0];
	assign rx_read = avs_ctrl_read && !avs_ctrl_address && !rx_empty && (!rx_mask || rx_upper);
	
	always @(posedge clk or posedge reset)
	begin
		if (reset) rx_upper <= 0;
		else if (avs_ctrl_read && !avs_ctrl_address && !rx_empty)
			rx_upper <= !rx_upper && rx_mask;
	end


	// === asi_uplink =========================================================

	reg [15:0]tx_ldata;
	reg tx_lmask;
	reg tx_lower;

	wire tx_ena = valid & ready;
	wire [1:0]tx_empty = endofpacket ? empty : 2'b00;

	assign ready = !tx_lower && !tx_full;
	
	wire tx_mask_dat  = tx_lower ? tx_lmask : ~&tx_empty;
	wire tx_write_dat = (tx_ena || tx_lower) && ! tx_full;

	assign tx_data = tx_lower ?
		{tx_ldata[7:0], tx_ldata[15:8]} : {data[23:16], data[31:24]};
	assign tx_mask = send ? 2'b00 : {tx_mask_dat, 1'b1};
	assign tx_write = send || tx_write_dat;

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			tx_ldata <= 0;
			tx_lmask <= 0;
			tx_lower <= 0;
		end
		else if (tx_ena)
		begin
			tx_ldata <= data[15:0];
			tx_lmask <= ~|tx_empty;
			if (!tx_empty[1]) tx_lower <= 1;
		end
		else if (tx_lower && !tx_full) tx_lower <= 0;
	end


endmodule
