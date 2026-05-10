# Decision Log

## 2026-05-09

```text
Project target: Ibex-based Mini SoC FE-to-BE implementation baseline.
Primary source: https://github.com/lowRISC/ibex
Support source: https://github.com/lowRISC/ibex-demo-system
First milestone: one end-to-end baseline, not sweeps.
Initial clock target: 10 ns.
Initial libraries: SAED32 TT 1.05V 25C mixed-VT RVT/LVT/HVT.
Initial memory plan: 2KB IMEM + 2KB DMEM stdcell regfile memories.
Fallback memory plan: 1KB IMEM + 1KB DMEM if runtime/congestion is too high.
Initial synthesis top: ibex_mini_soc_top.
Initial integration preference superseded: use ibex_top from project wrapper.
Initial parameter policy: prefer wrapper-level overrides, avoid tool-script-only overrides.
Initial tie-off policy: prefer wrapper RTL tie-offs.
```

```text
Decision: upload only project scripts, constraints, docs, and tracking records to GitHub.
Reason: rtl/ibex is an upstream clone and should be represented by source revision, not vendored into this project repo.
Remote: ssh://git@ssh.github.com:443/combipatal/ibex.git
SSH port policy: use GitHub SSH over port 443, not port 22.
Local git note: /DATA/home/edu135/ibex/.git is a read-only placeholder directory, so project git metadata uses .git_local via scripts/git_project.sh.
```

```text
Decision: first baseline integrates ibex_top, not ibex_core.
Reason: ibex_core exposes register-file ports. ibex_top contains the register file and reduces first-pass SoC integration risk.
Actual synthesis top remains ibex_mini_soc_top.
Expected Ibex instance path: ibex_mini_soc_top/u_ibex_top.
```

```text
Decision: run project execution with practical ASIC implementation discipline.
Reason: baseline must be reproducible and auditable after context reset, not just a chat-driven demo.
Policy: prefer scripted runs, frozen config, aligned DC/FM/PT/backend inputs, report-based pass/fail checks, and tracking records for every major stage.
Context file updated: AGENTS.md
```

```text
Decision: generate Formality hier-map guidance in the official DC topo SVF.
Reason: initial FM R2N run stayed in verify for too long; log showed no guide_hier_map commands, 1044 rejected SVF commands, and unmatched reference compare points.
Implementation: set hdlin_enable_hier_map true before RTL analyze and call set_verification_top after elaboration in 2_Synthesis/0_Script/run_dc_compile_topo.tcl.
Result: regenerated SVF produced 2146 accepted guidance commands, 0 rejected, including 33 accepted hier_map commands; FM R2N passed.
```

```text
Decision: do not add script-level lock files to shared EDA wrappers.
Reason: this project area may be used for separate experiments by different users/projects; locking inside the checked-in wrapper would impose a local execution policy globally.
Operational policy: before rerunning a shared backend step, manually check active icc2_shell/icc2_exec processes and archive partial logs if a run was interrupted.
```

```text
Decision: treat the clean single-process CTS retry as the accepted CTS baseline.
Reason: the earlier CTS aborted logs were contaminated by duplicate runs and termination artifacts; a clean retry completed without Fatal/Internal system error.
Evidence: 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log, 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt, 4_Backend_ICC2/4_Report/05_cts/timing.max.rpt, 4_Backend_ICC2/4_Report/05_cts/timing.min.rpt, 4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt.
Result: CTS is PASS_WITH_NOTE; PG connectivity remains an open backend issue.
```

```text
Decision: do not switch the production backend baseline to the modified-LEF NDM as a claimed PG fix.
Reason: the modified-LEF probe used a separate debug ICC2 library and improved PG connectivity only slightly, from VDD 3358/VSS 415 floating std cells to VDD 3196/VSS 396. PG DRC stayed clean in both cases, and floating wires stayed at VDD 7/VSS 1.
Scope note: modified LEFs are physical abstracts, so this experiment does not require front-end RTL, DC, PT pre-backend, or Formality rerun unless logical .db/lib content also changes.
Operational decision: keep the original backend baseline intact; use the modified-LEF NDM only as a debug/probe artifact until a clean PG connectivity result or a stronger root-cause argument exists.
```

## 2026-05-10

