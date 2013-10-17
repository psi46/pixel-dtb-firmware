// fifo_data.v

// synthesis translate_off
`timescale 1ns / 100ps
// synthesis translate_on

module fifo_data
(
	input clk,
	input reset,

	// avalon slave
	input        slave_read,
	output [15:0]slave_readdata,

	// external signals
	input       fifo_empty,
	output      fifo_read,
	input [14:0]fifo_data
);

	assign slave_readdata = { fifo_empty, fifo_data };
	assign fifo_read = slave_read && !fifo_empty;

endmodule
