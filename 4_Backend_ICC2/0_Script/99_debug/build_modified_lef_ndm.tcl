################################################################################
# Debug-only SAED32 NDM reference library build using ../lib/libdir/LEF/modify.
#
# Front-end netlist is unchanged. This trial changes only the backend physical
# abstract used by ICC2.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
cd $PROJECT_ROOT

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK
set LIBDIR_ROOT /DATA/home/edu135/lib/libdir

if {[info exists ::env(MOD_LEF_TECH_FILE)] && $::env(MOD_LEF_TECH_FILE) ne ""} {
  set TECH_FILE $::env(MOD_LEF_TECH_FILE)
} else {
  set TECH_FILE $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf
}

if {[info exists ::env(MOD_LEF_WORKSPACE_SUFFIX)] && $::env(MOD_LEF_WORKSPACE_SUFFIX) ne ""} {
  set WORKSPACE_SUFFIX $::env(MOD_LEF_WORKSPACE_SUFFIX)
} else {
  set WORKSPACE_SUFFIX ibex_libdir_modify
}

if {[info exists ::env(MOD_LEF_NDM_SUFFIX)] && $::env(MOD_LEF_NDM_SUFFIX) ne ""} {
  set NDM_SUFFIX $::env(MOD_LEF_NDM_SUFFIX)
} else {
  set NDM_SUFFIX modified_lef
}

set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB $SAED32_ROOT/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB $SAED32_ROOT/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set RVT_LEF $LIBDIR_ROOT/LEF/modify/saed32nm_rvt_1p9m.lef
set LVT_LEF $LIBDIR_ROOT/LEF/modify/saed32nm_lvt_1p9m.lef
set HVT_LEF $LIBDIR_ROOT/LEF/modify/saed32nm_hvt_1p9m.lef

if {[info exists ::env(MOD_LEF_NDM_DIR)] && $::env(MOD_LEF_NDM_DIR) ne ""} {
  set NDM_DIR $::env(MOD_LEF_NDM_DIR)
} else {
  set NDM_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/99_debug/modified_lef_pg_probe/ndm
}
file mkdir $NDM_DIR

create_workspace -technology $TECH_FILE -flow normal saed32rvt_tt_$WORKSPACE_SUFFIX
read_db $RVT_TT_DB
read_lef $RVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32rvt_tt.$NDM_SUFFIX.ndm -force

create_workspace -technology $TECH_FILE -flow normal saed32lvt_tt_$WORKSPACE_SUFFIX
read_db $LVT_TT_DB
read_lef $LVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32lvt_tt.$NDM_SUFFIX.ndm -force

create_workspace -technology $TECH_FILE -flow normal saed32hvt_tt_$WORKSPACE_SUFFIX
read_db $HVT_TT_DB
read_lef $HVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32hvt_tt.$NDM_SUFFIX.ndm -force

exit
