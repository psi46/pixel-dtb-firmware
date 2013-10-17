// register8.v


`timescale 1 ps / 1 ps

module register8
(
  input clock,
  input reset,

  // avalon slave
  input       avs_slave_address,
  input       avs_slave_write,
  input  [7:0]avs_slave_writedata,

  input       avs_slave_read,
  output [7:0]avs_slave_readdata
);

  reg [7:0]register1;
  reg [7:0]register2;

  always @(posedge clock or posedge reset)
  begin
    if (reset)
    begin
      register1 <= 0;
      register2 <= 0;
    end
    else if (avs_slave_write)
    begin
      if (avs_slave_address) register2 <= avs_slave_writedata;
      else                   register1 <= avs_slave_writedata;
    end
  end
  
	assign avs_slave_readdata = avs_slave_address ? register2 : register1;

endmodule
