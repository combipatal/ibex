################################################################################
# Debug-only saved route cleanup on a copied modified-LEF ICC2 library.
#
# Opens ICC2_LIB_DIR, runs a bounded incremental route_detail cleanup, writes
# route/legality/PG/timing reports, then saves the copied candidate library.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(MOD_LEF_CLEANUP_REPORT_DIR)] && $::env(MOD_LEF_CLEANUP_REPORT_DIR) ne ""} {
  set CLEANUP_REPORT_DIR $::env(MOD_LEF_CLEANUP_REPORT_DIR)
} else {
  set CLEANUP_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/modified_lef_route_cleanup_saved
}
file mkdir $CLEANUP_REPORT_DIR

if {[info exists ::env(MOD_LEF_CLEANUP_START_ITER)] && $::env(MOD_LEF_CLEANUP_START_ITER) ne ""} {
  set CLEANUP_START_ITER $::env(MOD_LEF_CLEANUP_START_ITER)
} else {
  set CLEANUP_START_ITER 40
}

if {[info exists ::env(MOD_LEF_CLEANUP_MAX_ITER)] && $::env(MOD_LEF_CLEANUP_MAX_ITER) ne ""} {
  set CLEANUP_MAX_ITER $::env(MOD_LEF_CLEANUP_MAX_ITER)
} else {
  set CLEANUP_MAX_ITER 10
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

proc write_summary {file_name before after} {
  set fh [open $file_name w]
  puts $fh "stage\ttotal_drc\topen_nets\tdiff_net_spacing\tless_than_min_area\tneeds_fat_contact\toff_grid\tsame_net_spacing\tshort"
  foreach stage {before after} result [list $before $after] {
    puts $fh "$stage\t[dict get $result total]\t[dict get $result open_nets]\t[dict get $result diff_net_spacing]\t[dict get $result less_than_min_area]\t[dict get $result needs_fat_contact]\t[dict get $result off_grid]\t[dict get $result same_net_spacing]\t[dict get $result short]"
  }
  close $fh
}

puts "MOD_LEF_CLEANUP lib=$ICC2_LIB_DIR"
puts "MOD_LEF_CLEANUP report_dir=$CLEANUP_REPORT_DIR"
puts "MOD_LEF_CLEANUP start_iter=$CLEANUP_START_ITER max_iter=$CLEANUP_MAX_ITER"

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

redirect -file $CLEANUP_REPORT_DIR/before_check_routes.rpt {
  check_routes
}

set_app_options -name route.detail.force_max_number_iterations -value true
route_detail \
  -incremental true \
  -initial_drc_from_input true \
  -start_iteration $CLEANUP_START_ITER \
  -max_number_iterations $CLEANUP_MAX_ITER

connect_pg_net

redirect -file $CLEANUP_REPORT_DIR/after_check_routes.rpt {
  check_routes
}

redirect -file $CLEANUP_REPORT_DIR/check_legality.rpt {
  check_legality
}

redirect -file $CLEANUP_REPORT_DIR/timing.max.rpt {
  report_timing -delay_type max -max_paths 20
}

redirect -file $CLEANUP_REPORT_DIR/timing.min.rpt {
  report_timing -delay_type min -max_paths 20
}

redirect -file $CLEANUP_REPORT_DIR/qor.rpt {
  report_qor
}

redirect -file $CLEANUP_REPORT_DIR/pg_connectivity.rpt {
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $CLEANUP_REPORT_DIR/pg_connectivity_detail.rpt
}

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $CLEANUP_REPORT_DIR/pg_drc.rpt

set before [parse_check_routes $CLEANUP_REPORT_DIR/before_check_routes.rpt]
set after [parse_check_routes $CLEANUP_REPORT_DIR/after_check_routes.rpt]
write_summary $CLEANUP_REPORT_DIR/summary.tsv $before $after

puts "MOD_LEF_CLEANUP RESULT before_total=[dict get $before total] after_total=[dict get $after total] after_open_nets=[dict get $after open_nets] after_off_grid=[dict get $after off_grid] after_short=[dict get $after short]"

save_block
save_lib

puts "MOD_LEF_CLEANUP DONE"

exit
