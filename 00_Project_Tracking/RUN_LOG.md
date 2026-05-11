# Run Log

## 2026-05-09

```text
Stage: project setup
Action: created initial project directory skeleton and tracking files
Status: PASS
Next action: clone lowRISC/ibex into rtl/ibex and record source revision
```

```text
Stage: RTL intake
Action: cloned https://github.com/lowRISC/ibex.git into rtl/ibex
Status: PASS
Commit: 9742d89f54fc297bed026841c8e68454ddfd7cc0
License: Apache-2.0
Initial filelist candidate: rtl/ibex/rtl/ibex_core.f
Next action: inspect Ibex parameters/core descriptors and freeze baseline config
```

```text
Stage: git publish setup
Action: added .gitignore to exclude rtl/ibex and EDA generated outputs; added scripts/git_project.sh for .git_local metadata
Status: IN_PROGRESS
Remote target: ssh://git@ssh.github.com:443/combipatal/ibex.git
Scope: scripts, docs, constraints, configs, AGENTS/init, and 00_Project_Tracking records only
Next action: initialize .git_local, commit scoped files, push to GitHub over SSH port 443
```

```text
Stage: git publish
Action: committed and pushed scoped project files to GitHub
Status: PASS
Remote: ssh://git@ssh.github.com:443/combipatal/ibex.git
Branch: main
Commit: 041887b Initialize Ibex Mini SoC flow records
Push output: main -> main, branch main set to track origin/main
Uploaded scope: .gitignore, AGENTS/init docs, project plan, docs, configs, constraints, filelists README, rtl/mini_soc README, scripts/git_project.sh, 00_Project_Tracking records
Excluded scope: rtl/ibex upstream clone, EDA outputs/logs/reports/runs
Next action: commit and push this publish log update
```

```text
Stage: RTL intake/config
Action: inspected ibex_core.sv, ibex_top.sv, ibex_core.core, ibex_top.core, and ibex_configs.yaml
Status: PASS_WITH_NOTE
Finding: ibex_core exposes register-file ports; ibex_top wraps register file and is safer for first Mini SoC baseline
Decision: freeze initial integration point to ibex_top inside ibex_mini_soc_top
Next action: create implementation filelists and Mini SoC RTL skeleton
```

```text
Stage: Mini SoC RTL/filelist/constraints
Action: created ibex_mini_soc_top, simple IMEM/DMEM/decoder/GPIO/timer RTL, DC/FM filelists, baseline 10ns SDC, and DC analyze smoke script
Status: RECORDED
Validation: filelist path existence check passed; Verilator unavailable in environment
Next action: run dc_shell outside sandbox using 2_Synthesis/0_Script/run_dc_analyze.tcl
```

```text
Stage: DC analyze smoke
Command: dc_shell -f 2_Synthesis/0_Script/run_dc_analyze.tcl -output_log_file 2_Synthesis/3_Log/dc_analyze.log
Status: FAILED
First fatal error: prim_lfsr.sv could not import prim_cipher_pkg; package missing from filelist
Log path: 2_Synthesis/3_Log/dc_analyze.log
Fix: added rtl/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_cipher_pkg.sv to filelists before prim_lfsr.sv
Next action: rerun DC analyze smoke
```

```text
Stage: DC analyze smoke
Command: dc_shell -f 2_Synthesis/0_Script/run_dc_analyze.tcl -output_log_file 2_Synthesis/3_Log/dc_analyze.log
Status: PASS_WITH_NOTE
Completion evidence: Presto compilation completed successfully; elaborated ibex_mini_soc_top; link completed; DDC written.
Output DDC: 2_Synthesis/2_Output/analyze/ibex_mini_soc_top.elab.ddc
Log path: 2_Synthesis/3_Log/dc_analyze.log
Check report: 2_Synthesis/4_Report/analyze/check_design.rpt
Hierarchy report: 2_Synthesis/4_Report/analyze/hierarchy.rpt
Warnings: check_design reports unconnected/unloaded/constant nets, mostly from disabled Ibex features and unused shadow/integrity outputs in the baseline wrapper.
Script update: 2_Synthesis/0_Script/run_dc_analyze.tcl now deletes 2_Synthesis/work_analyze before define_design_lib to make reruns clean.
Next action: create full DC synthesis script that reads the same top/config/filelist and writes mapped netlist/DDC/SVF/SDC reports.
```

```text
Stage: DC compile script prep
Action: added 2_Synthesis/0_Script/run_dc_compile.tcl
Status: READY_TO_RUN
Input evidence: same configs/library_setup.tcl and filelists/ibex_mini_soc_dc.tcl as analyze smoke
Expected outputs: mapped DDC/netlist/SVF/SDC/SDF under 2_Synthesis/2_Output/mapped
Expected reports: check_design, check_timing, QoR, setup/hold timing, area, power, constraints, references under 2_Synthesis/4_Report/compile
Next action: run dc_shell outside sandbox using 2_Synthesis/0_Script/run_dc_compile.tcl
```

```text
Stage: DC compile direction update
Action: user requested topographical compile and SVF-based handoff discipline
Status: SCRIPT_READY
Decision: official baseline is 2_Synthesis/0_Script/run_dc_compile_topo.tcl, run with dc_shell -topographical_mode
SVF policy: emit 2_Synthesis/2_Output/svf/ibex_mini_soc_top.pre_backend_topo.svf for Formality
STA policy: PrimeTime cannot read SVF directly; STA reads the same topo run netlist/SDC/SDF that produced the SVF
STA script: 5_STA/0_Script/run_pt_pre_backend_topo_sdf.tcl
Next action: run topographical DC compile, then run PT STA on the matched topo handoff files
```

```text
Stage: topo compile correction
Action: fixed SDC for read_sdc compatibility and added IMEM preload write ports
Status: READY_TO_RERUN
Reason: read_sdc did not accept remove_from_collection; read-only IMEM could be optimized as constant logic
Affected files: constraints/ibex_mini_soc_10ns.sdc, rtl/mini_soc/simple_imem.sv, rtl/mini_soc/ibex_mini_soc_top.sv
Next action: rerun topographical DC compile and regenerate SVF/netlist/SDC/SDF
```

```text
Stage: DC topographical compile
Command: dc_shell -topographical_mode -f 2_Synthesis/0_Script/run_dc_compile_topo.tcl -output_log_file 2_Synthesis/3_Log/dc_compile_topo.log
Status: PASS_WITH_NOTE
Completion evidence: mapped DDC/netlist/SDC/SDF and SVF generated.
Output DDC: 2_Synthesis/2_Output/pre_backend_topo/ibex_mini_soc_top.pre_backend_topo.ddc
Output netlist: 2_Synthesis/2_Output/pre_backend_topo/ibex_mini_soc_top.pre_backend_topo.vg
Output SDC: 2_Synthesis/2_Output/pre_backend_topo/ibex_mini_soc_top.pre_backend_topo.sdc
Output SDF: 2_Synthesis/2_Output/pre_backend_topo/ibex_mini_soc_top.pre_backend_topo.sdf
Formality SVF: 2_Synthesis/2_Output/svf/ibex_mini_soc_top.pre_backend_topo.svf
Log path: 2_Synthesis/3_Log/dc_compile_topo.log
QoR report: 2_Synthesis/4_Report/topo/post_compile.qor.rpt
Timing result: WNS 0.00 ns, TNS 0.00 ns, no setup/hold violating paths.
Area/cell result: cell area 414758.187451, leaf cells 109713.
SVF guidance update: script now enables hdlin_enable_hier_map before analyze and calls set_verification_top after elaboration.
Known notes: pre-backend max transition/cap violations remain; acceptable for this baseline handoff and to be revisited in backend closure.
Next action: run PrimeTime STA on the matching topo netlist/SDC/SDF.
```

```text
Stage: pre-backend STA
Command: 5_STA/0_Script/run_pt_pre_backend_topo_sdf.sh
Status: PASS_WITH_NOTE
Basis: PrimeTime reads the topo netlist/SDC/SDF from the same DC run that emitted the Formality SVF.
SVF policy: SVF is recorded as Formality provenance; PrimeTime does not read SVF directly.
Log path: 5_STA/3_Log/pt_pre_backend_topo_sdf.log
Global timing report: 5_STA/4_Report/pre_backend_topo/global_timing.rpt
Check timing report: 5_STA/4_Report/pre_backend_topo/check_timing.rpt
Coverage report: 5_STA/4_Report/pre_backend_topo/coverage.rpt
Annotated delay report: 5_STA/4_Report/pre_backend_topo/annotated_delay.rpt
Timing result: no setup violations, no hold violations.
Annotation result: 1002647 / 1002679 delay arcs annotated; 32 primary-output net arcs not annotated.
Coverage result: 139601 / 145136 checks met, 0 violated, 5535 untested.
Known notes: rst_ni has no clock-relative input delay; recovery/removal checks are untested under current async reset policy; pre-backend cap/transition violations are recorded for backend closure.
Next action: run Formality R2N using the generated SVF and matching DC filelist/config.
```

```text
Stage: Formality R2N first attempt
Command: 3_Formality/0_Script/run_fm_r2n_topo.sh
Status: STOPPED_BY_USER
Log path: 3_Formality/3_Log/fm_r2n_topo.log
Observed issue: Formality was active in verify for about 27 minutes on one CPU core, not hung at system level.
Root cause: DC SVF lacked guide_hier_map commands; Guidance Summary had 1044 rejected commands and 15 unmatched reference compare points.
Fix: updated 2_Synthesis/0_Script/run_dc_compile_topo.tcl to enable hdlin_enable_hier_map before RTL analyze and call set_verification_top after elaboration; regenerated DC topo handoff.
Next action: rerun Formality R2N using the regenerated SVF/DDC.
```

```text
Stage: Formality R2N
Command: 3_Formality/0_Script/run_fm_r2n_topo.sh
Status: PASS_WITH_NOTE
Basis: reference RTL from filelists/ibex_mini_soc_fm_ref.f, implementation DDC from 2_Synthesis/2_Output/pre_backend_topo, SVF from the matching DC topo run.
Log path: 3_Formality/3_Log/fm_r2n_topo.log
Setup report: 3_Formality/4_Report/pre_backend_topo/r2n_topo.setup_status.rpt
SVF accepted report: 3_Formality/4_Report/pre_backend_topo/r2n_topo.svf_accepted.rpt
SVF rejected report: 3_Formality/4_Report/pre_backend_topo/r2n_topo.svf_rejected.rpt
Failing report: 3_Formality/4_Report/pre_backend_topo/r2n_topo.failing_points.rpt
Unmatched report: 3_Formality/4_Report/pre_backend_topo/r2n_topo.unmatched_points.post_verify.rpt
Result: Verification SUCCEEDED; 34915 passing compare points; 0 failing compare points; 0 unmatched compare points.
SVF guidance result: 2146 accepted, 0 rejected; hier_map 33 accepted, 0 rejected.
Known notes: synopsys_auto_setup enabled; reference RTL interpretation warnings exist, including suppressed FMR_ELAB-116 messages; one clock-gate latch is reported as not compared.
Next action: start backend floorplan/powerplan setup from the FM-clean topo handoff.
```

```text
Stage: ICC2 NDM setup
Command: 4_Backend_ICC2/0_Script/00_setup/build_saed32_ndm.sh
Status: PASS_WITH_NOTE
Log path: 4_Backend_ICC2/3_Log/00_setup/build_saed32_ndm.log
Outputs: 4_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm, saed32lvt_tt.ndm, saed32hvt_tt.ndm
Result: SAED32 RVT/LVT/HVT NDM libraries created for backend use.
Known notes: SAED32 LEF/DB import warnings are recorded in the log; workspace checks completed and NDMs were written.
Next action: run ICC2 init_design from the FM-clean topo handoff.
```

```text
Stage: ICC2 init_design
Command: 4_Backend_ICC2/0_Script/01_init_design/run_init_design_check.sh
Status: PASS_WITH_NOTE
Log path: 4_Backend_ICC2/3_Log/01_init_design/run_init_design_check.log
Check design report: 4_Backend_ICC2/4_Report/01_init_design/check_design.rpt
Timing report: 4_Backend_ICC2/4_Report/01_init_design/timing.rpt
Result: design linked successfully; 0 errors in check_design; timing slack MET 1.88 ns in initial estimated timing.
Known notes: ICC2 reports unsupported set_load constraints from the DC SDC; unconstrained/unused style warnings are recorded for closure tracking.
Next action: create initial floorplan.
```

