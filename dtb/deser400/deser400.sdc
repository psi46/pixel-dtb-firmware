# deser400.sdc


# --- phase_detector
set_false_path -from {*|phase_detector:phdet|inst1[*]} -to {*}

set_false_path -from {*|deser400_ctrl:inst|deser_enable[*]} -to {*}
