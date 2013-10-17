`timescale 1 ps / 1 ps

module ft232h (

	// avalon-bus
	input clk,
	input reset,

	input          avs_slave_write,
	input          avs_slave_read,
	input     [7:0]avs_slave_writedata,
	output    [7:0]avs_slave_readdata,
	
	// ft232h
	inout  reg[7:0]usb_data,
	input          usb_rxf_n,
	input          usb_txe_n,
	output reg     usb_rd_n,
	output reg     usb_wr_n,
	output reg     usb_siwu_n,
	input          usb_clk,
	output reg     usb_oe_n,
	
	output reg     test

);

	//
	// regs / wires
	//
	reg  wrclock;
	wire wrfull;
	wire rdempty;

	//
	// init
	//
	assign usb_data = 8'bz;
	
	//
	// read
	//
	always @(posedge reset or negedge usb_clk)
	begin
		if(reset)
		begin
			usb_rd_n   <= 1;
			usb_wr_n   <= 1;
			usb_siwu_n <= 1;
			usb_oe_n   <= 1;
			wrclock    <= 0;
			test       <= 0;
		end
		else	// negedge clk
		begin
			if(usb_rxf_n)	// no data
			begin
				usb_oe_n <= 1;
				usb_rd_n <= 1;
			end
			else		// data available
			begin
				usb_oe_n <= 0;
				if(!usb_oe_n)
				begin
					usb_rd_n <= 0;
					wrclock  <= 1;
				end
			end
		end
	end
	
	always @(posedge usb_clk)
	begin
		wrclock <= 0;
	end
	
	//
	// read-fifo
	//
	lpm_fifo_dc read_fifo
	(
		.data(usb_data),
		.wrreq(!reset),
		.wrclock(wrclock),
		.wrfull(wrfull),
		.q(avs_slave_readdata),
		.rdreq(avs_slave_read),
		.rdclock(clk),
		.rdempty(rdempty),
		.aclr(reset)
	);
	defparam
		read_fifo.lpm_numwords = "256",
		read_fifo.lpm_showahead = "ON",
		read_fifo.lpm_width = "8";

endmodule