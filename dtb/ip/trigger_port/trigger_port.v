// trigger_port.v


`timescale 1 ps / 1 ps

module trigger_port
(
  input clock,
  input reset,

  // avalon slave
  input   [3:0]avs_slave_address,
  input        avs_slave_write,
  input  [31:0]avs_slave_writedata,
  
  // conduit
  output [36:0]trg_ctrl_out
);

	assign trg_ctrl_out = {avs_slave_write, avs_slave_address, avs_slave_writedata};

endmodule
