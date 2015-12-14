# clocks.sdc


# --- create base clocks
create_clock -name "clk50"     -period 20.000ns [get_ports {clk50}]
create_clock -name "clk40_ext" -period 25.000ns [get_ports {UIO_clk}]
create_clock -name "usb_clk"   -period 16.667ns [get_ports {USB_clk}]

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty


set_clock_groups \
  -asynchronous \
  -group { clk50 \
     inst14|inst23|altpll_component|auto_generated|pll1|clk[4] \
     inst14|inst3|altpll_component|auto_generated|pll1|clk[0] \
     inst14|inst3|altpll_component|auto_generated|pll1|clk[1] \
     inst14|inst3|altpll_component|auto_generated|pll1|clk[2] \
     inst14|inst3|altpll_component|auto_generated|pll1|clk[3] \
     inst14|inst5|altpll_component|auto_generated|pll1|clk[0] \
     inst14|inst23|altpll_component|auto_generated|pll1|clk[1] \
     inst14|inst23|altpll_component|auto_generated|pll1|clk[4] \
   } \
   -group { clk40_ext \
     inst14|inst3|altpll_component|auto_generated|pll1|clk[0]~1 \
     inst14|inst3|altpll_component|auto_generated|pll1|clk[1]~1 \
     inst14|inst3|altpll_component|auto_generated|pll1|clk[2]~1 \
     inst14|inst3|altpll_component|auto_generated|pll1|clk[3]~1 \
     inst14|inst5|altpll_component|auto_generated|pll1|clk[0]~1 \
   } \
   -group { usb_clk }
