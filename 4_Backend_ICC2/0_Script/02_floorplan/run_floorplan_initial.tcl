################################################################################
# ICC2 initial floorplan for Ibex Mini SoC.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set CORE_UTILIZATION 0.60
set CORE_ASPECT_RATIO {1 1}
set CORE_OFFSET_UM 20.0

if {[info exists ::env(CORE_UTILIZATION)] && $::env(CORE_UTILIZATION) ne ""} {
  set CORE_UTILIZATION $::env(CORE_UTILIZATION)
}
if {[info exists ::env(CORE_ASPECT_RATIO)] && $::env(CORE_ASPECT_RATIO) ne ""} {
  set CORE_ASPECT_RATIO $::env(CORE_ASPECT_RATIO)
}
if {[info exists ::env(CORE_OFFSET_UM)] && $::env(CORE_OFFSET_UM) ne ""} {
  set CORE_OFFSET_UM $::env(CORE_OFFSET_UM)
}

initialize_floorplan \
  -control_type core \
  -shape R \
  -side_ratio $CORE_ASPECT_RATIO \
  -core_utilization $CORE_UTILIZATION \
  -core_offset $CORE_OFFSET_UM \
  -flip_first_row true

place_pins -self

report_design -physical > $FLOORPLAN_REPORT_DIR/design_physical.rpt
report_utilization > $FLOORPLAN_REPORT_DIR/utilization.rpt
report_qor > $FLOORPLAN_REPORT_DIR/qor.rpt
report_timing -max_paths 10 > $FLOORPLAN_REPORT_DIR/timing.rpt

check_design \
  -checks {netlist design_mismatch timing} \
  -ems_database $FLOORPLAN_REPORT_DIR/check_design.ems \
  -log_file $FLOORPLAN_REPORT_DIR/check_design.rpt

save_block
save_lib

exit
