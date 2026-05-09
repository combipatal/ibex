# Project Status

## Current Phase

```text
Phase: B0 Repository Intake
Status: COMPLETE
```

```text
Phase: B1 Mini SoC RTL + DC smoke
Status: COMPLETE
```

```text
Phase: B2 DC full synthesis
Status: COMPLETE_WITH_NOTES
```

```text
Phase: B3 pre-backend STA
Status: COMPLETE_WITH_NOTES
```

```text
Phase: B4 Formality R2N
Status: COMPLETE_WITH_NOTES
```

```text
Phase: B5 Backend init/floorplan/powerplan/place
Status: COMPLETE_WITH_OPEN_PG_NOTE
```

```text
Phase: B6 CTS
Status: COMPLETE_WITH_NOTES
```

## Checklist

```text
[x] Create project skeleton
[x] Create initial tracking files
[x] Clone lowRISC/ibex
[x] Record Ibex commit hash
[x] Read Ibex README/license
[x] Identify initial synthesizable RTL filelist method
[x] Freeze initial Ibex config
[x] Create Mini SoC RTL skeleton
[x] Create first DC filelist and SDC
[x] Run DC analyze/elaborate/link smoke
[x] Run topographical DC compile and generate mapped outputs/SVF
[x] Run pre-backend STA on the matching topo netlist/SDC/SDF
[x] Run Formality R2N against mapped netlist
[x] Build ICC2 SAED32 NDM libraries
[x] Run ICC2 init_design
[x] Create initial floorplan
[x] Create initial powerplan
[x] Run initial placement/legalization
[ ] Resolve or classify PG connectivity open issue
[x] Complete CTS
[ ] Complete route
[ ] Complete post-route timing/report extraction
```

## Current Notes

```text
DC topo timing: WNS 0.00 ns, TNS 0.00 ns, no setup/hold violating paths.
PT pre-backend STA: no setup/hold violations.
Formality R2N: Verification SUCCEEDED, 34915 passing compare points, 0 failing, 0 unmatched.
SVF guidance: DC topo now emits hier_map guidance; FM accepted 2146 guidance commands and rejected 0.
Known open implementation note: pre-backend max transition/cap violations remain and are acceptable to carry into backend closure for this baseline.
Known constraint note: rst_ni is intentionally not clock-relative; recovery/removal checks are currently untested.
ICC2 init/floorplan/place: completed through placement; placement legality reports TOTAL 0 violations.
Backend PG note: powerplan/place PG DRC is clean, but PG connectivity is not clean. VDD has 3142 std-cell unconnected ports and VSS has 380 std-cell unconnected ports in current reports.
CTS status: clean single-process retry completed. Clock tree compilation finished successfully; routed clock nets report 0 open nets and 0 DRCs; check_legality reports TOTAL 0 violations.
CTS timing: timing.max worst reported slack MET 0.63 ns; timing.min worst reported slack MET 0.04 ns; qor.rpt reports total negative slack 0.00.
CTS diagnosis: previous aborted logs were not accepted because duplicate/log-contaminated attempts and termination artifacts made the result unreliable. Clean retry shows the Phase 6 Iter 2 no-output interval was a long-running optimization step, not a hang.
CTS PG note: PG DRC is clean, but PG connectivity is still not clean after CTS. VDD reports 3358 floating std cells and VSS reports 415 floating std cells.
Execution note: observed icc2_exec %CPU near 100 means one logical core is busy, not whole-machine 100 percent CPU usage.
Next phase: route can proceed from the saved ICC2 design, but PG connectivity remains the primary open backend issue.
```
