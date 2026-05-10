################################################################################
# Debug-only inspector for residual Off-grid route DRC.
#
# Opens a routed block, reruns check_routes, expands Off-grid DRC objects, and
# lists nearby cells, shapes, vias, and pins. This script does not save.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(OFFGRID_CONTEXT_REPORT_DIR)] && $::env(OFFGRID_CONTEXT_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(OFFGRID_CONTEXT_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/inspect_offgrid_context
}
file mkdir $DEBUG_REPORT_DIR

proc attr_or_na {object attr_name} {
  if {[catch {set value [get_attribute $object $attr_name]}]} {
    return "NA"
  }
  return $value
}

proc object_names_or_na {objects} {
  if {[catch {set value [get_object_name $objects]}]} {
    return "NA"
  }
  return $value
}

proc safe_size {objects} {
  if {[catch {set count [sizeof_collection $objects]}]} {
    return 0
  }
  return $count
}

proc bbox_values {bbox} {
  set ll [lindex $bbox 0]
  set ur [lindex $bbox 1]
  return [list [lindex $ll 0] [lindex $ll 1] [lindex $ur 0] [lindex $ur 1]]
}

proc expand_bbox {bbox margin} {
  lassign [bbox_values $bbox] x1 y1 x2 y2
  return [list [list [expr {$x1 - $margin}] [expr {$y1 - $margin}]] [list [expr {$x2 + $margin}] [expr {$y2 + $margin}]]]
}

proc dump_objects {fh label objects} {
  set idx 0
  foreach_in_collection obj $objects {
    incr idx
    set name [object_names_or_na $obj]
    set class [attr_or_na $obj object_class]
    set layer [attr_or_na $obj layer_name]
    set bbox [attr_or_na $obj bbox]
    set net [object_names_or_na [attr_or_na $obj net]]
    set ref_name [attr_or_na $obj ref_name]
    set lib_cell [object_names_or_na [attr_or_na $obj lib_cell]]
    set shape_use [attr_or_na $obj shape_use]
    set via_def [attr_or_na $obj via_def_name]
    set owner [object_names_or_na [attr_or_na $obj owner]]
    puts $fh "$label\t$idx\t$name\t$class\t$layer\t$bbox\t$net\t$ref_name\t$lib_cell\t$shape_use\t$via_def\t$owner"
  }
}

puts "OFFGRID_CONTEXT lib=$ICC2_LIB_DIR"
puts "OFFGRID_CONTEXT report_dir=$DEBUG_REPORT_DIR"

open_lib $ICC2_LIB_DIR
open_block $TOP_NAME

redirect -file $DEBUG_REPORT_DIR/check_routes.rpt {
  check_routes
}

set error_data [get_drc_error_data -all -quiet zroute.err]
if {[safe_size $error_data] > 0} {
  set opened_data [open_drc_error_data $error_data]
  if {[safe_size $opened_data] > 0} {
    set error_data $opened_data
  }
}

if {[safe_size $error_data] == 0} {
  puts stderr "ERROR: no DRC error data exists after check_routes"
  exit 2
}

set offgrid_type [get_drc_error_types -quiet -error_data $error_data {Off-grid}]
set offgrid_errors [get_drc_errors -quiet -error_data $error_data -of_objects $offgrid_type]

redirect -file $DEBUG_REPORT_DIR/offgrid_drc_detail.rpt {
  report_drc_error \
    -error_data $error_data \
    -error_type $offgrid_type \
    -report_type detailed \
    -nosplit
}

set fh [open $DEBUG_REPORT_DIR/offgrid_context.tsv w]
puts $fh "label\tidx\tname\tclass\tlayer\tbbox\tnet\tref_name\tlib_cell\tshape_use\tvia_def\towner"

set err_idx 0
foreach_in_collection err $offgrid_errors {
  incr err_idx
  set err_bbox [attr_or_na $err bbox]
  puts $fh "offgrid_error_$err_idx\t0\t[object_names_or_na $err]\t[attr_or_na $err object_class]\t[attr_or_na $err layer_name]\t$err_bbox\tNA\tNA\tNA\tNA\tNA\tNA"

  set err_objects [attr_or_na $err objects]
  if {$err_objects ne "NA"} {
    dump_objects $fh "drc_object_$err_idx" $err_objects
  }

  set small_area [expand_bbox $err_bbox 0.25]
  set cell_area [expand_bbox $err_bbox 1.50]

  if {![catch {set area_cells [get_cells -quiet -intersect $cell_area]}]} {
    dump_objects $fh "near_cell_$err_idx" $area_cells
  }
  if {![catch {set area_pins [get_pins -quiet -intersect $small_area]}]} {
    dump_objects $fh "near_pin_$err_idx" $area_pins
  }
  if {![catch {set area_shapes [get_shapes -quiet -intersect $small_area]}]} {
    dump_objects $fh "near_shape_$err_idx" $area_shapes
  }
  if {![catch {set area_vias [get_vias -quiet -intersect $small_area]}]} {
    dump_objects $fh "near_via_$err_idx" $area_vias
  }
}

close $fh

puts "OFFGRID_CONTEXT DONE"
puts "OFFGRID_CONTEXT NOTE=no save_block/save_lib executed"

exit
