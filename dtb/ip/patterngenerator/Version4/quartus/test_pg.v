// test_pg.v

`timescale 1ns / 1ps


module test_pg;

	reg csi_clock_clk = 0;
	reg csi_clock_reset = 1;

 	// avalon mm slave: status/control
	reg        avs_ctrl_address = 1'bx;
	reg        avs_ctrl_read = 1'b0;
	wire [31:0]avs_ctrl_readdata;
	reg        avs_ctrl_write = 1'b0;
	reg  [31:0]avs_ctrl_writedata = 32'hxxxxxxxx;

 	// avalon mm slave: command memory
	reg   [7:0]avs_data_address = 8'hxx;
	reg        avs_data_read = 0;
	wire [15:0]avs_data_readdata;
	reg        avs_data_write = 1'b0;
	reg   [1:0]avs_data_byteenable = 2'b11;
	reg  [15:0]avs_data_writedata = 16'hxxxx;

	// pattern generator interface
 	reg clk     = 0;
	reg clkena  = 0;
	reg trigger = 0;
	wire [3:0]signal;


task write_ctrl(input address, input [31:0]data);
begin
	@(posedge clk) #1;
	avs_ctrl_address   <= address;
	avs_ctrl_writedata <= data;
	avs_ctrl_write     <= 1;
	@(posedge clk) #1;
	avs_ctrl_address   <= 1'bx;
	avs_ctrl_writedata <= 32'hxxxxxxxx;
	avs_ctrl_write     <= 0;
end
endtask

task write_mem(input [7:0]address, input [31:0]data);
begin
	@(posedge clk) #1;
	avs_data_address   <= address;
	avs_data_writedata <= data;
	avs_data_write     <= 1;
	@(posedge clk) #1;
	avs_data_address   <= 1'bx;
	avs_data_writedata <= 32'hxxxxxxxx;
	avs_data_write     <= 0;
end
endtask

task set_trigger(input [15:0]delay);
  integer i;
  begin
    i = delay;
    while (i) @(posedge clk) if (clkena) i=i-1;
    #1 trigger <= 1;
    
    @(posedge clk);
    while (!clkena) @(posedge clk);
    #1 trigger <= 0;
  end
endtask


always #10 clk <= ~clk;
always #10 csi_clock_clk <= ~csi_clock_clk;

integer n = 0;
always @(posedge clk)
begin
  n    <= n + 1;
  clkena <= !clkena;
end


initial
begin
  #50 csi_clock_reset = 0;
  #20;
  
  write_mem(  0, { 4'b1000, 8'd1 } );
  write_mem(  1, { 4'b0100, 8'd2 } );
  write_mem(  2, { 4'b0010, 8'd3 } );
  write_mem(  3, { 4'b0001, 8'd4 } );
  write_mem(  4, { 4'b1111, 8'd1 } );
  write_mem(  5, { 4'b0100, 8'd1 } );
  write_mem(  6, { 4'b0010, 8'd5 } );
  write_mem(  7, { 4'b0001, 8'd0 } );  // stop

	write_ctrl( 1, 50 );
	write_ctrl( 0, 'b1000_0100 );

//	set_trigger(5);
//	#200 write_ctrl(0, 'b0000_0010 );
  
  @(negedge pg.running);
  #100 $stop(2);
end

patterngenerator pg
(
  .csi_clock_clk(clk),
  .csi_clock_reset(csi_clock_reset),

 	// avalon mm slave: status/control
	.avs_ctrl_address(avs_ctrl_address),
	.avs_ctrl_read(avs_ctrl_read),
	.avs_ctrl_readdata(avs_ctrl_readdata),
	.avs_ctrl_write(avs_ctrl_write),
	.avs_ctrl_writedata(avs_ctrl_writedata),

 	// avalon mm slave: command memory
	.avs_data_address(avs_data_address),
	.avs_data_read(avs_data_read),
	.avs_data_readdata(avs_data_readdata),
	.avs_data_write(avs_data_write),
	.avs_data_byteenable(avs_data_byteenable),
	.avs_data_writedata(avs_data_writedata),

	// pattern generator interface
 	.clk(clk),
	.clkena(clkena),
	.trigger(trigger),
	.signal(signal)
);

endmodule


