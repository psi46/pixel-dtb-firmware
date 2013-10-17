// i2c master
// whisbone to avalon mapping

// synopsys translate_off
`timescale 1ns / 100ps
// synopsys translate_on


module i2c_master
(
  input clk,
  input reset,
 
  // avalon mm slave
  input  [2:0] slave_address,
  input  [7:0] slave_writedata,
  output [7:0] slave_readdata,
  input        slave_select,
  input        slave_write,
  output       slave_int,

	// I2C signals
  inout scl,
  inout sda
);

	wire scl_padoen_o;   // SCL-line output enable (active low)
	wire sda_padoen_o;   // SDA-line output enable (active low)

  wire rst = 0;

  assign scl = scl_padoen_o ? 1'bz : 1'b0;
  assign sda = sda_padoen_o ? 1'bz : 1'b0;

  i2c_master_top i2c
  (
   	.wb_clk_i(clk),              // master clock input
   	.wb_rst_i(rst),              // synchronous active high reset
   	.arst_i(reset),              // asynchronous reset
   	.wb_adr_i(slave_address),    // lower address bits
   	.wb_dat_i(slave_writedata),  // databus input
  	 .wb_dat_o(slave_readdata),   // databus output
   	.wb_we_i(slave_write),       // write enable input
   	.wb_stb_i(slave_select),     // stobe/core select signal
     // .wb_ack_o(),             // bus cycle acknowledge output
    .wb_inta_o(slave_int),       // interrupt request signal output

   	// i2c clock line
   	.scl_pad_i(scl),             // SCL-line input
   	// .scl_pad_o(),             // SCL-line output (always 1'b0)
  	 .scl_padoen_o(scl_padoen_o), // SCL-line output enable (active low)

   	// i2c data line
   	.sda_pad_i(sda),             // SDA-line input
   	// .sda_pad_o(),             // SDA-line output (always 1'b0)
  	 .sda_padoen_o(sda_padoen_o)  // SDA-line output enable (active low)
  );
endmodule
