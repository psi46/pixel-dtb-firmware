// sample_reg.v

/*
FUNCTION cycloneiii_lcell_comb (cin, dataa, datab, datac, datad)
WITH ( DONT_TOUCH, LUT_MASK, SUM_LUTC_INPUT)
RETURNS ( combout, cout);
*/

module sample_reg
(
	input clk,
	input res_n,
	input D,
	output reg Q
);

wire Dint;


cycloneiii_lcell_comb #( .DONT_TOUCH("on"), .LUT_MASK(16'hff00) ) comb
(
	.datad(D),
	.combout(Dint)
);


always @(posedge clk or negedge res_n) Q <= !res_n ? 1'b0 : Dint;

endmodule
