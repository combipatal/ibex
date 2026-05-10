################################################################################
# Debug-only PG M2 vertical stripe sweep for Ibex Mini SoC.
#
# Opens a copied ICC2 design library and rebuilds PG in memory for each M2
# candidate. This script intentionally does not save the block or library.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {![info exists ::env(DEBUG_ICC2_LIB_DIR)]} {
  set DEBUG_ICC2_LIB_DIR $ICC2_ROOT/2_Output/debug_pg/${TOP_NAME}_icc2_lib_pg_debug
} else {
  set DEBUG_ICC2_LIB_DIR $::env(DEBUG_ICC2_LIB_DIR)
}

if {![file exists $DEBUG_ICC2_LIB_DIR]} {
  puts stderr "ERROR: DEBUG_ICC2_LIB_DIR does not exist: $DEBUG_ICC2_LIB_DIR"
  exit 2
}

set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/pg_m2_sweep
file mkdir $DEBUG_REPORT_DIR

set CASE_LIST {
  {p40_o00_w0p4 40.0 0.0 0.4}
  {p40_o05_w0p4 40.0 5.0 0.4}
  {p40_o10_w0p4 40.0 10.0 0.4}
  {p40_o15_w0p4 40.0 15.0 0.4}
  {p40_o20_w0p4 40.0 20.0 0.4}
  {p40_o25_w0p4 40.0 25.0 0.4}
  {p40_o30_w0p4 40.0 30.0 0.4}
  {p40_o35_w0p4 40.0 35.0 0.4}
  {p20_o00_w0p4 20.0 0.0 0.4}
  {p20_o05_w0p4 20.0 5.0 0.4}
  {p20_o10_w0p4 20.0 10.0 0.4}
  {p20_o15_w0p4 20.0 15.0 0.4}
  {p10_o00_w0p4 10.0 0.0 0.4}
  {p10_o05_w0p4 10.0 5.0 0.4}
}

if {[info exists ::env(PG_M2_CASES)] && $::env(PG_M2_CASES) ne ""} {
  set CASE_LIST $::env(PG_M2_CASES)
}

set M7_OFFSET 28.0
if {[info exists ::env(PG_M7_OFFSET)] && $::env(PG_M7_OFFSET) ne ""} {
  set M7_OFFSET $::env(PG_M7_OFFSET)
}

set MESH_STOP innermost_ring
if {[info exists ::env(PG_MESH_STOP)] && $::env(PG_MESH_STOP) ne ""} {
  set MESH_STOP $::env(PG_MESH_STOP)
}

proc write_line {fh line} {
  puts $fh $line
  flush $fh
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

proc clear_existing_pg {pg_nets} {
  set old_pg_vias [get_vias -quiet -of_objects $pg_nets]
  if {[sizeof_collection $old_pg_vias] > 0} {
    remove_objects -force $old_pg_vias
  }

  set old_pg_shapes [get_shapes -quiet -of_objects $pg_nets]
  if {[sizeof_collection $old_pg_shapes] > 0} {
    remove_objects -force $old_pg_shapes
  }

  catch {remove_pg_strategy_via_rules -all}
  catch {remove_pg_strategies -all}
  catch {remove_pg_patterns -all}
}

proc build_pg_with_m2_case {m2_pitch m2_offset m2_width m7_offset mesh_stop} {
  if {[sizeof_collection [get_nets -quiet VDD]] == 0} {
    create_net -power VDD
  }
  if {[sizeof_collection [get_nets -quiet VSS]] == 0} {
    create_net -ground VSS
  }

  set pg_nets [get_nets -quiet {VDD VSS}]
  clear_existing_pg $pg_nets

  connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
  set vddg_pins [get_pins -hierarchical -quiet */VDDG]
  if {[sizeof_collection $vddg_pins] > 0} {
    connect_pg_net -net VDD $vddg_pins
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

  set mesh_layers [subst {
    {{vertical_layer: M2}{width: $m2_width}{spacing: interleaving}{pitch: $m2_pitch}{offset: $m2_offset}}
    {{vertical_layer: M8}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}}
    {{horizontal_layer: M7}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: $m7_offset}}
  }]

  create_pg_mesh_pattern core_mesh_pattern \
    -layers $mesh_layers

  set_pg_strategy core_mesh_strategy \
    -core \
    -pattern {{name: core_mesh_pattern}{nets: {VDD VSS}}} \
    -extension [list [list stop: $mesh_stop]]

  set_pg_strategy_via_rule pg_via_all \
    -via_rule {{intersection: all}{via_master: default}} \
    -tag pg_m2_sweep_via

  compile_pg \
    -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
    -via_rule pg_via_all
}

puts "PG_M2_SWEEP DEBUG_LIB=$DEBUG_ICC2_LIB_DIR"
puts "PG_M2_SWEEP M7_OFFSET=$M7_OFFSET"
puts "PG_M2_SWEEP MESH_STOP=$MESH_STOP"

open_lib $DEBUG_ICC2_LIB_DIR
open_block -edit $TOP_NAME

set summary_file $DEBUG_REPORT_DIR/summary.tsv
set summary_fh [open $summary_file w]
write_line $summary_fh "case\tm2_pitch\tm2_offset\tm2_width\tm7_offset\tmesh_stop\tvdd_floating_std_cells\tvss_floating_std_cells\tvdd_floating_wires\tvss_floating_wires\tpg_drc_errors"

foreach case_spec $CASE_LIST {
  lassign $case_spec case_name m2_pitch m2_offset m2_width
  set run_dir $DEBUG_REPORT_DIR/$case_name
  file mkdir $run_dir
  puts "PG_M2_SWEEP START case=$case_name pitch=$m2_pitch offset=$m2_offset width=$m2_width"

  build_pg_with_m2_case $m2_pitch $m2_offset $m2_width $M7_OFFSET $MESH_STOP

  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $run_dir/pg_connectivity_detail.rpt \
    > $run_dir/pg_connectivity.rpt

  set vdd_floating_std [pg_connectivity_count $run_dir/pg_connectivity.rpt VDD {floating std cells}]
  set vss_floating_std [pg_connectivity_count $run_dir/pg_connectivity.rpt VSS {floating std cells}]
  set vdd_floating_wires [pg_connectivity_count $run_dir/pg_connectivity.rpt VDD {floating wires}]
  set vss_floating_wires [pg_connectivity_count $run_dir/pg_connectivity.rpt VSS {floating wires}]
  set total_floating_std [expr {$vdd_floating_std + $vss_floating_std}]

  set pg_drc_errors "SKIP"
  if {$total_floating_std == 0} {
    check_pg_drc \
      -nets [get_nets {VDD VSS}] \
      -no_gui \
      -output $run_dir/pg_drc.rpt
    set pg_drc_errors [count_regexp_matches $run_dir/pg_drc.rpt {^Error:}]
  }

  write_line $summary_fh "$case_name\t$m2_pitch\t$m2_offset\t$m2_width\t$M7_OFFSET\t$MESH_STOP\t$vdd_floating_std\t$vss_floating_std\t$vdd_floating_wires\t$vss_floating_wires\t$pg_drc_errors"
  puts "PG_M2_SWEEP DONE case=$case_name vdd_std=$vdd_floating_std vss_std=$vss_floating_std vdd_wires=$vdd_floating_wires vss_wires=$vss_floating_wires pg_drc_errors=$pg_drc_errors"
}

close $summary_fh
puts "PG_M2_SWEEP SUMMARY=$summary_file"
puts "PG_M2_SWEEP NOTE=no save_block/save_lib executed"

exit
