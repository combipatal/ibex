#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

log_path="${REPLACE_VIA_PROBE_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_replace_offgrid_via1_def.${REPLACE_VIA_DEF:-VIA12SQ_C_1x2}.log}"
mkdir -p "$(dirname "$log_path")"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_replace_offgrid_via1_def.tcl \
  | tee "$log_path"
