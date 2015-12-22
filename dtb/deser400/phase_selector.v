// phase_selector.v

`timescale 1 ns / 1 ps


module phase_selector
(
	input CLK400,
	input CLK80,
	input reset,
	
	input [3:0]phsel,
	input [7:0]serin,
	output serout
);
	// --- expand fron 8 to 16 phases (serin -> ser) -------------------------
	reg [7:0]serdel;
	wire [15:0]ser = {serin, serdel};
	
	always @(posedge CLK400 or posedge reset)
	begin
		if (reset) serdel <= 0;
		else serdel <= serin;
	end
	
	// --- 4:16 decoder (phsel -> pos) ---------------------------------------
	reg [15:0]pos;
	always @(posedge CLK80)
	begin
		case (phsel)
			 4'd0: pos <= 16'b0000_0000_0000_0001;
			 4'd1: pos <= 16'b0000_0000_0000_0010;
			 4'd2: pos <= 16'b0000_0000_0000_0100;
			 4'd3: pos <= 16'b0000_0000_0000_1000;
			 4'd4: pos <= 16'b0000_0000_0001_0000;
			 4'd5: pos <= 16'b0000_0000_0010_0000;
			 4'd6: pos <= 16'b0000_0000_0100_0000;
			 4'd7: pos <= 16'b0000_0000_1000_0000;
			 4'd8: pos <= 16'b0000_0001_0000_0000;
			 4'd9: pos <= 16'b0000_0010_0000_0000;
			4'd10: pos <= 16'b0000_0100_0000_0000;
			4'd11: pos <= 16'b0000_1000_0000_0000;
			4'd12: pos <= 16'b0001_0000_0000_0000;
			4'd13: pos <= 16'b0010_0000_0000_0000;
			4'd14: pos <= 16'b0100_0000_0000_0000;
			4'd15: pos <= 16'b1000_0000_0000_0000;
		endcase
	end
	
	// --- demultiplexer 16:1 (3 stage pipeline) -----------------------------
	reg [15:0]stage1;
	reg [3:0]stage2;
	reg stage3;
	
	always @(posedge CLK400 or posedge reset)
	begin
		if (reset)
		begin
			stage1 <= 0;
			stage2 <= 0;
			stage3 <= 0;
		end
		else
		begin
			stage1 <= ser & pos;  // clock crossing (pos)
			stage2 <= {|stage1[15:12], |stage1[11:8], |stage1[7:4], |stage1[3:0]};
			stage3 <= |stage2;
		end
	end

	assign serout = stage3;
	
endmodule
