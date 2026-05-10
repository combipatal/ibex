################################################################################
# Final bounded cleanup attempt after max-cap ECO.
#
# This is a single cleanup pass: repair routing damage introduced by the
# max-cap ECO, then regenerate signoff-style sanity reports. It intentionally
# does not loop through more ECO hypotheses.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set FINAL_CLEANUP_LIB $PROJECT_ROOT/4_Backend_ICC2/2_Output/11_post_route_final_cleanup/ibex_mini_soc_top_post_route_final_cleanup_icc2_lib
set SRC_BLOCK ${TOP_NAME}_post_route_maxcap_eco
set CLEANUP_BLOCK ${TOP_NAME}_post_route_final_cleanup
set REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/11_post_route_final_cleanup
set OUTPUT_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/11_post_route_final_cleanup/export

if {[info exists ::env(FINAL_CLEANUP_LIB)] && $::env(FINAL_CLEANUP_LIB) ne ""} {
  set FINAL_CLEANUP_LIB $::env(FINAL_CLEANUP_LIB)
}
if {[info exists ::env(SRC_BLOCK)] && $::env(SRC_BLOCK) ne ""} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(CLEANUP_BLOCK)] && $::env(CLEANUP_BLOCK) ne ""} {
  set CLEANUP_BLOCK $::env(CLEANUP_BLOCK)
}
if {[info exists ::env(FINAL_CLEANUP_REPORT_DIR)] && $::env(FINAL_CLEANUP_REPORT_DIR) ne ""} {
  set REPORT_DIR $::env(FINAL_CLEANUP_REPORT_DIR)
}
if {[info exists ::env(FINAL_CLEANUP_OUTPUT_DIR)] && $::env(FINAL_CLEANUP_OUTPUT_DIR) ne ""} {
  set OUTPUT_DIR $::env(FINAL_CLEANUP_OUTPUT_DIR)
}

file mkdir $REPORT_DIR
file mkdir $OUTPUT_DIR

set NETLIST_OUT $OUTPUT_DIR/${TOP_NAME}.post_route_final_cleanup.vg
set DEF_OUT     $OUTPUT_DIR/${TOP_NAME}.post_route_final_cleanup.def
set SDC_OUT     $OUTPUT_DIR/${TOP_NAME}.post_route_final_cleanup.sdc
set SDF_OUT     $OUTPUT_DIR/${TOP_NAME}.post_route_final_cleanup.sdf
set MANIFEST    $OUTPUT_DIR/post_route_final_cleanup_manifest.txt

open_lib $FINAL_CLEANUP_LIB
copy_block -from_block $SRC_BLOCK -to_block $CLEANUP_BLOCK
current_block $CLEANUP_BLOCK

check_routes > $REPORT_DIR/check_routes.before_cleanup.rpt
check_legality > $REPORT_DIR/check_legality.before_cleanup.rpt
report_qor > $REPORT_DIR/qor.before_cleanup.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_cleanup.rpt

set ROUTE_DETAIL_STATUS [catch {
  route_detail -incremental true -max_number_iterations 80
} ROUTE_DETAIL_MSG]

set ROUTE_ECO_STATUS [catch {
  route_eco -reroute any_nets -reuse_existing_global_route true -max_detail_route_iterations 160
} ROUTE_ECO_MSG]

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
set VDDG_PINS [get_pins -hierarchical -quiet */VDDG]
if {[sizeof_collection $VDDG_PINS] > 0} {
  connect_pg_net -net VDD $VDDG_PINS
}
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

check_routes > $REPORT_DIR/check_routes.after_cleanup.rpt
check_legality > $REPORT_DIR/check_legality.after_cleanup.rpt
check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.after_cleanup.rpt \
  > $REPORT_DIR/pg_connectivity.after_cleanup.rpt
check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $REPORT_DIR/pg_drc.after_cleanup.rpt
report_qor > $REPORT_DIR/qor.after_cleanup.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_cleanup.rpt
report_timing -delay_type max -max_paths 20 > $REPORT_DIR/timing.max.after_cleanup.rpt
report_timing -delay_type min -max_paths 20 > $REPORT_DIR/timing.min.after_cleanup.rpt

set WRITE_V_STATUS [catch {write_verilog $NETLIST_OUT} WRITE_V_MSG]
set WRITE_SDC_STATUS [catch {write_sdc -output $SDC_OUT} WRITE_SDC_MSG]
set WRITE_SDF_STATUS [catch {write_sdf $SDF_OUT} WRITE_SDF_MSG]
set WRITE_DEF_STATUS [catch {write_def $DEF_OUT} WRITE_DEF_MSG]

save_block
save_lib

set FP [open $MANIFEST w]
puts $FP "source_block=$SRC_BLOCK"
puts $FP "cleanup_block=$CLEANUP_BLOCK"
puts $FP "icc2_lib=$FINAL_CLEANUP_LIB"
puts $FP "report_dir=$REPORT_DIR"
puts $FP "output_dir=$OUTPUT_DIR"
puts $FP "route_detail_status=$ROUTE_DETAIL_STATUS"
puts $FP "route_detail_message=$ROUTE_DETAIL_MSG"
puts $FP "route_eco_status=$ROUTE_ECO_STATUS"
puts $FP "route_eco_message=$ROUTE_ECO_MSG"
puts $FP "netlist=$NETLIST_OUT"
puts $FP "def=$DEF_OUT"
puts $FP "sdc=$SDC_OUT"
puts $FP "sdf=$SDF_OUT"
puts $FP "write_verilog_status=$WRITE_V_STATUS"
puts $FP "write_verilog_message=$WRITE_V_MSG"
puts $FP "write_sdc_status=$WRITE_SDC_STATUS"
puts $FP "write_sdc_message=$WRITE_SDC_MSG"
puts $FP "write_sdf_status=$WRITE_SDF_STATUS"
puts $FP "write_sdf_message=$WRITE_SDF_MSG"
puts $FP "write_def_status=$WRITE_DEF_STATUS"
puts $FP "write_def_message=$WRITE_DEF_MSG"
close $FP

if {$ROUTE_DETAIL_STATUS != 0 || $ROUTE_ECO_STATUS != 0} {
  error "final route cleanup failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0} {
  error "final cleanup export failed. See $MANIFEST"
}

exit
