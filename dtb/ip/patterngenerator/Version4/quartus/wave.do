onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_pg/csi_clock_clk
add wave -noupdate /test_pg/avs_data_write
add wave -noupdate -radix hexadecimal -childformat {{{/test_pg/avs_data_address[7]} -radix hexadecimal} {{/test_pg/avs_data_address[6]} -radix hexadecimal} {{/test_pg/avs_data_address[5]} -radix hexadecimal} {{/test_pg/avs_data_address[4]} -radix hexadecimal} {{/test_pg/avs_data_address[3]} -radix hexadecimal} {{/test_pg/avs_data_address[2]} -radix hexadecimal} {{/test_pg/avs_data_address[1]} -radix hexadecimal} {{/test_pg/avs_data_address[0]} -radix hexadecimal}} -subitemconfig {{/test_pg/avs_data_address[7]} {-height 15 -radix hexadecimal} {/test_pg/avs_data_address[6]} {-height 15 -radix hexadecimal} {/test_pg/avs_data_address[5]} {-height 15 -radix hexadecimal} {/test_pg/avs_data_address[4]} {-height 15 -radix hexadecimal} {/test_pg/avs_data_address[3]} {-height 15 -radix hexadecimal} {/test_pg/avs_data_address[2]} {-height 15 -radix hexadecimal} {/test_pg/avs_data_address[1]} {-height 15 -radix hexadecimal} {/test_pg/avs_data_address[0]} {-height 15 -radix hexadecimal}} /test_pg/avs_data_address
add wave -noupdate -radix hexadecimal /test_pg/avs_data_writedata
add wave -noupdate /test_pg/avs_ctrl_write
add wave -noupdate -radix hexadecimal /test_pg/avs_data_address
add wave -noupdate -radix hexadecimal /test_pg/avs_ctrl_writedata
add wave -noupdate /test_pg/clk
add wave -noupdate /test_pg/clkena
add wave -noupdate /test_pg/trigger
add wave -noupdate -expand /test_pg/signal
add wave -noupdate -divider sequencer
add wave -noupdate /test_pg/pg/pg/clk
add wave -noupdate /test_pg/pg/pg/sync
add wave -noupdate /test_pg/pg/pg/reset
add wave -noupdate /test_pg/pg/pg/start
add wave -noupdate /test_pg/pg/pg/running
add wave -noupdate -radix hexadecimal -childformat {{{/test_pg/pg/pg/signal[3]} -radix hexadecimal} {{/test_pg/pg/pg/signal[2]} -radix hexadecimal} {{/test_pg/pg/pg/signal[1]} -radix hexadecimal} {{/test_pg/pg/pg/signal[0]} -radix hexadecimal}} -subitemconfig {{/test_pg/pg/pg/signal[3]} {-height 15 -radix hexadecimal} {/test_pg/pg/pg/signal[2]} {-height 15 -radix hexadecimal} {/test_pg/pg/pg/signal[1]} {-height 15 -radix hexadecimal} {/test_pg/pg/pg/signal[0]} {-height 15 -radix hexadecimal}} /test_pg/pg/pg/signal
add wave -noupdate -radix hexadecimal /test_pg/pg/pg/ip
add wave -noupdate -radix hexadecimal /test_pg/pg/pg/cmd
add wave -noupdate -radix hexadecimal /test_pg/pg/pg/cmd_sig
add wave -noupdate -radix hexadecimal /test_pg/pg/pg/cmd_del
add wave -noupdate -radix hexadecimal /test_pg/pg/pg/stop
add wave -noupdate -radix hexadecimal /test_pg/pg/pg/delay
add wave -noupdate -radix hexadecimal /test_pg/pg/pg/next
add wave -noupdate -divider ram
add wave -noupdate -radix hexadecimal /test_pg/pg/ram/wrclock
add wave -noupdate -radix hexadecimal /test_pg/pg/ram/wraddress
add wave -noupdate -radix hexadecimal /test_pg/pg/ram/wren
add wave -noupdate /test_pg/pg/ram/byteena_a
add wave -noupdate -radix hexadecimal /test_pg/pg/ram/data
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /test_pg/pg/ram/rdclock
add wave -noupdate -radix hexadecimal /test_pg/pg/ram/rdaddress
add wave -noupdate -radix hexadecimal /test_pg/pg/ram/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {470000 ps} 0}
configure wave -namecolwidth 190
configure wave -valuecolwidth 59
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
WaveRestoreZoom {0 ps} {4924500 ps}
