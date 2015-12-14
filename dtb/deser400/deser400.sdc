# deser400.sdc


# --- phase_detector
set_false_path -from {*|phase_detector:phdet|inst1[*]} -to {*}

set_false_path -from {*|deser400_ctrl:inst|deser_enable[*]} -to {*}


set_max_skew \
  -from [get_ports LVDS2LCDS_sdata_I] \
  -to "*|deser400_PSI:ds400_I|oversampling:ovs|s1[*]"   0.1 \
  -exclude { from_clock to_clock clock_uncertainty }
  
set_max_skew \
  -from [get_ports LVDS2LCDS_sdata_II] \
  -to "*|deser400_PSI:ds400_II|oversampling:ovs|s1[*]"  0.1 \
  -exclude { from_clock to_clock clock_uncertainty }
  
set_max_skew \
  -from [get_ports LVDS2LCDS_sdata_III] \
  -to "*|deser400_PSI:ds400_III|oversampling:ovs|s1[*]" 0.1 \
  -exclude { from_clock to_clock clock_uncertainty }
  
set_max_skew \
  -from [get_ports LVDS2LCDS_sdata_IV] \
  -to "*|deser400_PSI:ds400_IV|oversampling:ovs|s1[*]"  0.1 \
  -exclude { from_clock to_clock clock_uncertainty }
