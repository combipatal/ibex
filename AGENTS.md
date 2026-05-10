# AGENTS.md instructions for /DATA/home/edu135/ibex

## Read First

After context reset, read these files before changing scripts, constraints, wrappers, filelists, or tool setup:

```text
init/context_bootstrap.md
2026-05-09_103000-ibex-mini-soc-implementation-flow.md
/DATA/home/edu135/AGENTS.md
```

Useful reference project files:

```text
/DATA/home/edu135/CV32E40P/AGENTS.md
/DATA/home/edu135/CV32E40P/configs/library_setup.tcl
/DATA/home/edu135/CV32E40P/docs/tt_mvt_10ns_scan1_execution_spec.md
```

## Project Purpose

This repository is for an Ibex RISC-V Mini SoC FE-to-BE implementation flow.

First milestone:

```text
Ibex RTL intake
source revision freeze
Ibex config freeze
Mini SoC top construction
DC synthesis
Formality R2N
ICC2 floorplan/powerplan/place/CTS/route
post-route timing/DRC/ANT/legality/PG report collection
RESULT_SUMMARY.md
```

Do not start clock, memory, or utilization sweeps before one baseline flow exists.

## Professional Execution Standard

Run this project like a practical ASIC implementation project, not as a demo.

Default behavior:

```text
prefer reproducible scripts over one-off terminal commands
keep DC, Formality, PT, and backend inputs aligned by top/config/filelist
freeze configuration before comparing area/timing/FM/backend results
record run commands, logs, reports, generated outputs, and pass/fail status
separate source-controlled project collateral from generated tool outputs
do not treat a tool completion as success until logs and signoff-style reports are checked
when results are suspiciously small, large, clean, or broken, inspect the cause before proceeding
```

For each major stage, leave enough evidence that another engineer can rerun and audit it after context reset:

```text
script path
exact command
input RTL/filelist/constraints/config
output netlist/database/SVF/SDF/SDC paths
primary log path
key reports checked
known warnings or limitations
next action
```

## Current State

