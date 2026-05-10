################################################################################
# Pre-filler max-cap margin ECO for the residual max-cap clean block.
#
# The 12_post_route_residual_maxcap_eco block is electrically clean before
# filler. GDS filler insertion/reconnect slightly increases extracted cap on
# several near-limit nets. This script adds driver-pin max-cap margin before
# filler, then lets ECO choose buffer insertion/sizing and exports a new
# functional post-route netlist for FM/PT.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set MARGIN_LIB $PROJECT_ROOT/4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/ibex_mini_soc_top_post_route_prefiller_maxcap_margin_icc2_lib
set SRC_BLOCK ${TOP_NAME}_post_route_residual_maxcap_eco
set MARGIN_BLOCK ${TOP_NAME}_post_route_prefiller_maxcap_margin
set REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/14_post_route_prefiller_maxcap_margin
set OUTPUT_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/export
set SESSION_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/pt_eco_session
set PT_WORK_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/pt_work
set PT_EXEC /tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell
set PHYSICAL_MODE occupied_site

if {[info exists ::env(MARGIN_LIB)] && $::env(MARGIN_LIB) ne ""} {
  set MARGIN_LIB $::env(MARGIN_LIB)
}
if {[info exists ::env(SRC_BLOCK)] && $::env(SRC_BLOCK) ne ""} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(MARGIN_BLOCK)] && $::env(MARGIN_BLOCK) ne ""} {
  set MARGIN_BLOCK $::env(MARGIN_BLOCK)
}
if {[info exists ::env(MARGIN_REPORT_DIR)] && $::env(MARGIN_REPORT_DIR) ne ""} {
  set REPORT_DIR $::env(MARGIN_REPORT_DIR)
}
if {[info exists ::env(MARGIN_OUTPUT_DIR)] && $::env(MARGIN_OUTPUT_DIR) ne ""} {
  set OUTPUT_DIR $::env(MARGIN_OUTPUT_DIR)
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

set NETLIST_OUT $OUTPUT_DIR/${TOP_NAME}.post_route_prefiller_maxcap_margin.vg
set DEF_OUT     $OUTPUT_DIR/${TOP_NAME}.post_route_prefiller_maxcap_margin.def
set SDC_OUT     $OUTPUT_DIR/${TOP_NAME}.post_route_prefiller_maxcap_margin.sdc
set SDF_OUT     $OUTPUT_DIR/${TOP_NAME}.post_route_prefiller_maxcap_margin.sdf
set MANIFEST    $OUTPUT_DIR/post_route_prefiller_maxcap_margin_manifest.txt

set target_maxcap_pin_pairs {
  U77216/Y 7.50
  U13303/Y 15.50
  ZBUF_1069_inst_8294/Y 15.50
  ZBUF_259_inst_8705/Y 15.50
  U7539/Y 7.50
}

open_lib $MARGIN_LIB
copy_block -from_block $SRC_BLOCK -to_block $MARGIN_BLOCK
current_block $MARGIN_BLOCK

check_routes > $REPORT_DIR/check_routes.before_margin.rpt
check_legality > $REPORT_DIR/check_legality.before_margin.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_margin.rpt
report_qor > $REPORT_DIR/qor.before_margin.rpt

set target_status ok
set target_rpt [open $REPORT_DIR/target_maxcap_pins.tsv w]
puts $target_rpt "pin\tmargin_max_cap\tstatus"
foreach {pin_name margin_cap} $target_maxcap_pin_pairs {
  set pin_obj [get_pins -quiet $pin_name]
  if {[sizeof_collection $pin_obj] == 0} {
    puts $target_rpt "$pin_name\t$margin_cap\tmissing_pin"
    set target_status missing_pin
    continue
  }
  if {[catch {set_max_capacitance $margin_cap $pin_obj} err]} {
    puts $target_rpt "$pin_name\t$margin_cap\terror:$err"
    set target_status set_max_cap_error
  } else {
    puts $target_rpt "$pin_name\t$margin_cap\tok"
  }
}
close $target_rpt

report_constraints -all_violators > $REPORT_DIR/constraints.after_margin_targets.rpt

set_pt_options -pt_exec $PT_EXEC -work_dir $PT_WORK_DIR
report_pt_options > $REPORT_DIR/pt_options.rpt
set_app_options -name extract.starrc_mode -value false

set ECO_STATUS [catch {
  eco_opt -types max_capacitance -physical_mode $PHYSICAL_MODE -save_session $SESSION_DIR
} ECO_MSG]

report_qor > $REPORT_DIR/qor.after_margin_eco.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_margin_eco.rpt
check_routes > $REPORT_DIR/check_routes.after_margin_eco.rpt
check_legality > $REPORT_DIR/check_legality.after_margin_eco.rpt

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

check_routes > $REPORT_DIR/check_routes.final.rpt
check_legality > $REPORT_DIR/check_legality.final.rpt
check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.final.rpt \
  > $REPORT_DIR/pg_connectivity.final.rpt
check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $REPORT_DIR/pg_drc.final.rpt
report_qor > $REPORT_DIR/qor.final.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.final.rpt
report_timing -delay_type max -max_paths 20 > $REPORT_DIR/timing.max.final.rpt
report_timing -delay_type min -max_paths 20 > $REPORT_DIR/timing.min.final.rpt

set WRITE_V_STATUS [catch {write_verilog $NETLIST_OUT} WRITE_V_MSG]
set WRITE_DEF_STATUS [catch {write_def $DEF_OUT} WRITE_DEF_MSG]
set WRITE_SDC_STATUS [catch {write_sdc -output $SDC_OUT} WRITE_SDC_MSG]
set WRITE_SDF_STATUS [catch {write_sdf $SDF_OUT} WRITE_SDF_MSG]

save_block
save_lib

set FP [open $MANIFEST w]
puts $FP "source_block=$SRC_BLOCK"
puts $FP "margin_block=$MARGIN_BLOCK"
puts $FP "icc2_lib=$MARGIN_LIB"
puts $FP "report_dir=$REPORT_DIR"
puts $FP "output_dir=$OUTPUT_DIR"
puts $FP "target_maxcap_pin_pairs=$target_maxcap_pin_pairs"
puts $FP "target_status=$target_status"
puts $FP "eco_command=eco_opt -types max_capacitance -physical_mode $PHYSICAL_MODE"
puts $FP "pt_exec=$PT_EXEC"
puts $FP "pt_work_dir=$PT_WORK_DIR"
puts $FP "eco_status=$ECO_STATUS"
puts $FP "eco_message=$ECO_MSG"
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
puts $FP "write_def_status=$WRITE_DEF_STATUS"
puts $FP "write_def_message=$WRITE_DEF_MSG"
puts $FP "write_sdc_status=$WRITE_SDC_STATUS"
puts $FP "write_sdc_message=$WRITE_SDC_MSG"
puts $FP "write_sdf_status=$WRITE_SDF_STATUS"
puts $FP "write_sdf_message=$WRITE_SDF_MSG"
close $FP

if {$target_status ne "ok"} {
  error "pre-filler margin target setup failed. See $REPORT_DIR/target_maxcap_pins.tsv"
}
if {$ECO_STATUS != 0 || $ROUTE_DETAIL_STATUS != 0 || $ROUTE_ECO_STATUS != 0} {
  error "pre-filler margin route cleanup failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0} {
  error "pre-filler margin export failed. See $MANIFEST"
}

exit
