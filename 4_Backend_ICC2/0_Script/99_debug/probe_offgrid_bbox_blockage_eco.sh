#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

log_path="${OFFGRID_BLOCKAGE_LOG:-4_Backend_ICC2/3_Log/99_debug/probe_offgrid_bbox_blockage_eco.log}"
mkdir -p "$(dirname "$log_path")"

icc2_shell -f 4_Backend_ICC2/0_Script/99_debug/probe_offgrid_bbox_blockage_eco.tcl \
  -output_log_file "$log_path"
