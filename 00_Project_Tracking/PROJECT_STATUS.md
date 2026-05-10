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
Status: COMPLETE_WITH_NOTES
```

```text
Phase: B8 Educational GDS candidate
Status: COMPLETE_WITH_NOTES
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
[x] Produce debug route candidate with 0 open nets and 0 signal DRC
[x] Run Formality R2N on NOR2+MUX41 debug synthesis handoff
[x] Record backend library policy gate for VIA1 no-track NDM
[x] Accept VIA1 no-track library policy for project baseline promotion
[x] Promote DRC-clean candidate wrapper/manifest path to baseline backend flow
[x] Export educational GDS candidate from route-closure block
[x] Attempt one post-route max-cap ECO and record non-promoted result
[x] Attempt final route cleanup after max-cap ECO and verify residual max-cap status
[x] Attempt one residual max-cap ECO from final cleanup and verify route/electrical reports
[x] Run Formality on residual max-cap ECO netlist
[x] Run PrimeTime SDF STA on residual max-cap ECO netlist
[x] Diagnose after-filler max-cap regression in residual max-cap GDS refresh
[x] Apply pre-filler max-cap margin ECO and verify route/electrical reports
[x] Run Formality on pre-filler margin ECO netlist
[x] Run PrimeTime SDF STA on pre-filler margin ECO netlist
[x] Export final educational GDS candidate with after-filler route/electrical reports clean
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
VIA1 pitch/no-track NDM probe: project-local techfile/NDM enabling VIA1 pitch = 0.36 and removing VIA1 onGrid/onWireTrack built successfully with no TECH-025/TECH-006/LIB-007/Fatal pattern in the build log.
VIA1 pitch/no-track NOR2-policy route: clean backend rerun improved to 1 signal DRC/open0. The remaining Off-grid is an M1 pin-access issue near U6629/MUX41X2_HVT/S0. Post-route U6629 resize is rejected because it creates 14 DRC and 6 open nets.
NOR2+MUX41 policy synthesis: debug DC handoff set NOR2X0_HVT, NOR2X2_HVT, and MUX41X2_HVT dont_use. Mapped netlist contains 0 of those cells and uses 126 MUX41X1_HVT instances.
NOR2+MUX41 Formality R2N: passed. Verification SUCCEEDED with 34915 passing compare points, 0 failing, 0 unmatched compare points, and SVF guidance 2146 accepted / 0 rejected.
Current best debug route candidate: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_icc2_lib.
Current best debug route result: check_routes reports 0 open nets and 0 signal DRC; check_legality TOTAL 0; PG connectivity VDD/VSS floating objects 0; PG DRC no errors; timing.max slack MET 0.78 ns; timing.min slack MET 0.04 ns. Antenna checking is not active because no antenna rules are defined.
Route policy update: VIA1 pitch/no-track techfile policy is accepted for project baseline promotion as of 2026-05-10. The clean route artifact is still under 99_debug until the wrapper/manifest path is promoted or explicitly aliased as the baseline flow.
Backend library policy note: docs/backend_library_policy.md records the exact VIA1 techfile delta, NDM source, route/FM evidence, and accepted production promotion gate.
Route closure case study: docs/ibex_backend_route_closure_case_study.md records the DRC breakdown, hypotheses, experiments, accepted candidate, production-promotion boundary, and interview explanation.
Route closure baseline promotion: 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh reran the selected policy as a named baseline path. Report root 4_Backend_ICC2/4_Report/07_route_closure shows 0 open nets, 0 signal DRC, legality TOTAL 0, PG connectivity floating objects 0, PG DRC no errors, timing.max MET 0.78 ns, and timing.min MET 0.04 ns.
Educational GDS candidate: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh exported GDS/DEF/netlist/SDC from the route-closure block. GDS path is 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.gds, size 157M.
GDS candidate checks: after-filler route DRC/open nets are clean, legality is clean, PG connectivity/PG DRC are clean, and qor.after_filler.rpt reports clk critical path slack 0.78 ns with no setup/hold violating paths.
Remaining implementation notes: constraints.after_filler.rpt reports max_transition 8 and max_capacitance 228 violations. Antenna rules are absent, and LVS/foundry DRC/IR/EM/metal-fill/signoff STA are not performed.
Post-route electrical DRC attempt: route_opt iterations reduced max_transition to 0 and max_capacitance to 120, then stalled. A single max-cap ECO reduced final ICC2 max_capacitance to 2, but check_routes regressed to 31 route DRCs. Final cleanup recovered check_routes to open nets 0 and route DRC 0, with legality 0, PG clean, timing positive, max_transition 0, and max_capacitance 2.
Residual max-cap ECO update: one approved final attempt from the final-cleanup block inserted 1 buffer and issued 1 size_cell command. Final reports in 4_Backend_ICC2/4_Report/12_post_route_residual_maxcap_eco show max_transition 0, max_capacitance 0, min_capacitance 0, route open nets 0, route DRC 0, legality TOTAL 0, PG connectivity floating objects 0, PG DRC no errors, and timing.max/min MET 0.64 ns / 0.04 ns.
Residual max-cap ECO FM/PT: Formality passed on 12_post_route_residual_maxcap_eco with 34915 passing compare points, 0 failing, 0 unmatched, and SVF guidance 2146 accepted / 0 rejected. PrimeTime SDF STA reports no setup/hold violations, SDF read errors 0, setup slack 0.68 ns, and hold slack 0.03 ns.
Residual max-cap GDS refresh diagnosis: GDS stream-out from 12_post_route_residual_maxcap_eco completed with route/PG/legality/timing checks clean, but after-filler constraints reintroduced 4 max_capacitance violations on near-limit nets. The cause was filler insertion plus PG reconnect/re-extraction slightly increasing extracted capacitance after the pre-filler clean point.
Pre-filler margin ECO: 14_post_route_prefiller_maxcap_margin applies driver-pin max-cap margin to U77216/Y, U13303/Y, ZBUF_1069_inst_8294/Y, ZBUF_259_inst_8705/Y, and U7539/Y. ECO inserted 5 NBUFFX2_RVT buffers and final reports show max_transition 0, max_capacitance 0, min_capacitance 0, route DRC 0, legality 0, PG clean, and positive timing.
Pre-filler margin ECO FM/PT: Formality passed with 34915 passing compare points, 0 failing, 0 unmatched, SVF guidance 2146 accepted / 0 rejected. PrimeTime SDF STA reports no setup/hold violations, SDF read errors 0, setup slack 0.67 ns, and hold slack 0.03 ns.
Final educational GDS candidate: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds, size 157M. After-filler reports show open nets 0, route DRC 0, max_transition 0, max_capacitance 0, min_capacitance 0, legality clean, PG clean, and timing positive.
Current decision: keep post_route_prefiller_maxcap_margin_gds_candidate as the final educational GDS candidate for this phase. Do not claim signoff clean or tapeout-ready without antenna/LVS/IR/EM/foundry DRC/metal-fill/signoff STA evidence.
Next phase: package and commit scripts/docs/tracking records, then optional educational extensions can start from signoff-style checks or from software/verification bring-up.
```
