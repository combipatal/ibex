# Project Status

## Current Phase

```text
Phase: B0 Repository Intake
Status: COMPLETE
```

```text
Phase: B1 Mini SoC RTL + DC smoke
Status: COMPLETE
```

```text
Phase: B2 DC full synthesis
Status: COMPLETE_WITH_NOTES
```

```text
Phase: B3 pre-backend STA
Status: COMPLETE_WITH_NOTES
```

```text
Phase: B4 Formality R2N
Status: COMPLETE_WITH_NOTES
```

```text
Phase: B5 Backend init/floorplan/powerplan/place
Status: COMPLETE_WITH_NOTES
```

```text
Phase: B6 CTS
Status: COMPLETE_WITH_NOTES
```

```text
Phase: B7 Route
Status: COMPLETE_WITH_OPEN_SIGNAL_DRC
```

## Checklist

```text
[x] Create project skeleton
[x] Create initial tracking files
[x] Clone lowRISC/ibex
[x] Record Ibex commit hash
[x] Read Ibex README/license
[x] Identify initial synthesizable RTL filelist method
[x] Freeze initial Ibex config
[x] Create Mini SoC RTL skeleton
[x] Create first DC filelist and SDC
[x] Run DC analyze/elaborate/link smoke
[x] Run topographical DC compile and generate mapped outputs/SVF
[x] Run pre-backend STA on the matching topo netlist/SDC/SDF
[x] Run Formality R2N against mapped netlist
[x] Build ICC2 SAED32 NDM libraries
[x] Run ICC2 init_design
[x] Create initial floorplan
[x] Create initial powerplan
[x] Run initial placement/legalization
[x] Resolve PG connectivity open issue
[x] Classify modified-LEF NDM as not sufficient to fix PG connectivity
[x] Complete CTS
[x] Complete route
[x] Complete post-route timing/report extraction
[x] Test modified-LEF physical abstract direction for route DRC
[ ] Resolve route signal DRC
```

## Current Notes

