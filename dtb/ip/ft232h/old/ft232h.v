module ft232h (

	// avalon-bus
	input clk,
	input reset,

	input            avs_slave_address,
	input            avs_slave_write,
	input            avs_slave_read,
	input      [15:0]avs_slave_writedata,
	output     [15:0]avs_slave_readdata,
	output           avs_slave_waitrequest,

	// ft232h
	inout       [7:0]usb_data,
	input            usb_rxf_n,
	input            usb_txe_n,
	output reg       usb_rd_n,
	output           usb_wr_n,
	output reg       usb_siwu_n,
	input            usb_clk,
	output reg       usb_oe_n
);

	//
	// parameters
	//
	parameter        transmit_fifo_size = 32;
	parameter        receive_fifo_size = 32;

	//
	// regs / wires
	//
	// read-fifo
	wire             read_full;
	wire             read_empty;
	wire        [7:0]read_out;
	reg		 read_wrreq;
	// transmit-fifo
	wire             trans_full;
	wire             trans_empty;
	wire		 trans_rdreq;
	wire        [8:0]data_out;
	wire             data_oe;
	// async part
	wire             receive_ok;


	//
	// usb
	//
	// transmit
	assign usb_wr_n    = usb_txe_n | trans_empty | !usb_rd_n | !usb_siwu_n;
	assign data_oe     = !usb_txe_n & !trans_empty & usb_rd_n & usb_siwu_n;
	assign trans_rdreq = !usb_txe_n & !trans_empty & usb_rd_n & usb_siwu_n;
	assign usb_data = data_oe ? data_out : 8'bzzzzzzzz;
	
	always @(posedge usb_clk or posedge reset)
	begin
		if(reset)
		begin
			usb_siwu_n <= 1;
		end
		else
		begin
			if(data_out[8] && trans_rdreq)
			begin
				usb_siwu_n <= 0;
			end
			else
			begin
				usb_siwu_n <= 1;
			end
		end
	end
	
	assign avs_slave_waitrequest = trans_full & avs_slave_write;
	
	// receive
	assign receive_ok    = !usb_rxf_n & !read_full & usb_wr_n;
	
	always @(posedge usb_clk or negedge receive_ok or posedge reset)
	begin
		if(reset || !receive_ok)
		begin
			usb_rd_n   <= 1;
			usb_oe_n   <= 1;
			read_wrreq <= 0;
		end
		else
		begin
			usb_rd_n   <= 0;
			usb_oe_n   <= 0;
			read_wrreq <= 1;
		end
	end


	//
	// fifo
	//
	dcfifo usb_read_fifo
	(
		.data(usb_data),
		.rdclk(clk),
		.wrclk(usb_clk),
		.wrreq(read_wrreq),
		.rdreq(avs_slave_read),
		.q(read_out),
		.wrfull(read_full),
		.rdempty(read_empty),
		.aclr(reset)
	);
	defparam
		usb_read_fifo.lpm_width = 8,
		usb_read_fifo.lpm_numwords = receive_fifo_size,
		usb_read_fifo.lpm_widthu = $clog2(receive_fifo_size),
		usb_read_fifo.lpm_showahead = "ON";

	dcfifo usb_trans_fifo
	(
		.data({avs_slave_writedata[15], avs_slave_writedata[7:0]}),
		.rdclk(usb_clk),
		.wrclk(clk),
		.wrreq(avs_slave_write),
		.rdreq(trans_rdreq),
		.q(data_out),
		.wrfull(trans_full),
		.rdempty(trans_empty),
		.aclr(reset)
	);
	defparam
		usb_trans_fifo.lpm_width = 9,
		usb_trans_fifo.lpm_numwords = transmit_fifo_size,
		usb_trans_fifo.lpm_widthu = $clog2(transmit_fifo_size),
		usb_trans_fifo.lpm_showahead = "ON";

	assign avs_slave_readdata = (avs_slave_address==0) ? {read_empty, 7'b0000000, read_out} : {trans_full, 15'b000000000000000};
	

endmodule