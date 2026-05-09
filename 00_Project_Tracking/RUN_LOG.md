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

```text
Stage: git publish
Action: committed and pushed scoped project files to GitHub
Status: PASS
Remote: ssh://git@ssh.github.com:443/combipatal/ibex.git
Branch: main
Commit: 041887b Initialize Ibex Mini SoC flow records
Push output: main -> main, branch main set to track origin/main
Uploaded scope: .gitignore, AGENTS/init docs, project plan, docs, configs, constraints, filelists README, rtl/mini_soc README, scripts/git_project.sh, 00_Project_Tracking records
Excluded scope: rtl/ibex upstream clone, EDA outputs/logs/reports/runs
Next action: commit and push this publish log update
```
