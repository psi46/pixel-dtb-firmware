// datamaster.v

`timescale 1ns / 100ps

`define ADDR_PTR   0
`define ADDR_LEN   1
`define ADDR_CTRL  2
`define ADDR_STAT  2

module datamaster
(
	input clk,
	input reset,
	
	// control port (avalon slave)
	input       [3:0]ctrl_address,
	input            ctrl_write,
	input      [31:0]ctrl_writedata,
	input            ctrl_read,
	output reg [31:0]ctrl_readdata,

	// data port (avalon master)
	output [31:0]data_address,
	output       data_write,
	output [15:0]data_writedata,
	input        data_waitrequest,
	output  [1:0]data_byteenable,

	// interface
	input write,
	input [15:0]data,
	output waitrq,
	output ready
);

  reg [30:1]pointer; // address pointer (read/write)
  reg [30:1]length;  // max/actual data size (read/write)
  reg enable;        // DMA enable
  wire lastword;
  wire next;

  // set registers
  always @(posedge clk or posedge reset)
  begin
    if (reset)
    begin
      pointer <= 0;
      length  <= 0;
      enable  <= 0;
    end
    else
    begin
      if (ctrl_write && ctrl_address == `ADDR_CTRL)
        enable <= ctrl_writedata[0];

      if (enable)
      begin // count
        if (next)
        begin
          pointer <= pointer + 1;
          length  <= length  - 1;
        end
      end
      else if (ctrl_write)
      begin
        case (ctrl_address)
          `ADDR_PTR: pointer <= ctrl_writedata[30:1];
          `ADDR_LEN: length  <= ctrl_writedata[30:1];
        endcase
      end
    end
  end

  assign lastword = length == 0;
  assign waitrq   = !enable || data_waitrequest || lastword;
  assign ready    = lastword;
  assign next = data_write & !data_waitrequest;

  assign data_address    = { 1'b0, pointer, 1'b0 };
  assign data_byteenable = 2'b11;
  assign data_write = enable && !lastword && write;
  assign data_writedata = data;

  always @(*)
  begin
    if (ctrl_read)
      case (ctrl_address)
        `ADDR_PTR: ctrl_readdata = { 1'b0, pointer, 1'b0 };
        `ADDR_LEN: ctrl_readdata = { 1'b0, length,  1'b0 };
        default:   ctrl_readdata = { 31'b0, ready };
      endcase
    else ctrl_readdata = 0;
  end
  
endmodule
