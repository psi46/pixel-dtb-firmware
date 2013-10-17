// pg_sequencer.v

`timescale 1ns / 1ps


module pg_sequencer
(
  input clk,
  input sync,
  input reset,

	input enable,
  input start,
  output reg running,
  output reg [3:0]signal,

  output reg [7:0]ip,  // command index pointer
  input [15:0]cmd
);

  /* command word structure
  
    15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
   |           |  signal   |        delay          |
   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

  */
  wire [3:0]cmd_sig = cmd[11:8];
  wire [7:0]cmd_del = cmd[7:0];
  wire stop = cmd_del == 0;   // stop command

  reg [7:0]delay;   // delay counter
  wire next = delay == 0;
 
   
  // start/stop 
  always @(posedge clk or posedge reset)
  begin
    if (reset) running <= 0;
    else if (enable)
    begin
    	if (sync)
    	begin
    	  if (start)             running <= 1;
    	  else if (stop && next) running <= 0;
    	end
    end
    else running <= 0;
  end

  // set index pointer
  always @(posedge clk or posedge reset)
  begin
    if (reset) ip <= 0;
    else if (sync)
    begin
      if (!running)  ip <= 0;
      else if (next) ip <= ip + 1;
    end
  end
 
  // command execution
  always @(posedge clk or posedge reset)
  begin
    if (reset)
    begin
      delay  <= 0;
      signal <= 0;
    end
    else if (sync)
    begin
      if (!running)
      begin
        delay  <= 0;
        signal <= 0;
      end
      else if (next)
      begin
        delay  <= cmd_del;
        signal <= cmd_sig;
      end
      else
      begin
        delay  <= delay - 1;
        signal <= 4'b0000;
      end
    end
  end

endmodule
