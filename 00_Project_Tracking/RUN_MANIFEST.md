# Run Manifest

## Baseline Run

```text
Run name: tt_mvt_10ns_baseline
Project root: /DATA/home/edu135/ibex
RTL source: rtl/ibex
SoC RTL: rtl/mini_soc
Top: ibex_mini_soc_top
Clock target: 10 ns
Library corner: TT 1.05V 25C
VT usage: mixed RVT/LVT/HVT
EDA tool versions: pending first tool run
DC version: W-2024.09-SP5-5
Formality version: W-2024.09-SP5
PrimeTime version: W-2024.09-SP5-3
IMEM model: 2KB stdcell/flop memory with top-level preload write interface
```

## Libraries

```text
SAED32_ROOT=/DATA/home/edu135/lib/SAED32_EDK
RVT_TT_DB=/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
LVT_TT_DB=/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
HVT_TT_DB=/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db
```

## Debug Library Probes

```text
Modified LEF source: /DATA/home/edu135/lib/libdir/LEF/modify
Modified LEF NDM build script: 4_Backend_ICC2/0_Script/99_debug/build_modified_lef_ndm.sh
Modified LEF NDM build log: 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_ndm.log
Modified LEF NDM outputs: 4_Backend_ICC2/2_Output/99_debug/modified_lef_pg_probe/ndm/saed32rvt_tt.modified_lef.ndm, saed32lvt_tt.modified_lef.ndm, saed32hvt_tt.modified_lef.ndm
Modified LEF PG probe script: 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_pg_probe.sh
Modified LEF PG probe log: 4_Backend_ICC2/3_Log/99_debug/run_modified_lef_pg_probe.log
Modified LEF PG probe summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_pg_probe/summary.tsv
Modified LEF PG probe note: separate debug ICC2 library only; production backend library remains unchanged.
```

## Source Revision

```text
Ibex upstream commit: 9742d89f54fc297bed026841c8e68454ddfd7cc0
Ibex clone path: rtl/ibex
```

## Project Git Remote

```text
Remote: ssh://git@ssh.github.com:443/combipatal/ibex.git
Branch: main
SSH key: /DATA/home/edu135/.ssh/id_ed25519
SSH port: 443 via ssh.github.com
Local git metadata: .git_local, accessed by scripts/git_project.sh
Uploaded scope: scripts/docs/configs/constraints/filelists/tracking records only
Excluded: rtl/ibex upstream clone and generated EDA outputs
```

## Baseline Handoff Naming

```text
Official synthesis baseline: DC Graphical topographical
Synthesis script: 2_Synthesis/0_Script/run_dc_compile_topo.tcl
DC invocation: dc_shell -topographical_mode -f 2_Synthesis/0_Script/run_dc_compile_topo.tcl -output_log_file 2_Synthesis/3_Log/dc_compile_topo.log
Run tag: pre_backend_topo
Mapped DDC: 2_Synthesis/2_Output/pre_backend_topo/ibex_mini_soc_top.pre_backend_topo.ddc
Mapped netlist: 2_Synthesis/2_Output/pre_backend_topo/ibex_mini_soc_top.pre_backend_topo.vg
Mapped SDC: 2_Synthesis/2_Output/pre_backend_topo/ibex_mini_soc_top.pre_backend_topo.sdc
Mapped SDF: 2_Synthesis/2_Output/pre_backend_topo/ibex_mini_soc_top.pre_backend_topo.sdf
Formality SVF: 2_Synthesis/2_Output/svf/ibex_mini_soc_top.pre_backend_topo.svf
Formality R2N script: 3_Formality/0_Script/run_fm_r2n_topo.tcl
Formality R2N wrapper: 3_Formality/0_Script/run_fm_r2n_topo.sh
FM invocation: 3_Formality/0_Script/run_fm_r2n_topo.sh
FM basis: reference RTL from filelists/ibex_mini_soc_fm_ref.f, implementation DDC, and matching DC topo SVF.
FM SVF note: DC topo enables hdlin_enable_hier_map and calls set_verification_top so SVF contains hier_map guidance.
Pre-backend STA script: 5_STA/0_Script/run_pt_pre_backend_topo_sdf.tcl
Pre-backend STA wrapper: 5_STA/0_Script/run_pt_pre_backend_topo_sdf.sh
PT invocation: 5_STA/0_Script/run_pt_pre_backend_topo_sdf.sh
STA basis: same topo netlist/SDC/SDF run that produced the SVF; PrimeTime does not read SVF directly.
STA note: wrapper creates log/report directories before pt_shell opens -output_log_file.
```

## Baseline Results

```text
DC topo status: PASS_WITH_NOTE
DC version: W-2024.09-SP5-5
DC log: 2_Synthesis/3_Log/dc_compile_topo.log
DC QoR: 2_Synthesis/4_Report/topo/post_compile.qor.rpt
DC timing: WNS 0.00 ns, TNS 0.00 ns, setup violating paths 0, hold violating paths 0
DC area: 414758.187451
DC leaf cells: 109713
DC DRC note: max transition/cap violations remain in pre-backend topo report
```

```text
Formality R2N status: PASS_WITH_NOTE
FM version: W-2024.09-SP5
FM log: 3_Formality/3_Log/fm_r2n_topo.log
FM result: Verification SUCCEEDED
FM compare points: 34915 passing, 0 failing, 0 unmatched
FM SVF guidance: 2146 accepted, 0 rejected; hier_map 33 accepted, 0 rejected
FM note: synopsys_auto_setup enabled; one clock-gate latch not compared; RTL interpretation warnings recorded in log.
```

