# Result Summary

| Stage | Tool | Result | Key Report | Open Item |
|---|---|---:|---|---|
| RTL intake | git/filelist | PASS | docs/rtl_intake.md | Keep upstream commit/config frozen |
| DC analyze/elaborate/link | DC | PASS_WITH_NOTE | 2_Synthesis/4_Report/analyze/check_design.rpt | Classify unused Ibex shadow/debug/feature tie-off warnings before full compile |
| Synthesis | DC Graphical topo | PASS_WITH_NOTE | 2_Synthesis/4_Report/topo/post_compile.qor.rpt | Pre-backend max cap/transition DRC remains for backend closure |
| Pre-backend STA | PrimeTime | PASS_WITH_NOTE | 5_STA/4_Report/pre_backend_topo/global_timing.rpt | Reset recovery/removal untested by current async reset policy |
| Formality R2N | FM | PASS_WITH_NOTE | 3_Formality/3_Log/fm_r2n_topo.log | Auto setup and RTL interpretation warnings recorded |
| Floorplan | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/02_floorplan/utilization.rpt | Initial 0.6004 utilization floorplan only |
| Powerplan | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/03_powerplan/pg_connectivity.rpt | PG rail stitch fix applied; PG clean |
| Place | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/04_place/check_legality.rpt | Legality/PG clean |
| CTS | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt | Legality/PG clean; route_clock DRC/open nets clean |
| PG diagnosis | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/99_debug/baseline_pg_local_stitches/summary.tsv | Root cause classified; targeted rail stitch ported to production |
| Route | ICC2 | COMPLETE_WITH_OPEN_SIGNAL_DRC | 4_Backend_ICC2/4_Report/06_route/check_routes.rpt | 0 open nets and PG clean; signal DRC 720 remains |
| Post-route timing | ICC2/PT | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/06_route/timing.max.rpt | ICC2 route timing positive; route DRC still open |
| Modified-LEF route debug | ICC2 | COMPLETE_WITH_RESIDUAL_SIGNAL_DRC | 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/check_routes.rpt | 0 open nets and PG clean; signal DRC reduced to 41, not clean |
| Modified-LEF cleanup candidate | ICC2 | SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC | 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved/summary.tsv | 0 open nets; residual DRC 20 = Off-grid 19, Short 1 |
| VIA12SQ_C row-limit NDM route probe | ICC2 | REJECTED_NO_IMPROVEMENT | 4_Backend_ICC2/4_Report/99_debug/modified_lef_via12sqc_row1_route_flow/06_route/check_routes.rpt | 41 DRCs; worse than saved 20-DRC candidate |
| Residual split-via probes | ICC2 | REJECTED_NO_ACCEPTED_FIX | 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_repair_cleanup_saved/summary.tsv | Split ECOs worsen DRC/open nets or restore original 20 DRCs |
| Via-array/fat-contact option combo | ICC2 | REJECTED_NO_ACCEPTED_FIX | 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv | 20 DRCs; Off-grid 0 but Needs fat contact 9 and Short 11 |
| Off-grid context inspection | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_offgrid_context/offgrid_context.tsv | Residual locations are near NOR2 A1/VSS pin-access contexts |
| Targeted NOR2 resize ECO probe | ICC2 | REJECTED_BREAKS_CONNECTIVITY | 4_Backend_ICC2/4_Report/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved/summary.tsv | 43 DRCs and 19 open nets; rejected |
| Extended cleanup candidate | ICC2 | SAVED_REJECTED_CANDIDATE | 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_iter50_saved/summary.tsv | 21 DRCs; rejected |
| NOR2 cell-use synthesis debug | DC Graphical topo | PASS_WITH_PRE_BACKEND_DRC_NOTE | 2_Synthesis/4_Report/99_debug/pre_backend_topo_nor2_no_x0x2_hvt/nor2_dont_use_verify.rpt | NOR2X0/X2 removed; max transition/cap notes remain |
| NOR2-policy modified-LEF route debug | ICC2 | REJECTED_NO_IMPROVEMENT | 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow/06_route/check_routes.rpt | 36 DRCs; worse than saved 20-DRC candidate |
| NOR2-policy cleanup candidate | ICC2 | SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC | 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved/summary.tsv | 0 open nets; residual DRC 19 = Diff net spacing 2, Off-grid 17 |
| NOR2-policy residual probes | ICC2 | REJECTED_NO_ACCEPTED_FIX | 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv | Direct VIA/route-option probes remain at 19 DRCs by trading classes |
| PG M2 offset route probe | ICC2 | REJECTED_PG_DRC_REGRESSION | 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow/06_route/pg_drc.rpt | Signal DRC 32 but PG DRC 640; not acceptable |
| Diff-net blockage cleanup candidate | ICC2 | SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC | 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/summary.tsv | New best: 0 open nets; residual DRC 18 = Off-grid 17, Short 1 |
| 18-DRC residual probes | ICC2 | REJECTED_NO_ACCEPTED_FIX | 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_route_eco_diff_m2_blockage_saved/summary.tsv | Short/M1 blockage and Off-grid remove+route_eco probes did not improve saved candidate |
| Off-grid bbox blockage ECO | ICC2 | REJECTED_NO_TOTAL_DRC_IMPROVEMENT | 4_Backend_ICC2/4_Report/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved/summary.tsv | Off-grid 17 becomes 0, but Short 1 becomes 18 |
| Alternate techfile NDM probes | LM | REJECTED_INPUT_TECHFILE_LOAD_FAILURE | 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_pdk_tf_ndm.log | PDK/ORCA techfiles fail create_workspace with TECH-006/LIB-007 |
| Lower-utilization clean backend rerun | ICC2 | REJECTED_DRC_AND_PG_CONNECTIVITY_REGRESSION | 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_u055_route_flow/06_route/check_routes.rpt | 36 signal DRCs and VSS PG floating std cells 307; worse than 18-DRC best artifact |
| VIA1 pitch NDM route probe | ICC2/LM | REJECTED_NO_IMPROVEMENT | 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow/06_route/check_routes.rpt | 36 signal DRCs = Diff net spacing 2, Off-grid 34; worse than 18-DRC best artifact |
| VIA1 pitch/no-track NDM build | LM | PASS_WITH_NOTE | 4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_no_track_ndm.log | Debug techfile removes VIA1 onGrid/onWireTrack; production policy not decided |
| VIA1 pitch/no-track NOR2-policy route | ICC2 | COMPLETE_WITH_ONE_RESIDUAL_SIGNAL_DRC | 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow/06_route/check_routes.rpt | 0 open nets; 1 Off-grid near MUX41X2_HVT/S0 |
| NOR2+MUX41 cell-use synthesis debug | DC Graphical topo | PASS_WITH_PRE_BACKEND_DRC_NOTE | 2_Synthesis/4_Report/99_debug/pre_backend_topo_nor2_mux41_no_x0x2_hvt/nor2_dont_use_verify.rpt | MUX41X2_HVT removed; Formality not rerun yet |
| VIA1 pitch/no-track NOR2+MUX41 route | ICC2 | DEBUG_ROUTE_DRC_CLEAN_CANDIDATE | 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/06_route/check_routes.rpt | 0 open nets and 0 signal DRC; debug candidate, not production-promoted |

