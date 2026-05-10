#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

export SRC_ICC2_LIB="${SRC_ICC2_LIB:-4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/ibex_mini_soc_top_post_route_residual_maxcap_eco_icc2_lib}"
export SRC_BLOCK="${SRC_BLOCK:-ibex_mini_soc_top_post_route_residual_maxcap_eco}"
export MARGIN_LIB="${MARGIN_LIB:-4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/ibex_mini_soc_top_post_route_prefiller_maxcap_margin_icc2_lib}"
export MARGIN_REPORT_DIR="${MARGIN_REPORT_DIR:-4_Backend_ICC2/4_Report/14_post_route_prefiller_maxcap_margin}"
export MARGIN_LOG_DIR="${MARGIN_LOG_DIR:-4_Backend_ICC2/3_Log/14_post_route_prefiller_maxcap_margin}"
export MARGIN_OUTPUT_DIR="${MARGIN_OUTPUT_DIR:-4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/export}"

if [ ! -d "$SRC_ICC2_LIB" ]; then
  echo "Missing source ICC2 library: $SRC_ICC2_LIB" >&2
  exit 1
fi

rm -rf "$MARGIN_LIB"
mkdir -p "$(dirname "$MARGIN_LIB")" "$MARGIN_REPORT_DIR" "$MARGIN_LOG_DIR" "$MARGIN_OUTPUT_DIR"
cp -a "$SRC_ICC2_LIB" "$MARGIN_LIB"

icc2_shell \
  -f 4_Backend_ICC2/0_Script/14_post_route_prefiller_maxcap_margin/run_post_route_prefiller_maxcap_margin.tcl \
  -output_log_file "$MARGIN_LOG_DIR/run_post_route_prefiller_maxcap_margin.log"
