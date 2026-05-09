#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 4_Backend_ICC2/3_Log/01_init_design

icc2_shell -f 4_Backend_ICC2/0_Script/01_init_design/run_init_design_check.tcl \
  | tee 4_Backend_ICC2/3_Log/01_init_design/run_init_design_check.log

