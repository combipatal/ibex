# IBEX_MINI_SOC_IMPLEMENTATION_FLOW — Project Plan

- 작성 시각: 2026-05-09 10:30 UTC
- 프로젝트 성격: Open-source Ibex RISC-V core 기반 Mini SoC FE-to-BE implementation flow 구축
- 1차 목표: 비교/sweep이 아니라, Mini SoC RTL 구성 후 DC/Formality/ICC2 backend route/post-route report까지 end-to-end flow 1회 완주
- Primary source: https://github.com/lowRISC/ibex
- Support source: https://github.com/lowRISC/ibex-demo-system

---

## 1. Project Purpose

Open-source Ibex RISC-V core를 기반으로 작은 SoC top을 구성한다. Ibex core 단독 backend가 아니라 instruction/data memory, simple interconnect, timer/GPIO 등 작은 주변 블록을 포함한 SoC-level implementation target을 만든다.

핵심은 RTL 설계 과시가 아니라, 주어진 CPU RTL과 간단한 SoC wrapper를 input design으로 받아 FE-to-BE implementation flow를 구축하는 것이다.

목표 flow:

```text
Ibex RTL intake
→ source revision freeze
→ Ibex config freeze
→ Mini SoC top 구성
→ filelist cleanup
→ SDC creation
→ DC synthesis
→ Formality R2N
→ ICC2 init_design
→ floorplan
→ powerplan
→ placement
→ CTS
→ route
→ post-route timing/report extraction
→ DRC/ANT/legality/PG checks
→ RESULT_SUMMARY
```

Portfolio one-liner:

> Ibex RISC-V core 기반 mini SoC를 대상으로 RTL integration, DC synthesis, Formality R2N, ICC2 floorplan/powerplan/place/CTS/route, post-route analysis까지 연결되는 FE-to-BE implementation flow를 구축했다.

---

## 2. Why This Project

선정 이유:

```text
- Ibex는 production-quality open-source RISC-V core
- SystemVerilog
- CV32E40P보다 작아 backend 반복 가능성 높음
- core 단독이 아니라 mini SoC로 키우면 project scale 확보 가능
- CPU + memory + peripheral integration으로 NPU project와 역할 분리됨
```

기존 CV32E40P와 역할 구분:

```text
CV32E40P = RISC-V CPU Front-End flow evidence
Ibex Mini SoC = RISC-V based SoC FE-to-BE/backend implementation evidence
```

---

## 3. Initial SoC Target

Baseline SoC:

```text
Ibex core
+ simple instruction memory wrapper
+ simple data memory wrapper
+ address decoder/interconnect
+ GPIO
+ timer
+ interrupt tie-off or simple interrupt path
+ single clock/reset
+ stdcell-only memory for v1
```

Recommended memory size v1:

```text
IMEM: 2KB regfile memory
DMEM: 2KB regfile memory
```

Reason:

```text
- core-only looks small
- 2KB/2KB gives SoC scale without huge runtime
- stdcell memory avoids SRAM macro/floorplan dependency for first baseline
```

Potential v2:

```text
IMEM/DMEM 4KB or 8KB
UART-lite
memory blackbox/SRAM macro placeholder
clock/util/memory sweep
```

Address map draft:

```text
0x0000_0000 - 0x0000_07FF : IMEM 2KB
0x0001_0000 - 0x0001_07FF : DMEM 2KB
0x0002_0000 - 0x0002_00FF : GPIO
0x0002_0100 - 0x0002_01FF : TIMER
```

---

## 4. First Milestone

1차 목표:

```text
Ibex Mini SoC 1개 baseline을 FE-to-BE 끝까지 연결한다.
```

1차 완료 기준:

