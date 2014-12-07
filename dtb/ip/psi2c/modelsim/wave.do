onerror {resume}
quietly virtual function -install /test_psi2c -env /test_psi2c { (1)} virtual_000001
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_psi2c/reset
add wave -noupdate /test_psi2c/clk
add wave -noupdate -radix unsigned /test_psi2c/address
add wave -noupdate /test_psi2c/read
add wave -noupdate -radix hexadecimal -childformat {{{/test_psi2c/readdata[31]} -radix hexadecimal} {{/test_psi2c/readdata[30]} -radix hexadecimal} {{/test_psi2c/readdata[29]} -radix hexadecimal} {{/test_psi2c/readdata[28]} -radix hexadecimal} {{/test_psi2c/readdata[27]} -radix hexadecimal} {{/test_psi2c/readdata[26]} -radix hexadecimal} {{/test_psi2c/readdata[25]} -radix hexadecimal} {{/test_psi2c/readdata[24]} -radix hexadecimal} {{/test_psi2c/readdata[23]} -radix hexadecimal} {{/test_psi2c/readdata[22]} -radix hexadecimal} {{/test_psi2c/readdata[21]} -radix hexadecimal} {{/test_psi2c/readdata[20]} -radix hexadecimal} {{/test_psi2c/readdata[19]} -radix hexadecimal} {{/test_psi2c/readdata[18]} -radix hexadecimal} {{/test_psi2c/readdata[17]} -radix hexadecimal} {{/test_psi2c/readdata[16]} -radix hexadecimal} {{/test_psi2c/readdata[15]} -radix hexadecimal} {{/test_psi2c/readdata[14]} -radix hexadecimal} {{/test_psi2c/readdata[13]} -radix hexadecimal} {{/test_psi2c/readdata[12]} -radix hexadecimal} {{/test_psi2c/readdata[11]} -radix hexadecimal} {{/test_psi2c/readdata[10]} -radix hexadecimal} {{/test_psi2c/readdata[9]} -radix hexadecimal} {{/test_psi2c/readdata[8]} -radix hexadecimal} {{/test_psi2c/readdata[7]} -radix hexadecimal} {{/test_psi2c/readdata[6]} -radix hexadecimal} {{/test_psi2c/readdata[5]} -radix hexadecimal} {{/test_psi2c/readdata[4]} -radix hexadecimal} {{/test_psi2c/readdata[3]} -radix hexadecimal} {{/test_psi2c/readdata[2]} -radix hexadecimal} {{/test_psi2c/readdata[1]} -radix hexadecimal} {{/test_psi2c/readdata[0]} -radix hexadecimal}} -subitemconfig {{/test_psi2c/readdata[31]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[30]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[29]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[28]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[27]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[26]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[25]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[24]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[23]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[22]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[21]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[20]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[19]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[18]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[17]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[16]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[15]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[14]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[13]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[12]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[11]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[10]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[9]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[8]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[7]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[6]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[5]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[4]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[3]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[2]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[1]} {-height 15 -radix hexadecimal} {/test_psi2c/readdata[0]} {-height 15 -radix hexadecimal}} /test_psi2c/readdata
add wave -noupdate /test_psi2c/write
add wave -noupdate -radix hexadecimal /test_psi2c/writedata
add wave -noupdate -color White /test_psi2c/sync
add wave -noupdate /test_psi2c/phase
add wave -noupdate /test_psi2c/send
add wave -noupdate -color Gold /test_psi2c/sda
add wave -noupdate -color Cyan /test_psi2c/rda
add wave -noupdate /test_psi2c/DUT/tbm
add wave -noupdate /test_psi2c/DUT/go
add wave -noupdate -divider bitsend
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/clk
add wave -noupdate -group bitsend -color White /test_psi2c/DUT/bitsend/sync
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/d
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/empty
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/em
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/hold
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/latch
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/s
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/p
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/data
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/rd
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/go
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/goff
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/busy
add wave -noupdate -group bitsend -color Gold /test_psi2c/DUT/bitsend/sda
add wave -noupdate -group bitsend /test_psi2c/DUT/bitsend/sm
add wave -noupdate -divider readback
add wave -noupdate /test_psi2c/DUT/readback/clk
add wave -noupdate /test_psi2c/DUT/readback/sync
add wave -noupdate /test_psi2c/DUT/readback/sync2
add wave -noupdate /test_psi2c/DUT/readback/i2c_send
add wave -noupdate /test_psi2c/DUT/readback/go
add wave -noupdate -radix hexadecimal /test_psi2c/DUT/readback/d
add wave -noupdate -divider {New Divider}
add wave -noupdate /test_psi2c/DUT/readback/rda
add wave -noupdate /test_psi2c/DUT/readback/rdaff
add wave -noupdate /test_psi2c/DUT/readback/nto
add wave -noupdate /test_psi2c/DUT/readback/bitcounter/sset
add wave -noupdate -radix unsigned -childformat {{{/test_psi2c/DUT/readback/bitcounter/q[4]} -radix unsigned} {{/test_psi2c/DUT/readback/bitcounter/q[3]} -radix unsigned} {{/test_psi2c/DUT/readback/bitcounter/q[2]} -radix unsigned} {{/test_psi2c/DUT/readback/bitcounter/q[1]} -radix unsigned} {{/test_psi2c/DUT/readback/bitcounter/q[0]} -radix unsigned}} -expand -subitemconfig {{/test_psi2c/DUT/readback/bitcounter/q[4]} {-height 15 -radix unsigned} {/test_psi2c/DUT/readback/bitcounter/q[3]} {-height 15 -radix unsigned} {/test_psi2c/DUT/readback/bitcounter/q[2]} {-height 15 -radix unsigned} {/test_psi2c/DUT/readback/bitcounter/q[1]} {-height 15 -radix unsigned} {/test_psi2c/DUT/readback/bitcounter/q[0]} {-height 15 -radix unsigned}} /test_psi2c/DUT/readback/bitcounter/q
add wave -noupdate /test_psi2c/DUT/readback/running
add wave -noupdate -radix hexadecimal /test_psi2c/DUT/readback/shiftreg
add wave -noupdate /test_psi2c/DUT/readback/last
add wave -noupdate -radix hexadecimal /test_psi2c/DUT/readback/ha
add wave -noupdate -radix hexadecimal /test_psi2c/DUT/readback/pa
add wave -noupdate -radix hexadecimal /test_psi2c/DUT/readback/ra
add wave -noupdate -radix hexadecimal /test_psi2c/DUT/readback/rd
add wave -noupdate /test_psi2c/DUT/readback/start
add wave -noupdate /test_psi2c/DUT/readback/_s3
add wave -noupdate /test_psi2c/DUT/readback/_rw
add wave -noupdate /test_psi2c/DUT/readback/_d4
add wave -noupdate /test_psi2c/DUT/readback/_d0
add wave -noupdate -radix hexadecimal /test_psi2c/DUT/readback/d
add wave -noupdate -group {TBM Hub} -color White /test_psi2c/t/scl
add wave -noupdate -group {TBM Hub} -color Gold /test_psi2c/t/sda
add wave -noupdate -group {TBM Hub} -color {Orange Red} /test_psi2c/t/rda
add wave -noupdate -group {TBM Hub} /test_psi2c/t/gate
add wave -noupdate -group {TBM Hub} -radix unsigned /test_psi2c/t/count
add wave -noupdate -group {TBM Hub} /test_psi2c/t/rd
add wave -noupdate -expand -group FFto /test_psi2c/DUT/readback/ffto/clk
add wave -noupdate -expand -group FFto /test_psi2c/DUT/readback/ffto/sync
add wave -noupdate -expand -group FFto /test_psi2c/DUT/readback/ffto/to_disable
add wave -noupdate -expand -group FFto /test_psi2c/DUT/readback/ffto/s
add wave -noupdate -expand -group FFto /test_psi2c/DUT/readback/ffto/r
add wave -noupdate -expand -group FFto /test_psi2c/DUT/readback/toflag
add wave -noupdate -expand -group FFto /test_psi2c/DUT/readback/ffto/q
add wave -noupdate -expand -group FFto -radix unsigned /test_psi2c/DUT/readback/ffto/timeout_counter
add wave -noupdate -expand -group FFto /test_psi2c/DUT/readback/ffto/timeout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 7} {950000 ps} 0} {{Cursor 8} {2460000 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 239
configure wave -valuecolwidth 114
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
WaveRestoreZoom {0 ps} {2699550 ps}
