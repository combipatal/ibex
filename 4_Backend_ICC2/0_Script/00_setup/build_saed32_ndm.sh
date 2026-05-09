#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

mkdir -p 4_Backend_ICC2/3_Log/00_setup

lm_shell -f 4_Backend_ICC2/0_Script/00_setup/build_saed32_ndm.tcl \
  | tee 4_Backend_ICC2/3_Log/00_setup/build_saed32_ndm.log

