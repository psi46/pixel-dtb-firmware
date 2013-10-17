// edge.v

module edge
(
	input clk,
	input d,
	output q
);
	localparam sm_idle = 0x00;
	localparam sm_set  = 0x01;
	localparam sm_wait = 0x10;
	
	reg [1:0]sm;
	always @(posedge clk or posedge reset)
	begin
		if (reset) sm <= state_idle;
		else
		case (sm)
			sm_idle: if (d) sm <= sm_set;
			sm_set:  sm <= sm_wait;
			sm_wait: if (!d) sm <= sm_idle;
			default: sm <= sm_idle;
		endcase
	end
	
	assign q = sm[0];
	
endmodule
