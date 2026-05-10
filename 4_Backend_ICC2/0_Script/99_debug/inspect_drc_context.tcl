################################################################################
# Debug-only DRC context inspector.
#
# Opens a routed block, reruns check_routes, expands a selected DRC type, and
# lists nearby cells, pins, route shapes, and vias. This script does not save.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(DRC_CONTEXT_TYPE)] && $::env(DRC_CONTEXT_TYPE) ne ""} {
  set DRC_CONTEXT_TYPE $::env(DRC_CONTEXT_TYPE)
} else {
  set DRC_CONTEXT_TYPE {Diff net spacing}
}

if {[info exists ::env(DRC_CONTEXT_MARGIN)] && $::env(DRC_CONTEXT_MARGIN) ne ""} {
  set DRC_CONTEXT_MARGIN $::env(DRC_CONTEXT_MARGIN)
} else {
  set DRC_CONTEXT_MARGIN 0.35
}

if {[info exists ::env(DRC_CONTEXT_REPORT_DIR)] && $::env(DRC_CONTEXT_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(DRC_CONTEXT_REPORT_DIR)
} else {
  set safe_type [string map {" " "_" "/" "_" "\\" "_" ":" "_"} $DRC_CONTEXT_TYPE]
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/drc_context_$safe_type
}
file mkdir $DEBUG_REPORT_DIR

proc write_line {fh text} {
  puts $fh $text
}

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

proc dump_objects {fh label err_idx objects} {
  set idx 0
  foreach_in_collection obj $objects {
    incr idx
    set name [object_names_or_na $obj]
    set class [attr_or_na $obj object_class]
    set layer [attr_or_na $obj layer_name]
    set bbox [attr_or_na $obj bbox]
    set net [attr_or_na $obj net]
    set net_name [object_names_or_na $net]
    set ref_name [attr_or_na $obj ref_name]
    set lib_cell [attr_or_na $obj lib_cell]
    set shape_use [attr_or_na $obj shape_use]
    set via_def [attr_or_na $obj via_def_name]
    set owner [attr_or_na $obj owner]
    set owner_name [object_names_or_na $owner]
    write_line $fh "$label\t$err_idx\t$idx\t$name\t$class\t$layer\t$bbox\t$net_name\t$ref_name\t$lib_cell\t$shape_use\t$via_def\t$owner_name"
  }
}

puts "DRC_CONTEXT lib=$ICC2_LIB_DIR"
puts "DRC_CONTEXT type=$DRC_CONTEXT_TYPE"
puts "DRC_CONTEXT report_dir=$DEBUG_REPORT_DIR"

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

set error_type [get_drc_error_types -quiet -error_data $error_data [list $DRC_CONTEXT_TYPE]]
set errors [get_drc_errors -quiet -error_data $error_data -of_objects $error_type]

redirect -file $DEBUG_REPORT_DIR/drc_detail.rpt {
  report_drc_error \
    -error_data $error_data \
    -error_type $error_type \
    -report_type detailed \
    -nosplit
}

set fh [open $DEBUG_REPORT_DIR/context.tsv w]
write_line $fh "label\terror_idx\tidx\tname\tclass\tlayer\tbbox\tnet\tref_name\tlib_cell\tshape_use\tvia_def\towner"

set err_idx 0
foreach_in_collection err $errors {
  incr err_idx
  set err_name [object_names_or_na $err]
  set err_bbox [attr_or_na $err bbox]
  set err_objects [attr_or_na $err objects]
  write_line $fh "drc_error\t$err_idx\t0\t$err_name\t[attr_or_na $err object_class]\t[attr_or_na $err layer_name]\t$err_bbox\tNA\tNA\tNA\tNA\tNA\tNA"

  if {$err_objects ne "NA"} {
    dump_objects $fh drc_object $err_idx $err_objects
  }

  set near_area [expand_bbox $err_bbox $DRC_CONTEXT_MARGIN]
  set cell_area [expand_bbox $err_bbox [expr {$DRC_CONTEXT_MARGIN + 1.25}]]

  if {![catch {set near_cells [get_cells -quiet -intersect $cell_area]} cell_err]} {
    dump_objects $fh near_cell $err_idx $near_cells
  } else {
    write_line $fh "near_cell_error\t$err_idx\t0\t$cell_err\tNA\tNA\t$cell_area\tNA\tNA\tNA\tNA\tNA\tNA"
  }

  if {![catch {set near_pins [get_pins -quiet -intersect $near_area]} pin_err]} {
    dump_objects $fh near_pin $err_idx $near_pins
  } else {
    write_line $fh "near_pin_error\t$err_idx\t0\t$pin_err\tNA\tNA\t$near_area\tNA\tNA\tNA\tNA\tNA\tNA"
  }

  if {![catch {set near_shapes [get_shapes -quiet -intersect $near_area]} shape_err]} {
    dump_objects $fh near_shape $err_idx $near_shapes
  } else {
    write_line $fh "near_shape_error\t$err_idx\t0\t$shape_err\tNA\tNA\t$near_area\tNA\tNA\tNA\tNA\tNA\tNA"
  }

  if {![catch {set near_vias [get_vias -quiet -intersect $near_area]} via_err]} {
    dump_objects $fh near_via $err_idx $near_vias
  } else {
    write_line $fh "near_via_error\t$err_idx\t0\t$via_err\tNA\tNA\t$near_area\tNA\tNA\tNA\tNA\tNA\tNA"
  }
}

close $fh

puts "DRC_CONTEXT DONE"
puts "DRC_CONTEXT NOTE=no save_block/save_lib executed"

exit