```text
Decision: fix PG rail connectivity with targeted local rail stitches in production powerplan.
Reason: debug probes showed the floating stdcell rows are isolated M1 rails. Direct M1-M2 via insertion fixes connectivity but conflicts with existing upper stacked vias; removing the local upper stack first and then adding an M1-M2 stitch gives both PG connectivity clean and PG DRC clean.
Implementation: 4_Backend_ICC2/0_Script/03_powerplan/run_powerplan_initial.tcl now applies eight fixed rail stitch points after compile_pg.
Evidence: 4_Backend_ICC2/4_Report/99_debug/baseline_pg_local_stitches/summary.tsv reports removed_conflicting_vias=48, created_vias=8, VDD/VSS floating objects 0, pg_drc_errors=0. Production 03_powerplan/04_place/05_cts/06_route reports keep PG connectivity clean and PG DRC clean.
Scope: backend physical-only change; no RTL/DC/FM rerun required.
```

```text
Decision: classify the first signal route as complete but not DRC-clean.
Reason: route_auto completed, saved the block, and check_routes reports 0 open nets, but signal-route DRC remains 720.
Evidence: 4_Backend_ICC2/4_Report/06_route/check_routes.rpt reports 0 open nets and Total number of DRCs = 720. PG connectivity and PG DRC are clean through route. Timing remains positive in 06_route timing reports.
Policy: do not claim signoff-clean or route DRC clean. Next work item is targeted route DRC closure diagnosis.
```

```text
Decision: reject route-only "more iteration" and "M2-only reroute" as production route fixes.
Reason: detailed DRC inspection shows all route DRCs are lower-metal/pin-access/contact related. Extra detail routing only reduced DRC modestly and oscillated, while avoiding M1 made the DRC count much worse.
Evidence: 4_Backend_ICC2/4_Report/99_debug/route_drc_inspect/drc_matrix.rpt reports M1/M2/VIA1-only DRC distribution. 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.detail_extra.log reaches 671 DRCs at iteration 46. 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.reroute_m2.log grows above 11000 DRCs during detail routing.
Next policy: test via/contact/via-ladder or physical-abstract setup before floorplan/utilization sweeps.
```

```text
Decision: do not promote fat_contact_effort route options directly into the production route script yet.
Reason: route.detail.fat_metal_forbidden_pitch_effort_level=high and route.detail.optimize_wire_via_effort_level=high reduce the Needs fat contact class, but the probe trades those violations for Diff net spacing and leaves total DRC in the same 660-672 range.
Evidence: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.fat_contact_effort.log reports Needs fat contact as low as 239 at iteration 43, while Diff net spacing reaches 361 and total DRC remains 663 at that iteration. The probe was debug-only and no save_block/save_lib was executed.
Next policy: use this as evidence that contact/fat-contact handling is on the right root-cause axis, then test physical abstract/LEF setup or localized pin-access fixes rather than only increasing route effort.
```

```text
Decision: treat the modified-LEF NDM route run as the leading backend DRC closure direction, but not as a promoted production baseline yet.
Reason: a full debug backend run using the modified-LEF NDMs reduced final route DRC from 720 to 41 and eliminated the Needs fat contact class, while keeping open nets 0, legality clean, PG connectivity clean, PG DRC clean, and positive ICC2 timing. However, 41 signal DRCs remain and the modified LEF provenance/adoption policy still needs to be documented before switching the production scripts.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/check_routes.rpt reports 0 open nets and 41 DRCs: Diff net spacing 1, Off-grid 39, Short 1. 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/pg_connectivity.rpt reports VDD/VSS floating objects 0. 4_Backend_ICC2/3_Log/99_debug/modified_lef_route_flow/06_route.log reports No errors found after check_pg_drc. 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/check_legality.rpt reports TOTAL 0.
Scope: physical-only backend experiment; no RTL/DC/FM rerun is required for diagnosis because the logical handoff is unchanged. Production adoption should rerun backend from init with the selected NDMs and update library provenance records.
Next policy: fix or locally repair the residual DRCs in the modified-LEF flow. Residual inspection shows M1 has 3 DRCs, M2 has 19 Off-grid DRCs, and VIA1 has 19 Off-grid DRCs, with most Off-grid issues appearing as paired M2/VIA1 locations. A debug-only incremental route_detail probe reduced this to 20 DRCs, Off-grid 19 and Short 1, without saving the block. Do not run broad utilization or route-option sweeps until these residual off-grid/short locations are understood.
```

