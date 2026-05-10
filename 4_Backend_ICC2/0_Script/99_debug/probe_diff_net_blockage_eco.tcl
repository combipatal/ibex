################################################################################
# Debug-only probe for residual Diff net spacing.
#
# Adds a small signal routing blockage around the observed PG VSS M2 conflict,
# rips up one target net, reroutes it with route_eco, reports check_routes, and
# exits without saving unless DIFF_ECO_SAVE=1 is set.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(DIFF_ECO_REPORT_DIR)] && $::env(DIFF_ECO_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(DIFF_ECO_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/probe_diff_net_blockage_eco
}
file mkdir $DEBUG_REPORT_DIR

if {[info exists ::env(DIFF_ECO_NET)] && $::env(DIFF_ECO_NET) ne ""} {
  set DIFF_ECO_NET $::env(DIFF_ECO_NET)
} else {
  set DIFF_ECO_NET ZBUF_1454_851
}

if {[info exists ::env(DIFF_BLOCKAGE_LAYERS)] && $::env(DIFF_BLOCKAGE_LAYERS) ne ""} {
  set DIFF_BLOCKAGE_LAYERS $::env(DIFF_BLOCKAGE_LAYERS)
} else {
  set DIFF_BLOCKAGE_LAYERS {M2}
}

if {[info exists ::env(DIFF_BLOCKAGE_HALF_X)] && $::env(DIFF_BLOCKAGE_HALF_X) ne ""} {
  set DIFF_BLOCKAGE_HALF_X $::env(DIFF_BLOCKAGE_HALF_X)
} else {
  set DIFF_BLOCKAGE_HALF_X 0.50
}

if {[info exists ::env(DIFF_BLOCKAGE_HALF_Y)] && $::env(DIFF_BLOCKAGE_HALF_Y) ne ""} {
  set DIFF_BLOCKAGE_HALF_Y $::env(DIFF_BLOCKAGE_HALF_Y)
} else {
  set DIFF_BLOCKAGE_HALF_Y 2.20
}

if {[info exists ::env(DIFF_BLOCKAGE_CX)] && $::env(DIFF_BLOCKAGE_CX) ne ""} {
  set DIFF_BLOCKAGE_CX $::env(DIFF_BLOCKAGE_CX)
} else {
  set DIFF_BLOCKAGE_CX 779.85
}

if {[info exists ::env(DIFF_BLOCKAGE_CY)] && $::env(DIFF_BLOCKAGE_CY) ne ""} {
  set DIFF_BLOCKAGE_CY $::env(DIFF_BLOCKAGE_CY)
} else {
  set DIFF_BLOCKAGE_CY 267.85
}

