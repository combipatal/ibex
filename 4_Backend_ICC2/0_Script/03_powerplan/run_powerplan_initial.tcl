################################################################################
# ICC2 initial power plan for Ibex Mini SoC.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

if {[sizeof_collection [get_nets -quiet VDD]] == 0} {
  create_net -power VDD
}

if {[sizeof_collection [get_nets -quiet VSS]] == 0} {
  create_net -ground VSS
}

set PG_NETS [get_nets -quiet {VDD VSS}]

proc attr_or_na {object attr_name} {
  if {[catch {set value [get_attribute $object $attr_name]}]} {
    return "NA"
  }
  return $value
}

proc bbox_intersects_window {bbox x_min x_max y_min y_max} {
  set ll [lindex $bbox 0]
  set ur [lindex $bbox 1]
  set bx_min [lindex $ll 0]
  set by_min [lindex $ll 1]
  set bx_max [lindex $ur 0]
  set by_max [lindex $ur 1]

  if {$bx_max < $x_min || $bx_min > $x_max} {
    return 0
  }
  if {$by_max < $y_min || $by_min > $y_max} {
    return 0
  }
  return 1
}

proc remove_conflicting_upper_pg_vias {net_name x y report_fh} {
  set x_min [expr {$x - 0.25}]
  set x_max [expr {$x + 0.25}]
  set y_min [expr {$y - 0.15}]
  set y_max [expr {$y + 0.15}]
  set to_remove {}

  set vias [get_vias -quiet -of_objects [get_nets -quiet $net_name]]
  foreach_in_collection via $vias {
    set bbox [attr_or_na $via bbox]
    if {$bbox eq "NA" || ![bbox_intersects_window $bbox $x_min $x_max $y_min $y_max]} {
      continue
    }

    set lower_layer [attr_or_na $via lower_layer_name]
    set upper_layer [attr_or_na $via upper_layer_name]
    if {$lower_layer eq "M1" && $upper_layer eq "M2"} {
      continue
    }

    set full_name [attr_or_na $via full_name]
    puts $report_fh "REMOVE net=$net_name point=$x,$y object=$full_name bbox=$bbox lower_layer=$lower_layer upper_layer=$upper_layer"
    lappend to_remove $via
  }

  set removed_count 0
  foreach via $to_remove {
    remove_objects -force $via
    incr removed_count
  }
  return $removed_count
}

proc add_pg_rail_stitches {report_dir} {
  set stitch_specs {
    {VDD 840.0 327.648}
    {VDD 840.0 367.776}
    {VDD 840.0 407.904}
    {VDD 840.0 448.032}
    {VDD 840.0 488.160}
    {VDD 840.0 528.288}
    {VDD 840.0 568.416}
    {VSS 820.0 827.576}
  }
  set via_def_candidates {VIA12SQ_C VIA12_C VIA12}

  set stitch_report $report_dir/pg_rail_stitches.rpt
  set stitch_fh [open $stitch_report w]
  set removed_count 0
  set created_count 0

  foreach spec $stitch_specs {
    lassign $spec net_name x y
    set point [list $x $y]
    set created_here 0

    incr removed_count [remove_conflicting_upper_pg_vias $net_name $x $y $stitch_fh]

    foreach via_def $via_def_candidates {
      if {[catch {
        set new_via [create_via \
          -via_def $via_def \
          -origin $point \
          -net [get_nets $net_name] \
          -shape_use lib_cell_pin_connect]
      } err]} {
        puts $stitch_fh "FAIL net=$net_name point=$point via_def=$via_def error=$err"
        continue
      }

      puts $stitch_fh "PASS net=$net_name point=$point via_def=$via_def object=[get_object_name $new_via]"
      incr created_count
      set created_here 1
      break
    }

    if {!$created_here} {
      puts $stitch_fh "ERROR no M1-M2 stitch via created for net=$net_name point=$point"
      close $stitch_fh
      error "Failed to create PG rail stitch for $net_name at $point"
    }
  }

  puts $stitch_fh "SUMMARY removed_conflicting_vias=$removed_count created_stitch_vias=$created_count"
  close $stitch_fh
  puts "PG_RAIL_STITCHES report=$stitch_report removed_conflicting_vias=$removed_count created_stitch_vias=$created_count"
}

set OLD_PG_VIAS [get_vias -quiet -of_objects $PG_NETS]
if {[sizeof_collection $OLD_PG_VIAS] > 0} {
  remove_objects -force $OLD_PG_VIAS
}

set OLD_PG_SHAPES [get_shapes -quiet -of_objects $PG_NETS]
if {[sizeof_collection $OLD_PG_SHAPES] > 0} {
  remove_objects -force $OLD_PG_SHAPES
}

catch {remove_pg_strategy_via_rules -all}
catch {remove_pg_strategies -all}
catch {remove_pg_patterns -all}

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
set VDDG_PINS [get_pins -hierarchical -quiet */VDDG]
if {[sizeof_collection $VDDG_PINS] > 0} {
  connect_pg_net -net VDD $VDDG_PINS
}
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

