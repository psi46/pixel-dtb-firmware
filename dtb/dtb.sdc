#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 13.1.0 Build 162 10/23/2013 SJ Full Version
#
#************************************************************

# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints

create_clock -name "clk50"     -period 20.000ns [get_ports {clk50}]
create_clock -name "clk40_ext" -period 25.000ns [get_ports {UIO_clk}]
create_clock -name "usb_clk"   -period 16.667ns [get_ports {USB_clk}]


create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]~1} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {UIO_clk} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[1]~1} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {UIO_clk} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[1]}] -add
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[1]}] -add
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[2]~1} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {UIO_clk} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[2]}] -add
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[2]}] -add
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[3]~1} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 8 -master_clock {UIO_clk} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[3]}] -add
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[3]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]~1} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 10 -master_clock {UIO_clk} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]~1} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 10 -phase 45.000 -master_clock {UIO_clk} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 45.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]~1} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 10 -phase 90.000 -master_clock {UIO_clk} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 90.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]~1} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 10 -phase 135.000 -master_clock {UIO_clk} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 135.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]}] -add

set_clock_groups -exclusive \
	-group {inst14|inst5|altpll_component|auto_generated|pll1|clk[*] inst14|inst5|altpll_component|auto_generated|pll1|clk[*]} \
	-group {inst14|inst3|altpll_component|auto_generated|pll1|clk[*]~1 inst14|inst5|altpll_component|auto_generated|pll1|clk[*]~1}

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks



# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints
set_input_delay -clock "usb_clk" -max 9.67ns [get_ports {USB_data[*]}]
set_input_delay -clock "usb_clk" -min 0.000ns [get_ports {USB_data[*]}]

# tco constraints
set_output_delay -clock "usb_clk" -max 7.5ns [get_ports {USB_data[*]}]
set_output_delay -clock "usb_clk" -min -0.000ns [get_ports {USB_data[*]}]

set_output_delay -clock "usb_clk" -max 7.5ns [get_ports {USB_oe_n}]
set_output_delay -clock "usb_clk" -max 7.5ns [get_ports {USB_rd_n}]
set_output_delay -clock "usb_clk" -max 7.5ns [get_ports {USB_wr_n}]


# tpd constraints

set_multicycle_path \
	-from {deser400_PSI:instDESER400_*|lpm_dff0:inst487|lpm_ff:|lpm_ff_component|dffs[*]} \
	-to   {deser400_PSI:instDESER400_*|NRZI_decoder:inst4003|OUT_5b_o[*]} \
	-setup -end 3

set_false_path -from {dtb_system:inst|delay_out:delay_*|ext_mode[*]} -to {*}
set_false_path -from {dtb_system:inst|delay_out:delay_*|delr[*]} -to {*}
set_false_path -from {dtb_system:inst|delay_out:delay_*|delf[*]} -to {*}
set_false_path -from {dtb_system:inst|delay_out:delay_*|ext_sel} -to {*}

set_false_path -from {dtb_system:inst|dtb_system_main_control:main_control|data_out[*]}
	
# report_path -from [get_ports {LVDS2LCDS_sdata_*}] -npaths 40 -panel_name {SDATA delay}

write_sdc -expand "dtb_report.sdc"
