################################################################################
# Debug-only top VSS local stitch probe.
#
# Rebuilds the best PG candidate in memory and adds one or more explicit M1-M2
# vias from the residual floating top VSS rail PATH_11_483 to existing VSS M2
# stripes. This script does not save the block or library.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {![info exists ::env(DEBUG_ICC2_LIB_DIR)]} {
  set DEBUG_ICC2_LIB_DIR $ICC2_ROOT/2_Output/debug_pg/${TOP_NAME}_icc2_lib_pg_debug
} else {
  set DEBUG_ICC2_LIB_DIR $::env(DEBUG_ICC2_LIB_DIR)
}

set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/top_vss_local_stitch
file mkdir $DEBUG_REPORT_DIR

if {![file exists $DEBUG_ICC2_LIB_DIR]} {
  puts stderr "ERROR: DEBUG_ICC2_LIB_DIR does not exist: $DEBUG_ICC2_LIB_DIR"
  exit 2
}

set STITCH_POINTS {{830.0 827.576}}
if {[info exists ::env(TOP_VSS_STITCH_POINTS)] && $::env(TOP_VSS_STITCH_POINTS) ne ""} {
  set STITCH_POINTS $::env(TOP_VSS_STITCH_POINTS)
}

set VIA_DEF_CANDIDATES {VIA12SQ_C VIA12_C VIA12}
if {[info exists ::env(TOP_VSS_VIA_DEFS)] && $::env(TOP_VSS_VIA_DEFS) ne ""} {
  set VIA_DEF_CANDIDATES $::env(TOP_VSS_VIA_DEFS)
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

proc build_best_candidate_pg {} {
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

  create_pg_mesh_pattern core_mesh_pattern \
    -layers { \
      {{vertical_layer: M2}{width: 0.2}{spacing: interleaving}{pitch: 20.0}{offset: 0.0}} \
      {{vertical_layer: M8}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}} \
      {{horizontal_layer: M7}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 28.0}} \
    }

  set_pg_strategy core_mesh_strategy \
    -core \
    -pattern {{name: core_mesh_pattern}{nets: {VDD VSS}}} \
    -extension {{stop: innermost_ring}}

  set_pg_strategy_via_rule pg_via_all \
    -via_rule {{intersection: all}{via_master: default}} \
    -tag top_vss_local_stitch_via

  compile_pg \
    -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
    -via_rule pg_via_all
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

puts "TOP_VSS_LOCAL_STITCH DEBUG_LIB=$DEBUG_ICC2_LIB_DIR"
puts "TOP_VSS_LOCAL_STITCH POINTS=$STITCH_POINTS"
puts "TOP_VSS_LOCAL_STITCH VIA_DEF_CANDIDATES=$VIA_DEF_CANDIDATES"

open_lib $DEBUG_ICC2_LIB_DIR
open_block -edit $TOP_NAME

build_best_candidate_pg

set stitch_report $DEBUG_REPORT_DIR/stitch_attempts.rpt
set stitch_fh [open $stitch_report w]
set created_count 0
set chosen_via_def ""

foreach point $STITCH_POINTS {
  set created_here 0
  foreach via_def $VIA_DEF_CANDIDATES {
    if {[catch {
      set new_via [create_via \
        -via_def $via_def \
        -origin $point \
        -net [get_nets VSS] \
        -shape_use lib_cell_pin_connect]
    } err]} {
      puts $stitch_fh "FAIL point=$point via_def=$via_def error=$err"
      continue
    }

    puts $stitch_fh "PASS point=$point via_def=$via_def object=[get_object_name $new_via]"
    incr created_count
    set created_here 1
    if {$chosen_via_def eq ""} {
      set chosen_via_def $via_def
    }
    break
  }

  if {!$created_here} {
    puts $stitch_fh "NO_VIA_CREATED point=$point"
  }
}
close $stitch_fh

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $DEBUG_REPORT_DIR/pg_connectivity_detail.rpt \
  > $DEBUG_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $DEBUG_REPORT_DIR/pg_drc.rpt

set vdd_std [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VDD {floating std cells}]
set vss_std [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VSS {floating std cells}]
set vdd_wires [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VDD {floating wires}]
set vss_wires [pg_connectivity_count $DEBUG_REPORT_DIR/pg_connectivity.rpt VSS {floating wires}]
set pg_drc_errors [count_regexp_matches $DEBUG_REPORT_DIR/pg_drc.rpt {^Error:}]

set summary_file $DEBUG_REPORT_DIR/summary.tsv
set summary_fh [open $summary_file w]
puts $summary_fh "created_vias\tchosen_via_def\tvdd_floating_std_cells\tvss_floating_std_cells\tvdd_floating_wires\tvss_floating_wires\tpg_drc_errors"
puts $summary_fh "$created_count\t$chosen_via_def\t$vdd_std\t$vss_std\t$vdd_wires\t$vss_wires\t$pg_drc_errors"
close $summary_fh

puts "TOP_VSS_LOCAL_STITCH SUMMARY=$summary_file"
puts "TOP_VSS_LOCAL_STITCH RESULT created_vias=$created_count via_def=$chosen_via_def vdd_std=$vdd_std vss_std=$vss_std vdd_wires=$vdd_wires vss_wires=$vss_wires pg_drc_errors=$pg_drc_errors"
puts "TOP_VSS_LOCAL_STITCH NOTE=no save_block/save_lib executed"

exit
