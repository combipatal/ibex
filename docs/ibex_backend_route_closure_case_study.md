# Ibex Backend Route Closure Case Study

## 1. Goal

Close the first Ibex Mini SoC backend route baseline enough to support an auditable FE-to-BE milestone:

```text
RTL/config freeze -> DC topo synthesis -> Formality R2N -> ICC2 backend -> route reports
```

The immediate route-closure goal was:

```text
0 signal open nets
0 signal route DRC
PG connectivity clean
PG DRC clean
legal placement
positive route timing
matching Formality R2N proof for the mapped handoff used by backend
```

This is not a full signoff claim. Antenna checking is not active because no antenna rules are defined, and LVS/IR/EM/ATPG/software boot are outside the current evidence set.

## 2. Baseline Result

The first production route completed and saved a routed block, but it was not DRC-clean.

```text
Route report: 4_Backend_ICC2/4_Report/06_route/check_routes.rpt
Open nets: 0
Signal route DRC: 720
Legality: TOTAL 0 violations
PG connectivity: VDD/VSS floating objects 0
PG DRC: no errors
Timing: setup slack MET 0.57 ns; hold/min slack MET 0.03 ns
```

Summary matrix:

| Run | Open | DRC | PG | Legality | Timing | Decision |
|---|---:|---:|---|---:|---|---|
| production route | 0 | 720 | clean | 0 | +0.57/+0.03 | not clean |
| modified LEF | 0 | 41 | clean | 0 | +0.74/+0.04 | partial |
| cleanup saved | 0 | 20 | clean | 0 | positive | partial |
| NOR2 policy | 0 | 19 | clean | 0 | positive | partial |
| diff blockage | 0 | 18 | clean | 0 | +0.77/+0.04 | partial |
| VIA1 no-track + NOR2/MUX41 | 0 | 0 | clean | 0 | +0.78/+0.04 | debug clean candidate |

## 3. DRC Breakdown

Initial route DRC breakdown:

```text
Report: 4_Backend_ICC2/4_Report/06_route/check_routes.rpt

Total DRCs: 720
Diff net spacing: 251
Less than minimum area: 24
Needs fat contact: 347
Off-grid: 92
Short: 6
```

Detailed inspection showed the issue was localized to lower-metal routing and pin access:

```text
Report: 4_Backend_ICC2/4_Report/99_debug/route_drc_inspect/drc_matrix.rpt

M1: 263 total
M1-M2: 347 total
M2: 67 total
VIA1: 43 total
```

The dominant class was `Needs fat contact` on M1-M2. This shifted the diagnosis away from PG, timing, or global connectivity and toward lower-metal physical abstracts, via/contact definitions, and standard-cell pin access.

## 4. Hypothesis

Primary hypothesis:

```text
The route DRCs are driven by inconsistent or insufficient lower-metal pin-access/contact modeling for the physical abstracts used by ICC2.
```

Supporting observations:

```text
PG was clean through route, so the 720 DRCs were not a PG-network open problem.
All route DRCs were on M1/M2/VIA1.
More detail-route iteration reduced DRC only modestly and then oscillated.
M2-only reroute made pin access much worse.
Fat-contact route effort moved the dominant class, but traded into spacing DRC.
Modified physical abstracts removed the Needs fat contact class.
Residual off-grid errors repeatedly involved VIA1/M1-M2 pin-access geometry.
```

Rejected alternative hypotheses:

```text
More route iterations alone are sufficient.
Avoiding M1 routing is sufficient.
Lower utilization alone is sufficient.
Coordinate-only blockages or post-route via ECOs are sufficient.
Post-route cell resizing is safe enough for final closure.
```

## 5. Experiments

Key experiments and decisions:

```text
detail_extra route probe:
Result: DRC oscillated around the 660-680 range.
Decision: rejected.

reroute_m2 route probe:
Result: detail-route DRC grew above 11000.
Decision: rejected.

fat_contact_effort route probe:
Result: Needs fat contact improved, but Diff net spacing increased and total DRC stayed high.
Decision: rejected as standalone fix.

modified-LEF backend rerun:
Result: 720 DRC -> 41 DRC; Needs fat contact disappeared.
Decision: accepted as root-cause evidence, partial closure only.

cleanup saved candidate:
Result: 41 DRC -> 20 DRC with open nets 0.
Decision: debug waypoint.

VIA12SQ_C row-limit / split-via / route-option probes:
Result: no connected clean route; DRC classes traded.
Decision: rejected.

NOR2X0_HVT/NOR2X2_HVT dont_use:
Result: clean rerun reached 19 DRC after cleanup.
Decision: useful partial cell-use direction, not standalone closure.

diff-net M2 blockage:
Result: 19 DRC -> 18 DRC, but introduced one Short.
Decision: debug waypoint only.

VIA1 pitch-only techfile:
Result: NDM built but reported TECH-025; route remained 36 DRC.
Decision: rejected as standalone fix.

VIA1 pitch/no-track techfile:
Result: NDM built without TECH-025 and route improved to 1 DRC with NOR2 policy.
Decision: accepted as active closure direction, pending policy approval.

NOR2X0_HVT/NOR2X2_HVT/MUX41X2_HVT dont_use with VIA1 no-track:
Result: route reached 0 open nets and 0 signal DRC.
Decision: accepted debug clean candidate.
```

## 6. Accepted Debug Candidate

Accepted candidate:

```text
Route wrapper:
4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_mux41_policy_route_flow.sh

ICC2 route block:
4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_icc2_lib

Route report root:
4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/06_route
```

Route evidence:

