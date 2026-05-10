#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/DATA/home/edu135/ibex"
cd "$ROOT_DIR"

export DEBUG_ICC2_LIB_DIR="${DEBUG_ICC2_LIB_DIR:-$ROOT_DIR/4_Backend_ICC2/2_Output/debug_pg/ibex_mini_soc_top_icc2_lib_pg_debug}"

LOG_DIR="4_Backend_ICC2/3_Log/99_debug"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/probe_baseline_pg_local_stitches.log"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_baseline_pg_local_stitches.tcl \
  -output_log_file "$LOG_FILE"

if rg -n "^(Error:|ERROR:)|stopped at line .* due to error" "$LOG_FILE"; then
  echo "Baseline PG local stitches probe finished with errors. See $LOG_FILE" >&2
  exit 1
fi

echo "Baseline PG local stitches probe finished. Log: $LOG_FILE"
