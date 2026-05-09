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
[ ] Identify synthesizable package order
[ ] Identify ibex_core and ibex_top parameter sets
[ ] Identify simulation-only files to exclude
[ ] Decide integration point
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
