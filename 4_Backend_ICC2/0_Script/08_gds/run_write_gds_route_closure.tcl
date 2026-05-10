################################################################################
# Ibex route-closure GDS candidate export.
#
# This writes an educational GDS candidate from the route-clean backend block.
# It is not a tapeout/signoff GDS: signoff DRC, LVS, antenna signoff, IR/EM,
# noise, and metal fill are outside this script's evidence.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_ICC2_LIB $PROJECT_ROOT/4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib
set SRC_BLOCK $TOP_NAME
set GDS_TAG route_closure_gds_candidate

if {[info exists ::env(SRC_ICC2_LIB)] && $::env(SRC_ICC2_LIB) ne ""} {
  set SRC_ICC2_LIB $::env(SRC_ICC2_LIB)
}
if {[info exists ::env(SRC_BLOCK)] && $::env(SRC_BLOCK) ne ""} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(GDS_TAG)] && $::env(GDS_TAG) ne ""} {
  set GDS_TAG $::env(GDS_TAG)
}

set GDS_BLOCK ${TOP_NAME}_${GDS_TAG}
set OUTPUT_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/08_gds/$GDS_TAG
set REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/08_gds/$GDS_TAG
set LOG_DIR $PROJECT_ROOT/4_Backend_ICC2/3_Log/08_gds
file mkdir $OUTPUT_DIR
file mkdir $REPORT_DIR
file mkdir $LOG_DIR

set GDS_OUT      $OUTPUT_DIR/${TOP_NAME}.${GDS_TAG}.gds
set NETLIST_OUT  $OUTPUT_DIR/${TOP_NAME}.${GDS_TAG}.vg
set DEF_OUT      $OUTPUT_DIR/${TOP_NAME}.${GDS_TAG}.def
set SDC_OUT      $OUTPUT_DIR/${TOP_NAME}.${GDS_TAG}.sdc
set MANIFEST     $OUTPUT_DIR/gds_export_manifest.txt

set GDS_MAP /DATA/home/edu135/lib/libdir/TECH/map/saed32nm_1p9m_gdsout_mw.map
set RVT_GDS $SAED32_ROOT/lib/stdcell_rvt/gds/saed32nm_rvt_oa.gds
set LVT_GDS $SAED32_ROOT/lib/stdcell_lvt/gds/saed32nm_lvt_oa.gds
set HVT_GDS $SAED32_ROOT/lib/stdcell_hvt/gds/saed32nm_hvt_oa.gds

if {![file exists $SRC_ICC2_LIB]} {
  error "Missing source ICC2 library: $SRC_ICC2_LIB"
}
foreach required [list $GDS_MAP $RVT_GDS $LVT_GDS $HVT_GDS] {
  if {![file exists $required]} {
    error "Missing GDS stream-out input: $required"
  }
}

open_lib $SRC_ICC2_LIB
copy_block -from_block $SRC_BLOCK -to_block $GDS_BLOCK
current_block $GDS_BLOCK

check_routes > $REPORT_DIR/check_routes.before_filler.rpt
check_legality > $REPORT_DIR/check_legality.before_filler.rpt
check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.before_filler.rpt \
  > $REPORT_DIR/pg_connectivity.before_filler.rpt

set filler_names {
  SHFILL128_RVT SHFILL64_RVT SHFILL3_RVT SHFILL2_RVT SHFILL1_RVT
  SHFILL128_HVT SHFILL64_HVT SHFILL3_HVT SHFILL2_HVT SHFILL1_HVT
  SHFILL128_LVT SHFILL64_LVT SHFILL3_LVT SHFILL2_LVT SHFILL1_LVT
}

set filler_lib_cells {}
set filler_rpt [open $REPORT_DIR/filler_lib_cells.rpt w]
foreach filler_name $filler_names {
  set lib_cell [get_lib_cells -quiet */$filler_name]
  if {[sizeof_collection $lib_cell] > 0} {
    set one_lib_cell [index_collection $lib_cell 0]
    set full_name [get_object_name $one_lib_cell]
    lappend filler_lib_cells $full_name
    puts $filler_rpt "FOUND $full_name"
  } else {
    puts $filler_rpt "MISSING $filler_name"
  }
}
close $filler_rpt