```text
Stage: ICC2 floorplan
Command: 4_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.sh
Status: PASS_WITH_NOTE
Log path: 4_Backend_ICC2/3_Log/02_floorplan/run_floorplan_initial.log
Utilization report: 4_Backend_ICC2/4_Report/02_floorplan/utilization.rpt
QoR report: 4_Backend_ICC2/4_Report/02_floorplan/qor.rpt
Result: initial 1:1 floorplan created; utilization 0.6004; core bbox {20 20} {851.288 850.984}; no setup/hold violations in estimated QoR.
Next action: create initial power plan.
```

```text
Stage: ICC2 powerplan
Command: 4_Backend_ICC2/0_Script/03_powerplan/run_powerplan_initial.sh
Status: PASS_WITH_NOTE
Log path: 4_Backend_ICC2/3_Log/03_powerplan/run_powerplan_initial.log
PG DRC report: 4_Backend_ICC2/4_Report/03_powerplan/pg_drc.rpt
PG connectivity report: 4_Backend_ICC2/4_Report/03_powerplan/pg_connectivity.rpt
Result: initial VDD/VSS rail/ring/mesh generated; PG DRC reports no errors.
Open issue: PG connectivity is not clean. VDD reports 3142 std-cell unconnected ports and VSS reports 380 std-cell unconnected ports, with isolated rail paths recorded in pg_connectivity.rpt.
Rejected experiment: denser M2/M3/M8 mesh variants reduced/shifted connectivity symptoms but introduced thousands of M1 spacing DRCs, so the DRC-clean baseline mesh was restored.
Next action: continue placement while tracking PG connectivity as an open backend issue.
```

```text
Stage: ICC2 placement
Command: 4_Backend_ICC2/0_Script/04_place/run_place_initial.sh
Status: PASS_WITH_NOTE
Log path: 4_Backend_ICC2/3_Log/04_place/run_place_initial.log
Legality report: 4_Backend_ICC2/4_Report/04_place/check_legality.rpt
QoR report: 4_Backend_ICC2/4_Report/04_place/place_qor.rpt
Timing report: 4_Backend_ICC2/4_Report/04_place/timing.rpt
Result: placement/legalization completed; check_legality TOTAL 0 violations; WNS/TNS 0; setup slack approximately 0.06 ns in estimated post-place timing.
Open issue: PG connectivity issue from powerplan persists after placement.
Next action: run CTS from placed design.
```

```text
Stage: ICC2 CTS first attempts
Command: 4_Backend_ICC2/0_Script/05_cts/run_cts_initial.sh
Status: ABORTED_TO_DEBUG
Log archive 1: 4_Backend_ICC2/3_Log/05_cts_aborted_20260509_2213/run_cts_initial.log
Log archive 2: 4_Backend_ICC2/3_Log/05_cts_aborted_20260509_2220/run_cts_initial.log
Stack trace archive: 4_Backend_ICC2/3_Log/05_cts_aborted_20260509_2213/Synopsys_stack_trace_3034893.txt and 4_Backend_ICC2/3_Log/05_cts_aborted_20260509_2220/Synopsys_stack_trace_3044997.txt
Observed issue: duplicated CTS runs wrote the same current log path during debug, so partial logs were quarantined as aborted and are not accepted as signoff evidence.
Fatal point: ICC2 reported an internal system error during clock_opt/CTS, including a message that fatal optimization occurred near U24139/Y in one aborted run.
Process note: host ps showed individual icc2_exec processes near 100 percent CPU; this means roughly one logical CPU core per process, not whole-server 100 percent CPU usage.
Current policy: do not add script-level atomic locks because this project area may be shared across users/projects; check active processes manually before launching shared-step reruns.
Next action: inspect CTS Tcl/options and rerun from a clean log/report directory with only one active CTS process.
```

```text
Stage: ICC2 CTS clean retry
Command: 4_Backend_ICC2/0_Script/05_cts/run_cts_initial.sh
Status: PASS_WITH_NOTE
Start time: 2026-05-09 22:19 KST
End time: 2026-05-09 22:33 KST
Log path: 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log
Clock tree report: 4_Backend_ICC2/4_Report/05_cts/check_clock_trees.post.rpt
Clock QoR report: 4_Backend_ICC2/4_Report/05_cts/clock_qor.summary.rpt
Timing max report: 4_Backend_ICC2/4_Report/05_cts/timing.max.rpt
Timing min report: 4_Backend_ICC2/4_Report/05_cts/timing.min.rpt
Legality report: 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt
PG connectivity report: 4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt
PG DRC report: 4_Backend_ICC2/4_Report/05_cts/pg_drc.rpt
Result: clean single-process CTS completed. The previous Phase 6 Iter 2 no-output interval was not a hang; it advanced after several minutes.
Completion evidence: clock tree compilation finished successfully; clock route detail routing finished with 0 open nets and 0 DRCs; check_legality reports TOTAL 0 violations; check_pg_drc reports no errors.
Timing result: timing.max worst reported slack MET 0.63 ns; timing.min worst reported slack MET 0.04 ns; qor.rpt reports total negative slack 0.00.
Diagnosis result: duplicate/contaminated CTS logs caused a misleading failure picture. The earlier Error code=15/Terminated fatal artifact is not accepted as a clean tool-crash reproduction.
Known notes: log still includes many intermediate ZRT-763 overlap warnings during CTS/routing analysis, but final check_legality is clean. Default max transition/default voltage warnings remain to be cleaned up later.
Open issue: PG connectivity is still not clean. VDD reports 3358 floating std cells and VSS reports 415 floating std cells in 05_cts pg_connectivity.rpt. PG DRC remains clean.
Next action: continue to route only with PG connectivity tracked as an open backend issue, or fix PG rail connectivity before route if strict backend strong-done criteria are required.
```

```text
Stage: ICC2 PG diagnosis - M7 offset sweep
Command: 4_Backend_ICC2/0_Script/99_debug/run_pg_m7_offset_sweep.sh
Status: PASS_WITH_NOTE
Basis: debug copy of the accepted CTS design; production ICC2 block not modified.
Result: M7 offset changes only shifted the VDD/VSS floating-cell distribution and did not produce a clean PG connectivity case.
Observed range: best tested VSS case still had VDD 3412 floating std cells at offset 18; current offset 28 matched baseline shape with VDD 3358 and VSS 415 floating std cells.
Conclusion: horizontal M7 offset alone is not the root fix.
Next action: test lower-metal/stdcell rail interaction with an M2 sweep and modified LEF NDM probe.
```

```text
Stage: ICC2 PG diagnosis - M2 sweep
Command: 4_Backend_ICC2/0_Script/99_debug/run_pg_m2_sweep.sh
Status: PASS_WITH_NOTE
Basis: debug copy of the accepted CTS design; production ICC2 block not modified.
Initial result: tested M2 pitch/offset variants with width fixed at 0.4 produced the same PG connectivity counts as baseline, VDD 3358 and VSS 415 floating std cells.
Follow-up result: M2 pitch 20.0, offset 0.0, width 0.2 reduced VDD floating std cells to 0 and left VSS at 415.
Conclusion: M2 pitch/offset alone is not the root fix, but M2 width/geometry is a primary cause axis for rail-to-mesh via cleanup.
Next action: diagnose the remaining top-side VSS rail with M2 width 0.2 held fixed.
```

```text
Stage: ICC2 modified LEF NDM build
Command: 4_Backend_ICC2/0_Script/99_debug/build_modified_lef_ndm.sh
Status: PASS_WITH_NOTE
LEF source: /DATA/home/edu135/lib/libdir/LEF/modify
Log path: 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_ndm.log
Outputs: 4_Backend_ICC2/2_Output/99_debug/modified_lef_pg_probe/ndm/saed32rvt_tt.modified_lef.ndm, saed32lvt_tt.modified_lef.ndm, saed32hvt_tt.modified_lef.ndm
Result: workspace checks succeeded and RVT/LVT/HVT modified-LEF NDM libraries were written.
Known notes: NDM import warnings are recorded in the log, including LEF bus-bit and large M1 blockage warnings.
Next action: run placement-aware PG probe using the modified-LEF NDM libraries.
```

```text
Stage: ICC2 modified LEF PG probe
Command: 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_pg_probe.sh
Status: PASS_WITH_NOTE
Basis: separate debug ICC2 library using modified-LEF NDMs; same DC topo netlist/SDC and same initial floorplan/PG strategy; production ICC2 block not modified.
Log path: 4_Backend_ICC2/3_Log/99_debug/run_modified_lef_pg_probe.log
Summary report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_pg_probe/summary.tsv
PG connectivity report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_pg_probe/pg_connectivity.rpt
PG DRC report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_pg_probe/pg_drc.rpt
Result: placement and legalization completed; compile_pg recognized 109713 standard cells; PG DRC reported no errors.
Comparison: baseline CTS PG connectivity was VDD 3358 and VSS 415 floating std cells; modified-LEF probe reports VDD 3196 and VSS 396 floating std cells, with the same 7 VDD and 1 VSS floating wires.
Conclusion: modified LEF NDM slightly changes the symptom but does not resolve the PG connectivity issue. No front-end/DC/FM rerun is required for this LEF-only physical abstract test, and switching production backend to modified LEF is not justified as a fix yet.
Next action: diagnose stdcell rail-to-mesh/via access or row/rail alignment directly before route, or proceed to route only with PG connectivity explicitly classified as open.
```

```text
Stage: ICC2 PG diagnosis - floating rail shape inspection
Command: 4_Backend_ICC2/0_Script/99_debug/inspect_pg_floating_shapes.sh
Status: PASS_WITH_NOTE
Basis: debug copy of the accepted CTS design; production ICC2 block not modified.
Report: 4_Backend_ICC2/4_Report/99_debug/pg_floating_shape_inspect/shape_summary.tsv
Result: all listed floating objects are M1 lib_cell_pin_connect stdcell rails spanning the core width. The repeated VDD floating rail y locations are 327.618/367.746/407.874/448.002/488.130/528.258/568.386, and the residual VSS rail is y 827.546.
Conclusion: the issue is isolated stdcell rail rows with zero vias to the higher PG network, not unconnected logical PG pins.
Next action: hold M2 pitch 20/width 0.2 and test top-edge/M7/ring-boundary fixes for the remaining VSS rail.
```

```text
Stage: ICC2 PG diagnosis - combined M2/M7 probes
Command: 4_Backend_ICC2/0_Script/99_debug/run_pg_m2_sweep.sh with PG_M2_CASES and PG_M7_OFFSET overrides
Status: PASS_WITH_NOTE
Basis: debug copy of the accepted CTS design; production ICC2 block not modified.
Best tested case: M2 pitch 20.0, offset 0.0, width 0.2 with M7 offset 28.0.
Best result: VDD floating std cells 0; VSS floating std cells 415; VDD floating wires 0; VSS floating wires 1.
Rejected variants: M7 offset 18 with M2 width 0.2 worsened VSS to 931; M7 offset 30 worsened VSS to 3443.
Mesh boundary check: changing core mesh stop from innermost_ring to design_boundary kept the same best-case residual, VDD 0 and VSS 415.
Conclusion: M2 width/geometry fixes the major VDD rail isolation, while the remaining VSS issue is a top-side rail stitch/parity issue. M7 offset alone and mesh stop boundary alone are not clean fixes.
Next action: test targeted top-side VSS connection or ring/mesh stitch adjustment around PATH_11_483.
```

## 2026-05-10