```text
Decision: keep the saved modified-LEF cleanup candidate as a debug waypoint, not a production baseline.
Reason: the saved candidate is the best artifact so far, with 0 open nets and signal DRC reduced to 20, but it still has 19 VIA1 Off-grid violations and 1 M1 Short. Object-level and route-option probes did not produce a connected DRC-clean result.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved/summary.tsv reports after-cleanup DRC 20 and open nets 0. 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect/offgrid_via_attrs.tsv shows the 19 Off-grid vias are VIA12SQ_C M1-M2 2x1 arrays. probe_remove_offgrid_via1, probe_shrink_offgrid_via1_array, via_array_off, via1_on_grid, via_ladder_clean, via1_offgrid_cost20, and n48420 route_eco probes all failed to produce a clean connected route.
Next policy: shift from route effort probes to physical abstract/via-rule review for VIA12SQ_C 2-row array legality and M1 rail/pin-access geometry before production promotion.
```

```text
Decision: reject VIA12SQ_C row-limit NDM, split-via ECO, and extended cleanup as promotion candidates.
Reason: none produced a clean connected route or improved the current best saved debug artifact. The row-limit NDM stayed at 41 DRCs; split-via edits either worsened DRC/open nets or were undone by repair; extra route_detail iterations changed the saved candidate from 20 DRCs to 21 DRCs.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via12sqc_row1_route_flow/06_route/check_routes.rpt reports 41 DRCs. 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_cleanup_saved/summary.tsv, probe_split_offgrid_via1_array_repair_cleanup_saved/summary.tsv, and probe_split_offgrid_via1_array_x_cleanup_saved/summary.tsv show the rejected split-via outcomes. 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_iter50_saved/summary.tsv shows the rejected 21-DRC extended cleanup result.
Then-current best artifact: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib, with 0 open nets and 20 signal DRCs = Off-grid 19, Short 1. This has since been superseded by the 19-DRC NOR2-policy cleanup candidate.
Next policy: stop spending runs on broad route iteration/direct VIA object ECOs for this symptom. Move to physical abstract/TF via-rule consistency review for VIA12SQ_C and lower-metal pin-access geometry, then rerun from a clean backend library if a PDK-consistent fix is identified.
```

```text
Decision: reject via_array_off_fat_contact as a route-option fix and treat libdir LEF adoption as a provenance-gated physical-abstract change.
Reason: combining via_array_mode=off with high fat-contact/wire-via route effort keeps open nets at 0 and removes Off-grid, but the total DRC remains 20 by trading into Needs fat contact 9 and Short 11. Also, libdir/LEF and libdir/LEF/modify are identical for RVT/LVT/HVT, so the useful change is not a private modify-folder patch; it is the difference between libdir LEFs and original SAED32_EDK LEFs.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv reports 20 DRCs, open nets 0, Off-grid 0, Needs fat contact 9, Short 11. Local LEF comparison shows only OR2X1/OR2X4 RVT/LVT/HVT sizes changed versus SAED32_EDK, with associated lower-metal pin/OBS/PG geometry edits; libdir/LEF and libdir/LEF/modify compare identical.
Next policy: do not promote libdir/modified-LEF NDMs silently. If adopted, record the physical-abstract source and rerun backend from a clean library. Continue residual closure by reviewing OR2 physical abstracts and VIA12SQ_C/via-array rule consistency rather than stacking more route-option probes.
```

```text
Decision: reject post-route NOR2 resize ECO; keep NOR2 cell-use changes as an upstream clean-rerun option only.
Reason: residual Off-grid context points to NOR2X0_HVT/NOR2X2_HVT A1/VSS pin-access areas, but resizing those 19 nearby instances to NOR2X4_HVT after route broke connectivity and worsened final DRC. A post-route cell resize is too disruptive for this block.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_offgrid_context/offgrid_context.tsv maps residual context to NOR2 A1/VSS locations. 4_Backend_ICC2/4_Report/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved/summary.tsv reports final 43 DRCs and 19 open nets after the NOR2X4_HVT resize probe.
Next policy: do not use late NOR2 resize ECO for this baseline. If this axis is pursued, apply it as synthesis/cell-use policy or placement/pin-access policy and rerun backend from a clean library, then compare against the current best artifact.
```

