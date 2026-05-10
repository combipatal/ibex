# PG Diagnosis Notes

## Repro Loop

```text
Symptom: check_pg_connectivity reports floating std cells after ICC2 powerplan/place/CTS while check_pg_drc is clean.
Accepted baseline: 4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt
Debug loop: rebuild PG in a copied debug ICC2 library, do not save, then compare check_pg_connectivity counts.
```

## Baseline Symptom

```text
Baseline CTS PG connectivity:
- VDD floating std cells: 3358
- VSS floating std cells: 415
- VDD floating wires: 7
- VSS floating wires: 1

Connectivity detail pattern:
- VDD has 7 floating sub-networks.
- VSS has 1 floating sub-network.
- Each floating sub-network is one M1 rail wire, zero vias, and hundreds of std cells.
```

## Shape Evidence

```text
Inspector script: 4_Backend_ICC2/0_Script/99_debug/inspect_pg_floating_shapes.sh
Report: 4_Backend_ICC2/4_Report/99_debug/pg_floating_shape_inspect/shape_summary.tsv

Floating shape IDs are M1 lib_cell_pin_connect stdcell rails:
- PATH_11_184 bbox {20.0000 327.6180} {851.2880 327.6780}
- PATH_11_208 bbox {20.0000 367.7460} {851.2880 367.8060}
- PATH_11_232 bbox {20.0000 407.8740} {851.2880 407.9340}
- PATH_11_256 bbox {20.0000 448.0020} {851.2880 448.0620}
- PATH_11_280 bbox {20.0000 488.1300} {851.2880 488.1900}
- PATH_11_304 bbox {20.0000 528.2580} {851.2880 528.3180}
- PATH_11_328 bbox {20.0000 568.3860} {851.2880 568.4460}
- PATH_11_483 bbox {20.0000 827.5460} {851.2880 827.6060}
```

## Hypotheses Tested

```text
H1: Modified LEF abstract fixes rail access.
Prediction: modified-LEF NDM should remove or strongly reduce floating rails.
Result: rejected as full fix. Modified-LEF NDM changed VDD/VSS to 3196/396 only.
```

```text
H2: M7 horizontal offset alone fixes the issue.
Prediction: moving M7 offset should make all rail subnets connect.
Result: rejected as full fix. Integer and decimal M7 offset sweeps only shift the VDD/VSS distribution; no clean case found.
```

```text
H3: M2 strap/via geometry is the main cause.
Prediction: changing M2 width/pitch should change the floating rail count materially.
Result: supported. M2 pitch 20, offset 0, width 0.2 changed VDD from 3358 floating std cells to 0. VSS remained at 415.
```

```text
H4: The remaining VSS issue is an upper-edge/M7/ring-boundary interaction.
Prediction: after M2 width fix, only a top-side VSS rail remains floating and M7 offset changes move or worsen the residual VSS symptom.
Result: supported. Best tested case leaves only PATH_11_483 at y=827.546-827.606. M7 offset 18 and 30 worsened VSS. Changing mesh stop to design_boundary did not fix the residual top VSS rail.
```

## Current Root-Cause Classification

```text
Primary cause: PG strategy geometry, not front-end RTL/DC/FM and not mainly modified LEF.

The initial PG mesh uses M2 vertical straps with width 0.4 and pitch 40. compile_pg creates many rail-to-mesh via candidates, then via DRC/dangling cleanup removes enough M1-to-mesh via connections that entire M1 stdcell rail rows become isolated. This produces one-wire, zero-via floating sub-networks with hundreds of std cells.

Final accepted fix: keep the original DRC-clean PG mesh geometry, remove the conflicting upper stacked vias at the eight isolated rail/M2 stripe intersections, and add explicit M1-M2 stitch vias at those rail locations.

Reason: placing an M1-M2 via directly under the original M2-M7 stacked via fixes connectivity but creates same-net cut spacing DRC. Removing the local upper stack first avoids the cut-spacing conflict while the vertical M2 strap remains connected to the PG network through other intersections.
```

## Accepted Debug Probe

```text
Script: 4_Backend_ICC2/0_Script/99_debug/probe_baseline_pg_local_stitches.sh
Report: 4_Backend_ICC2/4_Report/99_debug/baseline_pg_local_stitches/summary.tsv

Connectivity result:
- VDD floating std cells: 0
- VSS floating std cells: 0
- VDD floating wires: 0
- VSS floating wires: 0
- PG DRC errors: 0

Implementation details:
- removed conflicting upper vias: 48
- added M1-M2 stitch vias: 8
```

## Production Fix

```text
Script changed: 4_Backend_ICC2/0_Script/03_powerplan/run_powerplan_initial.tcl
Production stitch report: 4_Backend_ICC2/4_Report/03_powerplan/pg_rail_stitches.rpt
Production rerun evidence:
- 03_powerplan: VDD/VSS floating objects 0; PG DRC no errors
- 04_place: VDD/VSS floating objects 0; PG DRC no errors; legality TOTAL 0
- 05_cts: VDD/VSS floating objects 0; PG DRC no errors; legality TOTAL 0
- 06_route: VDD/VSS floating objects 0; PG DRC no errors

Policy: no RTL/DC/FM rerun is required for this PG-only backend change.
```
