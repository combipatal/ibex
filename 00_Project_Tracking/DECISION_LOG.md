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
Initial integration preference: instantiate ibex_core directly from project wrapper.
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
