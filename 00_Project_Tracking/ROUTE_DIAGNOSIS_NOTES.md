# Route Diagnosis Notes

## Repro Loop

```text
Script: 4_Backend_ICC2/0_Script/06_route/run_route_initial.sh
Primary log: 4_Backend_ICC2/3_Log/06_route/run_route_initial.log
Primary pass/fail reports:
- 4_Backend_ICC2/4_Report/06_route/check_routes.rpt
- 4_Backend_ICC2/4_Report/06_route/pg_connectivity.rpt
- 4_Backend_ICC2/4_Report/06_route/pg_drc.rpt
- 4_Backend_ICC2/4_Report/06_route/timing.max.rpt
- 4_Backend_ICC2/4_Report/06_route/timing.min.rpt
```

## Current Route Result

```text
Status: ROUTED_WITH_OPEN_SIGNAL_DRC
Open nets: 0
Legality: TOTAL 0 violations
PG connectivity: VDD/VSS floating objects 0
PG DRC: no errors
Timing: max slack MET 0.57 ns; min slack MET 0.03 ns
Signal route DRC: 720
```

## Residual Signal DRC Breakdown

```text
Report: 4_Backend_ICC2/4_Report/06_route/check_routes.rpt

Total DRCs: 720
- Diff net spacing: 251
- Less than minimum area: 24
- Needs fat contact: 347
- Off-grid: 92
- Short: 6
```

## Initial Classification

```text
This is no longer the PG floating-rail issue. The PG issue is fixed through route.

The route DRC pattern is dominated by signal routing/via/contact rules:
- Needs fat contact is the largest class.
- Off-grid is present before route as 43 off-track M1 pins in check_routability.
- Diff-net spacing and short violations indicate route closure/congestion remains.

The design is connected and timing-positive, but it is not route-DRC clean.
```

## Candidate Next Experiments

```text
H1: Current route layer/track setup overuses low metal and pin-access regions.
Prediction: a route variant that changes routing layer policy or route options reduces M1/off-grid/fat-contact classes without reintroducing opens.

H2: SAED32 route technology/contact setup is incomplete for fat-contact handling.
Prediction: enabling or correcting via/contact/fat-contact routing options reduces Needs fat contact while other DRC classes remain similar.

H3: Utilization/congestion is too high for this stdcell-memory SoC with current PG mesh and M1-heavy pins.
Prediction: rerunning from floorplan/place with lower utilization reduces spacing/short DRCs more than route-only option changes.

H4: Some DRCs are library pin-access artifacts.
Prediction: DRC locations cluster around the off-track M1 pins reported by check_routability and specific problematic cells such as MUX41X2_HVT/S0.
```

## 2026-05-10 DRC Error Data Inspection

```text
Skill workflow: diagnose
Script: 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
Log: 4_Backend_ICC2/3_Log/99_debug/inspect_route_drc.log
Reports: 4_Backend_ICC2/4_Report/99_debug/route_drc_inspect/
Result: PASS_WITH_NOTE
```

```text
Detailed matrix report: 4_Backend_ICC2/4_Report/99_debug/route_drc_inspect/drc_matrix.rpt

All 720 signal DRCs are on M1/M2/VIA1:
- M1: 263 total = Diff net spacing 251, Off-grid 7, Short 5
- M1-M2: 347 total = Needs fat contact 347
- M2: 67 total = Less than minimum area 24, Off-grid 42, Short 1
- VIA1: 43 total = Off-grid 43

Interpretation:
- The route DRC problem is strongly localized to pin-access/lower-metal routing, not PG.
- Needs fat contact is entirely M1-M2.
- Off-grid is split across M1/M2/VIA1 and is consistent with check_routability's 43 off-track M1 pin warnings.
- Logs repeatedly warn: "Cannot find a default contact code for layer CO" and "Standard cell pin MUX41X2_HVT/S0 has no valid via regions."
```

## 2026-05-10 Route-Only Variant Probes

```text
Script: 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Status: ABORTED_AFTER_DIAGNOSTIC_SIGNAL
Policy: debug-only; no save_block/save_lib; production ICC2 block not modified.
```

```text
Variant: detail_extra
Command: ROUTE_DRC_VARIANT=detail_extra 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Log: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.detail_extra.log
Observation: additional detail routing lowered DRC from 720 to roughly the 660-680 range but then oscillated; iteration 46 summary was 671 total DRCs.
Result: rejected as sufficient fix. More detail-route iteration alone is not closing the issue.
```

```text
Variant: reroute_m2
Command: ROUTE_DRC_VARIANT=reroute_m2 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Log: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.reroute_m2.log
Observation: after removing signal/clock detail routes and rerouting with min routing layer M2, detail-route iteration 0 grew above 11000 DRCs before the run was stopped.
Result: rejected. Simply blocking M1 for signal route makes pin-access/congestion much worse.
```

