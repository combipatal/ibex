################################################################################
# Ibex Mini SoC DC analyze/elaborate/link smoke script
#
# Purpose:
#   Prove that the selected RTL/config/filelist can elaborate before full compile.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
cd $PROJECT_ROOT

source configs/library_setup.tcl
source filelists/ibex_mini_soc_dc.tcl

file mkdir 2_Synthesis/2_Output/analyze
file mkdir 2_Synthesis/3_Log
file mkdir 2_Synthesis/4_Report/analyze
file delete -force 2_Synthesis/work_analyze
file mkdir 2_Synthesis/work_analyze

define_design_lib WORK -path 2_Synthesis/work_analyze

set_app_var search_path [concat $search_path $RTL_INC_DIRS]

analyze -format sverilog -define $RTL_DEFINES $RTL_FILES
elaborate ibex_mini_soc_top
current_design ibex_mini_soc_top
link

check_design > 2_Synthesis/4_Report/analyze/check_design.rpt
report_hierarchy > 2_Synthesis/4_Report/analyze/hierarchy.rpt
write -format ddc -hierarchy -output 2_Synthesis/2_Output/analyze/ibex_mini_soc_top.elab.ddc

exit