```text
Ibex upstream clone exists at rtl/ibex.
Frozen upstream commit: 9742d89f54fc297bed026841c8e68454ddfd7cc0.
Project-specific Mini SoC RTL exists under rtl/mini_soc.
Synthesis top: ibex_mini_soc_top.
Ibex integration point: ibex_top instance u_ibex_top.
Official synthesis baseline: DC Graphical topographical run tag pre_backend_topo.
DC topo writes mapped DDC/netlist/SDC/SDF and Formality SVF.
DC topo must enable hdlin_enable_hier_map and call set_verification_top before compile so Formality receives hier_map SVF guidance.
Formality R2N has passed on the pre_backend_topo handoff.
PrimeTime STA uses the matching topo netlist/SDC/SDF; SVF is Formality provenance, not a PT input.
Pre-backend timing has no setup/hold violations, with known pre-backend max cap/transition DRC notes.
Backend route closure baseline uses project-local modified-LEF VIA1 pitch/no-track NDMs plus NOR2X0_HVT/NOR2X2_HVT/MUX41X2_HVT dont_use debug synthesis.
Backend route closure wrapper: 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh.
Backend route closure artifact: 4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib.
Backend route closure result: 0 open nets, 0 signal DRC, legality TOTAL 0, PG connectivity floating objects 0, PG DRC no errors, ICC2 timing.max MET 0.78 ns, timing.min MET 0.04 ns.
Formality for NOR2+MUX41 debug handoff passed with 34915 passing compare points, 0 failing, 0 unmatched, and SVF guidance 2146 accepted / 0 rejected.
VIA1 no-track library policy is accepted for project baseline promotion as of 2026-05-10 and recorded in docs/backend_library_policy.md.
Route closure case study is recorded in docs/ibex_backend_route_closure_case_study.md.
Educational GDS candidate wrapper: 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh.
Educational GDS candidate output: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.gds.
Educational GDS candidate result: GDS/DEF/netlist/SDC written; post-filler route DRC/open clean, legality clean, PG clean, and qor.after_filler reports clk critical path slack 0.78 ns.
GDS caveat: constraints.after_filler reports max_transition 8 and max_capacitance 228 violations; antenna/LVS/IR/EM/foundry DRC/metal-fill/signoff STA are not done, so do not claim signoff clean or tapeout-ready.
Post-route residual max-cap ECO candidate: 4_Backend_ICC2/0_Script/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.sh.
Post-route residual max-cap ECO artifact: 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/ibex_mini_soc_top_post_route_residual_maxcap_eco_icc2_lib.
Post-route residual max-cap ECO result: constraints.final reports max_transition 0, max_capacitance 0, min_capacitance 0; check_routes.final reports open nets 0 and route DRC 0; legality TOTAL 0; PG connectivity floating objects 0; check_pg_drc command reports no errors; timing.max/min reports MET 0.64 ns / 0.04 ns.
Post-route residual max-cap ECO FM/PT: fm_post_route_residual_maxcap_eco.log reports Verification SUCCEEDED with 34915 passing, 0 failing, 0 unmatched; PT post_route_residual_maxcap_eco reports no setup/hold violations and read_sdf errors 0.
Residual max-cap GDS refresh from 12 completed stream-out but reintroduced after-filler max_capacitance 4, so it is superseded.
Pre-filler margin ECO wrapper: 4_Backend_ICC2/0_Script/14_post_route_prefiller_maxcap_margin/run_post_route_prefiller_maxcap_margin.sh.
Pre-filler margin ECO artifact: 4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/ibex_mini_soc_top_post_route_prefiller_maxcap_margin_icc2_lib.
Pre-filler margin ECO result: driver-pin max-cap margin fixed by 5 NBUFFX2_RVT buffers; final reports show route DRC 0, max_transition 0, max_capacitance 0, min_capacitance 0, legality/PG clean, and timing positive.
Pre-filler margin ECO FM/PT: fm_post_route_prefiller_maxcap_margin.log reports Verification SUCCEEDED with 34915 passing, 0 failing, 0 unmatched; PT post_route_prefiller_maxcap_margin reports no setup/hold violations and read_sdf errors 0.
Final educational GDS candidate: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds.
Final GDS reports: 4_Backend_ICC2/4_Report/13_gds/post_route_prefiller_maxcap_margin_gds_candidate.
Final GDS result: after-filler route open 0/DRC 0, max_transition 0, max_capacitance 0, min_capacitance 0, legality clean, PG clean, timing positive; GDS size 157M.
Final GDS caveat: educational only; antenna/LVS/IR/EM/foundry DRC/metal-fill/signoff STA are not done, so do not claim signoff clean or tapeout-ready.
/DATA/home/edu135/ibex/.git is a read-only placeholder; use ./scripts/git_project.sh for .git_local.
```

## EDA Tool Execution

Run licensed EDA tools outside the sandbox.

This applies to:

```text
dc_shell
fm_shell
dft-related dc_shell runs
tmax
pt_shell
icc2_shell
lmutil
```

Use the sandbox only for lightweight file inspection, parsing, and documentation edits:

```text
rg
sed
ls
find
report parsing
documentation edits
```

## Recording Discipline

Do not leave important decisions only in chat or terminal output. Record them in the project.

When the project skeleton exists, keep these files updated:

```text
00_Project_Tracking/DECISION_LOG.md
00_Project_Tracking/RUN_MANIFEST.md
00_Project_Tracking/RUN_LOG.md
00_Project_Tracking/PROJECT_STATUS.md
00_Project_Tracking/RESULT_SUMMARY.md
```

When a tool run completes, update `RUN_LOG.md` and the relevant result table.

If a run fails, record:

```text
stage
command
log path
first fatal error
suspected root cause
next action
```

