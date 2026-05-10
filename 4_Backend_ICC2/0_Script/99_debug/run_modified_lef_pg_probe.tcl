################################################################################
# Debug-only modified LEF PG probe for Ibex Mini SoC.
#
# Uses temporary NDM reference libraries built from ../lib/libdir/LEF/modify,
# creates a separate ICC2 design library from the existing synthesized netlist,
# runs floorplan + placement + PG, and reports PG connectivity/DRC. Production
# ICC2 blocks and production NDMs are not modified.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set LIBDIR_ROOT /DATA/home/edu135/lib/libdir
set MOD_LEF_DIR $LIBDIR_ROOT/LEF/modify

set DEBUG_ROOT $ICC2_ROOT/2_Output/99_debug/modified_lef_pg_probe
set DEBUG_NDM_DIR $DEBUG_ROOT/ndm
set DEBUG_LIB_DIR $DEBUG_ROOT/${TOP_NAME}_modified_lef_icc2_lib
set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/modified_lef_pg_probe

file mkdir $DEBUG_ROOT
file mkdir $DEBUG_NDM_DIR
file mkdir $DEBUG_REPORT_DIR

set MOD_NDM_RVT $DEBUG_NDM_DIR/saed32rvt_tt.modified_lef.ndm
set MOD_NDM_LVT $DEBUG_NDM_DIR/saed32lvt_tt.modified_lef.ndm
set MOD_NDM_HVT $DEBUG_NDM_DIR/saed32hvt_tt.modified_lef.ndm

set MOD_RVT_LEF $MOD_LEF_DIR/saed32nm_rvt_1p9m.lef
set MOD_LVT_LEF $MOD_LEF_DIR/saed32nm_lvt_1p9m.lef
set MOD_HVT_LEF $MOD_LEF_DIR/saed32nm_hvt_1p9m.lef

foreach required_file [list \
  $MOD_RVT_LEF $MOD_LVT_LEF $MOD_HVT_LEF \
  $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB \
  $TECH_FILE $BACKEND_NETLIST $BACKEND_SDC \
] {
  if {![file exists $required_file]} {
    puts stderr "ERROR: required file does not exist: $required_file"
    exit 2
  }
}

proc pg_connectivity_count {file_name net_name item_name} {
  if {![file exists $file_name]} {
    return "NA"
  }

  set fh [open $file_name r]
  set current_net ""
  set result "NA"

  while {[gets $fh line] >= 0} {
    if {[regexp {Verify net ([^ ]+) connectivity} $line -> parsed_net]} {
      set current_net $parsed_net
    } elseif {$current_net eq $net_name && [regexp "Number of $item_name: *(\[0-9\]+)" $line -> value]} {
      set result $value
      break
    }
  }

  close $fh
  return $result
}

proc count_regexp_matches {file_name pattern} {
  if {![file exists $file_name]} {
    return -1
  }
  set fh [open $file_name r]
  set data [read $fh]
  close $fh
  return [regexp -all -line $pattern $data]
}

puts "MOD_LEF_PG_PROBE use_ndm_dir=$DEBUG_NDM_DIR"

if {[file exists $DEBUG_LIB_DIR]} {
  file delete -force $DEBUG_LIB_DIR
}

create_lib $DEBUG_LIB_DIR \
  -technology $TECH_FILE \
  -ref_libs [list $MOD_NDM_RVT $MOD_NDM_LVT $MOD_NDM_HVT]

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

report_ref_libs > $DEBUG_REPORT_DIR/ref_libs.rpt
report_design -physical > $DEBUG_REPORT_DIR/init_design_physical.rpt
check_design \
  -checks {netlist design_mismatch timing} \
  -ems_database $DEBUG_REPORT_DIR/check_design.ems \
  -log_file $DEBUG_REPORT_DIR/check_design.rpt

initialize_floorplan \
  -control_type core \
  -shape R \
  -side_ratio {1 1} \
  -core_utilization 0.60 \
  -core_offset 20.0 \
  -flip_first_row true

place_pins -self