```text
Stage: ICC2 PG diagnosis - baseline local rail stitch
Command: 4_Backend_ICC2/0_Script/99_debug/probe_baseline_pg_local_stitches.sh
Status: PASS_WITH_NOTE
Basis: debug ICC2 library; production block not modified during probe.
Log path: 4_Backend_ICC2/3_Log/99_debug/probe_baseline_pg_local_stitches.log
Summary report: 4_Backend_ICC2/4_Report/99_debug/baseline_pg_local_stitches/summary.tsv
Rejected attempt: creating M1-M2 stitch vias under existing M2-M7 via stacks fixed connectivity but left 12 same-net cut-spacing PG DRCs.
Accepted attempt: remove local conflicting upper stacked vias first, then add explicit M1-M2 rail stitch vias.
Result: removed 48 conflicting upper vias; created 8 M1-M2 stitch vias; VDD/VSS floating std cells 0; VDD/VSS floating wires 0; PG DRC errors 0.
Conclusion: PG issue is a local rail-to-mesh via conflict/cleanup problem, not modified LEF, front-end logic, DC, or Formality mismatch.
Next action: port the targeted stitch into production powerplan and rerun backend from powerplan onward.
```

```text
Stage: ICC2 powerplan rerun with PG rail stitch fix
Command: 4_Backend_ICC2/0_Script/03_powerplan/run_powerplan_initial.sh
Status: PASS_WITH_NOTE
Log path: 4_Backend_ICC2/3_Log/03_powerplan/run_powerplan_initial.log
Stitch report: 4_Backend_ICC2/4_Report/03_powerplan/pg_rail_stitches.rpt
PG connectivity report: 4_Backend_ICC2/4_Report/03_powerplan/pg_connectivity.rpt
PG DRC report: 4_Backend_ICC2/4_Report/03_powerplan/pg_drc.rpt
Result: production powerplan removed 48 local conflicting upper vias and added 8 M1-M2 rail stitches; VDD/VSS floating objects 0; PG DRC reports no errors.
Next action: rerun placement and CTS from the corrected powerplan block.
```

```text
Stage: ICC2 placement rerun after PG fix
Command: 4_Backend_ICC2/0_Script/04_place/run_place_initial.sh
Status: PASS_WITH_NOTE
Log path: 4_Backend_ICC2/3_Log/04_place/run_place_initial.log
Legality report: 4_Backend_ICC2/4_Report/04_place/check_legality.rpt
PG connectivity report: 4_Backend_ICC2/4_Report/04_place/pg_connectivity.rpt
PG DRC report: 4_Backend_ICC2/4_Report/04_place/pg_drc.rpt
Timing report: 4_Backend_ICC2/4_Report/04_place/timing.rpt
Result: legality TOTAL 0; VDD/VSS floating objects 0; PG DRC no errors; worst reported setup slack MET 0.07 ns.
Known notes: route-analysis overlap warnings appear during placement, but final check_legality is clean.
Next action: rerun CTS.
```

```text
Stage: ICC2 CTS rerun after PG fix
Command: 4_Backend_ICC2/0_Script/05_cts/run_cts_initial.sh
Status: PASS_WITH_NOTE
Log path: 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log
Clock tree report: 4_Backend_ICC2/4_Report/05_cts/check_clock_trees.post.rpt
Legality report: 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt
Timing max report: 4_Backend_ICC2/4_Report/05_cts/timing.max.rpt
Timing min report: 4_Backend_ICC2/4_Report/05_cts/timing.min.rpt
PG connectivity report: 4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt
PG DRC report: 4_Backend_ICC2/4_Report/05_cts/pg_drc.rpt
Result: clock tree compilation finished successfully; clock route detail routing finished with 0 open nets and 0 DRCs; legality TOTAL 0; VDD/VSS floating objects 0; PG DRC no errors.
Timing result: timing.max worst reported slack MET 0.43 ns; timing.min worst reported slack MET 0.03 ns.
Next action: run initial signal route.
```

```text
Stage: ICC2 route
Command: 4_Backend_ICC2/0_Script/06_route/run_route_initial.sh
Status: COMPLETE_WITH_OPEN_SIGNAL_DRC
Log path: 4_Backend_ICC2/3_Log/06_route/run_route_initial.log
Route report: 4_Backend_ICC2/4_Report/06_route/check_routes.rpt
Legality report: 4_Backend_ICC2/4_Report/06_route/check_legality.rpt
Timing max report: 4_Backend_ICC2/4_Report/06_route/timing.max.rpt
Timing min report: 4_Backend_ICC2/4_Report/06_route/timing.min.rpt
PG connectivity report: 4_Backend_ICC2/4_Report/06_route/pg_connectivity.rpt
PG DRC report: 4_Backend_ICC2/4_Report/06_route/pg_drc.rpt
Result: route_auto completed and block was saved; 0 open nets; legality TOTAL 0; VDD/VSS floating objects 0; PG DRC no errors.
Timing result: timing.max worst reported slack MET 0.57 ns; timing.min worst reported slack MET 0.03 ns.
Open issue: signal route DRC remains 720 in check_routes.rpt: Diff net spacing 251, Less than minimum area 24, Needs fat contact 347, Off-grid 92, Short 6.
Diagnosis note: 00_Project_Tracking/ROUTE_DIAGNOSIS_NOTES.md
Next action: diagnose route DRC closure with a targeted route-option or floorplan/utilization experiment; do not claim route DRC clean.
```

```text
Stage: ICC2 route DRC diagnosis - detailed error data inspection
Command: 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
Status: PASS_WITH_NOTE
Basis: current routed ICC2 block opened for report-only debug; no save_block/save_lib executed.
Log path: 4_Backend_ICC2/3_Log/99_debug/inspect_route_drc.log
Report directory: 4_Backend_ICC2/4_Report/99_debug/route_drc_inspect
Matrix report: 4_Backend_ICC2/4_Report/99_debug/route_drc_inspect/drc_matrix.rpt
Result: all 720 signal-route DRCs are on M1/M2/VIA1. M1 has 263, M1-M2 has 347 Needs fat contact, M2 has 67, VIA1 has 43.
Conclusion: route DRC is a lower-metal/pin-access/contact issue, not PG. Next route experiments should target via/contact/via-ladder or physical abstract setup before utilization sweeps.
```

```text
Stage: ICC2 route DRC diagnosis - detail_extra probe
Command: ROUTE_DRC_VARIANT=detail_extra 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Status: ABORTED_AFTER_DIAGNOSTIC_SIGNAL
Basis: debug-only in-memory route_detail probe; production block not saved.
Original log path: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.detail_extra.log
Artifact note: this default log path was later reused by a modified-LEF detail_extra probe before ROUTE_DRC_VARIANT_LOG override support was added; use the recorded observation below as the retained result for this historical probe.
Observation: additional detail routing reduced DRC from 720 to about 669 at iteration 40 and stayed around 660-680; iteration 46 summary was 671 DRCs.
Conclusion: more detail-route iteration alone is not sufficient for closure.
```

```text
Stage: ICC2 route DRC diagnosis - reroute_m2 probe
Command: ROUTE_DRC_VARIANT=reroute_m2 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Status: ABORTED_AFTER_DIAGNOSTIC_SIGNAL
Basis: debug-only in-memory reroute after removing signal/clock route shapes; production block not saved.
Log path: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.reroute_m2.log
Routability report: 4_Backend_ICC2/4_Report/99_debug/route_drc_variants/reroute_m2/check_routability.rpt
Observation: min-routing-layer M2 reroute entered detail routing with DRC rising above 11000 before the probe was stopped.
Conclusion: simply avoiding M1 makes pin-access/congestion much worse and is rejected as a route fix.
```

```text
Stage: ICC2 route DRC diagnosis - fat_contact_effort probe
Command: ROUTE_DRC_VARIANT=fat_contact_effort 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Status: ABORTED_AFTER_DIAGNOSTIC_SIGNAL
Basis: debug-only in-memory route_detail probe; production block not saved.
Log path: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.fat_contact_effort.log
Option report: 4_Backend_ICC2/4_Report/99_debug/route_drc_variants/fat_contact_effort/app_options.after.rpt
Observation: setting route.detail.fat_metal_forbidden_pitch_effort_level=high and route.detail.optimize_wire_via_effort_level=high reduced Needs fat contact as low as 239 at iteration 43, but Diff net spacing rose as high as 361 and total DRC remained around 660-672.
Conclusion: the route options touch the suspected contact/fat-contact issue, but they are not a standalone production fix because they trade contact DRC for spacing DRC.
```

```text
Stage: ICC2 modified-LEF full backend route debug
Command: 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Status: COMPLETE_WITH_RESIDUAL_SIGNAL_DRC
Basis: debug-only full backend rerun with modified-LEF NDMs and separate ICC2 library/report/log roots; production ICC2 library was not overwritten.
Modified NDM inputs: 4_Backend_ICC2/2_Output/99_debug/modified_lef_pg_probe/ndm/saed32{rvt,lvt,hvt}_tt_modified.ndm
ICC2 library output: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_route_flow
Route log: 4_Backend_ICC2/3_Log/99_debug/modified_lef_route_flow/06_route.log
Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/check_routes.rpt
Legality report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/check_legality.rpt
PG connectivity report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/pg_connectivity.rpt
PG DRC report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/pg_drc.rpt
Timing reports: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_flow/06_route/timing.max.rpt, timing.min.rpt
Result: wrapper completed with MOD_LEF_ROUTE_FLOW DONE. Route reports 0 open nets and 41 signal DRCs: Diff net spacing 1, Off-grid 39, Short 1. Needs fat contact is eliminated in the final route report.
Sanity checks: legality TOTAL 0; PG connectivity VDD/VSS floating objects 0; route log reports check_pg_drc No errors found; timing.max worst slack MET 0.74 ns; timing.min worst slack MET 0.04 ns.
Caveats: route is still not DRC clean; route log still reports CO default contact and MUX41X2_HVT/S0 via-region warnings; QoR still reports max transition/cap violations.
Conclusion: modified LEF/physical abstract setup is a strong route-DRC root-cause direction and is much better than route-option-only probes, but it is not yet a clean production baseline.
```

```text
Stage: ICC2 modified-LEF residual route DRC inspection
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib ROUTE_DRC_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
Status: PASS_WITH_NOTE
Basis: report-only open of the modified-LEF routed debug block; no save_block/save_lib executed.
Log path: 4_Backend_ICC2/3_Log/99_debug/inspect_route_drc.log
Report directory: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect
Matrix report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_inspect/drc_matrix.rpt
Result: residual 41 DRCs are all on M1/M2/VIA1. M1 has 3 total: Diff net spacing 1, Off-grid 1, Short 1. M2 has 19 Off-grid. VIA1 has 19 Off-grid.
Observation: most residual Off-grid DRCs are paired M2/VIA1 entries at near-identical coordinates, consistent with a small set of off-grid via/metal placements rather than a broad route congestion issue.
Next action: target residual off-grid cleanup/via snapping or localized DRC repair on the modified-LEF block before any broader utilization or route-option sweep.
```

```text
Stage: ICC2 modified-LEF residual DRC cleanup probe - detail_extra
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_flow/ibex_mini_soc_top_modified_lef_route_icc2_lib ROUTE_DRC_VARIANT=detail_extra ROUTE_DRC_VARIANT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Status: PASS_WITH_NOTE
Basis: debug-only in-memory incremental route_detail probe on the modified-LEF routed block; no save_block/save_lib executed.
Log path: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.modified_lef_detail_extra.log
Report directory: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra
Before report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra/before_check_routes.rpt
After report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra/after_check_routes.rpt
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/detail_extra/summary.tsv
Result: DRC reduced from 41 to 20 with 0 open nets. Final breakdown: Off-grid 19, Short 1.
Conclusion: a small incremental detail-route cleanup removes about half of the residual modified-LEF DRCs, but still does not produce a DRC-clean route. Next work should inspect the remaining 19 Off-grid and 1 Short locations.
```

```text
Stage: ICC2 modified-LEF cleanup saved candidate
Command: 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
Status: SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC
Basis: debug-only copied ICC2 library; production ICC2 library was not overwritten.
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved/summary.tsv
Result: after saved cleanup, 0 open nets and 20 signal DRCs: Off-grid 19, Short 1. Legality TOTAL 0; PG connectivity VDD/VSS floating objects 0; route log check_pg_drc reports No errors found; timing.max slack MET 0.74 ns; timing.min slack MET 0.04 ns.
Next action: inspect/fix 19 VIA1 Off-grid DRCs and 1 M1 Short before promotion.
```

