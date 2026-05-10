# Ibex GDS Candidate Export

## Purpose

This flow exports an educational GDS candidate from the route-clean Ibex backend block.

It is intended to teach the final backend handoff mechanics:

```text
route-clean ICC2 block -> filler insertion -> PG reconnect -> report checks -> GDS/DEF/netlist/SDC export
```

This is not a tapeout-ready signoff GDS. Missing signoff items include foundry signoff DRC, LVS, antenna signoff, IR/EM, noise, metal fill, and final signoff STA methodology.

## Baseline Route Closure Wrapper

Script:

```text
4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh
```

The wrapper reruns the approved route-closure configuration using:

```text
Synthesis handoff: pre_backend_topo_nor2_mux41_no_x0x2_hvt
Backend NDM: modified-LEF VIA1 pitch/no-track NDMs
Techfile policy: VIA1 pitch = 0.36, VIA1 onGrid/onWireTrack removed
Output ICC2 lib: 4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib
Report root: 4_Backend_ICC2/4_Report/07_route_closure
Log root: 4_Backend_ICC2/3_Log/07_route_closure
```

## GDS Export Wrapper

Script:

```text
4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh
```

Default command:

```text
4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh
```

Default input:

```text
SRC_ICC2_LIB=4_Backend_ICC2/2_Output/07_route_closure/ibex_mini_soc_top_route_closure_icc2_lib
GDS_TAG=route_closure_gds_candidate
```

The script copies the source block to:

```text
ibex_mini_soc_top_route_closure_gds_candidate
```

Then it performs:

```text
1. check_routes / check_legality / check_pg_connectivity before filler
2. create_stdcell_fillers using available RVT/HVT/LVT SHFILL cells
3. connect_pg_net -automatic
4. check_routes / check_legality / check_pg_connectivity / check_pg_drc after filler
5. report_qor / report_timing max/min / report_reference / report_constraints
6. write_verilog
7. write_def
8. write_sdc
9. write_gds with RVT/LVT/HVT stdcell GDS merge files
```

Expected outputs:

```text
4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.gds
4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.vg
4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.def
4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.sdc
4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/gds_export_manifest.txt
```

Expected report root:

```text
4_Backend_ICC2/4_Report/08_gds/route_closure_gds_candidate
```

## Completed Candidate

Run:

```text
4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh
4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh
```

Route-closure input result:

```text
Report root: 4_Backend_ICC2/4_Report/07_route_closure/06_route
check_routes.rpt: 0 open nets, 0 signal DRC
check_legality.rpt: TOTAL 0
pg_connectivity.rpt: VDD/VSS floating objects 0
pg_drc.rpt: No errors found
timing.max.rpt: slack MET 0.78 ns
timing.min.rpt: slack MET 0.04 ns
```

GDS export result:

```text
Manifest: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/gds_export_manifest.txt
GDS: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.gds
DEF: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.def
Verilog: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.vg
SDC: 4_Backend_ICC2/2_Output/08_gds/route_closure_gds_candidate/ibex_mini_soc_top.route_closure_gds_candidate.sdc
File sizes: GDS 157M, DEF 127M, Verilog 32M, SDC 13M
```

Post-filler checks:

```text
check_routes.after_filler.rpt: 0 open nets, 0 signal DRC
check_legality.after_filler.rpt: TOTAL 0
pg_connectivity.after_filler.rpt: VDD/VSS floating objects 0
pg_drc.after_filler.rpt: No errors found
qor.after_filler.rpt: clk critical path slack 0.78 ns; no setup/hold violating paths
constraints.after_filler.rpt: max_transition 8 violations, max_capacitance 228 violations
```

Notes:

```text
The GDS export script was updated after this first candidate to also emit timing.max.after_filler.rpt and timing.min.after_filler.rpt on future reruns.
Antenna checking is not active because no antenna rules are defined.
```

## Electrical-Clean GDS Refresh

After post-route electrical DRC closure, a newer GDS candidate was generated through the 13/14 scripts:

```text
Pre-filler margin ECO:
4_Backend_ICC2/0_Script/14_post_route_prefiller_maxcap_margin/run_post_route_prefiller_maxcap_margin.sh

Final GDS command:
env SOURCE_CLEAN_ICC2_LIB=4_Backend_ICC2/2_Output/14_post_route_prefiller_maxcap_margin/ibex_mini_soc_top_post_route_prefiller_maxcap_margin_icc2_lib \
    SRC_BLOCK=ibex_mini_soc_top_post_route_prefiller_maxcap_margin \
    GDS_TAG=post_route_prefiller_maxcap_margin_gds_candidate \
    4_Backend_ICC2/0_Script/13_gds/run_write_gds_residual_maxcap_clean.sh
```

Why this extra step exists:

```text
12_post_route_residual_maxcap_eco was clean before filler and passed FM/PT.
The first GDS refresh from that block reintroduced 4 tiny max-cap violations after filler.
14_post_route_prefiller_maxcap_margin adds driver-pin max-cap margin before filler to absorb the post-filler extraction shift.
```

Final output:

```text
4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds
4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.def
4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.vg
4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.sdc
4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/gds_export_manifest.txt
File sizes: GDS 157M, DEF 128M, Verilog 32M, SDC 13M
```

Final after-filler checks:

```text
Report root: 4_Backend_ICC2/4_Report/13_gds/post_route_prefiller_maxcap_margin_gds_candidate
check_routes.after_filler.rpt: 0 open nets, 0 signal DRC
constraints.after_filler.rpt: max_transition 0, max_capacitance 0, min_capacitance 0
check_legality.after_filler.rpt: legality succeeded
pg_connectivity.after_filler.rpt: VDD/VSS floating objects 0
pg_drc.after_filler.rpt: no reported PG DRC records
qor.after_filler.rpt: setup slack 0.64 ns; no hold violations
```

FM/PT evidence for the source netlist:

```text
Formality log: 3_Formality/3_Log/fm_post_route_prefiller_maxcap_margin.log
FM result: Verification SUCCEEDED; 34915 passing; 0 failing; 0 unmatched
PT report root: 5_STA/4_Report/post_route_prefiller_maxcap_margin
PT result: no setup/hold violations; read_sdf errors 0
```

This `post_route_prefiller_maxcap_margin_gds_candidate` supersedes the earlier `route_closure_gds_candidate` for electrical-clean educational GDS handoff. It still does not prove signoff readiness.

## Claim Boundary

Allowed after reports prove it:

```text
ICC2 educational GDS candidate written
post-filler ICC2 route check collected
post-filler legality collected
post-filler PG connectivity/PG DRC collected
handoff GDS/DEF/netlist/SDC generated
```

Not allowed without separate evidence:

```text
tapeout ready
signoff clean
LVS clean
antenna clean
IR/EM clean
metal-fill complete
foundry DRC clean
```