```text
PT STA status: PASS_WITH_NOTE
PT version: W-2024.09-SP5-3
PT log: 5_STA/3_Log/pt_pre_backend_topo_sdf.log
PT global timing: 5_STA/4_Report/pre_backend_topo/global_timing.rpt
PT result: no setup violations, no hold violations
PT SDF annotation: 1002647 / 1002679 delay arcs annotated; 32 primary-output net arcs not annotated
PT coverage: 139601 / 145136 checks met, 0 violated, 5535 untested
PT note: reset recovery/removal checks are untested by current async reset constraint policy
```

## Backend Baseline Results

```text
ICC2 NDM setup status: PASS_WITH_NOTE
NDM log: 4_Backend_ICC2/3_Log/00_setup/build_saed32_ndm.log
NDM outputs: 4_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm, saed32lvt_tt.ndm, saed32hvt_tt.ndm
```

```text
ICC2 init_design status: PASS_WITH_NOTE
ICC2 init log: 4_Backend_ICC2/3_Log/01_init_design/run_init_design_check.log
ICC2 init check_design: 4_Backend_ICC2/4_Report/01_init_design/check_design.rpt
ICC2 init timing: 4_Backend_ICC2/4_Report/01_init_design/timing.rpt
```

```text
ICC2 floorplan status: PASS_WITH_NOTE
ICC2 floorplan log: 4_Backend_ICC2/3_Log/02_floorplan/run_floorplan_initial.log
ICC2 floorplan utilization: 4_Backend_ICC2/4_Report/02_floorplan/utilization.rpt
ICC2 floorplan QoR: 4_Backend_ICC2/4_Report/02_floorplan/qor.rpt
```

```text
ICC2 powerplan status: PASS_WITH_NOTE
ICC2 powerplan log: 4_Backend_ICC2/3_Log/03_powerplan/run_powerplan_initial.log
ICC2 powerplan PG DRC: 4_Backend_ICC2/4_Report/03_powerplan/pg_drc.rpt
ICC2 powerplan PG connectivity: 4_Backend_ICC2/4_Report/03_powerplan/pg_connectivity.rpt
Powerplan note: rerun after PG rail stitch fix; VDD/VSS floating objects 0 and PG DRC no errors.
```

```text
ICC2 place status: PASS_WITH_NOTE
ICC2 place log: 4_Backend_ICC2/3_Log/04_place/run_place_initial.log
ICC2 place legality: 4_Backend_ICC2/4_Report/04_place/check_legality.rpt
ICC2 place QoR: 4_Backend_ICC2/4_Report/04_place/place_qor.rpt
Place note: rerun after PG rail stitch fix; legality and PG connectivity are clean.
```

```text
ICC2 CTS status: PASS_WITH_NOTE
ICC2 CTS log: 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log
ICC2 CTS clock tree post-check: 4_Backend_ICC2/4_Report/05_cts/check_clock_trees.post.rpt
ICC2 CTS legality: 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt
ICC2 CTS timing max: 4_Backend_ICC2/4_Report/05_cts/timing.max.rpt
ICC2 CTS timing min: 4_Backend_ICC2/4_Report/05_cts/timing.min.rpt
ICC2 CTS PG DRC: 4_Backend_ICC2/4_Report/05_cts/pg_drc.rpt
ICC2 CTS PG connectivity: 4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt
CTS result: rerun after PG rail stitch fix; clock tree compilation completed; route_clock reports 0 open nets and 0 DRCs; check_legality reports TOTAL 0 violations.
CTS timing: timing.max worst reported slack MET 0.43 ns; timing.min worst reported slack MET 0.03 ns.
CTS PG note: VDD/VSS floating objects 0; PG DRC no errors.
```

```text
ICC2 PG diagnosis status: PASS_WITH_NOTE
M7 offset sweep script: 4_Backend_ICC2/0_Script/99_debug/run_pg_m7_offset_sweep.sh
M2 sweep script: 4_Backend_ICC2/0_Script/99_debug/run_pg_m2_sweep.sh
Modified LEF PG probe result: PG DRC clean; compile_pg recognized 109713 standard cells; PG connectivity reports VDD 3196 and VSS 396 floating std cells.
Accepted PG fix script: 4_Backend_ICC2/0_Script/03_powerplan/run_powerplan_initial.tcl
Accepted PG debug probe: 4_Backend_ICC2/0_Script/99_debug/probe_baseline_pg_local_stitches.sh
Accepted PG debug summary: 4_Backend_ICC2/4_Report/99_debug/baseline_pg_local_stitches/summary.tsv
Production stitch report: 4_Backend_ICC2/4_Report/03_powerplan/pg_rail_stitches.rpt
Diagnosis note: M7/M2 PG parameter sweeps and modified-LEF NDM did not produce a clean PG connectivity result. The production fix is targeted local rail stitching, not modified LEF.
```

```text
ICC2 route status: COMPLETE_WITH_OPEN_SIGNAL_DRC
ICC2 route log: 4_Backend_ICC2/3_Log/06_route/run_route_initial.log
ICC2 route check_routes: 4_Backend_ICC2/4_Report/06_route/check_routes.rpt
ICC2 route legality: 4_Backend_ICC2/4_Report/06_route/check_legality.rpt
ICC2 route timing max: 4_Backend_ICC2/4_Report/06_route/timing.max.rpt
ICC2 route timing min: 4_Backend_ICC2/4_Report/06_route/timing.min.rpt
ICC2 route PG connectivity: 4_Backend_ICC2/4_Report/06_route/pg_connectivity.rpt
ICC2 route PG DRC: 4_Backend_ICC2/4_Report/06_route/pg_drc.rpt
Route result: 0 open nets; legality TOTAL 0; PG connectivity clean; PG DRC no errors; timing max slack MET 0.57 ns; timing min slack MET 0.03 ns.
Route open item: signal route DRC remains 720.
Route DRC breakdown: Diff net spacing 251, Less than minimum area 24, Needs fat contact 347, Off-grid 92, Short 6.
Route diagnosis note: 00_Project_Tracking/ROUTE_DIAGNOSIS_NOTES.md
Route DRC inspect script: 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
Route DRC matrix: 4_Backend_ICC2/4_Report/99_debug/route_drc_inspect/drc_matrix.rpt
Route variant probe script: 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Rejected route probes: detail_extra oscillated around 660-680 DRCs; reroute_m2 grew above 11000 DRCs before abort.
Route option help script: 4_Backend_ICC2/0_Script/99_debug/inspect_route_option_help.sh
Route option help reports: 4_Backend_ICC2/4_Report/99_debug/route_option_help/
fat_contact_effort probe log: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.fat_contact_effort.log
fat_contact_effort option report: 4_Backend_ICC2/4_Report/99_debug/route_drc_variants/fat_contact_effort/app_options.after.rpt
fat_contact_effort result: reduced Needs fat contact as low as 239, but increased Diff net spacing as high as 361 and total DRC stayed around 660-672.
```

