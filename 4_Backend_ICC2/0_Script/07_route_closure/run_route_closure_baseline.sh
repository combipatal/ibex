#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

run_tag="pre_backend_topo_nor2_mux41_no_x0x2_hvt"
ndm_dir="4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/ndm"
ndm_suffix="modified_lef_via1_pitch_no_track"
tech_file="4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf"

closure_root="4_Backend_ICC2/2_Output/07_route_closure"
report_root="4_Backend_ICC2/4_Report/07_route_closure"
log_root="4_Backend_ICC2/3_Log/07_route_closure"
lib_dir="$closure_root/ibex_mini_soc_top_route_closure_icc2_lib"

env \
  BACKEND_NETLIST="2_Synthesis/2_Output/${run_tag}/ibex_mini_soc_top.${run_tag}.vg" \
  BACKEND_SDC="2_Synthesis/2_Output/${run_tag}/ibex_mini_soc_top.${run_tag}.sdc" \
  MOD_LEF_ROUTE_DEBUG_ROOT="$closure_root" \
  MOD_LEF_ROUTE_REPORT_ROOT="$report_root" \
  MOD_LEF_ROUTE_LOG_ROOT="$log_root" \
  MOD_LEF_ROUTE_LIB_DIR="$lib_dir" \
  MOD_LEF_ROUTE_NDM_DIR="$ndm_dir" \
  MOD_LEF_ROUTE_NDM_SUFFIX="$ndm_suffix" \
  MOD_LEF_ROUTE_TECH_FILE="$tech_file" \
  4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
