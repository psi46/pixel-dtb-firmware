// clocksm.v
// clock state machine


module clocksm
(
	input clk,
	input reset,
	input syncin,
	input veto,

	output sync,
	output phase
);

	localparam SM_PHASE0 = 3'b000;
	localparam SM_PHASE1 = 3'b010;
	localparam SM_PHASE2 = 3'b001;
	localparam SM_PHASE3 = 3'b101;

	reg [2:0]sm;

	assign phase = sm[0];
	assign sync  = sm[1];

	always @(posedge clk or posedge reset)
	begin
		if (reset) sm <= SM_PHASE0;
		else
			case (sm)
				SM_PHASE0: if (syncin) sm <= SM_PHASE1;
				SM_PHASE1: sm <= syncin ? SM_PHASE2 : SM_PHASE3;
				SM_PHASE2: if (!syncin) sm <= SM_PHASE3;
				default: if (!veto) sm <= syncin ? SM_PHASE1 : SM_PHASE0;
			endcase
	end

endmodule
