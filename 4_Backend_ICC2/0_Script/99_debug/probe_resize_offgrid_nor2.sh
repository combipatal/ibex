#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 4_Backend_ICC2/3_Log/99_debug

target="${NOR2_RESIZE_TARGET:-NOR2X4_HVT}"
log_path="${NOR2_RESIZE_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_resize_offgrid_nor2.${target}.log}"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_resize_offgrid_nor2.tcl \
  | tee "$log_path"
