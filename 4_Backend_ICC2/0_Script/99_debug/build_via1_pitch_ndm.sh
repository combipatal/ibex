#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

variant_root="4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch"
tech_dir="$variant_root/tech"
ndm_dir="$variant_root/ndm"
log_dir="4_Backend_ICC2/3_Log/99_debug"
src_tf="/DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf"
dst_tf="$tech_dir/saed32nm_1p9m_mw.via1_pitch.tf"
log_path="$log_dir/build_via1_pitch_ndm.log"

mkdir -p "$tech_dir" "$ndm_dir" "$log_dir"

awk '
  BEGIN { in_via1 = 0 }
  /^Layer[[:space:]]+"VIA1"[[:space:]]*\{/ { in_via1 = 1 }
  in_via1 && /\/\*pitch[[:space:]]*=[[:space:]]*0\.36\*\// {
    sub(/\/\*pitch[[:space:]]*=[[:space:]]*0\.36\*\//, "pitch\t\t\t\t= 0.36")
  }
  in_via1 && /^}/ { in_via1 = 0 }
  { print }
' "$src_tf" > "$dst_tf"

env \
  MOD_LEF_TECH_FILE="$dst_tf" \
  MOD_LEF_NDM_DIR="$ndm_dir" \
  MOD_LEF_WORKSPACE_SUFFIX="ibex_libdir_modify_via1_pitch" \
  MOD_LEF_NDM_SUFFIX="modified_lef_via1_pitch" \
  lm_shell -f 4_Backend_ICC2/0_Script/99_debug/build_modified_lef_ndm.tcl \
    | tee "$log_path"

echo "VIA1_PITCH_NDM_DONE ndm_dir=$ndm_dir"
