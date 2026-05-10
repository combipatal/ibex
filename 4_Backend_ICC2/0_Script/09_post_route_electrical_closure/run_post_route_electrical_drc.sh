#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

export SRC_ICC2_LIB="${SRC_ICC2_LIB:-4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib}"
export ELEC_CLOSURE_LIB="${ELEC_CLOSURE_LIB:-4_Backend_ICC2/2_Output/09_post_route_electrical_closure/ibex_mini_soc_top_post_route_electrical_drc_icc2_lib}"
export ELEC_CLOSURE_REPORT_DIR="${ELEC_CLOSURE_REPORT_DIR:-4_Backend_ICC2/4_Report/09_post_route_electrical_closure}"
export ELEC_CLOSURE_LOG_DIR="${ELEC_CLOSURE_LOG_DIR:-4_Backend_ICC2/3_Log/09_post_route_electrical_closure}"

if [ ! -d "$SRC_ICC2_LIB" ]; then
  echo "Missing source ICC2 library: $SRC_ICC2_LIB" >&2
  exit 1
fi

rm -rf "$ELEC_CLOSURE_LIB"
mkdir -p "$(dirname "$ELEC_CLOSURE_LIB")" "$ELEC_CLOSURE_REPORT_DIR" "$ELEC_CLOSURE_LOG_DIR"
cp -a "$SRC_ICC2_LIB" "$ELEC_CLOSURE_LIB"

icc2_shell \
  -f 4_Backend_ICC2/0_Script/09_post_route_electrical_closure/run_post_route_electrical_drc.tcl \
  -output_log_file "$ELEC_CLOSURE_LOG_DIR/run_post_route_electrical_drc.log"
