// phasedet.v
// phase detector


module phasedet
(
	input clk,
	input reset,
	
	input enable,

	input in,
	input ref_in,

	output shift
);

	// --- phase comparator
	reg ref_ff;
	reg phaseError;

	always @(negedge clk or posedge reset)
	begin
		if (reset) ref_ff <= 0;
		else ref_ff <= ref_in && enable;
	end

	always @(posedge clk or posedge reset)
	begin
		if (reset) phaseError <= 0;
		else if (in) phaseError <= ref_ff;
	end

	// low pass filter
	reg [5:0]lpcnt;
	wire lpmin = lpcnt == 5'd0;
	assign shift = lpcnt[5];

	always @(posedge clk or posedge reset)
	begin
		if (reset)lpcnt <= 6'd0;
		else
		begin
			if (shift)           lpcnt <= 6'd0;
			else if (phaseError) lpcnt <= lpcnt + 6'd1;
			else if (!lpmin)     lpcnt <= lpcnt - 6'd1;
		end
	end


endmodule
