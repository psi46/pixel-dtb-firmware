// dtb.v

module dtb
(
// where to connect ???
  input           reset_n,
  input           clkin_125,

// --- EPCS
  output EPCS_DCLK,
  output EPCS_nCSO,
  output EPCS_ASDO,
  input  EPCS_DATA0,

// --- 40 MHz clock oscillator input
  input   clk40,

// --- ROC control
  output   Chip_HV,      // High Voltage on
  output   Chip_reset_n, // ROC Reset disable (open drain)
  output   Chip_term,    // Termination 1=LCDS, 0=LVDS
  output [0:3] Chip_addr,// ROC address select (opendrain)

// ---  
 //(* altera_attribute = "-name IO_STANDARD \"2.5-V\"" *)(* chip_pin = "B15" *)
  output Power_run,    // VA/VD on
  inout    Power_scl,    // DAC/ADC
  inout    Power_sda,    // DAC/ADC

// --- to ROC/Module interfaces (SCSI cable)
  inout        Plug_scl2, // I2C extern
  inout        Plug_sda2, // I2C extern
  input  [0:7] Plug_IOs,

  input  [0:1] Switches,
  output [0:3] LEDs,

 // --- Cross Point Switch
  output   CPS_clk,
  output   CPS_ce_n,
  output   CPS_datain,
  input    CPS_dataout,
  output   CPS_reset_n,
  output   CPS_update_n,

// --- ROC/Module interface
  output  LVDS2LCDS_clk,  // LVDS
  output  LVDS2LCDS_ctr,  // LVDS
  output  LVDS2LCDS_sda,  // LVDS
  output  LVDS2LCDS_tin,  // LVDS
  input   LVDS2LCDS_tout,    // tout/RDA  // LVDS
  input   LVDS2LCDS_sdata_I,  // LVDS
  input   LVDS2LCDS_sdata_II,  // LVDS

  output  LVDS2LCDS_reset_n,
  output  LVDS2LCDS_scl,
  output  LVDS2LCDS_sdi,
  input   LVDS2LCDS_sdo,
  output  LVDS2LCDS_sld,

// --- ADC
  output        ADC_clk, // ADC clock  // LVDS
  input         ADC_dco, // Data clock output
  output        ADC_pdwn,// ADC power down
  input  [0:11] ADC_data,// data
  input         ADC_or,  // overrange
  
// --- DDR2 RAM  
  inout         RAM_clk,
  inout         RAM_clk_n,
  output        RAM_cke,

  output        RAM_cs_n,
  output        RAM_ras_n,
  output        RAM_cas_n,
  output        RAM_we_n,

  output        RAM_odt,
  output [0:12] RAM_addr,
  output [0:1]  RAM_ba,
  output [0:3]  RAM_dm,
  inout  [0:31] RAM_dq,
  inout  [0:3]  RAM_dqs,

// --- USB interface
  input        USB_clk,  // clock
  output       USB_rd_n, // !read
  output       USB_wr_n, // !write
  input        USB_rxf_n,// !receiver full
  input        USB_txe_n,// !transmitter empty
  output       USB_siwua,// send immediate/wake up
  output       USB_oe_n, // output enable
  inout  [0:7] USB_data, // data bus
 
// --- Marvell 88E1111 Gigabit Ethernet
  output       Ethernet_gtx_clk,
  output [0:3] Ethernet_txd,
  output       Ethernet_tx_en,
  
  input        Ethernet_rx_clk,
  input  [0:3] Ethernet_rxd,
  input        Ethernet_rx_dv,
  
  input        Ethernet_int_n,
  output       Ethernet_mdc,
  inout        Ethernet_mdio,
  output       Ethernet_reset_n,

// --- Micro SD Card  
  output   SD_clk,
  output   SD_cs,
  output   SD_mosi,
  input    SD_miso,
  input    SD_cd,   // card detect

// --- Cyclic Redundance Check
  input    CRC_error_in,

// --- external clock & general purpose IO (LEMO)
  input   UI_clk,
  inout   UI_GPIO0,
  inout   UI_GPIO1,
  inout   UI_GPIO2,

 // --- User Interface IOs (spares)
  inout [0:15] UI_IOs
);

// --- Chip -----------------------------------------------------------------
  assign  Chip_HV      = 1'b0;     // High Voltage on
  assign  Chip_reset_n = 1'bx;     // ROC Reset disable
  assign  Chip_term    = 1'b0;     // LVDS Termination
  assign  Chip_addr    = 4'b0000;  // ROC address select

// --- Power control --------------------------------------------------------
  assign  Power_run = 1'b0;
  assign  Power_scl = 1'bz;
  assign  Power_sda = 1'bz;

  assign  Plug_scl2 = 1'bz;
  assign  Plug_sda2 = 1'bz;

 // --- Cross point switch --------------------------------------------------
  assign  CPS_clk      = 1'b0;
  assign  CPS_ce_n     = 1'b1;
  assign  CPS_datain   = 1'b0;
  assign  CPS_reset_n  = 1'b0;
  assign  CPS_update_n = 1'b1;

// --- ROC/Module interface -------------------------------------------------
  assign  LVDS2LCDS_clk = 1'b0;
  assign  LVDS2LCDS_ctr = 1'b0;
  assign  LVDS2LCDS_sda = 1'b0;
  assign  LVDS2LCDS_tin = 1'b0;

  assign  LVDS2LCDS_reset_n = 1'b0;
  assign  LVDS2LCDS_scl     = 1'b0;
  assign  LVDS2LCDS_sdi     = 1'b0;
  assign  LVDS2LCDS_sld     = 1'b0;