## Failure Diagnosis Discipline

When a tool run fails, crashes, hangs, regresses, or produces suspicious results, use the installed `diagnose` skill workflow before changing scripts broadly.

Apply this loop:

```text
build a reproducible pass/fail signal
reproduce and capture the exact symptom
list 3-5 falsifiable root-cause hypotheses
instrument or inspect one hypothesis at a time
try the smallest targeted fix or workaround
evaluate against the original pass/fail signal
record the result, rejected hypotheses, and next action
```

For EDA failures, the feedback loop should normally be a scripted tool invocation plus report/log checks, not a visual guess.

Record diagnosis notes in `00_Project_Tracking/` when the issue affects project direction or rerun policy.

Every major claim must point to an artifact.

Examples:

```text
Synthesis passed -> DC log + check_design report + mapped netlist path
R2N passed -> Formality verify report
ICC2 route completed -> ICC2 log + route/check_routes report + output database/netlist paths
Post-route timing checked -> timing report with WNS/TNS/violating endpoints
```

## Library Context

Primary library root:

```text
/DATA/home/edu135/lib/SAED32_EDK
```

PDK root:

```text
/DATA/home/edu135/lib/SAED32nm_PDK_04152022
```

Initial recommended DC/FM/PT timing libraries:

```text
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db
```

Useful ICC2 physical/RC files:

```text
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef
/DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
/DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
/DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
/DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_nominal.tluplus
/DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_tf_itf_tluplus.map
```

## Ibex Config Freeze

Ibex config must be frozen before synthesis and reused by DC, Formality, and backend scripts.

Record exact values in:

```text
docs/ibex_config.md
```

Must include:

```text
RV32E or RV32I
RV32M option
BranchTargetALU
Multiplier / Divider
PMP enable + entry count
Debug enable + tie-off
RVFI enable
performance counter enable + count
ICache
branch option
SecureIbex/hardening
reset vector / boot address
exception/interrupt tie-off policy
selected Ibex integration point: ibex_core / ibex_top / custom wrapper
actual synthesis top: ibex_mini_soc_top
Ibex instance path inside SoC top
parameter source and exact override table
DC parameter passing method
Formality parameter passing method
evidence that DC and FM read the same top/config/filelist
tie-off location: wrapper RTL vs synthesis script constants
```

Initial recommendation:

```text
actual synthesis top: ibex_mini_soc_top
integration point: instantiate ibex_core directly first
ISA: RV32IMC if feasible after RTL intake
BranchTargetALU: disabled for first baseline
PMP: disabled
Debug: disabled or tied off
RVFI: disabled
ICache: disabled
reset vector / boot address: 0x0000_0000
parameter source: prefer wrapper-level override
avoid tool-script-only parameter override
tie-off location: prefer wrapper RTL
keep DC/FM filelist identical
```

## Skill Usage

Use installed skills only when the user's intent clearly matches the skill description. If a skill is used, briefly say which skill is being used and why.

Common matches:

```text
diagnose: broken/failing tool runs, errors, regressions, hard debug
tdd: explicit test-first/red-green-refactor request
prototype: throwaway sanity-check or prototype request
grill-me / grill-with-docs: stress-test a plan or design
to-prd / to-issues / triage: PRD, issue breakdown, or issue workflow
caveman: user asks for very brief/caveman/low-token mode
zoom-out: broader codebase/domain overview
improve-codebase-architecture: architecture/refactoring opportunity request
```

For ordinary documentation or narrow implementation edits, no special skill is required.

## Claim Boundary

Allowed only after evidence exists:

```text
DC synthesis completed
Formality R2N performed
ICC2 floorplan/powerplan/place/CTS/route performed
post-route timing/DRC/QoR reports collected
```

Do not claim unless explicitly proven by reports:

```text
signoff-clean
DRC clean
hold clean
IR/EM complete
LVS clean
ATPG complete
software boot complete
full ISA verification
production readiness
```
