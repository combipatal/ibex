#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 4_Backend_ICC2/3_Log/99_debug

log_path="${OFFGRID_ECO_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_remove_offgrid_via1_route_eco.log}"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_remove_offgrid_via1_route_eco.tcl \
  | tee "$log_path"
