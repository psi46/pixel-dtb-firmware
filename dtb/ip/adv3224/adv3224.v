module adv3224 (

	// avalon-bus
	input clk,
	input reset,

	input            avs_slave_write,
	input            avs_slave_read,
	input       [7:0]avs_slave_writedata,
	output      [7:0]avs_slave_readdata,
	input       [2:0]avs_slave_address,

	// adv3224
	output           cps_reset_n,
	output           cps_ce_n,
	output           cps_update_n,
	output           cps_clk,
	output           cps_datain
);

	//
	// parameters
	//
	parameter        divider = 5;

	//
	// regs / wires
	//
	reg         [8:0]clk_counter;
	reg              div_clk;
	reg              clk_en;
	reg        [39:0]shift_buffer;
	reg              shift_busy;
	reg         [5:0]shift_counter;
	reg         [4:0]outputs[0:7];

	//
	// ip
	//
	assign cps_reset_n        = !reset;
	assign cps_ce_n           = 0;
	assign avs_slave_readdata = shift_busy;
	assign cps_clk            = clk_en ? div_clk : 1;
	assign cps_update_n       = (!clk_en && shift_busy) ? !div_clk : 1;
	assign cps_datain         = shift_buffer[39];

	always @(posedge clk or posedge reset)
	begin
	
		if(reset)
		begin
		
			clk_counter   <= 1;
			div_clk       <= 1;
			clk_en        <= 0;
			shift_busy    <= 0;
			shift_counter <= 0;
			outputs[0]    <= 5'b00000;
			outputs[1]    <= 5'b00000;
			outputs[2]    <= 5'b00000;
			outputs[3]    <= 5'b00000;
			outputs[4]    <= 5'b00000;
			outputs[5]    <= 5'b00000;
			outputs[6]    <= 5'b00000;
			outputs[7]    <= 5'b00000;

		end
		else
		begin	// posedge clk

			if(shift_busy)
			begin
			
				if(clk_counter == (divider/2))
				begin
					clk_counter <= 1;
					div_clk     <= !div_clk;
					if(!div_clk)
					begin
						
						if(!clk_en)
						begin
							shift_busy <= 0;
						end
						else
						begin
							if(shift_counter == 39)
							begin
								clk_en        <= 0;
							end
							else
							begin
								shift_counter <= shift_counter + 1;
								shift_buffer  <= shift_buffer << 1;
							end
						end
					end
				end
				else
				begin
					clk_counter = clk_counter + 1;
				end
			
			end
			else
			begin
			
				clk_counter   <= 1;
				shift_counter <= 0;
				div_clk       <= 1;
				if(avs_slave_write)
				begin
					if(avs_slave_writedata[7])
					begin
						shift_buffer <= {outputs[7], outputs[6], outputs[5], outputs[4], outputs[3], outputs[2], outputs[1], outputs[0]};
						shift_busy   <= 1;
						clk_en       <= 1;
					end
					else
					begin
						outputs[avs_slave_address] <= {!avs_slave_writedata[4], avs_slave_writedata[3:0]};
					end

				end
			
			end

		end
	end

endmodule