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
```

## Current Notes

```text
DC topo timing: WNS 0.00 ns, TNS 0.00 ns, no setup/hold violating paths.
PT pre-backend STA: no setup/hold violations.
Formality R2N: Verification SUCCEEDED, 34915 passing compare points, 0 failing, 0 unmatched.
SVF guidance: DC topo now emits hier_map guidance; FM accepted 2146 guidance commands and rejected 0.
Known open implementation note: pre-backend max transition/cap violations remain and are acceptable to carry into backend closure for this baseline.
Known constraint note: rst_ni is intentionally not clock-relative; recovery/removal checks are currently untested.
Next phase: backend floorplan/powerplan setup from the FM-clean topo handoff.
```
