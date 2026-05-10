#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/ibex

route_root="4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/06_route"
route_log="4_Backend_ICC2/3_Log/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/06_route.log"
fm_log="3_Formality/3_Log/fm_r2n_topo.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log"
ndm_log="4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_no_track_ndm.log"
tech_file="4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf"

check_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "FAIL missing file: $path" >&2
    exit 1
  fi
}

check_grep() {
  local pattern="$1"
  local path="$2"
  local label="$3"
  if ! grep -Eq "$pattern" "$path"; then
    echo "FAIL $label: pattern not found in $path: $pattern" >&2
    exit 1
  fi
  echo "PASS $label"
}

check_no_grep() {
  local pattern="$1"
  local path="$2"
  local label="$3"
  if grep -Eq "$pattern" "$path"; then
    echo "FAIL $label: forbidden pattern found in $path: $pattern" >&2
    exit 1
  fi
  echo "PASS $label"
}

check_file "$route_root/check_routes.rpt"
check_file "$route_root/check_legality.rpt"
check_file "$route_root/pg_connectivity.rpt"
check_file "$route_root/timing.max.rpt"
check_file "$route_root/timing.min.rpt"
check_file "$route_root/antenna.rpt"
check_file "$route_log"
check_file "$fm_log"
check_file "$ndm_log"
check_file "$tech_file"

check_grep "Total number of open nets = 0" "$route_root/check_routes.rpt" "route open nets 0"
check_grep "Total number of DRCs = 0" "$route_root/check_routes.rpt" "route signal DRC 0"
check_grep "TOTAL 0 Violations" "$route_root/check_legality.rpt" "route legality 0"
check_grep "No antenna rules defined" "$route_root/antenna.rpt" "antenna rule absence recorded"
check_grep "No errors found\\." "$route_log" "PG DRC no errors in route log"
check_grep "slack \\(MET\\)[[:space:]]+0\\.78" "$route_root/timing.max.rpt" "max timing MET"
check_grep "slack \\(MET\\)[[:space:]]+0\\.04" "$route_root/timing.min.rpt" "min timing MET"
check_no_grep "VIOLATED" "$route_root/timing.max.rpt" "max timing no VIOLATED"
check_no_grep "VIOLATED" "$route_root/timing.min.rpt" "min timing no VIOLATED"

if awk '/Number of floating/ { if ($NF != 0) bad=1 } END { exit bad ? 1 : 0 }' "$route_root/pg_connectivity.rpt"; then
  echo "PASS PG connectivity floating counts 0"
else
  echo "FAIL PG connectivity has nonzero floating count" >&2
  exit 1
fi

check_grep "Verification SUCCEEDED" "$fm_log" "Formality verification succeeded"
check_grep "34915 Passing compare points" "$fm_log" "Formality passing compare points"
check_grep "Failing \\(not equivalent\\)[[:space:]]+0[[:space:]]+0[[:space:]]+0[[:space:]]+0[[:space:]]+0[[:space:]]+0[[:space:]]+0[[:space:]]+0" "$fm_log" "Formality failing points 0"
check_grep "Total[[:space:]]+:[[:space:]]+2146[[:space:]]+0[[:space:]]+0[[:space:]]+0[[:space:]]+2146" "$fm_log" "Formality SVF guidance 0 rejected"
check_grep "hier_map[[:space:]]+:[[:space:]]+33[[:space:]]+0[[:space:]]+0[[:space:]]+0[[:space:]]+33" "$fm_log" "Formality hier_map guidance 0 rejected"

check_no_grep "TECH-025|TECH-006|LIB-007|Fatal|Error:" "$ndm_log" "NDM build no known fatal/tech errors"

if awk '
  /^Layer[[:space:]]+"VIA1"[[:space:]]*\{/ { in_via1 = 1 }
  in_via1 && /pitch[[:space:]]*=[[:space:]]*0\.36/ { pitch = 1 }
  in_via1 && /onWireTrack[[:space:]]*=/ { bad = 1 }
  in_via1 && /onGrid[[:space:]]*=/ { bad = 1 }
  in_via1 && /^}/ { in_via1 = 0 }
  END { exit (pitch && !bad) ? 0 : 1 }
' "$tech_file"; then
  echo "PASS VIA1 techfile pitch/no-track policy present"
else
  echo "FAIL VIA1 techfile policy check failed" >&2
  exit 1
fi

echo "DRC_CLEAN_CANDIDATE_CHECK PASS"