set FILLER_STATUS 0
set FILLER_MSG ""
if {[llength $filler_lib_cells] == 0} {
  set FILLER_STATUS 1
  set FILLER_MSG "no filler lib cells found"
} else {
  set FILLER_STATUS [catch {
    create_stdcell_fillers -lib_cells $filler_lib_cells -prefix FILL_IBEX_
  } FILLER_MSG]
}

set PG_STATUS [catch {connect_pg_net -automatic} PG_MSG]

check_routes > $REPORT_DIR/check_routes.after_filler.rpt
check_legality > $REPORT_DIR/check_legality.after_filler.rpt
check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.after_filler.rpt \
  > $REPORT_DIR/pg_connectivity.after_filler.rpt
check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $REPORT_DIR/pg_drc.after_filler.rpt
report_qor > $REPORT_DIR/qor.after_filler.rpt
report_timing -delay_type max -max_paths 20 > $REPORT_DIR/timing.max.after_filler.rpt
report_timing -delay_type min -max_paths 20 > $REPORT_DIR/timing.min.after_filler.rpt
report_reference > $REPORT_DIR/reference.after_filler.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_filler.rpt

set WRITE_V_STATUS [catch {write_verilog $NETLIST_OUT} WRITE_V_MSG]
set WRITE_DEF_STATUS [catch {write_def $DEF_OUT} WRITE_DEF_MSG]
set WRITE_SDC_STATUS [catch {write_sdc -output $SDC_OUT} WRITE_SDC_MSG]
set WRITE_GDS_STATUS [catch {
  write_gds \
    -design $GDS_BLOCK \
    -long_names \
    -hierarchy design_lib \
    -layer_map $GDS_MAP \
    -merge_files [list $RVT_GDS $LVT_GDS $HVT_GDS] \
    $GDS_OUT
} WRITE_GDS_MSG]

save_block
save_lib

set FP [open $MANIFEST w]
puts $FP "gds_tag=$GDS_TAG"
puts $FP "source_icc2_lib=$SRC_ICC2_LIB"
puts $FP "source_block=$SRC_BLOCK"
puts $FP "gds_block=$GDS_BLOCK"
puts $FP "gds=$GDS_OUT"
puts $FP "netlist=$NETLIST_OUT"
puts $FP "def=$DEF_OUT"
puts $FP "sdc=$SDC_OUT"
puts $FP "gds_map=$GDS_MAP"
puts $FP "merge_rvt_gds=$RVT_GDS"
puts $FP "merge_lvt_gds=$LVT_GDS"
puts $FP "merge_hvt_gds=$HVT_GDS"
puts $FP "filler_lib_cells=$filler_lib_cells"
puts $FP "filler_status=$FILLER_STATUS"
puts $FP "filler_message=$FILLER_MSG"
puts $FP "pg_status=$PG_STATUS"
puts $FP "pg_message=$PG_MSG"
puts $FP "write_verilog_status=$WRITE_V_STATUS"
puts $FP "write_verilog_message=$WRITE_V_MSG"
puts $FP "write_def_status=$WRITE_DEF_STATUS"
puts $FP "write_def_message=$WRITE_DEF_MSG"
puts $FP "write_sdc_status=$WRITE_SDC_STATUS"
puts $FP "write_sdc_message=$WRITE_SDC_MSG"
puts $FP "write_gds_status=$WRITE_GDS_STATUS"
puts $FP "write_gds_message=$WRITE_GDS_MSG"
close $FP

if {$FILLER_STATUS != 0 || $PG_STATUS != 0} {
  error "GDS candidate filler/PG step failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_GDS_STATUS != 0} {
  error "GDS candidate export failed. See $MANIFEST"
}

exit
