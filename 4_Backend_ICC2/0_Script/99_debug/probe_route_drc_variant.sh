#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

variant="${ROUTE_DRC_VARIANT:-detail_extra}"

mkdir -p 4_Backend_ICC2/3_Log/99_debug

log_path="${ROUTE_DRC_VARIANT_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.${variant}.log}"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.tcl \
  | tee "$log_path"
