# Ibex Config

Status: pending RTL intake.

## Initial Recommendation

```text
actual synthesis top: ibex_mini_soc_top
integration point: instantiate ibex_core directly first
ISA: RV32IMC if feasible after RTL intake
BranchTargetALU: disabled for first baseline
PMP: disabled
Debug: disabled or tied off
RVFI: disabled
ICache: disabled
reset vector / boot address: 0x0000_0000
parameter source: prefer wrapper-level override
avoid tool-script-only parameter override
tie-off location: prefer wrapper RTL
keep DC/FM filelist identical
```

## Frozen Values

Fill this table after inspecting upstream Ibex parameters.

| Item | Value | Source/Location | Rationale |
|---|---|---|---|
| RV32E or RV32I | pending | pending | pending |
| RV32M option | pending | pending | pending |
| BranchTargetALU | pending | pending | pending |
| Multiplier / Divider | pending | pending | pending |
| PMP enable + entry count | pending | pending | pending |
| Debug enable + tie-off | pending | pending | pending |
| RVFI enable | pending | pending | pending |
| performance counter enable + count | pending | pending | pending |
| ICache | pending | pending | pending |
| branch option | pending | pending | pending |
| SecureIbex/hardening | pending | pending | pending |
| reset vector / boot address | pending | pending | pending |
| exception/interrupt tie-off policy | pending | pending | pending |
| selected Ibex integration point | pending | pending | pending |
| actual synthesis top | ibex_mini_soc_top | project plan | baseline |
| Ibex instance path inside SoC top | pending | pending | pending |
| parameter source | pending | pending | pending |
| exact parameter override table | pending | pending | pending |
| DC parameter passing method | pending | pending | pending |
| Formality parameter passing method | pending | pending | pending |
| DC/FM same top/config/filelist evidence | pending | pending | pending |
| tie-off location | pending | pending | pending |

