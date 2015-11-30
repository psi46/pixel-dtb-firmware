// deser400_control.v


`timescale 1 ps / 1 ps

module deser400_control
(
		// avalon clock interface
	input csi_clock_clk,
	input csi_clock_reset,
	
	// avalon mm slave: control
	input avs_ctrl_write,
	input avs_ctrl_read,
	input [3:0]avs_ctrl_address,
	input [31:0]avs_ctrl_writedata,
	output [31:0]avs_ctrl_readdata,

  // conduit
  output write,
  output read,
  output [3:0]address,
  output [31:0]writedata,
  input  [31:0]readdata
);

	assign write = avs_ctrl_write;
	assign read = avs_ctrl_read;
	assign address = avs_ctrl_address;
	assign writedata = avs_ctrl_writedata;
	assign avs_ctrl_readdata = readdata;

endmodule