```text
Stage: ICC2 saved modified-LEF cleanup DRC inspection
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib ROUTE_DRC_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect ROUTE_DRC_INSPECT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_route_drc.modified_lef_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
Status: PASS_WITH_NOTE
Basis: report-only open of saved debug cleanup candidate; no save_block/save_lib executed.
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect
Matrix report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect/drc_matrix.rpt
Via attribute report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_drc_inspect/offgrid_via_attrs.tsv
Result: residual DRC matrix is VIA1 Off-grid 19 and M1 Short 1. All 19 Off-grid entries are VIA12SQ_C M1-M2 vias with array_size 2 1 / rows 2 / cols 1.
Conclusion: Off-grid is tied to router-generated VIA12SQ_C 2-row array geometry, not via-center track snapping.
```

```text
Stage: ICC2 residual VIA1 Off-grid probes on saved modified-LEF cleanup candidate
Commands: probe_remove_offgrid_via1.sh, probe_shrink_offgrid_via1_array.sh, probe_replace_offgrid_via1_def.sh, and probe_route_drc_variant.sh variants via_array_off/via1_on_grid/via_ladder_clean/via1_offgrid_cost.
Status: DIAGNOSED_NO_ACCEPTED_FIX
Basis: debug-only in-memory probes; no save_block/save_lib executed.
Key reports:
- 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_by_net_bbox_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_repair_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_repair_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_replace_offgrid_via1_def_VIA12SQ_C_1x2_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via1_on_grid_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_ladder_clean_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via1_offgrid_cost20_cleanup_saved/summary.tsv
Result: removing vias eliminates Off-grid but creates 14 open nets; shrinking to 1x1 eliminates Off-grid but creates open/fat-contact/min-area DRC; via_array_mode=off eliminates Off-grid but creates Needs fat contact 9 and Short 11; via_on_grid, via_ladder_clean, and off-grid cost max 20 are unchanged.
Conclusion: no route-option or object-level probe produced a DRC-clean connected candidate.
```

```text
Stage: ICC2 residual M1 Short inspection and targeted ECO probes
Inspect command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib SHORT_INSPECT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_short_inspect SHORT_INSPECT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_short_area.modified_lef_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_short_area.sh
ECO commands: probe_short_net_eco.sh with SHORT_ECO_NET=n48420 and modes eco_only, remove_detail_then_eco
Status: DIAGNOSED_NO_ACCEPTED_FIX
Reports:
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_short_inspect/short_area_objects.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_short_net_eco_n48420_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_short_net_remove_detail_eco_n48420_cleanup_saved/summary.tsv
Result: short DRC object resolves to net n48420 near M1 detail route and VSS M1 lib_cell_pin_connect rail. Targeted route_eco and remove-detail-then-route_eco both end unchanged at 20 DRC = Off-grid 19 and Short 1.
Conclusion: residual short is not fixed by ordinary route_eco on the DRC net.
```

```text
Stage: ICC2 VIA12SQ_C row-limit NDM route probe
Command: 4_Backend_ICC2/0_Script/99_debug/run_via12sqc_row1_route_flow.sh
Status: COMPLETE_WITH_RESIDUAL_SIGNAL_DRC_REJECTED
Basis: debug-only backend run using project-local generated tech file with ContactCode "VIA12SQ_C" maxNumRowsNonTurning = 1.
Generated tech: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via12sqc_row1/tech/saed32nm_1p9m_mw.via12sqc_row1.tf
NDM build log: 4_Backend_ICC2/3_Log/99_debug/build_via12sqc_row1_ndm.log
Route log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_via12sqc_row1_route_flow
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via12sqc_row1_route_flow
Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via12sqc_row1_route_flow/06_route/check_routes.rpt
Result: 0 open nets; 41 DRC = Diff net spacing 1, Off-grid 39, Short 1. Legality TOTAL 0; PG connectivity clean; PG DRC no errors; timing.max slack MET 0.74 ns; timing.min slack MET 0.04 ns.
Conclusion: row-limit tech-only change did not improve residual DRC; do not promote.
```

```text
Stage: ICC2 residual VIA definition and split-via probes
Commands:
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib VIA_DEF_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_via_def_inspect2 4_Backend_ICC2/0_Script/99_debug/inspect_via_defs.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib SPLIT_VIA_PROBE_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_cleanup_saved 4_Backend_ICC2/0_Script/99_debug/probe_split_offgrid_via1_array.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib SPLIT_VIA_PROBE_REPAIR=1 SPLIT_VIA_PROBE_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_repair_cleanup_saved 4_Backend_ICC2/0_Script/99_debug/probe_split_offgrid_via1_array.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib SPLIT_VIA_AXIS=x SPLIT_VIA_PROBE_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_x_cleanup_saved 4_Backend_ICC2/0_Script/99_debug/probe_split_offgrid_via1_array.sh
Status: DIAGNOSED_NO_ACCEPTED_FIX
Reports:
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_via_def_inspect2/via_defs.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_repair_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_split_offgrid_via1_array_x_cleanup_saved/summary.tsv
Result: direct get_via_defs queries for VIA12SQ_C-style names return 0; y-axis split worsens to 115 DRC before repair and route_detail returns to original 20 DRC; x-axis split worsens to 167 DRC and creates 10 open nets.
Conclusion: direct split/replacement ECO is not a viable residual DRC fix.
```

```text
Stage: ICC2 extended cleanup on saved modified-LEF candidate
Command: env MOD_LEF_CLEANUP_SRC_LIB=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib MOD_LEF_CLEANUP_LIB=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_iter50_saved/ibex_mini_soc_top_modified_lef_cleanup_iter50_icc2_lib MOD_LEF_CLEANUP_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_iter50_saved MOD_LEF_CLEANUP_LOG=4_Backend_ICC2/3_Log/99_debug/save_modified_lef_detail_cleanup_iter50.log MOD_LEF_CLEANUP_START_ITER=50 MOD_LEF_CLEANUP_MAX_ITER=50 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
Status: SAVED_REJECTED_CANDIDATE
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_iter50_saved/ibex_mini_soc_top_modified_lef_cleanup_iter50_icc2_lib
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_iter50_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_iter50_saved/summary.tsv
Result: before 20 DRC/open0; after 21 DRC/open0 = Diff net spacing 1, Off-grid 20, Short 0.
Conclusion: longer cleanup removes the one short but increases total/off-grid DRC; keep the previous 20-DRC saved candidate as best artifact.
```

```text
Stage: ICC2 residual route-option combination probe on saved modified-LEF candidate
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib ROUTE_DRC_VARIANT=via_array_off_fat_contact ROUTE_DRC_VARIANT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_fat_contact_cleanup_saved ROUTE_DRC_VARIANT_LOG=4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.via_array_off_fat_contact_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Status: REJECTED_NO_ACCEPTED_FIX
Basis: debug-only in-memory probe; no save_block/save_lib executed.
Script update: 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.tcl now supports via_array_off_fat_contact.
Log: 4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.via_array_off_fat_contact_cleanup_saved.log
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_fat_contact_cleanup_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv
Result: Off-grid changed from 19 to 0, but total DRC stayed 20 with Needs fat contact 9 and Short 11; open nets stayed 0.
Conclusion: combining via_array_mode=off with high fat-contact/wire-via route effort still trades DRC class rather than closing route DRC.
```

```text
Stage: ICC2 residual Off-grid context inspection
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib OFFGRID_CONTEXT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_offgrid_context OFFGRID_CONTEXT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_offgrid_context.modified_lef_cleanup_saved.log bash 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.sh
Status: PASS_WITH_NOTE
Basis: debug-only read-only inspection; no save_block/save_lib executed.
Scripts: 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.sh, 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.tcl
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_offgrid_context
Context report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_route_cleanup_saved_offgrid_context/offgrid_context.tsv
Result: each residual Off-grid location is near a NOR2 A1/VSS pin-access context; the A1 pin instances map to NOR2X0_HVT or NOR2X2_HVT in the synthesis netlist. NOR2 LEF macros compare identical between SAED32_EDK and libdir, so the residual is not explained by the OR2-only libdir LEF edits alone.
Conclusion: residual DRC is lower-metal NOR2 pin-access/via-array behavior in dense placement, not a simple OR2 abstract mismatch.
```

```text
Stage: ICC2 targeted NOR2 resize ECO probe
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_route_cleanup_saved/ibex_mini_soc_top_modified_lef_cleanup_icc2_lib NOR2_RESIZE_TARGET=NOR2X4_HVT NOR2_RESIZE_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved NOR2_RESIZE_LOG=4_Backend_ICC2/3_Log/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved.log bash 4_Backend_ICC2/0_Script/99_debug/probe_resize_offgrid_nor2.sh
Status: REJECTED_BREAKS_CONNECTIVITY
Basis: debug-only in-memory ECO probe; no save_block/save_lib executed.
Scripts: 4_Backend_ICC2/0_Script/99_debug/probe_resize_offgrid_nor2.sh, 4_Backend_ICC2/0_Script/99_debug/probe_resize_offgrid_nor2.tcl
Report root: 4_Backend_ICC2/4_Report/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/probe_resize_offgrid_nor2_x4_cleanup_saved/summary.tsv
Result: before 20 DRC/open0; after final check_routes 43 DRC/open19 = Diff net spacing 4, Less than minimum area 9, Off-grid 17, Short 8. During route_detail the best transient DRC was 17, but the final routed block is not connected.
Conclusion: direct post-route resize of the 19 nearby NOR2 cells is not a valid fix.
```

```text
Stage: DC topo NOR2 cell-use policy debug synthesis
Command: env NOR2_POLICY_RUN_TAG=pre_backend_topo_nor2_no_x0x2_hvt 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.sh
Status: PASS_WITH_PRE_BACKEND_DRC_NOTE
Script: 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.tcl
Log: 2_Synthesis/3_Log/99_debug/run_dc_compile_topo_nor2_policy.pre_backend_topo_nor2_no_x0x2_hvt.log
Output root: 2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt
Report root: 2_Synthesis/4_Report/99_debug/pre_backend_topo_nor2_no_x0x2_hvt
Policy: NOR2X0_HVT and NOR2X2_HVT are set dont_use before compile_ultra.
Evidence: nor2_dont_use_verify.rpt reports both cells dont_use=true; the mapped Verilog contains 0 NOR2X0_HVT/NOR2X2_HVT references.
Outputs: ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.{ddc,vg,sdc,sdf}
QoR note: post_compile.qor.rpt reports Design Area 414721.590708, Max Trans Violations 3354, Max Cap Violations 6804.
Conclusion: valid debug handoff for a NOR2 cell-use policy experiment, but not a clean synthesis closure target.
```

```text
Stage: ICC2 modified-LEF backend rerun with NOR2 cell-use policy netlist
Command: env MOD_LEF_ROUTE_DEBUG_ROOT=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow MOD_LEF_ROUTE_REPORT_ROOT=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow MOD_LEF_ROUTE_LOG_ROOT=4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_route_flow MOD_LEF_ROUTE_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_route_icc2_lib BACKEND_NETLIST=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg BACKEND_SDC=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.sdc 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Status: COMPLETE_WITH_RESIDUAL_SIGNAL_DRC_REJECTED
Basis: full debug backend rerun from init through route using modified-LEF NDMs and the NOR2-policy synthesis handoff.
ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_route_icc2_lib
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_route_flow
Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_flow/06_route/check_routes.rpt
Result: 0 open nets; 36 signal DRCs = Diff net spacing 2, Off-grid 34.
Sanity checks: check_legality.rpt reports TOTAL 0; pg_connectivity.rpt reports VDD/VSS floating objects 0; pg_drc.rpt reports no errors; timing.max slack MET 0.77 ns; timing.min slack MET 0.04 ns.
Conclusion: upstream NOR2X0_HVT/NOR2X2_HVT dont_use does not improve the current best route artifact. It is worse than the saved modified-LEF cleanup candidate at 20 DRC, so do not promote this policy.
```

