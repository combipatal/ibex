#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

LOG_DIR="4_Backend_ICC2/3_Log/99_debug"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/run_modified_lef_pg_probe.log"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_pg_probe.tcl \
  -output_log_file "$LOG_FILE"

if rg -n "^(Error:|.*stopped at line .* due to error)" "$LOG_FILE"; then
  exit 1
fi
