################################################################################
# Ibex Mini SoC PrimeTime pre-backend topo/SDF STA script
#
# Purpose:
#   Run STA on the netlist/SDC/SDF emitted by the same DC topographical compile
#   run that emits the Formality SVF.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
set TOP_DESIGN ibex_mini_soc_top
set RUN_TAG pre_backend_topo

cd $PROJECT_ROOT

set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set NETLIST 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.vg
set SDC_FILE 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.sdc
set SDF_FILE 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.sdf
set SVF_FILE 2_Synthesis/2_Output/svf/${TOP_DESIGN}.${RUN_TAG}.svf

file mkdir 5_STA/3_Log
file mkdir 5_STA/4_Report/${RUN_TAG}

set link_path [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

puts "INFO: SVF provenance file for matching Formality run: $SVF_FILE"
puts "INFO: PrimeTime does not read SVF; STA reads matched netlist/SDC/SDF from the same DC topo run."

read_verilog $NETLIST
current_design $TOP_DESIGN
link_design

read_sdc $SDC_FILE
read_sdf $SDF_FILE

check_timing -verbose > 5_STA/4_Report/${RUN_TAG}/check_timing.rpt
report_global_timing > 5_STA/4_Report/${RUN_TAG}/global_timing.rpt
report_timing -delay_type max -max_paths 50 -slack_lesser_than 100 > 5_STA/4_Report/${RUN_TAG}/setup_timing.rpt
report_timing -delay_type min -max_paths 50 -slack_lesser_than 100 > 5_STA/4_Report/${RUN_TAG}/hold_timing.rpt
report_constraint -all_violators > 5_STA/4_Report/${RUN_TAG}/constraints.rpt
report_analysis_coverage > 5_STA/4_Report/${RUN_TAG}/coverage.rpt
report_annotated_delay > 5_STA/4_Report/${RUN_TAG}/annotated_delay.rpt

exit
