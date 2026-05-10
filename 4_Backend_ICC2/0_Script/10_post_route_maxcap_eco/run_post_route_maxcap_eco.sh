#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

export SRC_ICC2_LIB="${SRC_ICC2_LIB:-4_Backend_ICC2/2_Output/09_post_route_electrical_closure_iter4/ibex_mini_soc_top_post_route_electrical_drc_iter4_icc2_lib}"
export SRC_BLOCK="${SRC_BLOCK:-ibex_mini_soc_top_post_route_electrical_drc_iter4}"
export MAXCAP_ECO_LIB="${MAXCAP_ECO_LIB:-4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/ibex_mini_soc_top_post_route_maxcap_eco_icc2_lib}"
export MAXCAP_ECO_REPORT_DIR="${MAXCAP_ECO_REPORT_DIR:-4_Backend_ICC2/4_Report/10_post_route_maxcap_eco}"
export MAXCAP_ECO_LOG_DIR="${MAXCAP_ECO_LOG_DIR:-4_Backend_ICC2/3_Log/10_post_route_maxcap_eco}"
export MAXCAP_ECO_OUTPUT_DIR="${MAXCAP_ECO_OUTPUT_DIR:-4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/export}"

if [ ! -d "$SRC_ICC2_LIB" ]; then
  echo "Missing source ICC2 library: $SRC_ICC2_LIB" >&2
  exit 1
fi

rm -rf "$MAXCAP_ECO_LIB"
mkdir -p "$(dirname "$MAXCAP_ECO_LIB")" "$MAXCAP_ECO_REPORT_DIR" "$MAXCAP_ECO_LOG_DIR" "$MAXCAP_ECO_OUTPUT_DIR"
cp -a "$SRC_ICC2_LIB" "$MAXCAP_ECO_LIB"

icc2_shell \
  -f 4_Backend_ICC2/0_Script/10_post_route_maxcap_eco/run_post_route_maxcap_eco.tcl \
  -output_log_file "$MAXCAP_ECO_LOG_DIR/run_post_route_maxcap_eco.log"
