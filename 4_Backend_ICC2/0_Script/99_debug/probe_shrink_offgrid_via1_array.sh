#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

log_path="${SHRINK_VIA_PROBE_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_shrink_offgrid_via1_array.log}"
mkdir -p "$(dirname "$log_path")"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_shrink_offgrid_via1_array.tcl \
  | tee "$log_path"
