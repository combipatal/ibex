#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

net="${DIFF_ECO_NET:-ZBUF_1454_851}"

mkdir -p 4_Backend_ICC2/3_Log/99_debug

log_path="${DIFF_ECO_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_diff_net_blockage_eco.${net}.log}"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_diff_net_blockage_eco.tcl \
  | tee "$log_path"
