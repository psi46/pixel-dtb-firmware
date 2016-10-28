# TCL File Generated by Component Editor 13.1
# Tue Aug 30 08:17:25 CEST 2016
# DO NOT MODIFY


# 
# i2c_master "i2c_master" v1.0
#  2016.08.30.08:17:25
# I2C master
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module i2c_master
# 
set_module_property DESCRIPTION "I2C master"
set_module_property NAME i2c_master
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP ATB
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME i2c_master
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset quartus_synth QUARTUS_SYNTH "" "Quartus Synthesis"
set_fileset_property quartus_synth TOP_LEVEL i2c_master
set_fileset_property quartus_synth ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file i2c_master.v VERILOG PATH i2c_master.v TOP_LEVEL_FILE
add_fileset_file i2c_master_bit_ctrl.v VERILOG PATH i2c_master_bit_ctrl.v
add_fileset_file i2c_master_byte_ctrl.v VERILOG PATH i2c_master_byte_ctrl.v
add_fileset_file i2c_master_top.v VERILOG PATH i2c_master_top.v

add_fileset sim_verilog SIM_VERILOG "" "Verilog Simulation"
set_fileset_property sim_verilog TOP_LEVEL i2c_master
set_fileset_property sim_verilog ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file i2c_master.v VERILOG PATH i2c_master.v
add_fileset_file i2c_master_bit_ctrl.v VERILOG PATH i2c_master_bit_ctrl.v
add_fileset_file i2c_master_byte_ctrl.v VERILOG PATH i2c_master_byte_ctrl.v
add_fileset_file i2c_master_top.v VERILOG PATH i2c_master_top.v


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point slave
# 
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
set_interface_property slave readWaitTime 1
set_interface_property slave setupTime 0
set_interface_property slave timingUnits Cycles
set_interface_property slave writeWaitTime 0
set_interface_property slave ENABLED true
set_interface_property slave EXPORT_OF ""
set_interface_property slave PORT_NAME_MAP ""
set_interface_property slave CMSIS_SVD_VARIABLES ""
set_interface_property slave SVD_ADDRESS_GROUP ""

add_interface_port slave slave_address address Input 3
add_interface_port slave slave_writedata writedata Input 8
add_interface_port slave slave_readdata readdata Output 8
add_interface_port slave slave_select chipselect Input 1
add_interface_port slave slave_write write Input 1
set_interface_assignment slave embeddedsw.configuration.isFlash 0
set_interface_assignment slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment slave embeddedsw.configuration.isPrintableDevice 0


# 
# connection point i2c
# 
add_interface i2c conduit end
set_interface_property i2c associatedClock ""
set_interface_property i2c associatedReset ""
set_interface_property i2c ENABLED true
set_interface_property i2c EXPORT_OF ""
set_interface_property i2c PORT_NAME_MAP ""
set_interface_property i2c CMSIS_SVD_VARIABLES ""
set_interface_property i2c SVD_ADDRESS_GROUP ""

add_interface_port i2c sda export Bidir 1
add_interface_port i2c scl export Bidir 1
add_interface_port i2c ext_scl export Input 1


# 
# connection point interrupt
# 
add_interface interrupt interrupt end
set_interface_property interrupt associatedAddressablePoint slave
set_interface_property interrupt associatedClock clock
set_interface_property interrupt associatedReset reset
set_interface_property interrupt bridgedReceiverOffset ""
set_interface_property interrupt bridgesToReceiver ""
set_interface_property interrupt ENABLED true
set_interface_property interrupt EXPORT_OF ""
set_interface_property interrupt PORT_NAME_MAP ""
set_interface_property interrupt CMSIS_SVD_VARIABLES ""
set_interface_property interrupt SVD_ADDRESS_GROUP ""

add_interface_port interrupt slave_int irq Output 1

