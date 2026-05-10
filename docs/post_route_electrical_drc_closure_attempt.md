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
| residual max-cap ECO | max_transition 0, max_capacitance 0, route DRC 0 | ICC2 clean candidate |

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

## Residual Max-Cap ECO

Command:

```text
4_Backend_ICC2/0_Script/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.sh
```

Key output:

```text
ICC2 library: 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/ibex_mini_soc_top_post_route_residual_maxcap_eco_icc2_lib
Report root: 4_Backend_ICC2/4_Report/12_post_route_residual_maxcap_eco
Export root: 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export
Manifest: 4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/post_route_residual_maxcap_eco_manifest.txt
```

PrimeTime ECO result:

```text
2 max-cap violations found before ECO
1 size_cell command
1 insert_buffer command
remaining ECO violations: 0
```

Final ICC2 saved-block reports:

```text
constraints.final.rpt: max_transition 0, max_capacitance 0, min_capacitance 0
qor.final.rpt: Nets with Violations 0, Max Trans Violations 0, Max Cap Violations 0
check_routes.final.rpt: open nets 0, route DRC 0
check_legality.final.rpt: TOTAL 0
pg_connectivity.final.rpt: VDD/VSS floating objects 0
pg_drc.final.rpt: No errors found in command log; report file contains no PG DRC records
timing.max.final.rpt: worst listed slack MET 0.64 ns
timing.min.final.rpt: worst listed slack MET 0.04 ns
```

This run is the first ICC2 saved-block candidate in this sequence with route DRC, max-transition, max-capacitance, legality, PG connectivity, PG DRC, and ICC2 timing sanity all clean or positive in the generated reports.

## Decision

The max-cap ECO plus final route cleanup was not an electrical-DRC-clean result because it still left 2 max-cap violations in the final ICC2 report.

After later project-owner approval for exactly one more attempt, the residual max-cap ECO closed those last 2 violations and recovered route DRC to 0. Treat `12_post_route_residual_maxcap_eco` as the accepted ICC2 internal post-route electrical/route clean candidate for this debug sequence.

## Current Accepted Baseline

Keep the named route-closure baseline as the accepted reproducible backend flow baseline. The earlier `08_gds/route_closure_gds_candidate` remains a historical educational stream-out artifact with its recorded electrical DRC caveat.

The `12_post_route_residual_maxcap_eco` block proved the post-route route/electrical cleanup direction, then a GDS refresh showed that filler insertion needed extra pre-filler margin. The final educational GDS candidate for this phase is generated from `14_post_route_prefiller_maxcap_margin`.

## FM/PT And GDS Refresh

After the residual max-cap ECO, the ECO netlist was checked before any new GDS claim:

```text
Formality command:
env FM_RUN_TAG=post_route_residual_maxcap_eco \
    FM_IMPL_NETLIST=4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/ibex_mini_soc_top.post_route_residual_maxcap_eco.vg \
    FM_LOG=3_Formality/3_Log/fm_post_route_residual_maxcap_eco.log \
    3_Formality/0_Script/run_fm_post_route_residual_maxcap_eco.sh

PrimeTime command:
env PT_RUN_TAG=post_route_residual_maxcap_eco \
    PT_NETLIST=4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/ibex_mini_soc_top.post_route_residual_maxcap_eco.vg \
    PT_SDC_FILE=4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/ibex_mini_soc_top.post_route_residual_maxcap_eco.sdc \
    PT_SDF_FILE=4_Backend_ICC2/2_Output/12_post_route_residual_maxcap_eco/export/ibex_mini_soc_top.post_route_residual_maxcap_eco.sdf \
    5_STA/0_Script/run_pt_post_route_residual_maxcap_eco_sdf.sh
```

Results:

```text
Formality: Verification SUCCEEDED; 34915 passing; 0 failing; 0 unmatched; SVF guidance 2146 accepted / 0 rejected
PrimeTime: no setup/hold violations; read_sdf errors 0; setup slack 0.68 ns; hold slack 0.03 ns
```

