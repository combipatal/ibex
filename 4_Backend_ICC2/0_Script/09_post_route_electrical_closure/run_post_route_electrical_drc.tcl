################################################################################
# Post-route electrical DRC closure for the Ibex route-closure baseline.
#
# This targets max_transition/max_capacitance after signal route DRC is clean.
# It works on a copied ICC2 library so the route-closure baseline DB remains
# available for comparison.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set ELEC_CLOSURE_LIB $PROJECT_ROOT/4_Backend_ICC2/2_Output/09_post_route_electrical_closure/ibex_mini_soc_top_post_route_electrical_drc_icc2_lib
set SRC_BLOCK $TOP_NAME
set WORK_BLOCK ${TOP_NAME}_post_route_electrical_drc
set REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/09_post_route_electrical_closure

if {[info exists ::env(ELEC_CLOSURE_LIB)] && $::env(ELEC_CLOSURE_LIB) ne ""} {
  set ELEC_CLOSURE_LIB $::env(ELEC_CLOSURE_LIB)
}
if {[info exists ::env(SRC_BLOCK)] && $::env(SRC_BLOCK) ne ""} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(WORK_BLOCK)] && $::env(WORK_BLOCK) ne ""} {
  set WORK_BLOCK $::env(WORK_BLOCK)
}
if {[info exists ::env(ELEC_CLOSURE_REPORT_DIR)] && $::env(ELEC_CLOSURE_REPORT_DIR) ne ""} {
  set REPORT_DIR $::env(ELEC_CLOSURE_REPORT_DIR)
}

file mkdir $REPORT_DIR

open_lib $ELEC_CLOSURE_LIB
copy_block -from_block $SRC_BLOCK -to_block $WORK_BLOCK
current_block $WORK_BLOCK

check_routes > $REPORT_DIR/check_routes.before_route_opt.rpt
check_legality > $REPORT_DIR/check_legality.before_route_opt.rpt
report_qor > $REPORT_DIR/qor.before_route_opt.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_route_opt.rpt
report_timing -delay_type max -max_paths 20 > $REPORT_DIR/timing.max.before_route_opt.rpt
report_timing -delay_type min -max_paths 20 > $REPORT_DIR/timing.min.before_route_opt.rpt

route_opt

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
set VDDG_PINS [get_pins -hierarchical -quiet */VDDG]
if {[sizeof_collection $VDDG_PINS] > 0} {
  connect_pg_net -net VDD $VDDG_PINS
}
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

check_routes > $REPORT_DIR/check_routes.after_route_opt.rpt
check_legality > $REPORT_DIR/check_legality.after_route_opt.rpt
check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.after_route_opt.rpt \
  > $REPORT_DIR/pg_connectivity.after_route_opt.rpt
check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $REPORT_DIR/pg_drc.after_route_opt.rpt
report_qor > $REPORT_DIR/qor.after_route_opt.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_route_opt.rpt
report_timing -delay_type max -max_paths 20 > $REPORT_DIR/timing.max.after_route_opt.rpt
report_timing -delay_type min -max_paths 20 > $REPORT_DIR/timing.min.after_route_opt.rpt
report_design -physical > $REPORT_DIR/design_physical.after_route_opt.rpt
report_utilization > $REPORT_DIR/utilization.after_route_opt.rpt

set FP [open $REPORT_DIR/post_route_electrical_drc_manifest.txt w]
puts $FP "source_block=$SRC_BLOCK"
puts $FP "work_block=$WORK_BLOCK"
puts $FP "icc2_lib=$ELEC_CLOSURE_LIB"
puts $FP "report_dir=$REPORT_DIR"
puts $FP "command=route_opt"
close $FP

save_block
save_lib
exit
