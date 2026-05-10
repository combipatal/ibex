#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 2_Synthesis/3_Log/99_debug

tag="${NOR2_POLICY_RUN_TAG:-pre_backend_topo_nor2_no_x0x2_hvt}"
log_path="${NOR2_POLICY_LOG:-2_Synthesis/3_Log/99_debug/run_dc_compile_topo_nor2_policy.${tag}.log}"

dc_shell -topographical_mode -f 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.tcl \
  | tee "$log_path"
