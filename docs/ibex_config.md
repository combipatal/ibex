# Ibex Config

Status: baseline config selected and DC elaborate/link smoke passed.

## Initial Recommendation

```text
actual synthesis top: ibex_mini_soc_top
integration point: instantiate ibex_top from project wrapper
ISA: RV32IMC-class baseline
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

## Integration Point Decision

```text
Selected integration point: ibex_top
Reason: ibex_core exposes the register file interface externally. ibex_top wraps ibex_core
with the register file and top-level tie-off/control interfaces, reducing first-baseline
integration risk.
Actual synthesis top: ibex_mini_soc_top
Expected Ibex instance path: ibex_mini_soc_top/u_ibex_top
ibex_top usage: yes
ibex_core direct instantiation: deferred
```

## Frozen Values

Fill this table after inspecting upstream Ibex parameters.

| Item | Value | Source/Location | Rationale |
|---|---|---|---|
| RV32E or RV32I | RV32I (`RV32E=0`) | `ibex_top` parameter | RV32IMC-class baseline |
| RV32M option | `ibex_pkg::RV32MFast` | upstream default / wrapper override | Keep M extension with known default implementation |
| RV32B option | `ibex_pkg::RV32BNone` | upstream default / wrapper override | Exclude bitmanip from first baseline |
| RV32ZC option | `ibex_pkg::RV32ZcaZcbZcmp` | upstream default / wrapper override | Keep compressed extension per upstream default |
| BranchTargetALU | `0` | wrapper override | Reduce timing/area/debug risk |
| WritebackStage | `0` | wrapper override | Keep two-stage baseline |
| BranchPredictor | `0` | wrapper override | Avoid experimental branch prediction in baseline |
| Multiplier / Divider | enabled through `RV32MFast` | `ibex_pkg::rv32m_e` | RV32IMC-class target |
| PMP enable + entry count | `PMPEnable=0`, `PMPNumRegions=4` | wrapper override / upstream default regions | Disable PMP logic first |
| Debug enable + tie-off | `DbgTriggerEn=0`, `debug_req_i=1'b0` | wrapper RTL | No external debug path in baseline |
| RVFI enable | disabled; do not define `RVFI` or `RISCV_FORMAL` | filelist/tool defines | Avoid RVFI ports in synthesis/FM |
| performance counter enable + count | `MHPMCounterNum=0`, `MHPMCounterWidth=40` | wrapper override | Minimal counter logic |
| ICache | `ICache=0`, `ICacheECC=0`, `ICacheScramble=0` | wrapper override | Avoid internal cache RAMs first |
| branch option | `BranchTargetALU=0`, `BranchPredictor=0` | wrapper override | Simple branch baseline |
| SecureIbex/hardening | `SecureIbex=0`, `MemECC=0` | wrapper override | Avoid lockstep/ECC/hardening first |
| reset vector / boot address | `32'h0000_0000` | wrapper RTL input to `boot_addr_i` | Matches IMEM base |
| exception/interrupt tie-off policy | timer optional later; all non-used IRQs tied low initially | wrapper RTL | Deterministic baseline |
| selected Ibex integration point | `ibex_top` | RTL intake decision | Includes register file |
| actual synthesis top | ibex_mini_soc_top | project plan | baseline |
| Ibex instance path inside SoC top | `ibex_mini_soc_top/u_ibex_top` | planned RTL | Stable reporting path |
| parameter source | wrapper-level override | planned RTL | Keep DC/FM identical |
| exact parameter override table | this document + wrapper RTL | docs/ibex_config.md | Reproducible config |
| DC parameter passing method | none for Ibex config; parameters set in RTL wrapper | DC script/filelist | Avoid tool-only config |
| Formality parameter passing method | none for Ibex config; same RTL wrapper/filelist | FM script/filelist | Match DC elaboration |
| DC/FM same top/config/filelist evidence | DC analyze passed with `filelists/ibex_mini_soc_dc.tcl`; FM reference filelist mirrors the same top/config RTL list | `2_Synthesis/3_Log/dc_analyze.log`, `filelists/ibex_mini_soc_fm_ref.tcl` | FM script must keep this aligned |
| tie-off location | wrapper RTL | planned RTL | Avoid hidden synthesis-only constants |

## Exact Parameter Override Table

```systemverilog
.PMPEnable       (1'b0),
.PMPGranularity  (0),
.PMPNumRegions   (4),
.MHPMCounterNum  (0),
.MHPMCounterWidth(40),
.RV32E           (1'b0),
.RV32M           (ibex_pkg::RV32MFast),
.RV32B           (ibex_pkg::RV32BNone),
.RV32ZC          (ibex_pkg::RV32ZcaZcbZcmp),
.RegFile         (ibex_pkg::RegFileFF),
.BranchTargetALU (1'b0),
.WritebackStage  (1'b0),
.ICache          (1'b0),
.ICacheECC       (1'b0),
.BranchPredictor (1'b0),
.DbgTriggerEn    (1'b0),
.DbgHwBreakNum   (1),
.SecureIbex      (1'b0),
.MemECC          (1'b0),
.ICacheScramble  (1'b0)
```

## DC Elaborate Evidence

```text
Run date: 2026-05-09
Command: dc_shell -f 2_Synthesis/0_Script/run_dc_analyze.tcl -output_log_file 2_Synthesis/3_Log/dc_analyze.log
Result: PASS_WITH_NOTE
Evidence:
- Presto compilation completed successfully.
- ibex_mini_soc_top elaborated and linked.
- 2_Synthesis/2_Output/analyze/ibex_mini_soc_top.elab.ddc written.
- check_design and hierarchy reports written under 2_Synthesis/4_Report/analyze/.
Note:
- check_design warnings remain from unused disabled-feature outputs and should be reviewed during full synthesis.
```
