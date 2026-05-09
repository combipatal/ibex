#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 4_Backend_ICC2/3_Log/06_route

icc2_shell -f 4_Backend_ICC2/0_Script/06_route/run_route_initial.tcl \
  | tee 4_Backend_ICC2/3_Log/06_route/run_route_initial.log

