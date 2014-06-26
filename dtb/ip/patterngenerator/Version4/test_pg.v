// test_pg.v

`timescale 1ns / 1ps


module test_pg;

reg clk     = 0;
reg sync    = 0;
reg reset   = 1;
reg trigger = 0;
wire [4:0]signal;
  
// avalon interface
reg write_data = 0;
reg write_ctrl = 0;
reg read_ctrl  = 0;

reg [7:0]address;
reg [31:0]writedata;
wire [31:0]readdata;
reg [1:0]byteenable = 2'b11;



task automatic pgwrite_data(input [7:0]a, input [15:0]d);
begin
  @(posedge clk)
  begin
    #5;
    write_data <= 1;
    write_ctrl <= 0;
    read_ctrl  <= 0;
    address    <= a;
    writedata  <= {16'd0, d};
  end
end
endtask


task automatic pgwrite_ctrl(input [7:0]a, input [31:0]d);
begin
  @(posedge clk)
  begin
    #5;
    write_data <= 0;
    write_ctrl <= 1;
    read_ctrl  <= 0;
    address    <= a;
    writedata  <= d;
  end
end
endtask


task automatic pgend();
begin
  @(posedge clk)
  begin
    #5;
    write_data <= 0;
    write_ctrl <= 0;
    read_ctrl  <= 0;
    address    <= 8'dx;
    writedata  <= 32'dx;
  end
end
endtask


always #10 clk <= ~clk;

integer n = 0;
always @(posedge clk)
begin
  n    <= n + 1;
  sync <= !sync;
end


initial
begin
  #25 reset = 0;
  #20;
  
  pgwrite_data(  0, { 5'b01000, 8'd1 } );
  pgwrite_data(  1, { 5'b00100, 8'd2 } );
  pgwrite_data(  2, { 5'b00010, 8'd3 } );
  pgwrite_data(  3, { 5'b10001, 8'd4 } );
  pgwrite_data(  4, { 5'b01111, 8'd1 } );
  pgwrite_data(  5, { 5'b00100, 8'd1 } );
  pgwrite_data(  6, { 5'b00010, 8'd5 } );
  pgwrite_data(  7, { 5'b00001, 8'd0 } );  // stop
  pgend();
  
  pgwrite_ctrl( 1, 40);  // period
  pgwrite_ctrl( 0, {24'd0, 8'b10000000}); // loop
  pgend();

  #160 trigger = 1;
  #40 trigger = 0;
  #80 pgwrite_ctrl(0, {24'd0, 8'b10000001}); // start
  pgend();
  
  @(negedge pg.running);
  #100 $stop(2);
end

patterngenerator pg
(
  .csi_clock_clk(clk),
  .csi_clock_reset(reset),

  .avs_ctrl_address(address[0]),
  .avs_ctrl_read(read_ctrl),
  .avs_ctrl_readdata(readdata),
  .avs_ctrl_write(write_ctrl),
  .avs_ctrl_writedata(writedata),

  .avs_data_address(address),
  .avs_data_write(write_data),
  .avs_data_byteenable(byteenable),
  .avs_data_writedata(writedata[15:0]),

  .clkena(sync),
  .trigger(trigger),
  .pgout(signal)
);

endmodule


