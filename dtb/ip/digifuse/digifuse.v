// digifuse.v

// synthesis translate_off
`timescale 1ns / 100ps
// synthesis translate_on

module digifuse
(
	input  clk,
	input  reset,
	input  sync,
	input  slave_read,
	output [7:0] slave_readdata,
	input  slave_write,
	input  [7:0] slave_writedata,
	input  pon_in,
	input  i_comp,
	output pon_out
);

reg [2:0]delay;
reg active;

reg [7:0]dcnt;
reg raised;
reg timeout;

// --- avalon slave interface
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    delay <= 0;
    active <= 0;
    dcnt <= 0;
    raised <= 0;
  end
  else
  begin
    // avalon slave write
    if (slave_write) { active, delay } <= slave_writedata[3:0];

    // fuse logic
    if (timeout && active) raised <= 1;
    else if (!pon_in)      raised <= 0;

    // delay timer    
    dcnt <= (active && i_comp && !raised)? dcnt+1 : 0;
  end
end

// avalon slave write
assign slave_readdata = slave_read ? { 4'h0, raised, delay } : 0;

always @(*)
begin
  case (delay)
    0: timeout = dcnt[0];
    1: timeout = dcnt[1];
    2: timeout = dcnt[2];
    3: timeout = dcnt[3];
    4: timeout = dcnt[4];
    5: timeout = dcnt[5];
    6: timeout = dcnt[6];
    7: timeout = dcnt[7];
  endcase
end


endmodule
