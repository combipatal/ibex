################################################################################
# Ibex Mini SoC PrimeTime final post-route ECO/SDF STA script
#
# Purpose:
#   Run final educational STA on the netlist/SDC/SDF exported from the ICC2
#   residual max-cap ECO clean candidate.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
set TOP_DESIGN ibex_mini_soc_top
set RUN_TAG post_route_residual_maxcap_eco

if {[info exists ::env(PT_RUN_TAG)] && $::env(PT_RUN_TAG) ne ""} {
  set RUN_TAG $::env(PT_RUN_TAG)
}

cd $PROJECT_ROOT

set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set NETLIST 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/${TOP_DESIGN}.post_route_residual_maxcap_eco.vg
set SDC_FILE 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/${TOP_DESIGN}.post_route_residual_maxcap_eco.sdc
set SDF_FILE 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/${TOP_DESIGN}.post_route_residual_maxcap_eco.sdf
set FM_LOG 3_Formality/3_Log/fm_post_route_residual_maxcap_eco.log
set REPORT_DIR 5_STA/4_Report/${RUN_TAG}

if {[info exists ::env(PT_NETLIST)] && $::env(PT_NETLIST) ne ""} {
  set NETLIST $::env(PT_NETLIST)
}
if {[info exists ::env(PT_SDC_FILE)] && $::env(PT_SDC_FILE) ne ""} {
  set SDC_FILE $::env(PT_SDC_FILE)
}
if {[info exists ::env(PT_SDF_FILE)] && $::env(PT_SDF_FILE) ne ""} {
  set SDF_FILE $::env(PT_SDF_FILE)
}

file mkdir 5_STA/3_Log
file mkdir $REPORT_DIR

foreach required [list $NETLIST $SDC_FILE $SDF_FILE] {
  if {![file exists $required]} {
    error "Missing PrimeTime input: $required"
  }
}

set link_path [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

puts "INFO: Formality provenance log for this final ECO netlist: $FM_LOG"
puts "INFO: PrimeTime does not read SVF; STA reads final ECO netlist/SDC/SDF."

read_verilog $NETLIST
current_design $TOP_DESIGN
link_design

read_sdc $SDC_FILE
read_sdf $SDF_FILE

check_timing -verbose > $REPORT_DIR/check_timing.rpt
report_global_timing > $REPORT_DIR/global_timing.rpt
report_timing -delay_type max -max_paths 50 -slack_lesser_than 100 > $REPORT_DIR/setup_timing.rpt
report_timing -delay_type min -max_paths 50 -slack_lesser_than 100 > $REPORT_DIR/hold_timing.rpt
report_constraint -all_violators > $REPORT_DIR/constraints.rpt
report_analysis_coverage > $REPORT_DIR/coverage.rpt
report_annotated_delay > $REPORT_DIR/annotated_delay.rpt
report_qor > $REPORT_DIR/qor.rpt

exit
