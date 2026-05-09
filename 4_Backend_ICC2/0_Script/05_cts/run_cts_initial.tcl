################################################################################
# ICC2 initial CTS for Ibex Mini SoC.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set CTS_CLOCK clk
set CTS_TARGET_SKEW 0.20

set_clock_tree_options \
  -clocks [get_clocks $CTS_CLOCK] \
  -target_skew $CTS_TARGET_SKEW

set_clock_routing_rules \
  -clocks [get_clocks $CTS_CLOCK] \
  -min_routing_layer M4 \
  -max_routing_layer M6 \
  -default_rule

check_clock_trees \
  -clocks [get_clocks $CTS_CLOCK] \
  > $CTS_REPORT_DIR/check_clock_trees.pre.rpt

report_clock_tree_options > $CTS_REPORT_DIR/clock_tree_options.rpt
report_clock_routing_rules > $CTS_REPORT_DIR/clock_routing_rules.rpt

clock_opt \
  -from build_clock \
  -to route_clock

check_clock_trees \
  -clocks [get_clocks $CTS_CLOCK] \
  > $CTS_REPORT_DIR/check_clock_trees.post.rpt

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
set VDDG_PINS [get_pins -hierarchical -quiet */VDDG]
if {[sizeof_collection $VDDG_PINS] > 0} {
  connect_pg_net -net VDD $VDDG_PINS
}
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

report_clock_qor -type summary > $CTS_REPORT_DIR/clock_qor.summary.rpt
report_clock_qor -type latency > $CTS_REPORT_DIR/clock_qor.latency.rpt
report_clock_qor -type drc_violators > $CTS_REPORT_DIR/clock_qor.drc_violators.rpt
report_clock_qor -type area > $CTS_REPORT_DIR/clock_qor.area.rpt

report_clock_timing -type summary > $CTS_REPORT_DIR/clock_timing.summary.rpt
report_clock_timing -type skew -setup -nworst 20 > $CTS_REPORT_DIR/clock_timing.skew_setup.rpt
report_clock_timing -type skew -hold -nworst 20 > $CTS_REPORT_DIR/clock_timing.skew_hold.rpt
report_clock_timing -type latency -setup -nworst 20 > $CTS_REPORT_DIR/clock_timing.latency_setup.rpt
report_clock_timing -type latency -hold -nworst 20 > $CTS_REPORT_DIR/clock_timing.latency_hold.rpt

report_timing -delay_type max -max_paths 20 > $CTS_REPORT_DIR/timing.max.rpt
report_timing -delay_type min -max_paths 20 > $CTS_REPORT_DIR/timing.min.rpt
report_qor > $CTS_REPORT_DIR/qor.rpt
report_utilization > $CTS_REPORT_DIR/utilization.rpt
report_design -physical > $CTS_REPORT_DIR/design_physical.rpt
check_legality > $CTS_REPORT_DIR/check_legality.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $CTS_REPORT_DIR/pg_connectivity_detail.rpt \
  > $CTS_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $CTS_REPORT_DIR/pg_drc.rpt

save_block
save_lib

exit