```text
Stage: ICC2 cleanup on NOR2-policy modified-LEF route candidate
Command: env MOD_LEF_CLEANUP_SRC_LIB=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_route_icc2_lib MOD_LEF_CLEANUP_LIB=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib MOD_LEF_CLEANUP_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved MOD_LEF_CLEANUP_LOG=4_Backend_ICC2/3_Log/99_debug/save_modified_lef_nor2_policy_cleanup.log MOD_LEF_CLEANUP_START_ITER=40 MOD_LEF_CLEANUP_MAX_ITER=10 4_Backend_ICC2/0_Script/99_debug/save_modified_lef_detail_cleanup.sh
Status: SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved/summary.tsv
Result: cleanup reduced the NOR2-policy route from 36 DRC/open0 to 19 DRC/open0 = Diff net spacing 2, Off-grid 17, Short 0.
Sanity checks: check_legality.rpt reports TOTAL 0; pg_connectivity.rpt reports VDD/VSS floating objects 0; pg_drc.rpt reports no errors; timing.max slack MET 0.77 ns; timing.min slack MET 0.04 ns.
Conclusion: this is the new best debug artifact by count, improving the previous saved 20-DRC candidate by one DRC, but it is still not DRC clean and is not promoted to production.
```

```text
Stage: ICC2 residual DRC inspection on NOR2-policy cleanup candidate
Commands:
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib ROUTE_DRC_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_drc_inspect ROUTE_DRC_INSPECT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_route_drc.modified_lef_nor2_policy_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib OFFGRID_CONTEXT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_offgrid_context OFFGRID_CONTEXT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_offgrid_context.modified_lef_nor2_policy_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.sh
Status: PASS_WITH_NOTE
Reports:
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_drc_inspect/drc_matrix.rpt
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_cleanup_saved_offgrid_context/offgrid_context.tsv
Result: residual DRC matrix is Diff net spacing 2 and Off-grid 17. Off-grid distribution is M1 1 and VIA1 16; all Off-grid objects are associated with M1-M2 VIA12SQ_C route vias, but surrounding cell refs are now mixed and no longer a NOR2-only pattern.
Conclusion: the original NOR2-only local root-cause hypothesis is not supported after the upstream rerun. The remaining issue is broader lower-metal pin-access/contact-code/via-array behavior.
```

```text
Stage: ICC2 residual VIA/off-grid probes on NOR2-policy cleanup candidate
Commands:
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib SHRINK_VIA_PROBE_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_nor2_policy_cleanup_saved SHRINK_VIA_PROBE_LOG=4_Backend_ICC2/3_Log/99_debug/probe_shrink_offgrid_via1_array.nor2_policy_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/probe_shrink_offgrid_via1_array.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib SHRINK_VIA_PROBE_REPAIR=1 SHRINK_VIA_PROBE_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_repair_nor2_policy_cleanup_saved SHRINK_VIA_PROBE_LOG=4_Backend_ICC2/3_Log/99_debug/probe_shrink_offgrid_via1_array_repair.nor2_policy_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/probe_shrink_offgrid_via1_array.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_cleanup_saved/ibex_mini_soc_top_modified_lef_nor2_policy_cleanup_icc2_lib ROUTE_DRC_VARIANT=via_array_off_fat_contact ROUTE_DRC_VARIANT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_drc_variants/via_array_off_fat_contact_cleanup_saved ROUTE_DRC_VARIANT_LOG=4_Backend_ICC2/3_Log/99_debug/probe_route_drc_variant.via_array_off_fat_contact_nor2_policy_cleanup_saved.log 4_Backend_ICC2/0_Script/99_debug/probe_route_drc_variant.sh
Status: DIAGNOSED_NO_ACCEPTED_FIX
Reports:
- 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_nor2_policy_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_shrink_offgrid_via1_array_repair_nor2_policy_cleanup_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_route_drc_variants/via_array_off_fat_contact_cleanup_saved/summary.tsv
Result: shrinking 17 VIA12SQ_C arrays changes the class but not the count: final check_routes remains 19 DRC/open0 with Diff net spacing 2, Needs fat contact 16, Off-grid 1. Adding route_detail repair gives the same final check_routes. via_array_off_fat_contact also remains 19 DRC/open0, trading into Diff net spacing 2, Needs fat contact 13, Off-grid 1, Short 3.
Conclusion: on the new best candidate, direct via-array/ECO route probes still trade DRC classes rather than closing the remaining DRC.
```

```text
Stage: ICC2 PG M2 offset route experiment on NOR2-policy handoff
Command: env BACKEND_NETLIST=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg BACKEND_SDC=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.sdc MOD_LEF_ROUTE_DEBUG_ROOT=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow MOD_LEF_ROUTE_REPORT_ROOT=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow MOD_LEF_ROUTE_LOG_ROOT=4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow MOD_LEF_ROUTE_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_pg_m2_o25_route_icc2_lib PG_M2_OFFSET=25.0 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Status: REJECTED_PG_DRC_REGRESSION
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_pg_m2_o25_route_flow
Result: signal check_routes had 32 DRC/open0, all Off-grid, but PG DRC reported 640 errors.
Conclusion: naive M2 mesh offset is not acceptable. If this axis is revisited, PG mesh and fixed rail-stitch coordinates must move coherently.
```

```text
Stage: ICC2 targeted Diff-net blockage ECO save
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib DIFF_BLOCKAGE_HALF_X=0.25 DIFF_BLOCKAGE_HALF_Y=1.20 DIFF_ECO_SAVE=1 DIFF_ECO_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved DIFF_ECO_LOG=4_Backend_ICC2/3_Log/99_debug/save_diff_net_blockage_eco_nor2_policy_cleanup.log 4_Backend_ICC2/0_Script/99_debug/probe_diff_net_blockage_eco.sh
Status: SAVED_CANDIDATE_WITH_RESIDUAL_SIGNAL_DRC
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/summary.tsv
Result: before 19 DRC/open0 = Diff net spacing 2, Off-grid 17; after 18 DRC/open0 = Off-grid 17, Short 1, Diff net spacing 0.
Sanity checks: check_legality.rpt reports TOTAL 0; pg_connectivity.rpt reports VDD/VSS floating objects 0; pg_drc.rpt reports no errors; timing.max slack MET 0.77 ns; timing.min slack MET 0.04 ns.
Conclusion: this is the new best debug artifact by total DRC count. It is still not DRC clean because Off-grid 17 and Short 1 remain.
```

```text
Stage: ICC2 residual Short and Off-grid inspection on 18-DRC candidate
Commands:
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib ROUTE_DRC_INSPECT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_drc_inspect ROUTE_DRC_INSPECT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_route_drc_diff_m2_blockage_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_route_drc.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib SHORT_INSPECT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_short_inspect SHORT_INSPECT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_short_area_diff_m2_blockage_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_short_area.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib OFFGRID_CONTEXT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_offgrid_context OFFGRID_CONTEXT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_offgrid_context_diff_m2_blockage_saved.log 4_Backend_ICC2/0_Script/99_debug/inspect_offgrid_context.sh
Status: PASS_WITH_NOTE
Reports:
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_drc_inspect/drc_matrix.rpt
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_short_inspect/short_area_objects.tsv
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved_offgrid_context/offgrid_context.tsv
Result: residual matrix is Off-grid 17 and Short 1. Off-grid is M1 1 and VIA1 16. The Short is on net ZBUF_1454_851 near VSS M1 rail PATH_11_149 and rerouted reset-net M2/via objects.
Conclusion: the Diff fix traded the previous reset-net spacing DRC into one reset-net/VSS-rail Short.
```

```text
Stage: ICC2 residual ECO probes on 18-DRC candidate
Commands:
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib DIFF_BLOCKAGE_LAYERS=M1 DIFF_BLOCKAGE_CX=781.05 DIFF_BLOCKAGE_CY=268.98 DIFF_BLOCKAGE_HALF_X=0.35 DIFF_BLOCKAGE_HALF_Y=0.25 DIFF_ECO_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_short_m1_blockage_on_diff_m2_saved DIFF_ECO_LOG=4_Backend_ICC2/3_Log/99_debug/probe_short_m1_blockage_on_diff_m2_saved.log 4_Backend_ICC2/0_Script/99_debug/probe_diff_net_blockage_eco.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib OFFGRID_ECO_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_route_eco_diff_m2_blockage_saved OFFGRID_ECO_LOG=4_Backend_ICC2/3_Log/99_debug/probe_remove_offgrid_via1_route_eco_diff_m2_blockage_saved.log 4_Backend_ICC2/0_Script/99_debug/probe_remove_offgrid_via1_route_eco.sh
Status: REJECTED_NO_ACCEPTED_FIX
Reports:
- 4_Backend_ICC2/4_Report/99_debug/probe_short_m1_blockage_on_diff_m2_saved/summary.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_remove_offgrid_via1_route_eco_diff_m2_blockage_saved/summary.tsv
Result: M1 blockage removes the Short but worsens to 21 DRC = Diff net spacing 3, Off-grid 18. Removing 17 off-grid VIA1 objects creates 15 open nets; route_eco restores open nets to 0 but regenerates the same 18 DRC = Off-grid 17, Short 1.
Conclusion: both probes are rejected. The current 18-DRC saved candidate remains the best debug artifact, and residual closure likely needs PDK-consistent lower-metal via/contact/pin-access rule work rather than object-level ECO.
```

```text
Stage: ICC2 Off-grid bbox M2 blockage ECO probe on 18-DRC candidate
Command: env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_diff_m2_blockage_saved/ibex_mini_soc_top_modified_lef_nor2_policy_diff_m2_blockage_icc2_lib OFFGRID_BLOCKAGE_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved OFFGRID_BLOCKAGE_LOG=4_Backend_ICC2/3_Log/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved.log 4_Backend_ICC2/0_Script/99_debug/probe_offgrid_bbox_blockage_eco.sh
Status: REJECTED_NO_TOTAL_DRC_IMPROVEMENT
Script: 4_Backend_ICC2/0_Script/99_debug/probe_offgrid_bbox_blockage_eco.sh
Report root: 4_Backend_ICC2/4_Report/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved
Summary: 4_Backend_ICC2/4_Report/99_debug/probe_offgrid_bbox_m2_blockage_diff_m2_blockage_saved/summary.tsv
Result: before 18 DRC/open0 = Off-grid 17, Short 1; after 18 DRC/open0 = Off-grid 0, Short 18.
Conclusion: rejected. Blocking the Off-grid bbox locations proves the router can avoid the off-grid VIA1 placements, but it trades the exact residual class into shorts instead of closing the route. This reinforces lower-metal pin-access/contact legality as the active root-cause axis.
```

```text
Stage: Modified-LEF NDM build probes with alternate SAED32 techfiles
Commands:
- env MOD_LEF_TECH_FILE=/DATA/home/edu135/lib/SAED32nm_PDK_04152022/techfiles/saed32nm_1p9m_mw.tf MOD_LEF_NDM_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_pdk_tf/ndm MOD_LEF_WORKSPACE_SUFFIX=ibex_libdir_modify_pdk_tf MOD_LEF_NDM_SUFFIX=modified_lef_pdk_tf lm_shell -f 4_Backend_ICC2/0_Script/99_debug/build_modified_lef_ndm.tcl -output_log_file 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_pdk_tf_ndm.log
- env MOD_LEF_TECH_FILE=/DATA/home/edu135/lib/SAED32_EDK/references/orca/icc/ref/tech/saed32nm_1p9m_mw.tf MOD_LEF_NDM_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_orca_tf/ndm MOD_LEF_WORKSPACE_SUFFIX=ibex_libdir_modify_orca_tf MOD_LEF_NDM_SUFFIX=modified_lef_orca_tf lm_shell -f 4_Backend_ICC2/0_Script/99_debug/build_modified_lef_ndm.tcl -output_log_file 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_orca_tf_ndm.log
Status: REJECTED_INPUT_TECHFILE_LOAD_FAILURE
Logs:
- 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_pdk_tf_ndm.log
- 4_Backend_ICC2/3_Log/99_debug/build_modified_lef_orca_tf_ndm.log
Result: both alternate techfiles fail at create_workspace before any NDM is committed. PDK techfile fails with TECH-006 at line 356 and LIB-007. ORCA reference techfile fails with TECH-006 at line 405 and LIB-007.
Conclusion: do not switch to those alternate techfiles directly in this flow. Any PDK/reference tech adoption would first need a tool-version-compatible techfile cleanup/import step, not a simple NDM rebuild.
```

