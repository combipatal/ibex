#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

target_ref="${RESIZE_INST_TARGET_REF:?RESIZE_INST_TARGET_REF is required}"
inst_list="${RESIZE_INST_LIST:?RESIZE_INST_LIST is required}"
safe_target="${target_ref// /_}"
safe_insts="${inst_list// /_}"

mkdir -p 4_Backend_ICC2/3_Log/99_debug

log_path="${RESIZE_INST_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_resize_instances.${safe_target}.${safe_insts}.log}"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_resize_instances.tcl \
  | tee "$log_path"
