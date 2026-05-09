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
```