## Backend Open Items

```text
PG connectivity issue is resolved in production powerplan by targeted local rail stitches.
PG fix evidence: 4_Backend_ICC2/4_Report/03_powerplan/pg_rail_stitches.rpt reports 48 conflicting upper vias removed and 8 M1-M2 stitch vias created.
PG clean evidence through route: 03_powerplan/04_place/05_cts/06_route pg_connectivity.rpt reports VDD/VSS floating objects 0 and pg_drc.rpt reports no errors.
CTS rerun after PG fix: 4_Backend_ICC2/4_Report/05_cts/timing.max.rpt worst reported slack MET 0.43 ns; timing.min.rpt worst reported slack MET 0.03 ns.
Route completed: 4_Backend_ICC2/4_Report/06_route/check_routes.rpt reports 0 open nets and 720 signal-route DRCs.
Route DRC breakdown: Diff net spacing 251, Less than minimum area 24, Needs fat contact 347, Off-grid 92, Short 6.
Route DRC matrix inspection: all 720 signal DRCs are on M1/M2/VIA1; M1-M2 Needs fat contact accounts for 347.
Rejected route probes: extra detail routing only oscillated around 660-680 DRCs, and M2-only reroute grew above 11000 DRCs before abort.
Route option probe: fat_contact_effort reduced Needs fat contact as low as 239, but increased Diff net spacing as high as 361 and left total DRC around 660-672; not promoted to production.
Modified-LEF route debug: full backend rerun with modified-LEF NDMs completed in a separate debug library and reduced route DRC from 720 to 41.
Modified-LEF DRC breakdown: Diff net spacing 1, Off-grid 39, Short 1; Needs fat contact eliminated in the final route report.
Modified-LEF sanity checks: route open nets 0, legality TOTAL 0, PG connectivity VDD/VSS floating objects 0, route log reports check_pg_drc No errors found, timing.max slack MET 0.74 ns, timing.min slack MET 0.04 ns.
Modified-LEF residual DRC matrix: M1 has 3 DRCs, M2 has 19 Off-grid DRCs, and VIA1 has 19 Off-grid DRCs. Most residual Off-grid errors are paired M2/VIA1 locations.
Modified-LEF cleanup candidate: debug-only incremental route_detail was saved into 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib; remaining DRC is Off-grid 19 and Short 1 with 0 open nets.
Residual DRC diagnosis: all 19 Off-grid errors map to VIA12SQ_C M1-M2 2x1 via arrays. Removing/shrinking these vias or disabling via arrays either creates opens or trades into fat-contact/min-area/short DRC. Targeted route_eco on the lone short net n48420 also leaves the result unchanged.
VIA12SQ_C row-limit NDM probe: changing ContactCode maxNumRowsNonTurning to 1 in a project-local TF/NDM completed, but final route stayed at 41 DRCs and did not improve the best candidate.
Split-via ECO probes: y-axis and x-axis splits of residual VIA12SQ_C arrays were rejected because they either worsened DRC/open nets or route repair returned to the original 20-DRC state.
Via-array/fat-contact option combo: Off-grid can be forced to 0, but the route trades into Needs fat contact 9 and Short 11 with total DRC still 20.
Extended route_detail cleanup: extra iterations from the saved 20-DRC candidate produced a saved 21-DRC candidate, so it is not promoted.
LEF provenance: libdir/LEF and libdir/LEF/modify are identical; the observed improvement is due to libdir LEFs differing from the original SAED32_EDK LEFs, mainly OR2X1/OR2X4 physical abstracts.
Off-grid context: residual Off-grid locations are near NOR2 A1/VSS pin-access; direct post-route resize to NOR2X4_HVT worsens to 43 DRCs and 19 open nets.
NOR2 cell-use policy rerun: DC debug synthesis successfully removed NOR2X0_HVT/NOR2X2_HVT from the mapped netlist, but the full modified-LEF backend rerun ended at 36 DRCs = Diff net spacing 2, Off-grid 34. This is worse than the saved 20-DRC cleanup candidate before cleanup, so NOR2 dont_use is rejected as a standalone fix.
NOR2-policy cleanup candidate: follow-up route_detail cleanup on the NOR2-policy route saved a debug artifact with 0 open nets and 19 DRCs = Diff net spacing 2, Off-grid 17. It was superseded by the 18-DRC diff-net blockage candidate.
NOR2-policy residual probes: shrinking residual VIA12SQ_C arrays or applying via_array_mode=off plus high fat-contact/wire-via effort leaves final check_routes at 19 DRCs, trading among Off-grid, Needs fat contact, and Short.
PG M2 offset probe: rejected because signal-route DRC changed to 32 all-Off-grid while PG DRC regressed to 640 errors. PG mesh/stitch coordinates must move together if this is revisited.
Diff-net blockage candidate: saved new best debug artifact at 18 DRC with 0 open nets. It removes the previous Diff net spacing 2 on reset net ZBUF_1454_851 but introduces one M1 Short near VSS rail PATH_11_149.
18-DRC candidate sanity: check_legality TOTAL 0, PG connectivity floating objects 0, PG DRC no errors, timing.max slack MET 0.77 ns, timing.min slack MET 0.04 ns.
18-DRC residual probes: added M1 blockage removes Short but worsens to 21 DRC; Off-grid VIA1 remove+route_eco recreates the same 18 DRCs. Both are rejected.
Off-grid bbox blockage probe: M2 blockages at all residual Off-grid bboxes remove the Off-grid class, but the final route is still 18 DRCs because Short increases to 18. This is rejected and supports a lower-metal pin-access/contact legality root cause.
Alternate techfile probes: PDK and ORCA reference techfiles are not direct replacements in the current LM flow; both fail create_workspace with TECH-006/LIB-007 before NDM commit.
Lower-utilization rerun: CORE_UTILIZATION=0.55 clean modified-LEF NOR2-policy backend rerun is rejected. Final route has 36 DRCs = Diff net spacing 2, Off-grid 34, and PG connectivity regresses to VSS floating wires 1/std cells 307, despite legality TOTAL 0, PG DRC no errors, and positive timing.
VIA1 pitch probe: project-local techfile/NDM with VIA1 pitch = 0.36 built successfully but reports TECH-025 for VIA1 onGrid/onWireTrack coexistence. Clean NOR2-policy route has 36 DRCs = Diff net spacing 2, Off-grid 34 with open nets 0, legality clean, PG clean, and timing positive. Rejected because it does not improve the 18-DRC best artifact.
VIA1 pitch/no-track probe: project-local NDMs with VIA1 pitch = 0.36 and VIA1 onGrid/onWireTrack removed built successfully without TECH-025. Clean NOR2-policy backend route improved to 1 Off-grid/open0.
One-DRC context: the remaining Off-grid is M1 net n55676 near U6629/MUX41X2_HVT/S0. Post-route resize of U6629 to MUX41X1_HVT is rejected because it creates 14 DRC and 6 open nets.
NOR2+MUX41 debug synthesis: NOR2X0_HVT/NOR2X2_HVT/MUX41X2_HVT are set dont_use and absent from the mapped Verilog; MUX41X1_HVT count is 126. This debug handoff has not yet gone through Formality R2N.
Current best debug route candidate: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_icc2_lib.
Current best debug route result: 0 open nets, 0 signal DRC, legality TOTAL 0, PG connectivity floating objects 0, PG DRC no errors, timing.max slack MET 0.78 ns, timing.min slack MET 0.04 ns. Antenna checking is not active because no antenna rules are defined.
Modified-LEF/no-track caveat: not promoted to production baseline yet. Production promotion requires a library-policy decision on the VIA1 no-track techfile change plus Formality R2N for the NOR2+MUX41 DC handoff.
Route timing for current official production route remains timing.max MET 0.57 ns and timing.min MET 0.03 ns; the DRC-clean result is still under 99_debug until promoted.
Strict backend strong-done is conditionally open: a debug candidate has signal DRC 0, but production baseline promotion and equivalent handoff proof are not complete.
```
