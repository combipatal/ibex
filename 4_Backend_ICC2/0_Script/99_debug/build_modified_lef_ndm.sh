#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

LOG_DIR="4_Backend_ICC2/3_Log/99_debug"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/build_modified_lef_ndm.log"

lm_shell -f 4_Backend_ICC2/0_Script/99_debug/build_modified_lef_ndm.tcl \
  | tee "$LOG_FILE"

if rg -n "^(Error:|.*stopped at line .* due to error)" "$LOG_FILE"; then
  exit 1
fi
