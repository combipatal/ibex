#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

drc_type="${DRC_CONTEXT_TYPE:-Diff net spacing}"
safe_type="${drc_type// /_}"
safe_type="${safe_type//\//_}"

mkdir -p 4_Backend_ICC2/3_Log/99_debug

log_path="${DRC_CONTEXT_LOG:-4_Backend_ICC2/3_Log/99_debug/inspect_drc_context.${safe_type}.log}"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/inspect_drc_context.tcl \
  | tee "$log_path"
