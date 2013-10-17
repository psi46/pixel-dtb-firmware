// adc.v


`timescale 1 ps / 1 ps

module adc
(
		input  wire        clk,           // clock.clk
		input  wire        reset,         // reset.reset

		input  wire [1:0]  address,       //  ctrl.address
		input  wire        write,         //      .write
		input  wire [15:0] writedata,     //      .writedata
		input  wire        read,          //      .read
		output wire [15:0] readdata,      //      .readdata

		output wire [1:0]  adc_address,   //   adc.export
		output wire        adc_write,     //      .export
		output wire [15:0] adc_writedata, //      .export
		output wire        adc_read,      //      .export
		input  wire [15:0] adc_readdata   //      .export
	);

	assign readdata = adc_readdata;

	assign adc_writedata = writedata;

	assign adc_address = address;

	assign adc_write = write;

	assign adc_read = read;

endmodule
