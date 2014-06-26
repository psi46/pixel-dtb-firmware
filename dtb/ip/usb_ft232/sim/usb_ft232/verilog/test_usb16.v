// test_usb_ft232.v

`timescale 1 ns / 1 ps


module test_usb16;
	reg clk = 0;
	reg reset = 1;

	// FT232 interface
	reg usb_clk = 0;
	wire wr_n;
	wire rd_n;
	wire oe_n;
	wire  [7:0]data;
	reg  txe_n = 1;
	reg  rxf_n = 1;
	wire siwu_n;
	
	// avs_ctrl
	reg avs_ctrl_address = 1'bx;
	reg avs_ctrl_write = 0;
	reg [7:0]avs_ctrl_writedata = 8'hxx;
	reg avs_ctrl_read = 0;
	wire [7:0]avs_ctrl_readdata;
	
	// asi_uplink
	wire asi_uplink_ready;
	reg asi_uplink_valid = 0;
	reg [15:0]asi_uplink_data = 16'hxxxx;
	reg asi_uplink_startofpacket = 0;
	reg asi_uplink_endofpacket = 0;
	reg asi_uplink_empty = 1'bx;

	// --- clk
	always #10 clk = !clk;
	initial #15 reset = 0;

	task waitclk(input integer n);
	begin
		repeat (n) @(posedge clk);
	end
	endtask

	task waitusbclk(input integer n);
	begin
		repeat (n) @(posedge usb_clk);
	end
	endtask


  // === ft232 ==============================================================
  
  // --- transmitter
  always #8.333 usb_clk = !usb_clk;
  
  reg [3:0]ft_cnt = 0;
  always @(posedge usb_clk)
  begin
    txe_n  <= ft_cnt < 3;
    ft_cnt <= ft_cnt + 1;
  end

	// -- receiver
	reg [7:0]ft_data = 0;
	reg [2:0]ft_wait = 0;
	
	initial
	begin
		waitusbclk(5);
		forever	@(posedge usb_clk)
		begin
			rxf_n <= ft_wait < 2;
			ft_wait <= ft_wait + 1;
		end
	end
	
	always @(posedge usb_clk) if (!rxf_n && !rd_n) ft_data = ft_data + 1;
	assign data = oe_n ? 8'hzz : (rd_n ? 8'hxx : ft_data);

	// log write access to ft232, log read access from ft232
	reg [7:0]ft232_write;
	reg [7:0]ft232_read;
	
	always @(negedge usb_clk)
	begin
		ft232_write <= wr_n ? 8'hzz : (txe_n ? 8'hxx : data);
		ft232_read  <= rd_n ? 8'hzz : (rxf_n ? 8'hxx : data);
	end


	// === avs_ctrl ===========================================================

	task avsWrite(input [7:0]value, input address);
	begin
		waitclk(1);
		avs_ctrl_write <= 1;
		avs_ctrl_address <= 1;
		avs_ctrl_writedata <= value;
		waitclk(1);
		avs_ctrl_write <= 0;
		avs_ctrl_address <= 1'bx;
		avs_ctrl_writedata <= 8'hxx;		
	end
	endtask

	task avsRead(output [7:0]value, input address);  
	begin
		waitclk(1);
		avs_ctrl_read <= 1;
		avs_ctrl_address <= address;

		@(negedge clk);
		value <= avs_ctrl_readdata;
	
		waitclk(1);
		avs_ctrl_read <= 0;
		avs_ctrl_address <= 1'bx;
	end
	endtask

	reg [7:0]ret;
	reg [7:0]rxdata;

	initial
	begin
		waitclk(5);
		avsRead(ret, 1);
		avsRead(ret, 1);

		avsWrite(8'hfe, 1);
		
		forever
		begin
			avsRead(ret, 1);
			if (ret) avsRead(rxdata,0);
		end
	end

	// log read/write from/to avs ctrl
	reg [7:0]avs_read_0;
	reg [7:0]avs_read_1;
	reg [7:0]avs_write_0;
	reg [7:0]avs_write_1;
	
	always @(negedge clk)
	begin
		avs_read_0  <= (avs_ctrl_read  && !avs_ctrl_address) ? avs_ctrl_readdata  : 8'hzz;
		avs_read_1  <= (avs_ctrl_read  &&  avs_ctrl_address) ? avs_ctrl_readdata  : 8'hzz;
		avs_write_0 <= (avs_ctrl_write && !avs_ctrl_address) ? avs_ctrl_writedata : 8'hzz;
		avs_write_1 <= (avs_ctrl_write &&  avs_ctrl_address) ? avs_ctrl_writedata : 8'hzz;
	end
	
	
	// === asi_uplink =========================================================
	
	task asi_burst_data(input [7:0]value, input integer size);
	begin
		case (size)
			0:
				begin
					asi_uplink_data  <= 16'hxxxx;
					asi_uplink_empty <= 1'bx;
				end
			1:
				begin
					asi_uplink_data <= {value, 8'hxx};
					asi_uplink_empty <= 1;
				end
			default
				begin
					asi_uplink_data <= {value, value+8'h1};
					asi_uplink_empty <= 0;
				end
		endcase
	end
	endtask
	

	task asi_burst(input [7:0]startvalue, input integer length);
	begin
		waitclk(1);
		asi_uplink_startofpacket <= 1;
		asi_uplink_valid <= 1;
		while (length > 0)
		begin
			asi_burst_data(startvalue, length);
			if (length <= 1) asi_uplink_endofpacket <= 1;
			startvalue = startvalue + 2;
			length = length - 2;
			waitclk(1);
			asi_uplink_startofpacket <= 0;
			while (!asi_uplink_ready) waitclk(1);
		end
		asi_uplink_startofpacket <= 0;
		asi_uplink_endofpacket   <= 0;
		asi_uplink_valid <= 0;
		asi_uplink_data <= 16'hxxxx;
		asi_uplink_empty <= 1'bx;
		asi_uplink_valid <= 0;
	end
	endtask


	initial
	begin
		waitclk(10);
//		asi_burst(8'h00, 1120);
//		waitclk(7);
//		avsWrite(1, 1);
//		waitclk(20);

		forever @(posedge clk)
		begin
			asi_burst(8'h20, 1);
			waitclk(5);
			asi_burst(8'h30, 2);
			waitclk(5);
			asi_burst(8'h40, 3);
			waitclk(5);
			asi_burst(8'h50, 4);
			waitclk(5);
			asi_burst(8'h80, 10);
			waitclk(5);
			asi_burst(8'hc0, 19);
			avsWrite(1, 1);
			waitclk(2);
			asi_burst(8'h00, 301);
			avsWrite(1, 1);
			waitclk(10);
			repeat (6)
			begin
				asi_burst(8'h80, 7);
				waitclk(4);
			end
			asi_burst(8'h40, 17);
			waitclk(200);
		end
	end

	// log write to uplink sink
	reg [7:0]uplink_data1;
	reg [7:0]uplink_data0;
	
	always @(negedge clk)
	begin
		if (asi_uplink_valid && asi_uplink_ready)
		begin
			uplink_data1 <= asi_uplink_data[15:8];
			uplink_data0 <= (!asi_uplink_endofpacket || !asi_uplink_empty) ?
				asi_uplink_data[7:0] : 8'hzz;
		end
		else
		begin
			uplink_data1 <= 8'hzz;
			uplink_data0 <= 8'hzz;
		end

	end




	usb16 DUT
	(
		.clk(clk),
		.reset(reset),

		.avs_ctrl_address(avs_ctrl_address),
		.avs_ctrl_write(avs_ctrl_write),
		.avs_ctrl_writedata(avs_ctrl_writedata),
		.avs_ctrl_read(avs_ctrl_read),
		.avs_ctrl_readdata(avs_ctrl_readdata),
	
		.asi_uplink_ready(asi_uplink_ready),
		.asi_uplink_valid(asi_uplink_valid),
		.asi_uplink_data(asi_uplink_data),
		.asi_uplink_startofpacket(asi_uplink_startofpacket),
		.asi_uplink_endofpacket(asi_uplink_endofpacket),
		.asi_uplink_empty(asi_uplink_empty),
	
		.usb_clk(usb_clk),
		.wr_n(wr_n),
		.rd_n(rd_n),
		.oe_n(oe_n),
		.data(data),
		.txe_n(txe_n),
		.rxf_n(rxf_n),
		.siwu_n(siwu_n)
	);

endmodule
