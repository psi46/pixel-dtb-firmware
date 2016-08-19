// module_decoder

`timescale 1 ns / 1 ps


module module_decoder
(
	input clk,
	input reset,
		
	input davail,
	input [3:0]din,
	
	input tbm_hdr,
	input tbm_trl,
	input roc_hdr,
	
	input  idle_in,
	output idle_out,
	
	output reg running,
	
	input  [7:0]xorsum,

	input  [1:0]error_in,
	output [1:0]error_out,
	
	output reg write,
	output reg [15:0]data
);

	// --- error flags -----------------------------------------------------
	
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
	

	// --- idle detector ---------------------------------------------------

	reg [2:0]idle_reg;
	reg idle_data;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			idle_reg  <= 0;
			idle_data <= 0;
		end
		else if (davail)
		begin
			idle_reg  <= {idle_reg[1:0], &din};
			idle_data <= &idle_reg;
		end
	end
	
	assign idle_out = idle_data;
	wire idle = idle_data & idle_in;

	// --- data delay chain
	reg [3:0]d0;
	reg [3:0]d1;
	reg [3:0]d2;
	

	always @(posedge clk or posedge reset)
	begin
		if (reset) {d2, d1, d0} <= 12'd0;
		else if (davail) {d2, d1, d0} <= {d1, d0, din};
	end


	// --- decoder FSM -----------------------------------------------------
	
	localparam SM_IDLE = 6'd0;
	localparam SM_H0   = 6'd1;
	localparam SM_H1   = 6'd2;
	localparam SM_H2   = 6'd3;  // writeH
	localparam SM_H3   = 6'd4;
	localparam SM_H4   = 6'd5;  // writeH
	localparam SM_H5   = 6'd6;
	localparam SM_H6   = 6'd7;
	localparam SM_H7   = 6'd8;
	localparam SM_H8   = 6'd9;
	localparam SM_R0   = 6'd10; // writeR
	localparam SM_R1   = 6'd11;
	localparam SM_R2   = 6'd12;
	localparam SM_R3   = 6'd13; // writeP
	localparam SM_R4   = 6'd14;
	localparam SM_R5   = 6'd15;
	localparam SM_R6   = 6'd16; // writeP
	localparam SM_T0   = 6'd20;
	localparam SM_T1   = 6'd21;
	localparam SM_T2   = 6'd22; // writeT
	localparam SM_T3   = 6'd23;
	localparam SM_T4   = 6'd24; // writeT
	localparam SM_T5   = 6'd25;
	localparam SM_ERR  = 6'd26;

	
	reg [5:0]sm;
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			sm  <= SM_IDLE;
			sme <= 0;
		end
		else
		begin if (davail)
			case (sm)
			
				// --- TBM header detection
				SM_IDLE: if (tbm_hdr)
				         begin
				           sme <= 2'b00; sm <= SM_H0;
				         end
				SM_H0: sm <= SM_H1; // D0
				SM_H1: sm <= SM_H2; // D1
				SM_H2: sm <= SM_H3; // D2
				SM_H3: sm <= SM_H4; // D3
				SM_H4: sm <= SM_H5;
				SM_H5: sm <= SM_H6;
				
				// earliest possible position for TT or RH
				SM_H6: if      (tbm_trl) sm <= SM_T0;
				       else if (roc_hdr) sm <= SM_R0;
				       else              sm <= SM_H7;
				
				// delayed position
				SM_H7: if      (tbm_trl) sm <= SM_T0;
				       else if (roc_hdr) sm <= SM_R0;
				       else			         sm <= SM_H8;

				// delayed position
				SM_H8: if      (tbm_trl) sm <= SM_T0;
				       else if (roc_hdr) sm <= SM_R0;
				       else
				       begin
					       sme[0] <= 1'b1; sm <= SM_ERR;
				       end
				
				// --- ROC data
				SM_R0:                   sm <= SM_R1;
				       
				SM_R1: if      (tbm_trl) sm <= SM_T0;
				       else              sm <= SM_R2;
				       
				SM_R2: if      (tbm_trl) sm <= SM_T0;
				       else if (roc_hdr) sm <= SM_R0;
				       else              sm <= SM_R3;
				       
				SM_R3: if      (tbm_trl) sm <= SM_T0;
				       else if (roc_hdr) sm <= SM_R0;
				       else              sm <= SM_R4;
				       
				SM_R4: if      (tbm_trl) sm <= SM_T0;
				       else if (roc_hdr) sm <= SM_R0;
				       else              sm <= SM_R5;
				       
				SM_R5: if      (tbm_trl) sm <= SM_T0;
				       else              sm <= SM_R6;
				       
				SM_R6: if      (tbm_trl) sm <= SM_T0;
				       else if (idle)
				       begin
				         sme[1] <= 1'b1; sm <= SM_ERR;
				       end
				       else              sm <= SM_R1;
	
				SM_ERR: sm <= SM_T0; // set error flags
	
				SM_T0: sm <= SM_T1; // D0
				SM_T1: sm <= SM_T2; // D1
				SM_T2: sm <= SM_T3; // D2
				SM_T3: sm <= SM_T4; // D3
				SM_T4: sm <= SM_T5;
				default: sm <= SM_IDLE;
			endcase
		end
	end // always


	always @(posedge clk or posedge reset)
	begin
		if (reset) running <= 0;
		else       running = |sm;
	end
	

	// --- error handling --------------------------------------------------

	assign error_out = error_flags[1:0];
	
	always @(posedge clk or posedge reset)
	begin
		if (reset) ef <= 0;
		else
		begin
			if (sm==SM_IDLE) ef <= 0;
			else
			begin
				if (error_in[0]) ef[0] <= 1'b1;
				if (error_in[1]) ef[1] <= 1'b1;
				ef[2] <= |{ef[1:0], sme};
			end
		end
	end
	
	
	// --- data handling ---------------------------------------------------

	reg [1:0]send;
	reg [15:0]data2;

	wire writeH = davail && (sm==SM_H2 || sm==SM_H4); // write TBM header
	wire writeR = davail &&  sm==SM_R0;               // write ROC header
	wire writeP = davail && (sm==SM_R3 || sm==SM_R6); // write ROC data
	wire writeT = davail && (sm==SM_T2 || sm==SM_T4); // write TBM trailer

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			send  <= 0;
			write <= 0;
			data  <= 16'd0;
		end
		else
		begin
			write <= writeH || writeR || writeT || (|send && davail);
			
			case (sm)
				SM_H2: data  <= {4'b1010, 4'b0000, d1,      d0};
				SM_H4: data  <= {4'b1000, 4'b0000, d1,      d0};
				SM_R0: data  <= {4'b0100,      xorsum, 2'b00, d0[1:0]};
				SM_R3: data  <= {4'b0000, d2,      d1,      d0};
				SM_R6:
					begin
						data2 <= {4'b0010, d2,      d1,      d0};
						if (!(tbm_trl || roc_hdr || idle_data)) send <= 2'b11;
					end
				SM_T2: data  <= error_flags[4] ?
				                {3'b111, error_flags, 4'd0, 4'd0} :
				                {3'b111, error_flags, d1,   d0};
				SM_T4: data  <= error_flags[4] ?
				                {3'b110, error_flags, 4'd0, 4'd0} :
				                {3'b110, error_flags, d1,   d0};
				default:
					begin
						if (tbm_trl || roc_hdr) send <= 2'b00;
						else if (send[1]) begin send[1] <= 0; data <= data2; end
						else if (send[0])  send[0] <= 0;
					end
			endcase
		end
	end

endmodule
