################################################################################
# Debug-only route DRC inspector.
#
# Opens the current routed block, reruns check_routes to populate ICC2 DRC error
# data, and writes matrix/detail reports. This script does not save the block or
# library.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {[info exists ::env(ROUTE_DRC_INSPECT_DIR)] && $::env(ROUTE_DRC_INSPECT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(ROUTE_DRC_INSPECT_DIR)
} else {
  set DEBUG_REPORT_DIR $ICC2_ROOT/4_Report/99_debug/route_drc_inspect
}
file mkdir $DEBUG_REPORT_DIR

proc write_line {fh text} {
  puts $fh $text
}

proc attr_or_na {object attr_name} {
  if {[catch {set value [get_attribute $object $attr_name]}]} {
    return "NA"
  }
  return $value
}

proc collection_names {objects} {
  if {[catch {set names [get_object_name $objects]}]} {
    return "NA"
  }
  return $names
}

proc safe_size {objects} {
  if {[catch {set count [sizeof_collection $objects]}]} {
    return 0
  }
  return $count
}

proc report_type_samples {error_data report_dir type_name limit} {
  set safe_name [string map {" " "_" "/" "_" "\\" "_" ":" "_"} $type_name]
  set type_file "$report_dir/sample_${safe_name}.rpt"
  set tsv_file "$report_dir/sample_${safe_name}.tsv"

  set error_type [get_drc_error_types -quiet -error_data $error_data [list $type_name]]
  set errors [get_drc_errors -quiet -error_data $error_data -of_objects $error_type]

  redirect -file $type_file {
    report_drc_error \
      -error_data $error_data \
      -error_type $error_type \
      -report_type detailed \
      -nosplit
  }

  set fh [open $tsv_file w]
  write_line $fh "idx\tname\ttype_name\tlayer_name\tbbox\tobjects\tdescription"

  set idx 0
  foreach_in_collection err $errors {
    incr idx
    if {$idx > $limit} {
      break
    }

    set name [collection_names $err]
    set err_type [attr_or_na $err type_name]
    set layer [attr_or_na $err layer_name]
    set bbox [attr_or_na $err bbox]
    set objects [attr_or_na $err objects]
    set description [attr_or_na $err description]
    write_line $fh "$idx\t$name\t$err_type\t$layer\t$bbox\t$objects\t$description"
  }

  close $fh
}

puts "ROUTE_DRC_INSPECT LIB=$ICC2_LIB_DIR"
puts "ROUTE_DRC_INSPECT REPORT_DIR=$DEBUG_REPORT_DIR"

open_lib $ICC2_LIB_DIR
open_block $TOP_NAME

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

if {[safe_size $error_data] == 0} {
  puts stderr "ERROR: no DRC error data exists after check_routes"
  exit 2
}

redirect -file $DEBUG_REPORT_DIR/drc_error_data.list {
  query_objects $error_data
}

redirect -file $DEBUG_REPORT_DIR/drc_error_attributes.rpt {
  catch {list_attributes -application -class drc_error -nosplit}
  catch {list_attributes -application -class drc_error_type -nosplit}
  catch {list_attributes -application -class drc_error_data -nosplit}
}

redirect -file $DEBUG_REPORT_DIR/drc_matrix.rpt {
  report_drc_error -error_data $error_data -report_type matrix -nosplit
}

redirect -file $DEBUG_REPORT_DIR/drc_by_type.rpt {
  report_drc_error -error_data $error_data -report_type error_type -nosplit
}

redirect -file $DEBUG_REPORT_DIR/drc_by_layer.rpt {
  report_drc_error -error_data $error_data -report_type error_layer -nosplit
}

set sample_limit 25
foreach type_name {
  {Needs fat contact}
  {Diff net spacing}
  {Off-grid}
  {Less than minimum area}
  {Short}
} {
  if {[catch {report_type_samples $error_data $DEBUG_REPORT_DIR $type_name $sample_limit} err]} {
    set safe_name [string map {" " "_" "/" "_" "\\" "_" ":" "_"} $type_name]
    set fh [open "$DEBUG_REPORT_DIR/sample_${safe_name}.error" w]
    write_line $fh $err
    close $fh
  }
}

puts "ROUTE_DRC_INSPECT DONE"
puts "ROUTE_DRC_INSPECT NOTE=no save_block/save_lib executed"

exit