```text
Stage: ICC2 modified-LEF NOR2-policy clean backend rerun with lower core utilization
Command: env CORE_UTILIZATION=0.55 BACKEND_NETLIST=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg BACKEND_SDC=2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.sdc MOD_LEF_ROUTE_DEBUG_ROOT=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_u055_route_flow MOD_LEF_ROUTE_REPORT_ROOT=4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_u055_route_flow MOD_LEF_ROUTE_LOG_ROOT=4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_u055_route_flow MOD_LEF_ROUTE_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_u055_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_u055_route_icc2_lib 4_Backend_ICC2/0_Script/99_debug/run_modified_lef_route_flow.sh
Status: REJECTED_DRC_AND_PG_CONNECTIVITY_REGRESSION
Script update: 4_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.tcl now supports CORE_UTILIZATION/CORE_ASPECT_RATIO/CORE_OFFSET_UM env overrides for controlled floorplan experiments.
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_nor2_policy_u055_route_flow
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_nor2_policy_u055_route_flow
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_nor2_policy_u055_route_flow/ibex_mini_soc_top_modified_lef_nor2_policy_u055_route_icc2_lib
Result: floorplan utilization was 0.5505, but final route utilization was 0.5972. check_routes reports 0 open nets and 36 signal DRCs = Diff net spacing 2, Off-grid 34. check_legality reports TOTAL 0. pg_drc reports no errors, but pg_connectivity reports VSS floating wires 1 and floating std cells 307. timing.max worst reported slack is MET 0.77 ns and timing.min worst reported slack is MET 0.03 ns.
Conclusion: rejected. Lowering core utilization alone does not close the residual M1/M2/VIA1 route DRC and regresses PG connectivity. The current best debug artifact remains the 18-DRC diff-net blockage saved library.
```

```text
Stage: Modified-LEF VIA1 pitch NDM build
Command: 4_Backend_ICC2/0_Script/99_debug/build_via1_pitch_ndm.sh
Status: PASS_WITH_NOTE
Script: 4_Backend_ICC2/0_Script/99_debug/build_via1_pitch_ndm.sh
Log: 4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_ndm.log
Patched techfile: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch/tech/saed32nm_1p9m_mw.via1_pitch.tf
NDM outputs: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch/ndm/saed32rvt_tt.modified_lef_via1_pitch.ndm, saed32lvt_tt.modified_lef_via1_pitch.ndm, saed32hvt_tt.modified_lef_via1_pitch.ndm
Probe: uncommented VIA1 pitch = 0.36 in a project-local copy of the current SAED32_EDK techfile while keeping the libdir modified LEFs.
Warning: build log reports TECH-025 because VIA1 now has pitch together with onGrid/onWireTrack.
Next action: route the NOR2-policy handoff against this debug NDM and compare against the 18-DRC best artifact.
```

```text
Stage: ICC2 VIA1 pitch NDM NOR2-policy backend rerun
Command: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_nor2_policy_route_flow.sh
Status: REJECTED_NO_IMPROVEMENT
Script: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_nor2_policy_route_flow.sh
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_nor2_policy_route_icc2_lib
Route report: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_nor2_policy_route_flow/06_route/check_routes.rpt
Result: 0 open nets and 36 signal DRCs = Diff net spacing 2, Off-grid 34.
Sanity checks: check_legality reports TOTAL 0; pg_connectivity reports VDD/VSS floating objects 0; pg_drc reports no errors; timing.max slack MET 0.77 ns; timing.min slack MET 0.04 ns.
Conclusion: rejected. Adding VIA1 pitch to the current techfile does not resolve the residual Off-grid issue and is worse than the 18-DRC diff-net blockage saved artifact.
```

```text
Stage: Modified-LEF VIA1 pitch/no-track NDM build
Command: 4_Backend_ICC2/0_Script/99_debug/build_via1_pitch_no_track_ndm.sh
Status: PASS_WITH_NOTE
Script: 4_Backend_ICC2/0_Script/99_debug/build_via1_pitch_no_track_ndm.sh
Log: 4_Backend_ICC2/3_Log/99_debug/build_via1_pitch_no_track_ndm.log
Patched techfile: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf
NDM root: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track/ndm
Patch: in Layer "VIA1", enabled pitch = 0.36 and removed onWireTrack/onGrid from a project-local copy of the SAED32_EDK techfile.
Result: LM workspace checks succeeded and RVT/LVT/HVT NDMs were written. No TECH-025/TECH-006/LIB-007/Fatal pattern was found in the build log.
Known warnings: existing SAED32 LEF/DB import warnings and FRAM-066 large M1 blockage warnings remain.
Next action: rerun a clean backend route using these NDMs and compare against the 18-DRC best artifact.
```

```text
Stage: ICC2 VIA1 pitch/no-track NDM NOR2-policy backend rerun
Command: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_policy_route_flow.sh
Status: COMPLETE_WITH_ONE_RESIDUAL_SIGNAL_DRC
Script: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_policy_route_flow.sh
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_policy_route_icc2_lib
Backend inputs: NOR2-policy netlist 2_Synthesis/2_Output/pre_backend_topo_nor2_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_no_x0x2_hvt.vg and matching SDC.
Result: 06_route/check_routes.rpt reports 0 open nets and 1 signal DRC = Off-grid 1.
Sanity checks: check_legality TOTAL 0; pg_connectivity VDD/VSS floating objects 0; pg_drc no errors; timing.max slack MET 0.77 ns; timing.min slack MET 0.04 ns.
Conclusion: this superseded the 18-DRC saved artifact by count, but still was not route DRC clean.
```

```text
Stage: ICC2 one-DRC context inspection and post-route MUX resize probe
Commands:
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_policy_route_icc2_lib DRC_CONTEXT_TYPE=Off-grid DRC_CONTEXT_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_drc_context DRC_CONTEXT_LOG=4_Backend_ICC2/3_Log/99_debug/inspect_drc_context.modified_lef_via1_pitch_no_track_nor2_policy_route.Off-grid.log 4_Backend_ICC2/0_Script/99_debug/inspect_drc_context.sh
- env ICC2_LIB_DIR=4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_policy_route_icc2_lib RESIZE_INST_TARGET_REF=MUX41X1_HVT RESIZE_INST_LIST=U6629 RESIZE_INST_REPORT_DIR=4_Backend_ICC2/4_Report/99_debug/probe_resize_mux41x2_u6629_to_x1 RESIZE_INST_LOG=4_Backend_ICC2/3_Log/99_debug/probe_resize_instances.mux41x2_u6629_to_x1.log 4_Backend_ICC2/0_Script/99_debug/probe_resize_instances.sh
Status: DIAGNOSED_NO_ACCEPTED_ECO_FIX
Scripts: 4_Backend_ICC2/0_Script/99_debug/probe_resize_instances.sh, 4_Backend_ICC2/0_Script/99_debug/probe_resize_instances.tcl
Reports:
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_drc_context/drc_detail.rpt
- 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_policy_route_drc_context/context.tsv
- 4_Backend_ICC2/4_Report/99_debug/probe_resize_mux41x2_u6629_to_x1/summary.tsv
Result: the remaining Off-grid is M1 at bbox {799.4010 612.0100} {799.5110 612.0700}, net n55676, near U6629/MUX41X2_HVT/S0. Post-route resize of U6629 to MUX41X1_HVT cleared Off-grid but worsened the block to 14 DRC and 6 open nets.
Conclusion: the residual DRC is a MUX41X2_HVT/S0 lower-metal pin-access case. Fixing it post-route is not acceptable; test upstream cell-use policy instead.
```

```text
Stage: DC topo NOR2+MUX41 cell-use policy debug synthesis
Command: env NOR2_POLICY_RUN_TAG=pre_backend_topo_nor2_mux41_no_x0x2_hvt NOR2_POLICY_DONT_USE="NOR2X0_HVT NOR2X2_HVT MUX41X2_HVT" NOR2_POLICY_LOG=2_Synthesis/3_Log/99_debug/run_dc_compile_topo_nor2_policy.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.sh
Status: PASS_WITH_PRE_BACKEND_DRC_NOTE
Script: 2_Synthesis/0_Script/99_debug/run_dc_compile_topo_nor2_policy.tcl
Log: 2_Synthesis/3_Log/99_debug/run_dc_compile_topo_nor2_policy.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log
Output root: 2_Synthesis/2_Output/pre_backend_topo_nor2_mux41_no_x0x2_hvt
Report root: 2_Synthesis/4_Report/99_debug/pre_backend_topo_nor2_mux41_no_x0x2_hvt
Evidence: nor2_dont_use_verify.rpt reports NOR2X0_HVT, NOR2X2_HVT, and MUX41X2_HVT dont_use=true. The mapped Verilog has 0 NOR2X0_HVT/NOR2X2_HVT/MUX41X2_HVT references and 126 MUX41X1_HVT references.
Outputs: ibex_mini_soc_top.pre_backend_topo_nor2_mux41_no_x0x2_hvt.{ddc,vg,sdc,sdf}
QoR note: post_compile.qor.rpt reports Design Area 414611.038071; pre-backend max transition/cap notes remain.
Formality note: this debug handoff later passed Formality R2N; see the Formality R2N for NOR2+MUX41 debug handoff entry below.
```

```text
Stage: ICC2 VIA1 pitch/no-track NDM NOR2+MUX41-policy backend rerun
Command: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_mux41_policy_route_flow.sh
Status: DEBUG_ROUTE_DRC_CLEAN_CANDIDATE
Script: 4_Backend_ICC2/0_Script/99_debug/run_via1_pitch_no_track_nor2_mux41_policy_route_flow.sh
Log root: 4_Backend_ICC2/3_Log/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow
Report root: 4_Backend_ICC2/4_Report/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow
Saved ICC2 library: 4_Backend_ICC2/2_Output/99_debug/modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_flow/ibex_mini_soc_top_modified_lef_via1_pitch_no_track_nor2_mux41_policy_route_icc2_lib
Backend inputs: NOR2+MUX41-policy netlist 2_Synthesis/2_Output/pre_backend_topo_nor2_mux41_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_mux41_no_x0x2_hvt.vg and matching SDC.
Result: 06_route/check_routes.rpt reports 0 open nets and 0 signal DRC. Antenna checking is not active because no antenna rules are defined.
Sanity checks: check_legality TOTAL 0; pg_connectivity VDD/VSS floating objects 0; route log/check_pg_drc reports No errors found; timing.max worst reported slack MET 0.78 ns; timing.min worst reported slack MET 0.04 ns.
Important caveat: this is a debug DRC-clean candidate, not a promoted production baseline. Promotion requires deciding whether the VIA1 no-track techfile change is acceptable library policy. The NOR2+MUX41 DC handoff later passed Formality R2N.
```

```text
Stage: Formality R2N for NOR2+MUX41 debug handoff
Command: env FM_RUN_TAG=pre_backend_topo_nor2_mux41_no_x0x2_hvt FM_LOG=3_Formality/3_Log/fm_r2n_topo.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log 3_Formality/0_Script/run_fm_r2n_topo.sh
Status: PASS_WITH_NOTE
Script updates: 3_Formality/0_Script/run_fm_r2n_topo.sh and run_fm_r2n_topo.tcl now accept FM_RUN_TAG/FM_LOG while preserving pre_backend_topo as the default.
Basis: reference RTL from filelists/ibex_mini_soc_fm_ref.f; implementation DDC 2_Synthesis/2_Output/pre_backend_topo_nor2_mux41_no_x0x2_hvt/ibex_mini_soc_top.pre_backend_topo_nor2_mux41_no_x0x2_hvt.ddc; matching SVF 2_Synthesis/2_Output/svf/ibex_mini_soc_top.pre_backend_topo_nor2_mux41_no_x0x2_hvt.svf.
Log path: 3_Formality/3_Log/fm_r2n_topo.pre_backend_topo_nor2_mux41_no_x0x2_hvt.log
Report root: 3_Formality/4_Report/pre_backend_topo_nor2_mux41_no_x0x2_hvt
Output session: 3_Formality/2_Output/pre_backend_topo_nor2_mux41_no_x0x2_hvt/r2n_topo_fm_session.fss
Result: Verification SUCCEEDED; 34915 passing compare points; 0 failing compare points; 0 unmatched reference/implementation compare points.
SVF guidance result: 2146 accepted, 0 rejected; hier_map 33 accepted, 0 rejected.
Known notes: synopsys_auto_setup enabled; RTL interpretation warnings exist; one clock-gate latch not compared, consistent with prior baseline note.
Historical promotion caveat at run time: only the VIA1 no-track techfile/library policy remained to be accepted before moving this candidate out of 99_debug. This policy was later accepted on 2026-05-10; wrapper/manifest promotion remains.
```

