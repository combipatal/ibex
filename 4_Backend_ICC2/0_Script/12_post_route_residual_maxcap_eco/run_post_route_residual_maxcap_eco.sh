#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

export SRC_ICC2_LIB="${SRC_ICC2_LIB:-4_Backend_ICC2/2_Output/11_post_route_final_cleanup/ibex_mini_soc_top_post_route_final_cleanup_icc2_lib}"
export SRC_BLOCK="${SRC_BLOCK:-ibex_mini_soc_top_post_route_final_cleanup}"
export RESIDUAL_MAXCAP_LIB="${RESIDUAL_MAXCAP_LIB:-4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/ibex_mini_soc_top_post_route_residual_maxcap_eco_icc2_lib}"
export RESIDUAL_MAXCAP_REPORT_DIR="${RESIDUAL_MAXCAP_REPORT_DIR:-4_Backend_ICC2/4_Report/12_post_route_residual_maxcap_eco}"
export RESIDUAL_MAXCAP_LOG_DIR="${RESIDUAL_MAXCAP_LOG_DIR:-4_Backend_ICC2/3_Log/12_post_route_residual_maxcap_eco}"
export RESIDUAL_MAXCAP_OUTPUT_DIR="${RESIDUAL_MAXCAP_OUTPUT_DIR:-4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export}"

if [ ! -d "$SRC_ICC2_LIB" ]; then
  echo "Missing source ICC2 library: $SRC_ICC2_LIB" >&2
  exit 1
fi

rm -rf "$RESIDUAL_MAXCAP_LIB"
mkdir -p "$(dirname "$RESIDUAL_MAXCAP_LIB")" "$RESIDUAL_MAXCAP_REPORT_DIR" "$RESIDUAL_MAXCAP_LOG_DIR" "$RESIDUAL_MAXCAP_OUTPUT_DIR"
cp -a "$SRC_ICC2_LIB" "$RESIDUAL_MAXCAP_LIB"

icc2_shell \
  -f 4_Backend_ICC2/0_Script/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.tcl \
  -output_log_file "$RESIDUAL_MAXCAP_LOG_DIR/run_post_route_residual_maxcap_eco.log"
