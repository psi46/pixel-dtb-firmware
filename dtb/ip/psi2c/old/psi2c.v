// i2c_hs_interface.v

// This file was auto-generated as a prototype implementation of a module
// created in component editor.  It ties off all outputs to ground and
// ignores all inputs.  It needs to be edited to make it do something
// useful.
// 
// This file will not be automatically regenerated.  You should check it in
// to your version control system if you want to keep it.

`timescale 1 ps / 1 ps

module i2c_hs_interface (
		input  wire        clk,              //  clock.clk
		input  wire [2:0]  slave_address,    //  slave.address
		output wire [31:0] slave_readdata,   //       .readdata
		input  wire        slave_read,       //       .read
		input  wire        slave_write,      //       .write
		input  wire [31:0] slave_writedata,  //       .writedata
		input  wire        reset,            //  reset.reset
		output wire        i2c_hs_read,      // i2c_hs.export
		output wire        i2c_hs_write,     //       .export
		output wire [2:0]  i2c_hs_addr,      //       .export
		input  wire [31:0] i2c_hs_readdata,  //       .export
		output wire [31:0] i2c_hs_writedata  //       .export
	);

	assign slave_readdata = i2c_hs_readdata;
	assign i2c_hs_writedata = slave_writedata;
	assign i2c_hs_write = slave_write;
	assign i2c_hs_read = slave_read;
	assign i2c_hs_addr = slave_address;

endmodule
