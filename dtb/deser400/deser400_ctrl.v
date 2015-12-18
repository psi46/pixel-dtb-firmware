// demux400_ctrl.v

/*
reg  bits       description
-------------------------------------------------------------------------------
  0    1   W    event: single trigger
  1    4   W    enable: enable_IV, enable_III, enable_II, enable_I
  2    7   W    gate: gate_ena, gate_periode, gate_width
  3    4   W    phenable: phenable_IV, phenable_III, phenable_II, phenable_I,
  4    8   W    phsel_IV, phsel_III, phsel_II, phsel_I, phdata
  5   32   R    xorsum_IV, xorsum_III, xorsum_II, xorsum_I
  6   16   R    phsel_IV, phsel_III, phsel_II, phsel_I
  8    7   W    Test point select A
  9    7   W    Test point select B

  Test signals:
  - phase det gate
  - frame error
  - code error
  - tbmA data
  - tbmA gate
  - tbmA header
  - tbmA roc header
  - tbmA trailer
  - tbmA error header
  - tbmA error idle
  - tbmB data
  - tbmB gate
  - tbmB header
  - tbmB roc header
  - tbmB trailer
  - tbmB error header
  - tbmB error idle
*/
	
module deser400_ctrl
(
	input clk,
	input reset,

	input read,
	input write,
	input [3:0]address,
	input [31:0]writedata,
	output reg [31:0]readdata,

	output gate,

	output enable_I,
	output enable_II,
	output enable_III,
	output enable_IV,
	
	output phwrite_I,
	output phwrite_II,
	output phwrite_III,
	output phwrite_IV,
	output [3:0]phdata,
	
	output phenable_I,
	output phenable_II,
	output phenable_III,
	output phenable_IV,
	
	input [7:0]xorsum_I,
	input [7:0]xorsum_II,
	input [7:0]xorsum_III,
	input [7:0]xorsum_IV,

	input [3:0]phsel_I,
	input [3:0]phsel_II,
	input [3:0]phsel_III,
	input [3:0]phsel_IV,
	
	output reg [6:0]tp_sel_a,
	output reg [6:0]tp_sel_b
);

	reg [3:0]deser_enable;  // deser IV..I enable
	reg gate_single;
	reg gate_enable;
	reg [2:0]gate_period;
	reg [2:0]gate_width;
	reg [3:0]phenable;  // phase detector enable

	assign enable_I   = deser_enable[0];
	assign enable_II  = deser_enable[1];
	assign enable_III = deser_enable[2];
	assign enable_IV  = deser_enable[3];

	assign phenable_I   = phenable[0];
	assign phenable_II  = phenable[1];
	assign phenable_III = phenable[2];
	assign phenable_IV  = phenable[3];

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			gate_single <= 0;
			deser_enable <= 0;
			gate_enable <= 0;
			gate_width <= 0;
			gate_period <= 0;
			phenable <= 0;
			tp_sel_a <= 0;
			tp_sel_b <= 0;
		end
		else
		begin
			if (write)
			begin
				case (address) 
				 4'd0: gate_single <= writedata[0];
				 4'd1: deser_enable <= writedata[3:0];
				 4'd2: {gate_enable, gate_period, gate_width} <= writedata[6:0];
				 4'd3: phenable <= writedata[3:0];
				 4'd8: tp_sel_a <= writedata[6:0];
				 4'd9: tp_sel_b <= writedata[6:0];
				endcase
			end
			else
			begin
				gate_single <= 0;
			end
		end
	end

	reg [3:0]phwrite;
	always @(*)
	begin
		if (write && address == 4'd4)
			phwrite <= writedata[7:4];
		else
			phwrite <= 4'b0000;
	end
	
	assign phwrite_I   = phwrite[0];
	assign phwrite_II  = phwrite[1];
	assign phwrite_III = phwrite[2];
	assign phwrite_IV  = phwrite[3];
	
	assign phdata = writedata[3:0];


	always @(*)
	begin
		case (address)
			4'd5: readdata <= {xorsum_IV, xorsum_III, xorsum_II, xorsum_I};
			4'd6: readdata <= {16'd0, phsel_IV, phsel_III, phsel_II, phsel_I};
			default: readdata <= 32'd0;
		endcase
	end


	gate_generator gategen
	(
		.clk(clk),
		.reset(reset),
		.run(gate_enable),
		.single(gate_single),
		.width(gate_width),
		.periode(gate_period),
		.gate(gate)
	);
 
endmodule



// === gate_generator.v =====================================================

