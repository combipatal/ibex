#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 3_Formality/3_Log 3_Formality/4_Report/pre_backend_topo 3_Formality/2_Output/pre_backend_topo

fm_shell \
  -overwrite \
  -file 3_Formality/0_Script/run_fm_r2n_topo.tcl \
  | tee 3_Formality/3_Log/fm_r2n_topo.log
