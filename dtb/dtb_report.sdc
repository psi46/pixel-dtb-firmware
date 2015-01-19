## Generated SDC file "dtb_report.sdc"

## Copyright (C) 1991-2013 Altera Corporation
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
## VERSION "Version 13.1.0 Build 162 10/23/2013 SJ Full Version"

## DATE    "Mon Jan 19 20:28:11 2015"

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

create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {inst14|inst5|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst5|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 45.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 90.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 135.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} [get_pins {inst14|inst3|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name {inst14|inst23|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {clk50} [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst14|inst23|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 5 -divide_by 2 -master_clock {clk50} [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]} -source [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -divide_by 5 -master_clock {clk50} [get_pins {inst14|inst23|altpll_component|auto_generated|pll1|clk[4]}] 
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -divide_by 2 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[0]} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[0]} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -phase -90.000 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[0]} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[0]} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[4]} -source [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -master_clock {inst14|inst23|altpll_component|auto_generated|pll1|clk[0]} [get_pins {inst|ram_ext|dtb_system_ram_ext_controller_phy_inst|dtb_system_ram_ext_phy_inst|dtb_system_ram_ext_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[4]}] 


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
set_clock_groups -exclusive -group [get_clocks {inst14|inst5|altpll_component|auto_generated|pll1|clk[*] inst14|inst5|altpll_component|auto_generated|pll1|clk[*]}] -group [get_clocks {inst14|inst3|altpll_component|auto_generated|pll1|clk[*]~1 inst14|inst5|altpll_component|auto_generated|pll1|clk[*]~1}] 


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
set_false_path -from [get_registers {*altera_avalon_st_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|out_data_buffer*}]
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -to [get_registers {*altera_tse_a_fifo_34:*|wr_g_rptr*}]
set_false_path -from [get_registers {*altera_tse_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_tse_clock_crosser:*|out_data_buffer*}]
set_false_path -from [get_keepers {**}] -to [get_keepers {*phasedone_state*}]
set_false_path -from [get_keepers {**}] -to [get_keepers {*internal_phasestep*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_ue9:dffpipe9|dffe10a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_te9:dffpipe6|dffe7a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_se9:dffpipe15|dffe16a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_pe9:dffpipe12|dffe13a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_re9:dffpipe17|dffe18a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_qe9:dffpipe14|dffe15a*}]
set_false_path -from [get_keepers {dtb_system:inst|delay_out:delay_*|ext_mode[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|delay_out:delay_*|delr[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|delay_out:delay_*|delf[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|delay_out:delay_*|ext_sel}] 
set_false_path -from [get_keepers {dtb_system:inst|dtb_system_main_control:main_control|data_out[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|probe_async:probe_async_d1|sel[*]}] 
set_false_path -from [get_keepers {dtb_system:inst|probe_async:probe_async_d2|sel[*]}] 
set_false_path -from [get_keepers {deser400_PSI:instDESER400_*|NRZI_decoder:inst4003|error}] 
set_false_path -from [get_keepers {deser400_PSI:instDESER400_*|dffom:inst377|inst}] 


#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -setup -end -from [get_keepers {deser400_PSI:instDESER400_*|lpm_dff0:inst487|lpm_ff:lpm_ff_component|dffs[*]}] 4
set_multicycle_path -hold -end -from [get_keepers {deser400_PSI:instDESER400_*|lpm_dff0:inst487|lpm_ff:lpm_ff_component|dffs[*]}] 3
set_multicycle_path -setup -end -from [get_keepers {deser400_PSI:instDESER400_*|inst4487}] 4
set_multicycle_path -hold -end -from [get_keepers {deser400_PSI:instDESER400_*|inst4487}] 3
set_multicycle_path -setup -end -from [get_keepers {deser400_PSI:instDESER400_*|PhSeROM:inst66|altsyncram:altsyncram_component|altsyncram_uat3:auto_generated|ram_block1a0~porta_re_reg}] -to [get_keepers {deser400_PSI:instDESER400_*|inst10[*]}] 3
set_multicycle_path -hold -end -from [get_keepers {deser400_PSI:instDESER400_*|PhSeROM:inst66|altsyncram:altsyncram_component|altsyncram_uat3:auto_generated|ram_block1a0~porta_re_reg}] -to [get_keepers {deser400_PSI:instDESER400_*|inst10[*]}] 2
set_multicycle_path -setup -end -from [get_keepers {deser400_PSI:instDESER400_*|DECODE_5b4b:inst488|OUT_4b_o[*]}] -to [get_keepers {deser400_PSI:instDESER400_*|gl_dff4e:inst469|lpm_ff:lpm_ff_component|dffs[*]}] 3
set_multicycle_path -hold -end -from [get_keepers {deser400_PSI:instDESER400_*|DECODE_5b4b:inst488|OUT_4b_o[*]}] -to [get_keepers {deser400_PSI:instDESER400_*|gl_dff4e:inst469|lpm_ff:lpm_ff_component|dffs[*]}] 2
set_multicycle_path -setup -end -from [get_keepers {deser400_PSI:instDESER400_*|NRZI_decoder:inst4003|OUT_5b_o[*]}] -to [get_keepers {deser400_PSI:instDESER400_*|NRZI_decoder:inst4003|OUT_5b_o[*]}] 3
set_multicycle_path -hold -end -from [get_keepers {deser400_PSI:instDESER400_*|NRZI_decoder:inst4003|OUT_5b_o[*]}] -to [get_keepers {deser400_PSI:instDESER400_*|NRZI_decoder:inst4003|OUT_5b_o[*]}] 2
set_multicycle_path -setup -end -from [get_keepers {deser400_PSI:instDESER400_*|gl_dff8e:inst442|lpm_ff:lpm_ff_component|dffs[*]}] 4
set_multicycle_path -hold -end -from [get_keepers {deser400_PSI:instDESER400_*|gl_dff8e:inst442|lpm_ff:lpm_ff_component|dffs[*]}] 3


#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

