################################################################################
# Debug-only probe for residual modified-LEF cleanup DRC.
#
# Opens a routed block, removes objects attached to VIA1 Off-grid DRC errors,
# reruns check_routes, and exits without saving. This tests whether the residual
# off-grid vias are redundant/removable or required connectivity.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(OFFGRID_PROBE_REPORT_DIR)] && $::env(OFFGRID_PROBE_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(OFFGRID_PROBE_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/probe_remove_offgrid_via1
}
file mkdir $DEBUG_REPORT_DIR

proc attr_or_na {object attr_name} {
  if {[catch {set value [get_attribute $object $attr_name]}]} {
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

proc parse_check_routes {file_name} {
  set result [dict create total NA open_nets NA off_grid 0 short 0]
  if {![file exists $file_name]} {
    return $result
  }

  set fh [open $file_name r]
  while {[gets $fh line] >= 0} {
    if {[regexp {Total number of open nets = *([0-9]+)} $line -> count]} {
      dict set result open_nets $count
    } elseif {[regexp {TOTAL VIOLATIONS = *([0-9]+)} $line -> count]} {
      dict set result total $count
    } elseif {[regexp {Off-grid : *([0-9]+)} $line -> count]} {
      dict set result off_grid $count
    } elseif {[regexp {Short : *([0-9]+)} $line -> count]} {
      dict set result short $count
    } elseif {[regexp {Total number of DRCs = *([0-9]+)} $line -> count]} {
      dict set result total $count
    }
  }
  close $fh

  return $result
}

proc write_line {fh text} {
  puts $fh $text
}

proc bbox_values {bbox} {
  set ll [lindex $bbox 0]
  set ur [lindex $bbox 1]
  return [list [lindex $ll 0] [lindex $ll 1] [lindex $ur 0] [lindex $ur 1]]
}

proc bbox_intersects_expanded {bbox target_bbox expand} {
  lassign [bbox_values $bbox] x1 y1 x2 y2
  lassign [bbox_values $target_bbox] tx1 ty1 tx2 ty2
  set tx1 [expr {$tx1 - $expand}]
  set ty1 [expr {$ty1 - $expand}]
  set tx2 [expr {$tx2 + $expand}]
  set ty2 [expr {$ty2 + $expand}]

  if {$x2 < $tx1 || $x1 > $tx2} {
    return 0
  }
  if {$y2 < $ty1 || $y1 > $ty2} {
    return 0
  }
  return 1
}

proc remove_via1_near_error {net_obj err_bbox fh idx err_name err_type err_layer} {
  set removed 0
  set vias [get_vias -quiet -of_objects $net_obj]
  foreach_in_collection via $vias {
    set via_name [get_object_name $via]
    set via_class [attr_or_na $via object_class]
    set via_bbox [attr_or_na $via bbox]
    set lower_layer [attr_or_na $via lower_layer_name]
    set upper_layer [attr_or_na $via upper_layer_name]
    set via_master [attr_or_na $via via_master]

    if {$via_bbox eq "NA"} {
      continue
    }
    if {$lower_layer ne "M1" || $upper_layer ne "M2"} {
      continue
    }
    if {![bbox_intersects_expanded $via_bbox $err_bbox 0.005]} {
      continue
    }

    if {[catch {remove_objects -force $via} remove_err]} {
      write_line $fh "$idx\t$err_name\t$err_type\t$err_layer\t$err_bbox\t$via_name\t$via_class\t$via_master:$lower_layer-$upper_layer\t$via_bbox\tREMOVE_ERROR:$remove_err"
    } else {
      incr removed
      write_line $fh "$idx\t$err_name\t$err_type\t$err_layer\t$err_bbox\t$via_name\t$via_class\t$via_master:$lower_layer-$upper_layer\t$via_bbox\tREMOVED_NEAR_NET_BBOX"
    }
  }
  return $removed
}

puts "OFFGRID_VIA1_PROBE lib=$ICC2_LIB_DIR"
puts "OFFGRID_VIA1_PROBE report_dir=$DEBUG_REPORT_DIR"

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

redirect -file $DEBUG_REPORT_DIR/before_check_routes.rpt {
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

set detail_file $DEBUG_REPORT_DIR/removed_objects.tsv
set fh [open $detail_file w]
write_line $fh "idx\terror_name\ttype\tlayer\tbbox\tobject\tobject_class\tobject_layer\tobject_bbox\taction"

set error_type [get_drc_error_types -quiet -error_data $error_data {Off-grid}]
set errors [get_drc_errors -quiet -error_data $error_data -of_objects $error_type]
set remove_count 0
set inspect_count 0

foreach_in_collection err $errors {
  incr inspect_count
  set err_name [get_object_name $err]
  set err_type [attr_or_na $err type_name]
  set err_layer [attr_or_na $err layer_name]
  set err_bbox [attr_or_na $err bbox]
  set objects [attr_or_na $err objects]

  if {$objects eq "NA" || [safe_size $objects] == 0} {
    write_line $fh "$inspect_count\t$err_name\t$err_type\t$err_layer\t$err_bbox\tNA\tNA\tNA\tNA\tNO_OBJECTS"
    continue
  }

  foreach_in_collection obj $objects {
    set obj_name [get_object_name $obj]
    set obj_class [attr_or_na $obj object_class]
    set obj_layer [attr_or_na $obj layer_name]
    set obj_bbox [attr_or_na $obj bbox]

    if {$obj_class eq "via" || $obj_layer eq "VIA1"} {
      if {[catch {remove_objects -force $obj} remove_err]} {
        write_line $fh "$inspect_count\t$err_name\t$err_type\t$err_layer\t$err_bbox\t$obj_name\t$obj_class\t$obj_layer\t$obj_bbox\tREMOVE_ERROR:$remove_err"
      } else {
        incr remove_count
        write_line $fh "$inspect_count\t$err_name\t$err_type\t$err_layer\t$err_bbox\t$obj_name\t$obj_class\t$obj_layer\t$obj_bbox\tREMOVED"
      }
    } elseif {$obj_class eq "net"} {
      set removed_here [remove_via1_near_error $obj $err_bbox $fh $inspect_count $err_name $err_type $err_layer]
      incr remove_count $removed_here
      if {$removed_here == 0} {
        write_line $fh "$inspect_count\t$err_name\t$err_type\t$err_layer\t$err_bbox\t$obj_name\t$obj_class\t$obj_layer\t$obj_bbox\tNO_NEARBY_VIA1_ON_NET"
      }
    } else {
      write_line $fh "$inspect_count\t$err_name\t$err_type\t$err_layer\t$err_bbox\t$obj_name\t$obj_class\t$obj_layer\t$obj_bbox\tSKIP_NOT_VIA1"
    }
  }
}
close $fh

if {[info exists ::env(OFFGRID_PROBE_REPAIR)] && $::env(OFFGRID_PROBE_REPAIR) eq "1"} {
  puts "OFFGRID_VIA1_PROBE repair=route_detail"
  set_app_options -name route.detail.force_max_number_iterations -value true
  route_detail \
    -incremental true \
    -initial_drc_from_input true \
    -start_iteration 50 \
    -max_number_iterations 10
}

redirect -file $DEBUG_REPORT_DIR/after_check_routes.rpt {
  check_routes
}

set before [parse_check_routes $DEBUG_REPORT_DIR/before_check_routes.rpt]
set after [parse_check_routes $DEBUG_REPORT_DIR/after_check_routes.rpt]

set sfh [open $DEBUG_REPORT_DIR/summary.tsv w]
write_line $sfh "removed_objects\tbefore_total\tbefore_open_nets\tbefore_off_grid\tbefore_short\tafter_total\tafter_open_nets\tafter_off_grid\tafter_short"
write_line $sfh "$remove_count\t[dict get $before total]\t[dict get $before open_nets]\t[dict get $before off_grid]\t[dict get $before short]\t[dict get $after total]\t[dict get $after open_nets]\t[dict get $after off_grid]\t[dict get $after short]"
close $sfh

puts "OFFGRID_VIA1_PROBE RESULT removed_objects=$remove_count before_total=[dict get $before total] before_open_nets=[dict get $before open_nets] after_total=[dict get $after total] after_open_nets=[dict get $after open_nets] after_off_grid=[dict get $after off_grid] after_short=[dict get $after short]"
puts "OFFGRID_VIA1_PROBE NOTE=no save_block/save_lib executed"

exit
