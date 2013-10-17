// registerfile_io32.v

// This file was auto-generated as a prototype implementation of a module
// created in component editor.  It ties off all outputs to ground and
// ignores all inputs.  It needs to be edited to make it do something
// useful.
// 
// This file will not be automatically regenerated.  You should check it in
// to your version control system if you want to keep it.

`timescale 1 ps / 1 ps
module registerfile_io16 (
		input  wire        clk,             // clock.clk
		input  wire        slave_read,      // slave.read
		input  wire        slave_write,     //      .write
		input  wire  [5:0]slave_address,    //      .address
		output wire [15:0] slave_readdata,  //      .readdata
		input  wire [15:0] slave_writedata, //      .writedata
		input  wire        reset,           // reset.reset
		
		output       atb_read,
		output       atb_write,
		output  [5:0]atb_register,
		input  [15:0]atb_readdata,
		output [15:0]atb_writedata
	);

  assign atb_read  = slave_read;
  assign atb_write = slave_write;
  assign atb_register   = slave_address;
  assign atb_writedata  = slave_writedata;
	assign slave_readdata = atb_readdata;

endmodule
