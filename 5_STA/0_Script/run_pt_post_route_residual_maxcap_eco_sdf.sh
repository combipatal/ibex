#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

run_tag="${PT_RUN_TAG:-post_route_residual_maxcap_eco}"

mkdir -p 5_STA/3_Log "5_STA/4_Report/${run_tag}"

pt_shell \
  -f 5_STA/0_Script/run_pt_post_route_residual_maxcap_eco_sdf.tcl \
  -output_log_file "5_STA/3_Log/pt_${run_tag}_sdf.log"
