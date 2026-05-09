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

create_pg_mesh_pattern core_mesh_pattern \
  -layers { \
    {{vertical_layer: M2}{width: 0.4}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}} \
    {{vertical_layer: M8}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}} \
    {{horizontal_layer: M7}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 28.0}} \
  }

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
