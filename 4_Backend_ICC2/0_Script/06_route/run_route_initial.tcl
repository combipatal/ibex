################################################################################
# ICC2 initial signal route for Ibex Mini SoC.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

catch {report_ignored_layers > $ROUTE_REPORT_DIR/ignored_layers.rpt}

check_routability > $ROUTE_REPORT_DIR/check_routability.rpt

route_auto

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
set VDDG_PINS [get_pins -hierarchical -quiet */VDDG]
if {[sizeof_collection $VDDG_PINS] > 0} {
  connect_pg_net -net VDD $VDDG_PINS
}
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

check_routes > $ROUTE_REPORT_DIR/route_check_routes.rpt
check_routes > $ROUTE_REPORT_DIR/check_routes.rpt
report_qor > $ROUTE_REPORT_DIR/qor.rpt
report_timing -delay_type max -max_paths 20 > $ROUTE_REPORT_DIR/timing.max.rpt
report_timing -delay_type min -max_paths 20 > $ROUTE_REPORT_DIR/timing.min.rpt
report_utilization > $ROUTE_REPORT_DIR/utilization.rpt
report_design -physical > $ROUTE_REPORT_DIR/design_physical.rpt
check_legality > $ROUTE_REPORT_DIR/check_legality.rpt
check_routes -antenna true > $ROUTE_REPORT_DIR/antenna.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $ROUTE_REPORT_DIR/pg_connectivity_detail.rpt \
  > $ROUTE_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $ROUTE_REPORT_DIR/pg_drc.rpt

save_block
save_lib

exit
