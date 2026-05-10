#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

variant_root="4_Backend_ICC2/2_Output/99_debug/modified_lef_via12_all_row1"
tech_dir="$variant_root/tech"
ndm_dir="$variant_root/ndm"
log_dir="4_Backend_ICC2/3_Log/99_debug"
src_tf="/DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf"
dst_tf="$tech_dir/saed32nm_1p9m_mw.via12_all_row1.tf"
log_path="$log_dir/build_via12_all_row1_ndm.log"

mkdir -p "$tech_dir" "$ndm_dir" "$log_dir"

awk '
  BEGIN {
    in_target = 0
    targets["VIA12SQ_C"] = 1
    targets["VIA12BAR_C"] = 1
    targets["VIA12LG_C"] = 1
    targets["VIA12SQ"] = 1
    targets["VIA12BAR"] = 1
    targets["VIA12LG"] = 1
  }
  match($0, /ContactCode[[:space:]]+"([^"]+)"/, m) {
    in_target = (m[1] in targets)
  }
  in_target && /maxNumRowsNonTurning[[:space:]]*=/ {
    sub(/maxNumRowsNonTurning[[:space:]]*=[[:space:]]*[0-9]+/, "maxNumRowsNonTurning\t\t= 1")
  }
  in_target && /^}/ {
    in_target = 0
  }
  { print }
' "$src_tf" > "$dst_tf"

env \
  MOD_LEF_TECH_FILE="$dst_tf" \
  MOD_LEF_NDM_DIR="$ndm_dir" \
  MOD_LEF_WORKSPACE_SUFFIX="ibex_libdir_modify_via12_all_row1" \
  MOD_LEF_NDM_SUFFIX="modified_lef_via12_all_row1" \
  lm_shell -f 4_Backend_ICC2/0_Script/99_debug/build_modified_lef_ndm.tcl \
    | tee "$log_path"

echo "VIA12_ALL_ROW1_NDM_DONE ndm_dir=$ndm_dir"
