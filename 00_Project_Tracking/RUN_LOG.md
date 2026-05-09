# Run Log

## 2026-05-09

```text
Stage: project setup
Action: created initial project directory skeleton and tracking files
Status: PASS
Next action: clone lowRISC/ibex into rtl/ibex and record source revision
```

```text
Stage: RTL intake
Action: cloned https://github.com/lowRISC/ibex.git into rtl/ibex
Status: PASS
Commit: 9742d89f54fc297bed026841c8e68454ddfd7cc0
License: Apache-2.0
Initial filelist candidate: rtl/ibex/rtl/ibex_core.f
Next action: inspect Ibex parameters/core descriptors and freeze baseline config
```

```text
Stage: git publish setup
Action: added .gitignore to exclude rtl/ibex and EDA generated outputs; added scripts/git_project.sh for .git_local metadata
Status: IN_PROGRESS
Remote target: ssh://git@ssh.github.com:443/combipatal/ibex.git
Scope: scripts, docs, constraints, configs, AGENTS/init, and 00_Project_Tracking records only
Next action: initialize .git_local, commit scoped files, push to GitHub over SSH port 443
```
