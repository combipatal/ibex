# Backend Flow

Initial ICC2 target:

```text
Technology: SAED32 1p9m
Utilization: 55-60%
Aspect ratio: 1:1
Memory style: stdcell-only for first baseline
```

## Current Backend Baseline

```text
Input handoff: DC topographical pre_backend_topo netlist/SDC
Backend library: SAED32 RVT/LVT/HVT NDM generated under 4_Backend_ICC2/2_Output/00_setup/ndm
ICC2 design library: 4_Backend_ICC2/2_Output/01_init_design/ibex_mini_soc_top_icc2_lib
```

## Completed Stages

```text
NDM setup: PASS_WITH_NOTE
init_design: PASS_WITH_NOTE
floorplan: PASS_WITH_NOTE, utilization 0.6004
powerplan: PASS_WITH_NOTE, PG DRC clean, PG connectivity clean after rail stitch fix
place: PASS_WITH_NOTE, legality clean, PG connectivity clean
CTS: PASS_WITH_NOTE, clean single-process retry completed
route: COMPLETE_WITH_OPEN_SIGNAL_DRC, 0 open nets, signal DRC 720
route-closure baseline: PASS_WITH_NOTE, 0 open nets, 0 signal DRC with modified-LEF VIA1 pitch/no-track NDMs and NOR2+MUX41 cell-use handoff
educational GDS candidate: PASS_WITH_NOTE, GDS/DEF/netlist/SDC exported from route-closure block
final electrical-clean GDS candidate: PASS_WITH_NOTE, GDS/DEF/netlist/SDC exported after pre-filler max-cap margin ECO
```

CTS evidence:

```text
Log: 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log
Clock post-check: 4_Backend_ICC2/4_Report/05_cts/check_clock_trees.post.rpt
Legality: 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt
Timing max/min: 4_Backend_ICC2/4_Report/05_cts/timing.max.rpt, timing.min.rpt
PG connectivity: 4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt
```

CTS result after PG fix:

```text
clock tree compilation completed successfully
clock route detail routing ended with 0 open nets and 0 DRCs
check_legality reports TOTAL 0 violations
timing.max worst reported slack MET 0.43 ns
timing.min worst reported slack MET 0.03 ns
PG connectivity reports VDD/VSS floating objects 0
PG DRC reports no errors
```

## Current Route Closure State

```text
Historical official production route still has signal route DRC open.
06_route check_routes.rpt: 0 open nets, 720 DRCs.
DRC breakdown: Diff net spacing 251, Less than minimum area 24, Needs fat contact 347, Off-grid 92, Short 6.
PG connectivity and PG DRC remain clean through route.

Promoted route-closure baseline exists:
- Wrapper: 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh
- Route report: 4_Backend_ICC2/4_Report/07_route_closure/06_route/check_routes.rpt
- ICC2 library: 4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib
- Result: 0 open nets, 0 signal DRC.
- Legality: TOTAL 0.
- PG connectivity: VDD/VSS floating objects 0.
- PG DRC: no errors.
- Timing: max slack MET 0.78 ns; min slack MET 0.04 ns.
- Antenna checking is not active because no antenna rules are defined.

Original debug DRC-clean evidence:
- Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/06_route/check_routes.rpt
- Result: 0 open nets, 0 signal DRC.
- Legality: TOTAL 0.
- PG connectivity: VDD/VSS floating objects 0.
- PG DRC: no errors.
- Timing: max slack MET 0.78 ns; min slack MET 0.04 ns.
- Formality R2N for the matching NOR2+MUX41 synthesis handoff: PASS_WITH_NOTE.

Educational GDS candidate:
- Wrapper: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh
- Manifest: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/gds_export_manifest.txt
- GDS: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.gds
- Companion outputs: DEF, Verilog, and SDC in the same output directory.
- Post-filler checks: route DRC/open clean, legality clean, PG connectivity clean, PG DRC no errors.
- QoR note: clk critical path slack 0.78 ns; constraints.after_filler reports max_transition 8 and max_capacitance 228 violations.

Final electrical-clean educational GDS candidate:
- Margin ECO wrapper: 4_Backend_ICC2/0_Script/14_post_route_prefiller_maxcap_margin/run_post_route_prefiller_maxcap_margin.sh
- GDS wrapper: 4_Backend_ICC2/0_Script/13_gds/run_write_gds_residual_maxcap_clean.sh
- Manifest: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/gds_export_manifest.txt
- GDS: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds
- Companion outputs: DEF, Verilog, and SDC in the same output directory.
- Source netlist FM/PT: fm_post_route_prefiller_maxcap_margin.log reports Verification SUCCEEDED; PT post_route_prefiller_maxcap_margin reports no setup/hold violations and read_sdf errors 0.
- Post-filler checks: route DRC/open clean, max_transition 0, max_capacitance 0, min_capacitance 0, legality clean, PG connectivity clean, PG DRC no errors.
- QoR note: setup slack 0.64 ns; no hold violations.

Strict backend strong-done for educational baseline is complete with caveats. The final GDS candidate has ICC2 after-filler route/electrical/PG checks clean, but do not claim signoff clean without antenna rules, foundry DRC, LVS, IR/EM, metal fill, and signoff STA evidence.
```

