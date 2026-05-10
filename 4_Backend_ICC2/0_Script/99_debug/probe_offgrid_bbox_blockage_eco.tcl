################################################################################
# Debug-only probe for residual Off-grid DRC.
#
# Adds small routing blockages around each current Off-grid DRC bbox, removes
# detail route for the DRC nets, reroutes only those nets with route_eco, and
# reports check_routes. Does not save unless OFFGRID_BLOCKAGE_SAVE=1 is set.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(OFFGRID_BLOCKAGE_REPORT_DIR)] && $::env(OFFGRID_BLOCKAGE_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(OFFGRID_BLOCKAGE_REPORT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/probe_offgrid_bbox_blockage_eco
}
file mkdir $DEBUG_REPORT_DIR

if {[info exists ::env(OFFGRID_BLOCKAGE_LAYERS)] && $::env(OFFGRID_BLOCKAGE_LAYERS) ne ""} {
  set OFFGRID_BLOCKAGE_LAYERS $::env(OFFGRID_BLOCKAGE_LAYERS)
} else {
  set OFFGRID_BLOCKAGE_LAYERS {M2}
}

if {[info exists ::env(OFFGRID_BLOCKAGE_MARGIN_X)] && $::env(OFFGRID_BLOCKAGE_MARGIN_X) ne ""} {
  set OFFGRID_BLOCKAGE_MARGIN_X $::env(OFFGRID_BLOCKAGE_MARGIN_X)
} else {
  set OFFGRID_BLOCKAGE_MARGIN_X 0.12
}

if {[info exists ::env(OFFGRID_BLOCKAGE_MARGIN_Y)] && $::env(OFFGRID_BLOCKAGE_MARGIN_Y) ne ""} {
  set OFFGRID_BLOCKAGE_MARGIN_Y $::env(OFFGRID_BLOCKAGE_MARGIN_Y)
} else {
  set OFFGRID_BLOCKAGE_MARGIN_Y 0.16
}

if {[info exists ::env(OFFGRID_BLOCKAGE_SAVE)] && $::env(OFFGRID_BLOCKAGE_SAVE) ne ""} {
  set OFFGRID_BLOCKAGE_SAVE $::env(OFFGRID_BLOCKAGE_SAVE)
} else {
  set OFFGRID_BLOCKAGE_SAVE 0
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

proc expand_bbox_xy {bbox margin_x margin_y} {
  lassign [bbox_values $bbox] x1 y1 x2 y2
  return [list [list [expr {$x1 - $margin_x}] [expr {$y1 - $margin_y}]] [list [expr {$x2 + $margin_x}] [expr {$y2 + $margin_y}]]]
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

proc append_unique_net {net_list_var net_obj} {
  upvar $net_list_var net_list
  set net_name [object_names_or_na $net_obj]
  if {$net_name eq "NA" || $net_name eq "VDD" || $net_name eq "VSS"} {
    return
  }
  if {[lsearch -exact $net_list $net_name] < 0} {
    lappend net_list $net_name
  }
}

puts "OFFGRID_BLOCKAGE_ECO lib=$ICC2_LIB_DIR"
puts "OFFGRID_BLOCKAGE_ECO report_dir=$DEBUG_REPORT_DIR"
puts "OFFGRID_BLOCKAGE_ECO layers=$OFFGRID_BLOCKAGE_LAYERS margin=$OFFGRID_BLOCKAGE_MARGIN_X,$OFFGRID_BLOCKAGE_MARGIN_Y"

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

set fh [open $DEBUG_REPORT_DIR/blockages.tsv w]
puts $fh "idx\terror_name\terror_layer\terror_bbox\tblockage_boundary\tnets\taction"

set target_net_names {}
set blockage_count 0
set error_type [get_drc_error_types -quiet -error_data $error_data {Off-grid}]
set errors [get_drc_errors -quiet -error_data $error_data -of_objects $error_type]
set idx 0

foreach_in_collection err $errors {
  incr idx
  set err_name [object_names_or_na $err]
  set err_bbox [attr_or_na $err bbox]
  set err_layer [attr_or_na $err layer_name]
  set objects [attr_or_na $err objects]
  set err_nets {}

  if {$err_bbox eq "NA"} {
    puts $fh "$idx\t$err_name\t$err_layer\t$err_bbox\tNA\tNA\tSKIP_NO_BBOX"
    continue
  }

  if {$objects ne "NA"} {
    foreach_in_collection obj $objects {
      if {[attr_or_na $obj object_class] eq "net"} {
        append_unique_net target_net_names $obj
        lappend err_nets [object_names_or_na $obj]
      }
    }
  }

  set boundary [expand_bbox_xy $err_bbox $OFFGRID_BLOCKAGE_MARGIN_X $OFFGRID_BLOCKAGE_MARGIN_Y]
  if {[catch {
    create_routing_blockage \
      -layers $OFFGRID_BLOCKAGE_LAYERS \
      -boundary $boundary \
      -net_types {signal} \
      -name_prefix offgrid_bbox_avoid
  } blockage_msg]} {
    puts $fh "$idx\t$err_name\t$err_layer\t$err_bbox\t$boundary\t$err_nets\tBLOCKAGE_ERROR:$blockage_msg"
  } else {
    incr blockage_count
    puts $fh "$idx\t$err_name\t$err_layer\t$err_bbox\t$boundary\t$err_nets\tBLOCKAGE_CREATED"
  }
}
close $fh

if {[llength $target_net_names] == 0} {
  puts stderr "ERROR: no target signal nets collected"
  exit 2
}

set target_nets [get_nets -quiet $target_net_names]
set nf [open $DEBUG_REPORT_DIR/target_nets.rpt w]
foreach net_name $target_net_names {
  puts $nf $net_name
}
close $nf

remove_routes -nets $target_nets -detail_route

redirect -file $DEBUG_REPORT_DIR/after_remove_check_routes.rpt {
  check_routes
}

route_eco \
  -nets $target_nets \
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
puts $sfh "layers\tmargin_x\tmargin_y\tblockages\ttarget_nets\tbefore_total\tbefore_open_nets\tbefore_off_grid\tbefore_short\tafter_total\tafter_open_nets\tafter_diff_net_spacing\tafter_less_than_min_area\tafter_needs_fat_contact\tafter_off_grid\tafter_same_net_spacing\tafter_short"
puts $sfh "$OFFGRID_BLOCKAGE_LAYERS\t$OFFGRID_BLOCKAGE_MARGIN_X\t$OFFGRID_BLOCKAGE_MARGIN_Y\t$blockage_count\t[llength $target_net_names]\t[dict get $before total]\t[dict get $before open_nets]\t[dict get $before off_grid]\t[dict get $before short]\t[dict get $after total]\t[dict get $after open_nets]\t[dict get $after diff_net_spacing]\t[dict get $after less_than_min_area]\t[dict get $after needs_fat_contact]\t[dict get $after off_grid]\t[dict get $after same_net_spacing]\t[dict get $after short]"
close $sfh

puts "OFFGRID_BLOCKAGE_ECO RESULT before_total=[dict get $before total] after_total=[dict get $after total] after_open_nets=[dict get $after open_nets] after_off_grid=[dict get $after off_grid] after_short=[dict get $after short]"

if {$OFFGRID_BLOCKAGE_SAVE} {
  redirect -file $DEBUG_REPORT_DIR/check_legality.rpt {
    check_legality
  }
  save_block
  save_lib
  puts "OFFGRID_BLOCKAGE_ECO NOTE=saved block/library"
} else {
  puts "OFFGRID_BLOCKAGE_ECO NOTE=no save_block/save_lib executed"
}

exit
