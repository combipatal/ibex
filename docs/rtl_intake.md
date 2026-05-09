# RTL Intake

Status: Ibex cloned, RTL intake in progress.

## Source

```text
Primary: https://github.com/lowRISC/ibex
Clone path: rtl/ibex
Commit: 9742d89f54fc297bed026841c8e68454ddfd7cc0
License: Apache-2.0, see rtl/ibex/LICENSE
Support reference: https://github.com/lowRISC/ibex-demo-system
```

## Intake Tasks

```text
[x] Clone upstream source
[x] Record commit hash
[x] Read README/license
[x] Identify first RTL filelist/manifest mechanism
[x] Identify synthesizable package order
[x] Identify ibex_core and ibex_top parameter sets
[ ] Identify simulation-only files to exclude
[x] Decide integration point
```

## Initial Findings

```text
Primary core filelist candidate:
rtl/ibex/rtl/ibex_core.f

Top-level FuseSoC/core descriptors seen:
rtl/ibex/ibex_core.core
rtl/ibex/ibex_top.core
rtl/ibex/ibex_pkg.core
rtl/ibex/ibex_multdiv.core
rtl/ibex/ibex_icache.core

Simple system reference inside upstream:
rtl/ibex/examples/simple_system/
```

Integration finding:

```text
ibex_core exposes the register file interface externally.
ibex_top wraps ibex_core with register file selection and top-level support interfaces.
First baseline should instantiate ibex_top inside ibex_mini_soc_top.
```

Current Mini SoC top-level ports:

```text
clk_i
rst_ni
imem_we_i
imem_waddr_i[31:0]
imem_wdata_i[31:0]
gpio_i[31:0]
gpio_o[31:0]
```

IMEM preload decision:

```text
The baseline uses stdcell/flop memory, not SRAM macros.
Instruction memory needs a write/preload path so it does not synthesize as a constant ROM.
The preload interface is a top-level input path for program image loading and implementation realism.
```

`rtl/ibex/rtl/ibex_core.f` currently lists:

```text
ibex_pkg.sv
ibex_alu.sv
ibex_compressed_decoder.sv
ibex_controller.sv
ibex_counter.sv
ibex_cs_registers.sv
ibex_decoder.sv
ibex_ex_block.sv
ibex_id_stage.sv
ibex_if_stage.sv
ibex_load_store_unit.sv
ibex_multdiv_slow.sv
ibex_multdiv_fast.sv
ibex_prefetch_buffer.sv
ibex_fetch_fifo.sv
ibex_register_file_ff.sv
ibex_core.sv
```