```text
- Ibex repo cloned and commit frozen
- selected Ibex config frozen and recorded
- mini SoC top created or adapted
- IMEM/DMEM/GPIO/timer/address map documented
- RTL filelist cleaned
- SDC written
- DC analyze/elaborate/link completed
- DC synthesis completed
- netlist/DDC/SDC/SDF/SVF generated
- Formality R2N passed or failing root cause documented
- ICC2 init/floorplan/powerplan/place/CTS/route completed
- open nets / legality / PG / DRC / timing reports collected
- RESULT_SUMMARY.md written
```

Strong done:

```text
- R2N PASS
- route open nets 0
- legality clean
- PG connectivity clean
- route DRC clean or root cause classified
- setup/hold checked after route
- scripts rerunnable from clean workspace
```

---

## 5. Non-goals for First Milestone

First pass에서 하지 않는 것:

```text
- Linux/software boot
- full RISC-V compliance verification
- UVM environment
- real SRAM macro integration
- AXI/AHB complexity unless already simple
- DFT/ATPG first pass
- memory size sweep
- clock/utilization comparison
- IR/EM signoff
```

이후 확장:

```text
- memory size sweep: 1KB/2KB/4KB or 2KB/4KB/8KB
- clock sweep: 10ns / 7ns / 5ns
- utilization sweep: 50% / 60% / 70%
- CTS/timing ECO case
- UART-lite addition
- SRAM macro placeholder floorplan practice
```

---

## 6. Work Breakdown

### B0 — Repository Intake

Tasks:

```text
1. Clone lowRISC/ibex.
2. Record commit hash.
3. Read license/README.
4. Identify core RTL filelist method.
5. Identify simple system/demo system reference.
6. Select and freeze Ibex core configuration.
7. Document exact configuration values in docs/ibex_config.md.
8. Decide whether to adapt existing simple system or write local mini_soc_top.
```

Required config documentation:

```text
- RV32E or RV32I
- RV32M option
- BranchTargetALU
- Multiplier / Divider
- PMP enable + entry count
- Debug enable + tie-off
- RVFI enable
- performance counter enable + count
- ICache
- branch option
- SecureIbex/hardening
- reset vector / boot address
- exception/interrupt tie-off policy
- selected Ibex integration point: ibex_core / ibex_top / custom wrapper
- actual synthesis top: ibex_mini_soc_top
- Ibex instance path inside SoC top
- ibex_top usage or non-usage
- parameter source: RTL wrapper override / package config / tool script override
- exact parameter override table
- DC parameter passing method
- Formality parameter passing method
- evidence that DC and FM read the same top/config/filelist
- tie-off location: wrapper RTL vs synthesis script constants
```

Initial recommended config:

```text
- ISA: RV32IMC if feasible after RTL intake
- BranchTargetALU: disabled for first baseline
- PMP: disabled
- Debug: disabled or tied off
- RVFI: disabled
- ICache: disabled
- reset vector / boot address: 0x0000_0000
- actual synthesis top: ibex_mini_soc_top
- integration point: instantiate ibex_core directly first
- parameter source: prefer wrapper-level override
- avoid tool-script-only parameter override
- tie-off location: prefer wrapper RTL
- keep DC/FM filelist identical
```

Reason:

```text
Ibex configuration changes generated hierarchy, ports, debug/RVFI/counter logic,
timing, and backend size. If DC and Formality elaborate different top/config/filelist
sets, R2N can fail before meaningful comparison. The config must be frozen before
synthesis and reused by every downstream tool.
```

Deliverables:

```text
00_Project_Tracking/SOURCE_REVISION.md
docs/ibex_config.md
docs/rtl_intake.md
```

Exit criteria:

```text
Ibex core filelist known
config known
mini SoC top strategy chosen
```

### B1 — Mini SoC Top Construction

Tasks:

```text
1. Instantiate Ibex core.
2. Add instruction memory model.
3. Add data memory model.
4. Add address decoder.
5. Add GPIO register block.
6. Add timer register block.
7. Tie off unused debug/interrupt/interfaces carefully.
8. Add reset synchronizer only if needed.
```

