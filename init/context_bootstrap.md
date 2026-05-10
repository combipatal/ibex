# Ibex Mini SoC Context Bootstrap

Created: 2026-05-09

Project root:

```text
/DATA/home/edu135/ibex
```

Primary goal:

```text
Build one reproducible FE-to-BE baseline for an Ibex-based Mini SoC:
RTL intake -> config freeze -> DC synthesis -> Formality R2N -> ICC2 route -> report summary.
```

Key rules:

```text
- Read AGENTS.md before changing scripts, constraints, wrappers, filelists, or tool setup.
- Run licensed EDA tools outside the sandbox: dc_shell, fm_shell, pt_shell, icc2_shell, tmax, lmutil.
- Record decisions and run results in 00_Project_Tracking/.
- Do not start clock/memory/utilization sweeps before one baseline flow exists.
- Run like a practical ASIC implementation project: scripted, reproducible, report-checked, and artifact-backed.
```

Initial SAED32 timing libraries:

```text
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db
```

Ibex source policy:

```text
Clone upstream Ibex into rtl/ibex.
Do not edit upstream RTL directly unless explicitly required.
Place project-specific SoC RTL under rtl/mini_soc/.
```

Config freeze policy:

```text
Document exact Ibex config in docs/ibex_config.md before synthesis.
Keep DC and Formality top/config/filelist aligned.
Prefer wrapper-level parameter overrides and wrapper RTL tie-offs.
```

Current baseline state:

```text
Ibex upstream commit: 9742d89f54fc297bed026841c8e68454ddfd7cc0
Synthesis top: ibex_mini_soc_top
Ibex integration point: ibex_top as u_ibex_top
Official synthesis script: 2_Synthesis/0_Script/run_dc_compile_topo.tcl
Official synthesis command: dc_shell -topographical_mode -f 2_Synthesis/0_Script/run_dc_compile_topo.tcl -output_log_file 2_Synthesis/3_Log/dc_compile_topo.log
Run tag: pre_backend_topo
Formality SVF: 2_Synthesis/2_Output/svf/ibex_mini_soc_top.pre_backend_topo.svf
Formality R2N wrapper: 3_Formality/0_Script/run_fm_r2n_topo.sh
STA wrapper: 5_STA/0_Script/run_pt_pre_backend_topo_sdf.sh
STA basis: matching topo netlist/SDC/SDF; PrimeTime does not read SVF directly.
Formality result: PASS_WITH_NOTE, 34915 passing compare points, 0 failing, 0 unmatched.
SVF guidance note: DC topo emits hier_map guidance; FM accepted 2146 guidance commands and rejected 0.
Known note: pre-backend timing has no setup/hold violations, but max cap/transition DRC remains for backend closure.
Backend route note: baseline route closure uses project-local modified-LEF VIA1 pitch/no-track NDMs plus a DC cell-use policy that sets NOR2X0_HVT, NOR2X2_HVT, and MUX41X2_HVT dont_use.
Backend route wrapper: 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh.
Backend route artifact: 4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib.
Backend route reports: 4_Backend_ICC2/4_Report/07_route_closure/06_route.
Backend route result: check_routes reports 0 open nets and 0 signal DRC; legality TOTAL 0; PG connectivity floating objects 0; PG DRC no errors; ICC2 timing.max MET 0.78 ns and timing.min MET 0.04 ns. Antenna checking is not active because no antenna rules are defined.
Formality for NOR2+MUX41 handoff: PASS_WITH_NOTE, 34915 passing compare points, 0 failing, 0 unmatched, SVF guidance 2146 accepted and 0 rejected.
VIA1 no-track library policy: accepted for project baseline promotion as of 2026-05-10; see docs/backend_library_policy.md.
Route closure case study: docs/ibex_backend_route_closure_case_study.md.
Educational GDS wrapper: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh.
Educational GDS output: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.gds.
Educational GDS reports: 4_Backend_ICC2/4_Report/08_gds/route_closure_gds_candidate.
Educational GDS result: GDS/DEF/netlist/SDC written; post-filler route DRC/open clean, legality clean, PG clean, and qor.after_filler reports clk critical path slack 0.78 ns.
GDS caveat: constraints.after_filler reports max_transition 8 and max_capacitance 228 violations; do not claim signoff clean or tapeout-ready without antenna/LVS/IR/EM/foundry DRC/metal-fill/signoff STA evidence.
```
