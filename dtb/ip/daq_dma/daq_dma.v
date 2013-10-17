// dtb_daq.v

`timescale 1 ns / 1 ps

/*
		register set:
		
	 offset	| bits | name      |access| description
   -------+------+-----------+------+--------------------------------
      0   | 30:0 | mem_base  |  R/W |memory base byte address
      4   | 25:0 | mem_size  |  R/W |memory size in words (16 bit)
      8   | 25:0 | mem_read  |  R/W |memory read offset in words
     12   | 25:0 | mem_write |  R   |memory write offset in words
     16   |    0 | control   |  W   | bit 0: enable
     16   |  2:0 | status    |  R   | {fifo_ovfl, ram_ovfl, running}
*/

module daq_dma
(
	
	input clk,
	input reset,
	
	// avalon mm data master
	input avm_data_waitrq,
	output avm_data_write,
	output [15:0]avm_data_writedata,
	output [31:0]avm_data_address,
	output [1:0]avm_data_byteenable,

	// avalon mm ctrl slave
	input  avs_ctrl_write,
	input  [31:0]avs_ctrl_writedata,
	input  avs_ctrl_read,
	output reg [31:0]avs_ctrl_readdata,
	input  [2:0]avs_ctrl_address,

	// conduit interface
	input clk_daq,
	input write,
	input [15:0]din,
	
	output reg running
);

	wire fifo_read;
	wire fifo_empty;
	wire fifo_full;

	// register
	reg [30:1]mem_base;
	reg [26:1]mem_size;
	reg [26:1]mem_read;
	reg [26:1]mem_write;
	reg start;
	reg fifo_ovfl;
	reg ram_ovfl;

	// --- register write -----------------------------------------------------
	wire write_ctrl = avs_ctrl_write && (avs_ctrl_address == 3'd4);
	wire set_start = write_ctrl &&  avs_ctrl_writedata[0];
	wire set_stop  = write_ctrl && !avs_ctrl_writedata[0];

	wire inc;
	wire [26:1]inc_addr = mem_write + 1;
	wire carry = inc_addr == mem_size;
	wire [26:1]next_addr = carry ? 0 : inc_addr;
	wire overflow = next_addr == mem_read;


	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			mem_base  <= 0;
			mem_size  <= 0;
			mem_write <= 0;
			mem_read  <= 0;
			start     <= 0;
			running   <= 0;
			fifo_ovfl <= 0;
			ram_ovfl  <= 0;
		end
		else
		begin
			start <= set_start;
			if (running)
			begin
				if (overflow)  ram_ovfl  <= 1;
				if (fifo_full) fifo_ovfl <= 1;
				if (overflow || fifo_full || set_stop) running <= 0;
				if (fifo_read) mem_write <= next_addr;
				if (avs_ctrl_write && (avs_ctrl_address == 2))
					mem_read <= avs_ctrl_writedata[25:0];
			end
			else if (start)
			begin
				mem_write <= 0;
				mem_read  <= 0;
				fifo_ovfl <= 0;
				ram_ovfl  <= 0;
				running   <= 1;
			end
			else
			begin
				if (avs_ctrl_write)
					case (avs_ctrl_address)
						0: mem_base <= avs_ctrl_writedata[30:1];
						1: mem_size <= avs_ctrl_writedata[25:0];
						2: mem_read <= avs_ctrl_writedata[25:0];
					endcase
			end
		end
	end

	// --- register read ------------------------------------------------------
	always @(*)
	begin
		case (avs_ctrl_address)
			0: avs_ctrl_readdata <= {1'b0,      mem_base, 1'b0};
			1: avs_ctrl_readdata <= {6'b000000, mem_size  };
			2: avs_ctrl_readdata <= {6'b000000, mem_read  };
			3: avs_ctrl_readdata <= {6'b000000, mem_write };
			default: avs_ctrl_readdata <= {29'b0, fifo_ovfl, ram_ovfl, running};
		endcase
	end

	// --- DMA write controller -----------------------------------------------
	assign avm_data_write = !fifo_empty && running;
	assign fifo_read = avm_data_write && !avm_data_waitrq;

	assign avm_data_address = {mem_base + {4'b0000, mem_write}, 1'b0};
	assign avm_data_byteenable = 2'b11;


	daq_dma_fifo buffer
	(
		.aclr(reset || start),
		.data(din),
		.rdclk(clk),
		.rdreq(fifo_read),
		.wrclk(clk_daq),
		.wrreq(write),
		.q(avm_data_writedata),
		.rdempty(fifo_empty),
		.rdfull(fifo_full)
	);

endmodule
