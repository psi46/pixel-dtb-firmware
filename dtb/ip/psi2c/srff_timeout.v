// srff_timeout.v

`timescale 1 ps / 1 ps


module srff_timeout
(
	input clk,
	input sync,
	input reset,

	input to_disable,
	input s,
	input r,
	output reg q,
	output reg to
);

reg [4:0]timeout_counter;
wire timeout = timeout_counter == 5'd1;

always @(posedge clk or posedge reset)
begin
	if (reset)
	begin
    q  <= 0;
    to  <= 0;
  end
	else
	begin
		if (r || timeout) q <= 0;
		else if (s) q <= 1;

    if (s) to <= 0; else if (timeout) to <= 1;
	end
end

always @(posedge clk or posedge reset)
begin
	if (reset) timeout_counter <= 0;
	else if (sync)
		timeout_counter <= (q && !to_disable) ? timeout_counter - 5'd1 : 5'd0;
end

endmodule
