# Ibex Mini SoC FE-to-BE Implementation Flow

This repository contains an educational front-end to back-end ASIC implementation
flow for a small Ibex RISC-V based Mini SoC.

The project integrates a frozen Ibex RTL revision into `ibex_mini_soc_top`,
runs DC Graphical topographical synthesis, checks RTL-to-netlist equivalence
with Formality, runs PrimeTime STA on exported netlist/SDC/SDF handoffs, closes
an ICC2 backend route, applies post-route electrical ECO, and exports a final
educational GDS candidate.

## Status

```text
Status: CLOSED_AS_EDUCATIONAL_FE_TO_BE_IMPLEMENTATION_FLOW
Closure date: 2026-05-11
Synthesis top: ibex_mini_soc_top
Ibex instance: u_ibex_top
Frozen Ibex commit: 9742d89f54fc297bed026841c8e68454ddfd7cc0
Final candidate: post_route_prefiller_maxcap_margin_gds_candidate
```

## Flow

```text
Ibex RTL intake
-> source revision freeze
-> Ibex configuration freeze
-> Mini SoC top construction
-> DC Graphical topographical synthesis
-> Formality R2N
-> PrimeTime pre/post-route STA
-> ICC2 floorplan, powerplan, place, CTS, route
-> route DRC diagnosis and closure
-> post-route max-cap ECO
-> final educational GDS export
-> result summary and project closure records
```

## Final Evidence Summary

| Area | Result | Evidence |
|---|---|---|
| DC topo synthesis | Completed, mapped DDC/netlist/SDC/SDF/SVF generated | `2_Synthesis/4_Report/topo/post_compile.qor.rpt` |
| Formality R2N | Passed, 34915 passing compare points, 0 failing, 0 unmatched | `3_Formality/4_Report/pre_backend_topo` |
| Route closure baseline | 0 open nets, 0 signal route DRC, legality and PG clean, timing positive | `4_Backend_ICC2/4_Report/07_route_closure/06_route` |
| Final post-route ECO | max_transition 0, max_capacitance 0, min_capacitance 0, route DRC 0 | `4_Backend_ICC2/4_Report/14_post_route_prefiller_maxcap_margin` |
| Final ECO Formality | Passed, 34915 passing, 0 failing, 0 unmatched | `3_Formality/4_Report/post_route_prefiller_maxcap_margin` |
| Final ECO PrimeTime | No setup/hold violations in the checked scenario | `5_STA/4_Report/post_route_prefiller_maxcap_margin` |
| Final educational GDS | GDS/DEF/VG/SDC exported; after-filler route/electrical/PG reports clean | `4_Backend_ICC2/4_Report/13_gds/post_route_prefiller_maxcap_margin_gds_candidate` |

## Important Claim Boundary

This is an educational implementation-flow project, not a tapeout-ready signoff
package.

Do not claim:

- production readiness
- tapeout readiness
- foundry signoff DRC clean
- LVS clean
- antenna signoff clean
- IR/EM complete
- metal fill complete
- full signoff STA complete

Those items were not performed or are not evidenced in this repository.

## Repository Contents

```text
rtl/mini_soc/                 Project Mini SoC RTL
constraints/                  Project constraints
2_Synthesis/0_Script/         DC scripts and wrappers
2_Synthesis/4_Report/         DC reports
3_Formality/0_Script/         Formality scripts and wrappers
3_Formality/4_Report/         Formality reports
4_Backend_ICC2/0_Script/      ICC2 backend scripts and wrappers
4_Backend_ICC2/4_Report/      ICC2 backend reports
5_STA/0_Script/               PrimeTime scripts and wrappers
5_STA/4_Report/               PrimeTime reports
docs/                         Design/config/backend policy notes
00_Project_Tracking/          Run logs, manifests, status, summary, closure
```

Large generated implementation databases, logs, GDS/output handoff files, and
the upstream Ibex clone are intentionally excluded from Git. Reports are kept in
Git so the flow claims remain auditable.

## Key Documents

```text
00_Project_Tracking/PROJECT_CLOSURE.md
00_Project_Tracking/RESULT_SUMMARY.md
00_Project_Tracking/RUN_MANIFEST.md
00_Project_Tracking/RUN_LOG.md
docs/ibex_config.md
docs/backend_library_policy.md
docs/ibex_backend_route_closure_case_study.md
```

## Git Note

This workspace uses a project-local Git directory because `.git` is a read-only
placeholder in this environment. Use:

```sh
./scripts/git_project.sh status
./scripts/git_project.sh diff --cached --stat
```
