# Result Summary

| Stage | Tool | Result | Key Report | Open Item |
|---|---|---:|---|---|
| RTL intake | git/filelist | PASS | docs/rtl_intake.md | Keep upstream commit/config frozen |
| DC analyze/elaborate/link | DC | PASS_WITH_NOTE | 2_Synthesis/4_Report/analyze/check_design.rpt | Classify unused Ibex shadow/debug/feature tie-off warnings before full compile |
| Synthesis | DC Graphical topo | PASS_WITH_NOTE | 2_Synthesis/4_Report/topo/post_compile.qor.rpt | Pre-backend max cap/transition DRC remains for backend closure |
| Pre-backend STA | PrimeTime | PASS_WITH_NOTE | 5_STA/4_Report/pre_backend_topo/global_timing.rpt | Reset recovery/removal untested by current async reset policy |
| Formality R2N | FM | PASS_WITH_NOTE | 3_Formality/3_Log/fm_r2n_topo.log | Auto setup and RTL interpretation warnings recorded |
| Floorplan | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/02_floorplan/utilization.rpt | Initial 0.6004 utilization floorplan only |
| Powerplan | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/03_powerplan/pg_connectivity.rpt | PG connectivity not clean; PG DRC clean |
| Place | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/04_place/check_legality.rpt | PG connectivity issue persists |
| CTS | ICC2 | PASS_WITH_NOTE | 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt | PG connectivity not clean; route_clock DRC/open nets clean |
| Route | ICC2 | PENDING | pending | Needs route run; PG connectivity issue remains open before/through route |
| Post-route timing | ICC2/PT | PENDING | pending | Needs routed design |

## Backend Open Items

```text
CTS clean retry completed on 2026-05-09.
Clock routing: 0 open nets, 0 DRCs in run_cts_initial.log.
Legality: 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt reports TOTAL 0 violations.
Timing: timing.max worst reported slack MET 0.63 ns; timing.min worst reported slack MET 0.04 ns.
PG DRC: 4_Backend_ICC2/4_Report/05_cts/pg_drc.rpt reports no errors.
PG connectivity: not clean. VDD has 3358 floating std cells and VSS has 415 floating std cells in 4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt.
```
