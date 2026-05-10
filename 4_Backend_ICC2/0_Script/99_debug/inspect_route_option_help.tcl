################################################################################
# Debug-only route option discovery.
#
# Queries ICC2 route app options related to via/contact/fat-metal handling.
# This script does not open or save a design block.
################################################################################

set REPORT_DIR /DATA/home/edu135/ibex/4_Backend_ICC2/4_Report/99_debug/route_option_help
file mkdir $REPORT_DIR

proc capture_help {pattern file_name} {
  redirect -file $file_name {
    puts "### help_app_options $pattern"
    catch {help_app_options $pattern}
    puts ""
    puts "### report_app_options $pattern"
    catch {report_app_options $pattern}
  }
}

capture_help {route.common.*via*} $REPORT_DIR/route_common_via.rpt
capture_help {route.detail.*via*} $REPORT_DIR/route_detail_via.rpt
capture_help {route.auto_via_ladder.*} $REPORT_DIR/route_auto_via_ladder.rpt
capture_help {route.common.*fat*} $REPORT_DIR/route_common_fat.rpt
capture_help {route.detail.*fat*} $REPORT_DIR/route_detail_fat.rpt
capture_help {route.*contact*} $REPORT_DIR/route_contact.rpt

puts "ROUTE_OPTION_HELP DONE report_dir=$REPORT_DIR"
exit