```text
Variant: fat_contact_effort
Command: ROUTE_DRC_VARIANT=fat_contact_effort 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Log: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.fat_contact_effort.log
Option report: 4_Backend_ICC2/4_Report/99_debug/route_drc_variants/fat_contact_effort/app_options.after.rpt
Options tested: route.detail.fat_metal_forbidden_pitch_effort_level=high and route.detail.optimize_wire_via_effort_level=high.
Observation: Needs fat contact improved during some iterations, with a best observed value of 239 at iteration 43, but Diff net spacing increased as high as 361 and total DRC stayed around 660-672.
Result: useful diagnostic signal, but rejected as a standalone production fix. The option changes the right class but trades it for spacing DRC.
Note: the probe was stopped after enough diagnostic signal; production block was not saved.
```

## Updated Hypothesis Ranking

```text
H1: Lower-metal pin access/contact setup is the primary route DRC driver.
Prediction: via/contact/via-array/via-ladder options or corrected physical abstracts reduce Needs fat contact and VIA1/M1/M2 off-grid classes without a large open-net increase.
Status: supported. fat_contact_effort reduced Needs fat contact but did not close total DRC because spacing DRC increased.

H2: More detail-route iteration alone is insufficient.
Prediction: extra iterations reduce DRC only marginally and then oscillate.
Status: supported by detail_extra probe.

H3: M1 cannot simply be avoided for this stdcell design.
Prediction: min-routing-layer M2 reroute worsens DRC or pin access.
Status: supported by reroute_m2 probe.

H4: Modified LEF may affect route DRC, but prior PG probe does not justify switching production baseline yet.
Prediction: a full modified-LEF route probe could change M1/M2/VIA1 DRC distribution, but it must be measured separately.
Status: unresolved; physical-only backend experiment, no DC/FM rerun required if logical DBs are unchanged.

H5: Utilization/congestion may still contribute, but it is secondary until pin-access/contact setup is tested.
Prediction: lower utilization reduces spacing/short DRCs, but may not resolve Needs fat contact if via/contact setup remains wrong.
Status: still plausible. fat_contact_effort reduced contact violations while raising spacing violations, which suggests local congestion/pin access may interact with the contact rule.
```

## 2026-05-10 Modified-LEF Full Route Probe

```text
Skill workflow: diagnose
Script: 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Status: COMPLETE_WITH_RESIDUAL_SIGNAL_DRC
Policy: debug-only separate ICC2 library/report tree; production ICC2 library and reports were not overwritten.
Modified NDM inputs: 4_Backend_ICC2/2_Output/99_debug/modified_lef_pg_probe/ndm/saed32{rvt,lvt,hvt}_tt_modified.ndm
ICC2 library output: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_route_flow
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow
```

```text
Command:
4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh

Wrapper result:
MOD_LEF_ROUTE_FLOW DONE
```

```text
Final route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/check_routes.rpt
Route log: 4_Backend_ICC2/3_Log/99_debug/modified_lef_route_flow/06_route.log

Result:
- Total number of open nets = 0
- Total number of DRCs = 41
- Diff net spacing = 1
- Off-grid = 39
- Short = 1
- Needs fat contact = 0 observed in final route report
- Less than minimum area = 0 observed in final route report
```

```text
Comparison to production original-LEF route:
- Original production route: 720 DRCs = Diff net spacing 251, Less than minimum area 24, Needs fat contact 347, Off-grid 92, Short 6.
- Modified-LEF debug route: 41 DRCs = Diff net spacing 1, Off-grid 39, Short 1.

Interpretation:
- The modified physical abstract/NDM materially improves lower-metal route DRC.
- The old dominant class, M1-M2 Needs fat contact, disappears in this debug route.
- Residual DRC is now mostly Off-grid, so the next debug target changes from fat-contact handling to residual off-grid/pin-access legality.
```

```text
Sanity checks:
- Legality report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/check_legality.rpt reports TOTAL 0 Violations.
- PG connectivity report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/pg_connectivity.rpt reports VDD/VSS floating wires/vias/std cells/terminals all 0.
- PG DRC command evidence: 4_Backend_ICC2/3_Log/99_debug/modified_lef_route_flow/06_route.log reports No errors found after check_pg_drc; 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/pg_drc.rpt was generated.
- Timing max report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/timing.max.rpt worst reported slack MET 0.74 ns.
- Timing min report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/timing.min.rpt worst reported slack MET 0.04 ns.
```

```text
Known caveats:
- This is still not route DRC clean because 41 signal DRCs remain.
- Route log still warns: Cannot find a default contact code for layer CO.
- Route log still warns: Standard cell pin MUX41X2_HVT/S0 has no valid via regions.
- Route log warns that top VDD/VSS ports are unplaced/no-pin ports, although PG connectivity is clean by report.
- QoR report still shows design-rule timing constraints: Max Trans Violations 19 and Max Cap Violations 269.
```

## Updated Hypothesis Ranking After Modified-LEF Route

