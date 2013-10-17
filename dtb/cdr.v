// cdr.v

module cdr
(
	input res,
	input [7:0]clk,
	
	input sdata,
	output [7:0]q
);

wire [7:0]q0, q1, q2;

sample_reg sample[7:0] ( {clk[0], clk[1], clk[2], clk[3], clk[4], clk[5], clk[6], clk[7]}, ~res, sdata, q0 );
sample_reg del1[7:0]   ( {clk[0], clk[0], clk[0], clk[1], clk[2], clk[3], clk[4], clk[5]}, ~res, q0,    q1 );
sample_reg del2[7:0]   ( {clk[0], clk[0], clk[0], clk[0], clk[0], clk[1], clk[2], clk[3]}, ~res, q1,    q2 );
sample_reg del3[7:0]   ( {clk[0], clk[0], clk[0], clk[0], clk[0], clk[0], clk[0], clk[0]}, ~res, q2,    q  );

endmodule
