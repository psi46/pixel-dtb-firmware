module delayport
(
  input  clk,
  input  reset_n,

  // avalon mm slave
  input  [2:0]slave_address,
  input       slave_write,
  input [15:0]slave_writedata,

  // interface
  output store,
  output [2:0]sel,
  output [9:0]data
);

  reg  storereg;
  reg  [2:0]selreg;
  reg  [9:0]datareg;

  assign store  = storereg;
  assign sel    = selreg;
  assign data   = datareg;

	always @(posedge clk or negedge reset_n)
	begin
		if (reset_n == 0)
		begin
			storereg  <= 0;
			selreg    <= 0;
			datareg   <= 0;
		end
      	else
		begin
     	storereg  <= slave_write;
     	if (slave_write)
			begin
      	selreg  <= slave_address;
				datareg <= slave_writedata[9:0];
			end
		end
	end

endmodule