```text
H1: Modified physical abstracts/NDM are material to lower-metal route DRC.
Status: strongly supported. The full debug route lowered signal DRC from 720 to 41 and eliminated the Needs fat contact class.

H2: Residual off-grid/pin-access issues remain even with the modified LEF.
Status: supported. Final DRC is dominated by 39 Off-grid violations plus 1 Short and 1 Diff net spacing.

H3: Front-end/DC/FM rerun is not required for this experiment.
Status: supported for debug scope because the experiment changed backend physical abstracts/NDM only and reused the same DC topo handoff. Production adoption must still document LEF provenance and rerun the backend from init.

H4: Promote modified-LEF NDM directly to production.
Status: not accepted yet. The result is a strong candidate direction, but residual signal DRC remains and LEF provenance must be documented before production baseline switch.
```

## 2026-05-10 Modified-LEF Residual DRC Inspection

```text
Script: 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
Tcl: 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.tcl
Command:
env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib ROUTE_DRC_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
Status: PASS_WITH_NOTE
Policy: report-only; no save_block/save_lib executed.
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect
Log: 4_Backend_ICC2/3_Log/99_debug/inspect_route_drc.log
```

```text
Matrix report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect/drc_matrix.rpt

Residual DRC matrix:
- M1: 3 total = Diff net spacing 1, Off-grid 1, Short 1
- M2: 19 total = Off-grid 19
- VIA1: 19 total = Off-grid 19
- Total: 41
```

```text
Detailed samples:
- Off-grid samples: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect/sample_Off-grid.rpt
- Short sample: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect/sample_Short.rpt
- Diff net spacing sample: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect/sample_Diff_net_spacing.rpt

Observation:
- Most Off-grid entries are paired M2/VIA1 errors at nearly identical coordinates, consistent with residual off-grid via placement rather than broad route congestion.
- The lone Short is on M1 at bbox {781.5210 372.5650} {781.6710 372.7150}.
- The lone Diff net spacing error is on M1 at bbox {800.4920 464.8960} {800.6890 464.9790}.
```

```text
Next target:
Inspect or fix residual off-grid M2/VIA1 placements in the modified-LEF block. Candidate directions are a small route-detail/off-grid cleanup pass, via snapping/via-rule setup review, or localized DRC repair around the sampled coordinates. Do not return to broad route-option sweeps until these residual locations are understood.
```

## 2026-05-10 Modified-LEF Residual Cleanup Probe

```text
Variant: detail_extra on modified-LEF routed block
Command:
env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib ROUTE_DRC_VARIANT=detail_extra ROUTE_DRC_VARIANT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Status: PASS_WITH_NOTE
Policy: debug-only in-memory probe; no save_block/save_lib executed.
Log: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.modified_lef_detail_extra.log
Report directory: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra/summary.tsv
```

```text
Before:
- Open nets = 0
- Total DRC = 41
- Diff net spacing = 1
- Off-grid = 39
- Short = 1

After:
- Open nets = 0
- Total DRC = 20
- Off-grid = 19
- Short = 1
```

```text
Interpretation:
- Incremental detail routing is useful after the modified-LEF NDM route, unlike the original-LEF baseline where route-only effort plateaued around 660-680 DRCs.
- The remaining issue is now very narrow: 19 Off-grid and 1 Short.
- A saved debug candidate was later created from this cleanup sequence. A production candidate flow would still need to rerun/save the selected modified-LEF route sequence and recheck legality, PG, timing, antenna, and route DRC before promotion.
```

## 2026-05-10 Saved Modified-LEF Cleanup Candidate

```text
Script: 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
Tcl: 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.tcl
Source ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved/summary.tsv
Status: SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC
```

```text
Before cleanup:
- Open nets = 0
- Total DRC = 41
- Diff net spacing = 1
- Off-grid = 39
- Short = 1

After saved cleanup:
- Open nets = 0
- Total DRC = 20
- Off-grid = 19
- Short = 1
- Legality = TOTAL 0 violations
- PG connectivity = VDD/VSS floating objects 0
- PG DRC = route log check_pg_drc reports No errors found
- Timing max slack = MET 0.74 ns
- Timing min slack = MET 0.04 ns
```

```text
Residual inspection command:
env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib ROUTE_DRC_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect ROUTE_DRC_INSPECT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_route_drc.modified_lef_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh

Residual matrix: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect/drc_matrix.rpt
- VIA1: Off-grid 19
- M1: Short 1
```

## 2026-05-10 Residual VIA1 Off-Grid Diagnosis

```text
Inspector evidence:
4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect/offgrid_via_attrs.tsv

Finding:
- All 19 residual Off-grid DRCs map to router-generated M1-M2 vias.
- Via objects are VIA_SA_157xx instances with via_def VIA12SQ_C.
- Each has array_size 2 1, number_of_rows 2, number_of_columns 1.
- Via origins are on the M1/M2 route track grid, so the issue is not via-center track snapping.

Interpretation:
Residual Off-grid is caused by the generated VIA12SQ_C 2-row array/cut geometry, not a broad routing-grid offset.
```

