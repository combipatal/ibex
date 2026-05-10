#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

export SRC_ICC2_LIB="${SRC_ICC2_LIB:-4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib}"
export GDS_TAG="${GDS_TAG:-route_closure_gds_candidate}"

mkdir -p 4_Backend_ICC2/3_Log/08_gds

icc2_shell \
  -f 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.tcl \
  -output_log_file "4_Backend_ICC2/3_Log/08_gds/run_write_gds_route_closure.${GDS_TAG}.log"