```text
ICC2 route-closure baseline status: PASS_WITH_NOTE
Route-closure wrapper: 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh
Route-closure command: 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh
Route-closure log root: 4_Backend_ICC2/3_Log/07_route_closure
Route-closure report root: 4_Backend_ICC2/4_Report/07_route_closure
Route-closure ICC2 library: 4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib
Route-closure handoff: 2_Synthesis/2_Output/pre_backend_topo_nor2_mux41_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_mux41_no_x0x2_hvt.vg and matching SDC
Route-closure NDM root: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/ndm
Route-closure techfile: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf
Route-closure result: 0 open nets, 0 signal DRC, legality TOTAL 0, PG connectivity floating objects 0, PG DRC no errors, timing.max MET 0.78 ns, timing.min MET 0.04 ns.
Route-closure caveat: antenna checking is not active because no antenna rules are defined.
```

```text
ICC2 GDS candidate export status: PASS_WITH_NOTE
GDS wrapper: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh
GDS Tcl: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.tcl
GDS command: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh
GDS log: 4_Backend_ICC2/3_Log/08_gds/run_write_gds_route_closure.route_closure_gds_candidate.log
GDS input ICC2 library: 4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib
GDS output root: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate
GDS report root: 4_Backend_ICC2/4_Report/08_gds/route_closure_gds_candidate
GDS output: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.gds
GDS manifest: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/gds_export_manifest.txt
GDS companion outputs: ibex_mini_soc_top.route_closure_gds_candidate.vg, .def, .sdc
GDS file sizes: GDS 157M, DEF 127M, Verilog 32M, SDC 13M.
Post-filler checks: route DRC/open clean, legality clean, PG connectivity clean, PG DRC no errors.
Timing/QoR: qor.after_filler.rpt reports clk critical path slack 0.78 ns and no setup/hold violating paths.
Known design-rule notes: constraints.after_filler.rpt reports max_transition 8 and max_capacitance 228 violations.
Claim boundary: educational GDS candidate only; not foundry/signoff DRC, LVS, antenna, IR/EM, metal-fill, or tapeout-ready.
```

```text
ICC2 modified-LEF route debug status: COMPLETE_WITH_RESIDUAL_SIGNAL_DRC
Command: 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Modified NDM inputs: 4_Backend_ICC2/2_Output/99_debug/modified_lef_pg_probe/ndm/saed32rvt_tt_modified.ndm, saed32lvt_tt_modified.ndm, saed32hvt_tt_modified.ndm
ICC2 library output: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_route_flow
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow
Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/check_routes.rpt
Legality report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/check_legality.rpt
PG connectivity report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/pg_connectivity.rpt
PG DRC report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/pg_drc.rpt
Timing reports: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/timing.max.rpt, timing.min.rpt
Route result: 0 open nets; 41 signal DRCs; Diff net spacing 1, Off-grid 39, Short 1; Needs fat contact eliminated.
Sanity result: legality TOTAL 0; PG connectivity VDD/VSS floating objects 0; route log reports check_pg_drc No errors found; timing.max slack MET 0.74 ns; timing.min slack MET 0.04 ns.
Caveat: debug-only route is not DRC clean and production NDM selection has not been switched.
```

```text
ICC2 modified-LEF residual DRC inspect status: PASS_WITH_NOTE
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib ROUTE_DRC_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
Script: 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
Tcl: 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.tcl
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect
DRC matrix: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect/drc_matrix.rpt
Result: M1 3 DRCs, M2 19 Off-grid DRCs, VIA1 19 Off-grid DRCs; total remains 41.
Next action: inspect/fix residual off-grid M2/VIA1 pairs and the one M1 short/spacing location.
```

```text
ICC2 modified-LEF residual cleanup probe status: PASS_WITH_NOTE
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib ROUTE_DRC_VARIANT=detail_extra ROUTE_DRC_VARIANT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Script: 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Tcl: 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.tcl
Log: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.modified_lef_detail_extra.log
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra/summary.tsv
Result: DRC reduced from 41 to 20 with 0 open nets; final DRC is Off-grid 19 and Short 1.
Caveat: no save_block/save_lib executed, so this is diagnostic signal only.
```

```text
ICC2 modified-LEF saved cleanup candidate status: SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC
Command: 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
Script: 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
Tcl: 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.tcl
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved/summary.tsv
Result: saved debug candidate has 0 open nets and 20 signal DRCs: Off-grid 19, Short 1. Legality/PG/timing sanity reports remain acceptable for debug.
```

