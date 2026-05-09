# Ibex Mini SoC Implementation Flow

This project builds one reproducible FE-to-BE implementation baseline for an Ibex-based Mini SoC.

Primary flow:

```text
Ibex RTL intake
-> source revision freeze
-> Ibex config freeze
-> Mini SoC RTL
-> DC synthesis
-> Formality R2N
-> ICC2 floorplan/powerplan/place/CTS/route
-> post-route report summary
```

Current phase:

```text
B0 Repository Intake
```

Read first:

```text
AGENTS.md
init/context_bootstrap.md
00_Project_Tracking/PROJECT_STATUS.md
```

Primary upstream source:

```text
rtl/ibex
```

