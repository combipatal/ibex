################################################################################
# Ibex Mini SoC ICC2 common setup
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
cd $PROJECT_ROOT

set TOP_NAME ibex_mini_soc_top
set RUN_TAG pre_backend_topo

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK

set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB $SAED32_ROOT/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB $SAED32_ROOT/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set MW_RVT $SAED32_ROOT/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
set MW_LVT $SAED32_ROOT/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m
set MW_HVT $SAED32_ROOT/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m

set NDM_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/00_setup/ndm
set NDM_RVT $NDM_DIR/saed32rvt_tt.ndm
set NDM_LVT $NDM_DIR/saed32lvt_tt.ndm
set NDM_HVT $NDM_DIR/saed32hvt_tt.ndm

if {[info exists ::env(NDM_RVT)]} {
  set NDM_RVT $::env(NDM_RVT)
}
if {[info exists ::env(NDM_LVT)]} {
  set NDM_LVT $::env(NDM_LVT)
}
if {[info exists ::env(NDM_HVT)]} {
  set NDM_HVT $::env(NDM_HVT)
}

set TECH_FILE $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf
set TLUPLUS_MAX $SAED32_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
set TLUPLUS_MIN $SAED32_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
set TLUPLUS_MAP $SAED32_ROOT/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

if {[info exists ::env(TECH_FILE)] && $::env(TECH_FILE) ne ""} {
  set TECH_FILE $::env(TECH_FILE)
}

set BACKEND_NETLIST $PROJECT_ROOT/2_Synthesis/2_Output/$RUN_TAG/$TOP_NAME.$RUN_TAG.vg
set BACKEND_SDC     $PROJECT_ROOT/2_Synthesis/2_Output/$RUN_TAG/$TOP_NAME.$RUN_TAG.sdc

if {[info exists ::env(BACKEND_NETLIST)]} {
  set BACKEND_NETLIST $::env(BACKEND_NETLIST)
}
if {[info exists ::env(BACKEND_SDC)]} {
  set BACKEND_SDC $::env(BACKEND_SDC)
}

set ICC2_ROOT $PROJECT_ROOT/4_Backend_ICC2
set SETUP_LOG_DIR $ICC2_ROOT/3_Log/00_setup
set ICC2_LIB_DIR $ICC2_ROOT/2_Output/01_init_design/${TOP_NAME}_icc2_lib
set INIT_REPORT_DIR $ICC2_ROOT/4_Report/01_init_design
set FLOORPLAN_REPORT_DIR $ICC2_ROOT/4_Report/02_floorplan
set POWERPLAN_REPORT_DIR $ICC2_ROOT/4_Report/03_powerplan
set PLACE_REPORT_DIR $ICC2_ROOT/4_Report/04_place
set CTS_REPORT_DIR $ICC2_ROOT/4_Report/05_cts
set ROUTE_REPORT_DIR $ICC2_ROOT/4_Report/06_route

if {[info exists ::env(ICC2_LIB_DIR)]} {
  set ICC2_LIB_DIR $::env(ICC2_LIB_DIR)
}

if {[info exists ::env(ICC2_REPORT_ROOT)]} {
  set INIT_REPORT_DIR $::env(ICC2_REPORT_ROOT)/01_init_design
  set FLOORPLAN_REPORT_DIR $::env(ICC2_REPORT_ROOT)/02_floorplan
  set POWERPLAN_REPORT_DIR $::env(ICC2_REPORT_ROOT)/03_powerplan
  set PLACE_REPORT_DIR $::env(ICC2_REPORT_ROOT)/04_place
  set CTS_REPORT_DIR $::env(ICC2_REPORT_ROOT)/05_cts
  set ROUTE_REPORT_DIR $::env(ICC2_REPORT_ROOT)/06_route
}

foreach dir [list \
  $ICC2_ROOT/2_Output/00_setup \
  $ICC2_ROOT/2_Output/01_init_design \
  $ICC2_ROOT/2_Output/02_floorplan \
  $ICC2_ROOT/2_Output/03_powerplan \
  $ICC2_ROOT/2_Output/04_place \
  $ICC2_ROOT/2_Output/05_cts \
  $ICC2_ROOT/2_Output/06_route \
  $ICC2_ROOT/3_Log/00_setup \
  $ICC2_ROOT/3_Log/01_init_design \
  $ICC2_ROOT/3_Log/02_floorplan \
  $ICC2_ROOT/3_Log/03_powerplan \
  $ICC2_ROOT/3_Log/04_place \
  $ICC2_ROOT/3_Log/05_cts \
  $ICC2_ROOT/3_Log/06_route \
  $INIT_REPORT_DIR \
  $FLOORPLAN_REPORT_DIR \
  $POWERPLAN_REPORT_DIR \
  $PLACE_REPORT_DIR \
  $CTS_REPORT_DIR \
  $ROUTE_REPORT_DIR \
] {
  file mkdir $dir
}

set target_library [list $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]
set link_library [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]
