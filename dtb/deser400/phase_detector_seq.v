// phase_detector_seq.v


module phase_detector_seq
(
	input CLK80,
	input reset,

	input trig,

	output xor_ena,
	output xor_res,
	output store,
	output lut,
	output phcnt,
	output demux
);

	// --- sequencer ----------------------------------------------------------
	reg [5:0]sm;
	localparam SM_IDLE = 6'b000000;
	localparam SM_XOR  = 6'b000101;
	localparam SM_CPY  = 6'b000011;
	localparam SM_LUT  = 6'b001001;
	localparam SM_FLT  = 6'b010000;
	localparam SM_MUX  = 6'b100000;

	assign xor_ena = ~sm[0];
	assign xor_res =  sm[1];
	assign store   =  sm[2];
	assign lut     =  sm[3];
	assign phcnt   =  sm[4];
	assign demux   =  sm[5];

	always @(posedge CLK80 or posedge reset)
	begin
		if (reset)
		begin
			sm <= 0;
		end
		else
		case (sm)
			SM_IDLE: if (trig) sm <= SM_XOR;
			SM_XOR:  sm <= SM_CPY;
			SM_CPY:  sm <= SM_LUT;
			SM_LUT:  sm <= SM_FLT;
			SM_FLT:  sm <= SM_MUX;
			SM_MUX:  sm <= SM_IDLE;
			default: sm <= SM_IDLE;
		endcase
	end

endmodule
