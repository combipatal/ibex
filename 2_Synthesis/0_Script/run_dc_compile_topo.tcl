################################################################################
# Ibex Mini SoC DC Graphical topographical compile script
#
# Purpose:
#   Synthesize the frozen Ibex Mini SoC baseline with physical guidance and emit
#   a matched handoff set for Formality and STA.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
set TOP_DESIGN ibex_mini_soc_top
set RUN_TAG pre_backend_topo

cd $PROJECT_ROOT

if {![shell_is_in_topographical_mode]} {
  puts "ERROR: run with dc_shell -topographical_mode -f 2_Synthesis/0_Script/run_dc_compile_topo.tcl"
  exit 1
}

source configs/library_setup.tcl
source filelists/ibex_mini_soc_dc.tcl

set TECH_FILE /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
set TLUPLUS_MAX /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
set TLUPLUS_MIN /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
set TLUPLUS_MAP /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

set MW_RVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
set MW_LVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m
set MW_HVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m
set MW_DESIGN_LIB 2_Synthesis/mw_lib/${TOP_DESIGN}_${RUN_TAG}_mw

file delete -force 2_Synthesis/work_topo
file delete -force 2_Synthesis/2_Output/${RUN_TAG}
file delete -force 2_Synthesis/4_Report/topo
file delete -force $MW_DESIGN_LIB

file mkdir 2_Synthesis/2_Output/${RUN_TAG}
file mkdir 2_Synthesis/2_Output/svf
file mkdir 2_Synthesis/3_Log
file mkdir 2_Synthesis/4_Report/topo
file mkdir 2_Synthesis/work_topo
file mkdir 2_Synthesis/mw_lib

define_design_lib WORK -path 2_Synthesis/work_topo

create_mw_lib \
  -technology $TECH_FILE \
  -mw_reference_library [list $MW_RVT $MW_LVT $MW_HVT] \
  -hier_separator {/} \
  -bus_naming_style {%d} \
  -open $MW_DESIGN_LIB

set_tlu_plus_files \
  -max_tluplus $TLUPLUS_MAX \
  -min_tluplus $TLUPLUS_MIN \
  -tech2itf_map $TLUPLUS_MAP

check_tlu_plus_files > 2_Synthesis/4_Report/topo/tlu_plus.check.rpt
check_library > 2_Synthesis/4_Report/topo/library.check.rpt

set_app_var search_path [concat $search_path $RTL_INC_DIRS]
set_app_var compile_ultra_ungroup_dw false
set_app_var hdlin_enable_hier_map true
set_app_var hdlin_verification_priority true

set_svf 2_Synthesis/2_Output/svf/${TOP_DESIGN}.${RUN_TAG}.svf

analyze -format sverilog -define $RTL_DEFINES $RTL_FILES
elaborate $TOP_DESIGN
current_design $TOP_DESIGN
set_verification_top
link
uniquify

check_design > 2_Synthesis/4_Report/topo/pre_compile.check_design.rpt

read_sdc constraints/ibex_mini_soc_10ns.sdc
check_timing > 2_Synthesis/4_Report/topo/pre_compile.check_timing.rpt

set_fix_multiple_port_nets -all -buffer_constants

compile_ultra -spg
set_svf -off

check_design > 2_Synthesis/4_Report/topo/post_compile.check_design.rpt
check_timing > 2_Synthesis/4_Report/topo/post_compile.check_timing.rpt
report_qor > 2_Synthesis/4_Report/topo/post_compile.qor.rpt
report_timing -delay_type max -max_paths 50 > 2_Synthesis/4_Report/topo/post_compile.setup_timing.rpt
report_timing -delay_type min -max_paths 50 > 2_Synthesis/4_Report/topo/post_compile.hold_timing.rpt
report_area -hierarchy > 2_Synthesis/4_Report/topo/post_compile.area_hierarchy.rpt
report_power -hierarchy > 2_Synthesis/4_Report/topo/post_compile.power_hierarchy.rpt
report_constraint -all_violators > 2_Synthesis/4_Report/topo/post_compile.constraints.rpt
report_reference -hierarchy > 2_Synthesis/4_Report/topo/post_compile.reference_hierarchy.rpt

write -format ddc -hierarchy -output 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.ddc

change_names -rules verilog -hierarchy

write -format verilog -hierarchy -output 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.vg
write_sdc 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.sdc
write_sdf 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.sdf

close_mw_lib
exit
