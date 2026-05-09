# Result Summary

| Stage | Tool | Result | Key Report | Open Item |
|---|---|---:|---|---|
| RTL intake | git/filelist | PASS | docs/rtl_intake.md | Keep upstream commit/config frozen |
| DC analyze/elaborate/link | DC | PASS_WITH_NOTE | 2_Synthesis/4_Report/analyze/check_design.rpt | Classify unused Ibex shadow/debug/feature tie-off warnings before full compile |
| Synthesis | DC Graphical topo | PASS_WITH_NOTE | 2_Synthesis/4_Report/topo/post_compile.qor.rpt | Pre-backend max cap/transition DRC remains for backend closure |
| Pre-backend STA | PrimeTime | PASS_WITH_NOTE | 5_STA/4_Report/pre_backend_topo/global_timing.rpt | Reset recovery/removal untested by current async reset policy |
| Formality R2N | FM | PASS_WITH_NOTE | 3_Formality/3_Log/fm_r2n_topo.log | Auto setup and RTL interpretation warnings recorded |
| Floorplan | ICC2 | PENDING | pending | Needs floorplan script and tech setup from FM-clean handoff |
| Powerplan | ICC2 | PENDING | pending | Needs floorplan |
| Place | ICC2 | PENDING | pending | Needs powerplan |
| CTS | ICC2 | PENDING | pending | Needs placement |
| Route | ICC2 | PENDING | pending | Needs CTS |
| Post-route timing | ICC2/PT | PENDING | pending | Needs routed design |