```text
ICC2 residual DRC diagnosis status: DIAGNOSED_NO_ACCEPTED_FIX
Primary saved candidate: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib
Residual DRC matrix: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect/drc_matrix.rpt
Off-grid via attributes: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect/offgrid_via_attrs.tsv
Short area inspection: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_short_inspect/short_area_objects.tsv
Rejected probe summaries: 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_by_net_bbox_cleanup_saved/summary.tsv, probe_remove_offgrid_via1_repair_cleanup_saved/summary.tsv, probe_shrink_offgrid_via1_array_cleanup_saved/summary.tsv, probe_shrink_offgrid_via1_array_repair_cleanup_saved/summary.tsv, probe_replace_offgrid_via1_def_VIA12SQ_C_1x2_cleanup_saved/summary.tsv, modified_lef_route_drc_variants/via_array_off_cleanup_saved/summary.tsv, modified_lef_route_drc_variants/via1_on_grid_cleanup_saved/summary.tsv, modified_lef_route_drc_variants/via_ladder_clean_cleanup_saved/summary.tsv, modified_lef_route_drc_variants/via1_offgrid_cost20_cleanup_saved/summary.tsv, probe_short_net_eco_n48420_cleanup_saved/summary.tsv, probe_short_net_remove_detail_eco_n48420_cleanup_saved/summary.tsv
Conclusion: residual 19 Off-grid DRCs are tied to VIA12SQ_C 2-row M1-M2 arrays; residual M1 Short is tied to n48420. Existing route-detail/ECO/via-option probes do not produce a clean connected route.
```

```text
ICC2 VIA12SQ_C row-limit route probe status: REJECTED_NO_IMPROVEMENT
Command: 4_Backend_ICC2/0_Script/99_debug/run_via12sqc_row1_route_flow.sh
Generated tech: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via12sqc_row1/tech/saed32nm_1p9m_mw.via12sqc_row1.tf
Generated NDM root: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via12sqc_row1/ndm
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via12sqc_row1_route_flow
Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via12sqc_row1_route_flow/06_route/check_routes.rpt
Result: 0 open nets; 41 signal DRCs = Diff net spacing 1, Off-grid 39, Short 1.
Conclusion: limiting VIA12SQ_C maxNumRowsNonTurning to 1 did not improve the modified-LEF route result and is worse than the saved 20-DRC cleanup candidate.
```

```text
ICC2 residual split-via probe status: REJECTED_NO_ACCEPTED_FIX
Inspect scripts: 4_Backend_ICC2/0_Script/99_debug/inspect_via_defs.sh, 4_Backend_ICC2/0_Script/99_debug/inspect_via_defs.tcl
Probe scripts: 4_Backend_ICC2/0_Script/99_debug/probe_split_offgrid_via1_array.sh, 4_Backend_ICC2/0_Script/99_debug/probe_split_offgrid_via1_array.tcl
Via-def inspect report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_via_def_inspect2/via_defs.tsv
Y split summary: 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_cleanup_saved/summary.tsv
Y split plus repair summary: 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_repair_cleanup_saved/summary.tsv
X split summary: 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_x_cleanup_saved/summary.tsv
Result: y-axis split worsened to 115 DRCs; y-axis split plus repair restored the original 20 DRCs; x-axis split worsened to 167 DRCs and 10 open nets.
Conclusion: direct object-level split of VIA12SQ_C arrays is not a viable repair path.
```

```text
ICC2 via-array/fat-contact combination probe status: REJECTED_NO_ACCEPTED_FIX
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib ROUTE_DRC_VARIANT=via_array_off_fat_contact ROUTE_DRC_VARIANT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_fat_contact_cleanup_saved ROUTE_DRC_VARIANT_LOG=4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.via_array_off_fat_contact_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Script: 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.tcl
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_fat_contact_cleanup_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv
Result: 0 open nets; 20 DRCs = Needs fat contact 9, Short 11, Off-grid 0.
Conclusion: option combination trades residual Off-grid into fat-contact/short DRC and is not promoted.
```

```text
ICC2 Off-grid context inspection status: PASS_WITH_NOTE
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib OFFGRID_CONTEXT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_offgrid_context OFFGRID_CONTEXT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_offgrid_context.modified_lef_cleanup_saved.log bash 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.sh
Scripts: 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.sh, 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.tcl
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_offgrid_context
Result: residual Off-grid locations are near NOR2 A1/VSS pin-access contexts; A1 pin owner instances map to NOR2X0_HVT or NOR2X2_HVT in the synthesis netlist.
Conclusion: residual Off-grid should be treated as lower-metal NOR2 pin-access/via-array behavior.
```

```text
ICC2 targeted NOR2 resize ECO probe status: REJECTED_BREAKS_CONNECTIVITY
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib NOR2_RESIZE_TARGET=NOR2X4_HVT NOR2_RESIZE_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved NOR2_RESIZE_LOG=4_Backend_ICC2/3_Log/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved.log bash 4_Backend_ICC2/0_Script/99_debug/probe_resize_offgrid_nor2.sh
Scripts: 4_Backend_ICC2/0_Script/99_debug/probe_resize_offgrid_nor2.sh, 4_Backend_ICC2/0_Script/99_debug/probe_resize_offgrid_nor2.tcl
Report root: 4_Backend_ICC2/4_Report/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved/summary.tsv
Result: final check_routes worsened to 43 DRCs and 19 open nets.
Conclusion: do not use post-route NOR2 resize as a fix.
```

```text
ICC2 extended cleanup status: SAVED_REJECTED_CANDIDATE
Command: env MOD_LEF_CLEANUP_SRC_LIB=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib MOD_LEF_CLEANUP_LIB=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_iter50_saved/ibex_mini_soc_top_modified_lef_cleanup_iter50_icc2_lib MOD_LEF_CLEANUP_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_iter50_saved MOD_LEF_CLEANUP_LOG=4_Backend_ICC2/3_Log/99_debug/save_modified_lef_detail_cleanup_iter50.log MOD_LEF_CLEANUP_START_ITER=50 MOD_LEF_CLEANUP_MAX_ITER=50 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_iter50_saved/ibex_mini_soc_top_modified_lef_cleanup_iter50_icc2_lib
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_iter50_saved/summary.tsv
Result: 20 DRCs became 21 DRCs; Short cleared but Off-grid increased to 20 and Diff net spacing 1 returned.
Conclusion: do not promote this iter50 saved candidate. It was worse than the then-best 20-DRC cleanup candidate and is now also worse than the 19-DRC NOR2-policy cleanup candidate.
```

