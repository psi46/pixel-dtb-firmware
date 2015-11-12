# dtb.sdc

# tsu/th constraints
set_input_delay -clock "usb_clk" -max 9.67ns [get_ports {USB_data[*]}]
set_input_delay -clock "usb_clk" -min 0.000ns [get_ports {USB_data[*]}]

# tco constraints
set_output_delay -clock "usb_clk" -max 7.5ns [get_ports {USB_data[*]}]
set_output_delay -clock "usb_clk" -min -0.000ns [get_ports {USB_data[*]}]

set_output_delay -clock "usb_clk" -max 7.5ns [get_ports {USB_oe_n}]
set_output_delay -clock "usb_clk" -max 7.5ns [get_ports {USB_rd_n}]
set_output_delay -clock "usb_clk" -max 7.5ns [get_ports {USB_wr_n}]


set_false_path -from {dtb_system:inst|delay_out:delay_*|ext_mode[*]} -to {*}
set_false_path -from {dtb_system:inst|delay_out:delay_*|delr[*]} -to {*}
set_false_path -from {dtb_system:inst|delay_out:delay_*|delf[*]} -to {*}
set_false_path -from {dtb_system:inst|delay_out:delay_*|ext_sel} -to {*}

set_false_path -from {dtb_system:inst|dtb_system_main_control:main_control|data_out[*]}

set_false_path -from {dtb_system:inst|probe_async:probe_async_d1|sel[*]} -to {*}
set_false_path -from {dtb_system:inst|probe_async:probe_async_d2|sel[*]} -to {*}

write_sdc -expand "dtb_report.sdc"