```text
Rejected probes:

1. Remove off-grid vias by net+bbox
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_by_net_bbox_cleanup_saved/summary.tsv
   Result: removed 19 vias; Off-grid 0 and Short 1 remain, but open nets increase to 14.
   Rejected because the vias are required connectivity.

2. Remove off-grid vias then route_detail repair
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_repair_cleanup_saved/summary.tsv
   Result: open nets remain 14; Off-grid 0 and Short 1 remain.
   Rejected because route_detail did not reconnect the removed VIA1 connectivity.

3. Shrink 2x1 VIA12SQ_C arrays to 1x1
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_cleanup_saved/summary.tsv
   Result: Off-grid 0, but open nets 1 and DRC remains 20 due to Less than minimum area 1, Needs fat contact 18, Short 1.
   Rejected because it trades Off-grid for fat-contact/min-area and opens one net.

4. Shrink then route_detail repair
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_repair_cleanup_saved/summary.tsv
   Result: same open net remains: u_ibex_top_u_ibex_core_if_stage_i_gen_prefetch_buffer_prefetch_buffer_i_fifo_busy[1]; DRC remains 20.
   Rejected because repair did not close the open or DRC tradeoff.

5. Replace with explicit VIA12SQ_C_1x2 via_def
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_replace_offgrid_via1_def_VIA12SQ_C_1x2_cleanup_saved/summary.tsv
   Result: ICC2 reports Cannot find via definition VIA12SQ_C_1x2; replacement is not a legal direct via_def.
   Rejected.

6. route.common.via_array_mode=off
   Report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_cleanup_saved/summary.tsv
   Result: open nets 0 and Off-grid 0, but DRC remains 20 with Needs fat contact 9 and Short 11.
   Rejected because it trades Off-grid for fat-contact/short DRC.

7. route.common.via_on_grid_by_layer_name={{VIA1 true}}
   Report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via1_on_grid_cleanup_saved/summary.tsv
   Result: unchanged, 20 DRC = Off-grid 19 and Short 1.
   Rejected as ineffective.

8. route.auto_via_ladder cleanup/check/connect options
   Report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_ladder_clean_cleanup_saved/summary.tsv
   Result: unchanged, 20 DRC = Off-grid 19 and Short 1.
   Rejected as ineffective.

9. route.common.extra_via_off_grid_cost_multiplier_by_layer_name={{VIA1 20}}
   Report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via1_offgrid_cost20_cleanup_saved/summary.tsv
   Result: unchanged, 20 DRC = Off-grid 19 and Short 1.
   Rejected as ineffective. A previous 1000 value attempt failed because ICC2 limits the multiplier to <=20.
```

## 2026-05-10 Residual M1 Short Diagnosis

```text
Inspector:
Script: 4_Backend_ICC2/0_Script/99_debug/inspect_short_area.sh
Report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_short_inspect/short_area_objects.tsv
Log: 4_Backend_ICC2/3_Log/99_debug/inspect_short_area.modified_lef_cleanup_saved.log

Finding:
- Short bbox: {781.5210 372.5650} {781.6710 372.7150}
- DRC object resolves to net n48420.
- Nearby objects include n48420 M1 detail route PATH_11_18238 and VSS M1 lib_cell_pin_connect rail PATH_11_211.
```

```text
Rejected short probes:

1. Targeted route_eco on n48420
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_short_net_eco_n48420_cleanup_saved/summary.tsv
   Result: unchanged, 20 DRC = Off-grid 19 and Short 1.
   Rejected as ineffective.

2. Remove n48420 detail routes then route_eco
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_short_net_remove_detail_eco_n48420_cleanup_saved/summary.tsv
   Result: unchanged, 20 DRC = Off-grid 19 and Short 1.
   Rejected as ineffective.
```

```text
Current conclusion:
The saved modified-LEF cleanup candidate is the best backend artifact so far, but it is still not DRC clean.
Remaining route DRC does not respond to ordinary detail_route, route_eco, via_on_grid, via_ladder cleanup, or via off-grid cost options.
The next useful work is library/NDM rule review for VIA12SQ_C 2-row array legality and M1 rail/pin-access geometry, or a controlled backend rerun with a corrected physical abstract/via rule setup.
```

## 2026-05-10 Residual DRC Follow-up Probes

