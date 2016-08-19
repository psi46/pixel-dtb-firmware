// trigger_delay.v

`timescale 1 ns / 1 ps


module trigger_delay #(parameter N=3)
(
	input clk,
	input sync,
	input reset,

	input [7:0]delay,
	
	input trg_in,
	input [(N-1):0]data_in,
	
	output reg trg_out,
	output reg [(N-1):0]data_out
);

  // time stamp counter
	reg [7:0]t;
	always @(posedge clk or posedge reset)
	begin
		if (reset) t <= 0;
		else if (sync) t <= t + 8'd1;
	end

	wire empty;
	wire [7:0]tq;
	wire [(N-1):0]dout;
	wire write = trg_in && sync;
	wire hit   = tq == (t - delay);
	wire read  = hit && sync;
	
	always @(posedge clk or posedge reset)
	begin
    if (reset)
    begin
      trg_out  <= 0;
      data_out <= 0;
    end
    else if (sync)
    begin
      if (!empty)
      begin
        trg_out  <= hit;
        data_out <= dout;
      end
      else
      begin
        trg_out  <= 0;
        data_out <= 0;
      end
    end
	end
	


	scfifo
	#(
		.add_ram_output_register("OFF"),
		.intended_device_family("Cyclone III"),
		.lpm_numwords(256),
		.lpm_showahead("ON"),
		.lpm_type("scfifo"),
		.lpm_width(N+8),
		.lpm_widthu(8),
		.overflow_checking("ON"),
		.underflow_checking("ON"),
		.use_eab("ON")
	) fifo
	(
		.aclr (reset),
		.clock (clk),
		.data ({data_in, t}),
		.rdreq (read),
		.wrreq (write),
		.empty (empty),
		.q ({dout, tq}),
		.almost_empty (),
		.almost_full (),
		.full (),
		.sclr (),
		.usedw ()
	);

endmodule