set_app_options -name place.coarse.continue_on_missing_scandef -value true

create_placement \
  -effort medium \
  -timing_driven \
  -congestion

legalize_placement

check_legality > $DEBUG_REPORT_DIR/check_legality.rpt
report_qor > $DEBUG_REPORT_DIR/place_qor.rpt
report_timing -max_paths 20 > $DEBUG_REPORT_DIR/timing.rpt

if {[sizeof_collection [get_nets -quiet VDD]] == 0} {
  create_net -power VDD
}
if {[sizeof_collection [get_nets -quiet VSS]] == 0} {
  create_net -ground VSS
}

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
set VDDG_PINS [get_pins -hierarchical -quiet */VDDG]
if {[sizeof_collection $VDDG_PINS] > 0} {
  connect_pg_net -net VDD $VDDG_PINS
}
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

create_pg_std_cell_conn_pattern stdcell_rail_pattern \
  -layers {M1}

set_pg_strategy stdcell_rail_strategy \
  -core \
  -pattern {{name: stdcell_rail_pattern}{nets: {VDD VSS}}}

create_pg_ring_pattern core_ring_pattern \
  -horizontal_layer M7 \
  -vertical_layer M8 \
  -horizontal_width 2.0 \
  -vertical_width 2.0 \
  -horizontal_spacing 1.0 \
  -vertical_spacing 1.0 \
  -corner_bridge true

set_pg_strategy core_ring_strategy \
  -core \
  -pattern {{name: core_ring_pattern}{nets: {VDD VSS}}{offset: {5 5}}} \
  -extension {{stop: design_boundary_and_generate_pin}}

create_pg_mesh_pattern core_mesh_pattern \
  -layers { \
    {{vertical_layer: M2}{width: 0.4}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}} \
    {{vertical_layer: M8}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}} \
    {{horizontal_layer: M7}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 28.0}} \
  }

set_pg_strategy core_mesh_strategy \
  -core \
  -pattern {{name: core_mesh_pattern}{nets: {VDD VSS}}} \
  -extension {{stop: innermost_ring}}

set_pg_strategy_via_rule pg_via_all \
  -via_rule {{intersection: all}{via_master: default}} \
  -tag modified_lef_pg_probe_via

compile_pg \
  -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
  -via_rule pg_via_all

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $DEBUG_REPORT_DIR/pg_connectivity_detail.rpt \
  > $DEBUG_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $DEBUG_REPORT_DIR/pg_drc.rpt

report_utilization > $DEBUG_REPORT_DIR/utilization.rpt
report_design -physical > $DEBUG_REPORT_DIR/powerplan_design_physical.rpt

set vdd_std [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VDD {floating std cells}]
set vss_std [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VSS {floating std cells}]
set vdd_unconn [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VDD {std cells with unconnected port}]
set vss_unconn [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VSS {std cells with unconnected port}]
set vdd_wires [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VDD {floating wires}]
set vss_wires [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VSS {floating wires}]
set pg_drc_errors [count_regexp_matches $DEBUG_REPORT_DIR/pg_drc.rpt {^Error:}]

set summary_file $DEBUG_REPORT_DIR/summary.tsv
set summary_fh [open $summary_file w]
puts $summary_fh "lef_dir\tvdd_floating_std_cells\tvss_floating_std_cells\tvdd_unconnected_std_cells\tvss_unconnected_std_cells\tvdd_floating_wires\tvss_floating_wires\tpg_drc_errors"
puts $summary_fh "$MOD_LEF_DIR\t$vdd_std\t$vss_std\t$vdd_unconn\t$vss_unconn\t$vdd_wires\t$vss_wires\t$pg_drc_errors"
close $summary_fh

puts "MOD_LEF_PG_PROBE SUMMARY=$summary_file"
puts "MOD_LEF_PG_PROBE RESULT vdd_std=$vdd_std vss_std=$vss_std vdd_unconn=$vdd_unconn vss_unconn=$vss_unconn vdd_wires=$vdd_wires vss_wires=$vss_wires pg_drc_errors=$pg_drc_errors"

exit