Deliverables:

```text
0_RTL/mini_soc/ibex_mini_soc_top.sv
0_RTL/mini_soc/simple_imem.sv
0_RTL/mini_soc/simple_dmem.sv
0_RTL/mini_soc/simple_decoder.sv
0_RTL/mini_soc/gpio.sv
0_RTL/mini_soc/timer.sv
```

Exit criteria:

```text
DC can analyze/elaborate mini SoC top
```

### B2 — Front-End Setup

Tasks:

```text
1. Build DC filelist.
2. Create SDC.
3. Set clock/reset.
4. Set IO delays.
5. Define false paths for async reset/debug only if justified.
6. Run DC link/check_design.
```

Deliverables:

```text
1_Input/filelists/ibex_mini_soc.f
1_Input/constraints/ibex_mini_soc_10ns.sdc
2_Synthesis/0_Script/run_dc.tcl
```

Exit criteria:

```text
link succeeds
unresolved references 0
```

### B3 — DC Synthesis Baseline

Run target:

```text
clock: 10ns
top: ibex_mini_soc_top
memory: 2KB IMEM + 2KB DMEM stdcell regfile
```

Tasks:

```text
1. Run synthesis.
2. Save DDC/netlist/SDC/SDF/SVF.
3. Generate reports.
4. Record memory area/cell count impact.
5. Classify warnings.
```

Reports:

```text
check_design.rpt
report_qor.rpt
report_timing.max.rpt
report_timing.min.rpt
report_area.rpt
report_power.rpt
report_constraint.rpt
report_hierarchy.rpt
```

Exit criteria:

```text
netlist generated
setup result recorded
memory area/cell count recorded
```

### B4 — Formality R2N

Tasks:

```text
1. Read same RTL filelist as reference.
2. Read synthesized netlist as implementation.
3. Read SVF.
4. Apply constants/tie-offs matching synthesis.
5. Verify.
```

Potential issue:

```text
Ibex has packages, parameters, generate blocks, and memories.
Keep filelist/config identical between DC and FM.
```

Deliverables:

```text
3_Formality/0_Script/run_fm_r2n.tcl
3_Formality/4_Report/r2n.summary.rpt
```

Exit criteria:

```text
R2N PASS preferred
If fail: root cause documented with failing compare points
```

### B5 — ICC2 Backend Flow

Tasks:

```text
1. init_design from synthesized netlist.
2. create floorplan.
3. create powerplan.
4. place.
5. CTS.
6. route.
7. collect post-route reports.
```

Initial physical target:

```text
utilization: 55~60%
aspect ratio: 1:1
clock: 10ns
stdcell-only
```

Reports:

```text
design_physical.rpt
utilization.rpt
pg_connectivity.rpt
pg_drc.rpt
place_qor.rpt
clock_qor.summary.rpt
route_check_routes.rpt
timing.max.rpt
timing.min.rpt
check_legality.rpt
antenna.rpt
```

Exit criteria:

```text
route completed
open nets recorded
legality recorded
DRC/ANT status recorded
timing recorded
```

### B6 — Summary / Final Report

Deliverables:

```text
00_Project_Tracking/PROJECT_STATUS.md
00_Project_Tracking/RESULT_SUMMARY.md
00_Project_Tracking/RUN_LOG.md
docs/final_fe_to_be_flow_report.md
```

Summary table:

```text
Stage | Tool | Result | Key report | Open item
RTL intake | git/filelist | PASS | source revision | ...
Synthesis | DC | PASS/PASS_WITH_NOTE | report_qor | ...
Formality | FM | PASS/PASS_WITH_NOTE | r2n.summary | ...
Floorplan | ICC2 | PASS | design_physical | ...
Powerplan | ICC2 | PASS/PASS_WITH_NOTE | pg_drc/connectivity | ...
Place | ICC2 | PASS/PASS_WITH_NOTE | place_qor | ...
CTS | ICC2 | PASS/PASS_WITH_NOTE | clock_qor | ...
Route | ICC2 | PASS/PASS_WITH_OPEN | check_routes | ...
Post-route timing | PT/ICC2 | PASS/PASS_WITH_NOTE | timing | ...
```

