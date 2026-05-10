################################################################################
# Debug-only top VSS PG context inspector.
#
# Rebuilds the best PG candidate found so far in memory:
#   M2 vertical width 0.2, pitch 20.0, offset 0.0
#   M7 horizontal width 1.0, pitch 40.0, offset 28.0
# Then dumps nearby PG shapes/vias around the residual floating rail PATH_11_483.
# This script does not save the block or library.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {![info exists ::env(DEBUG_ICC2_LIB_DIR)]} {
  set DEBUG_ICC2_LIB_DIR $ICC2_ROOT/2_Output/debug_pg/${TOP_NAME}_icc2_lib_pg_debug
} else {
  set DEBUG_ICC2_LIB_DIR $::env(DEBUG_ICC2_LIB_DIR)
}

set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/top_vss_pg_context
file mkdir $DEBUG_REPORT_DIR

if {![file exists $DEBUG_ICC2_LIB_DIR]} {
  puts stderr "ERROR: DEBUG_ICC2_LIB_DIR does not exist: $DEBUG_ICC2_LIB_DIR"
  exit 2
}

proc attr_or_na {obj attr} {
  if {[catch {set value [get_attribute $obj $attr]}]} {
    return "NA"
  }
  return $value
}

proc bbox_values {bbox} {
  set x1 [lindex [lindex $bbox 0] 0]
  set y1 [lindex [lindex $bbox 0] 1]
  set x2 [lindex [lindex $bbox 1] 0]
  set y2 [lindex [lindex $bbox 1] 1]
  return [list $x1 $y1 $x2 $y2]
}

proc bbox_intersects_window {bbox y_min y_max} {
  lassign [bbox_values $bbox] x1 y1 x2 y2
  return [expr {$y2 >= $y_min && $y1 <= $y_max}]
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
    -tag top_vss_pg_context_via

  compile_pg \
    -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
    -via_rule pg_via_all
}

puts "TOP_VSS_PG_CONTEXT DEBUG_LIB=$DEBUG_ICC2_LIB_DIR"

open_lib $DEBUG_ICC2_LIB_DIR
open_block -edit $TOP_NAME

build_best_candidate_pg

set y_min 800.0
set y_max 850.0
if {[info exists ::env(TOP_VSS_Y_MIN)] && $::env(TOP_VSS_Y_MIN) ne ""} {
  set y_min $::env(TOP_VSS_Y_MIN)
}
if {[info exists ::env(TOP_VSS_Y_MAX)] && $::env(TOP_VSS_Y_MAX) ne ""} {
  set y_max $::env(TOP_VSS_Y_MAX)
}

set shape_file $DEBUG_REPORT_DIR/nearby_shapes.tsv
set shape_fh [open $shape_file w]
puts $shape_fh "net\tobject_type\tfull_name\tlayer\tshape_use\tbbox"

foreach net_name {VDD VSS} {
  set shapes [get_shapes -quiet -of_objects [get_nets -quiet $net_name]]
  foreach_in_collection shape $shapes {
    set bbox [attr_or_na $shape bbox]
    if {$bbox eq "NA" || ![bbox_intersects_window $bbox $y_min $y_max]} {
      continue
    }
    set full_name [attr_or_na $shape full_name]
    set layer [attr_or_na $shape layer_name]
    set shape_use [attr_or_na $shape shape_use]
    puts $shape_fh "$net_name\tshape\t$full_name\t$layer\t$shape_use\t$bbox"
  }
}
close $shape_fh

set via_file $DEBUG_REPORT_DIR/nearby_vias.tsv
set via_fh [open $via_file w]
puts $via_fh "net\tobject_type\tfull_name\tvia_master\tbbox\tlower_layer\tupper_layer"

foreach net_name {VDD VSS} {
  set vias [get_vias -quiet -of_objects [get_nets -quiet $net_name]]
  foreach_in_collection via $vias {
    set bbox [attr_or_na $via bbox]
    if {$bbox eq "NA" || ![bbox_intersects_window $bbox $y_min $y_max]} {
      continue
    }
    set full_name [attr_or_na $via full_name]
    set via_master [attr_or_na $via via_master]
    set lower_layer [attr_or_na $via lower_layer_name]
    set upper_layer [attr_or_na $via upper_layer_name]
    puts $via_fh "$net_name\tvia\t$full_name\t$via_master\t$bbox\t$lower_layer\t$upper_layer"
  }
}
close $via_fh

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $DEBUG_REPORT_DIR/pg_connectivity_detail.rpt \
  > $DEBUG_REPORT_DIR/pg_connectivity.rpt

puts "TOP_VSS_PG_CONTEXT SHAPES=$shape_file"
puts "TOP_VSS_PG_CONTEXT VIAS=$via_file"
puts "TOP_VSS_PG_CONTEXT NOTE=no save_block/save_lib executed"

exit
