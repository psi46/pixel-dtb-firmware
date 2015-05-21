// clockgen.v
// clock generator



module clockgen
(
	input clk,
	input reset,

	input [5:0]clkdiv,

	input  shift,
	input  stretch,
	output reg sync,
	output reg phase,

	output reg adcclk,
	output reg adcsync
);

	// --- main counter (phase register) --------------------
	reg [5:0]counter;

	always @(posedge clk or posedge reset)
	begin
		if (reset) counter <= 0;
		else if (!shift) counter <= counter + 1;
	end
	
	
	// --- adc sync/phase generator -------------------------
	reg adcfsel;

	always @(*)
	begin
		case (clkdiv[5:3])
			0: adcfsel <= counter[0];
			1: adcfsel <= counter[1];
			2: adcfsel <= counter[2];
			3: adcfsel <= counter[3];
			4: adcfsel <= counter[4];
			default: adcfsel = counter[5];
		endcase
	end


	wire adcgen_sync;
	wire adcgen_phase;

	clocksm adcgen
	(
		.clk(clk),
		.reset(reset),
		.syncin(adcfsel),
		.veto(1'b0),
		.sync(adcgen_sync),
		.phase(adcgen_phase)
	);
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			adcsync <= 0;
			adcclk  <= 0;
		end
		else
		begin
			adcsync <= adcgen_sync;
			adcclk  <= adcgen_phase;
		end
	end
	

	// --- sync/phase generator -----------------------------
	reg fsel;
	
	always @(*)
	begin
		case (clkdiv[2:0])
			0: fsel <= counter[0];
			1: fsel <= counter[1];
			2: fsel <= counter[2];
			3: fsel <= counter[3];
			4: fsel <= counter[4];
			default: fsel = counter[5];
		endcase
	end


	wire clkgen_sync;
	wire clkgen_phase;

	clocksm clkgen
	(
		.clk(clk),
		.reset(reset),
		.syncin(fsel),
		.veto(stretch),
		.sync(clkgen_sync),
		.phase(clkgen_phase)
	);

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			sync  <= 0;
			phase <= 0;
		end
		else
		begin
			sync  <= clkgen_sync;
			phase <= clkgen_phase;
		end
	end

endmodule
