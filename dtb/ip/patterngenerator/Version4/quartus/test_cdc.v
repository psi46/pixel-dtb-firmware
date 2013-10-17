// test_cdc.v
// test of clock domain crossing logic

`timescale 1ns / 1ps


module test_cdc;
 	reg clk1    = 0;
	reg clk2    = 0;
	reg clk2ena = 0;
	reg reset   = 1;
	
	reg in      = 0;
	wire out_p;
	wire out_s;

task set(input [15:0]delay, input value);
  integer i;
  begin
    for (i=0; i<delay; i=i+1) @(posedge clk1);
    #1 in <= value;
  end
endtask

always #20 clk1 <= ~clk1;
always #10.51 clk2 <= ~clk2;

integer n = 0;
always @(posedge clk2) n = n + 1;

always @(posedge clk2)
begin
  if (n & 1) clk2ena <= 1;
  @(posedge clk2) clk2ena <= 0;
end

integer i;

initial
begin
  #20 reset = 0;
  for (i=0; i<30; i=i+1)
  begin
    set( 40, 1);  set(1,0);
  end

  #200 $stop(2);
end

cdc_state DUTS
(
	.clk1(clk1),
	.clk2(clk2),
	.clk2ena(clk2ena),
	.reset(reset),
	.in(in),
	.out(out_s)
);

cdc_pulse DUTP
(
	.clk1(clk1),
	.clk2(clk2),
	.clk2ena(clk2ena),
	.reset(reset),
	.in(in),
	.out(out_p)
);

endmodule
