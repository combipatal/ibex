# Decision Log

## 2026-05-09

```text
Project target: Ibex-based Mini SoC FE-to-BE implementation baseline.
Primary source: https://github.com/lowRISC/ibex
Support source: https://github.com/lowRISC/ibex-demo-system
First milestone: one end-to-end baseline, not sweeps.
Initial clock target: 10 ns.
Initial libraries: SAED32 TT 1.05V 25C mixed-VT RVT/LVT/HVT.
Initial memory plan: 2KB IMEM + 2KB DMEM stdcell regfile memories.
Fallback memory plan: 1KB IMEM + 1KB DMEM if runtime/congestion is too high.
Initial synthesis top: ibex_mini_soc_top.
Initial integration preference superseded: use ibex_top from project wrapper.
Initial parameter policy: prefer wrapper-level overrides, avoid tool-script-only overrides.
Initial tie-off policy: prefer wrapper RTL tie-offs.
```

```text
Decision: upload only project scripts, constraints, docs, and tracking records to GitHub.
Reason: rtl/ibex is an upstream clone and should be represented by source revision, not vendored into this project repo.
Remote: ssh://git@ssh.github.com:443/combipatal/ibex.git
SSH port policy: use GitHub SSH over port 443, not port 22.
Local git note: /DATA/home/edu135/ibex/.git is a read-only placeholder directory, so project git metadata uses .git_local via scripts/git_project.sh.
```

```text
Decision: first baseline integrates ibex_top, not ibex_core.
Reason: ibex_core exposes register-file ports. ibex_top contains the register file and reduces first-pass SoC integration risk.
Actual synthesis top remains ibex_mini_soc_top.
Expected Ibex instance path: ibex_mini_soc_top/u_ibex_top.
```

```text
Decision: run project execution with practical ASIC implementation discipline.
Reason: baseline must be reproducible and auditable after context reset, not just a chat-driven demo.
Policy: prefer scripted runs, frozen config, aligned DC/FM/PT/backend inputs, report-based pass/fail checks, and tracking records for every major stage.
Context file updated: AGENTS.md
```

```text
Decision: generate Formality hier-map guidance in the official DC topo SVF.
Reason: initial FM R2N run stayed in verify for too long; log showed no guide_hier_map commands, 1044 rejected SVF commands, and unmatched reference compare points.
Implementation: set hdlin_enable_hier_map true before RTL analyze and call set_verification_top after elaboration in 2_Synthesis/0_Script/run_dc_compile_topo.tcl.
Result: regenerated SVF produced 2146 accepted guidance commands, 0 rejected, including 33 accepted hier_map commands; FM R2N passed.
```

```text
Decision: do not add script-level lock files to shared EDA wrappers.
Reason: this project area may be used for separate experiments by different users/projects; locking inside the checked-in wrapper would impose a local execution policy globally.
Operational policy: before rerunning a shared backend step, manually check active icc2_shell/icc2_exec processes and archive partial logs if a run was interrupted.
```

```text
Decision: treat the clean single-process CTS retry as the accepted CTS baseline.
Reason: the earlier CTS aborted logs were contaminated by duplicate runs and termination artifacts; a clean retry completed without Fatal/Internal system error.
Evidence: 4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log, 4_Backend_ICC2/4_Report/05_cts/check_legality.rpt, 4_Backend_ICC2/4_Report/05_cts/timing.max.rpt, 4_Backend_ICC2/4_Report/05_cts/timing.min.rpt, 4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt.
Result: CTS is PASS_WITH_NOTE; PG connectivity remains an open backend issue.
```
