################################################################################
# Build SAED32 NDM reference libraries for ICC2.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/ibex
cd $PROJECT_ROOT

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK

set TECH_FILE $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf

set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB $SAED32_ROOT/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB $SAED32_ROOT/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

# RVT top LEF is a small include-style file. The nested LEF contains the full
# macro abstracts needed by ICC2.
set RVT_LEF $SAED32_ROOT/lib/stdcell_rvt/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef
set LVT_LEF $SAED32_ROOT/lib/stdcell_lvt/lef/saed32nm_lvt_1p9m.lef
set HVT_LEF $SAED32_ROOT/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef

set NDM_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/00_setup/ndm
file mkdir $NDM_DIR

create_workspace -technology $TECH_FILE -flow normal saed32rvt_tt
read_db $RVT_TT_DB
read_lef $RVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32rvt_tt.ndm -force

create_workspace -technology $TECH_FILE -flow normal saed32lvt_tt
read_db $LVT_TT_DB
read_lef $LVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32lvt_tt.ndm -force

create_workspace -technology $TECH_FILE -flow normal saed32hvt_tt
read_db $HVT_TT_DB
read_lef $HVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32hvt_tt.ndm -force

exit

