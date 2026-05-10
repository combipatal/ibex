#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mode="${SHORT_ECO_MODE:-eco_only}"
net="${SHORT_ECO_NET:-n48420}"

mkdir -p 4_Backend_ICC2/3_Log/99_debug

log_path="${SHORT_ECO_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_short_net_eco.${net}.${mode}.log}"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_short_net_eco.tcl \
  | tee "$log_path"
