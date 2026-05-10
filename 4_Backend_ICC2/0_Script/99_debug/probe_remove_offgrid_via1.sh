#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

log_path="${OFFGRID_PROBE_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_remove_offgrid_via1.log}"
mkdir -p "$(dirname "$log_path")"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_remove_offgrid_via1.tcl \
  | tee "$log_path"
