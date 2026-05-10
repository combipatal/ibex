################################################################################
# Debug-only probe for residual modified-LEF cleanup DRC.
#
# Converts VIA1 Off-grid M1-M2 via arrays attached to DRC errors from 2x1 to
# 1x1 in memory, then reruns check_routes. This tests whether the residual
# off-grid class is caused by router-generated VIA12SQ_C 2-row arrays.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(SHRINK_VIA_PROBE_REPORT_DIR)] && $::env(SHRINK_VIA_PROBE_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(SHRINK_VIA_PROBE_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/probe_shrink_offgrid_via1_array
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

proc parse_check_routes {file_name} {
  set result [dict create total NA open_nets NA diff_net_spacing 0 off_grid 0 short 0 same_net_spacing 0]
  if {![file exists $file_name]} {
    return $result
  }

  set fh [open $file_name r]
  while {[gets $fh line] >= 0} {
    if {[regexp {Total number of open nets = *([0-9]+)} $line -> count]} {
      dict set result open_nets $count
    } elseif {[regexp {TOTAL VIOLATIONS = *([0-9]+)} $line -> count]} {
      dict set result total $count
    } elseif {[regexp {Diff net spacing : *([0-9]+)} $line -> count]} {
      dict set result diff_net_spacing $count
    } elseif {[regexp {Off-grid : *([0-9]+)} $line -> count]} {
      dict set result off_grid $count
    } elseif {[regexp {Same net spacing : *([0-9]+)} $line -> count]} {
      dict set result same_net_spacing $count
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

proc shrink_via1_near_error {net_obj err_bbox fh idx err_name} {
  set changed 0
  set vias [get_vias -quiet -of_objects $net_obj]
  foreach_in_collection via $vias {
    set via_name [get_object_name $via]
    set via_bbox [attr_or_na $via bbox]
    set lower_layer [attr_or_na $via lower_layer_name]
    set upper_layer [attr_or_na $via upper_layer_name]

    if {$via_bbox eq "NA"} {
      continue
    }
    if {$lower_layer ne "M1" || $upper_layer ne "M2"} {
      continue
    }
    if {![bbox_intersects_expanded $via_bbox $err_bbox 0.005]} {
      continue
    }

    set before_array [attr_or_na $via array_size]
    set before_rows [attr_or_na $via number_of_rows]
    set before_cols [attr_or_na $via number_of_columns]
    set before_bbox [attr_or_na $via bbox]
    set before_origin [attr_or_na $via origin]
    set via_def [attr_or_na $via via_def_name]

    set action OK
    if {[catch {
      set_attribute $via number_of_rows 1
      set_attribute $via number_of_columns 1
    } err]} {
      set action "SET_ERROR:$err"
    } else {
      incr changed
    }

    set after_array [attr_or_na $via array_size]
    set after_rows [attr_or_na $via number_of_rows]
    set after_cols [attr_or_na $via number_of_columns]
    set after_bbox [attr_or_na $via bbox]
    write_line $fh "$idx\t$err_name\t$via_name\t$via_def\t$before_origin\t$before_array\t$before_rows\t$before_cols\t$before_bbox\t$after_array\t$after_rows\t$after_cols\t$after_bbox\t$action"
  }
  return $changed
}

puts "SHRINK_VIA1_PROBE lib=$ICC2_LIB_DIR"
puts "SHRINK_VIA1_PROBE report_dir=$DEBUG_REPORT_DIR"

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

set detail_file $DEBUG_REPORT_DIR/changed_vias.tsv
set fh [open $detail_file w]
write_line $fh "idx\terror_name\tvia\tvia_def\torigin\tbefore_array\tbefore_rows\tbefore_cols\tbefore_bbox\tafter_array\tafter_rows\tafter_cols\tafter_bbox\taction"

set changed_count 0
set error_type [get_drc_error_types -quiet -error_data $error_data {Off-grid}]
set errors [get_drc_errors -quiet -error_data $error_data -of_objects $error_type]
set idx 0

foreach_in_collection err $errors {
  incr idx
  set err_name [get_object_name $err]
  set err_bbox [attr_or_na $err bbox]
  set objects [attr_or_na $err objects]

  if {$objects eq "NA" || [safe_size $objects] == 0} {
    continue
  }

  foreach_in_collection obj $objects {
    if {[attr_or_na $obj object_class] eq "net"} {
      incr changed_count [shrink_via1_near_error $obj $err_bbox $fh $idx $err_name]
    }
  }
}
close $fh

if {[info exists ::env(SHRINK_VIA_PROBE_REPAIR)] && $::env(SHRINK_VIA_PROBE_REPAIR) eq "1"} {
  puts "SHRINK_VIA1_PROBE repair=route_detail"
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
write_line $sfh "changed_vias\tbefore_total\tbefore_open_nets\tbefore_off_grid\tbefore_short\tafter_total\tafter_open_nets\tafter_diff_net_spacing\tafter_off_grid\tafter_same_net_spacing\tafter_short"
write_line $sfh "$changed_count\t[dict get $before total]\t[dict get $before open_nets]\t[dict get $before off_grid]\t[dict get $before short]\t[dict get $after total]\t[dict get $after open_nets]\t[dict get $after diff_net_spacing]\t[dict get $after off_grid]\t[dict get $after same_net_spacing]\t[dict get $after short]"
close $sfh

puts "SHRINK_VIA1_PROBE RESULT changed_vias=$changed_count before_total=[dict get $before total] before_open_nets=[dict get $before open_nets] after_total=[dict get $after total] after_open_nets=[dict get $after open_nets] after_off_grid=[dict get $after off_grid] after_short=[dict get $after short]"
puts "SHRINK_VIA1_PROBE NOTE=no save_block/save_lib executed"

exit
