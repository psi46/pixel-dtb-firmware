// usb_ft232.v

`timescale 1 ns / 1 ps


module usb_ft232
(
	input clk,
	input reset,

	// FT232 interface
	output wr_n,
	output rd_n,
	output oe_n,
	inout  [7:0]data,
	input  txe_n,
	input  rxf_n,
	output siwu_n,
	
	// tx fifo interface
	output tx_read,
	input  [15:0]tx_data,
	input  [1:0]tx_mask,
	input  tx_ready,

	// rx fifo interface
	output reg rx_write,
	output reg [15:0]rx_data,
	output reg rx_mask,
	input  rx_ready
);

  // === transmitter ========================================================

	wire tx_ena;
	wire tx_wait;
	wire tx_skip;
	
	reg  tx_upper;
	
	wire tx_is_send  = tx_ready && !tx_mask[0];
	wire tx_is_16bit = tx_ready && tx_mask[1];
	
	// tx_data -> data transfer; flow control with tx_ena & tx_wait
	wire   wr = !txe_n && tx_ready && tx_ena && !tx_is_send;
	assign wr_n = !wr;
	assign oe_n = !wr_n;
	assign tx_read = (wr && !tx_wait) || tx_skip;
	assign data = oe_n ? (tx_upper ? tx_data[15:8] : tx_data[7:0]) : 8'hzz;
	assign tx_skip = tx_is_send;

	// 16 bit transfer
	always @(posedge clk or posedge reset)
	begin
		if (reset) tx_upper <= 0;
		else if (wr) tx_upper = tx_is_16bit && !tx_upper;
	end
	assign tx_wait = tx_is_16bit && !tx_upper;

	// send immediate
	reg tx_si;
	reg tx_siwu;
	reg [4:0]send_delay;
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			tx_si   <= 0;
			tx_siwu <= 0;
			send_delay <= 0;
		end
		else
		begin
			if (tx_is_send && !tx_si)	tx_si <= 1;
		
			if (tx_si && (send_delay ==  0)) tx_siwu <= 1;
			if (tx_si && (send_delay == 16))
			begin
				tx_si   <= 0;
				tx_siwu <= 0;
			end
	
			if (tx_si || !(send_delay == 5'd0)) send_delay = send_delay + 5'b1;
		end
	end

	assign siwu_n = !tx_siwu;

	
	// === receiver ===========================================================

	wire rx_ena;
	
	wire rx_rd = !rxf_n && rx_ready && rx_ena;
	
	reg rx_upper;

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			rx_upper <= 0;
			rx_mask  <= 0;
			rx_write <= 0;
			rx_data  <= 0;
		end
		else if (rx_ready)
		begin
			rx_upper <= !rx_upper && rx_rd;
			rx_mask  <= rx_upper && rx_rd;
			rx_write <= rx_upper;
			if (rx_rd && !rx_upper) rx_data[7:0]  <= data;
			if (rx_rd &&  rx_upper) rx_data[15:8] <= data;
		end
	end

	assign rd_n = !rx_rd;


	// === priority logic =====================================================

	assign tx_ena = !tx_si;
	assign rx_ena = !(tx_ready && !txe_n);

endmodule