## PG Diagnosis Notes

```text
M7 offset sweep: did not find a clean PG connectivity case; offset changes only shifted the VDD/VSS floating-cell distribution.
M2 sweep: tested pitch/offset variants reproduced the baseline PG connectivity counts.
Modified LEF NDM build: completed from /DATA/home/edu135/lib/libdir/LEF/modify into 4_Backend_ICC2/2_Output/99_debug/modified_lef_pg_probe/ndm.
Modified LEF PG probe: separate debug ICC2 library, same DC topo handoff and same initial PG strategy.
Modified LEF result: compile_pg recognized 109713 standard cells and PG DRC was clean, but PG connectivity remained not clean at VDD 3196 and VSS 396 floating std cells.
Conclusion: modified LEF NDM slightly changes the symptom but is not sufficient as a production fix. No front-end/DC/FM rerun is needed for this physical-abstract-only experiment.
```

Current PG root-cause classification:

```text
Floating connectivity objects are full-width M1 stdcell rails with shape_use lib_cell_pin_connect and zero vias to the main PG network.
The initial M2 mesh geometry causes ICC2 via DRC/dangling cleanup to remove all rail-to-mesh vias for several rail rows.
Accepted fix keeps the original PG mesh, removes the local conflicting upper via stacks at the eight isolated rail intersections, and adds explicit M1-M2 stitch vias.
Production evidence: 4_Backend_ICC2/4_Report/03_powerplan/pg_rail_stitches.rpt, 03_powerplan/04_place/05_cts/06_route pg_connectivity.rpt, and matching pg_drc.rpt files.
Detailed diagnosis: 00_Project_Tracking/PG_DIAGNOSIS_NOTES.md
```

Route DRC diagnosis:

```text
Route completed with 0 open nets and timing-positive reports, but signal DRC remains 720.
Dominant classes are Needs fat contact and Diff net spacing.
Detailed matrix: 4_Backend_ICC2/4_Report/99_debug/route_drc_inspect/drc_matrix.rpt shows all DRCs are on M1/M2/VIA1.
Rejected route-only probes:
- detail_extra: additional detail routing only oscillated around 660-680 DRCs.
- reroute_m2: min-routing-layer M2 reroute drove DRC above 11000 before abort.
Route option probe:
- fat_contact_effort: route.detail.fat_metal_forbidden_pitch_effort_level=high and route.detail.optimize_wire_via_effort_level=high reduced Needs fat contact as low as 239, but increased Diff net spacing as high as 361 and left total DRC around 660-672.
Modified-LEF route debug:
- full backend rerun using modified-LEF NDMs completed in 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib.
- final check_routes reports 0 open nets and 41 signal DRCs: Diff net spacing 1, Off-grid 39, Short 1.
- Needs fat contact is eliminated in the modified-LEF debug route.
- legality TOTAL 0, PG connectivity clean, route log reports check_pg_drc No errors found, timing.max slack MET 0.74 ns, timing.min slack MET 0.04 ns.
- residual DRC matrix shows M1 3, M2 19, VIA1 19. Most residual Off-grid DRCs are paired M2/VIA1 locations.
- debug-only incremental route_detail cleanup was saved into 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib.
- saved cleanup candidate reports 0 open nets and 20 residual DRCs: Off-grid 19 and Short 1.
- all 19 Off-grid DRCs map to VIA12SQ_C M1-M2 2x1 via arrays; via-center origins are on the routing track grid, so the problem is the generated array/cut geometry rather than center-grid snapping.
- rejected residual probes: removing off-grid vias creates 14 open nets; shrinking to 1x1 trades into open/fat-contact/min-area DRC; via_array_mode=off trades into Needs fat contact 9 and Short 11; via_on_grid/via_ladder_clean/off-grid cost do not change DRC; targeted n48420 route_eco does not remove the lone M1 Short.
- NOR2 cell-use policy alone is rejected: a full modified-LEF backend rerun with NOR2X0_HVT/NOR2X2_HVT removed ended at 36 DRCs.
- cleanup on that NOR2-policy route saved the current best debug artifact at 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib.
- later 18-DRC and 1-DRC debug waypoints narrowed the remaining issue to VIA1 track policy and MUX41X2_HVT/S0 pin access.
- project-local VIA1 pitch/no-track NDMs improved the NOR2-policy clean rerun to 1 Off-grid/open0.
- excluding MUX41X2_HVT upstream and rerunning clean backend with the VIA1 pitch/no-track NDM produced the current DRC-clean debug candidate.
Current diagnosis: lower-metal pin-access/contact physical abstract setup was the active route DRC cause. The current debug candidate closes signal DRC, but production promotion is gated by the backend library policy in docs/backend_library_policy.md.
Initial route diagnosis: 00_Project_Tracking/ROUTE_DIAGNOSIS_NOTES.md
```
