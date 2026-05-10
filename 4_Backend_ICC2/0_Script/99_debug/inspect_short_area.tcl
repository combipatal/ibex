################################################################################
# Debug-only inspector for the residual M1 short.
#
# Opens a routed block, reruns check_routes, expands Short DRC objects, and
# lists nearby M1 shapes/vias around the short bbox. This script does not save.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(SHORT_INSPECT_REPORT_DIR)] && $::env(SHORT_INSPECT_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(SHORT_INSPECT_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/inspect_short_area
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

proc dump_collection {fh label objects} {
  set idx 0
  foreach_in_collection obj $objects {
    incr idx
    set name [object_names_or_na $obj]
    set class [attr_or_na $obj object_class]
    set layer [attr_or_na $obj layer_name]
    set bbox [attr_or_na $obj bbox]
    set net [attr_or_na $obj net]
    set net_name [object_names_or_na $net]
    set shape_use [attr_or_na $obj shape_use]
    set physical_status [attr_or_na $obj physical_status]
    set owner [attr_or_na $obj owner]
    set owner_name [object_names_or_na $owner]
    write_line $fh "$label\t$idx\t$name\t$class\t$layer\t$bbox\t$net_name\t$shape_use\t$physical_status\t$owner_name"
  }
}

puts "SHORT_INSPECT lib=$ICC2_LIB_DIR"
puts "SHORT_INSPECT report_dir=$DEBUG_REPORT_DIR"

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

set short_type [get_drc_error_types -quiet -error_data $error_data {Short}]
set short_errors [get_drc_errors -quiet -error_data $error_data -of_objects $short_type]

redirect -file $DEBUG_REPORT_DIR/short_drc_detail.rpt {
  report_drc_error \
    -error_data $error_data \
    -error_type $short_type \
    -report_type detailed \
    -nosplit
}

set fh [open $DEBUG_REPORT_DIR/short_area_objects.tsv w]
write_line $fh "label\tidx\tname\tclass\tlayer\tbbox\tnet\tshape_use\tphysical_status\towner"

set err_idx 0
foreach_in_collection err $short_errors {
  incr err_idx
  set err_name [object_names_or_na $err]
  set err_bbox [attr_or_na $err bbox]
  set err_objects [attr_or_na $err objects]
  write_line $fh "short_error\t$err_idx\t$err_name\t[attr_or_na $err object_class]\t[attr_or_na $err layer_name]\t$err_bbox\tNA\tNA\tNA\tNA"

  if {$err_objects ne "NA"} {
    dump_collection $fh "short_drc_object_$err_idx" $err_objects
  }

  set area [expand_bbox $err_bbox 0.25]

  if {![catch {set area_shapes [get_shapes -quiet -intersect $area]} shape_err]} {
    dump_collection $fh "near_shape_$err_idx" $area_shapes
  } else {
    write_line $fh "near_shape_error_$err_idx\t0\t$shape_err\tNA\tNA\t$area\tNA\tNA\tNA\tNA"
  }

  if {![catch {set area_vias [get_vias -quiet -intersect $area]} via_err]} {
    dump_collection $fh "near_via_$err_idx" $area_vias
  } else {
    write_line $fh "near_via_error_$err_idx\t0\t$via_err\tNA\tNA\t$area\tNA\tNA\tNA\tNA"
  }
}

close $fh

puts "SHORT_INSPECT DONE"
puts "SHORT_INSPECT NOTE=no save_block/save_lib executed"

exit
