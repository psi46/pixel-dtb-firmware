// patterngenerator.v

`timescale 1ns / 1ps


module patterngenerator
(
	// avalon clock interface
	input csi_clock_clk,
	input csi_clock_reset,

 	// avalon mm slave: status/control
	input        avs_ctrl_address,
	input        avs_ctrl_read,
	output [31:0]avs_ctrl_readdata,
	input        avs_ctrl_write,
	input  [31:0]avs_ctrl_writedata,

 	// avalon mm slave: command memory
	input   [7:0]avs_data_address,
	input        avs_data_write,
	input   [1:0]avs_data_byteenable,
	input  [15:0]avs_data_writedata,

	// pattern generator interface
	input clkena,
	input trigger,
	output [4:0]pgout
);

  /* avalon 16 bit register file
    0   w  control register
    0   r  status register
    1   w  period register
 
    control register:
    bit 7: enable pattern generator
    bit 2: enable loop
    bit 1: enable external trigger
    bit 0: start single sequence
  */

	// control regisdter bits
	reg ctrl_ena;
	reg ctrl_ext;
	reg ctrl_loop;
	reg ctrl_start;

	wire start;
	wire enable;
	wire ena_loop;
	wire ena_ext;
	wire set_start;

	wire running;
  
	reg [15:0]period;
	reg [15:0]loopcnt;
  
	wire  [7:0]seq_address;
	wire [15:0]seq_command;

	
	// --- control register programming ---------------------------------------
	always @(posedge csi_clock_clk or posedge csi_clock_reset)
	begin
		if (csi_clock_reset)
		begin
			{ ctrl_ena, ctrl_loop, ctrl_ext, ctrl_start } <= 4'b0000;
			period   <= 0;
		end
		else if (avs_ctrl_write)
		begin
			case (avs_ctrl_address)
				0: { ctrl_ena, ctrl_loop, ctrl_ext, ctrl_start }
						<= { avs_ctrl_writedata[7], avs_ctrl_writedata[2:0] };
				1: period   <= avs_ctrl_writedata[15:0];
			endcase
		end
		else if (clkena) ctrl_start <= 0;
	end

	assign avs_ctrl_readdata =
		avs_ctrl_address ? { 16'd0, period } : { 31'd0, running };

	assign enable    = ctrl_ena;
	assign ena_ext   = ctrl_ext;
	assign ena_loop  = ctrl_loop;
	assign set_start = ctrl_start;
	
	// --- trigger generator --------------------------------------------------
	wire trig_loop = loopcnt == 0;
  
	always @(posedge csi_clock_clk or posedge csi_clock_reset)
	begin
		if (csi_clock_reset) loopcnt <= 0;
		else if (clkena)
		begin
			if (ena_loop)
			begin
				if (trig_loop) loopcnt <= period;	else loopcnt <= loopcnt - 1;
			end
			else loopcnt <= 0;
		end
	end

	assign start = set_start || (ena_loop && trig_loop) || (ena_ext && trigger);


	pg_ram ram
	(
		// avalon port
		.clock     (csi_clock_clk),
		.wren      (avs_data_write),
		.wraddress (avs_data_address),
		.byteena_a (avs_data_byteenable),
		.data      (avs_data_writedata),

		// pattern generator port
		.rdaddress (seq_address),
		.q (seq_command)
	);


	pg_sequencer pg
	(
		.clk(csi_clock_clk),
		.sync(clkena),
		.reset(csi_clock_reset),
		.enable(enable),
		.start(start),
		.running(running),
		.pgout(pgout),

		.ip(seq_address),
		.cmd(seq_command)
	);

endmodule
