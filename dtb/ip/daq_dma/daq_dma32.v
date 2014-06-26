// daq_dma32_debug.v

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

module daq_dma32
(
	
	input clk,
	input reset,
	
	// avalon mm data master
	input avm_data_waitrq,
	output avm_data_write,
	output [31:0]avm_data_writedata,
	output [31:0]avm_data_address,
	output [3:0]avm_data_byteenable,

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
	
	wire dreg_clear;
	wire dreg_write;
	wire [15:0]data;

	wire [1:0]be;
	wire next;

	// register
	reg [15:0]dreg;
	reg dreg_empty;

	reg [30:1]mem_base;
	reg [26:1]mem_size;
	reg [26:1]mem_read;
	reg [26:1]mem_write;
	reg  next2;
	
	reg start;
	reg fifo_ovfl;
	reg ram_ovfl;
	reg running_int;

	// --- register write -----------------------------------------------------
	wire write_ctrl = avs_ctrl_write && (avs_ctrl_address == 3'd4);
	wire set_start = write_ctrl &&  avs_ctrl_writedata[0];
	wire set_stop  = write_ctrl && !avs_ctrl_writedata[0];

	wire [26:1]inc_addr = mem_write + 1;
	wire carry = inc_addr == mem_size;
	wire [26:1]next_addr = carry ? 0 : inc_addr;
	wire overflow = next_addr == mem_read;


	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			dreg        <= 0;
			dreg_empty  <= 1;
			next2       <= 0;
			mem_base    <= 0;
			mem_size    <= 0;
			mem_write   <= 0;
			mem_read    <= 0;
			start       <= 0;
			running_int <= 0;
			fifo_ovfl   <= 0;
			ram_ovfl    <= 0;
		end
		else
		begin
			start <= set_start;
			if (running_int)
			begin
				if (dreg_write) {dreg, dreg_empty} = {data, 1'b0};
				else if (dreg_clear) dreg_empty = 1'b1;
	
				if (overflow)  ram_ovfl  <= 1;
				if (fifo_full) fifo_ovfl <= 1;
				if (overflow || fifo_full || set_stop) running_int <= 0;
				if (next || next2) mem_write <= next_addr;
				
				if ((be == 3) && avm_data_write && !avm_data_waitrq) next2 <= 1;
				else if (!next) next2 <= 0;
				
				if (avs_ctrl_write && (avs_ctrl_address == 2))
					mem_read <= avs_ctrl_writedata[25:0];
			end
			else if (start)
			begin
				dreg_empty  <= 1;
				next2       <= 0;
				mem_write   <= 0;
				mem_read    <= 0;
				fifo_ovfl   <= 0;
				ram_ovfl    <= 0;
				running_int <= 1;
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
			default: avs_ctrl_readdata <= {29'b0, fifo_ovfl, ram_ovfl, running_int};
		endcase
	end

	// --- DMA write controller -----------------------------------------------
	wire  [30:1]address = mem_base + {4'b0000, mem_write};

	reg [6:0]sm_out;
	always @(*)
	begin
		if (running_int)
		case ({fifo_empty, dreg_empty, address[1], avm_data_waitrq})
			4'b0000: sm_out <= 7'b1011111;
			4'b0001: sm_out <= 7'b0001110;
			4'b0010: sm_out <= 7'b1101101;
			4'b0011: sm_out <= 7'b0001100;
			
			4'b0100: sm_out <= 7'b1100110;
			4'b0101: sm_out <= 7'b1100110;
			4'b0110: sm_out <= 7'b1100100;
			4'b0111: sm_out <= 7'b1100100;
			
			4'b1000: sm_out <= 7'b0011011;
			4'b1001: sm_out <= 7'b0001010;
			4'b1010: sm_out <= 7'b0011101;
			4'b1011: sm_out <= 7'b0001100;
			
			4'b1100: sm_out <= 7'b0000010;
			4'b1101: sm_out <= 7'b0000010;
			4'b1110: sm_out <= 7'b0000100;
			4'b1111: sm_out <= 7'b0000100;
		endcase
		else sm_out <= 7'b0000000;
	end
	assign {fifo_read, dreg_write, dreg_clear, avm_data_write, be, next} = sm_out;
	assign avm_data_byteenable = { be[1], be[1], be[0], be[0] };
	assign avm_data_address = {1'b0, address[30:2], 2'b00};
	assign avm_data_writedata = be[0] ? {data, dreg} : {dreg, dreg};


	daq_dma_fifo buffer
	(
		.aclr(reset || start),
		.data(din),
		.rdclk(clk),
		.rdreq(fifo_read),
		.wrclk(clk_daq),
		.wrreq(write),
		.q(data),
		.rdempty(fifo_empty),
		.rdfull(fifo_full)
	);
	
	// clock crossing: runnning_int -> running
	reg running1;
	always @(posedge clk_daq or posedge reset)
	begin
		if (reset)
		begin
			running1 <= 0;
			running  <= 0;
		end
		else
		begin
			running1 <= running_int;
			running  <= running1;
		end
	end

endmodule
