################################################################################
# Ibex Mini SoC Formality check for post-route residual max-cap ECO netlist.
#
# Purpose:
#   Prove that the final ICC2/PrimeTime ECO netlist remains equivalent to the
#   frozen RTL reference after post-route buffer insertion/cell sizing.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
set TOP_DESIGN ibex_mini_soc_top
set RUN_TAG post_route_residual_maxcap_eco
set REF_RUN_TAG pre_backend_topo_nor2_mux41_no_x0x2_hvt

if {[info exists ::env(FM_RUN_TAG)] && $::env(FM_RUN_TAG) ne ""} {
  set RUN_TAG $::env(FM_RUN_TAG)
}
if {[info exists ::env(FM_REF_RUN_TAG)] && $::env(FM_REF_RUN_TAG) ne ""} {
  set REF_RUN_TAG $::env(FM_REF_RUN_TAG)
}

cd $PROJECT_ROOT

set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set REF_FILELIST filelists/ibex_mini_soc_fm_ref.f
set IMPL_NETLIST 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/${TOP_DESIGN}.post_route_residual_maxcap_eco.vg
set SVF_FILE 2_Synthesis/2_Output/svf/${TOP_DESIGN}.${REF_RUN_TAG}.svf

if {[info exists ::env(FM_IMPL_NETLIST)] && $::env(FM_IMPL_NETLIST) ne ""} {
  set IMPL_NETLIST $::env(FM_IMPL_NETLIST)
}
if {[info exists ::env(FM_SVF_FILE)] && $::env(FM_SVF_FILE) ne ""} {
  set SVF_FILE $::env(FM_SVF_FILE)
}

set REPORT_DIR 3_Formality/4_Report/${RUN_TAG}
set OUTPUT_DIR 3_Formality/2_Output/${RUN_TAG}

file mkdir 3_Formality/3_Log
file mkdir $REPORT_DIR
file mkdir $OUTPUT_DIR
file mkdir 3_Formality/FM_WORK

if {![file exists $IMPL_NETLIST]} {
  error "Missing implementation netlist: $IMPL_NETLIST"
}
if {![file exists $SVF_FILE]} {
  error "Missing SVF guidance file: $SVF_FILE"
}

set_app_var synopsys_auto_setup true
set_app_var verification_set_undriven_signals synthesis
set_app_var verification_clock_gate_reverse_gating true
set_app_var verification_failing_point_limit 1000
set_app_var verification_timeout_limit 08:00:00

suppress_message FMR_ELAB-116

read_db -technology_library [list $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

set_svf $SVF_FILE

read_sverilog -r -12 -libname WORK -f $REF_FILELIST
set_top r:/WORK/$TOP_DESIGN
set_clock r:/WORK/$TOP_DESIGN/clk_i

set_dont_verify_points -directly_undriven_output

read_verilog -i -libname WORK $IMPL_NETLIST
set_top i:/WORK/$TOP_DESIGN
set_clock i:/WORK/$TOP_DESIGN/clk_i

match

report_setup_status > $REPORT_DIR/${RUN_TAG}.setup_status.rpt
report_svf_operation -status accepted > $REPORT_DIR/${RUN_TAG}.svf_accepted.rpt
report_svf_operation -status rejected > $REPORT_DIR/${RUN_TAG}.svf_rejected.rpt
report_unmatched_points > $REPORT_DIR/${RUN_TAG}.unmatched_points.rpt
report_passing_points > $REPORT_DIR/${RUN_TAG}.passing_points.rpt

set verify_status [verify]

report_failing_points > $REPORT_DIR/${RUN_TAG}.failing_points.rpt
report_aborted_points > $REPORT_DIR/${RUN_TAG}.aborted_points.rpt
report_unverified_points > $REPORT_DIR/${RUN_TAG}.unverified_points.rpt
report_unmatched_points > $REPORT_DIR/${RUN_TAG}.unmatched_points.post_verify.rpt
report_passing_points > $REPORT_DIR/${RUN_TAG}.passing_points.post_verify.rpt
report_dont_verify_points > $REPORT_DIR/${RUN_TAG}.dont_verify_points.rpt
report_constants > $REPORT_DIR/${RUN_TAG}.constants.rpt

save_session -replace $OUTPUT_DIR/${RUN_TAG}_fm_session

if {$verify_status != 1} {
  puts "ERROR: Formality post-route ECO verification failed for $TOP_DESIGN."
  exit 2
}

puts "INFO: Formality post-route ECO verification passed for $TOP_DESIGN."
exit
