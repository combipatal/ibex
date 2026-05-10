#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

src_lib="${MOD_LEF_CLEANUP_SRC_LIB:-4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib}"
dst_lib="${MOD_LEF_CLEANUP_LIB:-4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib}"
log_path="${MOD_LEF_CLEANUP_LOG:-4_Backend_ICC2/3_Log/99_debug/save_modified_lef_detail_cleanup.log}"
report_dir="${MOD_LEF_CLEANUP_REPORT_DIR:-4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved}"

if [ ! -d "$src_lib" ]; then
  echo "ERROR: source ICC2 lib not found: $src_lib" >&2
  exit 2
fi

if [ -e "$dst_lib" ]; then
  echo "ERROR: destination ICC2 lib already exists: $dst_lib" >&2
  exit 2
fi

mkdir -p "$(dirname "$dst_lib")" "$(dirname "$log_path")" "$report_dir"
cp -a "$src_lib" "$dst_lib"

export ICC2_LIB_DIR="$dst_lib"
export MOD_LEF_CLEANUP_REPORT_DIR="$report_dir"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.tcl \
  | tee "$log_path"
