################################################################################
# Debug-only PG M7 horizontal offset sweep for Ibex Mini SoC.
#
# Opens a copied ICC2 design library and rebuilds PG in memory for each M7
# offset. This script intentionally does not save the block or library.
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

set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/pg_m7_offset_sweep
file mkdir $DEBUG_REPORT_DIR

set OFFSET_LIST {16 18 20 22 24 25 26 28 30 32 33 34 36}
if {[info exists ::env(PG_M7_OFFSETS)] && $::env(PG_M7_OFFSETS) ne ""} {
  set OFFSET_LIST $::env(PG_M7_OFFSETS)
}

proc write_line {fh line} {
  puts $fh $line
  flush $fh
}

proc first_regexp_match {file_name pattern default_value} {
  if {![file exists $file_name]} {
    return $default_value
  }
  set fh [open $file_name r]
  set data [read $fh]
  close $fh
  if {[regexp -line $pattern $data -> value]} {
    return $value
  }
  return $default_value
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

proc build_pg_with_m7_offset {m7_offset} {
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
    {{vertical_layer: M2}{width: 0.4}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}}
    {{vertical_layer: M8}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}}
    {{horizontal_layer: M7}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: $m7_offset}}
  }]

  create_pg_mesh_pattern core_mesh_pattern \
    -layers $mesh_layers

  set_pg_strategy core_mesh_strategy \
    -core \
    -pattern {{name: core_mesh_pattern}{nets: {VDD VSS}}} \
    -extension {{stop: innermost_ring}}

  set_pg_strategy_via_rule pg_via_all \
    -via_rule {{intersection: all}{via_master: default}} \
    -tag pg_m7_offset_sweep_via

  compile_pg \
    -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
    -via_rule pg_via_all
}

puts "PG_M7_OFFSET_SWEEP DEBUG_LIB=$DEBUG_ICC2_LIB_DIR"
puts "PG_M7_OFFSET_SWEEP OFFSETS=$OFFSET_LIST"

open_lib $DEBUG_ICC2_LIB_DIR
open_block -edit $TOP_NAME

set summary_file $DEBUG_REPORT_DIR/summary.tsv
set summary_fh [open $summary_file w]
write_line $summary_fh "offset\tfloating_subnets\tvdd_floating_std_cells\tvss_floating_std_cells\tvdd_floating_wires\tvss_floating_wires\tpg_drc_errors"

foreach offset $OFFSET_LIST {
  set run_dir $DEBUG_REPORT_DIR/offset_$offset
  file mkdir $run_dir
  puts "PG_M7_OFFSET_SWEEP START offset=$offset report_dir=$run_dir"

  build_pg_with_m7_offset $offset

  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $run_dir/pg_connectivity_detail.rpt \
    > $run_dir/pg_connectivity.rpt

  check_pg_drc \
    -nets [get_nets {VDD VSS}] \
    -no_gui \
    -output $run_dir/pg_drc.rpt

  set floating_subnets [count_regexp_matches $run_dir/pg_connectivity_detail.rpt {floating}]
  set vdd_floating_std [pg_connectivity_count $run_dir/pg_connectivity.rpt VDD {floating std cells}]
  set vss_floating_std [pg_connectivity_count $run_dir/pg_connectivity.rpt VSS {floating std cells}]
  set vdd_floating_wires [pg_connectivity_count $run_dir/pg_connectivity.rpt VDD {floating wires}]
  set vss_floating_wires [pg_connectivity_count $run_dir/pg_connectivity.rpt VSS {floating wires}]
  set pg_drc_errors [count_regexp_matches $run_dir/pg_drc.rpt {Error:}]

  write_line $summary_fh "$offset\t$floating_subnets\t$vdd_floating_std\t$vss_floating_std\t$vdd_floating_wires\t$vss_floating_wires\t$pg_drc_errors"
  puts "PG_M7_OFFSET_SWEEP DONE offset=$offset floating_subnets=$floating_subnets vdd_std=$vdd_floating_std vss_std=$vss_floating_std vdd_wires=$vdd_floating_wires vss_wires=$vss_floating_wires pg_drc_errors=$pg_drc_errors"
}

close $summary_fh
puts "PG_M7_OFFSET_SWEEP SUMMARY=$summary_file"
puts "PG_M7_OFFSET_SWEEP NOTE=no save_block/save_lib executed"

exit
