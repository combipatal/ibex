#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 5_STA/3_Log 5_STA/4_Report/pre_backend_topo

pt_shell \
  -f 5_STA/0_Script/run_pt_pre_backend_topo_sdf.tcl \
  -output_log_file 5_STA/3_Log/pt_pre_backend_topo_sdf.log