```text
Decision: reject NOR2X0_HVT/NOR2X2_HVT dont_use as a standalone route DRC fix.
Reason: the clean upstream rerun removed the suspected NOR2 cells from the netlist, but final route DRC worsened versus the current best saved cleanup candidate. The policy also increased area/instance pressure enough that the backend result did not improve.
Evidence: 2_Synthesis/4_Report/99_debug/pre_backend_topo_nor2_no_x0x2_hvt/nor2_dont_use_verify.rpt reports NOR2X0_HVT and NOR2X2_HVT dont_use=true, and the mapped Verilog has 0 references to those cells. 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow/06_route/check_routes.rpt reports 0 open nets and 36 DRCs = Diff net spacing 2, Off-grid 34. The saved modified-LEF cleanup candidate remains better at 20 DRCs = Off-grid 19, Short 1.
Next policy: do not promote this DC cell-use policy. Continue with physical abstract/TF via-rule consistency review around VIA12SQ_C and lower-metal pin-access, or test placement/pin-access policies that do not simply remove the cells.
```

```text
Decision: keep the NOR2-policy cleanup result as the current best debug waypoint, not a production baseline.
Reason: cleanup after the NOR2-policy backend rerun reduces residual route DRC below the previous best artifact, but the remaining DRCs are still real signal-route violations and follow-up probes only trade DRC classes.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved/summary.tsv reports 0 open nets and 19 DRCs = Diff net spacing 2, Off-grid 17. 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_drc_inspect/drc_matrix.rpt confirms the residual matrix. 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_nor2_policy_cleanup_saved/summary.tsv, probe_shrink_offgrid_via1_array_repair_nor2_policy_cleanup_saved/summary.tsv, and modified_lef_nor2_policy_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv all remain at 19 DRCs after class tradeoffs.
Current best artifact: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib.
Next policy: do not claim DRC clean. Shift from direct route/ECO probes to PDK-consistent contact-code/via-rule and M1-M2 pin-access review, or run a clean placement/pin-access policy experiment with this 19-DRC result as the comparison point.
```

```text
Decision: reject PG_M2_OFFSET=25.0 as a route DRC fix.
Reason: the probe reduces/changes signal DRC shape but breaks PG quality. Signal check_routes reports 32 all-Offgrid DRCs with open nets 0, while check_pg_drc reports 640 PG errors.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow/06_route/check_routes.rpt and pg_drc.rpt.
Next policy: do not use naive PG mesh offset. If PG offset is revisited, the fixed rail-stitch coordinates and PG strategy must be moved coherently and rerun from a clean backend library.
```

```text
Decision: supersede the 19-DRC NOR2-policy cleanup waypoint with the 18-DRC diff-net blockage waypoint.
Reason: a small M2 signal blockage around the reset-net/VSS spacing location removes Diff net spacing 2 and keeps open nets 0, legality clean, PG clean, and timing positive. It introduces one M1 Short, so it is only a better debug waypoint, not a clean route.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/summary.tsv reports after_total=18, after_open_nets=0, after_diff_net_spacing=0, after_off_grid=17, after_short=1. check_legality.rpt reports TOTAL 0; pg_connectivity.rpt has floating objects 0; pg_drc.rpt reports no errors; timing.max/min reports MET.
Current best artifact: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib.
Next policy: continue diagnosing from the 18-DRC saved candidate, but do not promote to production or claim DRC clean.
```

```text
Decision: reject additional M1 blockage and Off-grid remove+route_eco probes on the 18-DRC candidate.
Reason: the added M1 blockage removes the single Short but reintroduces Diff net spacing and worsens total DRC to 21. Removing Off-grid VIA1 objects proves they drive the Off-grid count to 0 only by creating 15 open nets; route_eco reconnects those nets but regenerates the same 18 DRCs.
Evidence: 4_Backend_ICC2/4_Report/99_debug/probe_short_m1_blockage_on_diff_m2_saved/summary.tsv reports after_total=21, after_diff_net_spacing=3, after_off_grid=18, after_short=0. 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_route_eco_diff_m2_blockage_saved/summary.tsv reports before 18/open0, after_remove 1 DRC/open15, after_eco 18/open0 with Off-grid 17 and Short 1.
Next policy: stop object-level via/blockage ECOs for this symptom unless a new local root cause is proven. Focus next on PDK-consistent lower-metal via/contact-code and pin-access rule consistency.
```

