# Backend Library Policy

## Current Decision State

```text
Status: APPROVED_FOR_PROJECT_BASELINE_PROMOTION
Scope: backend physical library / techfile policy
Candidate: modified-LEF VIA1 pitch/no-track NDMs
Approval date: 2026-05-10
Approval source: user project decision
```

The current best route result depends on a project-local physical-library setup:

```text
LEF source: /DATA/home/edu135/lib/libdir/LEF/modify
Base techfile: /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
Patched techfile: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf
NDM root: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/ndm
Build script: 4_Backend_ICC2/0_Script/99_debug/build_via1_pitch_no_track_ndm.sh
Build log: 4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_no_track_ndm.log
```

## Techfile Delta

The project-local techfile changes only the `Layer "VIA1"` section compared with the SAED32 EDK techfile:

```diff
-               /*pitch                         = 0.36*/
+               pitch                           = 0.36
...
-    onWireTrack = 1
-    onGrid = 1
```

This removes the earlier `TECH-025` condition caused by enabling VIA1 pitch while keeping `onGrid` and `onWireTrack`.

## Evidence

```text
NDM build: PASS_WITH_NOTE
NDM build evidence: build_via1_pitch_no_track_ndm.log writes RVT/LVT/HVT NDMs and has no TECH-025/TECH-006/LIB-007/Fatal pattern.

Route candidate: DEBUG_ROUTE_DRC_CLEAN_CANDIDATE
Route command: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_mux41_policy_route_flow.sh
Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/06_route/check_routes.rpt
Route result: 0 open nets, 0 signal DRC.

Sanity reports:
- check_legality.rpt: TOTAL 0 violations
- pg_connectivity.rpt: VDD/VSS floating objects 0
- pg_drc.rpt / route log: no PG DRC errors
- timing.max.rpt: worst reported slack MET 0.78 ns
- timing.min.rpt: worst reported slack MET 0.04 ns
- antenna.rpt: no antenna rules defined; antenna analysis is not active

Logic equivalence:
Formality log: 3_Formality/3_Log/fm_r2n_topo.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log
Formality result: Verification SUCCEEDED, 34915 passing compare points, 0 failing, 0 unmatched, SVF guidance 2146 accepted / 0 rejected.

Verifier:
Command: 4_Backend_ICC2/0_Script/99_debug/check_drc_clean_candidate.sh
Result: DRC_CLEAN_CANDIDATE_CHECK PASS
Scope: parses saved route/FM/NDM/techfile artifacts; does not run licensed EDA tools.
```

## Production Promotion Gate

This policy is now accepted for the project baseline:

```text
Accept using /DATA/home/edu135/lib/libdir/LEF/modify physical abstracts for backend.
Accept the project-local VIA1 techfile interpretation: pitch = 0.36 with onGrid/onWireTrack removed.
Keep all result claims tied to the route/FM artifacts listed above.
```

Remaining promotion work:

```text
Promote the selected scripts out of 99_debug or clearly mark the production wrapper that uses these exact NDMs.
Update RUN_MANIFEST.md and RESULT_SUMMARY.md to identify the promoted backend baseline.
Keep the route-clean claim bounded to the reports listed above until a promoted rerun or explicit baseline alias is recorded.
```

The policy approval removes the library-governance blocker. It does not by itself create antenna, LVS, IR/EM, ATPG, or silicon signoff evidence.
