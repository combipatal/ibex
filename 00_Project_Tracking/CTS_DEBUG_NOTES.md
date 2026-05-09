# CTS Debug Notes

## 2026-05-09

```text
Skill workflow: diagnose
Problem: ICC2 CTS did not produce an accepted 05_cts result.
Feedback loop: run 4_Backend_ICC2/0_Script/05_cts/run_cts_initial.sh from the placed design and require:
- no Fatal/Internal system error in 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log
- 4_Backend_ICC2/4_Report/05_cts/check_clock_trees.post.rpt exists
- 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt exists and is clean
- ICC2 design block is saved back into 4_Backend_ICC2/2_Output/01_init_design/ibex_mini_soc_top_icc2_lib
```

## Captured Symptoms

```text
Primary aborted log: 4_Backend_ICC2/3_Log/05_cts_aborted_20260509_2213/run_cts_initial.log
Secondary aborted log: 4_Backend_ICC2/3_Log/05_cts_aborted_20260509_2220/run_cts_initial.log
Status: ABORTED_TO_DEBUG
Reliable fatal evidence: first aborted run reached clock_opt and reported:
- Fatal: Internal system error, cannot recover.
- XFORM[012720] Detected fatal while optimizing near U24139/Y
Process observation: icc2_exec around 100 percent CPU means one logical core is busy, not whole-server 100 percent CPU.
Contamination note: one debug attempt had duplicate CTS processes writing the same log path; those artifacts are quarantined and not used as pass evidence.
```

## Ranked Hypotheses

```text
H1: ICC2 clock_opt route_clock/full CTS optimization is hitting a tool bug on this placed design.
Prediction: a narrower CTS run, for example build_clock-only or less aggressive CTS options, should get past the previous fatal point or move the failure.

H2: The design has incomplete/default physical or electrical setup for CTS, especially no default max transition and no default voltage messages.
Prediction: adding explicit CTS/design setup constraints should remove those warnings and either avoid the fatal or produce a clearer design-rule failure.

H3: The current PG connectivity issue is interacting with CTS/legalization/routing analysis.
Prediction: a CTS diagnostic run that avoids route_clock, or a run after PG connectivity repair, should behave differently.

H4: Concurrent runs/log contamination caused an apparent crash signature.
Prediction: a clean single-process rerun from an empty 05_cts current log/report directory should either complete or reproduce a consistent fatal.

H5: A specific placed instance/net around U24139/Y has an abnormal placement/connectivity/timing condition.
Prediction: inspecting U24139, its driver/load cone, placement status, and clock/data role should reveal an outlier or show it is only a tool-internal locality marker.
```

## Next Debug Sequence

```text
1. Confirm zero active CTS/ICC2 processes before a rerun.
2. Keep current 05_cts log/report directories clean; archive partial attempts under timestamped aborted directories.
3. Add a diagnostic CTS Tcl variant only if needed, without changing the shared production CTS wrapper policy.
4. First diagnostic target: isolate whether fatal is in build_clock or route_clock.
5. Evaluate each run against the feedback loop above and update this file plus RUN_LOG.md.
```

## Clean Retry Evaluation

```text
Run: 4_Backend_ICC2/0_Script/05_cts/run_cts_initial.sh
Log: 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log
Status: PASS_WITH_NOTE
Outcome: clean single-process retry completed; no Fatal/Internal system error occurred.
Key observation: Phase 6 Iter 2 had a long no-output interval while icc2_exec stayed at about one logical CPU core. The run later advanced to Phase 6 Iter 3/4/5, Phase 7, final CTS, clock routing, and report generation.
Corrected diagnosis: the previous failure picture was caused by duplicate/log-contaminated attempts and termination artifacts. Error code=15/Terminated is not treated as a clean ICC2 crash reproduction.
Clock completion: "Compilation of clock trees finished successfully" appears in the log.
Clock route result: 0 open nets and 0 DRCs.
Legality result: check_legality.rpt reports TOTAL 0 violations.
Timing result: timing.max worst reported slack MET 0.63 ns; timing.min worst reported slack MET 0.04 ns.
Residual issue: PG connectivity remains not clean even though PG DRC is clean.
```