```text
Decision: reject Off-grid bbox M2 blockage ECO as a closure fix.
Reason: adding small M2 signal blockages at every residual Off-grid bbox removes Off-grid 17, but the reroute produces Short 18, leaving total DRC unchanged at 18.
Evidence: 4_Backend_ICC2/4_Report/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved/summary.tsv reports after_total=18, after_open_nets=0, after_off_grid=0, after_short=18.
Next policy: do not stack more coordinate-only blockages on this artifact. Treat the remaining DRC as lower-metal pin-access/contact legality coupled to stdcell abstracts and routing tracks.
```

```text
Decision: reject direct PDK/ORCA reference techfile substitution for modified-LEF NDM generation.
Reason: both alternate techfiles fail Library Manager create_workspace before NDM commit; they are not drop-in replacements for the current W-2024.09-SP2 NDM build flow.
Evidence: 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_pdk_tf_ndm.log reports TECH-006 at line 356 and LIB-007. 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_orca_tf_ndm.log reports TECH-006 at line 405 and LIB-007.
Next policy: keep the current SAED32_EDK techfile for runnable backend probes unless a compatible techfile cleanup/import path is created and separately verified.
```

```text
Decision: reject CORE_UTILIZATION=0.55 clean backend rerun as a route DRC fix.
Reason: a clean rerun with lower floorplan utilization worsened signal DRC versus the current 18-DRC best artifact and introduced a VSS PG connectivity regression.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_u055_route_flow/06_route/check_routes.rpt reports 0 open nets and 36 DRCs = Diff net spacing 2, Off-grid 34. check_legality.rpt reports TOTAL 0. pg_connectivity.rpt reports VSS floating wires 1 and floating std cells 307. pg_drc.rpt reports no errors. timing.max.rpt reports slack MET 0.77 ns; timing.min.rpt reports slack MET 0.03 ns.
Current best artifact remains: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib, with 0 open nets and 18 signal DRCs = Off-grid 17, Short 1.
Next policy: do not use die/core enlargement alone as the next closure path. Continue with lower-metal physical abstract/contact-code/pin-access consistency review, or use any future placement experiment only if it also preserves PG stitch/connectivity assumptions.
```

```text
Decision: reject VIA1 pitch-only techfile patch as a route DRC fix.
Reason: enabling VIA1 pitch = 0.36 in a project-local copy of the current SAED32_EDK techfile built usable NDMs, but the clean NOR2-policy backend rerun still ended at 36 signal DRCs. This is worse than the 18-DRC diff-net blockage saved artifact and does not support missing VIA1 pitch as a standalone root cause.
Evidence: 4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_ndm.log shows the NDM build completed and reports TECH-025 for VIA1 onGrid/onWireTrack coexistence. 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow/06_route/check_routes.rpt reports 0 open nets and 36 DRCs = Diff net spacing 2, Off-grid 34. check_legality.rpt reports TOTAL 0; pg_connectivity.rpt reports VDD/VSS floating objects 0; pg_drc.rpt reports no errors; timing.max/min reports MET 0.77 ns / 0.04 ns.
Current best artifact remains: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib, with 0 open nets and 18 signal DRCs = Off-grid 17, Short 1.
Next policy: treat the VIA1 pitch/onGrid/onWireTrack interaction as an input clue, not a fix. Continue physical abstract/contact-code review or a targeted placement/pin-access policy experiment against the 18-DRC comparison point.
```

```text
Decision: keep the VIA1 pitch/no-track NDM as the active debug route-closure direction, not an automatic production library change.
Reason: enabling VIA1 pitch = 0.36 while removing VIA1 onGrid/onWireTrack from a project-local techfile copy eliminates the TECH-025 conflict and materially improves the clean backend route. The NOR2-policy route improved from the 18-DRC best artifact to 1 Off-grid/open0. However, removing onGrid/onWireTrack is a technology-rule interpretation change and must be explicitly accepted before production promotion.
Evidence: 4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_no_track_ndm.log shows workspace checks and NDM writes completed without TECH-025/TECH-006/LIB-007/Fatal. 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow/06_route/check_routes.rpt reports 0 open nets and 1 signal DRC = Off-grid 1. Legality, PG connectivity, PG DRC, and timing sanity reports are acceptable for debug.
Next policy: use this NDM only in debug wrappers until the VIA1 no-track techfile policy is reviewed and recorded as acceptable for the baseline.
```

