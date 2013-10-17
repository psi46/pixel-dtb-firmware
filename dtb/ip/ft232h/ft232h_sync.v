module ft232h (

	// avalon-bus
	input clk,
	input reset,

	input            avs_slave_write,
	input            avs_slave_read,
	input      [15:0]avs_slave_writedata,
	output     [15:0]avs_slave_readdata,

	// ft232h
	inout       [7:0]usb_data,
	input            usb_rxf_n,
	input            usb_txe_n,
	output reg       usb_rd_n,
	output           usb_wr_n,
	output           usb_siwu_n,
	input            usb_clk,
	output reg       usb_oe_n
);

	//
	// regs / wires
	//
	reg              data_oe_n;
	wire        [8:0]data_out;
	reg		 read_wrreq;
	reg		 trans_rdreq;
	wire             read_full;
	wire             read_empty;
	wire             trans_full;
	wire             trans_empty;
	wire        [7:0]read_out;

assign usb_siwu_n = trans_rdreq;
	//
	// usb
	//
	always @(posedge reset or posedge usb_clk)
	begin
		if(reset)
		begin
			usb_rd_n           <= 1;
			usb_oe_n           <= 1;
			data_oe_n          <= 1;
			trans_rdreq        <= 0;
			read_wrreq         <= 0;
		end
		else		// posedge clk
		begin
			/*if(!usb_rxf_n && !read_full && data_oe_n)		// data to receive, buffer not full and not transmitting
			begin
				usb_oe_n <= 0;
				usb_rd_n <= 0;
				read_wrreq <= 1;
			end
			else							// do not receive
			begin
				usb_oe_n <= 1;
				usb_rd_n <= 1;
				read_wrreq <= 0;

				if(!usb_txe_n && !trans_empty)			// buffer not full and data to transmit
				begin
					data_oe_n <= 0;
					trans_rdreq <= 1;
					usb_wr_n <= 0;
				end
				else						// do not transmit
				begin
					data_oe_n <= 1;
					trans_rdreq <= 0;
					usb_wr_n <= 1;
				end

			end*/
			
			/*if(data_out[8])
			begin
				usb_siwu_n <= 0;
			end
			if(!usb_siwu_n)
			begin
				usb_siwu_n <= 1;
			end*/

		end
	end
	
	assign usb_data = (usb_wr_n) ? 8'bzzzzzzzz : data_out;


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
		usb_read_fifo.lpm_numwords = 32,
		usb_read_fifo.lpm_widthu = 5,
		usb_read_fifo.lpm_showahead = "ON";

	dcfifo usb_trans_fifo
	(
		.data({avs_slave_writedata[15], avs_slave_writedata[7:0]}),
		.rdclk(usb_clk),
		.wrclk(clk),
		.wrreq(avs_slave_write),
		.rdreq(!usb_txe_n),
		.q(data_out),
		.wrfull(trans_full),
		.rdempty(usb_wr_n),
		.aclr(reset)
	);
	defparam
		usb_trans_fifo.lpm_width = 9,
		usb_trans_fifo.lpm_numwords = 32,
		usb_trans_fifo.lpm_widthu = 5,
		usb_trans_fifo.lpm_showahead = "ON";

	assign avs_slave_readdata = {read_empty, 7'b0000000, read_out};
	

endmodule