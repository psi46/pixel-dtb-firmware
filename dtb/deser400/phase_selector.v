// phase_selector.v

`timescale 1 ns / 1 ps


module phase_selector
(
	input CLK400,
	input reset,
	
	input [3:0]phsel,
	input [7:0]serin,
	output serout
);
	// --- select clock crossing CLK80 -> CLK400 (phsel -> sel);
	reg [3:0]sel;
	
	always @(posedge CLK400 or posedge reset)
	begin
		if (reset) sel <= 0;
		else sel <= phsel;
	end
	
	// --- expand fron 8 to 16 phases (serin -> ser)
	reg [7:0]serdel;
	wire [15:0]ser = {serin, serdel};
	
	always @(posedge CLK400 or posedge reset)
	begin
		if (reset) serdel <= 0;
		else serdel <= serin;
	end
	
	// --- demultiplexer 16:1 (3 stage pipeline)
	reg [7:0]stage1;
	reg [3:0]stage2;
	reg [1:0]stage3;
	reg stage4;
	
	always @(posedge CLK400 or posedge reset)
	begin
		if (reset)
		begin
			stage1 <= 0;
			stage2 <= 0;
			stage3 <= 0;
			stage4 <= 0;
		end
		else
		begin
			stage1 <= sel[0] ? 
				{ser[15], ser[13], ser[11], ser[9], ser[7], ser[5], ser[3], ser[1]} :
				{ser[14], ser[12], ser[10], ser[8], ser[6], ser[4], ser[2], ser[0]};
			
			stage2 <= sel[1] ?
				{stage1[7], stage1[5], stage1[3], stage1[1]} :
				{stage1[6], stage1[4], stage1[2], stage1[0]};
				
			stage3 <= sel[2] ? {stage2[3], stage2[1]} : {stage2[2], stage2[0]};
			
			stage4 <= sel[3] ? stage3[1] : stage3[0];
		end
	end

	assign serout = stage4;
	
endmodule
