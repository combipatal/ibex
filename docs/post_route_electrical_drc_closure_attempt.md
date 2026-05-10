# Post-Route Electrical DRC Closure Attempt

## Goal

Close the electrical DRC noted after the educational GDS candidate:

```text
constraints.after_filler.rpt: max_transition 8, max_capacitance 228
```

Do not treat GDS export as final clean while these violations remain.

## Baseline

Source route-closure block:

```text
4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib
```

Baseline route and PG checks are clean, but electrical DRC is not clean.

## Diagnosis

The issue was already present before filler insertion.

```text
07_route_closure qor: max_transition 8, max_capacitance 227
08_gds after filler: max_transition 8, max_capacitance 228
```

So filler insertion added at most one max-cap violation; the main problem is missing post-route electrical closure, not the GDS writer.

## Experiments

| Run | Result | Decision |
| --- | --- | --- |
| route closure baseline | max_transition 8, max_capacitance 227 | not electrically clean |
| GDS after filler | max_transition 8, max_capacitance 228 | not electrically clean |
| route_opt iter1 | max_transition 3, max_capacitance 174 | partial |
| route_opt iter2 | max_transition 0, max_capacitance 137 | partial |
| route_opt iter3 | max_transition 0, max_capacitance 120 | partial |
| route_opt iter4 | max_transition 0, max_capacitance 120 | stalled |
| max-cap ECO | max_transition 0, max_capacitance 2, route DRC 31 | not accepted |
| final route cleanup | max_transition 0, max_capacitance 2, route DRC 0 | route recovered, electrical partial |

## Max-Cap ECO

Command:

```text
4_Backend_ICC2/0_Script/10_post_route_maxcap_eco/run_post_route_maxcap_eco.sh
```

Key output:

```text
ICC2 library: 4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/ibex_mini_soc_top_post_route_maxcap_eco_icc2_lib
Report root: 4_Backend_ICC2/4_Report/10_post_route_maxcap_eco
Export root: 4_Backend_ICC2/2_Output/10_post_route_maxcap_eco/export
```

PrimeTime ECO internal result:

```text
120 max-cap violations found
65 size_cell commands
55 insert_buffer commands
remaining ECO violations: 0
```

Final ICC2 saved-block reports:

```text
constraints.after_maxcap_eco.rpt: max_transition 0, max_capacitance 2
check_routes.after_maxcap_eco.rpt: open nets 0, route DRC 31
check_legality.after_maxcap_eco.rpt: TOTAL 0
pg_connectivity.after_maxcap_eco.rpt: VDD/VSS floating objects 0
pg_drc.after_maxcap_eco.rpt: No errors found
timing.max.after_maxcap_eco.rpt: worst listed slack MET 0.64 ns
timing.min.after_maxcap_eco.rpt: worst listed slack MET 0.04 ns
```

The two residual max-cap nets are:

```text
n39125: required 16.00, actual 16.12
n51648: required 64.00, actual 64.04
```

The 31 route DRCs are:

```text
Diff net spacing: 11
Less than minimum enclosed area: 1
Off-grid: 8
Same net spacing: 5
Short: 6
```

## Final Cleanup

Command:

```text
4_Backend_ICC2/0_Script/11_post_route_final_cleanup/run_post_route_final_cleanup.sh
```

Key output:

```text
ICC2 library: 4_Backend_ICC2/2_Output/11_post_route_final_cleanup/ibex_mini_soc_top_post_route_final_cleanup_icc2_lib
Report root: 4_Backend_ICC2/4_Report/11_post_route_final_cleanup
Export root: 4_Backend_ICC2/2_Output/11_post_route_final_cleanup/export
```

Final saved-block reports:

```text
check_routes.after_cleanup.rpt: open nets 0, route DRC 0
constraints.after_cleanup.rpt: max_transition 0, max_capacitance 2, min_capacitance 0
check_legality.after_cleanup.rpt: TOTAL 0
pg_connectivity.after_cleanup.rpt: VDD/VSS floating objects 0
pg_drc.after_cleanup.rpt: No errors found
timing.max.after_cleanup.rpt: worst listed slack MET 0.64 ns
timing.min.after_cleanup.rpt: worst listed slack MET 0.04 ns
```

The final cleanup recovers the route DRC regression caused by max-cap ECO, but the two small max-cap violations remain.

## Decision

The max-cap ECO plus final route cleanup is not an electrical-DRC-clean result. It greatly reduced electrical DRC and recovered signal route DRC, but still leaves 2 max-cap violations in the final ICC2 report.

Per project-owner direction on 2026-05-10, this was the final bounded cleanup attempt. Carry the remaining 2 max-cap violations as a documented residual issue unless a later explicitly approved closure phase is opened.

## Current Accepted Baseline

Keep the route-closure baseline and educational GDS candidate as the accepted artifacts, with the electrical DRC caveat explicitly recorded.

Do not claim:

```text
electrical DRC clean
signoff clean
tapeout ready
```

without a later accepted closure run.
