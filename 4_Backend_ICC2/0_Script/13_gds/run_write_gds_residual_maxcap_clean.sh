#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

export SOURCE_CLEAN_ICC2_LIB="${SOURCE_CLEAN_ICC2_LIB:-4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/ibex_mini_soc_top_post_route_residual_maxcap_eco_icc2_lib}"
export GDS_TAG="${GDS_TAG:-post_route_residual_maxcap_eco_gds_candidate}"
export SRC_BLOCK="${SRC_BLOCK:-ibex_mini_soc_top_post_route_residual_maxcap_eco}"
export GDS_ICC2_LIB="${GDS_ICC2_LIB:-4_Backend_ICC2/2_Output/13_gds/${GDS_TAG}/ibex_mini_soc_top_${GDS_TAG}_icc2_lib}"
export SRC_ICC2_LIB="$GDS_ICC2_LIB"

if [ ! -d "$SOURCE_CLEAN_ICC2_LIB" ]; then
  echo "Missing source clean ICC2 library: $SOURCE_CLEAN_ICC2_LIB" >&2
  exit 1
fi

rm -rf "$GDS_ICC2_LIB"
mkdir -p "$(dirname "$GDS_ICC2_LIB")" 4_Backend_ICC2/3_Log/13_gds
cp -a "$SOURCE_CLEAN_ICC2_LIB" "$GDS_ICC2_LIB"

icc2_shell \
  -f 4_Backend_ICC2/0_Script/13_gds/run_write_gds_residual_maxcap_clean.tcl \
  -output_log_file "4_Backend_ICC2/3_Log/13_gds/run_write_gds_residual_maxcap_clean.${GDS_TAG}.log"
