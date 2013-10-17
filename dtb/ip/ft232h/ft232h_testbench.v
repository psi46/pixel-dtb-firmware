`timescale 1 ns / 1 ns


module ft232h_testbench;

	// simulated bus
	reg clk = 0;
	reg reset = 1;

	reg            avs_slave_address = 0;
	reg            avs_slave_write = 0;
	reg            avs_slave_read = 0;
	reg      [15:0]avs_slave_writedata = 32'h0080;
	wire     [15:0]avs_slave_readdata;
	wire           avs_slave_waitrequest;
	
	// simulated chip
	wire      [7:0]usb_data;
	reg            usb_rxf_n = 1;
	reg            usb_txe_n = 0;
	wire           usb_rd_n;
	wire           usb_wr_n;
	wire           usb_siwu_n;
	reg            usb_clk = 0;
	wire           usb_oe_n;

	reg  [7:0]rand_data  = 32;

	always #10 clk = !clk;
	always #8 usb_clk = !usb_clk;
	
	always @(posedge usb_clk)
	begin
		if(!usb_rd_n) #1 rand_data = rand_data + 1;
	end
	
	always @(posedge clk)
	begin
		if(avs_slave_write && !avs_slave_waitrequest) #1 avs_slave_writedata = avs_slave_writedata + 1;
	end
	
	assign usb_data = usb_oe_n ? 8'bz : rand_data;

	initial
	begin
		#1;
		#30   reset               <= 0;
		#1    usb_txe_n           <= 1;
		#100  avs_slave_write     <= 1;
		#1000 usb_txe_n           <= 0;
	end
	

	ft232h DUT (
		.clk(clk),
		.reset(reset),
		.avs_slave_address(avs_slave_address),
		.avs_slave_write(avs_slave_write),
		.avs_slave_read(avs_slave_read),
		.avs_slave_writedata(avs_slave_writedata),
		.avs_slave_readdata(avs_slave_readdata),
		.avs_slave_waitrequest(avs_slave_waitrequest),
		.usb_data(usb_data),
		.usb_rxf_n(usb_rxf_n),
		.usb_txe_n(usb_txe_n),
		.usb_rd_n(usb_rd_n),
		.usb_wr_n(usb_wr_n),
		.usb_siwu_n(usb_siwu_n),
		.usb_clk(usb_clk),
		.usb_oe_n(usb_oe_n)
	);


endmodule
