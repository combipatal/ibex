# Backend Flow

Initial ICC2 target:

```text
Technology: SAED32 1p9m
Utilization: 55-60%
Aspect ratio: 1:1
Memory style: stdcell-only for first baseline
```

## Current Backend Baseline

```text
Input handoff: DC topographical pre_backend_topo netlist/SDC
Backend library: SAED32 RVT/LVT/HVT NDM generated under 4_Backend_ICC2/2_Output/00_setup/ndm
ICC2 design library: 4_Backend_ICC2/2_Output/01_init_design/ibex_mini_soc_top_icc2_lib
```

## Completed Stages

```text
NDM setup: PASS_WITH_NOTE
init_design: PASS_WITH_NOTE
floorplan: PASS_WITH_NOTE, utilization 0.6004
powerplan: PASS_WITH_NOTE, PG DRC clean, PG connectivity not clean
place: PASS_WITH_NOTE, legality clean
CTS: PASS_WITH_NOTE, clean single-process retry completed
```

CTS evidence:

```text
Log: 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log
Clock post-check: 4_Backend_ICC2/4_Report/05_cts/check_clock_trees.post.rpt
Legality: 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt
Timing max/min: 4_Backend_ICC2/4_Report/05_cts/timing.max.rpt, timing.min.rpt
PG connectivity: 4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt
```

CTS result:

```text
clock tree compilation completed successfully
clock route detail routing ended with 0 open nets and 0 DRCs
check_legality reports TOTAL 0 violations
timing.max worst reported slack MET 0.63 ns
timing.min worst reported slack MET 0.04 ns
```

## Open Backend Issue

```text
PG connectivity remains not clean after CTS.
05_cts pg_connectivity.rpt: VDD 3358 floating std cells, VSS 415 floating std cells.
PG DRC remains clean.
Route may proceed as a baseline continuation only if this issue is explicitly tracked; strict backend strong-done still requires PG connectivity cleanup or root-cause classification.
```
