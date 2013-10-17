onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_data_dma/DUT/csi_clock_clk
add wave -noupdate /test_data_dma/DUT/csi_clock_reset
add wave -noupdate -divider programming
add wave -noupdate /test_data_dma/DUT/avs_ctrl_address
add wave -noupdate /test_data_dma/DUT/avs_ctrl_write
add wave -noupdate -radix hexadecimal /test_data_dma/DUT/avs_ctrl_writedata
add wave -noupdate /test_data_dma/DUT/avs_ctrl_read
add wave -noupdate -radix hexadecimal /test_data_dma/DUT/avs_ctrl_readdata
add wave -noupdate -divider {data source}
add wave -noupdate /test_data_dma/DUT/write
add wave -noupdate /test_data_dma/DUT/waitrq
add wave -noupdate -radix unsigned /test_data_dma/DUT/data
add wave -noupdate -divider {avalon master}
add wave -noupdate -radix hexadecimal /test_data_dma/DUT/avm_data_address
add wave -noupdate /test_data_dma/DUT/avm_data_write
add wave -noupdate -radix unsigned /test_data_dma/DUT/avm_data_writedata
add wave -noupdate /test_data_dma/DUT/avm_data_waitrequest
add wave -noupdate -divider DMA
add wave -noupdate /test_data_dma/DUT/dma_enable
add wave -noupdate /test_data_dma/DUT/running
add wave -noupdate -color Gold /test_data_dma/DUT/do_read
add wave -noupdate -color {Orange Red} /test_data_dma/DUT/do_write
add wave -noupdate /test_data_dma/DUT/full
add wave -noupdate -radix hexadecimal /test_data_dma/DUT/pointer
add wave -noupdate -radix unsigned /test_data_dma/DUT/length
add wave -noupdate /test_data_dma/DUT/lastword
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1950000 ps} 0}
configure wave -namecolwidth 194
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
configure wave -timelineunits us
update
WaveRestoreZoom {995809 ps} {2187559 ps}
