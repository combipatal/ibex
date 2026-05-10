#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

LOG_DIR="4_Backend_ICC2/3_Log/99_debug"
mkdir -p "$LOG_DIR"

export DEBUG_ICC2_LIB_DIR="${DEBUG_ICC2_LIB_DIR:-$ROOT_DIR/4_Backend_ICC2/2_Output/debug_pg/ibex_mini_soc_top_icc2_lib_pg_debug}"

LOG_FILE="$LOG_DIR/run_pg_m2_sweep.log"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/run_pg_m2_sweep.tcl \
  -output_log_file "$LOG_FILE"

if rg -n "^(Error:|.*stopped at line .* due to error)" "$LOG_FILE"; then
  exit 1
fi
