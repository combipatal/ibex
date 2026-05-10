################################################################################
# Debug-only route DRC variant probe.
#
# Runs one route repair/reroute experiment in memory, reports check_routes, and
# exits without save_block/save_lib.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(ROUTE_DRC_VARIANT)]} {
  set ROUTE_DRC_VARIANT $::env(ROUTE_DRC_VARIANT)
} else {
  set ROUTE_DRC_VARIANT detail_extra
}

if {[info exists ::env(ROUTE_DRC_VARIANT_REPORT_DIR)] && $::env(ROUTE_DRC_VARIANT_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(ROUTE_DRC_VARIANT_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/route_drc_variants/$ROUTE_DRC_VARIANT
}
file mkdir $DEBUG_REPORT_DIR

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

proc write_summary {file_name variant result} {
  set fh [open $file_name w]
  puts $fh "variant\ttotal_drc\topen_nets\tdiff_net_spacing\tless_than_min_area\tneeds_fat_contact\toff_grid\tshort"
  puts $fh "$variant\t[dict get $result total]\t[dict get $result open_nets]\t[dict get $result diff_net_spacing]\t[dict get $result less_than_min_area]\t[dict get $result needs_fat_contact]\t[dict get $result off_grid]\t[dict get $result short]"
  close $fh
}

proc run_short_incremental_detail {} {
  set_app_options -name route.detail.force_max_number_iterations -value true
  route_detail \
    -incremental true \
    -initial_drc_from_input true \
    -start_iteration 40 \
    -max_number_iterations 5
}

puts "ROUTE_DRC_VARIANT variant=$ROUTE_DRC_VARIANT"
puts "ROUTE_DRC_VARIANT report_dir=$DEBUG_REPORT_DIR"

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

redirect -file $DEBUG_REPORT_DIR/before_check_routes.rpt {
  check_routes
}

if {$ROUTE_DRC_VARIANT eq "detail_extra"} {
  set_app_options -name route.detail.force_max_number_iterations -value true
  route_detail \
    -incremental true \
    -initial_drc_from_input true \
    -start_iteration 40 \
    -max_number_iterations 10
} elseif {$ROUTE_DRC_VARIANT eq "fat_contact_effort"} {
  redirect -file $DEBUG_REPORT_DIR/app_options.before.rpt {
    report_app_options route.detail.fat_metal_forbidden_pitch_effort_level
    report_app_options route.detail.optimize_wire_via_effort_level
  }

  set option_status ok
  if {[catch {
    set_app_options -name route.detail.fat_metal_forbidden_pitch_effort_level -value high
    set_app_options -name route.detail.optimize_wire_via_effort_level -value high
  } option_error]} {
    set option_status error
    set fh [open $DEBUG_REPORT_DIR/app_option_error.rpt w]
    puts $fh $option_error
    close $fh
  }

  redirect -file $DEBUG_REPORT_DIR/app_options.after.rpt {
    report_app_options route.detail.fat_metal_forbidden_pitch_effort_level
    report_app_options route.detail.optimize_wire_via_effort_level
  }

  if {$option_status ne "ok"} {
    puts stderr "ERROR: failed to set fat_contact_effort route options"
    exit 2
  }

  run_short_incremental_detail
} elseif {$ROUTE_DRC_VARIANT eq "via_array_off"} {
  redirect -file $DEBUG_REPORT_DIR/app_options.before.rpt {
    report_app_options route.common.via_array_mode
  }

  set_app_options -name route.common.via_array_mode -value off

  redirect -file $DEBUG_REPORT_DIR/app_options.after.rpt {
    report_app_options route.common.via_array_mode
  }

  run_short_incremental_detail
} elseif {$ROUTE_DRC_VARIANT eq "via_array_off_fat_contact"} {
  redirect -file $DEBUG_REPORT_DIR/app_options.before.rpt {
    report_app_options route.common.via_array_mode
    report_app_options route.detail.fat_metal_forbidden_pitch_effort_level
    report_app_options route.detail.optimize_wire_via_effort_level
  }

  set_app_options -name route.common.via_array_mode -value off
  set_app_options -name route.detail.fat_metal_forbidden_pitch_effort_level -value high
  set_app_options -name route.detail.optimize_wire_via_effort_level -value high

  redirect -file $DEBUG_REPORT_DIR/app_options.after.rpt {
    report_app_options route.common.via_array_mode
    report_app_options route.detail.fat_metal_forbidden_pitch_effort_level
    report_app_options route.detail.optimize_wire_via_effort_level
  }

  run_short_incremental_detail
} elseif {$ROUTE_DRC_VARIANT eq "via1_on_grid"} {
  redirect -file $DEBUG_REPORT_DIR/app_options.before.rpt {
    report_app_options route.common.via_on_grid_by_layer_name
  }

  set_app_options -name route.common.via_on_grid_by_layer_name -value {{VIA1 true}}

  redirect -file $DEBUG_REPORT_DIR/app_options.after.rpt {
    report_app_options route.common.via_on_grid_by_layer_name
  }

  run_short_incremental_detail
} elseif {$ROUTE_DRC_VARIANT eq "via_ladder_clean"} {
  redirect -file $DEBUG_REPORT_DIR/app_options.before.rpt {
    report_app_options route.auto_via_ladder.check_drcs_on_existing_via_ladders
    report_app_options route.auto_via_ladder.clean
    report_app_options route.auto_via_ladder.connect_within_metal
    report_app_options route.auto_via_ladder.allow_via_array_as_single_cut
  }

  set_app_options -name route.auto_via_ladder.check_drcs_on_existing_via_ladders -value true
  set_app_options -name route.auto_via_ladder.clean -value true
  set_app_options -name route.auto_via_ladder.connect_within_metal -value true
  set_app_options -name route.auto_via_ladder.allow_via_array_as_single_cut -value false

  redirect -file $DEBUG_REPORT_DIR/app_options.after.rpt {
    report_app_options route.auto_via_ladder.check_drcs_on_existing_via_ladders
    report_app_options route.auto_via_ladder.clean
    report_app_options route.auto_via_ladder.connect_within_metal
    report_app_options route.auto_via_ladder.allow_via_array_as_single_cut
  }

  run_short_incremental_detail
} elseif {$ROUTE_DRC_VARIANT eq "via1_offgrid_cost"} {
  redirect -file $DEBUG_REPORT_DIR/app_options.before.rpt {
    report_app_options route.common.extra_via_off_grid_cost_multiplier_by_layer_name
  }

  set_app_options -name route.common.extra_via_off_grid_cost_multiplier_by_layer_name -value {{VIA1 20.0}}

  redirect -file $DEBUG_REPORT_DIR/app_options.after.rpt {
    report_app_options route.common.extra_via_off_grid_cost_multiplier_by_layer_name
  }

  run_short_incremental_detail
} elseif {$ROUTE_DRC_VARIANT eq "reroute_m2"} {
  remove_routes -net_types {signal clock} -detail_route
  remove_routes -net_types {signal clock} -global_route
  remove_routes -net_types {signal clock} -lib_cell_pin_connect

  set_ignored_layers \
    -min_routing_layer M2 \
    -max_routing_layer M8

  redirect -file $DEBUG_REPORT_DIR/check_routability.rpt {
    check_routability
  }

  route_auto -max_detail_route_iterations 80
} else {
  puts stderr "ERROR: unknown ROUTE_DRC_VARIANT=$ROUTE_DRC_VARIANT"
  exit 2
}

redirect -file $DEBUG_REPORT_DIR/after_check_routes.rpt {
  check_routes
}

set result [parse_check_routes $DEBUG_REPORT_DIR/after_check_routes.rpt]
write_summary $DEBUG_REPORT_DIR/summary.tsv $ROUTE_DRC_VARIANT $result

puts "ROUTE_DRC_VARIANT RESULT variant=$ROUTE_DRC_VARIANT total_drc=[dict get $result total] open_nets=[dict get $result open_nets] diff_net_spacing=[dict get $result diff_net_spacing] less_than_min_area=[dict get $result less_than_min_area] needs_fat_contact=[dict get $result needs_fat_contact] off_grid=[dict get $result off_grid] short=[dict get $result short]"
puts "ROUTE_DRC_VARIANT NOTE=no save_block/save_lib executed"

exit