```text
check_routes.rpt: Total number of open nets = 0; Total number of DRCs = 0
check_legality.rpt: TOTAL 0 Violations
pg_connectivity.rpt: VDD/VSS floating objects 0
06_route.log: check_pg_drc reports no errors
timing.max.rpt: worst reported slack MET 0.78 ns
timing.min.rpt: worst reported slack MET 0.04 ns
```

Logic-equivalence evidence for the matching handoff:

```text
Formality log:
3_Formality/3_Log/fm_r2n_topo.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log

Result:
Verification SUCCEEDED
34915 passing compare points
0 failing compare points
0 unmatched compare points
SVF guidance 2146 accepted / 0 rejected
```

Candidate verification helper:

```text
Script: 4_Backend_ICC2/0_Script/99_debug/check_drc_clean_candidate.sh
Result: DRC_CLEAN_CANDIDATE_CHECK PASS
Scope: parses saved reports/logs only; does not rerun licensed tools
```

## 7. Why Not Production-Promoted

Before explicit policy approval, this could not be called the production baseline because the clean result depended on a project-local technology interpretation:

```text
LEF source: /DATA/home/edu135/lib/libdir/LEF/modify
Base techfile: /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
Patched techfile:
4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf
```

The accepted techfile delta is limited to `Layer "VIA1"`:

```diff
-               /*pitch                         = 0.36*/
+               pitch                           = 0.36
...
-    onWireTrack = 1
-    onGrid = 1
```

The reason for the gate was not that the route result was incomplete. The reason was library governance: a route-clean result that depends on changed physical abstracts and a changed VIA1 techfile rule must not be silently mixed into the official flow.

Current policy state after user approval on 2026-05-10:

```text
The VIA1 pitch/no-track techfile policy is accepted for this project baseline.
The route-clean artifact was promoted to a named baseline wrapper/report path after policy approval.
Baseline wrapper: 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh.
Baseline report root: 4_Backend_ICC2/4_Report/07_route_closure.
```

Remaining claim boundary:

```text
Allowed: route DRC-clean baseline with 0 opens, PG clean, legality clean, positive route timing, matching Formality R2N, and educational GDS candidate export.
Not allowed yet: signoff-clean, antenna-clean, LVS-clean, IR/EM-clean, production-ready silicon claim.
```

## 8. Interview Explanation

Short explanation:

```text
The first route was connected and timing-positive, but it had 720 route DRCs. I did not treat tool completion as success. I broke down the DRCs and found they were all lower-metal M1/M2/VIA1 issues, dominated by M1-M2 fat-contact and off-grid pin-access behavior.

I rejected simple fixes first: more route iterations, M2-only routing, route effort options, direct post-route via ECO, lower utilization, and post-route cell resizing. They either oscillated, worsened connectivity, or traded one DRC class for another.

The breakthrough was proving that the route issue was tied to the physical abstract and VIA1 techfile interpretation. Modified LEFs removed the fat-contact class, and enabling VIA1 pitch while removing conflicting onGrid/onWireTrack constraints eliminated the remaining off-grid pattern when combined with an upstream cell-use policy that avoided NOR2X0, NOR2X2, and MUX41X2.

The final debug candidate has 0 open nets, 0 signal route DRC, clean PG connectivity, clean legality, positive route timing, and a passing Formality R2N check for the matching synthesis handoff. I still do not call it signoff-clean because antenna rules are absent and LVS/IR/EM are not in evidence.
```

Practical lesson:

```text
In implementation, a clean-looking timing result is not enough. Backend closure depends on consistent logical libraries, physical abstracts, techfile/via rules, synthesis cell-use policy, and DC/FM/backend handoff alignment. The important engineering step was keeping every experiment report-backed and rejecting fixes that only changed the DRC distribution without improving the objective pass/fail signal.
```

## 9. Post-Route Electrical/GDS Follow-Up

After the route-clean baseline and first educational GDS export, the after-filler electrical reports showed that route DRC clean was not the same as electrical DRC clean:

```text
First GDS candidate:
4_Backend_ICC2/4_Report/08_gds/route_closure_gds_candidate/constraints.after_filler.rpt

Result:
max_transition 8
max_capacitance 228
```

Bounded electrical cleanup sequence:

```text
09 route_opt: max_transition 0, max_capacitance 120
10 max-cap ECO: max_capacitance 2, but route DRC regressed to 31
11 route cleanup: route DRC 0, max_capacitance 2
12 residual max-cap ECO: route DRC 0, max_transition 0, max_capacitance 0
```

The `12_post_route_residual_maxcap_eco` netlist then passed FM and PT:

```text
FM: Verification SUCCEEDED; 34915 passing; 0 failing; 0 unmatched
PT: no setup/hold violations; read_sdf errors 0
```

Refreshing GDS directly from 12 exposed a final margin issue:

```text
13_gds/post_route_residual_maxcap_eco_gds_candidate:
GDS written, route/PG/legal/timing checks clean, but after-filler max_capacitance 4
```

Accepted final fix:

```text
14_post_route_prefiller_maxcap_margin:
apply driver-pin max-cap margin before filler
eco_opt inserts 5 NBUFFX2_RVT buffers
final ICC2 reports route DRC 0, max_transition 0, max_capacitance 0
FM/PT pass on the 14 netlist
13_gds/post_route_prefiller_maxcap_margin_gds_candidate writes GDS with after-filler route/electrical checks clean
```

Final educational GDS candidate:

```text
4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds
```

This strengthens the educational backend handoff, but it does not change the claim boundary: antenna rules, foundry DRC, LVS, IR/EM, metal fill, and signoff STA remain outside the evidence.
