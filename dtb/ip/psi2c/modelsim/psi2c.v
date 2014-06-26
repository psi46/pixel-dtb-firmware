// psi2c.v


module psi2c
(
	// avalon clock interface
	input csi_clock_clk,
	input csi_clock_reset,
	
	// avalon mm slave
	input   [2:0]avs_ctrl_address,
	input        avs_ctrl_read,
	output [31:0]avs_ctrl_readdata,
	input        avs_ctrl_write,
	input  [31:0]avs_ctrl_writedata,
	
	// conduit
	input  sync,
	input  phase,
	output send,
	output sda,
	input  rda
);

wire	go;
wire	empty;
wire	[11:0] dout;
wire	[11:0] din;
wire	full;
wire	[31:0]rda_data;
wire	wr;


psi2c_bitsend	bitsend(
	.clk(csi_clock_clk),
	.reset(csi_clock_reset),
	.sync(sync),
	.go(go),
	.empty(empty),
	.phase(phase),
	.d(dout),
	.rd(rd),
	.busy(send),
	.sda(sda)
);


psi2c_readback	readback
(
	.go(tbm & go),
	.clk(csi_clock_clk),
	.reset(csi_clock_reset),
	.sync(sync),
	.sync2(phase),
	.rda(rda),
	.i2c_send(send),
	.d(rda_data)
);


i2c_control	control
(
	.clk(csi_clock_clk),
	.reset(csi_clock_reset),

	.busy(send),
	.write(avs_ctrl_write),
	.read(avs_ctrl_read),
	.full(full),
	
	.address(avs_ctrl_address),
	.rda(rda_data),
	.writedata(avs_ctrl_writedata),
	.memw(wr),
	.go(go),
	.tbm(tbm),
	.memd(din),
	.readdata(avs_ctrl_readdata)
);

psi2c_fifo	fifo
(
	.clock (csi_clock_clk),
	.aclr (csi_clock_reset),
	.data (din),
	.rdreq (rd),
	.wrreq (wr),
	.empty (empty),
	.full (full),
	.q (dout)
);
	
endmodule
