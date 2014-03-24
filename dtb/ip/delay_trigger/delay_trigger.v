// delay_trigger.v


module delay_trigger
(
	input  clk,
	input  reset,
	input  sync,
	input  [3:0]trig_in,
	output pulse,
	
	input  clksys,
	input  write,
	input  [15:0] writedata,
	input  [1:0] address
);

	reg start;
	reg [1:0]sreg;
	reg enareg;
	reg [9:0]dreg;
	reg [15:0]wreg;
	
	// avalon interface
	always @(posedge clksys or posedge reset)
	begin
		if (reset)
		begin
			sreg   <= 0;
			enareg <= 0;
			dreg   <= 0;
			wreg   <= 0;
		end
		else if (write)
		begin
			case (address)
				0: {enareg, sreg} <= writedata[2:0];
				1: dreg <= writedata[9:0];
				2: wreg <= writedata;
			endcase
		end
	end
	
	// input switch
	always @(*)
	begin
		if (enareg)
			case (sreg)
				0: start <= trig_in[0];
				1: start <= trig_in[1];
				2: start <= trig_in[2];
				3: start <= trig_in[3];
			endcase
		else start <= 0;
	end
	
	// delay timer
	dt_counter delay
	(
		.clk(clk),
		.reset(reset),
		.sync(sync),
		.start(start),
		.t_del(dreg),
		.t_width(wreg),
		.pulse(pulse)
	);
endmodule
