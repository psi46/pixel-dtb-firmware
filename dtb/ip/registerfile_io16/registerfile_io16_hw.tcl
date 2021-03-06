# TCL File Generated by Component Editor 11.1sp2
# Tue Feb 14 15:49:03 CET 2012
# DO NOT MODIFY


# +-----------------------------------
# | 
# | registerfile_io16 "registerfile_io16" v1.0
# | Beat Meier 2012.02.14.15:49:03
# | adc register
# | 
# | D:/projekte/roctest/roctest_20120208_V11_1/source/FPGA/atb/ip/registerfile_io16/registerfile_io16.v
# | 
# |    ./registerfile_io16.v syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 11.0
# | 
package require -exact sopc 11.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module registerfile_io16
# | 
set_module_property DESCRIPTION "adc register"
set_module_property NAME registerfile_io16
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP ATB
set_module_property AUTHOR "Beat Meier"
set_module_property DISPLAY_NAME registerfile_io16
set_module_property TOP_LEVEL_HDL_FILE registerfile_io16.v
set_module_property TOP_LEVEL_HDL_MODULE registerfile_io16
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property STATIC_TOP_LEVEL_MODULE_NAME registerfile_io16
set_module_property FIX_110_VIP_PATH false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file registerfile_io16.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clock clock end
set_interface_property clock clockRate 0

set_interface_property clock ENABLED true

add_interface_port clock clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point slave
# | 
add_interface slave avalon end
set_interface_property slave addressUnits WORDS
set_interface_property slave associatedClock clock
set_interface_property slave associatedReset reset
set_interface_property slave bitsPerSymbol 8
set_interface_property slave burstOnBurstBoundariesOnly false
set_interface_property slave burstcountUnits WORDS
set_interface_property slave explicitAddressSpan 0
set_interface_property slave holdTime 0
set_interface_property slave linewrapBursts false
set_interface_property slave maximumPendingReadTransactions 0
set_interface_property slave readLatency 0
set_interface_property slave readWaitStates 0
set_interface_property slave readWaitTime 0
set_interface_property slave setupTime 0
set_interface_property slave timingUnits Cycles
set_interface_property slave writeWaitTime 0

set_interface_property slave ENABLED true

add_interface_port slave slave_read read Input 1
add_interface_port slave slave_write write Input 1
add_interface_port slave slave_address address Input 6
add_interface_port slave slave_readdata readdata Output 16
add_interface_port slave slave_writedata writedata Input 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset
# | 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT

set_interface_property reset ENABLED true

add_interface_port reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point adc
# | 
add_interface adc conduit end

set_interface_property adc ENABLED true

add_interface_port adc atb_read export Output 1
add_interface_port adc atb_write export Output 1
add_interface_port adc atb_register export Output 6
add_interface_port adc atb_readdata export Input 16
add_interface_port adc atb_writedata export Output 16
# | 
# +-----------------------------------
