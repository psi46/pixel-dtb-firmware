// test_usb_ft232.v

`timescale 1 ns / 1 ps


module test_usb_ft232;
	reg clk = 0;
	reg reset = 1;

	// FT232 interface
	wire wr_n;
	wire rd_n;
	wire oe_n;
	wire  [7:0]data;
	reg  txe_n = 1;
	reg  rxf_n = 1;
	wire siwu_n;
	
	// tx fifo interface
	wire tx_read;
	reg  [15:0]tx_data = 16'hxx01;
	reg  [1:0]tx_mask  = 2'b01;
	reg  tx_ready = 0;

	// rx fifo interface
	wire rx_write;
	wire [15:0]rx_data;
	wire [1:0]rx_mask;
	reg  rx_ready = 0;

	// clk
	always #8 clk = !clk;
	initial
	begin
    #10 reset = 0;
    @(posedge clk);
    @(posedge clk);
    txe_n = 0;
    tx_ready = 1;
  end
	
  // === ft232 ============================================
  reg [3:0]tx_ftcnt = 0;
  always @(posedge clk)
  begin
    txe_n    <= tx_ftcnt < 3;
    tx_ftcnt <= tx_ftcnt + 1;
  end

	reg [7:0]rx_ftdata = 8'h80;
	always @(posedge clk)
	begin
		if (!rd_n) rx_ftdata = rx_ftdata + 1;
	end
	
	initial
	begin
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		rxf_n = 0;
		rx_ready = 1;
	end
	
	assign data = oe_n ? 8'hzz : rx_ftdata;

  
	// === rxfifo ===========================================
	reg [7:0]datagen = 2;
	reg [3:0]txmode = 0;
	always @(posedge clk)
	begin
		if (tx_read)
		begin
		  txmode <= {$random} % 16;
		  if (txmode < 5)
		  begin // empty
		    tx_data <= 16'hxxxx;
		    tx_mask <= 2'bxx;
		    tx_ready <= 0;
		    @(posedge clk);
		    @(posedge clk);
		    tx_ready <= 1;
        tx_mask <= 2'b11;
        tx_data <= {datagen+1, datagen};
        datagen <= datagen + 2;
		  end
		  else if (txmode < 6)
		  begin // send
        tx_mask <= 2'b00;
        tx_data <= 16'hxxxx;
      end
		  else if (txmode < 13)
		  begin // 2 bytes
        tx_mask <= 2'b11;
        tx_data <= {datagen+1, datagen};
        datagen <= datagen + 2;
      end
		  else
		  begin // 1 byte
        tx_mask <= 2'b01;
        tx_data <= {8'hxx, datagen};
        datagen <= datagen + 1;
      end
		end
	end

  // tx error check
  event tx_error;
  reg [7:0]datavalue = 1;
  always @(posedge clk)
  begin
    if (!wr_n)
    begin
      if (data == datavalue); else -> tx_error;
      datavalue = datavalue + 1;
    end
  end
  

	usb_ft232 DUT
	(
		.clk(clk),
		.reset(reset),
		.wr_n(wr_n),
		.rd_n(rd_n),
		.oe_n(oe_n),
		.data(data),
		.txe_n(txe_n),
		.rxf_n(rxf_n),
		.siwu_n(siwu_n),
		.tx_read(tx_read),
		.tx_data(tx_data),
		.tx_mask(tx_mask),
		.tx_ready(tx_ready),
		.rx_write(rx_write),
		.rx_data(rx_data),
		.rx_mask(rx_mask),
		.rx_ready(rx_ready)
	);

endmodule
