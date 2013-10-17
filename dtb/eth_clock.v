// eth_clock.v



module eth_clock
(
  input enet_tx_125,
  input enet_tx_25,
  input enet_tx_2p5,
  
  input reset_n,
  input eth_mode,  // gigabit ethernet mode
  input ena_10,    // 10mb mode

  output tx_clk,
  output gtx_clk

 );

  assign tx_clk = (eth_mode) ? (enet_tx_125) :  // GbE Mode = 125MHz clock
                  (ena_10)   ? (enet_tx_2p5) :  // 10Mb Mode = 2.5MHz clock
                               (enet_tx_25);    // 100Mb Mode = 25MHz clock


  altddio_out altddio_out_component
  (
    .outclock ( tx_clk ),
    .dataout ( gtx_clk ),
    .aclr (!reset_n),
    .datain_h (1'b1),
    .datain_l (1'b0),
    .outclocken (1'b1),
    .aset (1'b0),
    .sclr (1'b0),
    .sset (1'b0),
    .oe_out (),
    .oe (1'b1)
  );
  defparam
    altddio_out_component.extend_oe_disable = "UNUSED",
    altddio_out_component.intended_device_family = "Cyclone III",
    altddio_out_component.invert_output = "OFF",
    altddio_out_component.lpm_type = "altddio_out",
    altddio_out_component.oe_reg = "UNUSED",
    altddio_out_component.width = 1;
  
endmodule