```text
Stage: Backend route closure documentation and VIA1 policy approval
Command: documentation edit only; no licensed EDA tools rerun
Status: RECORDED
Documents:
- docs/ibex_backend_route_closure_case_study.md
- docs/backend_library_policy.md
- 00_Project_Tracking/DECISION_LOG.md
- 00_Project_Tracking/PROJECT_STATUS.md
- 00_Project_Tracking/RESULT_SUMMARY.md
- 00_Project_Tracking/RUN_MANIFEST.md
- init/context_bootstrap.md
- AGENTS.md
Result: route closure case study records the baseline 720-DRC route, DRC breakdown, hypotheses, experiments, accepted 0-DRC debug candidate, production-promotion boundary, and interview explanation.
Policy result: VIA1 pitch/no-track techfile policy is accepted for project baseline promotion as of 2026-05-10.
Next action: promote or explicitly alias the selected 99_debug backend route wrapper/manifest path as the baseline flow; do not claim signoff clean without antenna/LVS/IR/EM evidence.
```

```text
Stage: ICC2 route-closure baseline promotion rerun
Command: 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh
Status: PASS_WITH_NOTE
Script: 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh
Log root: 4_Backend_ICC2/3_Log/07_route_closure
Report root: 4_Backend_ICC2/4_Report/07_route_closure
ICC2 library: 4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib
Backend inputs: pre_backend_topo_nor2_mux41_no_x0x2_hvt netlist/SDC, modified-LEF VIA1 pitch/no-track NDMs, project-local VIA1 no-track techfile.
Result: 06_route/check_routes.rpt reports 0 open nets and 0 signal DRC. Antenna checking is not active because no antenna rules are defined.
Sanity checks: check_legality.rpt reports TOTAL 0; pg_connectivity.rpt reports VDD/VSS floating objects 0; check_pg_drc reports No errors found; timing.max slack MET 0.78 ns; timing.min slack MET 0.04 ns.
Conclusion: the formerly 99_debug DRC-clean candidate has been rerun through a named baseline route-closure wrapper/report path. It is still not signoff clean because antenna/LVS/IR/EM/foundry DRC are outside this evidence.
```

```text
Stage: ICC2 educational GDS candidate export
Command: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh
Status: PASS_WITH_NOTE
Script: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.tcl
Wrapper: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh
Log: 4_Backend_ICC2/3_Log/08_gds/run_write_gds_route_closure.route_closure_gds_candidate.log
Input ICC2 library: 4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib
GDS block: ibex_mini_soc_top_route_closure_gds_candidate
Output root: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate
Report root: 4_Backend_ICC2/4_Report/08_gds/route_closure_gds_candidate
Outputs: ibex_mini_soc_top.route_closure_gds_candidate.gds, .vg, .def, .sdc, and gds_export_manifest.txt.
File sizes: GDS 157M, DEF 127M, Verilog 32M, SDC 13M.
Post-filler result: check_routes.after_filler.rpt reports 0 open nets and 0 signal DRC; check_legality.after_filler.rpt reports TOTAL 0; pg_connectivity.after_filler.rpt reports VDD/VSS floating objects 0; check_pg_drc reports No errors found.
Timing/QoR note: qor.after_filler.rpt reports critical path slack 0.78 ns for clk and no setup/hold violating paths; constraints.after_filler.rpt reports max_transition 8 and max_capacitance 228 design-rule violations.
Conclusion: educational GDS candidate export completed. It is not tapeout/signoff GDS; antenna rules are absent and LVS/foundry DRC/IR/EM/metal-fill/signoff STA are not performed.
```

```text
Stage: ICC2 post-route electrical DRC closure probe
Command: 4_Backend_ICC2/0_Script/09_post_route_electrical_closure/run_post_route_electrical_drc.sh plus iter2/iter3/iter4 environment overrides
Status: PARTIAL_NOT_PROMOTED
Scripts: 4_Backend_ICC2/0_Script/09_post_route_electrical_closure/run_post_route_electrical_drc.sh, run_post_route_electrical_drc.tcl
Report roots:
- 4_Backend_ICC2/4_Report/09_post_route_electrical_closure
- 4_Backend_ICC2/4_Report/09_post_route_electrical_closure_iter2
- 4_Backend_ICC2/4_Report/09_post_route_electrical_closure_iter3
- 4_Backend_ICC2/4_Report/09_post_route_electrical_closure_iter4
Result: route_opt reduced electrical DRC from GDS after-filler max_transition 8/max_capacitance 228 to max_transition 0/max_capacitance 120, but iter4 made no further progress.
Sanity checks at iter4: check_routes open nets 0 and DRC 0; check_legality TOTAL 0; PG connectivity floating objects 0; PG DRC no errors; timing.max/min MET 0.63 ns / 0.04 ns.
Conclusion: repeated route_opt is only a partial electrical-DRC cleanup path and is not sufficient for a clean promoted result.
```

```text
Stage: ICC2/PrimeTime post-route max-cap ECO attempt
Command: 4_Backend_ICC2/0_Script/10_post_route_maxcap_eco/run_post_route_maxcap_eco.sh
Status: PARTIAL_NOT_PROMOTED
Scripts: 4_Backend_ICC2/0_Script/10_post_route_maxcap_eco/run_post_route_maxcap_eco.sh, run_post_route_maxcap_eco.tcl
Log: 4_Backend_ICC2/3_Log/10_post_route_maxcap_eco/run_post_route_maxcap_eco.log
Report root: 4_Backend_ICC2/4_Report/10_post_route_maxcap_eco
Output root: 4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/export
Saved ICC2 library: 4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/ibex_mini_soc_top_post_route_maxcap_eco_icc2_lib
Source block: ibex_mini_soc_top_post_route_electrical_drc_iter4
ECO block: ibex_mini_soc_top_post_route_maxcap_eco
Result: eco_opt -types max_capacitance inserted 55 buffers and issued 65 size_cell commands. PrimeTime ECO internal summary reports remaining violations 0.
Final saved-block ICC2 reports: constraints.after_maxcap_eco.rpt reports max_transition 0 and max_capacitance 2; check_routes.after_maxcap_eco.rpt reports open nets 0 and route DRC 31; check_legality reports TOTAL 0; PG connectivity floating objects are 0; PG DRC reports no errors; timing.max/min reports MET 0.64 ns / 0.04 ns.
Residual max-cap nets: n39125 actual 16.12 vs required 16.00; n51648 actual 64.04 vs required 64.00.
Route DRC breakdown after ECO: Diff net spacing 11, Less than minimum enclosed area 1, Off-grid 8, Same net spacing 5, Short 6.
Conclusion: not accepted and not promoted. Per project-owner instruction, do not continue deeper ECO repair; carry this as a documented residual electrical/route DRC issue.
Document: docs/post_route_electrical_drc_closure_attempt.md
```

```text
Stage: ICC2 final post-route cleanup after max-cap ECO
Command: 4_Backend_ICC2/0_Script/11_post_route_final_cleanup/run_post_route_final_cleanup.sh
Status: PARTIAL_ELECTRICAL_DRC_REMAINS
Scripts: 4_Backend_ICC2/0_Script/11_post_route_final_cleanup/run_post_route_final_cleanup.sh, run_post_route_final_cleanup.tcl
Log: 4_Backend_ICC2/3_Log/11_post_route_final_cleanup/run_post_route_final_cleanup.log
Report root: 4_Backend_ICC2/4_Report/11_post_route_final_cleanup
Output root: 4_Backend_ICC2/2_Output/11_post_route_final_cleanup/export
Saved ICC2 library: 4_Backend_ICC2/2_Output/11_post_route_final_cleanup/ibex_mini_soc_top_post_route_final_cleanup_icc2_lib
Source block: ibex_mini_soc_top_post_route_maxcap_eco
Cleanup block: ibex_mini_soc_top_post_route_final_cleanup
Result: route_detail plus route_eco recovered the max-cap ECO route regression. check_routes.after_cleanup.rpt reports open nets 0 and route DRC 0.
Final saved-block ICC2 reports: constraints.after_cleanup.rpt reports max_transition 0, max_capacitance 2, and min_capacitance 0; check_legality reports TOTAL 0; PG connectivity floating objects are 0; PG DRC reports no errors; timing.max/min reports MET 0.64 ns / 0.04 ns.
Decision: final bounded cleanup improved the result but is not electrical-DRC-clean because two max-cap violations remain.
```

```text
Stage: ICC2 residual max-cap ECO after final cleanup
Command: 4_Backend_ICC2/0_Script/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.sh
Status: PASS_WITH_NOTE
Scripts: 4_Backend_ICC2/0_Script/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.sh, run_post_route_residual_maxcap_eco.tcl
Log: 4_Backend_ICC2/3_Log/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.log
Report root: 4_Backend_ICC2/4_Report/12_post_route_residual_maxcap_eco
Output root: 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export
Saved ICC2 library: 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/ibex_mini_soc_top_post_route_residual_maxcap_eco_icc2_lib
Source block: ibex_mini_soc_top_post_route_final_cleanup
ECO block: ibex_mini_soc_top_post_route_residual_maxcap_eco
Result: one residual max-cap ECO inserted 1 buffer and issued 1 size_cell command; PrimeTime ECO reported remaining violations 0.
Final saved-block ICC2 reports: constraints.final.rpt reports max_transition 0, max_capacitance 0, and min_capacitance 0; check_routes.final.rpt reports open nets 0 and route DRC 0; check_legality reports TOTAL 0; PG connectivity floating objects are 0; PG DRC has no reported errors; timing.max/min reports MET 0.64 ns / 0.04 ns.
Conclusion: accepted as an ICC2 internal post-route electrical/route clean candidate for this debug sequence. This is not signoff clean because antenna rules, foundry DRC, LVS, IR/EM, metal fill, and signoff STA methodology are not covered.
```

```text
Stage: Formality R2N for residual max-cap ECO netlist
Command: env FM_RUN_TAG=post_route_residual_maxcap_eco FM_IMPL_NETLIST=4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/ibex_mini_soc_top.post_route_residual_maxcap_eco.vg FM_LOG=3_Formality/3_Log/fm_post_route_residual_maxcap_eco.log 3_Formality/0_Script/run_fm_post_route_residual_maxcap_eco.sh
Status: PASS_WITH_NOTE
Reports: 3_Formality/4_Report/post_route_residual_maxcap_eco
Session: 3_Formality/2_Output/post_route_residual_maxcap_eco/post_route_residual_maxcap_eco_fm_session.fss
Result: Verification SUCCEEDED; 34915 passing compare points; 0 failing compare points; 0 unmatched compare points.
SVF guidance result: 2146 accepted, 0 rejected.
Known notes: synopsys_auto_setup enabled; RTL interpretation warnings remain; one clock-gate latch not compared, consistent with previous FM runs.
```

