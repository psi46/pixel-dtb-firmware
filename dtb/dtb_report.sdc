## Generated SDC file "dtb_report.sdc"

## Copyright (C) 1991-2014 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.1.4 Build 182 03/12/2014 SJ Full Version"

## DATE    "Fri Sep 30 09:07:03 2016"

##
## DEVICE  "EP3C40F484C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clk50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk50}]
create_clock -name {clk40_ext} -period 25.000 -waveform { 0.000 12.500 } [get_ports {UIO_clk}]
create_clock -name {usb_clk} -period 16.667 -waveform { 0.000 8.333 } [get_ports {USB_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {inst14|inst23|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 5 -divide_by 2 -master_clock {clk50} [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} -source [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -divide_by 5 -master_clock {clk50} [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]}] 
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]~1} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {clk40_ext} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -divide_by 2 -master_clock {clk50} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -master_clock {clk50} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -phase -90.000 -master_clock {clk50} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -master_clock {clk50} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[4]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -master_clock {clk50} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[4]}] 
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]~1} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 10 -master_clock {clk40_ext} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]~1} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 10 -phase 45.000 -master_clock {clk40_ext} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 45.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]~1} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 10 -phase 90.000 -master_clock {clk40_ext} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 90.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]~1} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 10 -phase 135.000 -master_clock {clk40_ext} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]}] -add
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 135.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]}] -add


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {usb_clk}]  9.670 [get_ports {USB_data[0]}]
set_input_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[0]}]
set_input_delay -add_delay -max -clock [get_clocks {usb_clk}]  9.670 [get_ports {USB_data[1]}]
set_input_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[1]}]
set_input_delay -add_delay -max -clock [get_clocks {usb_clk}]  9.670 [get_ports {USB_data[2]}]
set_input_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[2]}]
set_input_delay -add_delay -max -clock [get_clocks {usb_clk}]  9.670 [get_ports {USB_data[3]}]
set_input_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[3]}]
set_input_delay -add_delay -max -clock [get_clocks {usb_clk}]  9.670 [get_ports {USB_data[4]}]
set_input_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[4]}]
set_input_delay -add_delay -max -clock [get_clocks {usb_clk}]  9.670 [get_ports {USB_data[5]}]
set_input_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[5]}]
set_input_delay -add_delay -max -clock [get_clocks {usb_clk}]  9.670 [get_ports {USB_data[6]}]
set_input_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[6]}]
set_input_delay -add_delay -max -clock [get_clocks {usb_clk}]  9.670 [get_ports {USB_data[7]}]
set_input_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[7]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_data[0]}]
set_output_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[0]}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_data[1]}]
set_output_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[1]}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_data[2]}]
set_output_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[2]}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_data[3]}]
set_output_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[3]}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_data[4]}]
set_output_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[4]}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_data[5]}]
set_output_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[5]}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_data[6]}]
set_output_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[6]}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_data[7]}]
set_output_delay -add_delay -min -clock [get_clocks {usb_clk}]  0.000 [get_ports {USB_data[7]}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_oe_n}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_rd_n}]
set_output_delay -add_delay -max -clock [get_clocks {usb_clk}]  7.500 [get_ports {USB_wr_n}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks { clk50  inst14|inst23|altpll_component|auto_generated|pll1|clk[4]  inst14|inst3|altpll_component|auto_generated|pll1|clk[0]  inst14|inst3|altpll_component|auto_generated|pll1|clk[1]  inst14|inst3|altpll_component|auto_generated|pll1|clk[2]  inst14|inst3|altpll_component|auto_generated|pll1|clk[3]  inst14|inst5|altpll_component|auto_generated|pll1|clk[0]  inst14|inst23|altpll_component|auto_generated|pll1|clk[1]  inst14|inst23|altpll_component|auto_generated|pll1|clk[4]  }] -group [get_clocks { clk40_ext  inst14|inst3|altpll_component|auto_generated|pll1|clk[0]~1  inst14|inst3|altpll_component|auto_generated|pll1|clk[1]~1  inst14|inst3|altpll_component|auto_generated|pll1|clk[2]~1  inst14|inst3|altpll_component|auto_generated|pll1|clk[3]~1  inst14|inst5|altpll_component|auto_generated|pll1|clk[0]~1  }] -group [get_clocks { usb_clk }] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_registers {*|alt_jtag_atlantic:*|jupdate}] -to [get_registers {*|alt_jtag_atlantic:*|jupdate1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rdata[*]}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read}] -to [get_registers {*|alt_jtag_atlantic:*|read1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read_req}] 
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rvalid}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|t_dav}] -to [get_registers {*|alt_jtag_atlantic:*|tck_t_dav}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|user_saw_rvalid}] -to [get_registers {*|alt_jtag_atlantic:*|rvalid0*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|wdata[*]}] -to [get_registers *]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write}] -to [get_registers {*|alt_jtag_atlantic:*|write1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_ena*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_pause*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_valid}] 
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_keepers {**}] -to [get_keepers {*phasedone_state*}]
set_false_path -from [get_keepers {**}] -to [get_keepers {*internal_phasestep*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_ue9:dffpipe9|dffe10a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_te9:dffpipe6|dffe7a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_se9:dffpipe15|dffe16a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_pe9:dffpipe12|dffe13a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_re9:dffpipe17|dffe18a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_qe9:dffpipe14|dffe15a*}]
set_false_path -from [get_keepers {*|phase_detector:phdet|inst1[*]}] 
set_false_path -from [get_keepers {*|deser400_ctrl:inst|deser_enable[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|delay_out:delay_*|ext_mode[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|delay_out:delay_*|delr[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|delay_out:delay_*|delf[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|delay_out:delay_*|ext_sel}] 
set_false_path -from [get_keepers {dtb_system:inst|dtb_system_main_control:main_control|data_out[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|daq_dma32:daq_dma_*|running_int}] -to [get_keepers {dtb_system:inst|daq_dma32:daq_dma_*|running1}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Max Skew
#**************************************************************

set_max_skew -from [get_ports {LVDS2LCDS_sdata_III}] -to [get_keepers {*|deser400_PSI:ds400_III|cdr:cdr1|oversampling:ovs|s1[*]}] 0.100 -exclude { from_clock to_clock clock_uncertainty }
set_max_skew -from [get_ports {LVDS2LCDS_sdata_II}] -to [get_keepers {*|deser400_PSI:ds400_II|cdr:cdr1|oversampling:ovs|s1[*]}] 0.100 -exclude { from_clock to_clock clock_uncertainty }
set_max_skew -from [get_ports {LVDS2LCDS_sdata_IV}] -to [get_keepers {*|deser400_PSI:ds400_IV|cdr:cdr1|oversampling:ovs|s1[*]}] 0.100 -exclude { from_clock to_clock clock_uncertainty }
set_max_skew -from [get_ports {LVDS2LCDS_sdata_I}] -to [get_keepers {*|deser400_PSI:ds400_I|cdr:cdr1|oversampling:ovs|s1[*]}] 0.100 -exclude { from_clock to_clock clock_uncertainty }
