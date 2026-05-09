################################################################################
# ICC2 init_design sanity check for the DC topo handoff.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[file exists $ICC2_LIB_DIR]} {
  file delete -force $ICC2_LIB_DIR
}

create_lib $ICC2_LIB_DIR \
  -technology $TECH_FILE \
  -ref_libs [list $NDM_RVT $NDM_LVT $NDM_HVT]

read_parasitic_tech \
  -tlup $TLUPLUS_MAX \
  -layermap $TLUPLUS_MAP \
  -name saed32_cmax

read_parasitic_tech \
  -tlup $TLUPLUS_MIN \
  -layermap $TLUPLUS_MAP \
  -name saed32_cmin

read_verilog $BACKEND_NETLIST
current_design $TOP_NAME
link_block

read_sdc $BACKEND_SDC

set_parasitic_parameters \
  -early_spec saed32_cmin \
  -early_temperature 25 \
  -late_spec saed32_cmax \
  -late_temperature 25

report_ref_libs > $INIT_REPORT_DIR/ref_libs.rpt
report_parasitic_parameters > $INIT_REPORT_DIR/parasitic_parameters.rpt
report_design -physical > $INIT_REPORT_DIR/design_physical.rpt
report_design > $INIT_REPORT_DIR/design.rpt

check_design \
  -checks {netlist design_mismatch timing} \
  -ems_database $INIT_REPORT_DIR/check_design.ems \
  -log_file $INIT_REPORT_DIR/check_design.rpt

report_timing -max_paths 10 > $INIT_REPORT_DIR/timing.rpt

save_block
save_lib

exit

