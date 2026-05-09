# Filelists

Policy:

```text
Do not edit upstream Ibex manifests directly.
Keep project-specific implementation filelists here.
```

Initial upstream filelist candidate:

```text
rtl/ibex/rtl/ibex_core.f
```

Planned filelists:

```text
ibex_upstream_top.f    # upstream ibex_top source set candidate
ibex_mini_soc_dc.f     # DC source set for ibex_mini_soc_top
ibex_mini_soc_fm_ref.f # FM reference source set; must match DC source set
ibex_mini_soc_dc.tcl   # Tcl list used by DC scripts
ibex_mini_soc_fm_ref.tcl # Tcl list used by FM scripts
```

Current integration decision:

```text
Use ibex_top, not ibex_core directly, because ibex_core exposes register-file ports.
```
