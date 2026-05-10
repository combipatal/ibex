################################################################################
# Debug-only probe for residual NOR2 pin-access/off-grid DRC.
#
# Resizes NOR2 cells observed next to residual Off-grid DRC, then runs
# incremental legalize and detail route repair. This script does not save.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(NOR2_RESIZE_REPORT_DIR)] && $::env(NOR2_RESIZE_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(NOR2_RESIZE_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/probe_resize_offgrid_nor2
}
file mkdir $DEBUG_REPORT_DIR

if {[info exists ::env(NOR2_RESIZE_TARGET)] && $::env(NOR2_RESIZE_TARGET) ne ""} {
  set TARGET_REF $::env(NOR2_RESIZE_TARGET)
} else {
  set TARGET_REF NOR2X4_HVT
}

set TARGET_INSTS {
  U23131 U80571 U80632 U80708 U44775 U4214 U4110 U3055 U7945 U2900
  U8321 U5112 U6115 U6697 U6769 U3117 U3121 U80531 U80526
}

proc parse_check_routes {file_name} {
  set result [dict create total NA open_nets NA diff_net_spacing 0 less_than_min_area 0 needs_fat_contact 0 off_grid 0 short 0]
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
    } elseif {[regexp {Short : *([0-9]+)} $line -> count]} {
      dict set result short $count
    } elseif {[regexp {Total number of DRCs = *([0-9]+)} $line -> count]} {
      dict set result total $count
    }
  }
  close $fh

  return $result
}

proc write_summary {file_name target before after resize_status} {
  set fh [open $file_name w]
  puts $fh "target_ref\tresize_status\tstage\ttotal_drc\topen_nets\tdiff_net_spacing\tless_than_min_area\tneeds_fat_contact\toff_grid\tshort"
  puts $fh "$target\t$resize_status\tbefore\t[dict get $before total]\t[dict get $before open_nets]\t[dict get $before diff_net_spacing]\t[dict get $before less_than_min_area]\t[dict get $before needs_fat_contact]\t[dict get $before off_grid]\t[dict get $before short]"
  puts $fh "$target\t$resize_status\tafter\t[dict get $after total]\t[dict get $after open_nets]\t[dict get $after diff_net_spacing]\t[dict get $after less_than_min_area]\t[dict get $after needs_fat_contact]\t[dict get $after off_grid]\t[dict get $after short]"
  close $fh
}

puts "NOR2_RESIZE lib=$ICC2_LIB_DIR"
puts "NOR2_RESIZE report_dir=$DEBUG_REPORT_DIR"
puts "NOR2_RESIZE target_ref=$TARGET_REF"

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

redirect -file $DEBUG_REPORT_DIR/before_check_routes.rpt {
  check_routes
}
set before [parse_check_routes $DEBUG_REPORT_DIR/before_check_routes.rpt]

set lib_cell [get_lib_cells -quiet */$TARGET_REF]
set resize_status ok
if {[sizeof_collection $lib_cell] == 0} {
  set resize_status missing_target_ref
} else {
  set resized_fh [open $DEBUG_REPORT_DIR/resized_cells.tsv w]
  puts $resized_fh "inst\told_ref\ttarget_ref\tstatus"
  foreach inst $TARGET_INSTS {
    set cell [get_cells -quiet $inst]
    if {[sizeof_collection $cell] == 0} {
      puts $resized_fh "$inst\tNA\t$TARGET_REF\tmissing_inst"
      continue
    }
    set old_ref [get_attribute $cell ref_name]
    if {[catch {size_cell $cell $lib_cell} err]} {
      puts $resized_fh "$inst\t$old_ref\t$TARGET_REF\terror:$err"
      set resize_status resize_error
    } else {
      puts $resized_fh "$inst\t$old_ref\t$TARGET_REF\tok"
    }
  }
  close $resized_fh
}

if {$resize_status eq "ok"} {
  redirect -file $DEBUG_REPORT_DIR/legalize_placement.rpt {
    legalize_placement -incremental
  }

  set_app_options -name route.detail.force_max_number_iterations -value true
  route_detail \
    -incremental true \
    -initial_drc_from_input true \
    -start_iteration 40 \
    -max_number_iterations 10
}

redirect -file $DEBUG_REPORT_DIR/after_check_routes.rpt {
  check_routes
}
set after [parse_check_routes $DEBUG_REPORT_DIR/after_check_routes.rpt]
write_summary $DEBUG_REPORT_DIR/summary.tsv $TARGET_REF $before $after $resize_status

puts "NOR2_RESIZE RESULT target_ref=$TARGET_REF resize_status=$resize_status before_total=[dict get $before total] before_open=[dict get $before open_nets] after_total=[dict get $after total] after_open=[dict get $after open_nets] after_off_grid=[dict get $after off_grid] after_short=[dict get $after short] after_needs_fat_contact=[dict get $after needs_fat_contact]"
puts "NOR2_RESIZE NOTE=no save_block/save_lib executed"

exit