```text
DC NOR2 cell-use policy debug synthesis status: PASS_WITH_PRE_BACKEND_DRC_NOTE
Command: env NOR2_POLICY_RUN_TAG=pre_backend_topo_nor2_no_x0x2_hvt 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.sh
Scripts: 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.sh, 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.tcl
Log: 2_Synthesis/3_Log/99_debug/run_dc_compile_topo_nor2_policy.pre_backend_topo_nor2_no_x0x2_hvt.log
Output root: 2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt
Report root: 2_Synthesis/4_Report/99_debug/pre_backend_topo_nor2_no_x0x2_hvt
Key reports: nor2_dont_use_policy.rpt, nor2_dont_use_verify.rpt, post_compile.qor.rpt, post_compile.constraints.rpt
Result: NOR2X0_HVT/NOR2X2_HVT were dont_use=true and do not appear in the mapped Verilog. Design Area 414721.590708; max transition/cap violations remain.
Use: debug-only backend input for the NOR2 cell-use policy experiment.
```

```text
ICC2 modified-LEF NOR2-policy route debug status: REJECTED_NO_IMPROVEMENT
Command: env MOD_LEF_ROUTE_DEBUG_ROOT=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow MOD_LEF_ROUTE_REPORT_ROOT=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow MOD_LEF_ROUTE_LOG_ROOT=4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_route_flow MOD_LEF_ROUTE_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_route_icc2_lib BACKEND_NETLIST=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg BACKEND_SDC=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.sdc 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Script: 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_route_flow
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow
ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_route_icc2_lib
Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow/06_route/check_routes.rpt
Result: 0 open nets; 36 signal DRCs = Diff net spacing 2, Off-grid 34. Legality/PG/timing sanity reports are acceptable for debug.
Conclusion: worse than the saved 20-DRC modified-LEF cleanup candidate; do not promote.
```

```text
ICC2 NOR2-policy cleanup candidate status: SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC
Command: env MOD_LEF_CLEANUP_SRC_LIB=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_route_icc2_lib MOD_LEF_CLEANUP_LIB=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib MOD_LEF_CLEANUP_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved MOD_LEF_CLEANUP_LOG=4_Backend_ICC2/3_Log/99_debug/save_modified_lef_nor2_policy_cleanup.log MOD_LEF_CLEANUP_START_ITER=40 MOD_LEF_CLEANUP_MAX_ITER=10 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved/summary.tsv
Result: 0 open nets; 19 signal DRCs = Diff net spacing 2, Off-grid 17.
Use: current best debug artifact by DRC count, not production baseline.
```

```text
ICC2 NOR2-policy cleanup DRC inspection status: PASS_WITH_NOTE
Commands:
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib ROUTE_DRC_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_drc_inspect ROUTE_DRC_INSPECT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_route_drc.modified_lef_nor2_policy_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib OFFGRID_CONTEXT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_offgrid_context OFFGRID_CONTEXT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_offgrid_context.modified_lef_nor2_policy_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.sh
Reports: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_drc_inspect/drc_matrix.rpt, 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_offgrid_context/offgrid_context.tsv
Result: residual DRC is Diff net spacing 2 and Off-grid 17; Off-grid is still tied to VIA12SQ_C M1-M2 route vias, but nearby cell context is mixed and not NOR2-only.
```

```text
ICC2 NOR2-policy cleanup residual probe status: REJECTED_NO_ACCEPTED_FIX
Probe summaries:
- 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_nor2_policy_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_repair_nor2_policy_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv
Result: probes keep final DRC count at 19 and trade among Off-grid, Needs fat contact, and Short classes.
Conclusion: no accepted direct ECO/route-option fix was found for the remaining 19 DRCs.
```

```text
ICC2 PG M2 offset route probe status: REJECTED_PG_DRC_REGRESSION
Command: env BACKEND_NETLIST=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg BACKEND_SDC=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.sdc MOD_LEF_ROUTE_DEBUG_ROOT=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow MOD_LEF_ROUTE_REPORT_ROOT=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow MOD_LEF_ROUTE_LOG_ROOT=4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow MOD_LEF_ROUTE_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_pg_m2_o25_route_icc2_lib PG_M2_OFFSET=25.0 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow
Result: route check_routes 32 DRC/open0; PG DRC 640 errors.
Conclusion: rejected because PG DRC regressed.
```

```text
ICC2 diff-net blockage cleanup candidate status: SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib DIFF_BLOCKAGE_HALF_X=0.25 DIFF_BLOCKAGE_HALF_Y=1.20 DIFF_ECO_SAVE=1 DIFF_ECO_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved DIFF_ECO_LOG=4_Backend_ICC2/3_Log/99_debug/save_diff_net_blockage_eco_nor2_policy_cleanup.log 4_Backend_ICC2/0_Script/99_debug/probe_diff_net_blockage_eco.sh
Script: 4_Backend_ICC2/0_Script/99_debug/probe_diff_net_blockage_eco.sh
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/summary.tsv
Result: 0 open nets; 18 signal DRCs = Off-grid 17, Short 1.
Sanity reports: check_legality.rpt, pg_connectivity.rpt, pg_drc.rpt, timing.max.rpt, timing.min.rpt under the same report root.
Use: current best debug artifact by DRC count, not production baseline.
```

