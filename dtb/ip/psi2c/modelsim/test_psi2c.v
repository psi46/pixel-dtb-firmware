// test_psi2c.v

`timescale 1 ns / 1 ps


module test_psi2c;
	// avalon clock interface
	reg clk = 0;
	reg reset = 1;
	
	// avalon mm slave
	reg   [2:0]address = 3'bxxx;
	reg        read = 0;
	wire [31:0]readdata;
	reg        write = 0;
	reg  [31:0]writedata = 32'hxxxx_xxxx;
	
	// conduit
	reg  sync = 0;
	wire phase;
	wire send;
	wire sda;
	wire rda = sda;

localparam s = 31'h0000_0800;  // i2c start
localparam p = 31'h0000_0400;  // i2c stop

task Write(input [2:0]a, input [31:0]d);
begin
  @(posedge clk) #1;
  address = a;
  writedata = d;
  write = 1;
  @(posedge clk) #1;
  address = 3'bxxx;
  writedata = 32'hxxxx_xxxx;
  write = 0;
end
endtask

task Read(input [2:0]a);
begin
  @(posedge clk) #1;
  address = a;
  read = 1;
  @(posedge clk) #1;
  address = 3'bxxx;
  read = 0;
end
endtask

always #10 clk = !clk;
always @(posedge clk) sync = !sync;
assign phase = !sync;


initial
begin
  #60 reset = 0;
  #200 Write(0, 0);
  Write(1, s + 'h2aa);
  Write(1,     'h2aa);
  Write(1, p + 'h2aa);
  Write(0, 1);
  #200 Read(0);
  #1150 Read(0);
  Write(3, 'h55);
  Write(2, 'hca);
  Write(4, 'h35);
  Write(0, 1);
  #1400 $stop(2);
end

psi2c DUT
(
	.csi_clock_clk(clk),
	.csi_clock_reset(reset),

	.avs_ctrl_address(address),
	.avs_ctrl_read(read),
	.avs_ctrl_readdata(readdata),
	.avs_ctrl_write(write),
	.avs_ctrl_writedata(writedata),
	
	.sync(sync),
	.phase(phase),
	.send(send),
	.sda(sda),
	.rda(rda)
);

endmodule
