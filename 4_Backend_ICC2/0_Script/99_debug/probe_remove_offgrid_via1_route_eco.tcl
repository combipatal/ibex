################################################################################
# Debug-only probe for residual VIA1 Off-grid DRC.
#
# Removes M1-M2 vias adjacent to Off-grid DRC errors, then reroutes only the
# affected nets with route_eco. This tests whether the residual off-grid vias can
# be regenerated legally when the affected nets are explicitly reopened.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(OFFGRID_ECO_REPORT_DIR)] && $::env(OFFGRID_ECO_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(OFFGRID_ECO_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/probe_remove_offgrid_via1_route_eco
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
  set result [dict create total NA open_nets NA diff_net_spacing 0 less_than_min_area 0 needs_fat_contact 0 off_grid 0 same_net_spacing 0 short 0]
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

proc list_has {items item} {
  expr {[lsearch -exact $items $item] >= 0}
}

proc remove_via1_near_error {net_obj err_bbox fh idx err_name} {
  set removed 0
  set vias [get_vias -quiet -of_objects $net_obj]
  foreach_in_collection via $vias {
    set via_name [get_object_name $via]
    set via_bbox [attr_or_na $via bbox]
    set lower_layer [attr_or_na $via lower_layer_name]
    set upper_layer [attr_or_na $via upper_layer_name]
    set via_def [attr_or_na $via via_def_name]

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
      write_line $fh "$idx\t$err_name\t[get_object_name $net_obj]\t$via_name\t$via_def\t$via_bbox\tREMOVE_ERROR:$remove_err"
    } else {
      incr removed
      write_line $fh "$idx\t$err_name\t[get_object_name $net_obj]\t$via_name\t$via_def\t$via_bbox\tREMOVED"
    }
  }
  return $removed
}

puts "OFFGRID_VIA1_ECO lib=$ICC2_LIB_DIR"
puts "OFFGRID_VIA1_ECO report_dir=$DEBUG_REPORT_DIR"

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

set fh [open $DEBUG_REPORT_DIR/removed_vias.tsv w]
write_line $fh "idx\terror_name\tnet\tvia\tvia_def\tvia_bbox\taction"

set changed_net_names {}
set remove_count 0
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
    if {[attr_or_na $obj object_class] ne "net"} {
      continue
    }
    set removed_here [remove_via1_near_error $obj $err_bbox $fh $idx $err_name]
    if {$removed_here > 0} {
      incr remove_count $removed_here
      set net_name [get_object_name $obj]
      if {![list_has $changed_net_names $net_name]} {
        lappend changed_net_names $net_name
      }
    }
  }
}
close $fh

set nfh [open $DEBUG_REPORT_DIR/changed_nets.list w]
foreach net_name $changed_net_names {
  puts $nfh $net_name
}
close $nfh

redirect -file $DEBUG_REPORT_DIR/after_remove_check_routes.rpt {
  check_routes
}

if {[llength $changed_net_names] > 0} {
  set changed_nets [get_nets -quiet $changed_net_names]
  route_eco \
    -nets $changed_nets \
    -max_detail_route_iterations 80 \
    -reroute modified_nets_first_then_others \
    -reuse_existing_global_route false \
    -utilize_dangling_wires true
}

redirect -file $DEBUG_REPORT_DIR/after_check_routes.rpt {
  check_routes
}

set before [parse_check_routes $DEBUG_REPORT_DIR/before_check_routes.rpt]
set after_remove [parse_check_routes $DEBUG_REPORT_DIR/after_remove_check_routes.rpt]
set after [parse_check_routes $DEBUG_REPORT_DIR/after_check_routes.rpt]

set sfh [open $DEBUG_REPORT_DIR/summary.tsv w]
write_line $sfh "stage\tremoved_vias\tchanged_nets\ttotal\topen_nets\tdiff_net_spacing\tless_than_min_area\tneeds_fat_contact\toff_grid\tsame_net_spacing\tshort"
write_line $sfh "before\t0\t0\t[dict get $before total]\t[dict get $before open_nets]\t[dict get $before diff_net_spacing]\t[dict get $before less_than_min_area]\t[dict get $before needs_fat_contact]\t[dict get $before off_grid]\t[dict get $before same_net_spacing]\t[dict get $before short]"
write_line $sfh "after_remove\t$remove_count\t[llength $changed_net_names]\t[dict get $after_remove total]\t[dict get $after_remove open_nets]\t[dict get $after_remove diff_net_spacing]\t[dict get $after_remove less_than_min_area]\t[dict get $after_remove needs_fat_contact]\t[dict get $after_remove off_grid]\t[dict get $after_remove same_net_spacing]\t[dict get $after_remove short]"
write_line $sfh "after_eco\t$remove_count\t[llength $changed_net_names]\t[dict get $after total]\t[dict get $after open_nets]\t[dict get $after diff_net_spacing]\t[dict get $after less_than_min_area]\t[dict get $after needs_fat_contact]\t[dict get $after off_grid]\t[dict get $after same_net_spacing]\t[dict get $after short]"
close $sfh

puts "OFFGRID_VIA1_ECO RESULT removed_vias=$remove_count changed_nets=[llength $changed_net_names] after_total=[dict get $after total] after_open_nets=[dict get $after open_nets] after_off_grid=[dict get $after off_grid] after_short=[dict get $after short]"
puts "OFFGRID_VIA1_ECO NOTE=no save_block/save_lib executed"

exit