```text
ICC2 18-DRC candidate inspection status: PASS_WITH_NOTE
Commands:
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib ROUTE_DRC_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_drc_inspect ROUTE_DRC_INSPECT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_route_drc_diff_m2_blockage_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib SHORT_INSPECT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_short_inspect SHORT_INSPECT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_short_area_diff_m2_blockage_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_short_area.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib OFFGRID_CONTEXT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_offgrid_context OFFGRID_CONTEXT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_offgrid_context_diff_m2_blockage_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.sh
Reports: drc_matrix.rpt, short_area_objects.tsv, offgrid_context.tsv under the listed report roots.
Result: residual DRC is Off-grid 17 and Short 1; Short is on reset net ZBUF_1454_851 near VSS M1 rail PATH_11_149.
```

```text
ICC2 18-DRC residual probe status: REJECTED_NO_ACCEPTED_FIX
Probe summaries:
- 4_Backend_ICC2/4_Report/99_debug/probe_short_m1_blockage_on_diff_m2_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_route_eco_diff_m2_blockage_saved/summary.tsv
New probe script: 4_Backend_ICC2/0_Script/99_debug/probe_remove_offgrid_via1_route_eco.sh
Result: added M1 blockage worsens to 21 DRC; remove Off-grid VIA1 plus route_eco regenerates the same 18 DRC.
Conclusion: no accepted direct ECO fix was found for the remaining 18 DRCs.
```

```text
ICC2 Off-grid bbox blockage ECO status: REJECTED_NO_TOTAL_DRC_IMPROVEMENT
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib OFFGRID_BLOCKAGE_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved OFFGRID_BLOCKAGE_LOG=4_Backend_ICC2/3_Log/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved.log 4_Backend_ICC2/0_Script/99_debug/probe_offgrid_bbox_blockage_eco.sh
New probe script: 4_Backend_ICC2/0_Script/99_debug/probe_offgrid_bbox_blockage_eco.sh
Summary: 4_Backend_ICC2/4_Report/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved/summary.tsv
Result: Off-grid 17 becomes 0, but Short 1 becomes 18; total stays 18 and no save_block/save_lib was executed.
Conclusion: rejected as a fix; useful as diagnosis that residual off-grid is tightly coupled to lower-metal pin-access shorts.
```

```text
Modified-LEF alternate-tech NDM probes status: REJECTED_INPUT_TECHFILE_LOAD_FAILURE
Logs:
- 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_pdk_tf_ndm.log
- 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_orca_tf_ndm.log
Result: PDK and ORCA reference techfiles both fail Library Manager create_workspace with TECH-006 syntax errors and LIB-007 load failures.
Conclusion: these techfiles cannot be dropped directly into the current LM/ICC2 NDM build. Keep the current SAED32_EDK techfile until a compatible techfile import/cleanup path is defined.
```

```text
ICC2 lower-utilization modified-LEF NOR2-policy rerun status: REJECTED_DRC_AND_PG_CONNECTIVITY_REGRESSION
Command: env CORE_UTILIZATION=0.55 BACKEND_NETLIST=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg BACKEND_SDC=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.sdc MOD_LEF_ROUTE_DEBUG_ROOT=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_u055_route_flow MOD_LEF_ROUTE_REPORT_ROOT=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_u055_route_flow MOD_LEF_ROUTE_LOG_ROOT=4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_u055_route_flow MOD_LEF_ROUTE_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_u055_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_u055_route_icc2_lib 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_u055_route_flow
Logs: 4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_u055_route_flow
Library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_u055_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_u055_route_icc2_lib
Result: 06_route/check_routes.rpt reports 0 open nets and 36 DRCs = Diff net spacing 2, Off-grid 34. 06_route/check_legality.rpt reports TOTAL 0. 06_route/pg_connectivity.rpt reports VSS floating wires 1 and floating std cells 307. 06_route/pg_drc.rpt has no errors. timing.max.rpt reports MET 0.77 ns; timing.min.rpt reports MET 0.03 ns.
Conclusion: not accepted as a fix and not a new best artifact.
```

```text
Modified-LEF VIA1 pitch NDM probe status: REJECTED_NO_IMPROVEMENT
NDM build command: 4_Backend_ICC2/0_Script/99_debug/build_via1_pitch_ndm.sh
NDM build log: 4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_ndm.log
Patched techfile: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch/tech/saed32nm_1p9m_mw.via1_pitch.tf
NDM outputs: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch/ndm/saed32rvt_tt.modified_lef_via1_pitch.ndm, saed32lvt_tt.modified_lef_via1_pitch.ndm, saed32hvt_tt.modified_lef_via1_pitch.ndm
NDM warning to track: TECH-025 Layer VIA1 onGrid and onWireTrack coexist after enabling pitch = 0.36.
Route command: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_nor2_policy_route_flow.sh
Route log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow
Route report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow
Route ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_nor2_policy_route_icc2_lib
Backend inputs: NOR2-policy netlist 2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg and matching SDC.
Result: 06_route/check_routes.rpt reports 0 open nets and 36 signal DRCs = Diff net spacing 2, Off-grid 34. Legality, PG connectivity, PG DRC, and ICC2 timing sanity checks are acceptable for debug.
Conclusion: rejected; this probe does not improve over the 18-DRC diff-net blockage saved artifact.
```

```text
Modified-LEF VIA1 pitch/no-track NDM status: PASS_WITH_NOTE
NDM build command: 4_Backend_ICC2/0_Script/99_debug/build_via1_pitch_no_track_ndm.sh
NDM build log: 4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_no_track_ndm.log
Patched techfile: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf
NDM root: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/ndm
Result: project-local techfile enables VIA1 pitch = 0.36 and removes VIA1 onGrid/onWireTrack; RVT/LVT/HVT NDMs were written. No TECH-025/TECH-006/LIB-007/Fatal pattern was found in the log.
Use: accepted for project baseline promotion as of 2026-05-10; wrapper/manifest promotion remains.
```

