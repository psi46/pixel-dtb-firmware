//deser400_serpar.v

`timescale 1ns / 1ps

module deser400_serpar
(
	input clk,
	input clk400,
	input reset,
	input run,
	
	input ser_a,
	input ser_b,
	
	output reg [15:0] par_a,
	output reg [15:0] par_b,
	output reg write
);

// data shift register

reg [15:0]d_a;
reg [15:0]d_b;

always @(posedge clk400 or posedge reset)
begin
	if (reset)
	begin
		d_a <= 0;
		d_b <= 0;
	end
	else
		d_a[15] <= d_a[14];
		d_a[14] <= d_a[13];
		d_a[13] <= d_a[12];
		d_a[12] <= d_a[11];
		d_a[11] <= d_a[10];
		d_a[10] <= d_a[9];
		d_a[9] <= d_a[8];
		d_a[8] <= d_a[7];
		d_a[7] <= d_a[6];
		d_a[6] <= d_a[5];
		d_a[5] <= d_a[4];
		d_a[4] <= d_a[3];
		d_a[3] <= d_a[2];
		d_a[2] <= d_a[1];
		d_a[1] <= ser_a;
		
		d_b[15] <= d_b[14];
		d_b[14] <= d_b[13];
		d_b[13] <= d_b[12];
		d_b[12] <= d_b[11];
		d_b[11] <= d_b[10];
		d_b[10] <= d_b[9];
		d_b[9] <= d_b[8];
		d_b[8] <= d_b[7];
		d_b[7] <= d_b[6];
		d_b[6] <= d_b[5];
		d_b[5] <= d_b[4];
		d_b[4] <= d_b[3];
		d_b[3] <= d_b[2];
		d_b[2] <= d_b[1];
		d_b[1] <= ser_b;
end

// state machine

reg [15:0]state;

always @(posedge clk400 or posedge reset)
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
	
always @(posedge clk400 or posedge reset)
begin
	if (reset)
		begin
			par_a <= 0;
			par_b <= 0;
		end
		else
			if (run && (state == 15))
				par_a <= d_a;
				par_b <= d_b;
end

always @(posedge clk400 or posedge reset)
begin
   if (reset) write <= 0;
   else write <= (state == 0);
end

endmodule