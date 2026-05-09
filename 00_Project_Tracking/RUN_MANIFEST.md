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
Powerplan note: PG DRC is clean, but PG connectivity is not clean.
```

```text
ICC2 place status: PASS_WITH_NOTE
ICC2 place log: 4_Backend_ICC2/3_Log/04_place/run_place_initial.log
ICC2 place legality: 4_Backend_ICC2/4_Report/04_place/check_legality.rpt
ICC2 place QoR: 4_Backend_ICC2/4_Report/04_place/place_qor.rpt
Place note: legality is clean; PG connectivity issue persists.
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
CTS result: clock tree compilation completed; route_clock reports 0 open nets and 0 DRCs; check_legality reports TOTAL 0 violations.
CTS note: PG connectivity remains not clean: VDD 3358 floating std cells, VSS 415 floating std cells.
```
