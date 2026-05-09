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