The first GDS refresh from `12_post_route_residual_maxcap_eco` completed stream-out but reintroduced four tiny max-cap violations after filler:

```text
GDS report root: 4_Backend_ICC2/4_Report/13_gds/post_route_residual_maxcap_eco_gds_candidate
constraints.after_filler.rpt: max_transition 0, max_capacitance 4, min_capacitance 0
check_routes.after_filler.rpt: open nets 0, route DRC 0
```

Root cause:

```text
The 12 block was clean before filler.
Filler insertion plus PG reconnect/re-extraction slightly increased cap on near-limit nets.
The issue required pre-filler margin, not another broad route cleanup.
```

## Pre-Filler Margin ECO

The accepted margin ECO is:

```text
Command: 4_Backend_ICC2/0_Script/14_post_route_prefiller_maxcap_margin/run_post_route_prefiller_maxcap_margin.sh
Report root: 4_Backend_ICC2/4_Report/14_post_route_prefiller_maxcap_margin
ICC2 library: 4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/ibex_mini_soc_top_post_route_prefiller_maxcap_margin_icc2_lib
```

Failed sub-attempt:

```text
set_max_capacitance on net collections produced SEL-002/SEL-005 messages and no ECO changes.
The fix was to apply max-cap margin on driver pins.
```

Accepted target pins:

```text
U77216/Y 7.50
U13303/Y 15.50
ZBUF_1069_inst_8294/Y 15.50
ZBUF_259_inst_8705/Y 15.50
U7539/Y 7.50
```

Result:

```text
constraints.after_margin_targets.rpt: 5 intentional max-cap violations
ECO log: 5 NBUFFX2_RVT buffers inserted
constraints.final.rpt: max_transition 0, max_capacitance 0, min_capacitance 0
check_routes.final.rpt: open nets 0, route DRC 0
check_legality.final.rpt: TOTAL 0
pg_connectivity.final.rpt: VDD/VSS floating objects 0
qor.final.rpt: setup slack 0.64 ns; no hold violations
```

The margin ECO netlist also passed FM and PT:

```text
FM log: 3_Formality/3_Log/fm_post_route_prefiller_maxcap_margin.log
FM result: Verification SUCCEEDED; 34915 passing; 0 failing; 0 unmatched
PT report root: 5_STA/4_Report/post_route_prefiller_maxcap_margin
PT result: no setup/hold violations; read_sdf errors 0; setup slack 0.67 ns; hold slack 0.03 ns
```

## Final Educational GDS Candidate

Final GDS command:

```text
env SOURCE_CLEAN_ICC2_LIB=4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/ibex_mini_soc_top_post_route_prefiller_maxcap_margin_icc2_lib \
    SRC_BLOCK=ibex_mini_soc_top_post_route_prefiller_maxcap_margin \
    GDS_TAG=post_route_prefiller_maxcap_margin_gds_candidate \
    4_Backend_ICC2/0_Script/13_gds/run_write_gds_residual_maxcap_clean.sh
```

Final outputs:

```text
GDS: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds
DEF: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.def
Verilog: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.vg
SDC: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.sdc
Manifest: 4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/gds_export_manifest.txt
File sizes: GDS 157M, DEF 128M, Verilog 32M, SDC 13M
```

Final after-filler checks:

```text
check_routes.after_filler.rpt: open nets 0, route DRC 0
constraints.after_filler.rpt: max_transition 0, max_capacitance 0, min_capacitance 0
check_legality.after_filler.rpt: legality succeeded
pg_connectivity.after_filler.rpt: VDD/VSS floating objects 0
pg_drc.after_filler.rpt: no reported PG DRC records
qor.after_filler.rpt: setup slack 0.64 ns; no hold violations
```

This supersedes the earlier GDS artifact with max-cap violations. It is still educational, not signoff/tapeout ready.

Do not claim:

```text
signoff clean
tapeout ready
```

because antenna rules, foundry DRC, LVS, IR/EM, metal fill, and signoff STA methodology are still outside this evidence.
