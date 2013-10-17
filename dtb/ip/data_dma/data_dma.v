// data_dma.v

`timescale 1ns / 1ps


`define ADDR_PTR   0
`define ADDR_LEN   1
`define ADDR_CTRL  2
`define ADDR_STAT  2

module data_dma
(
	// avalon clock interface
	input csi_clock_clk,
	input csi_clock_reset,
	
	// avalon mm slave: control port
	input       [1:0]avs_ctrl_address,
	input            avs_ctrl_write,
	input      [31:0]avs_ctrl_writedata,
	input            avs_ctrl_read,
	output reg [31:0]avs_ctrl_readdata,

	// avalon mm master: DMA data write port
	output [31:0]avm_data_address,
	output       avm_data_write,
	output [15:0]avm_data_writedata,
	input        avm_data_waitrequest,
	output  [1:0]avm_data_byteenable,

	// avalon conduit: external data source
	input write,
	output waitrq,
	input [15:0]data
);

	wire clk = csi_clock_clk;
	wire reset = csi_clock_reset;
 	wire lastword;

	// --- data copy handshake ------------------------------------------------
	reg dma_enable;
	reg [15:0]data_reg;
	reg full;

	wire do_read  = dma_enable & write & !waitrq;
	wire do_write = avm_data_write & !avm_data_waitrequest & !lastword;
	
	// full reg
	always @(posedge clk or posedge reset)
	begin
		if (reset) full <= 0;
		else
		begin
			if (!dma_enable) full <= 0;
			else if ( do_write & !do_read) full <= 0;
			else if (!do_write &  do_read) full <= 1;
		end
	end

  // data reg
	always @(posedge clk or posedge reset)
	begin
		if (reset) data_reg <= 0;
		else	if (do_read) data_reg <= data;
	end  

	assign avm_data_write = full & dma_enable;
	assign waitrq = !dma_enable | (full & !do_write);

	// --- DMA register -------------------------------------------------------
	reg [30:1]pointer; // word address pointer (read/write)
	reg [30:1]length;  // max/actual data size in words (read/write)

 	assign lastword = length == 0;
 	wire running = dma_enable & !lastword;

  // set registers
  always @(posedge clk or posedge reset)
  begin
    if (reset)
    begin
      pointer    <= 0;
      length     <= 0;
      dma_enable <= 0;
    end
    else
    begin
      if (avs_ctrl_write && avs_ctrl_address == `ADDR_CTRL)
        dma_enable <= avs_ctrl_writedata[0];

      if (dma_enable)
      begin
        if (do_write)
        begin
          pointer <= pointer + 1;
          length  <= length  - 1;
        end
      end
      else if (avs_ctrl_write)
      begin
        case (avs_ctrl_address)
          `ADDR_PTR: pointer <= avs_ctrl_writedata[30:1];
          `ADDR_LEN: length  <= avs_ctrl_writedata[30:1];
        endcase
      end
    end
  end

  assign avm_data_address    = { 1'b0, pointer, 1'b0 };
  assign avm_data_byteenable = 2'b11;
  assign avm_data_writedata = data_reg;

  always @(*)
  begin
    case (avs_ctrl_address)
      `ADDR_PTR: avs_ctrl_readdata = { 1'b0, pointer, 1'b0 };
      `ADDR_LEN: avs_ctrl_readdata = { 1'b0, length,  1'b0 };
      default:   avs_ctrl_readdata = { 31'b0, running };
    endcase
  end

endmodule
