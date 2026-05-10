################################################################################
# Debug-only probe for targeted ECO routing of the residual M1 short net.
#
# Opens a routed block, optionally removes target-net detail route, runs
# route_eco on the target net, reports check_routes, and exits without saving.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(SHORT_ECO_REPORT_DIR)] && $::env(SHORT_ECO_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(SHORT_ECO_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/probe_short_net_eco
}
file mkdir $DEBUG_REPORT_DIR

if {[info exists ::env(SHORT_ECO_NET)] && $::env(SHORT_ECO_NET) ne ""} {
  set SHORT_ECO_NET $::env(SHORT_ECO_NET)
} else {
  set SHORT_ECO_NET n48420
}

if {[info exists ::env(SHORT_ECO_MODE)] && $::env(SHORT_ECO_MODE) ne ""} {
  set SHORT_ECO_MODE $::env(SHORT_ECO_MODE)
} else {
  set SHORT_ECO_MODE eco_only
}

proc write_line {fh text} {
  puts $fh $text
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

puts "SHORT_ECO lib=$ICC2_LIB_DIR"
puts "SHORT_ECO report_dir=$DEBUG_REPORT_DIR"
puts "SHORT_ECO net=$SHORT_ECO_NET mode=$SHORT_ECO_MODE"

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set target_net [get_nets -quiet $SHORT_ECO_NET]
if {[sizeof_collection $target_net] == 0} {
  puts stderr "ERROR: target net not found: $SHORT_ECO_NET"
  exit 2
}

redirect -file $DEBUG_REPORT_DIR/before_check_routes.rpt {
  check_routes
}

if {$SHORT_ECO_MODE eq "remove_detail_then_eco"} {
  remove_routes -nets $target_net -detail_route
  redirect -file $DEBUG_REPORT_DIR/after_remove_check_routes.rpt {
    check_routes
  }
} elseif {$SHORT_ECO_MODE ne "eco_only"} {
  puts stderr "ERROR: unknown SHORT_ECO_MODE=$SHORT_ECO_MODE"
  exit 2
}

route_eco \
  -nets $target_net \
  -max_detail_route_iterations 80 \
  -reroute modified_nets_first_then_others \
  -reuse_existing_global_route true \
  -utilize_dangling_wires true

redirect -file $DEBUG_REPORT_DIR/after_check_routes.rpt {
  check_routes
}

set before [parse_check_routes $DEBUG_REPORT_DIR/before_check_routes.rpt]
set after [parse_check_routes $DEBUG_REPORT_DIR/after_check_routes.rpt]

set sfh [open $DEBUG_REPORT_DIR/summary.tsv w]
write_line $sfh "net\tmode\tbefore_total\tbefore_open_nets\tbefore_off_grid\tbefore_short\tafter_total\tafter_open_nets\tafter_diff_net_spacing\tafter_less_than_min_area\tafter_needs_fat_contact\tafter_off_grid\tafter_short"
write_line $sfh "$SHORT_ECO_NET\t$SHORT_ECO_MODE\t[dict get $before total]\t[dict get $before open_nets]\t[dict get $before off_grid]\t[dict get $before short]\t[dict get $after total]\t[dict get $after open_nets]\t[dict get $after diff_net_spacing]\t[dict get $after less_than_min_area]\t[dict get $after needs_fat_contact]\t[dict get $after off_grid]\t[dict get $after short]"
close $sfh

puts "SHORT_ECO RESULT net=$SHORT_ECO_NET mode=$SHORT_ECO_MODE before_total=[dict get $before total] after_total=[dict get $after total] after_open_nets=[dict get $after open_nets] after_off_grid=[dict get $after off_grid] after_short=[dict get $after short]"
puts "SHORT_ECO NOTE=no save_block/save_lib executed"

exit
