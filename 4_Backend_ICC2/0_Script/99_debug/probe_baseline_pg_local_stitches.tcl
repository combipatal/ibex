################################################################################
# Debug-only baseline PG local stitch probe.
#
# Rebuilds the original DRC-clean PG geometry in memory, then adds explicit
# M1-M2 vias only for the floating stdcell rails observed in the baseline.
# This script does not save the block or library.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {![info exists ::env(DEBUG_ICC2_LIB_DIR)]} {
  set DEBUG_ICC2_LIB_DIR $ICC2_ROOT/2_Output/debug_pg/${TOP_NAME}_icc2_lib_pg_debug
} else {
  set DEBUG_ICC2_LIB_DIR $::env(DEBUG_ICC2_LIB_DIR)
}

set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/baseline_pg_local_stitches
file mkdir $DEBUG_REPORT_DIR

if {![file exists $DEBUG_ICC2_LIB_DIR]} {
  puts stderr "ERROR: DEBUG_ICC2_LIB_DIR does not exist: $DEBUG_ICC2_LIB_DIR"
  exit 2
}

set STITCH_SPECS {
  {VDD 840.0 327.648}
  {VDD 840.0 367.776}
  {VDD 840.0 407.904}
  {VDD 840.0 448.032}
  {VDD 840.0 488.160}
  {VDD 840.0 528.288}
  {VDD 840.0 568.416}
  {VSS 820.0 827.576}
}

set VIA_DEF_CANDIDATES {VIA12SQ_C VIA12_C VIA12}

proc attr_or_na {object attr_name} {
  if {[catch {set value [get_attribute $object $attr_name]}]} {
    return "NA"
  }
  return $value
}

proc bbox_intersects_window {bbox x_min x_max y_min y_max} {
  set ll [lindex $bbox 0]
  set ur [lindex $bbox 1]
  set bx_min [lindex $ll 0]
  set by_min [lindex $ll 1]
  set bx_max [lindex $ur 0]
  set by_max [lindex $ur 1]

  if {$bx_max < $x_min || $bx_min > $x_max} {
    return 0
  }
  if {$by_max < $y_min || $by_min > $y_max} {
    return 0
  }
  return 1
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

proc build_original_pg {} {
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
    -tag baseline_pg_local_stitches_via

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

proc pg_drc_error_count {file_name} {
  if {![file exists $file_name]} {
    return -1
  }
  set fh [open $file_name r]
  set data [read $fh]
  close $fh

  if {[regexp {Total number of errors found: *([0-9]+)} $data -> count]} {
    return $count
  }
  if {[regexp {No errors found\.} $data]} {
    return 0
  }
  return [regexp -all -line {^Error type:} $data]
}

proc remove_conflicting_upper_vias {net_name x y report_fh} {
  set x_min [expr {$x - 0.25}]
  set x_max [expr {$x + 0.25}]
  set y_min [expr {$y - 0.15}]
  set y_max [expr {$y + 0.15}]
  set to_remove {}

  set vias [get_vias -quiet -of_objects [get_nets -quiet $net_name]]
  foreach_in_collection via $vias {
    set bbox [attr_or_na $via bbox]
    if {$bbox eq "NA" || ![bbox_intersects_window $bbox $x_min $x_max $y_min $y_max]} {
      continue
    }

    set lower_layer [attr_or_na $via lower_layer_name]
    set upper_layer [attr_or_na $via upper_layer_name]
    if {$lower_layer eq "M1" && $upper_layer eq "M2"} {
      continue
    }

    set full_name [attr_or_na $via full_name]
    set via_master [attr_or_na $via via_master]
    puts $report_fh "REMOVE net=$net_name point=$x,$y object=$full_name via_master=$via_master bbox=$bbox lower_layer=$lower_layer upper_layer=$upper_layer"
    lappend to_remove $via
  }

  set removed_count 0
  foreach via $to_remove {
    remove_objects -force $via
    incr removed_count
  }
  return $removed_count
}

puts "BASELINE_PG_LOCAL_STITCHES DEBUG_LIB=$DEBUG_ICC2_LIB_DIR"

open_lib $DEBUG_ICC2_LIB_DIR
open_block -edit $TOP_NAME

build_original_pg

set stitch_report $DEBUG_REPORT_DIR/stitch_attempts.rpt
set stitch_fh [open $stitch_report w]
set removal_report $DEBUG_REPORT_DIR/removed_conflicting_vias.rpt
set removal_fh [open $removal_report w]
set created_count 0
set removed_count 0

foreach spec $STITCH_SPECS {
  lassign $spec net_name x y
  set point [list $x $y]
  set created_here 0
  incr removed_count [remove_conflicting_upper_vias $net_name $x $y $removal_fh]

  foreach via_def $VIA_DEF_CANDIDATES {
    if {[catch {
      set new_via [create_via \
        -via_def $via_def \
        -origin $point \
        -net [get_nets $net_name] \
        -shape_use lib_cell_pin_connect]
    } err]} {
      puts $stitch_fh "FAIL net=$net_name point=$point via_def=$via_def error=$err"
      continue
    }

    puts $stitch_fh "PASS net=$net_name point=$point via_def=$via_def object=[get_object_name $new_via]"
    incr created_count
    set created_here 1
    break
  }

  if {!$created_here} {
    puts $stitch_fh "NO_VIA_CREATED net=$net_name point=$point"
  }
}
close $stitch_fh
close $removal_fh

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
set pg_drc_errors [pg_drc_error_count $DEBUG_REPORT_DIR/pg_drc.rpt]

set summary_file $DEBUG_REPORT_DIR/summary.tsv
set summary_fh [open $summary_file w]
puts $summary_fh "removed_conflicting_vias\tcreated_vias\tvdd_floating_std_cells\tvss_floating_std_cells\tvdd_floating_wires\tvss_floating_wires\tpg_drc_errors"
puts $summary_fh "$removed_count\t$created_count\t$vdd_std\t$vss_std\t$vdd_wires\t$vss_wires\t$pg_drc_errors"
close $summary_fh

puts "BASELINE_PG_LOCAL_STITCHES SUMMARY=$summary_file"
puts "BASELINE_PG_LOCAL_STITCHES RESULT removed_conflicting_vias=$removed_count created_vias=$created_count vdd_std=$vdd_std vss_std=$vss_std vdd_wires=$vdd_wires vss_wires=$vss_wires pg_drc_errors=$pg_drc_errors"
puts "BASELINE_PG_LOCAL_STITCHES NOTE=no save_block/save_lib executed"

exit
