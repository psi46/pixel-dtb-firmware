// test_data_dma.v

`timescale 1ns / 1ps


module test_data_dma;

	// avalon clock interface
	reg clk = 0;
	reg reset = 1;
	
	// avalon mm slave: control port
	reg   [1:0]avs_ctrl_address = 2'bxx;
	reg        avs_ctrl_write = 0;
	reg  [31:0]avs_ctrl_writedata = 32'hxxxx_xxxx;
	reg        avs_ctrl_read = 0;
	wire [31:0]avs_ctrl_readdata;

	// avalon mm master: DMA data write port
	wire [31:0]avm_data_address;
	wire       avm_data_write;
	wire [15:0]avm_data_writedata;
	reg        avm_data_waitrequest;
	wire  [1:0]avm_data_byteenable;

	// avalon conduit: external data source
	reg write;
	wire waitrq;
	reg [15:0]data;

	always #10 clk = !clk;
	initial #25 reset = 0;

	// --- data generator -----------------------------------------------------
	integer dg_cnt = 0;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			data  <= 100;
			write <= 0;
		end
		else
		begin
			write <= (dg_cnt % 10) > 2;
			dg_cnt = dg_cnt + 1;
			if (write & !waitrq) data <= data + 1;
		end
	end

  
  // --- ram ----------------------------------------------------------------
  integer ram_cnt = 0;
  
  always @(posedge clk)
  begin
    ram_cnt = ram_cnt + 1;
  	avm_data_waitrequest <= (ram_cnt % 13) >= 11;
  end

  // --- DMA programming ----------------------------------------------------

  task WriteCtrl(input [1:0]register, input [31:0]data);
    begin
      @(posedge clk);
      avs_ctrl_write     <= 1;
      avs_ctrl_address   <= register;
      avs_ctrl_writedata <= data;
      @(posedge clk)
      avs_ctrl_write     <= 0;
      avs_ctrl_address   <= 2'bxx;
      avs_ctrl_writedata <= 32'hxxxx_xxxx;
    end
  endtask

  initial
  begin
    #160;
    WriteCtrl(0, 32'h0100_0000);
    WriteCtrl(1, 100);
    WriteCtrl(2, 1);
  
    #2000 $stop(2);
  end

	data_dma DUT
	(
		.csi_clock_clk(clk),
		.csi_clock_reset(reset),
	
		// avalon mm slave: control port
		.avs_ctrl_address(avs_ctrl_address),
		.avs_ctrl_write(avs_ctrl_write),
		.avs_ctrl_writedata(avs_ctrl_writedata),
		.avs_ctrl_read(avs_ctrl_read),
		.avs_ctrl_readdata(avs_ctrl_readdata),

		// avalon mm master: DMA data write port
		.avm_data_address(avm_data_address),
		.avm_data_write(avm_data_write),
		.avm_data_writedata(avm_data_writedata),
		.avm_data_waitrequest(avm_data_waitrequest),
		.avm_data_byteenable(avm_data_byteenable),

		// avalon conduit: external data source
		.write(write),
		.waitrq(waitrq),
		.data(data)
	);

endmodule
