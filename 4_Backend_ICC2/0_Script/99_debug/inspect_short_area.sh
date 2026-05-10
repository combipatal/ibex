#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 4_Backend_ICC2/3_Log/99_debug

log_path="${SHORT_INSPECT_LOG:-4_Backend_ICC2/3_Log/99_debug/inspect_short_area.log}"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/inspect_short_area.tcl \
  | tee "$log_path"
