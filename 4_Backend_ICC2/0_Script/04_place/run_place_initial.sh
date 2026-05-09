#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 4_Backend_ICC2/3_Log/04_place

icc2_shell -f 4_Backend_ICC2/0_Script/04_place/run_place_initial.tcl \
  | tee 4_Backend_ICC2/3_Log/04_place/run_place_initial.log