```text
1. Project-local VIA12SQ_C row-limit tech/NDM variant
   NDM build script: 4_Backend_ICC2/0_Script/99_debug/build_via12sqc_row1_ndm.sh
   Generated tech file: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via12sqc_row1/tech/saed32nm_1p9m_mw.via12sqc_row1.tf
   Route script: 4_Backend_ICC2/0_Script/99_debug/run_via12sqc_row1_route_flow.sh
   Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via12sqc_row1_route_flow/06_route/check_routes.rpt
   Result: full backend route completed with 0 open nets, legality TOTAL 0, PG connectivity clean, PG DRC no errors, timing.max slack MET 0.74 ns, timing.min slack MET 0.04 ns, but signal DRC remained 41 = Diff net spacing 1, Off-grid 39, Short 1.
   Rejected because it did not improve over the existing modified-LEF full route, and it is worse than the saved cleanup candidate at 20 DRC.

2. VIA definition availability inspection
   Script: 4_Backend_ICC2/0_Script/99_debug/inspect_via_defs.sh
   Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_via_def_inspect2
   Result: routed via objects report via_def_name VIA12SQ_C, but get_via_defs direct queries for VIA12SQ_C and generated-looking names such as VIA12SQ_C_1x2/VIA12SQ_C_2x1 return 0. Treat these route-report names as router-generated/contact-code forms, not directly reusable replacement via_defs through get_via_defs.

3. Split residual 2x1 Off-grid VIA12SQ_C arrays into two single VIA12SQ_C vias along y
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_cleanup_saved/summary.tsv
   Result: 20 DRC worsened to 115 DRC with Off-grid 57, Needs fat contact 37, Same net spacing 19, Less than minimum area 1, Short 1.
   Repair report: 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_repair_cleanup_saved/summary.tsv
   Repair result: route_detail restored the original 20 DRC = Off-grid 19, Short 1.
   Rejected because it is not a stable improvement.

4. Split residual 2x1 Off-grid VIA12SQ_C arrays into two single VIA12SQ_C vias along x
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_x_cleanup_saved/summary.tsv
   Result: 20 DRC worsened to 167 DRC and created 10 open nets.
   Rejected because it breaks connectivity and DRC.

5. Extended cleanup on copied best candidate
   Script: 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
   Source lib: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib
   Saved lib: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_iter50_saved/ibex_mini_soc_top_modified_lef_cleanup_iter50_icc2_lib
   Report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_iter50_saved/summary.tsv
   Result: after start_iter=50 max_iter=50 cleanup, DRC changed from 20 to 21: Diff net spacing 1, Off-grid 20, Short 0, open nets 0.
   Rejected because it worsens total DRC and off-grid count despite removing the short.

6. Combine via_array_mode=off with high fat-contact/wire-via effort
   Script: 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
   Variant: via_array_off_fat_contact
   Report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv
   Result: total DRC stayed 20 with open nets 0; Off-grid became 0, but violations traded into Needs fat contact 9 and Short 11.
   Rejected because route option combination still trades DRC class instead of producing a clean connected route.
```

```text
Updated conclusion:
At this point in the diagnosis, the best artifact was 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib with 20 DRC = Off-grid 19, Short 1 and 0 open nets. This was later superseded by the NOR2-policy cleanup candidate at 19 DRC/open0.
The row-limit NDM, split-via ECOs, and longer cleanup do not close the remaining DRC.
The via_array_off_fat_contact combination confirms the same tradeoff: Off-grid can be removed, but the design falls back into fat-contact/short DRC.
The likely remaining root cause is a mismatch between SAED32 TF contact-code/via-array legality and the libdir physical abstracts around lower-metal pin access, not a simple route iteration or direct ECO problem.
```

## 2026-05-10 LEF Provenance Check

```text
Finding:
- /DATA/home/edu135/lib/libdir/LEF and /DATA/home/edu135/lib/libdir/LEF/modify are identical for RVT/LVT/HVT stdcell LEFs.
- The route DRC improvement therefore comes from using libdir LEFs instead of the original SAED32_EDK LEFs, not from an additional difference inside libdir/LEF/modify.

Observed stdcell LEF differences versus SAED32_EDK:
- OR2X1_RVT/LVT/HVT size changes from 1.216 x 1.672 to 1.368 x 1.672.
- OR2X4_RVT/LVT/HVT size changes from 1.672 x 1.672 to 1.368 x 1.672.
- The same macros have changed M1 pin/OBS/PG rail/contact geometry.

Interpretation:
The libdir abstracts materially change OR2 lower-metal pin access and cell widths. This explains why the modified-LEF NDM strongly changes route DRC. It also raises a production-adoption risk: logical timing .db cells were not changed, so any LEF adoption must be treated as a physical-abstract provenance decision and rerun through backend from a clean library before promotion.
```

## 2026-05-10 Off-grid Context and NOR2 ECO Probe

```text
Inspector:
Script: 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.sh
Report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_offgrid_context/offgrid_context.tsv
Log: 4_Backend_ICC2/3_Log/99_debug/inspect_offgrid_context.modified_lef_cleanup_saved.log

Finding:
- Residual Off-grid locations are consistently near NOR2 A1/VSS pin-access context.
- A1 pin instances from the 19 locations map to NOR2X0_HVT or NOR2X2_HVT in 2_Synthesis/2_Output/pre_backend_topo/ibex_mini_soc_top.pre_backend_topo.vg.
- NOR2X0_HVT and NOR2X2_HVT LEF macros are identical between original SAED32_EDK and libdir LEFs.

Interpretation:
The remaining Off-grid behavior is a lower-metal NOR2 pin-access/via-array issue exposed in dense placement after the libdir LEFs remove the larger OR2-related DRC population. It is not fixed by editing OR2 abstracts alone.
```

