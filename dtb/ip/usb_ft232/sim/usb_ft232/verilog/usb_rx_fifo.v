// usb_rx_fifo.v

`timescale 1 ns / 1 ps


module usb_rx_fifo
(
	input reset,

	input wrclk,
	input write,
	input [15:0]din,
	input min,
	output full,

	input rdclk,
	input read,
	output [15:0]dout,
	output mout,
	output empty
);

	wire [16:0]data = { min, din };
	wire [16:0]q;
	assign { mout, dout } = q;

	dcfifo	dcfifo_component
	(
		.rdclk (rdclk),
		.wrclk (wrclk),
		.wrreq (write),
		.aclr (reset),
		.data (data),
		.rdreq (read),
		.wrfull (full),
		.q (q),
		.rdempty (empty),
		.rdfull (),
		.rdusedw (),
		.wrempty (),
		.wrusedw ()
	);
	defparam
		dcfifo_component.intended_device_family = "Cyclone III",
		dcfifo_component.lpm_numwords = 512,
		dcfifo_component.lpm_showahead = "ON",
		dcfifo_component.lpm_type = "dcfifo",
		dcfifo_component.lpm_width = 17,
		dcfifo_component.lpm_widthu = 9,
		dcfifo_component.overflow_checking = "OFF",
		dcfifo_component.rdsync_delaypipe = 4,
		dcfifo_component.read_aclr_synch = "OFF",
		dcfifo_component.underflow_checking = "OFF",
		dcfifo_component.use_eab = "ON",
		dcfifo_component.write_aclr_synch = "OFF",
		dcfifo_component.wrsync_delaypipe = 4;


endmodule


// Retrieval info: LIB_FILE: altera_mf
