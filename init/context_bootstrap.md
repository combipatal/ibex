# Ibex Mini SoC Context Bootstrap

Created: 2026-05-09

Project root:

```text
/DATA/home/edu135/ibex
```

Primary goal:

```text
Build one reproducible FE-to-BE baseline for an Ibex-based Mini SoC:
RTL intake -> config freeze -> DC synthesis -> Formality R2N -> ICC2 route -> report summary.
```

Key rules:

```text
- Read AGENTS.md before changing scripts, constraints, wrappers, filelists, or tool setup.
- Run licensed EDA tools outside the sandbox: dc_shell, fm_shell, pt_shell, icc2_shell, tmax, lmutil.
- Record decisions and run results in 00_Project_Tracking/.
- Do not start clock/memory/utilization sweeps before one baseline flow exists.
```

Initial SAED32 timing libraries:

```text
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db
```

Ibex source policy:

```text
Clone upstream Ibex into rtl/ibex.
Do not edit upstream RTL directly unless explicitly required.
Place project-specific SoC RTL under rtl/mini_soc/.
```

Config freeze policy:

```text
Document exact Ibex config in docs/ibex_config.md before synthesis.
Keep DC and Formality top/config/filelist aligned.
Prefer wrapper-level parameter overrides and wrapper RTL tie-offs.
```