```text
DC topo timing: WNS 0.00 ns, TNS 0.00 ns, no setup/hold violating paths.
PT pre-backend STA: no setup/hold violations.
Formality R2N: Verification SUCCEEDED, 34915 passing compare points, 0 failing, 0 unmatched.
SVF guidance: DC topo now emits hier_map guidance; FM accepted 2146 guidance commands and rejected 0.
Known open implementation note: pre-backend max transition/cap violations remain and are acceptable to carry into backend closure for this baseline.
Known constraint note: rst_ni is intentionally not clock-relative; recovery/removal checks are currently untested.
ICC2 init/floorplan/place: completed through placement; placement legality reports TOTAL 0 violations.
Backend PG note: resolved. Production powerplan now removes 48 local conflicting upper vias and adds 8 M1-M2 rail stitches; VDD/VSS floating objects are 0 through route and PG DRC reports no errors.
CTS status: rerun after PG fix completed. Clock tree compilation finished successfully; routed clock nets report 0 open nets and 0 DRCs; check_legality reports TOTAL 0 violations.
CTS timing: timing.max worst reported slack MET 0.43 ns; timing.min worst reported slack MET 0.03 ns.
CTS diagnosis: previous aborted logs were not accepted because duplicate/log-contaminated attempts and termination artifacts made the result unreliable. Clean retry shows the Phase 6 Iter 2 no-output interval was a long-running optimization step, not a hang.
PG diagnosis update: M7 offset and M2 sweeps did not find a clean case. Modified-LEF NDM probe completed with placement/legalization and PG DRC clean, but PG connectivity only changed to VDD 3196 and VSS 396 floating std cells, so it is not a sufficient fix.
PG root-cause update: floating objects were M1 stdcell rail rows with zero vias to the higher PG network. The accepted production fix keeps the original PG mesh, removes conflicting upper via stacks at the isolated rail intersections, and adds explicit M1-M2 stitch vias.
Route status: completed with 0 open nets, legality TOTAL 0, PG connectivity clean, and PG DRC clean.
Route timing: timing.max worst reported slack MET 0.57 ns; timing.min worst reported slack MET 0.03 ns.
Route DRC note: signal-route DRC is not clean. check_routes.rpt reports 720 DRCs: Diff net spacing 251, Less than minimum area 24, Needs fat contact 347, Off-grid 92, Short 6.
Route diagnosis update: DRC matrix shows all 720 signal DRCs are on M1/M2/VIA1; M1-M2 Needs fat contact is the largest class at 347. Extra detail routing is not sufficient, and M2-only reroute is rejected because it drove detail-route DRC above 11000 before abort.
Route option probe update: fat_contact_effort reduced Needs fat contact as low as 239, but increased Diff net spacing as high as 361 and left total DRC around 660-672. This supports lower-metal contact/pin-access as the active root-cause axis, but is not a standalone production fix.
Modified-LEF route probe update: full debug backend rerun using modified-LEF NDMs completed with 0 open nets, legality TOTAL 0, PG connectivity clean, PG DRC clean, timing.max slack MET 0.74 ns, timing.min slack MET 0.04 ns, and signal DRC reduced to 41. Needs fat contact was eliminated; residual DRC is Off-grid 39, Short 1, Diff net spacing 1.
Modified-LEF residual DRC inspection: residual 41 DRCs are all on M1/M2/VIA1. M1 has Diff net spacing 1, Off-grid 1, Short 1; M2 has Off-grid 19; VIA1 has Off-grid 19. Most residual Off-grid issues appear as paired M2/VIA1 locations.
Modified-LEF residual cleanup candidate: debug-only incremental route_detail was saved into a copied candidate ICC2 library under 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib. Remaining DRC is Off-grid 19 and Short 1 with 0 open nets.
Residual Off-grid diagnosis: all 19 remaining Off-grid DRCs are VIA1 and map to router-generated VIA12SQ_C M1-M2 vias with 2x1 array geometry. Removing them creates 14 open nets; shrinking to 1x1 trades Off-grid for open/fat-contact/min-area DRC; via_array_mode=off trades Off-grid for Needs fat contact 9 and Short 11; via_on_grid/via_ladder_clean/off-grid cost do not change the result.
Residual Short diagnosis: the M1 short resolves to net n48420 near a M1 detail route and VSS M1 lib_cell_pin_connect rail. Targeted route_eco and remove-detail-then-route_eco on n48420 both remain at Off-grid 19 and Short 1.
Modified-LEF decision: leading DRC closure direction, but not promoted to production baseline yet because residual route DRC remains and LEF provenance/adoption policy must be recorded before switching production NDMs.
Execution note: observed icc2_exec %CPU near 100 means one logical core is busy, not whole-machine 100 percent CPU usage.
VIA12SQ_C row-limit NDM probe: project-local tech/NDM with maxNumRowsNonTurning=1 completed, but route remained at 41 DRCs: Diff net spacing 1, Off-grid 39, Short 1. Rejected because it does not improve over the saved 20-DRC candidate.
Residual split-via probes: y-axis split worsened to 115 DRCs; y-axis split plus repair returned to the original 20 DRCs; x-axis split produced 167 DRCs and 10 open nets. Rejected as an ECO repair path.
Extended cleanup probe: running 50 more route_detail iterations from the saved 20-DRC candidate produced a saved 21-DRC candidate. Rejected because it worsened total DRC and Off-grid count despite clearing the Short.
Route-option combination probe: via_array_mode=off plus high fat-contact/wire-via effort changed residual DRC to Needs fat contact 9 and Short 11 with Off-grid 0, total still 20. Rejected because it trades DRC class instead of cleaning route.
LEF provenance note: ../lib/libdir/LEF and ../lib/libdir/LEF/modify are identical for RVT/LVT/HVT. The route improvement comes from using libdir LEFs instead of original SAED32_EDK LEFs. Observed differences are concentrated in OR2X1/OR2X4 physical abstracts and include cell width plus lower-metal pin/OBS/PG geometry changes.
Off-grid context update: residual Off-grid locations are near NOR2 A1/VSS pin-access contexts, and the A1 owner instances map to NOR2X0_HVT/NOR2X2_HVT. NOR2 LEF macros compare identical between SAED32_EDK and libdir, so residual closure likely needs NOR2 pin-access/cell-use/placement handling rather than more OR2 LEF editing.
Targeted NOR2 resize probe: resizing the 19 nearby NOR2 cells to NOR2X4_HVT after route worsened the final block to 43 DRCs and 19 open nets. Rejected; if NOR2 cell choice is pursued, do it upstream through synthesis/cell-use policy and clean backend rerun.
NOR2 cell-use policy debug: a DC topo debug handoff with NOR2X0_HVT/NOR2X2_HVT set dont_use was generated; the mapped Verilog contains 0 instances of those two cells, but pre-backend max transition/cap violations remain.
NOR2-policy backend rerun: full modified-LEF backend debug rerun with the NOR2-policy netlist completed with 0 open nets, legality TOTAL 0, PG connectivity clean, PG DRC no errors, timing.max slack MET 0.77 ns, timing.min slack MET 0.04 ns, but route DRC is 36 = Diff net spacing 2, Off-grid 34. Rejected as a standalone fix because it is worse than the saved 20-DRC cleanup candidate.
NOR2-policy cleanup update: route_detail cleanup on the NOR2-policy backend rerun saved a new best debug artifact with 0 open nets and 19 signal DRCs = Diff net spacing 2, Off-grid 17. Legality, PG, and timing sanity reports remain acceptable for debug.
NOR2-policy residual probe update: residual Off-grid inspection shows mixed lower-metal pin-access contexts rather than a NOR2-only pattern. Shrink-via and via_array_off_fat_contact probes remain at 19 DRCs by trading into Needs fat contact/Short classes.
PG M2 offset route probe: rejected. Signal DRC became 32 all-Off-grid, but PG DRC regressed to 640 errors because the shifted mesh no longer matched the fixed rail-stitch pattern.
Diff-net blockage ECO: saved a new best debug artifact by adding a small M2 signal blockage around reset net ZBUF_1454_851 and rerouting that net. Diff net spacing 2 was removed, but one M1 Short was introduced.
Current best debug artifact: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib with 0 open nets and 18 signal DRCs = Off-grid 17, Short 1.
18-DRC candidate sanity: check_legality TOTAL 0; PG connectivity VDD/VSS floating objects 0; PG DRC no errors; timing.max slack MET 0.77 ns; timing.min slack MET 0.04 ns.
Residual Short diagnosis: Short is on ZBUF_1454_851 near VSS M1 rail PATH_11_149 and the reset-net reroute generated by the M2 blockage ECO.
Rejected residual ECO probes: an added M1 blockage cleared the Short but worsened to 21 DRC with Diff net spacing 3 and Off-grid 18; removing Off-grid VIA1 objects then route_eco repaired opens but regenerated the same 18 DRCs.
Off-grid bbox blockage probe: adding M2 signal blockages at all residual Off-grid bboxes removed Off-grid 17 but traded into Short 18, leaving total DRC 18/open0. Rejected as a coordinate-only fix.
Alternate techfile NDM probes: using the PDK or ORCA reference SAED32 techfile directly with the libdir modified LEFs failed Library Manager create_workspace with TECH-006/LIB-007 before NDM commit. These techfiles are not drop-in replacements in the current flow.
Lower-utilization clean rerun: CORE_UTILIZATION=0.55 was tested from a clean modified-LEF NOR2-policy backend flow. It is rejected because final route worsened to 36 DRCs = Diff net spacing 2, Off-grid 34, and PG connectivity regressed to VSS floating wires 1/std cells 307. The 18-DRC diff-net blockage saved artifact remains the best debug artifact.
VIA1 pitch techfile probe: project-local NDMs with VIA1 pitch = 0.36 built successfully, but the build reports TECH-025 because VIA1 onGrid/onWireTrack coexist. A clean NOR2-policy backend rerun with those NDMs finished with 0 open nets, legality TOTAL 0, PG connectivity clean, PG DRC no errors, timing.max slack MET 0.77 ns, timing.min slack MET 0.04 ns, and 36 signal DRCs = Diff net spacing 2, Off-grid 34. Rejected because it does not improve the 18-DRC best artifact.
Residual DRC direction: direct route iteration, object-level VIA ECO probes, via-array route options, PG offset, and standalone NOR2 cell-use exclusion are exhausted for now; next work should inspect physical abstract/TF contact-code consistency around VIA12SQ_C and M1-M2 pin access or test a clean placement/pin-access policy against the 18-DRC artifact.
Next phase: review/fix modified physical abstract/via-rule setup for VIA12SQ_C 2-row M1-M2 arrays and M1 pin-access/rail geometry; do not claim signoff-clean route until a saved route block check_routes reports 0 DRC.
```
