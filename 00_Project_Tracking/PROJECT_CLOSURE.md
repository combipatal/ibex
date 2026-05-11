# Ibex Mini SoC Project Closure

## Date

```text
Closure date: 2026-05-11
Status: CLOSED_AS_EDUCATIONAL_FE_TO_BE_IMPLEMENTATION_FLOW
Scope: Ibex Mini SoC FE-to-BE educational implementation flow
```

## Closure Declaration

```text
The Ibex Mini SoC project is closed as an educational front-end to back-end
implementation flow.
```

This closure means the project has an auditable baseline from frozen Ibex RTL and
Mini SoC integration through DC synthesis, Formality, PrimeTime, ICC2 backend
route closure, post-route electrical ECO, and final educational GDS candidate
export.

This closure does not mean the design is tapeout-ready or signoff-clean.

## Final Candidate

```text
Final candidate: post_route_prefiller_maxcap_margin_gds_candidate
Final GDS:
4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds
Recorded GDS size: 157M
Source ICC2 block:
4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/ibex_mini_soc_top_post_route_prefiller_maxcap_margin_icc2_lib
Final GDS report root:
4_Backend_ICC2/4_Report/13_gds/post_route_prefiller_maxcap_margin_gds_candidate
```

## Final Evidence

| Evidence item | Result | Primary artifact |
|---|---|---|
| DC topo synthesis | Completed with mapped DDC/netlist/SDC/SDF/SVF. Setup/hold path violations are 0; pre-backend max transition/cap was carried into backend closure. | `2_Synthesis/3_Log/dc_compile_topo.log`, `2_Synthesis/4_Report/topo/post_compile.qor.rpt` |
| Formality R2N baseline | PASS: 34915 passing compare points, 0 failing, 0 unmatched; SVF guidance 2146 accepted / 0 rejected. | `3_Formality/3_Log/fm_r2n_topo.log` |
| Route-closure baseline | 0 open nets, 0 signal DRC, legality TOTAL 0, PG connectivity floating objects 0, PG DRC no errors, timing.max/min positive with representative slack +0.78 ns / +0.04 ns. | `4_Backend_ICC2/4_Report/07_route_closure/06_route/check_routes.rpt`, `timing.max.rpt`, `timing.min.rpt` |
| Backend library policy | VIA1 pitch/no-track project-local NDM policy accepted for this educational baseline. | `docs/backend_library_policy.md` |
| Pre-filler margin ECO | Completed. 5 `NBUFFX2_RVT` buffers inserted; max_transition 0, max_capacitance 0, min_capacitance 0, route DRC 0, legality clean, PG clean, timing positive. | `4_Backend_ICC2/4_Report/14_post_route_prefiller_maxcap_margin/constraints.final.rpt`, `check_routes.final.rpt` |
| Formality after final ECO | PASS: 34915 passing compare points, 0 failing, 0 unmatched; SVF guidance 2146 accepted / 0 rejected. | `3_Formality/3_Log/fm_post_route_prefiller_maxcap_margin.log` |
| PrimeTime SDF STA after final ECO | No setup/hold violations; SDF read errors 0; setup slack about +0.67 ns; hold slack about +0.03 ns. | `5_STA/4_Report/post_route_prefiller_maxcap_margin/global_timing.rpt`, `qor.rpt`, `5_STA/3_Log/pt_post_route_prefiller_maxcap_margin_sdf.log` |
| Final educational GDS candidate | GDS/DEF/VG/SDC written. After-filler open nets 0, route DRC 0, max_transition 0, max_capacitance 0, min_capacitance 0, legality clean, PG clean, timing positive. | `4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/gds_export_manifest.txt`, `4_Backend_ICC2/4_Report/13_gds/post_route_prefiller_maxcap_margin_gds_candidate` |

## What This Project Proves

```text
The project proves that a frozen Ibex configuration can be integrated into a
small Mini SoC and carried through a reproducible educational ASIC
implementation flow with saved scripts, logs, reports, and final handoff files.
```

It specifically proves:

- Ibex upstream source revision and configuration were frozen and documented.
- `ibex_mini_soc_top` was built as the implementation top with `u_ibex_top` as the Ibex integration point.
- DC Graphical topographical synthesis produced a reusable handoff.
- Formality R2N equivalence passed for the synthesis handoff and final ECO netlist.
- PrimeTime read the matching netlist/SDC/SDF and reported no setup/hold violations for the checked scenario.
- ICC2 backend progressed through floorplan, powerplan, placement, CTS, route, route DRC closure, electrical ECO, filler insertion, and GDS export.
- Route DRC closure was diagnosed and recorded instead of hidden behind a tool-completion claim.
- Final educational GDS collateral was generated with matching reports and explicit claim boundaries.

## Claim Boundary

Allowed claims:

```text
Educational FE-to-BE Ibex Mini SoC implementation flow completed.
Final educational GDS candidate generated.
Saved ICC2 after-filler reports show open nets 0, route DRC 0, max_transition 0,
max_capacitance 0, min_capacitance 0, legality clean, PG clean, and positive
timing for the final candidate.
Formality and PrimeTime evidence exists for the final ECO handoff.
```

Not allowed without additional evidence:

```text
tapeout-ready
foundry signoff clean
production signoff GDS
antenna clean
LVS clean
IR/EM clean
metal fill complete
full signoff STA complete
production-ready silicon
```

## Do-Not-Claim List

- Do not claim tapeout-ready.
- Do not claim foundry signoff clean.
- Do not claim production signoff GDS.
- Do not claim antenna verification; antenna rules are absent and antenna is not verified.
- Do not claim LVS; LVS was not performed.
- Do not claim IR/EM; IR/EM was not performed.
- Do not claim foundry signoff DRC; foundry signoff DRC was not performed.
- Do not claim metal fill; metal fill was not performed.
- Do not claim full signoff STA methodology; full signoff STA methodology is not evidenced.
- Do not claim ATPG, software boot, or full ISA verification.

## Portfolio/Interview Safe Claim

```text
I built an educational Ibex RISC-V Mini SoC FE-to-BE implementation flow with a
frozen RTL/config handoff, DC topographical synthesis, Formality R2N, PrimeTime
SDF STA, ICC2 floorplan/powerplan/place/CTS/route, route DRC diagnosis and
closure, post-route max-cap ECO, and final educational GDS export. The final
candidate has saved ICC2 after-filler reports showing 0 open nets, 0 route DRC,
0 max_transition, 0 max_capacitance, clean legality/PG checks, and positive
timing, plus Formality and PrimeTime evidence. I keep the claim bounded as
educational because foundry DRC, LVS, antenna, IR/EM, metal fill, and full
signoff STA were not performed.
```

## Remaining Optional Extensions

- Add antenna-rule setup and rerun antenna analysis if suitable rules are available.
- Add LVS setup and compare final GDS against the exported netlist.
- Add foundry-style signoff DRC if a signoff deck/environment is available.
- Add metal fill and repeat route/electrical/PG/timing checks after fill.
- Build a signoff STA methodology with extracted parasitics and multi-corner/multi-mode coverage.
- Add IR/EM analysis if power intent, activity, and tool setup are available.
- Add software preload/boot sanity work using the existing IMEM preload path.
- Add verification extensions only after preserving the current closed baseline.