```text
Rejected NOR2 ECO probe:
Script: 4_Backend_ICC2/0_Script/99_debug/probe_resize_offgrid_nor2.sh
Target: resize the 19 nearby NOR2X0_HVT/NOR2X2_HVT cells to NOR2X4_HVT, then incremental legalize and route_detail.
Report: 4_Backend_ICC2/4_Report/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved/summary.tsv
Result: final check_routes worsened from 20 DRC/open0 to 43 DRC/open19. Transient route_detail DRC reached 17, but the final block is disconnected and not usable.
Conclusion: post-route direct NOR2 resize is rejected. If NOR2 cell choice is pursued, it should be done upstream through synthesis/cell-use policy and a clean backend rerun, not as a late post-route ECO on this block.
```

## 2026-05-10 NOR2 Cell-Use Policy Clean Rerun

```text
Hypothesis:
If residual Off-grid is driven mainly by NOR2X0_HVT/NOR2X2_HVT A1/VSS pin-access geometry, then excluding those two cells during synthesis and rerunning backend from a clean library should reduce the residual DRC below the saved 20-DRC modified-LEF cleanup candidate.
```

```text
DC debug handoff:
Script: 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.sh
Tcl: 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.tcl
Run tag: pre_backend_topo_nor2_no_x0x2_hvt
Policy: set_dont_use NOR2X0_HVT and NOR2X2_HVT before compile_ultra.
Evidence:
- 2_Synthesis/4_Report/99_debug/pre_backend_topo_nor2_no_x0x2_hvt/nor2_dont_use_verify.rpt reports both lib cells dont_use=true.
- 2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg contains 0 NOR2X0_HVT/NOR2X2_HVT references.
QoR note:
- Design Area 414721.590708.
- Max Trans Violations 3354 and Max Cap Violations 6804 remain in post_compile.qor.rpt, so this is a debug handoff, not synthesis DRC closure.
```

```text
Backend debug rerun:
Command:
env MOD_LEF_ROUTE_DEBUG_ROOT=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow MOD_LEF_ROUTE_REPORT_ROOT=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow MOD_LEF_ROUTE_LOG_ROOT=4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_route_flow MOD_LEF_ROUTE_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_route_icc2_lib BACKEND_NETLIST=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg BACKEND_SDC=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.sdc 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow
ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_route_icc2_lib
Result:
- Open nets = 0.
- Total DRC = 36.
- Diff net spacing = 2.
- Off-grid = 34.
- Legality TOTAL 0.
- PG connectivity VDD/VSS floating objects 0.
- PG DRC no errors.
- timing.max slack MET 0.77 ns.
- timing.min slack MET 0.04 ns.
```

```text
Evaluation:
The hypothesis is not supported as a standalone fix. Removing NOR2X0_HVT/NOR2X2_HVT upstream did not improve DRC; it worsened the route result versus the saved modified-LEF cleanup candidate.

Comparison:
- Best saved cleanup candidate: 20 DRC = Off-grid 19, Short 1.
- NOR2-policy full debug backend rerun: 36 DRC = Diff net spacing 2, Off-grid 34.

Conclusion:
Do not promote the NOR2 dont_use policy. The residual root cause is broader lower-metal pin-access/via-rule behavior, and cell-use exclusion alone increases area/instance count enough that placement/route DRC does not improve.
```

## 2026-05-10 NOR2-Policy Cleanup and Remaining DRC

```text
Cleanup run:
Script: 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
Source lib: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_route_icc2_lib
Saved lib: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved/summary.tsv
Result: route_detail cleanup reduced DRC from 36 to 19 with open nets 0.
Breakdown: Diff net spacing 2, Off-grid 17, Short 0.
Sanity: legality TOTAL 0, PG connectivity clean, PG DRC no errors, timing.max slack MET 0.77 ns, timing.min slack MET 0.04 ns.
```

```text
Inspection:
DRC matrix: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_drc_inspect/drc_matrix.rpt
Off-grid context: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_offgrid_context/offgrid_context.tsv
Result:
- Diff net spacing: 2 total = M1 1, M2 1.
- Off-grid: 17 total = M1 1, VIA1 16.
- The Off-grid vias are still VIA12SQ_C M1-M2 generated route vias.
- Nearby cell contexts are mixed, not NOR2-only.

Evaluation:
The upstream NOR2 cell-use policy is not a standalone fix, but the cleaned NOR2-policy route is the current best debug waypoint by count: 19 DRC/open0 versus the prior 20 DRC/open0 candidate.
The residual root-cause axis remains lower-metal pin-access/contact-code/via-array legality, not a single NOR2 macro class.
```

