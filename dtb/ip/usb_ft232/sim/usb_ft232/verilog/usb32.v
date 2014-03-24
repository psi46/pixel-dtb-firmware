// usb.h

`timescale 1 ns / 1 ps


module usb32
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
	output asi_uplink_ready,
	input asi_uplink_valid,
	input [31:0]asi_uplink_data,
	input asi_uplink_startofpacket,
	input asi_uplink_endofpacket,
	input [1:0]asi_uplink_empty,
	
	// ft232 interface
	input usb_clk,
	output wr_n,
	output rd_n,
	output oe_n,
	inout  [7:0]data,
	input  txe_n,
	input  rxf_n,
	output siwu_n
);

wire tx_write;
wire [15:0]tx_dout;
wire [1:0]tx_min;
wire tx_full;
wire tx_read;
wire [15:0]tx_data;
wire [1:0]tx_mask;
wire empty;
wire tx_ready = !empty;

wire rx_read;
wire [15:0]rx_din;
wire rx_mout;
wire rx_empty;
wire rx_write;
wire [15:0]rx_data;
wire rx_mask;
wire full;
wire rx_ready = !full;


usb_avalon_32bit port
(
	.clk(clk),
	.reset(reset),

	// avs_ctrl
	.avs_ctrl_address(avs_ctrl_address),
	.avs_ctrl_write(avs_ctrl_write),
	.avs_ctrl_writedata(avs_ctrl_writedata),
	.avs_ctrl_read(avs_ctrl_read),
	.avs_ctrl_readdata(avs_ctrl_readdata),

	// asi_uplink
	.ready(asi_uplink_ready),
	.valid(asi_uplink_valid),
	.data(asi_uplink_data),
	.startofpacket(asi_uplink_startofpacket),
	.endofpacket(asi_uplink_endofpacket),
	.empty(asi_uplink_empty),
	
	// tx fifo interface
	.tx_write(tx_write),
	.tx_data(tx_dout),
	.tx_mask(tx_min),
	.tx_full(tx_full),

	// rx fifo interface
	.rx_read(rx_read),
	.rx_data(rx_din),
	.rx_mask(rx_mout),
	.rx_empty(rx_empty)
);


usb_ft232 ft232
(
	.clk(usb_clk),
	.reset(reset),

	// FT232 interface
	.wr_n(wr_n),
	.rd_n(rd_n),
	.oe_n(oe_n),
	.data(data),
	.txe_n(txe_n),
	.rxf_n(rxf_n),
	.siwu_n(siwu_n),
	
	// tx fifo interface
	.tx_read(tx_read),
	.tx_data(tx_data),
	.tx_mask(tx_mask),
	.tx_ready(tx_ready),

	// rx fifo interface
	.rx_write(rx_write),
	.rx_data(rx_data),
	.rx_mask(rx_mask),
	.rx_ready(rx_ready)
);


usb_tx_fifo tx_fifo
(
	.reset(reset),

	.wrclk(clk),
	.write(tx_write),
	.din(tx_dout),
	.min(tx_min),
	.full(tx_full),

	.rdclk(usb_clk),
	.read(tx_read),
	.dout(tx_data),
	.mout(tx_mask),
	.empty(empty)
);


usb_rx_fifo rx_fifo
(
	.reset(reset),

	.wrclk(usb_clk),
	.write(rx_write),
	.din(rx_data),
	.min(rx_mask),
	.full(full),

	.rdclk(clk),
	.read(rx_read),
	.dout(rx_din),
	.mout(rx_mout),
	.empty(rx_empty)
);

endmodule
