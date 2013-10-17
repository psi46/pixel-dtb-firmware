// deser160_sampling.v

`timescale 1ns / 1ps


module deser160_sampling
(
	input clk,
	input sync,
	input reset,
	
	input sclk0,
	input sclk180,
	
	input sdata,
	output reg [3:0]data
);
	// sclk register
	reg sin0, sin180;
	reg [2:0]del;

	// clk register
	reg [3:0]pdata;
	
	always @(posedge sclk180 or posedge reset)
	begin
		if (reset) sin180 <= 0;
		else sin180 <= sdata;
	end

	always @(posedge sclk0 or posedge reset)
	begin
		if (reset)
		begin
			sin0 <= 0;
			del  <= 3'b000;
		end
		else
		begin
			sin0 <= sdata;
			del  <= { del[1:0], sin180 };
		end
	end

	always @(posedge clk or posedge reset)
	begin
		if (reset) pdata <= 0;
		else
		begin
			if (sync) pdata[1:0] = { del[2], sin0 };
			else      pdata[3:2] = { del[2], sin0 };
		end
	end

	always @(posedge clk or posedge reset)
	begin
		if (reset) data <= 0;
		else	if (sync) data <= pdata;
	end
	
endmodule
