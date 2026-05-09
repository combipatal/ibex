#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 4_Backend_ICC2/3_Log/05_cts

icc2_shell -f 4_Backend_ICC2/0_Script/05_cts/run_cts_initial.tcl \
  | tee 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log