/*
	width: gate length
	  0       200 ns
	  1       800 ns
	  2       3.2 us
	  3      12.8 us
	  4      51.2 us
	  5     204.8 us
	  6       1.6 ms
	  7      26.2 ms
	
	periode: gate rep periode
	  0       800 ns
	  1       3.2 us
	  2      12.8 us
	  3      51.2 us
	  4     204.8 us
	  5       1.6 ms
	  6      13.1 ms
	  7     209.7 ms
*/

module gate_generator
(
	input clk,
	input reset,
	
	input run,
	input single,
	
	input [2:0]width,
	input [2:0]periode,
	
	output gate
);

	// --- frequency divider by 16 for delay counter
	reg [3:0]div_cnt;
	always @(posedge clk or posedge reset)
	begin
		if (reset) div_cnt <= 0;
		else       div_cnt <= div_cnt + 4'd1;
	end
	
	wire div = &div_cnt;

	/* --- delay counter (80 MHz)
	 bit    div       pulse      periode
	  0       1       200 ns(0)   400 ns
	  1       2       400 ns      800 ns(0)
	  2       4       800 ns(1)   1.6 us
	  3       8       1.6 us      3.2 us(1)
	  4      16       3.2 us(2)   6.4 us
	  5      32       6.4 us     12.8 us(2)
	  6      64      12.8 us(3)  25.6 us
	  7     128      25.6 us     51.2 us(3)
	  8     256      51.2 us(4) 102.4 us
	  9     512     102.4 us    204.8 us(4)
	 10    1024     204.8 us(5) 409.6 us
	 11    2048     409.6 us    819.2 us
	 12    4096     819.2 us      1.6 ms(5)
	 13    8192       1.6 ms(6)   3.3 ms
	 14   16384       3.3 ms      6.6 ms
	 15   32768       6.6 ms     13.1 ms(6)
	 16   65536      13.1 ms     26.2 ms
	 17  121972      26.2 ms(7)  52.4 ms
	 18   65536      52.4 ms    104.9 ms
	 19  131972     104.9 ms    209.7 ms(7)
	*/

	wire [19:0]cnt;
	
	lpm_counter	delay_cnt
	(
		.aclr (reset),
		.clock (clk),
		.q (cnt),
		.aload (1'b0),
		.aset (1'b0),
		.cin (1'b1),
		.clk_en (div),
		.cnt_en (1'b1),
		.cout (),
		.data ({20{1'b0}}),
		.eq (),
		.sclr (1'b0),
		.sload (1'b0),
		.sset (1'b0),
		.updown (1'b1)
	);
	defparam
		delay_cnt.lpm_direction = "UP",
		delay_cnt.lpm_port_updown = "PORT_UNUSED",
		delay_cnt.lpm_type = "LPM_COUNTER",
		delay_cnt.lpm_width = 20; 
	
	
	// --- periode p, width w selector
	reg w;
	reg p;

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			w <= 0;
			p <= 0;
		end
		else
		begin
			case (width)
				0: w <= cnt[0];
				1: w <= cnt[2];
				2: w <= cnt[4];
				3: w <= cnt[6];
				4: w <= cnt[8];
				5: w <= cnt[10];
				6: w <= cnt[13];
				7: w <= cnt[17];
			endcase
			case (periode)
				0: p <= cnt[1];
				1: p <= cnt[3];
				2: p <= cnt[5];
				3: p <= cnt[7];
				4: p <= cnt[9];
				5: p <= cnt[12];
				6: p <= cnt[15];
				7: p <= cnt[19];
			endcase
		end
	end


	// --- start signal
	wire start_loop;
	wire start_ext;
	reg  start_req;
	wire start;

	gg_pedge loop(clk, reset, p,      start_loop);
	gg_pedge ext (clk, reset, single, start_ext );

	always @(posedge clk or posedge reset)
	begin
		if (reset) start_req <= 0;
		else if (start_ext) start_req <= 1;
		else if (!w)        start_req <= 0;
	end
	
	assign start = (start_loop && run) || (start_req && !w);


	// --- pulse generator
	reg [1:0]sm; // pulse state machine

	always @(posedge clk or posedge reset)
	begin
		if (reset) sm <= 2'b00;
		else
		begin
			case (sm)
				2'b00: if (start) sm <= 2'b01;
				2'b01: if (w)     sm <= 2'b10;
				2'b10: if (!w)    sm <= 2'b00;
			endcase
		end
	end

	assign gate = sm[1];

endmodule



module gg_pedge
(
	input clk,
	input reset,
	input in,
	output reg pulse
);
	reg del;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset) {pulse, del} <= 2'b00;
		else {pulse, del} <= {in && !del, in};
	end

endmodule
