################################################################################
# ICC2 initial placement for Ibex Mini SoC.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set_app_options -name place.coarse.continue_on_missing_scandef -value true

create_placement \
  -effort medium \
  -timing_driven \
  -congestion

legalize_placement

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
set VDDG_PINS [get_pins -hierarchical -quiet */VDDG]
if {[sizeof_collection $VDDG_PINS] > 0} {
  connect_pg_net -net VDD $VDDG_PINS
}
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

check_legality > $PLACE_REPORT_DIR/check_legality.rpt
report_utilization > $PLACE_REPORT_DIR/utilization.rpt
report_qor > $PLACE_REPORT_DIR/place_qor.rpt
report_qor > $PLACE_REPORT_DIR/qor.rpt
report_timing -max_paths 20 > $PLACE_REPORT_DIR/timing.rpt
report_design -physical > $PLACE_REPORT_DIR/design_physical.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $PLACE_REPORT_DIR/pg_connectivity_detail.rpt \
  > $PLACE_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $PLACE_REPORT_DIR/pg_drc.rpt

save_block
save_lib

exit
