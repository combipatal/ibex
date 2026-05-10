################################################################################
# Debug-only PG floating-shape inspector.
#
# Opens a copied/debug ICC2 library and tries to report attributes for PG shape
# IDs listed by check_pg_connectivity, such as PATH_11_184. This script does not
# save the block or library.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {![info exists ::env(DEBUG_ICC2_LIB_DIR)]} {
  set DEBUG_ICC2_LIB_DIR $ICC2_ROOT/2_Output/debug_pg/${TOP_NAME}_icc2_lib_pg_debug
} else {
  set DEBUG_ICC2_LIB_DIR $::env(DEBUG_ICC2_LIB_DIR)
}

set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/pg_floating_shape_inspect
file mkdir $DEBUG_REPORT_DIR

if {![file exists $DEBUG_ICC2_LIB_DIR]} {
  puts stderr "ERROR: DEBUG_ICC2_LIB_DIR does not exist: $DEBUG_ICC2_LIB_DIR"
  exit 2
}

set SHAPE_IDS {PATH_11_184 PATH_11_208 PATH_11_232 PATH_11_256 PATH_11_280 PATH_11_304 PATH_11_328 PATH_11_483}
if {[info exists ::env(PG_FLOATING_SHAPES)] && $::env(PG_FLOATING_SHAPES) ne ""} {
  set SHAPE_IDS $::env(PG_FLOATING_SHAPES)
}

proc attr_or_na {obj attr} {
  if {[catch {set value [get_attribute $obj $attr]}]} {
    return "NA"
  }
  return $value
}

proc try_get_shape {shape_id} {
  set shape_obj [get_shapes -quiet $shape_id]
  if {[sizeof_collection $shape_obj] > 0} {
    return $shape_obj
  }

  foreach filter_expr [list \
    "name==$shape_id" \
    "full_name==$shape_id" \
    "object_name==$shape_id" \
  ] {
    if {![catch {set shape_obj [get_shapes -quiet -filter $filter_expr]}]} {
      if {[sizeof_collection $shape_obj] > 0} {
        return $shape_obj
      }
    }
  }

  return $shape_obj
}

puts "PG_FLOATING_SHAPE_INSPECT DEBUG_LIB=$DEBUG_ICC2_LIB_DIR"
puts "PG_FLOATING_SHAPE_INSPECT SHAPES=$SHAPE_IDS"

open_lib $DEBUG_ICC2_LIB_DIR
open_block $TOP_NAME

set summary_file $DEBUG_REPORT_DIR/shape_summary.tsv
set fh [open $summary_file w]
puts $fh "shape_id\tfound\tobject_name\tfull_name\tlayer\tmask_constraint\tshape_use\tnet_name\tbbox\towner"

foreach shape_id $SHAPE_IDS {
  set shape_obj [try_get_shape $shape_id]
  if {[sizeof_collection $shape_obj] == 0} {
    puts $fh "$shape_id\t0\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"
    puts "PG_FLOATING_SHAPE_INSPECT MISSING shape=$shape_id"
    continue
  }

  set object_name [attr_or_na $shape_obj object_name]
  set full_name [attr_or_na $shape_obj full_name]
  set layer [attr_or_na $shape_obj layer_name]
  set mask_constraint [attr_or_na $shape_obj mask_constraint]
  set shape_use [attr_or_na $shape_obj shape_use]
  set net_name [attr_or_na $shape_obj net_name]
  set bbox [attr_or_na $shape_obj bbox]
  set owner [attr_or_na $shape_obj owner]

  puts $fh "$shape_id\t1\t$object_name\t$full_name\t$layer\t$mask_constraint\t$shape_use\t$net_name\t$bbox\t$owner"
  puts "PG_FLOATING_SHAPE_INSPECT FOUND shape=$shape_id layer=$layer net=$net_name bbox=$bbox"
}

close $fh

set counts_file $DEBUG_REPORT_DIR/pg_shape_counts.rpt
set counts_fh [open $counts_file w]
foreach net_name {VDD VSS} {
  set shapes [get_shapes -quiet -of_objects [get_nets -quiet $net_name]]
  puts $counts_fh "NET $net_name total_shapes [sizeof_collection $shapes]"
  foreach layer_name {M1 M2 M7 M8} {
    set layer_shapes [filter_collection $shapes "layer_name==$layer_name"]
    puts $counts_fh "NET $net_name layer $layer_name shapes [sizeof_collection $layer_shapes]"
  }
}
close $counts_fh

puts "PG_FLOATING_SHAPE_INSPECT SUMMARY=$summary_file"
puts "PG_FLOATING_SHAPE_INSPECT COUNTS=$counts_file"
puts "PG_FLOATING_SHAPE_INSPECT NOTE=no save_block/save_lib executed"

exit
