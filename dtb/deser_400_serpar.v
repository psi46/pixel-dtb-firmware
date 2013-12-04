//deser400_serpar.v

`timescale 1ns / 1ps

module deser400_serpar
(
	//input clk,
	input clk160,
	input reset,
	input run,
	
	input ser_a,
	input ser_b,
	
	output reg [15:0] par_a,
	output reg [15:0] par_b,
	output reg write_a,
	output reg write_b,
	output reg [9:0] test
);

// data shift register

reg [15:0]d_a;
reg [15:0]d_b;


always @(posedge clk160 or posedge reset)
begin
	if (reset)
	begin
		d_a <= 0;
		d_b <= 0;
	end
	else
	begin	
		d_a <= {d_a[14:0],ser_a};
		d_b <= {d_b[14:0],ser_b};
	end
end

// state machine

reg [3:0]state;

always @(posedge clk160 or posedge reset)
begin
	if (reset) state <= 0;
	else
		begin
			case (state)
				0: state <=1;
				1: state <=2;
				2: state <=3;
				3: state <=4;
				4: state <=5;
				5: state <=6;
				6: state <=7;
				7: state <=8;
				8: state <=9;
				9: state <=10;
				10: state <=11;
				11: state <=12;
				12: state <=13;
				13: state <=14;
				14: state <=15;
				15: state <=0;
			endcase
		end
	end
	
always @(posedge clk160 or posedge reset)
begin

	test[0] <= ser_a;
	test[1] <= ser_b;

	if (reset)
		begin
				par_a <= 0;
				par_b <= 0;
		end
		else
			//if (run && (state == 15))
			if (state == 15)
			begin
				par_a <= d_a;
				par_b <= d_b;
			end
end

always @(posedge clk160 or posedge reset)
begin
   if (reset ) 
	begin	
		write_a <= 0;
		write_b <= 0;
	end		
		else 
		begin
			write_a <= (state == 0) & run & (par_a != 16'b1111111111111111);
			write_b <= (state == 0) & run & (par_b != 65535) ; // Supress IDLE
		end
end

endmodule