// --- ADC ------------------------------------------------------------------
  assign  ADC_clk   = 1'b0;   // ADC clock
  assign  ADC_pdwn  = 1'b1;  // ADC power down
  
// --- USB interface --------------------------------------------------------
  assign  USB_rd_n  = 1'b1;  // !read
  assign  USB_wr_n  = 1'b1;  // !write
  assign  USB_siwua = 1'b0;  // send immediate/wake up
  assign  USB_oe_n  = 1'b1;  // output enable
  assign  USB_data  = 8'hzz; // data bus
 
// --- Micro SD Card --------------------------------------------------------
  assign  SD_clk  = 1'b0;
  assign  SD_cs   = 1'b0;
  assign  SD_mosi = 1'b0;

// --- User IO (LEMO) -------------------------------------------------------
  assign  UI_GPIO0 = 1'bz;
  assign  UI_GPIO1 = 1'bz;
  assign  UI_GPIO2 = 1'bz;

 // --- User IOs (spares) ---------------------------------------------------
  assign UI_IOs = 16'hzzzz;

// --- Ethernet interface assignments ---------------------------------------
  wire   mdio_in;
  wire   mdio_oen;
  wire   mdio_out;

  wire   eth_mode;
  wire   ena_10;

  wire   tx_clk;
  wire   enet_tx_125;
  wire   enet_tx_25;
  wire   enet_tx_2p5;

  assign mdio_in = Ethernet_mdio;
  assign Ethernet_mdio = mdio_oen == 0 ? mdio_out : 1'bz;

  assign Ethernet_reset_n  =   reset_n;

  altddio_out altddio_out_component
  (
    .outclock ( tx_clk ),
    .dataout ( Ethernet_gtx_clk ),
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

  assign tx_clk = (eth_mode) ? (enet_tx_125) :  // GbE Mode = 125MHz clock
                  (ena_10)   ? (enet_tx_2p5) :  // 10Mb Mode = 2.5MHz clock
                               (enet_tx_25);    // 100Mb Mode = 25MHz clock

  enet_pll enet_pll_inst
  (
	  .areset (!reset_n),
     .inclk0 (clkin_125),
     .c0 (enet_tx_125),
     .c1 (enet_tx_25),
     .c2 (enet_tx_2p5),
     .locked ()
  );


// --- QSYS system instantiation --------------------------------------------

  dtb_system dtb_sys 
  (
    .clkin_50                         (clk40),
    .reset_n                          (reset_n),

    .sdram_aux_full_rate_clk_out      (),
    .sdram_phy_clk_out                (),
    .sdram_aux_half_rate_clk_out      (),
  
    // ddr2 sdram
    .sdram_reset_n                    (reset_n),
    .local_init_done_from_the_sdram   (),
    .local_refresh_ack_from_the_sdram (),
    .local_wdata_req_from_the_sdram   (),
    .mem_addr_from_the_sdram          (RAM_addr),
    .mem_ba_from_the_sdram            (RAM_ba),
    .mem_cas_n_from_the_sdram         (RAM_cas_n),
    .mem_cke_from_the_sdram           (RAM_cke),
    .mem_clk_n_to_and_from_the_sdram  (RAM_clk_n),
    .mem_clk_to_and_from_the_sdram    (RAM_clk),
    .mem_cs_n_from_the_sdram          (RAM_cs_n),
    .mem_dm_from_the_sdram            (RAM_dm),
    .mem_dq_to_and_from_the_sdram     (RAM_dq),
    .mem_dqs_to_and_from_the_sdram    (RAM_dqs),
    .mem_odt_from_the_sdram           (RAM_odt),
    .mem_ras_n_from_the_sdram         (RAM_ras_n),
    .mem_we_n_from_the_sdram          (RAM_we_n),
    .reset_phy_clk_n_from_the_sdram   (),

    // tse mac
    .ena_10_from_the_tse_mac          (ena_10),
    .eth_mode_from_the_tse_mac        (eth_mode),
    .mdc_from_the_tse_mac             (Ethernet_mdc),
    .mdio_in_to_the_tse_mac           (mdio_in),
    .mdio_oen_from_the_tse_mac        (mdio_oen),
    .mdio_out_from_the_tse_mac        (mdio_out),
    .rgmii_in_to_the_tse_mac          (Ethernet_rxd),
    .rgmii_out_from_the_tse_mac       (Ethernet_txd),
    .rx_clk_to_the_tse_mac            (Ethernet_rx_clk),
    .rx_control_to_the_tse_mac        (Ethernet_rx_dv),
    .set_1000_to_the_tse_mac          (),
    .set_10_to_the_tse_mac            (),
    .tx_clk_to_the_tse_mac            (tx_clk),
    .tx_control_from_the_tse_mac      (Ethernet_tx_en),

    // epcs
    .epcs_dclk                        (EPCS_DCLK),
    .epcs_sce                         (EPCS_nCSO),
    .epcs_sdo                         (EPCS_ASDO),
    .epcs_data0                       (EPCS_DATA0),
		  
    // button pio
    .in_port_to_the_button_pio        (Switches),
  
    // led pio
    .out_port_from_the_led_pio        (LEDs)
  );


endmodule
