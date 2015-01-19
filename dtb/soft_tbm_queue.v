// soft_tbm_queue.v

`timescale 1 ns / 1 ps

module soft_tbm_queue
#(parameter DATA_WIDTH=36)
(
	input clk,
	input sync,
	input reset,
	
	input write,
	input read,
	input clear,
	input clear_token,

	output empty,
	output full,
	output [3:0]size,

	input [DATA_WIDTH:0]din,
	output [DATA_WIDTH:0]dout
);

	wire write_int = write && !full;
	wire read_int  = read && !empty;

	wire [(DATA_WIDTH-1):0]fifo_din;
	wire [(DATA_WIDTH-1):0]fifo_dout;
	wire tok_in;
	wire tok_out;

	assign {fifo_din, tok_in} = din;
	assign dout = {fifo_dout, tok_out};

	// write -> 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
	//                |
	//                +--> read
	reg [15:0]tok_queue;
	reg [3:0]tok_pos;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			tok_queue <= 16'd0;
			tok_pos   <= 4'd15;
		end
		else if (sync)
		begin
			if (clear) tok_queue <= 16'd0;
			else if (write_int)
			begin
				if (clear_token) tok_queue <= {15'd0, tok_in};
				else             tok_queue <= {tok_queue[14:0], tok_in};
			end
			else if (clear_token) tok_queue <= 16'd0;
			
			if (clear) tok_pos <= 4'd15;
			else if (write_int && !read_int) tok_pos <= tok_pos + 4'd1;
			else if (!write_int && read_int) tok_pos <= tok_pos - 4'd1;
		end
	end

	assign tok_out = tok_queue[tok_pos];

	scfifo
	#(
	  .add_ram_output_register("OFF"),
	  .intended_device_family("Cyclone III"),
	  .lpm_numwords(16),
	  .lpm_showahead("ON"),
	  .lpm_type("scfifo"),
	  .lpm_width(DATA_WIDTH),
	  .lpm_widthu(4),
	  .overflow_checking("OFF"),
	  .underflow_checking("OFF"),
	  .use_eab("ON")
	) fifo
	(
	  .aclr (reset),
	  .clock (clk),
	  .data (fifo_din),
	  .rdreq (read_int && sync),
	  .wrreq (write_int && sync),
	  .empty (empty),
	  .full (full),
	  .q (fifo_dout),
	  .sclr (clear),
	  .usedw (size),
	  .almost_full (),
	  .almost_empty ()
	);

endmodule