---

## 7. Project Directory Template

```text
IBEX_MINI_SOC_IMPLEMENTATION_FLOW/
├── README.md
├── docs/
│   ├── rtl_intake.md
│   ├── ibex_config.md
│   ├── address_map.md
│   ├── constraint_strategy.md
│   ├── backend_flow.md
│   └── final_fe_to_be_flow_report.md
├── 0_RTL/
│   ├── ibex/
│   └── mini_soc/
├── 1_Input/
│   ├── filelists/
│   ├── constraints/
│   └── tech/
├── 2_Synthesis/
│   ├── 0_Script/
│   ├── 2_Output/
│   ├── 3_Log/
│   └── 4_Report/
├── 3_Formality/
│   ├── 0_Script/
│   ├── 3_Log/
│   └── 4_Report/
├── 4_Backend_ICC2/
│   ├── 0_Script/
│   │   ├── 00_setup/
│   │   ├── 01_init_design/
│   │   ├── 02_floorplan/
│   │   ├── 03_powerplan/
│   │   ├── 04_place/
│   │   ├── 05_cts/
│   │   ├── 06_route/
│   │   ├── 07_extract_sta/
│   │   └── 99_util/
│   ├── 2_Output/
│   ├── 3_Log/
│   └── 4_Report/
├── scripts/
│   ├── collect_reports.py
│   ├── parse_qor.py
│   └── make_summary.py
└── 00_Project_Tracking/
    ├── SOURCE_REVISION.md
    ├── PROJECT_STATUS.md
    ├── RESULT_SUMMARY.md
    ├── RUN_LOG.md
    └── DECISION_LOG.md
```

---

## 8. Possible Blockers

```text
- Ibex package/config mismatch
- RVFI/debug/performance counter interfaces need tie-off
- memory regfile too large for synthesis runtime
- Formality mismatch from memories or generated parameters
- backend congestion due stdcell memories
```

Handling:

```text
Start with 2KB/2KB.
If synthesis too large, reduce to 1KB/1KB.
If SoC top too complex, synthesize Ibex core alone once as debug baseline, then restore SoC path.
Do not start memory sweep before baseline flow exists.
```

---

## 9. First 3-Day Action Plan

Day 1:

```text
clone Ibex
record commit
inspect simple system/demo system
choose config
identify core filelist
run Ibex core DC analyze feasibility
```

Day 2:

```text
draft mini SoC top
add 2KB IMEM/DMEM wrapper
add decoder/GPIO/timer skeleton
try DC analyze/elaborate/link
record blockers
```

Day 3:

```text
fix link/config/tie-off issues
create initial SDC
run first DC synthesis if link succeeds
write SOURCE_REVISION.md, ibex_config.md, rtl_intake.md
```

Decision after Day 3:

```text
If mini SoC link OK → proceed full baseline.
If mini SoC blocks → synthesize Ibex core alone once to isolate issue, then return to SoC top.
```

---

## 10. Claim Boundary

Allowed after first baseline:

```text
Ibex 기반 mini SoC FE-to-BE implementation flow 구축
DC synthesis 완료
Formality R2N 검증 수행/PASS if passed
ICC2 floorplan/powerplan/place/CTS/route 수행
post-route timing/DRC/QoR report 확보
```

Use only if true:

```text
signoff-clean
DRC clean
hold clean
IR/EM complete
LVS clean
ATPG complete
software boot complete
```

Status labels:

```text
PASS
PASS_WITH_NOTE
PASS_WITH_OPEN
RECORDED
BLOCKED_WITH_ROOT_CAUSE
```