```text
Stage: PrimeTime final SDF STA for residual max-cap ECO netlist
Command: env PT_RUN_TAG=post_route_residual_maxcap_eco PT_NETLIST=4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/ibex_mini_soc_top.post_route_residual_maxcap_eco.vg PT_SDC_FILE=4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/ibex_mini_soc_top.post_route_residual_maxcap_eco.sdc PT_SDF_FILE=4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/ibex_mini_soc_top.post_route_residual_maxcap_eco.sdf 5_STA/0_Script/run_pt_post_route_residual_maxcap_eco_sdf.sh
Status: PASS_WITH_NOTE
Report root: 5_STA/4_Report/post_route_residual_maxcap_eco
Log: 5_STA/3_Log/pt_post_route_residual_maxcap_eco_sdf.log
Result: global_timing.rpt reports no setup violations and no hold violations; qor.rpt reports setup slack 0.68 ns, hold slack 0.03 ns, TNS 0, and total DRC cost 0.
SDF result: read_sdf reported 0 errors; annotated_delay.rpt reports 1011356 / 1015046 delay arcs annotated, 3690 not annotated.
Coverage: setup/hold 34884/34884 met, 0 violated; recovery/removal 1845 each untested; all checks 139601 met, 0 violated, 5535 untested.
Known note: PT constraints.rpt reports PTE-057, so ICC2 saved-block reports remain the evidence for max_transition/max_cap electrical DRC.
```

```text
Stage: GDS refresh from residual max-cap ECO block
Command: 4_Backend_ICC2/0_Script/13_gds/run_write_gds_residual_maxcap_clean.sh
Status: COMPLETED_WITH_AFTER_FILLER_MAX_CAP_REGRESSION
Script: 4_Backend_ICC2/0_Script/13_gds/run_write_gds_residual_maxcap_clean.tcl
Log: 4_Backend_ICC2/3_Log/13_gds/run_write_gds_residual_maxcap_clean.post_route_residual_maxcap_eco_gds_candidate.log
Report root: 4_Backend_ICC2/4_Report/13_gds/post_route_residual_maxcap_eco_gds_candidate
Output root: 4_Backend_ICC2/2_Output/13_gds/post_route_residual_maxcap_eco_gds_candidate
Result: GDS/DEF/VG/SDC written; manifest statuses are 0; check_routes.after_filler reports open nets 0 and route DRC 0; legality/PG/timing are clean or positive.
Issue reproduced: constraints.after_filler.rpt reports max_transition 0, min_capacitance 0, and max_capacitance 4 on n42733, n49555, ZBUF_1069_1170, and ZBUF_259_1196.
Diagnosis: the 12_post_route_residual_maxcap_eco block is clean before filler, but filler insertion plus PG reconnect/re-extraction slightly increases extracted cap on four near-limit nets.
Next action: create a pre-filler margin ECO rather than accepting this GDS artifact as the final clean candidate.
```

```text
Stage: ICC2 pre-filler max-cap margin ECO
Command: 4_Backend_ICC2/0_Script/14_post_route_prefiller_maxcap_margin/run_post_route_prefiller_maxcap_margin.sh
Status: PASS_WITH_NOTE
Script: 4_Backend_ICC2/0_Script/14_post_route_prefiller_maxcap_margin/run_post_route_prefiller_maxcap_margin.tcl
Log: 4_Backend_ICC2/3_Log/14_post_route_prefiller_maxcap_margin/run_post_route_prefiller_maxcap_margin.log
Report root: 4_Backend_ICC2/4_Report/14_post_route_prefiller_maxcap_margin
Output root: 4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/export
Saved ICC2 library: 4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/ibex_mini_soc_top_post_route_prefiller_maxcap_margin_icc2_lib
Failed sub-attempt: net-based set_max_capacitance produced SEL-002/SEL-005 messages and ECO made 0 changes because set_max_capacitance does not apply to net collections in this flow.
Accepted fix: apply tighter max_cap to driver pins U77216/Y, U13303/Y, ZBUF_1069_inst_8294/Y, ZBUF_259_inst_8705/Y, and U7539/Y.
ECO result: constraints.after_margin_targets.rpt intentionally created 5 max-cap violations; eco_opt inserted 5 NBUFFX2_RVT buffers; final constraints report max_transition 0, max_capacitance 0, min_capacitance 0.
Final sanity result: check_routes.final.rpt open nets 0 and route DRC 0; check_legality.final.rpt TOTAL 0; PG connectivity floating objects 0; PG DRC no errors; qor.final.rpt reports setup slack 0.64 ns and no hold violations.
```

```text
Stage: Formality R2N for pre-filler max-cap margin ECO netlist
Command: env FM_RUN_TAG=post_route_prefiller_maxcap_margin FM_IMPL_NETLIST=4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/export/ibex_mini_soc_top.post_route_prefiller_maxcap_margin.vg FM_LOG=3_Formality/3_Log/fm_post_route_prefiller_maxcap_margin.log 3_Formality/0_Script/run_fm_post_route_residual_maxcap_eco.sh
Status: PASS_WITH_NOTE
Reports: 3_Formality/4_Report/post_route_prefiller_maxcap_margin
Session: 3_Formality/2_Output/post_route_prefiller_maxcap_margin/post_route_prefiller_maxcap_margin_fm_session.fss
Result: Verification SUCCEEDED; 34915 passing compare points; 0 failing compare points; 0 unmatched compare points.
SVF guidance result: 2146 accepted, 0 rejected.
Known notes: synopsys_auto_setup enabled; RTL interpretation warnings remain; one clock-gate latch not compared.
```

```text
Stage: PrimeTime final SDF STA for pre-filler max-cap margin ECO netlist
Command: env PT_RUN_TAG=post_route_prefiller_maxcap_margin PT_NETLIST=4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/export/ibex_mini_soc_top.post_route_prefiller_maxcap_margin.vg PT_SDC_FILE=4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/export/ibex_mini_soc_top.post_route_prefiller_maxcap_margin.sdc PT_SDF_FILE=4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/export/ibex_mini_soc_top.post_route_prefiller_maxcap_margin.sdf 5_STA/0_Script/run_pt_post_route_residual_maxcap_eco_sdf.sh
Status: PASS_WITH_NOTE
Report root: 5_STA/4_Report/post_route_prefiller_maxcap_margin
Log: 5_STA/3_Log/pt_post_route_prefiller_maxcap_margin_sdf.log
Result: global_timing.rpt reports no setup violations and no hold violations; qor.rpt reports setup slack 0.67 ns, hold slack 0.03 ns, TNS 0, and total DRC cost 0.
SDF result: read_sdf reported 0 errors; annotated_delay.rpt reports 1011366 / 1015056 delay arcs annotated, 3690 not annotated.
Coverage: setup/hold 34884/34884 met, 0 violated; all checks 139601 met, 0 violated, 5535 untested.
Known note: PT constraints.rpt reports PTE-057, so ICC2 saved-block reports remain the evidence for max_transition/max_cap electrical DRC.
```

```text
Stage: GDS refresh from pre-filler max-cap margin ECO block
Command: env SOURCE_CLEAN_ICC2_LIB=4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/ibex_mini_soc_top_post_route_prefiller_maxcap_margin_icc2_lib SRC_BLOCK=ibex_mini_soc_top_post_route_prefiller_maxcap_margin GDS_TAG=post_route_prefiller_maxcap_margin_gds_candidate 4_Backend_ICC2/0_Script/13_gds/run_write_gds_residual_maxcap_clean.sh
Status: PASS_WITH_NOTE
Script: 4_Backend_ICC2/0_Script/13_gds/run_write_gds_residual_maxcap_clean.tcl
Log: 4_Backend_ICC2/3_Log/13_gds/run_write_gds_residual_maxcap_clean.post_route_prefiller_maxcap_margin_gds_candidate.log
Report root: 4_Backend_ICC2/4_Report/13_gds/post_route_prefiller_maxcap_margin_gds_candidate
Output root: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate
Manifest: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/gds_export_manifest.txt
Outputs: ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds, .def, .vg, .sdc
File sizes: GDS 157M, DEF 128M, Verilog 32M, SDC 13M
Post-filler route/electrical result: check_routes.after_filler.rpt reports open nets 0 and route DRC 0; constraints.after_filler.rpt reports max_transition 0, max_capacitance 0, min_capacitance 0; check_legality.after_filler.rpt succeeded with 0 illegal cells; pg_connectivity.after_filler.rpt reports VDD/VSS floating objects 0; pg_drc.after_filler.rpt has no reported PG DRC records; qor.after_filler.rpt reports setup slack 0.64 ns and no hold violations.
Conclusion: accepted final educational GDS candidate for this phase. It is not signoff/tapeout ready because antenna rules, foundry DRC, LVS, IR/EM, metal fill, and signoff STA methodology are not covered.
```

```text
Stage: HTML learning report generation
Command: read ibex_html_report_prompt.md and generate HTML reports from saved project evidence
Status: RECORDED
Outputs:
- ibex_frontend_flow_report.html
- ibex_backend_route_gds_report.html
Source evidence:
- AGENTS.md
- init/context_bootstrap.md
- 2026-05-09_103000-ibex-mini-soc-implementation-flow.md
- 00_Project_Tracking/PROJECT_STATUS.md
- 00_Project_Tracking/RESULT_SUMMARY.md
- docs/ibex_config.md
- docs/backend_flow.md
- docs/ibex_backend_route_closure_case_study.md
- docs/post_route_electrical_drc_closure_attempt.md
- docs/gds_candidate_export.md
- saved DC/FM/PT/ICC2 report roots cited inside the HTML reports
Result: two Korean A4-print HTML reports were generated. They summarize front-end handoff, backend route DRC closure, post-route electrical ECO, Formality/PrimeTime evidence, final educational GDS candidate, and explicit claim boundaries.
Note: no EDA tool was rerun for this documentation step.
```

```text
Stage: HTML learning report command-level expansion
Command: update ibex_frontend_flow_report.html and ibex_backend_route_gds_report.html per review notes
Status: RECORDED
Outputs updated:
- ibex_frontend_flow_report.html
- ibex_backend_route_gds_report.html
Frontend additions:
- Mini SoC block diagram and stronger module composition table
- DC topo command explanations: set_svf, write DDC/Verilog/SDC/SDF, and related compile/report commands
- Formality command explanations: reference read, implementation read, set_top, set_svf, match, verify
- PrimeTime command explanations: read_verilog, link_design, read_sdc, read_sdf, update_timing concept, report_timing, report_constraint
- stage gates explaining why each stage can hand off to the next
Backend additions:
- modified LEF / VIA1 no-track example
- NDM build command flow
- route-closure baseline command-level explanation
- post-route electrical ECO command-level explanation
- GDS export command-level explanation
- appendix expanded from path list to script-by-script learning table with purpose, input block, key command, report, PASS criterion, and next-stage evidence
Note: documentation-only update; no EDA tool rerun.
```

```text
Stage: Project closure declaration
Command: documentation edit only; no licensed EDA tools rerun
Status: CLOSED_AS_EDUCATIONAL_FE_TO_BE_IMPLEMENTATION_FLOW
Closure date: 2026-05-11
Scope: Ibex Mini SoC FE-to-BE educational implementation flow
Closure document: 00_Project_Tracking/PROJECT_CLOSURE.md
Final candidate: post_route_prefiller_maxcap_margin_gds_candidate
Final GDS: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds
Recorded GDS size: 157M
Evidence summary: DC topo synthesis completed; Formality R2N passed with 34915 passing compare points, 0 failing, 0 unmatched; route-closure baseline reports open nets 0, signal DRC 0, PG connectivity floating objects 0, PG DRC no errors, timing.max/min positive at +0.78 ns / +0.04 ns; pre-filler margin ECO inserted 5 NBUFFX2_RVT buffers and reports max_transition 0, max_capacitance 0, min_capacitance 0, route DRC 0, legality clean, PG clean, timing positive; PrimeTime SDF STA reports no setup/hold violations, SDF read errors 0, setup slack about +0.67 ns, hold slack about +0.03 ns; final GDS after-filler checks report open nets 0, route DRC 0, max_transition 0, max_capacitance 0, min_capacitance 0, legality clean, PG clean, timing positive.
Claim boundary: educational GDS candidate only; not tapeout-ready, not foundry signoff clean, not production signoff GDS; antenna rules absent, LVS not performed, IR/EM not performed, foundry signoff DRC not performed, metal fill not performed, full signoff STA methodology not evidenced.
Next milestone: implementation closed; next work is portfolio/report packaging or optional signoff-style extension.
```
