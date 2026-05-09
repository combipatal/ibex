# Constraint Strategy

Initial target:

```text
Clock: clk_i, 10 ns
Reset: rst_ni false path for async reset
IO delays: 1 ns input/output placeholder for GPIO and IMEM preload inputs, all top outputs
Clock uncertainty: 0.1 ns
Clock transition: 0.1 ns
```

Constraint file:

```text
constraints/ibex_mini_soc_10ns.sdc
```
