################################################################################
# Ibex Mini SoC DC Graphical topographical compile debug variant.
#
# Purpose:
#   Re-synthesize with a narrow NOR2 cell-use policy to test whether residual
#   backend Off-grid DRC tied to NOR2 A1/VSS pin access improves in a clean
#   FE-to-BE rerun. This is debug-only and does not replace pre_backend_topo.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
set TOP_DESIGN ibex_mini_soc_top

if {[info exists ::env(NOR2_POLICY_RUN_TAG)] && $::env(NOR2_POLICY_RUN_TAG) ne ""} {
  set RUN_TAG $::env(NOR2_POLICY_RUN_TAG)
} else {
  set RUN_TAG pre_backend_topo_nor2_no_x0x2_hvt
}

if {[info exists ::env(NOR2_POLICY_DONT_USE)] && $::env(NOR2_POLICY_DONT_USE) ne ""} {
  set NOR2_DONT_USE_LIST $::env(NOR2_POLICY_DONT_USE)
} else {
  set NOR2_DONT_USE_LIST {NOR2X0_HVT NOR2X2_HVT}
}

cd $PROJECT_ROOT

if {![shell_is_in_topographical_mode]} {
  puts "ERROR: run with dc_shell -topographical_mode -f 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.tcl"
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

file delete -force 2_Synthesis/work_topo_${RUN_TAG}
file delete -force 2_Synthesis/2_Output/${RUN_TAG}
file delete -force 2_Synthesis/4_Report/99_debug/${RUN_TAG}
file delete -force $MW_DESIGN_LIB

file mkdir 2_Synthesis/2_Output/${RUN_TAG}
file mkdir 2_Synthesis/2_Output/svf
file mkdir 2_Synthesis/3_Log/99_debug
file mkdir 2_Synthesis/4_Report/99_debug/${RUN_TAG}
file mkdir 2_Synthesis/work_topo_${RUN_TAG}
file mkdir 2_Synthesis/mw_lib

define_design_lib WORK -path 2_Synthesis/work_topo_${RUN_TAG}

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

set REPORT_DIR 2_Synthesis/4_Report/99_debug/${RUN_TAG}

check_tlu_plus_files > $REPORT_DIR/tlu_plus.check.rpt
check_library > $REPORT_DIR/library.check.rpt

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

check_design > $REPORT_DIR/pre_compile.check_design.rpt

read_sdc constraints/ibex_mini_soc_10ns.sdc
check_timing > $REPORT_DIR/pre_compile.check_timing.rpt

set policy_fh [open $REPORT_DIR/nor2_dont_use_policy.rpt w]
puts $policy_fh "run_tag\t$RUN_TAG"
puts $policy_fh "dont_use_list\t$NOR2_DONT_USE_LIST"
foreach ref_name $NOR2_DONT_USE_LIST {
  set cells [get_lib_cells -quiet */$ref_name]
  set count [sizeof_collection $cells]
  puts $policy_fh "$ref_name\t$count"
  if {$count > 0} {
    set_dont_use $cells
  }
}
close $policy_fh

set verify_fh [open $REPORT_DIR/nor2_dont_use_verify.rpt w]
puts $verify_fh "ref_name\tlib_cell\tdont_use"
foreach ref_name $NOR2_DONT_USE_LIST {
  foreach_in_collection cell [get_lib_cells -quiet */$ref_name] {
    puts $verify_fh "$ref_name\t[get_object_name $cell]\t[get_attribute $cell dont_use]"
  }
}
close $verify_fh

set_fix_multiple_port_nets -all -buffer_constants

compile_ultra -spg
set_svf -off

check_design > $REPORT_DIR/post_compile.check_design.rpt
check_timing > $REPORT_DIR/post_compile.check_timing.rpt
report_qor > $REPORT_DIR/post_compile.qor.rpt
report_timing -delay_type max -max_paths 50 > $REPORT_DIR/post_compile.setup_timing.rpt
report_timing -delay_type min -max_paths 50 > $REPORT_DIR/post_compile.hold_timing.rpt
report_area -hierarchy > $REPORT_DIR/post_compile.area_hierarchy.rpt
report_power -hierarchy > $REPORT_DIR/post_compile.power_hierarchy.rpt
report_constraint -all_violators > $REPORT_DIR/post_compile.constraints.rpt
report_reference -hierarchy > $REPORT_DIR/post_compile.reference_hierarchy.rpt

write -format ddc -hierarchy -output 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.ddc

change_names -rules verilog -hierarchy

write -format verilog -hierarchy -output 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.vg
write_sdc 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.sdc
write_sdf 2_Synthesis/2_Output/${RUN_TAG}/${TOP_DESIGN}.${RUN_TAG}.sdf

close_mw_lib
exit
