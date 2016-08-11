// phase_detector_filter.v


module phase_detector_filter
(
	input  clk,
	input  reset,
	
	input  update,
	input  [3:0]phase_in, // 2*pi phase, half steps
	output [3:0]phase_out // 4*pi phase, full steps
);
	localparam N = 10;  // must be >= 5

	// --- phase adder register
	wire [(N-1):0]ph_cnt;
	
	// 4*pi phase
	assign phase_out = ph_cnt[(N-1):(N-4)];

	
	// phase difference
	wire [3:0]diff = ph_cnt[(N-2):(N-5)] - phase_in;
	
	wire cnt_ena = update && (diff != 4'd0);
	wire up = diff[3];
	
	
	// --- phase counter: cnt_ena, up -> ph_cnt ------------------------------
	
	wire [(N-2):0]ph_cnt_L; // lower (N-1) bits
	reg ph_cnt_H;           // upper most bit
	wire carry;
	
	assign ph_cnt = {ph_cnt_H, ph_cnt_L};

	// special handling of upper most bit	
	always @(posedge clk or posedge reset)
	begin
		if (reset) ph_cnt_H <= 1'd1;
		else if (cnt_ena && carry) ph_cnt_H <= up;
	end	

	// counter for lower bits	
	lpm_counter	phase_counter
	(
		.aclr (reset),
		.clk_en (cnt_ena),
		.clock (clk),
		.updown (up),
		.cout (carry),
		.q (ph_cnt_L),
		.aload (1'b0),
		.aset (1'b0),
		.cin (1'b1),
		.cnt_en (1'b1),
		.data ({(N-1){1'b0}}),
		.eq (),
		.sclr (1'b0),
		.sload (1'b0),
		.sset (1'b0)
	);
	defparam
		phase_counter.lpm_direction = "UNUSED",
		phase_counter.lpm_port_updown = "PORT_USED",
		phase_counter.lpm_type = "LPM_COUNTER",
		phase_counter.lpm_width = N-1;
		
endmodule
