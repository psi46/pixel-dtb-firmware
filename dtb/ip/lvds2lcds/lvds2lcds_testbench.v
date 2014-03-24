`timescale 1 ns / 1 ns


module lvds2lcds_testbench;

	// simulated bus
	reg clk = 0;
	reg reset = 1;

	reg            avs_slave_write = 0;
	reg            avs_slave_read = 0;
	reg       [7:0]avs_slave_writedata = 0;
	wire      [7:0]avs_slave_readdata;
	
	// simulated chip
	wire           reset_n;
	wire           scl;
	wire           sdi;
	wire           sld;



	always #10 clk = !clk;
	

	initial
	begin
		#1    reset               <= 0;
		#120  avs_slave_writedata <= 8'b01001010;
		#10   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
	end
	

	lvds2lcds DUT (
		.clk(clk),
		.reset(reset),
		.avs_slave_write(avs_slave_write),
		.avs_slave_read(avs_slave_read),
		.avs_slave_writedata(avs_slave_writedata),
		.avs_slave_readdata(avs_slave_readdata),
		.reset_n(reset_n),
		.scl(scl),
		.sdi(sdi),
		.sld(sld)
	);


endmodule
