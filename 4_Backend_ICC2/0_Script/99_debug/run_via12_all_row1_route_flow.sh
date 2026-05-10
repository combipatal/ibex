#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

variant_root="4_Backend_ICC2/2_Output/99_debug/modified_lef_via12_all_row1_route_flow"
report_root="4_Backend_ICC2/4_Report/99_debug/modified_lef_via12_all_row1_route_flow"
log_root="4_Backend_ICC2/3_Log/99_debug/modified_lef_via12_all_row1_route_flow"
lib_dir="$variant_root/ibex_mini_soc_top_modified_lef_via12_all_row1_route_icc2_lib"
ndm_dir="4_Backend_ICC2/2_Output/99_debug/modified_lef_via12_all_row1/ndm"
ndm_suffix="modified_lef_via12_all_row1"
tech_file="4_Backend_ICC2/2_Output/99_debug/modified_lef_via12_all_row1/tech/saed32nm_1p9m_mw.via12_all_row1.tf"

env \
  MOD_LEF_ROUTE_DEBUG_ROOT="$variant_root" \
  MOD_LEF_ROUTE_REPORT_ROOT="$report_root" \
  MOD_LEF_ROUTE_LOG_ROOT="$log_root" \
  MOD_LEF_ROUTE_LIB_DIR="$lib_dir" \
  MOD_LEF_ROUTE_NDM_DIR="$ndm_dir" \
  MOD_LEF_ROUTE_NDM_SUFFIX="$ndm_suffix" \
  MOD_LEF_ROUTE_TECH_FILE="$tech_file" \
  4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
