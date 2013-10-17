onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_pg/n
add wave -noupdate /test_pg/sync
add wave -noupdate /test_pg/write_data
add wave -noupdate /test_pg/write_ctrl
add wave -noupdate /test_pg/address
add wave -noupdate /test_pg/writedata
add wave -noupdate /test_pg/trigger
add wave -noupdate -color Gold -expand -subitemconfig {{/test_pg/signal[4]} {-color #ffffd7d70000 -height 15} {/test_pg/signal[3]} {-color Gold -height 15} {/test_pg/signal[2]} {-color Gold -height 15} {/test_pg/signal[1]} {-color Gold -height 15} {/test_pg/signal[0]} {-color Gold -height 15}} /test_pg/signal
add wave -noupdate -divider internal
add wave -noupdate /test_pg/pg/ctrl_ena
add wave -noupdate /test_pg/pg/ctrl_ext
add wave -noupdate /test_pg/pg/ctrl_loop
add wave -noupdate /test_pg/pg/ctrl_start
add wave -noupdate /test_pg/pg/ena_ext
add wave -noupdate /test_pg/pg/ena_loop
add wave -noupdate /test_pg/pg/trig_loop
add wave -noupdate /test_pg/pg/enable
add wave -noupdate /test_pg/pg/running
add wave -noupdate /test_pg/pg/set_start
add wave -noupdate /test_pg/pg/start
add wave -noupdate -radix unsigned /test_pg/pg/loopcnt
add wave -noupdate -radix hexadecimal /test_pg/pg/seq_command
add wave -noupdate /test_pg/pg/seq_address
add wave -noupdate -divider sequencer
add wave -noupdate /test_pg/pg/pg/clk
add wave -noupdate /test_pg/pg/pg/sync
add wave -noupdate /test_pg/pg/pg/enable
add wave -noupdate /test_pg/pg/pg/start
add wave -noupdate /test_pg/pg/pg/running
add wave -noupdate -radix unsigned /test_pg/pg/pg/ip
add wave -noupdate /test_pg/pg/pg/cmd_sig
add wave -noupdate -radix unsigned /test_pg/pg/pg/cmd_del
add wave -noupdate /test_pg/pg/pg/stop
add wave -noupdate -radix unsigned /test_pg/pg/pg/delay
add wave -noupdate /test_pg/pg/pg/next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1630000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 56
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
WaveRestoreZoom {0 ps} {1816500 ps}