create_pg_std_cell_conn_pattern stdcell_rail_pattern \
  -layers {M1}

set_pg_strategy stdcell_rail_strategy \
  -core \
  -pattern {{name: stdcell_rail_pattern}{nets: {VDD VSS}}}

create_pg_ring_pattern core_ring_pattern \
  -horizontal_layer M7 \
  -vertical_layer M8 \
  -horizontal_width 2.0 \
  -vertical_width 2.0 \
  -horizontal_spacing 1.0 \
  -vertical_spacing 1.0 \
  -corner_bridge true

set_pg_strategy core_ring_strategy \
  -core \
  -pattern {{name: core_ring_pattern}{nets: {VDD VSS}}{offset: {5 5}}} \
  -extension {{stop: design_boundary_and_generate_pin}}

set PG_M2_WIDTH 0.4
set PG_M2_PITCH 40.0
set PG_M2_OFFSET 20.0
set PG_M7_OFFSET 28.0

if {[info exists ::env(PG_M2_WIDTH)] && $::env(PG_M2_WIDTH) ne ""} {
  set PG_M2_WIDTH $::env(PG_M2_WIDTH)
}
if {[info exists ::env(PG_M2_PITCH)] && $::env(PG_M2_PITCH) ne ""} {
  set PG_M2_PITCH $::env(PG_M2_PITCH)
}
if {[info exists ::env(PG_M2_OFFSET)] && $::env(PG_M2_OFFSET) ne ""} {
  set PG_M2_OFFSET $::env(PG_M2_OFFSET)
}
if {[info exists ::env(PG_M7_OFFSET)] && $::env(PG_M7_OFFSET) ne ""} {
  set PG_M7_OFFSET $::env(PG_M7_OFFSET)
}

puts "PG_MESH_CONFIG m2_width=$PG_M2_WIDTH m2_pitch=$PG_M2_PITCH m2_offset=$PG_M2_OFFSET m7_offset=$PG_M7_OFFSET"

set PG_MESH_LAYERS [subst {
  {{vertical_layer: M2}{width: $PG_M2_WIDTH}{spacing: interleaving}{pitch: $PG_M2_PITCH}{offset: $PG_M2_OFFSET}}
  {{vertical_layer: M8}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}}
  {{horizontal_layer: M7}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: $PG_M7_OFFSET}}
}]

create_pg_mesh_pattern core_mesh_pattern \
  -layers $PG_MESH_LAYERS

set_pg_strategy core_mesh_strategy \
  -core \
  -pattern {{name: core_mesh_pattern}{nets: {VDD VSS}}} \
  -extension {{stop: innermost_ring}}

set_pg_strategy_via_rule pg_via_all \
  -via_rule {{intersection: all}{via_master: default}} \
  -tag pg_initial_via

compile_pg \
  -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
  -via_rule pg_via_all

add_pg_rail_stitches $POWERPLAN_REPORT_DIR

set VDD_PORTS [get_ports -quiet VDD]
if {[sizeof_collection $VDD_PORTS] > 0} {
  set VDD_TERMS [get_terminals -quiet -of_objects $VDD_PORTS]
  if {[sizeof_collection $VDD_TERMS] == 0} {
    create_terminal \
      -port $VDD_PORTS \
      -boundary {{13.0000 3.0000} {15.0000 5.0000}} \
      -layer M8 \
      -direction all \
      -name VDD_top_terminal
  }
}

set VSS_PORTS [get_ports -quiet VSS]
if {[sizeof_collection $VSS_PORTS] > 0} {
  set VSS_TERMS [get_terminals -quiet -of_objects $VSS_PORTS]
  if {[sizeof_collection $VSS_TERMS] == 0} {
    create_terminal \
      -port $VSS_PORTS \
      -boundary {{10.0000 3.0000} {12.0000 5.0000}} \
      -layer M8 \
      -direction all \
      -name VSS_top_terminal
  }
}

report_pg_patterns > $POWERPLAN_REPORT_DIR/pg_patterns.rpt
report_pg_strategies > $POWERPLAN_REPORT_DIR/pg_strategies.rpt
report_pg_strategy_via_rules > $POWERPLAN_REPORT_DIR/pg_strategy_via_rules.rpt
report_ports [get_ports -quiet {VDD VSS VDD_1 VSS_1}] > $POWERPLAN_REPORT_DIR/pg_ports.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $POWERPLAN_REPORT_DIR/pg_connectivity_detail.rpt \
  > $POWERPLAN_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $POWERPLAN_REPORT_DIR/pg_drc.rpt

report_design -physical > $POWERPLAN_REPORT_DIR/design_physical.rpt
report_utilization > $POWERPLAN_REPORT_DIR/utilization.rpt
report_qor > $POWERPLAN_REPORT_DIR/qor.rpt

save_block
save_lib

exit
