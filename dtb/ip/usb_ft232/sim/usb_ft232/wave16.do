onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_usb16/clk
add wave -noupdate -expand -group {asi_uplink signals} /test_usb16/asi_uplink_ready
add wave -noupdate -expand -group {asi_uplink signals} /test_usb16/asi_uplink_valid
add wave -noupdate -expand -group {asi_uplink signals} -radix hexadecimal -childformat {{{/test_usb16/asi_uplink_data[15]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[14]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[13]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[12]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[11]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[10]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[9]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[8]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[7]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[6]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[5]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[4]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[3]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[2]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[1]} -radix hexadecimal} {{/test_usb16/asi_uplink_data[0]} -radix hexadecimal}} -subitemconfig {{/test_usb16/asi_uplink_data[15]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[14]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[13]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[12]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[11]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[10]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[9]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[8]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[7]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[6]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[5]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[4]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[3]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[2]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[1]} {-height 15 -radix hexadecimal} {/test_usb16/asi_uplink_data[0]} {-height 15 -radix hexadecimal}} /test_usb16/asi_uplink_data
add wave -noupdate -expand -group {asi_uplink signals} -radix unsigned /test_usb16/asi_uplink_empty
add wave -noupdate -expand -group {asi_uplink signals} /test_usb16/asi_uplink_startofpacket
add wave -noupdate -expand -group {asi_uplink signals} /test_usb16/asi_uplink_endofpacket
add wave -noupdate -group {avs_ctrl signals} /test_usb16/avs_ctrl_address
add wave -noupdate -group {avs_ctrl signals} /test_usb16/avs_ctrl_write
add wave -noupdate -group {avs_ctrl signals} -radix hexadecimal /test_usb16/avs_ctrl_writedata
add wave -noupdate -group {avs_ctrl signals} /test_usb16/avs_ctrl_read
add wave -noupdate -group {avs_ctrl signals} -radix hexadecimal /test_usb16/avs_ctrl_readdata
add wave -noupdate -group {avs_ctrl signals} -radix hexadecimal /test_usb16/ret
add wave -noupdate -group {avs_ctrl signals} -radix hexadecimal /test_usb16/rxdata
add wave -noupdate -group ft232_signals /test_usb16/usb_clk
add wave -noupdate -group ft232_signals /test_usb16/txe_n
add wave -noupdate -group ft232_signals /test_usb16/wr_n
add wave -noupdate -group ft232_signals -radix hexadecimal -childformat {{{/test_usb16/data[7]} -radix hexadecimal} {{/test_usb16/data[6]} -radix hexadecimal} {{/test_usb16/data[5]} -radix hexadecimal} {{/test_usb16/data[4]} -radix hexadecimal} {{/test_usb16/data[3]} -radix hexadecimal} {{/test_usb16/data[2]} -radix hexadecimal} {{/test_usb16/data[1]} -radix hexadecimal} {{/test_usb16/data[0]} -radix hexadecimal}} -subitemconfig {{/test_usb16/data[7]} {-height 15 -radix hexadecimal} {/test_usb16/data[6]} {-height 15 -radix hexadecimal} {/test_usb16/data[5]} {-height 15 -radix hexadecimal} {/test_usb16/data[4]} {-height 15 -radix hexadecimal} {/test_usb16/data[3]} {-height 15 -radix hexadecimal} {/test_usb16/data[2]} {-height 15 -radix hexadecimal} {/test_usb16/data[1]} {-height 15 -radix hexadecimal} {/test_usb16/data[0]} {-height 15 -radix hexadecimal}} /test_usb16/data
add wave -noupdate -group ft232_signals -color Gold /test_usb16/rd_n
add wave -noupdate -group ft232_signals /test_usb16/rxf_n
add wave -noupdate -group ft232_signals /test_usb16/siwu_n
add wave -noupdate -divider uplink
add wave -noupdate -radix unsigned /test_usb16/DUT/port/tx_empty
add wave -noupdate /test_usb16/DUT/tx_write
add wave -noupdate -radix hexadecimal -childformat {{{/test_usb16/DUT/tx_dout[15]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[14]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[13]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[12]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[11]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[10]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[9]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[8]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[7]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[6]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[5]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[4]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[3]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[2]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[1]} -radix hexadecimal} {{/test_usb16/DUT/tx_dout[0]} -radix hexadecimal}} -subitemconfig {{/test_usb16/DUT/tx_dout[15]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[14]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[13]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[12]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[11]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[10]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[9]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[8]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[7]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[6]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[5]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[4]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[3]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[2]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[1]} {-height 15 -radix hexadecimal} {/test_usb16/DUT/tx_dout[0]} {-height 15 -radix hexadecimal}} /test_usb16/DUT/tx_dout
add wave -noupdate /test_usb16/DUT/tx_min
add wave -noupdate -divider {asi uplink}
add wave -noupdate -radix hexadecimal /test_usb16/uplink_data1
add wave -noupdate -radix hexadecimal /test_usb16/uplink_data0
add wave -noupdate -divider {ft232 io}
add wave -noupdate -radix hexadecimal /test_usb16/ft232_write
add wave -noupdate /test_usb16/siwu_n
add wave -noupdate -radix hexadecimal /test_usb16/ft232_read
add wave -noupdate -divider {avs ctrl}
add wave -noupdate -radix hexadecimal /test_usb16/avs_read_1
add wave -noupdate -radix hexadecimal /test_usb16/avs_read_0
add wave -noupdate -radix hexadecimal /test_usb16/avs_write_0
add wave -noupdate -radix hexadecimal /test_usb16/avs_write_1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {220000 ps} 0} {{Cursor 3} {70988513 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {643770 ps}
