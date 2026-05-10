################################################################################
# Ibex Mini SoC Formality R2N script
#
# Purpose:
#   Compare frozen RTL reference against the DC topographical mapped design.
#   The SVF emitted by the same DC run is mandatory guidance for this R2N check.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
set TOP_DESIGN ibex_mini_soc_top
if {[info exists ::env(FM_RUN_TAG)] && $::env(FM_RUN_TAG) ne ""} {
  set RUN_TAG $::env(FM_RUN_TAG)
} else {
  set RUN_TAG pre_backend_topo
}

cd $PROJECT_ROOT

set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set REF_FILELIST filelists/ibex_mini_soc_fm_ref.f
set IMPL_DDC 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.ddc
set SVF_FILE 2_Synthesis/2_Output/svf/${TOP_DESIGN}.${RUN_TAG}.svf

set REPORT_DIR 3_Formality/4_Report/${RUN_TAG}
set OUTPUT_DIR 3_Formality/2_Output/${RUN_TAG}

file mkdir 3_Formality/3_Log
file mkdir $REPORT_DIR
file mkdir $OUTPUT_DIR
file mkdir 3_Formality/FM_WORK

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

read_ddc -i $IMPL_DDC
set_top i:/WORK/$TOP_DESIGN
set_clock i:/WORK/$TOP_DESIGN/clk_i

match

report_setup_status > $REPORT_DIR/r2n_topo.setup_status.rpt
report_svf_operation -status accepted > $REPORT_DIR/r2n_topo.svf_accepted.rpt
report_svf_operation -status rejected > $REPORT_DIR/r2n_topo.svf_rejected.rpt
report_unmatched_points > $REPORT_DIR/r2n_topo.unmatched_points.rpt
report_passing_points > $REPORT_DIR/r2n_topo.passing_points.rpt

set verify_status [verify]

report_failing_points > $REPORT_DIR/r2n_topo.failing_points.rpt
report_aborted_points > $REPORT_DIR/r2n_topo.aborted_points.rpt
report_unverified_points > $REPORT_DIR/r2n_topo.unverified_points.rpt
report_unmatched_points > $REPORT_DIR/r2n_topo.unmatched_points.post_verify.rpt
report_passing_points > $REPORT_DIR/r2n_topo.passing_points.post_verify.rpt
report_dont_verify_points > $REPORT_DIR/r2n_topo.dont_verify_points.rpt
report_constants > $REPORT_DIR/r2n_topo.constants.rpt

save_session -replace $OUTPUT_DIR/r2n_topo_fm_session

if {$verify_status != 1} {
  puts "ERROR: Formality R2N verification failed for $TOP_DESIGN."
  exit 2
}

puts "INFO: Formality R2N verification passed for $TOP_DESIGN."
exit
