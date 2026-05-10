################################################################################
# Debug-only probe for residual modified-LEF cleanup DRC.
#
# Replaces the M1-M2 vias attached to residual VIA1 Off-grid errors with an
# explicit via_def at the same origin/net, then reruns check_routes. This tests
# whether router-created via arrays can be represented by a legal fixed via_def.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(REPLACE_VIA_PROBE_REPORT_DIR)] && $::env(REPLACE_VIA_PROBE_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(REPLACE_VIA_PROBE_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/probe_replace_offgrid_via1_def
}
file mkdir $DEBUG_REPORT_DIR

if {[info exists ::env(REPLACE_VIA_DEF)] && $::env(REPLACE_VIA_DEF) ne ""} {
  set REPLACE_VIA_DEF $::env(REPLACE_VIA_DEF)
} else {
  set REPLACE_VIA_DEF VIA12SQ_C_1x2
}

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
  set result [dict create total NA open_nets NA diff_net_spacing 0 less_than_min_area 0 needs_fat_contact 0 off_grid 0 short 0 same_net_spacing 0]
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
    } elseif {[regexp {Less than minimum area : *([0-9]+)} $line -> count]} {
      dict set result less_than_min_area $count
    } elseif {[regexp {Needs fat contact : *([0-9]+)} $line -> count]} {
      dict set result needs_fat_contact $count
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

proc replace_via1_near_error {net_obj err_bbox via_def fh idx err_name} {
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

    set before_via_def [attr_or_na $via via_def_name]
    set before_origin [attr_or_na $via origin]
    set before_bbox [attr_or_na $via bbox]
    set before_array [attr_or_na $via array_size]

    set action OK
    if {[catch {
      remove_objects -force $via
      set new_via [create_via \
        -via_def $via_def \
        -origin $before_origin \
        -net $net_obj \
        -shape_use detail_route]
    } err]} {
      set action "REPLACE_ERROR:$err"
      set new_name NA
      set new_bbox NA
      set new_via_def NA
      set new_array NA
    } else {
      incr changed
      set new_name [get_object_name $new_via]
      set new_bbox [attr_or_na $new_via bbox]
      set new_via_def [attr_or_na $new_via via_def_name]
      set new_array [attr_or_na $new_via array_size]
    }

    write_line $fh "$idx\t$err_name\t$via_name\t$before_via_def\t$before_origin\t$before_array\t$before_bbox\t$new_name\t$new_via_def\t$new_array\t$new_bbox\t$action"
  }
  return $changed
}

puts "REPLACE_VIA1_PROBE lib=$ICC2_LIB_DIR"
puts "REPLACE_VIA1_PROBE report_dir=$DEBUG_REPORT_DIR"
puts "REPLACE_VIA1_PROBE via_def=$REPLACE_VIA_DEF"

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set via_def_status ok
if {[catch {set candidate_via_defs [get_via_defs -quiet $REPLACE_VIA_DEF]} via_def_error]} {
  set via_def_status $via_def_error
} elseif {[safe_size $candidate_via_defs] == 0} {
  set via_def_status "via_def_not_found"
}

if {$via_def_status ne "ok"} {
  set fh [open $DEBUG_REPORT_DIR/via_def_precheck.error w]
  write_line $fh "REPLACE_VIA_DEF=$REPLACE_VIA_DEF"
  write_line $fh "status=$via_def_status"
  write_line $fh "No route objects were modified."
  close $fh

  puts stderr "ERROR: replacement via_def precheck failed for $REPLACE_VIA_DEF: $via_def_status"
  puts stderr "ERROR: no route objects were modified"
  exit 3
}

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

set detail_file $DEBUG_REPORT_DIR/replaced_vias.tsv
set fh [open $detail_file w]
write_line $fh "idx\terror_name\told_via\told_via_def\torigin\told_array\told_bbox\tnew_via\tnew_via_def\tnew_array\tnew_bbox\taction"

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
      incr changed_count [replace_via1_near_error $obj $err_bbox $REPLACE_VIA_DEF $fh $idx $err_name]
    }
  }
}
close $fh

redirect -file $DEBUG_REPORT_DIR/after_check_routes.rpt {
  check_routes
}

set before [parse_check_routes $DEBUG_REPORT_DIR/before_check_routes.rpt]
set after [parse_check_routes $DEBUG_REPORT_DIR/after_check_routes.rpt]

set sfh [open $DEBUG_REPORT_DIR/summary.tsv w]
write_line $sfh "via_def\tchanged_vias\tbefore_total\tbefore_open_nets\tbefore_off_grid\tbefore_short\tafter_total\tafter_open_nets\tafter_diff_net_spacing\tafter_less_than_min_area\tafter_needs_fat_contact\tafter_off_grid\tafter_same_net_spacing\tafter_short"
write_line $sfh "$REPLACE_VIA_DEF\t$changed_count\t[dict get $before total]\t[dict get $before open_nets]\t[dict get $before off_grid]\t[dict get $before short]\t[dict get $after total]\t[dict get $after open_nets]\t[dict get $after diff_net_spacing]\t[dict get $after less_than_min_area]\t[dict get $after needs_fat_contact]\t[dict get $after off_grid]\t[dict get $after same_net_spacing]\t[dict get $after short]"
close $sfh

puts "REPLACE_VIA1_PROBE RESULT via_def=$REPLACE_VIA_DEF changed_vias=$changed_count before_total=[dict get $before total] before_open_nets=[dict get $before open_nets] after_total=[dict get $after total] after_open_nets=[dict get $after open_nets] after_off_grid=[dict get $after off_grid] after_needs_fat_contact=[dict get $after needs_fat_contact] after_short=[dict get $after short]"
puts "REPLACE_VIA1_PROBE NOTE=no save_block/save_lib executed"

exit