```text
ICC2 VIA1 pitch/no-track NOR2-policy route status: COMPLETE_WITH_ONE_RESIDUAL_SIGNAL_DRC
Command: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_policy_route_flow.sh
Script: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_policy_route_flow.sh
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow
ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_policy_route_icc2_lib
Backend inputs: 2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg and matching SDC.
Result: 0 open nets; 1 signal DRC = Off-grid 1. Legality/PG/timing sanity checks are acceptable for debug.
Residual context: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_drc_context/context.tsv identifies U6629/MUX41X2_HVT/S0.
```

```text
ICC2 generic resize probe status: REJECTED_BREAKS_CONNECTIVITY
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_policy_route_icc2_lib RESIZE_INST_TARGET_REF=MUX41X1_HVT RESIZE_INST_LIST=U6629 RESIZE_INST_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_resize_mux41x2_u6629_to_x1 RESIZE_INST_LOG=4_Backend_ICC2/3_Log/99_debug/probe_resize_instances.mux41x2_u6629_to_x1.log 4_Backend_ICC2/0_Script/99_debug/probe_resize_instances.sh
Scripts: 4_Backend_ICC2/0_Script/99_debug/probe_resize_instances.sh, 4_Backend_ICC2/0_Script/99_debug/probe_resize_instances.tcl
Summary: 4_Backend_ICC2/4_Report/99_debug/probe_resize_mux41x2_u6629_to_x1/summary.tsv
Result: final DRC/open nets worsened to 14/6 after resizing U6629 to MUX41X1_HVT.
Conclusion: rejected; use upstream cell-use policy, not post-route resize.
```

```text
DC NOR2+MUX41 cell-use policy debug synthesis status: PASS_WITH_PRE_BACKEND_DRC_NOTE
Command: env NOR2_POLICY_RUN_TAG=pre_backend_topo_nor2_mux41_no_x0x2_hvt NOR2_POLICY_DONT_USE="NOR2X0_HVT NOR2X2_HVT MUX41X2_HVT" NOR2_POLICY_LOG=2_Synthesis/3_Log/99_debug/run_dc_compile_topo_nor2_policy.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.sh
Scripts: 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.sh, 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.tcl
Log: 2_Synthesis/3_Log/99_debug/run_dc_compile_topo_nor2_policy.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log
Output root: 2_Synthesis/2_Output/pre_backend_topo_nor2_mux41_no_x0x2_hvt
Report root: 2_Synthesis/4_Report/99_debug/pre_backend_topo_nor2_mux41_no_x0x2_hvt
Key reports: nor2_dont_use_policy.rpt, nor2_dont_use_verify.rpt, post_compile.qor.rpt
Result: NOR2X0_HVT/NOR2X2_HVT/MUX41X2_HVT are dont_use=true and absent from mapped Verilog; MUX41X1_HVT count is 126.
Use: debug backend input for the DRC-clean route candidate; Formality R2N has now passed for this handoff.
```

```text
ICC2 VIA1 pitch/no-track NOR2+MUX41 route status: DEBUG_ROUTE_DRC_CLEAN_CANDIDATE
Command: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_mux41_policy_route_flow.sh
Script: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_mux41_policy_route_flow.sh
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow
ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_icc2_lib
Backend inputs: 2_Synthesis/2_Output/pre_backend_topo_nor2_mux41_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_mux41_no_x0x2_hvt.vg and matching SDC.
Result: 0 open nets; 0 signal DRC; legality TOTAL 0; PG connectivity VDD/VSS floating objects 0; PG DRC no errors; timing.max MET 0.78 ns; timing.min MET 0.04 ns.
Caveat: antenna checking is not active because no antenna rules are defined. VIA1 no-track library policy is now accepted; wrapper/manifest promotion remains before calling this the baseline route flow.
```

```text
Formality NOR2+MUX41 R2N status: PASS_WITH_NOTE
Command: env FM_RUN_TAG=pre_backend_topo_nor2_mux41_no_x0x2_hvt FM_LOG=3_Formality/3_Log/fm_r2n_topo.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log 3_Formality/0_Script/run_fm_r2n_topo.sh
Scripts: 3_Formality/0_Script/run_fm_r2n_topo.sh, 3_Formality/0_Script/run_fm_r2n_topo.tcl
Log: 3_Formality/3_Log/fm_r2n_topo.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log
Report root: 3_Formality/4_Report/pre_backend_topo_nor2_mux41_no_x0x2_hvt
Session: 3_Formality/2_Output/pre_backend_topo_nor2_mux41_no_x0x2_hvt/r2n_topo_fm_session.fss
Reference: filelists/ibex_mini_soc_fm_ref.f
Implementation: 2_Synthesis/2_Output/pre_backend_topo_nor2_mux41_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_mux41_no_x0x2_hvt.ddc
SVF: 2_Synthesis/2_Output/svf/ibex_mini_soc_top.pre_backend_topo_nor2_mux41_no_x0x2_hvt.svf
Result: Verification SUCCEEDED; 34915 passing compare points; 0 failing; 0 unmatched compare points; SVF guidance 2146 accepted and 0 rejected.
Caveat: synopsys_auto_setup and RTL interpretation warnings remain as in the official baseline.
```

```text
Backend library policy note status: APPROVED_FOR_PROJECT_BASELINE_PROMOTION
Document: docs/backend_library_policy.md
Scope: records the accepted VIA1 pitch/no-track physical-library policy for project baseline promotion.
Key delta: Layer "VIA1" enables pitch = 0.36 and removes onWireTrack/onGrid from a project-local techfile copy.
Evidence linked: NDM build log, DRC-clean route reports, PG/legal/timing sanity reports, and Formality R2N PASS.
Open gate: promote or explicitly alias the selected 99_debug wrapper/manifest path as the baseline backend flow.
```