```text
Rejected follow-up probes on the 19-DRC candidate:

1. Shrink VIA12SQ_C 2-row arrays to 1x1
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_nor2_policy_cleanup_saved/summary.tsv
   Result: 19 DRC/open0 remains; Off-grid drops to 1 but Needs fat contact rises to 16.
   Rejected because it trades DRC class.

2. Shrink VIA12SQ_C arrays then route_detail repair
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_repair_nor2_policy_cleanup_saved/summary.tsv
   Result: final check_routes remains 19 DRC/open0 with Diff net spacing 2, Needs fat contact 16, Off-grid 1.
   Rejected because final signoff-style check_routes is unchanged by count.

3. via_array_mode=off plus high fat-contact/wire-via effort
   Report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv
   Result: 19 DRC/open0 = Diff net spacing 2, Needs fat contact 13, Off-grid 1, Short 3.
   Rejected because it trades Off-grid into fat-contact/short DRC.
```

```text
Updated conclusion:
The new best debug artifact is 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib with 19 signal DRCs and 0 open nets.
It is not production-promoted and not DRC clean.
Direct route-detail, object-level VIA ECO, via-array option, and NOR2 cell-use exclusion have reached diminishing returns. Next useful work should focus on PDK/NDM/contact-code consistency for VIA12SQ_C and M1-M2 stdcell pin access, or a placement/pin-access policy experiment that is rerun from clean init/place/route and compared against this 19-DRC artifact.
```

## 2026-05-10 Diff-Net Blockage Candidate and 18-DRC State

```text
PG offset hypothesis:
Test: PG_M2_OFFSET=25.0 full modified-LEF/NOR2-policy backend route.
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow
Result:
- Signal route: 32 DRC/open0, all Off-grid.
- PG DRC: 640 errors.

Evaluation:
Rejected. The shifted M2 mesh is not coherent with the fixed rail-stitch locations, so PG DRC regresses heavily.
```

```text
Diff-net root cause:
Inspection report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_diff_context/context.tsv
Finding:
- The two Diff net spacing DRCs involve reset net ZBUF_1454_851 near the VSS rail/stripe intersection.
- Objects include VSS M1 rail PATH_11_149, VSS M2 stripe PATH_13_102, and reset-net route shapes around x~779.5, y~269.

Hypothesis:
A small M2 signal routing blockage near that PG conflict can force ZBUF_1454_851 away from the VSS M2/M1 conflict without reopening the design.
```

```text
Accepted debug waypoint:
Script: 4_Backend_ICC2/0_Script/99_debug/probe_diff_net_blockage_eco.sh
Saved lib: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/summary.tsv
Result:
- Before: 19 DRC/open0 = Diff net spacing 2, Off-grid 17.
- After: 18 DRC/open0 = Off-grid 17, Short 1.
- Diff net spacing is 0.
- Legality TOTAL 0.
- PG connectivity floating objects 0.
- PG DRC no errors.
- timing.max slack MET 0.77 ns.
- timing.min slack MET 0.04 ns.

Evaluation:
This supersedes the 19-DRC artifact by count, but it is still not route DRC clean.
```

```text
Residual 18-DRC inspection:
DRC matrix: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_drc_inspect/drc_matrix.rpt
Short context: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_short_inspect/short_area_objects.tsv
Off-grid context: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_offgrid_context/offgrid_context.tsv
Result:
- Off-grid: 17 total = M1 1, VIA1 16.
- Short: 1 total = M1 1.
- Short object is ZBUF_1454_851 near VSS M1 rail PATH_11_149 and reset-net M2/via route objects.

Interpretation:
The M2 blockage resolves the previous reset-net Diff spacing but pushes the reset-net reroute close enough to the VSS M1 rail to create one M1 Short.
```

```text
Rejected follow-up probes:
1. Additional M1 signal blockage around the Short
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_short_m1_blockage_on_diff_m2_saved/summary.tsv
   Result: after_total 21/open0 = Diff net spacing 3, Off-grid 18, Short 0.
   Rejected because it fixes Short by reintroducing more DRC.

2. Remove residual Off-grid VIA1 objects, then route_eco affected nets
   Script: 4_Backend_ICC2/0_Script/99_debug/probe_remove_offgrid_via1_route_eco.sh
   Report: 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_route_eco_diff_m2_blockage_saved/summary.tsv
   Result: after_remove gives Off-grid 0 but open nets 15; after route_eco returns to 18 DRC/open0 = Off-grid 17, Short 1.
   Rejected because route_eco regenerates the same residual DRC pattern.
```

```text
Updated conclusion:
The current best debug artifact is 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib with 18 signal DRCs and 0 open nets.
It is not production-promoted and not DRC clean.
Direct route-detail, object-level VIA ECO, local blockage ECO, PG offset, via-array option, and NOR2 cell-use exclusion have reached diminishing returns. Next useful work should focus on PDK/NDM/contact-code consistency for VIA12SQ_C and M1-M2 stdcell pin access, or a placement/pin-access policy experiment rerun from clean init/place/route and compared against this 18-DRC artifact.
```

