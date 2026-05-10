################################################################################
# Post-route max-capacitance ECO for the Ibex route-closure database.
#
# This stage starts from the post-route electrical-closure waypoint where
# max_transition is already clean and uses ICC2/PrimeTime ECO optimization for
# remaining max_capacitance violations.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set MAXCAP_ECO_LIB $PROJECT_ROOT/4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/ibex_mini_soc_top_post_route_maxcap_eco_icc2_lib
set SRC_BLOCK ${TOP_NAME}_post_route_electrical_drc_iter4
set ECO_BLOCK ${TOP_NAME}_post_route_maxcap_eco
set REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/10_post_route_maxcap_eco
set OUTPUT_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/export
set SESSION_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/pt_eco_session
set PT_WORK_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/pt_work
set PT_EXEC /tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell
set PHYSICAL_MODE occupied_site

if {[info exists ::env(MAXCAP_ECO_LIB)] && $::env(MAXCAP_ECO_LIB) ne ""} {
  set MAXCAP_ECO_LIB $::env(MAXCAP_ECO_LIB)
}
if {[info exists ::env(SRC_BLOCK)] && $::env(SRC_BLOCK) ne ""} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(ECO_BLOCK)] && $::env(ECO_BLOCK) ne ""} {
  set ECO_BLOCK $::env(ECO_BLOCK)
}
if {[info exists ::env(MAXCAP_ECO_REPORT_DIR)] && $::env(MAXCAP_ECO_REPORT_DIR) ne ""} {
  set REPORT_DIR $::env(MAXCAP_ECO_REPORT_DIR)
}
if {[info exists ::env(MAXCAP_ECO_OUTPUT_DIR)] && $::env(MAXCAP_ECO_OUTPUT_DIR) ne ""} {
  set OUTPUT_DIR $::env(MAXCAP_ECO_OUTPUT_DIR)
}
if {[info exists ::env(PT_EXEC)] && $::env(PT_EXEC) ne ""} {
  set PT_EXEC $::env(PT_EXEC)
}
if {[info exists ::env(PHYSICAL_MODE)] && $::env(PHYSICAL_MODE) ne ""} {
  set PHYSICAL_MODE $::env(PHYSICAL_MODE)
}

file mkdir $REPORT_DIR
file mkdir $OUTPUT_DIR
file mkdir $SESSION_DIR
file mkdir $PT_WORK_DIR

set NETLIST_OUT $OUTPUT_DIR/${TOP_NAME}.post_route_maxcap_eco.vg
set DEF_OUT     $OUTPUT_DIR/${TOP_NAME}.post_route_maxcap_eco.def
set SDC_OUT     $OUTPUT_DIR/${TOP_NAME}.post_route_maxcap_eco.sdc
set SDF_OUT     $OUTPUT_DIR/${TOP_NAME}.post_route_maxcap_eco.sdf
set MANIFEST    $OUTPUT_DIR/post_route_maxcap_eco_manifest.txt

open_lib $MAXCAP_ECO_LIB
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

check_routes > $REPORT_DIR/check_routes.before_maxcap_eco.rpt
check_legality > $REPORT_DIR/check_legality.before_maxcap_eco.rpt
report_qor > $REPORT_DIR/qor.before_maxcap_eco.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_maxcap_eco.rpt
report_timing -delay_type max -max_paths 20 > $REPORT_DIR/timing.max.before_maxcap_eco.rpt
report_timing -delay_type min -max_paths 20 > $REPORT_DIR/timing.min.before_maxcap_eco.rpt

set_pt_options -pt_exec $PT_EXEC -work_dir $PT_WORK_DIR
report_pt_options > $REPORT_DIR/pt_options.rpt
set_app_options -name extract.starrc_mode -value false

set ECO_STATUS [catch {
  eco_opt -types max_capacitance -physical_mode $PHYSICAL_MODE -save_session $SESSION_DIR
} ECO_MSG]

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
set VDDG_PINS [get_pins -hierarchical -quiet */VDDG]
if {[sizeof_collection $VDDG_PINS] > 0} {
  connect_pg_net -net VDD $VDDG_PINS
}
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

report_qor > $REPORT_DIR/qor.after_maxcap_eco.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_maxcap_eco.rpt
check_routes > $REPORT_DIR/check_routes.after_maxcap_eco.rpt
check_legality > $REPORT_DIR/check_legality.after_maxcap_eco.rpt
check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.after_maxcap_eco.rpt \
  > $REPORT_DIR/pg_connectivity.after_maxcap_eco.rpt
check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $REPORT_DIR/pg_drc.after_maxcap_eco.rpt
report_timing -delay_type max -max_paths 20 > $REPORT_DIR/timing.max.after_maxcap_eco.rpt
report_timing -delay_type min -max_paths 20 > $REPORT_DIR/timing.min.after_maxcap_eco.rpt

set WRITE_V_STATUS [catch {write_verilog $NETLIST_OUT} WRITE_V_MSG]
set WRITE_SDC_STATUS [catch {write_sdc -output $SDC_OUT} WRITE_SDC_MSG]
set WRITE_SDF_STATUS [catch {write_sdf $SDF_OUT} WRITE_SDF_MSG]
set WRITE_DEF_STATUS [catch {write_def $DEF_OUT} WRITE_DEF_MSG]

save_block
save_lib

set FP [open $MANIFEST w]
puts $FP "source_block=$SRC_BLOCK"
puts $FP "eco_block=$ECO_BLOCK"
puts $FP "icc2_lib=$MAXCAP_ECO_LIB"
puts $FP "report_dir=$REPORT_DIR"
puts $FP "output_dir=$OUTPUT_DIR"
puts $FP "eco_command=eco_opt -types max_capacitance -physical_mode $PHYSICAL_MODE"
puts $FP "pt_exec=$PT_EXEC"
puts $FP "pt_work_dir=$PT_WORK_DIR"
puts $FP "eco_status=$ECO_STATUS"
puts $FP "eco_message=$ECO_MSG"
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

if {$ECO_STATUS != 0} {
  error "max-cap ECO failed: $ECO_MSG"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0} {
  error "max-cap ECO export failed. See $MANIFEST"
}

exit
