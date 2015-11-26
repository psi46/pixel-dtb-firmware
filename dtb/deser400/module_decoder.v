// module_decoder

`timescale 1 ns / 1 ps


module module_decoder
(
	input clk80,
	input reset,
	
	input [1:0]error,
	input davail,
	output reg running,
	
	input [3:0]din,
	output write,
	output reg [15:0]data
);

	reg tbm_hdr;
	reg tbm_trl;
	reg roc_hdr;
	
	// --- delay chain
	reg [3:0]data4;
	reg [3:0]data3;
	reg [3:0]data2;
	reg [3:0]data1;
	
	// --- idle detector
	reg [3:0]idle;

	// --- decoder state machine
	reg [5:0]sm;
	
	// --- error flags
	reg [1:0]sme; // state machine error
	reg [2:0]ef;  // external error flags

	wire [4:0]error_flags = {ef, sme};
	/*
		bit 0: no TBM trailer or ROC header after TBM header
		bit 1: idle pattern detected during readout
		bit 2: code error
		bit 3: frame error
		bit 4: one of the four errors detected
	*/
	
	always @(posedge clk80 or posedge reset)
	begin
		if (reset) ef <= 0;
		else
		begin
			if (!running) ef <= 0;
			else
			begin
				if (error[0]) ef[0] <= 1'b1;
				if (error[1]) ef[1] <= 1'b1;
				ef[2] <= |{ef[1:0], sme};
			end
		end
	end
	
	// --- header detector ----------------------------------------------------
	reg [2:0]hdr;
	wire is_hdr = (hdr == 3'b110) && din[3];
	
	always @(posedge clk80 or posedge reset)
	begin
			if (reset)
			begin
				tbm_hdr <= 0;
				tbm_trl <= 0;
				roc_hdr <= 0;
				
				data4   <= 0;
				data3   <= 0;
				data2   <= 0;
				data1   <= 0;
				
				idle    <= 0;
				hdr     <= 0;
			end
			else if (davail)
			begin
				if      (din == 4'b0111) hdr <= {hdr[0], 2'b01};
				else if (din == 4'b1111) hdr <= {hdr[0], 2'b10};
				else hdr <= {hdr[0], 2'b00};
				
				tbm_hdr <= is_hdr && (din[2:0] == 3'b100);
				tbm_trl <= is_hdr && (din[2:0] == 3'b110);
				roc_hdr <= is_hdr && !din[2];
				
				data4 <= din;
				data3 <= data4;
				data2 <= data3;
				data1 <= data2;
				
				idle <= {idle[2:0], &data1};
			end
	end
	
	// --- decoder state machine --------------------------------------------------------

	// --- states
	// TBM header states
	localparam H0 = 6'b0_101_00; // 14
	localparam H1 = 6'b0_101_01; // 15
	localparam H2 = 6'b0_101_10; // 16
	localparam H3 = 6'b1_101_11; // 37
	localparam H4 = 6'b0_100_00; // 10
	localparam H5 = 6'b1_100_01; // 31
	localparam H6 = 6'b0_100_10; // 12
	
	// TBM trailer states
	localparam T0 = 6'b0_111_00; // 1c
	localparam T1 = 6'b0_111_01; // 1d
	localparam T2 = 6'b0_111_10; // 1e
	localparam T3 = 6'b1_111_11; // 3f
	localparam T4 = 6'b0_110_00; // 18
	localparam T5 = 6'b1_110_01; // 39
	localparam T6 = 6'b0_110_10; // 1a
	
	// ROC header states
	localparam R0 = 6'b0_010_00; // 08
	localparam R1 = 6'b0_010_01; // 09
	localparam R2 = 6'b1_010_10; // 2a
	
	// ROC pixel data states
	localparam P0 = 6'b1_000_00; // 20
	localparam P1 = 6'b0_000_01; // 01
	localparam P2 = 6'b0_000_10; // 02
	localparam P3 = 6'b1_001_00; // 24
	localparam P4 = 6'b0_001_01; // 05
	localparam P5 = 6'b0_001_10; // 06
	//                 | |||
	//                 | |||
	//                 | +++-------- data mode (qualifier)
	//                 +------------ write
	
	
	// data output state
	wire [2:0]mode = sm[4:2];
	  
	always @(posedge clk80 or posedge reset)
	begin
			if (reset)
			begin
				sm <= 0;
				running <= 0;
			end
			else if (davail)
			begin
				running = |sm;
				case (sm)
					4'd0: if (tbm_hdr) begin sme <= 0; sm <= H0; end

					H0: sm <= H1;
					H1: sm <= H2;
					H2: sm <= H3;
					H3: sm <= H4;
					H4: sm <= H5;
					H5: sm <= H6;
					H6: if      (tbm_trl)    sm <= T0;
					    else if (roc_hdr)    sm <= R0;
					    else begin sme[0] <= 1'b1; sm <= T0; end
					
					R0: sm <= R1;
					R1: sm <= R2;
					R2: if      (tbm_trl) sm <= T0;
					    else if (roc_hdr) sm <= R0;
					    else              sm <= P0;
					
					P0: sm <= P1;
					P1: sm <= P2;
					P2: sm <= P3;
					P3: sm <= P4;
					P4: sm <= P5;
					P5: if      (tbm_trl)    sm <= T0;
					    else if (roc_hdr)    sm <= R0;
					    else if (~&idle)     sm <= P0;
					    else begin sme[1] <= 1'b1; sm <= T0; end

					T0: sm <= T1;
					T1: sm <= T2;
					T2: sm <= T3;
					T3: sm <= T4;
					T4: sm <= T5;
					T5: sm <= T6;
					T6: sm <= 0;
					
					default: sm <= 0;
				endcase
			end
	end

	// --- data output
	assign write = sm[5] & davail;

	always @(*)
	begin
		if      (mode[2]) data <= {mode,  error_flags, data1, data2};
		else if (mode[1]) data <= {mode, 11'b0_0000_0000_00, data1[1:0]};
		else              data <= {mode,  1'b0, data1, data2, data3};
	end

endmodule
