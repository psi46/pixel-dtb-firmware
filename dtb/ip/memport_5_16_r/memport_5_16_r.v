// memport_5_16_r.v

// add one read wait state
// use register memory mapping

module memport_5_16_r
(
   input clk,
   input reset,
   input   [4:0]slave_address,
   input        slave_read,
   output [15:0]slave_readdata,
   
   output [4:0]a,
   input  [15:0]d
);

   assign a = slave_address;
   assign slave_readdata = d;

endmodule