if {[info exists ::env(DIFF_ECO_SAVE)] && $::env(DIFF_ECO_SAVE) ne ""} {
  set DIFF_ECO_SAVE $::env(DIFF_ECO_SAVE)
} else {
  set DIFF_ECO_SAVE 0
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

puts "DIFF_BLOCKAGE_ECO lib=$ICC2_LIB_DIR"
puts "DIFF_BLOCKAGE_ECO report_dir=$DEBUG_REPORT_DIR"
puts "DIFF_BLOCKAGE_ECO net=$DIFF_ECO_NET layers=$DIFF_BLOCKAGE_LAYERS center=$DIFF_BLOCKAGE_CX,$DIFF_BLOCKAGE_CY half=$DIFF_BLOCKAGE_HALF_X,$DIFF_BLOCKAGE_HALF_Y"

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set target_net [get_nets -quiet $DIFF_ECO_NET]
if {[sizeof_collection $target_net] == 0} {
  puts stderr "ERROR: target net not found: $DIFF_ECO_NET"
  exit 2
}

redirect -file $DEBUG_REPORT_DIR/before_check_routes.rpt {
  check_routes
}

set llx [expr {$DIFF_BLOCKAGE_CX - $DIFF_BLOCKAGE_HALF_X}]
set lly [expr {$DIFF_BLOCKAGE_CY - $DIFF_BLOCKAGE_HALF_Y}]
set urx [expr {$DIFF_BLOCKAGE_CX + $DIFF_BLOCKAGE_HALF_X}]
set ury [expr {$DIFF_BLOCKAGE_CY + $DIFF_BLOCKAGE_HALF_Y}]
set blockage_boundary [list [list $llx $lly] [list $urx $ury]]

set bfh [open $DEBUG_REPORT_DIR/blockage.rpt w]
set blockage_status [catch {
  create_routing_blockage \
    -layers $DIFF_BLOCKAGE_LAYERS \
    -boundary $blockage_boundary \
    -net_types {signal} \
    -name_prefix diff_pg_vss_m2_avoid
} blockage_msg]
puts $bfh "status=$blockage_status layers=$DIFF_BLOCKAGE_LAYERS boundary=$blockage_boundary msg=$blockage_msg"
close $bfh

if {$blockage_status != 0} {
  puts stderr "ERROR: failed to create routing blockage: $blockage_msg"
  exit 2
}

remove_routes -nets $target_net -detail_route

redirect -file $DEBUG_REPORT_DIR/after_remove_check_routes.rpt {
  check_routes
}

route_eco \
  -nets $target_net \
  -max_detail_route_iterations 80 \
  -reroute modified_nets_first_then_others \
  -reuse_existing_global_route false \
  -utilize_dangling_wires true

redirect -file $DEBUG_REPORT_DIR/after_check_routes.rpt {
  check_routes
}

set before [parse_check_routes $DEBUG_REPORT_DIR/before_check_routes.rpt]
set after [parse_check_routes $DEBUG_REPORT_DIR/after_check_routes.rpt]

set sfh [open $DEBUG_REPORT_DIR/summary.tsv w]
puts $sfh "net\tlayers\tcx\tcy\thalf_x\thalf_y\tbefore_total\tbefore_open_nets\tbefore_diff_net_spacing\tbefore_off_grid\tafter_total\tafter_open_nets\tafter_diff_net_spacing\tafter_less_than_min_area\tafter_needs_fat_contact\tafter_off_grid\tafter_same_net_spacing\tafter_short"
puts $sfh "$DIFF_ECO_NET\t$DIFF_BLOCKAGE_LAYERS\t$DIFF_BLOCKAGE_CX\t$DIFF_BLOCKAGE_CY\t$DIFF_BLOCKAGE_HALF_X\t$DIFF_BLOCKAGE_HALF_Y\t[dict get $before total]\t[dict get $before open_nets]\t[dict get $before diff_net_spacing]\t[dict get $before off_grid]\t[dict get $after total]\t[dict get $after open_nets]\t[dict get $after diff_net_spacing]\t[dict get $after less_than_min_area]\t[dict get $after needs_fat_contact]\t[dict get $after off_grid]\t[dict get $after same_net_spacing]\t[dict get $after short]"
close $sfh

puts "DIFF_BLOCKAGE_ECO RESULT before_total=[dict get $before total] after_total=[dict get $after total] after_open_nets=[dict get $after open_nets] after_diff=[dict get $after diff_net_spacing] after_off_grid=[dict get $after off_grid] after_short=[dict get $after short]"

if {$DIFF_ECO_SAVE} {
  redirect -file $DEBUG_REPORT_DIR/check_legality.rpt {
    check_legality
  }
  redirect -file $DEBUG_REPORT_DIR/timing.max.rpt {
    report_timing -delay_type max -max_paths 20
  }
  redirect -file $DEBUG_REPORT_DIR/timing.min.rpt {
    report_timing -delay_type min -max_paths 20
  }
  redirect -file $DEBUG_REPORT_DIR/pg_connectivity.rpt {
    check_pg_connectivity \
      -nets [get_nets {VDD VSS}] \
      -write_connectivity_file $DEBUG_REPORT_DIR/pg_connectivity_detail.rpt
  }
  check_pg_drc \
    -nets [get_nets {VDD VSS}] \
    -no_gui \
    -output $DEBUG_REPORT_DIR/pg_drc.rpt
  save_block
  save_lib
  puts "DIFF_BLOCKAGE_ECO NOTE=saved block/library"
} else {
  puts "DIFF_BLOCKAGE_ECO NOTE=no save_block/save_lib executed"
}

exit
