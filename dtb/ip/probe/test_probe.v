// test_probe.v

`timescale 1 ns / 1 ps

module test_probe;

	reg clk = 0;
	reg reset = 1;

	reg [1:0]select = 0;

	reg avs_ctrl_write = 0;
	reg [7:0]avs_ctrl_writedata = 8'hxx;
		
	reg [30:0]sig_in = 0;
	wire sig_out;

  always #5 clk = !clk;
  
  always @(posedge clk) sig_in <= sig_in + 1;
  
  initial
  begin
    #12 reset = 0;
    
    @(posedge clk);
    @(posedge clk)
    begin
      avs_ctrl_write <= 1;
      avs_ctrl_writedata <= 1;
    end
    @(posedge clk)
    begin
      avs_ctrl_write <= 0;
      avs_ctrl_writedata <= 8'hxx;
    end

    #120;
    @(posedge clk)
    begin
      avs_ctrl_write <= 1;
      avs_ctrl_writedata <= 2;
    end
    @(posedge clk)
    begin
      avs_ctrl_write <= 0;
      avs_ctrl_writedata <= 8'hxx;
    end

    #200 $stop(2);
  end

  probe DUT
  (
    .csi_clock_clk(clk),
    .csi_clock_reset(reset),

    .avs_ctrl_write(avs_ctrl_write),
    .avs_ctrl_writedata(avs_ctrl_writedata),
		 
		 .sig_in(sig_in),
		 .sig_out(sig_out)
	);
	
endmodule
