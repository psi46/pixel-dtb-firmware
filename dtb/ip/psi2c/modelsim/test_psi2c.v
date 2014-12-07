// test_psi2c.v

`timescale 1 ns / 1 ps


module tbm_hub
(
  input scl,
  input sda,
  output rda
);
  reg [4:0]hub     = 20;
  reg [2:0]port    = 1;
  reg tbm_rw       = 0;
  reg [6:0]tbm_reg = 7'h12;
  reg [7:0]tbm_dat = 8'h5a;

  reg gate = 0;
  reg [5:0]count = 0;
  
  always @(negedge sda) if (scl) gate <= 1;
  always @(posedge sda) if (scl) gate <= 0;
  
  always @(posedge scl)
  begin
    if (gate) count <= count + 1;
    else count <= 0;
  end
  
  reg rd = 1;
  reg data = 1;
  always @(posedge scl) if (count == 6'd9)
  begin
    // start
    @(posedge scl) rd <= 0;
    // data
    @(negedge scl) rd <=  tbm_reg[6];
    @(negedge scl) rd <=  tbm_reg[5];
    @(negedge scl) rd <=  tbm_reg[4];
    @(negedge scl) rd <=  tbm_reg[3];
    @(negedge scl) rd <= !tbm_reg[3];
    @(negedge scl) rd <=  tbm_reg[2];
    @(negedge scl) rd <=  tbm_reg[1];
    @(negedge scl) rd <=  tbm_reg[0];
    @(negedge scl) rd <=  tbm_rw;
    @(negedge scl) rd <= !tbm_rw;
    @(negedge scl) rd <=  tbm_dat[7];
    @(negedge scl) rd <=  tbm_dat[6];
    @(negedge scl) rd <=  tbm_dat[5];
    @(negedge scl) rd <=  tbm_dat[4];
    @(negedge scl) rd <= !tbm_dat[4];
    @(negedge scl) rd <=  tbm_dat[3];
    @(negedge scl) rd <=  tbm_dat[2];
    @(negedge scl) rd <=  tbm_dat[1];
    @(negedge scl) rd <=  tbm_dat[0];
    @(negedge scl) rd <= !tbm_dat[0];
    // repeated start
    @(negedge scl) rd <= 0;
    @(posedge scl) rd <= 1;
    // hub & port
    @(negedge scl) rd <= hub[4];
    @(negedge scl) rd <= hub[3];
    @(negedge scl) rd <= hub[2];
    @(negedge scl) rd <= hub[1];
    @(negedge scl) rd <= hub[0];
    @(negedge scl) rd <= port[2];
    @(negedge scl) rd <= port[1];
    @(negedge scl) rd <= port[0];
    @(negedge scl) rd <= 1;
  end

  assign #10 rda = rd;
endmodule


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
	reg rda;

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
  #200; // Write(0, 0);
  Write(3, s + 'h2ab);
  Write(3,     'h2aa);
  Write(4, p + 'h2aa);
  Write(0, 3);
  #200 Read(0);
  #1150 Read(0);
  #600 Read(1);
  #100 $stop(2);
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

reg scl = 0;
always @(phase)
begin
  #8 scl <= phase;
end


wire rda_tbm;

tbm_hub t
(
  .scl(scl),
  .sda(sda),
  .rda(rda_tbm)
);

always @(posedge clk) rda <= rda_tbm;

endmodule
