// eventsim.v

/*
	data words:
	15:    start
	14:    end
	13..0: datavalue
	
	trigger[3]: data = 0 (pg_resr)
	trigger[2]: start (pg_cal)
	trigger[1]: data (pg_tin)
	trigger[0]: end (pg_trg)
*/

module eventsim
(
	input clk,
	input reset,

	// avalon mm ctrl slave
	input avs_ctrl_write,
	input [31:0]avs_ctrl_writedata,
	input avs_ctrl_address,

	// data generator
	input sync,
	input [3:0]trigger,
	output reg enable,
	output write,
	output [15:0]data
);

	reg [13:0]count;

	assign write = (|trigger[2:0]) && sync && enable;
	assign data = {trigger[2], trigger[1], count};

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			enable <= 0;
			count  <= 0;
		end
		else
		begin
			if (avs_ctrl_write)
			begin
				if (avs_ctrl_address)
				begin
					if (!enable) count <= avs_ctrl_writedata[13:0];
				end
				else enable <= avs_ctrl_writedata[0];
			end

			if (enable && sync)
			begin
				if (trigger[3]) count <= 0;
				else if (write) count <= count + 1;
			end
		end
	end


endmodule
