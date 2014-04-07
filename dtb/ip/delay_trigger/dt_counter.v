// dt_counter.v


module dt_counter(
	input clk,
	input reset,
	input sync,
	input start,
	input [9:0]t_del,
	input [15:0]t_width,
	output pulse,
	output running
);

wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_13;
reg	DFFE_inst13;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_11;

assign	pulse = SYNTHESIZED_WIRE_14;
assign	running = SYNTHESIZED_WIRE_3;


lpm_counter b2v_inst
(
	.aclr(reset),
	.sload(SYNTHESIZED_WIRE_0),
	.cnt_en(SYNTHESIZED_WIRE_12),
	.clock(clk),
	.clk_en(sync),
	.data(t_del),
	.cout(SYNTHESIZED_WIRE_13)
);
defparam	b2v_inst.LPM_DIRECTION = "DOWN";
defparam	b2v_inst.LPM_PORT_UPDOWN = "PORT_UNUSED";
defparam	b2v_inst.LPM_WIDTH = 10;


assign	SYNTHESIZED_WIRE_14 =  ~SYNTHESIZED_WIRE_2;
assign	SYNTHESIZED_WIRE_11 =  ~SYNTHESIZED_WIRE_3;


always@(posedge clk)
begin
if (sync)
	begin
	DFFE_inst13 <= SYNTHESIZED_WIRE_12;
	end
end

assign	SYNTHESIZED_WIRE_12 =  ~SYNTHESIZED_WIRE_13;
assign	SYNTHESIZED_WIRE_9 = SYNTHESIZED_WIRE_13 & DFFE_inst13;
assign	SYNTHESIZED_WIRE_3 = SYNTHESIZED_WIRE_14 | SYNTHESIZED_WIRE_12;


lpm_counter b2v_inst8
(
	.aclr(reset),
	.sload(SYNTHESIZED_WIRE_9),
	.cnt_en(SYNTHESIZED_WIRE_14),
	.clock(clk),
	.clk_en(sync),
	.data(t_width),
	.cout(SYNTHESIZED_WIRE_2)
);
defparam	b2v_inst8.LPM_DIRECTION = "DOWN";
defparam	b2v_inst8.LPM_PORT_UPDOWN = "PORT_UNUSED";
defparam	b2v_inst8.LPM_WIDTH = 16;

assign	SYNTHESIZED_WIRE_0 = SYNTHESIZED_WIRE_11 & start;

endmodule
