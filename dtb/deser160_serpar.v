// deser12.v

`timescale 1ns / 1ps


module deser160_serpar_delay
(
  input clk,
  input sync,
  input reset,
  
  input [2:0]delay,
  input in,
  output out
);

  reg [7:0]shift;
  
  always @(posedge clk or posedge reset)
  begin
    if (reset) shift <= 0;
    else if (sync) shift <= { shift[6:0], in };
  end
  
  assign out = shift[delay];

endmodule



module deser160_serpar
(
	input clk,
	input sync,
	input reset,
	
	input [3:0]ctrl,
	
	input run,
	input tin,
	input tout,

	input [3:0]din,
	
	output reg write,
	output reg [15:0]data
);

  // command register
  //    3     2     1     0
  // +-----+-----+-----+-----+
  // | ena |      delay      |
  // +-----+-----+-----+-----+
  wire [2:0]delay;
  wire enable;
  assign {enable, delay} = ctrl;

  // --- enable, start timing adjust (tin) -----------------------------------
  reg tin_ena;
  always @(posedge clk or posedge reset)
  begin
    if (reset) tin_ena <= 0;
    else if (sync) tin_ena <= tin && run;
  end

  wire tin_del;
  deser160_serpar_delay del_tin (clk, sync, reset, delay,  tin_ena,  tin_del );

  // stop timing (tout) ------------------------------------------------------
  reg tout_del1, tout_del;
  always @(posedge clk or posedge reset)
  begin
    if (reset) { tout_del, tout_del1 } <= 2'b00;
    else if (sync) { tout_del, tout_del1 } <= { tout_del1,  tout };
  end 

  // --- start/stop marker ---------------------------------------------------
  reg mark_start;
  reg mark_end;
  always @(posedge clk or posedge reset)
  begin
    if (reset)
    begin
      mark_start <= 0;
      mark_end   <= 0;
    end
    else
    begin
      if (tin_del) mark_start <= 1;
      else if (write) mark_start <= 0;
      if (tout_del) mark_end <= 1;
      else if (write) mark_end <= 0;
    end
  end

	// data shift register
	reg [3:0]d1;
	reg [3:0]d2;	

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			d1 <= 0;
			d2 <= 0;
		end
		else if (sync)
		begin
			d1 <= din;
			d2 <= d1;
		end
	end

	reg stop;
	reg [1:0]sm;

	always @(posedge clk or posedge reset)
	begin
		if (reset) stop <= 0;
		else if (sync)
		begin
			if (sm == 0) stop <= 0;
			else if (tout_del) stop <= 1;
		end
	end

	// state machine
	always @(posedge clk or posedge reset)
	begin
		if (reset) sm <= 0;
		else if (sync)
		begin
		  if (enable && run)
		  begin    
			 case (sm)
				  0: if (tin_del) sm <= 1;
				  1: sm <= 2;
				  2: sm <= 3;
				  3: sm <= stop ? 0 : 1;
			 endcase
			end
			else sm <= 0;
		end
	end

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			data  <= 0;
		end
		else if (sync)
		begin
			if (sm == 2) data <= { mark_start, mark_end, 2'b00, d2, d1, din };
		end
	end

	always @(posedge clk or posedge reset)
	begin
    if (reset) write <= 0;
    else write <= (sm == 3) & sync;
	end

endmodule
