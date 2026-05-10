#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

debug_root="${MOD_LEF_ROUTE_DEBUG_ROOT:-4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow}"
debug_report_root="${MOD_LEF_ROUTE_REPORT_ROOT:-4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow}"
debug_log_root="${MOD_LEF_ROUTE_LOG_ROOT:-4_Backend_ICC2/3_Log/99_debug/modified_lef_route_flow}"
debug_lib_dir="${MOD_LEF_ROUTE_LIB_DIR:-$debug_root/ibex_mini_soc_top_modified_lef_route_icc2_lib}"
debug_ndm_dir="${MOD_LEF_ROUTE_NDM_DIR:-4_Backend_ICC2/2_Output/99_debug/modified_lef_pg_probe/ndm}"
ndm_suffix="${MOD_LEF_ROUTE_NDM_SUFFIX:-modified_lef}"
route_tech_file="${MOD_LEF_ROUTE_TECH_FILE:-}"

mod_ndm_rvt="$debug_ndm_dir/saed32rvt_tt.${ndm_suffix}.ndm"
mod_ndm_lvt="$debug_ndm_dir/saed32lvt_tt.${ndm_suffix}.ndm"
mod_ndm_hvt="$debug_ndm_dir/saed32hvt_tt.${ndm_suffix}.ndm"

mkdir -p "$debug_root" "$debug_report_root" "$debug_log_root"

for required in "$mod_ndm_rvt" "$mod_ndm_lvt" "$mod_ndm_hvt"; do
  if [[ ! -e "$required" ]]; then
    echo "ERROR: missing modified LEF NDM: $required" >&2
    echo "Run 4_Backend_ICC2/0_Script/99_debug/build_modified_lef_ndm.sh first." >&2
    exit 2
  fi
done

run_stage() {
  local stage="$1"
  local script="$2"
  local log="$debug_log_root/${stage}.log"

  echo "MOD_LEF_ROUTE_FLOW stage=$stage script=$script log=$log"

  env \
    NDM_RVT="$mod_ndm_rvt" \
    NDM_LVT="$mod_ndm_lvt" \
    NDM_HVT="$mod_ndm_hvt" \
    TECH_FILE="$route_tech_file" \
    ICC2_LIB_DIR="$debug_lib_dir" \
    ICC2_REPORT_ROOT="$debug_report_root" \
    icc2_shell -f "$script" -output_log_file "$log"

  if rg -n "^(Error:|.*stopped at line .* due to error)" "$log"; then
    echo "ERROR: ICC2 stage failed: $stage" >&2
    exit 1
  fi
}

run_stage 01_init_design 4_Backend_ICC2/0_Script/01_init_design/run_init_design_check.tcl
run_stage 02_floorplan 4_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.tcl
run_stage 03_powerplan 4_Backend_ICC2/0_Script/03_powerplan/run_powerplan_initial.tcl
run_stage 04_place 4_Backend_ICC2/0_Script/04_place/run_place_initial.tcl
run_stage 05_cts 4_Backend_ICC2/0_Script/05_cts/run_cts_initial.tcl
run_stage 06_route 4_Backend_ICC2/0_Script/06_route/run_route_initial.tcl

echo "MOD_LEF_ROUTE_FLOW DONE"
echo "MOD_LEF_ROUTE_FLOW report_root=$debug_report_root"