## 2026-05-10 Off-grid Bbox Blockage and Alternate Techfile Probes

```text
Hypothesis:
If residual Off-grid is mainly caused by exact generated VIA12SQ_C positions, then adding small M2 signal blockages at each Off-grid bbox and rerouting the affected signal nets should reduce total DRC.

Probe:
Script: 4_Backend_ICC2/0_Script/99_debug/probe_offgrid_bbox_blockage_eco.sh
Report: 4_Backend_ICC2/4_Report/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved/summary.tsv
Result:
- Before: 18 DRC/open0 = Off-grid 17, Short 1.
- After: 18 DRC/open0 = Off-grid 0, Short 18.

Evaluation:
Rejected. The probe removes the Off-grid class but does not reduce total DRC; the route collapses into shorts. This falsifies a simple coordinate-avoidance fix and supports a lower-metal pin-access/contact legality issue.
```

```text
Hypothesis:
The remaining issue might come from using the project default SAED32_EDK techfile rather than a PDK/reference techfile with different contact-code definitions.

Probe:
Tried rebuilding the same libdir modified-LEF NDMs with:
- /DATA/home/edu135/lib/SAED32nm_PDK_04152022/techfiles/saed32nm_1p9m_mw.tf
- /DATA/home/edu135/lib/SAED32_EDK/references/orca/icc/ref/tech/saed32nm_1p9m_mw.tf

Evidence:
- 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_pdk_tf_ndm.log
- 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_orca_tf_ndm.log

Result:
Both fail before NDM commit. PDK techfile reports TECH-006 at line 356 and LIB-007. ORCA reference techfile reports TECH-006 at line 405 and LIB-007.

Evaluation:
Rejected as a direct substitution. Alternate techfile adoption would require a compatible techfile cleanup/import step first.
```

## 2026-05-10 Lower Utilization Clean Rerun

```text
Hypothesis:
If the residual Off-grid/Short DRC is driven by placement density or pin-access pressure, then rerunning from a clean backend library at lower core utilization should reduce total route DRC compared with the 18-DRC saved candidate.

Probe:
Added floorplan env override support in 4_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.tcl and ran the modified-LEF NOR2-policy backend flow with CORE_UTILIZATION=0.55.

Evidence:
- Logs: 4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_u055_route_flow
- Reports: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_u055_route_flow
- Final route check: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_u055_route_flow/06_route/check_routes.rpt
- PG connectivity: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_u055_route_flow/06_route/pg_connectivity.rpt

Result:
- Floorplan utilization: 0.5505.
- Final route utilization: 0.5972.
- Route: 0 open nets, 36 DRCs = Diff net spacing 2, Off-grid 34.
- Legality: TOTAL 0.
- PG DRC: no errors.
- PG connectivity: VDD floating objects 0; VSS floating wires 1 and floating std cells 307.
- Timing: max slack MET 0.77 ns; min slack MET 0.03 ns.

Evaluation:
Rejected. Lowering utilization does not improve the residual DRC and introduces a PG connectivity regression. This weakens the pure density hypothesis and points back to lower-metal physical abstract/contact-code/pin-access consistency rather than die size alone.
```

## 2026-05-10 VIA1 Pitch Techfile Probe

```text
Hypothesis:
The current SAED32_EDK techfile comments out VIA1 pitch while keeping VIA1 onGrid and onWireTrack. If the residual Off-grid DRC is caused by missing VIA1 pitch metadata, then enabling pitch = 0.36 in a project-local techfile copy should reduce the Off-grid count in a clean backend rerun.

Probe:
Created a project-local modified techfile and NDMs that uncomment only the VIA1 pitch line, then reran the modified-LEF NOR2-policy backend flow.

Evidence:
- NDM build script: 4_Backend_ICC2/0_Script/99_debug/build_via1_pitch_ndm.sh
- NDM build log: 4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_ndm.log
- Route script: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_nor2_policy_route_flow.sh
- Route report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow
- Final route check: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow/06_route/check_routes.rpt

Result:
- NDM build succeeded and emitted TECH-025: Layer VIA1 onGrid and onWireTrack coexist.
- Route has 0 open nets.
- Signal DRC is 36 = Diff net spacing 2, Off-grid 34.
- Legality: TOTAL 0.
- PG connectivity: VDD/VSS floating objects 0.
- PG DRC: no errors.
- Timing: max slack MET 0.77 ns; min slack MET 0.04 ns.

Evaluation:
Rejected. Explicit VIA1 pitch does not reduce residual Off-grid; it produces the same 36-DRC class shape as the clean NOR2-policy route and remains worse than the current 18-DRC debug waypoint. This weakens the "missing VIA1 pitch alone" hypothesis. The next useful axis is still lower-metal physical abstract/contact-code consistency, especially the coexistence of VIA1 pitch/onGrid/onWireTrack and stdcell M1-M2 pin-access geometry, not another broad route iteration.
```
