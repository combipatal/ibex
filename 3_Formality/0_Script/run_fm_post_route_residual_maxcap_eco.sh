#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

run_tag="${FM_RUN_TAG:-post_route_residual_maxcap_eco}"
log_path="${FM_LOG:-3_Formality/3_Log/fm_${run_tag}.log}"

mkdir -p 3_Formality/3_Log "3_Formality/4_Report/${run_tag}" "3_Formality/2_Output/${run_tag}"

fm_shell \
  -overwrite \
  -file 3_Formality/0_Script/run_fm_post_route_residual_maxcap_eco.tcl \
  | tee "$log_path"
