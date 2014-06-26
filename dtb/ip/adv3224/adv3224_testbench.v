`timescale 1 ns / 1 ns


module adv3224_testbench;

	// simulated bus
	reg clk = 0;
	reg reset = 1;

	reg       [2:0]avs_slave_address = 0;
	reg            avs_slave_write = 0;
	reg            avs_slave_read = 0;
	reg       [7:0]avs_slave_writedata = 0;
	wire      [7:0]avs_slave_readdata;
	
	// simulated chip
	wire           cps_reset_n;
	wire           cps_ce_n;
	wire           cps_update_n;
	wire           cps_clk;
	wire           cps_datain;




	always #10 clk = !clk;
	

	initial
	begin
		#1    reset               <= 0;
		
		#100  avs_slave_address   <= 3;
		      avs_slave_writedata <= 8'b00010000;
		#20   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
		
		      avs_slave_address   <= 7;
		      avs_slave_writedata <= 8'b00000011;
		#20   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
		
		      avs_slave_address   <= 0;
		      avs_slave_writedata <= 8'b00000100;
		#20   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
		
		      avs_slave_address   <= 1;
		      avs_slave_writedata <= 8'b00001100;
		#20   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
		
		      avs_slave_address   <= 4;
		      avs_slave_writedata <= 8'b00001111;
		#20   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
		
		      avs_slave_address   <= 6;
		      avs_slave_writedata <= 8'b00000000;
		#20   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
		
		      avs_slave_address   <= 5;
		      avs_slave_writedata <= 8'b00010000;
		#20   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;

		      avs_slave_address   <= 2;
		      avs_slave_writedata <= 8'b00000001;
		#20   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
		
		      avs_slave_writedata <= 8'b10000000;
		#20   avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
		
		#5000 avs_slave_write     <= 1;
		#20   avs_slave_write     <= 0;
		
		 
	end
	

	adv3224 DUT (
		.clk(clk),
		.reset(reset),
		.avs_slave_write(avs_slave_write),
		.avs_slave_read(avs_slave_read),
		.avs_slave_writedata(avs_slave_writedata),
		.avs_slave_readdata(avs_slave_readdata),
		.avs_slave_address(avs_slave_address),
		.cps_reset_n(cps_reset_n),
		.cps_ce_n(cps_ce_n),
		.cps_update_n(cps_update_n),
		.cps_clk(cps_clk),
		.cps_datain(cps_datain)
	);


endmodule
