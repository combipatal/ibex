#!/usr/bin/env bash
set -euo pipefail

log_path="${VIA_DEF_INSPECT_LOG:-4_Backend_ICC2/3_Log/99_debug/inspect_via_defs.log}"
mkdir -p "$(dirname "$log_path")"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/inspect_via_defs.tcl \
  -output_log_file "$log_path"
