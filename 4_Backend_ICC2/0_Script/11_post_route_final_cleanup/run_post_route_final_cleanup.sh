#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

export SRC_ICC2_LIB="${SRC_ICC2_LIB:-4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/ibex_mini_soc_top_post_route_maxcap_eco_icc2_lib}"
export SRC_BLOCK="${SRC_BLOCK:-ibex_mini_soc_top_post_route_maxcap_eco}"
export FINAL_CLEANUP_LIB="${FINAL_CLEANUP_LIB:-4_Backend_ICC2/2_Output/11_post_route_final_cleanup/ibex_mini_soc_top_post_route_final_cleanup_icc2_lib}"
export FINAL_CLEANUP_REPORT_DIR="${FINAL_CLEANUP_REPORT_DIR:-4_Backend_ICC2/4_Report/11_post_route_final_cleanup}"
export FINAL_CLEANUP_LOG_DIR="${FINAL_CLEANUP_LOG_DIR:-4_Backend_ICC2/3_Log/11_post_route_final_cleanup}"
export FINAL_CLEANUP_OUTPUT_DIR="${FINAL_CLEANUP_OUTPUT_DIR:-4_Backend_ICC2/2_Output/11_post_route_final_cleanup/export}"

if [ ! -d "$SRC_ICC2_LIB" ]; then
  echo "Missing source ICC2 library: $SRC_ICC2_LIB" >&2
  exit 1
fi

rm -rf "$FINAL_CLEANUP_LIB"
mkdir -p "$(dirname "$FINAL_CLEANUP_LIB")" "$FINAL_CLEANUP_REPORT_DIR" "$FINAL_CLEANUP_LOG_DIR" "$FINAL_CLEANUP_OUTPUT_DIR"
cp -a "$SRC_ICC2_LIB" "$FINAL_CLEANUP_LIB"

icc2_shell \
  -f 4_Backend_ICC2/0_Script/11_post_route_final_cleanup/run_post_route_final_cleanup.tcl \
  -output_log_file "$FINAL_CLEANUP_LOG_DIR/run_post_route_final_cleanup.log"
