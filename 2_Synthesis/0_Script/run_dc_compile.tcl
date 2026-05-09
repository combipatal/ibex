################################################################################
# Ibex Mini SoC DC compile script
#
# Purpose:
#   Synthesize the frozen Ibex Mini SoC baseline with the same top/config/filelist
#   used by the DC analyze smoke run.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
set TOP_DESIGN ibex_mini_soc_top

cd $PROJECT_ROOT

source configs/library_setup.tcl
source filelists/ibex_mini_soc_dc.tcl

file delete -force 2_Synthesis/work_compile
file delete -force 2_Synthesis/2_Output/mapped
file delete -force 2_Synthesis/4_Report/compile

file mkdir 2_Synthesis/2_Output/mapped
file mkdir 2_Synthesis/3_Log
file mkdir 2_Synthesis/4_Report/compile
file mkdir 2_Synthesis/work_compile

define_design_lib WORK -path 2_Synthesis/work_compile

set_app_var search_path [concat $search_path $RTL_INC_DIRS]
set_app_var compile_ultra_ungroup_dw false

set_svf 2_Synthesis/2_Output/mapped/${TOP_DESIGN}.svf

analyze -format sverilog -define $RTL_DEFINES $RTL_FILES
elaborate $TOP_DESIGN
current_design $TOP_DESIGN
link
uniquify

check_design > 2_Synthesis/4_Report/compile/check_design_pre_compile.rpt

source constraints/ibex_mini_soc_10ns.sdc
check_timing > 2_Synthesis/4_Report/compile/check_timing_pre_compile.rpt

set_fix_multiple_port_nets -all -buffer_constants

compile_ultra -no_autoungroup

check_design > 2_Synthesis/4_Report/compile/check_design_post_compile.rpt
check_timing > 2_Synthesis/4_Report/compile/check_timing_post_compile.rpt
report_qor > 2_Synthesis/4_Report/compile/qor.rpt
report_timing -delay_type max -max_paths 50 > 2_Synthesis/4_Report/compile/timing_setup.rpt
report_timing -delay_type min -max_paths 50 > 2_Synthesis/4_Report/compile/timing_hold.rpt
report_area -hierarchy > 2_Synthesis/4_Report/compile/area_hierarchy.rpt
report_power -hierarchy > 2_Synthesis/4_Report/compile/power_hierarchy.rpt
report_constraint -all_violators > 2_Synthesis/4_Report/compile/constraints_violators.rpt
report_reference -hierarchy > 2_Synthesis/4_Report/compile/reference_hierarchy.rpt

write -format ddc -hierarchy -output 2_Synthesis/2_Output/mapped/${TOP_DESIGN}.mapped.ddc

change_names -rules verilog -hierarchy

write -format verilog -hierarchy -output 2_Synthesis/2_Output/mapped/${TOP_DESIGN}.mapped.v
write_sdc 2_Synthesis/2_Output/mapped/${TOP_DESIGN}.mapped.sdc
write_sdf 2_Synthesis/2_Output/mapped/${TOP_DESIGN}.mapped.sdf

set_svf -off

exit
