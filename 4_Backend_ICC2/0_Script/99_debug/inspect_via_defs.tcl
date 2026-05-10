################################################################################
# Debug-only via definition inspector.
#
# Opens an ICC2 routed block, lists available via definitions and samples routed
# VIA1 objects. This script is read-only: it does not save the block or library.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(VIA_DEF_INSPECT_DIR)] && $::env(VIA_DEF_INSPECT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(VIA_DEF_INSPECT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/via_def_inspect
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

proc write_line {fh text} {
  puts $fh $text
}

puts "VIA_DEF_INSPECT lib=$ICC2_LIB_DIR"
puts "VIA_DEF_INSPECT report_dir=$DEBUG_REPORT_DIR"

open_lib $ICC2_LIB_DIR
open_block $TOP_NAME

redirect -file $DEBUG_REPORT_DIR/via_def_attributes.rpt {
  catch {list_attributes -application -class via_def -nosplit}
  catch {list_attributes -application -class via -nosplit}
}

set fh [open $DEBUG_REPORT_DIR/via_defs.tsv w]
write_line $fh "query\tcount\tname\tfull_name\tlower_layer\tupper_layer\tcut_layers\tdefault\tsource_type\tvia_def_type\tmin_rows\tmin_columns\tcut_width\tcut_height\tmin_cut_spacing\txy_min_cut_spacing\tlower_enc_w\tlower_enc_h\tupper_enc_w\tupper_enc_h"

set via_queries {
  VIA12SQ_C
  VIA12SQ
  VIA12_C
  VIA12
  VIA12SQ_C_2x1
  VIA12SQ_C_1x2
  {VIA12SQ_C(rot)_2x1}
  VIA12SQ_2x1
  VIA12SQ_1x2
  {VIA12SQ(rot)_2x1}
}

foreach via_query $via_queries {
  if {[catch {set queried_defs [get_via_defs -quiet $via_query]} query_error]} {
    write_line $fh "$via_query\tERROR:$query_error\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"
    continue
  }

  set count [safe_size $queried_defs]
  if {$count == 0} {
    write_line $fh "$via_query\t0\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"
    continue
  }

  foreach_in_collection via_def $queried_defs {
    set name [get_object_name $via_def]
    set full_name [attr_or_na $via_def full_name]
    set lower [attr_or_na $via_def lower_layer_name]
    set upper [attr_or_na $via_def upper_layer_name]
    set cut_layers [attr_or_na $via_def cut_layer_names]
    set is_default [attr_or_na $via_def is_default]
    set source_type [attr_or_na $via_def source_type]
    set via_def_type [attr_or_na $via_def via_def_type]
    set min_rows [attr_or_na $via_def min_rows]
    set min_columns [attr_or_na $via_def min_columns]
    set cut_width [attr_or_na $via_def cut_width]
    set cut_height [attr_or_na $via_def cut_height]
    set min_cut_spacing [attr_or_na $via_def min_cut_spacing]
    set xy_min_cut_spacing [attr_or_na $via_def xy_min_cut_spacing]
    set lower_enc_w [attr_or_na $via_def lower_enclosure_width]
    set lower_enc_h [attr_or_na $via_def lower_enclosure_height]
    set upper_enc_w [attr_or_na $via_def upper_enclosure_width]
    set upper_enc_h [attr_or_na $via_def upper_enclosure_height]

    write_line $fh "$via_query\t$count\t$name\t$full_name\t$lower\t$upper\t$cut_layers\t$is_default\t$source_type\t$via_def_type\t$min_rows\t$min_columns\t$cut_width\t$cut_height\t$min_cut_spacing\t$xy_min_cut_spacing\t$lower_enc_w\t$lower_enc_h\t$upper_enc_w\t$upper_enc_h"
  }
}
close $fh

redirect -file $DEBUG_REPORT_DIR/check_routes.rpt {
  check_routes
}

set error_data [get_drc_error_data -all -quiet zroute.err]
if {[safe_size $error_data] > 0} {
  set opened_data [open_drc_error_data $error_data]
  if {[safe_size $opened_data] > 0} {
    set error_data $opened_data
  }
}

set offgrid_via_fh [open $DEBUG_REPORT_DIR/offgrid_vias.tsv w]
write_line $offgrid_via_fh "idx\terror\tvia\tvia_def\tlower\tupper\torigin\tbbox\tarray_size\trows\tcols\tshape_use\tnet"

if {[safe_size $error_data] > 0} {
  set error_type [get_drc_error_types -quiet -error_data $error_data {Off-grid}]
  set errors [get_drc_errors -quiet -error_data $error_data -of_objects $error_type]
  set idx 0
  foreach_in_collection err $errors {
    incr idx
    set err_name [get_object_name $err]
    set objects [attr_or_na $err objects]
    if {$objects eq "NA"} {
      continue
    }

    foreach_in_collection obj $objects {
      if {[attr_or_na $obj object_class] ne "net"} {
        continue
      }

      set net_name [get_object_name $obj]
      set vias [get_vias -quiet -of_objects $obj]
      foreach_in_collection via $vias {
        set lower [attr_or_na $via lower_layer_name]
        set upper [attr_or_na $via upper_layer_name]
        if {$lower ne "M1" || $upper ne "M2"} {
          continue
        }

        set via_name [get_object_name $via]
        set via_def [attr_or_na $via via_def_name]
        set origin [attr_or_na $via origin]
        set bbox [attr_or_na $via bbox]
        set array_size [attr_or_na $via array_size]
        set rows [attr_or_na $via number_of_rows]
        set cols [attr_or_na $via number_of_columns]
        set shape_use [attr_or_na $via shape_use]
        write_line $offgrid_via_fh "$idx\t$err_name\t$via_name\t$via_def\t$lower\t$upper\t$origin\t$bbox\t$array_size\t$rows\t$cols\t$shape_use\t$net_name"
      }
    }
  }
}

close $offgrid_via_fh

puts "VIA_DEF_INSPECT DONE"
puts "VIA_DEF_INSPECT NOTE=no save_block/save_lib executed"

exit