```text
Backend route closure case study status: RECORDED
Document: docs/ibex_backend_route_closure_case_study.md
Scope: records goal, baseline result, DRC breakdown, hypotheses, experiment history, accepted 0-DRC candidate, production-promotion boundary, and interview explanation.
Key matrix: production route 720 DRC -> modified LEF 41 -> cleanup 20 -> NOR2 policy 19 -> diff blockage 18 -> VIA1 no-track + NOR2/MUX41 0.
Claim boundary: route DRC-clean candidate only; not antenna/LVS/IR/EM/signoff clean.
```

```text
DRC-clean candidate verifier status: PASS
Command: 4_Backend_ICC2/0_Script/99_debug/check_drc_clean_candidate.sh
Script: 4_Backend_ICC2/0_Script/99_debug/check_drc_clean_candidate.sh
Scope: lightweight report/log checker; does not run licensed EDA tools.
Coverage:
- route check_routes open nets 0 and DRC 0
- route legality TOTAL 0
- PG connectivity all floating counts 0
- route log PG DRC no errors
- timing.max/timing.min MET and no VIOLATED text
- antenna rule absence recorded
- Formality R2N Verification SUCCEEDED, 34915 passing, 0 failing, SVF guidance 0 rejected
- NDM build log has no TECH-025/TECH-006/LIB-007/Fatal/Error pattern
- patched VIA1 techfile has pitch = 0.36 and no onGrid/onWireTrack in the VIA1 section
Result: DRC_CLEAN_CANDIDATE_CHECK PASS
```

```text
Post-route electrical DRC route_opt probe status: PARTIAL_NOT_PROMOTED
Command: 4_Backend_ICC2/0_Script/09_post_route_electrical_closure/run_post_route_electrical_drc.sh
Scripts: 4_Backend_ICC2/0_Script/09_post_route_electrical_closure/run_post_route_electrical_drc.sh, run_post_route_electrical_drc.tcl
Report roots: 4_Backend_ICC2/4_Report/09_post_route_electrical_closure*
Result: max_transition 8 -> 0 and max_capacitance 228 -> 120 after route_opt iterations; iter4 stalled at 120.
Conclusion: useful diagnostic/partial cleanup only, not a promoted clean result.
```

```text
Post-route max-cap ECO status: PARTIAL_NOT_PROMOTED
Command: 4_Backend_ICC2/0_Script/10_post_route_maxcap_eco/run_post_route_maxcap_eco.sh
Scripts: 4_Backend_ICC2/0_Script/10_post_route_maxcap_eco/run_post_route_maxcap_eco.sh, run_post_route_maxcap_eco.tcl
Log: 4_Backend_ICC2/3_Log/10_post_route_maxcap_eco/run_post_route_maxcap_eco.log
Report root: 4_Backend_ICC2/4_Report/10_post_route_maxcap_eco
Output root: 4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/export
ICC2 library: 4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/ibex_mini_soc_top_post_route_maxcap_eco_icc2_lib
Result: ECO inserted 55 buffers and resized 65 cells; final ICC2 reports max_transition 0, max_capacitance 2, route DRC 31, open nets 0, legality 0, PG clean, timing positive.
Decision: not promoted; no further ECO repair per project-owner instruction.
Document: docs/post_route_electrical_drc_closure_attempt.md
```

```text
Final post-route cleanup status: PARTIAL_ELECTRICAL_DRC_REMAINS
Command: 4_Backend_ICC2/0_Script/11_post_route_final_cleanup/run_post_route_final_cleanup.sh
Scripts: 4_Backend_ICC2/0_Script/11_post_route_final_cleanup/run_post_route_final_cleanup.sh, run_post_route_final_cleanup.tcl
Log: 4_Backend_ICC2/3_Log/11_post_route_final_cleanup/run_post_route_final_cleanup.log
Report root: 4_Backend_ICC2/4_Report/11_post_route_final_cleanup
Output root: 4_Backend_ICC2/2_Output/11_post_route_final_cleanup/export
ICC2 library: 4_Backend_ICC2/2_Output/11_post_route_final_cleanup/ibex_mini_soc_top_post_route_final_cleanup_icc2_lib
Result: open nets 0, route DRC 0, legality 0, PG clean, timing positive, max_transition 0, max_capacitance 2.
Decision: keep as final bounded cleanup artifact; do not claim electrical DRC clean.
```

```text
Residual max-cap ECO status: PASS_WITH_NOTE
Command: 4_Backend_ICC2/0_Script/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.sh
Scripts: 4_Backend_ICC2/0_Script/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.sh, run_post_route_residual_maxcap_eco.tcl
Log: 4_Backend_ICC2/3_Log/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.log
Report root: 4_Backend_ICC2/4_Report/12_post_route_residual_maxcap_eco
Output root: 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export
Manifest: 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/post_route_residual_maxcap_eco_manifest.txt
ICC2 library: 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/ibex_mini_soc_top_post_route_residual_maxcap_eco_icc2_lib
Source block: ibex_mini_soc_top_post_route_final_cleanup
ECO block: ibex_mini_soc_top_post_route_residual_maxcap_eco
ECO method: eco_opt -types max_capacitance -physical_mode occupied_site, then bounded route_detail and route_eco cleanup.
ECO result: 2 residual max-cap violations before ECO; 1 inserted buffer; 1 size_cell command; remaining PrimeTime ECO violations 0.
Final route/electrical result: constraints.final.rpt reports max_transition 0, max_capacitance 0, min_capacitance 0; qor.final.rpt reports Nets with Violations 0, Max Trans Violations 0, Max Cap Violations 0; check_routes.final.rpt reports open nets 0 and route DRC 0.
Final sanity result: check_legality.final.rpt reports TOTAL 0; pg_connectivity.final.rpt reports VDD/VSS floating objects 0; check_pg_drc command reported No errors found; timing.max/min reports MET 0.64 ns / 0.04 ns.
Decision: accepted as an ICC2 internal post-route electrical/route clean candidate for this debug sequence. Claim boundary remains not signoff/tapeout clean.
```