```text
Decision: do not use post-route U6629 MUX resize as the final one-DRC fix.
Reason: the remaining Off-grid in the no-track NOR2-policy route is localized near U6629/MUX41X2_HVT/S0, but resizing U6629 to MUX41X1_HVT after route clears Off-grid by breaking routing quality and connectivity.
Evidence: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_drc_context/context.tsv identifies net n55676 near U6629/MUX41X2_HVT/S0. 4_Backend_ICC2/4_Report/99_debug/probe_resize_mux41x2_u6629_to_x1/summary.tsv reports final 14 DRC and 6 open nets after the resize probe.
Next policy: if MUX41X2_HVT is the issue, handle it upstream as synthesis cell-use policy and rerun backend from a clean library.
```

```text
Decision: create a debug DRC-clean candidate by combining VIA1 pitch/no-track NDM with upstream NOR2X0_HVT/NOR2X2_HVT/MUX41X2_HVT dont_use.
Reason: the one remaining Off-grid was tied to MUX41X2_HVT/S0 pin access. Removing MUX41X2_HVT upstream and rerunning clean backend with the no-track NDM produces a saved route block with 0 open nets and 0 signal DRC.
Evidence: 2_Synthesis/4_Report/99_debug/pre_backend_topo_nor2_mux41_no_x0x2_hvt/nor2_dont_use_verify.rpt reports all three cells dont_use=true; the mapped Verilog has 0 NOR2X0_HVT/NOR2X2_HVT/MUX41X2_HVT references and 126 MUX41X1_HVT references. 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/06_route/check_routes.rpt reports 0 open nets and 0 signal DRC. check_legality.rpt reports TOTAL 0; pg_connectivity.rpt reports VDD/VSS floating objects 0; route log/check_pg_drc reports No errors found; timing.max/min reports MET 0.78 ns / 0.04 ns.
Current best debug artifact: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_icc2_lib.
Promotion caveat: this is not yet the production baseline. Antenna checking is not active because no antenna rules are defined. Production promotion requires accepting the VIA1 no-track library policy and moving the selected wrapper/report paths out of 99_debug.
```

```text
Decision: treat the NOR2+MUX41 debug synthesis handoff as logically proven by Formality R2N.
Reason: the new DC cell-use policy handoff needed an equivalence check before any production promotion. Formality R2N using the matching DDC/SVF passed with the same compare-point count as the official baseline and no rejected SVF guidance.
Evidence: 3_Formality/3_Log/fm_r2n_topo.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log reports Verification SUCCEEDED, 34915 passing compare points, 0 failing compare points, 0 unmatched reference/implementation compare points, and SVF guidance total 2146 accepted / 0 rejected, including hier_map 33 accepted / 0 rejected.
Scope: this resolves the logic-equivalence promotion gate for the NOR2+MUX41 handoff. The remaining promotion decision is the VIA1 no-track techfile/library policy.
```

```text
Decision: accept the VIA1 pitch/no-track techfile policy for project baseline promotion.
Reason: the DRC-clean route candidate depends on a project-local VIA1 techfile interpretation. The project owner explicitly accepted that policy on 2026-05-10, so the library-governance blocker is removed.
Accepted policy: use /DATA/home/edu135/lib/libdir/LEF/modify physical abstracts and the project-local VIA1 techfile patch that enables pitch = 0.36 while removing VIA1 onGrid/onWireTrack.
Evidence: docs/backend_library_policy.md records the exact techfile delta, NDM build evidence, route/FM evidence, and remaining claim boundary. docs/ibex_backend_route_closure_case_study.md records the 720-to-0 DRC closure path.
Remaining work: promote or explicitly alias the selected 99_debug wrapper/manifest path as the baseline backend flow. This approval does not create antenna, LVS, IR/EM, ATPG, or silicon signoff evidence.
```
