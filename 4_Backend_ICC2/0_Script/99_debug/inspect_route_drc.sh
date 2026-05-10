#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 4_Backend_ICC2/3_Log/99_debug

log_path="${ROUTE_DRC_INSPECT_LOG:-4_Backend_ICC2/3_Log/99_debug/inspect_route_drc.log}"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.tcl \
  | tee "$log_path"
