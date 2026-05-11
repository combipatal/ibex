# Ibex HTML 학습 보고서 생성 프롬프트

아래 내용을 그대로 복사해서, Ibex 프로젝트를 같이 진행한 AI에게 전달한다.

---

```text
너는 Ibex Mini SoC 프로젝트를 함께 진행한 기술 보고서 작성 AI다.

목표:
Ibex Mini SoC 프로젝트를 따라가면서 Front-End부터 Back-End, route DRC closure, post-route electrical DRC closure, Formality, PrimeTime SDF STA, educational GDS export까지의 흐름을 학습할 수 있도록 “설명형 프로젝트 보고서”를 작성해줘.

이 문서는 포트폴리오 제출용이 아니라 내부 학습용이다. 결과만 요약하지 말고, 왜 그렇게 했는지, 어떤 문제가 있었는지, 어떤 근거로 판단했는지, 어떤 명령어/report/script로 확인했는지, ECO는 어떤 방식으로 적용했고 왜 그 판단이 맞았는지를 자세히 설명해줘.

출력 형식:
Markdown이나 docx가 아니라 HTML 파일로 작성해줘.
브라우저에서 열고 A4 PDF로 바로 출력할 수 있어야 한다.

권장 산출물:
1. ibex_frontend_flow_report.html
2. ibex_backend_route_gds_report.html

분량이 너무 길면 Front-End와 Back-End/GDS를 위처럼 2개 HTML로 나눠라. 한 파일로 충분하면 ibex_fe_to_gds_learning_report.html 하나로 작성해도 된다.

분량:
A4 최대 30장 정도를 생각한다. 내부 학습용이므로 설명은 충분히 자세히 해도 된다. 단, 무의미한 반복은 줄이고 표/박스/코드블록으로 읽기 좋게 정리해라.

언어:
한글 중심으로 작성해줘. 단, Synopsys tool command, report name, file path, script variable, timing/DRC/Formality/ECO/GDS 용어는 영어 그대로 유지해도 된다.

문체:
질문형이 아니라 알려주는 문서로 작성해줘.
“왜 이런 문제가 생겼고, 그래서 어떤 접근을 했고, 결과가 어떻게 나왔고, 그 결과를 어떻게 해석했는지”를 설명하듯 정리해줘.
과장하지 말고, 실무에서 어떻게 판단하는지까지 같이 설명해줘.

디자인:
화려한 디자인은 필요 없다. 가독성이 중요하다.
- 흰 배경
- 본문 10.5~11pt 수준
- 제목 hierarchy 명확히
- 표는 얇은 회색 border
- 핵심 숫자/결론은 옅은 파란색 또는 회색 박스로 강조
- code block은 연한 회색 배경
- 각 장 시작은 page break 처리
- 첫 페이지에는 “현재 상태 요약 1페이지” 배치

HTML/PDF 필수 조건:
HTML에는 A4 출력용 CSS를 반드시 포함해라.

예시 CSS:

<style>
@page {
  size: A4;
  margin: 16mm 14mm;
}

body {
  font-family: "Noto Sans KR", "Malgun Gothic", Arial, sans-serif;
  color: #111827;
  line-height: 1.55;
  font-size: 10.5pt;
}

.page-break {
  break-before: page;
}

h1, h2, h3 {
  break-after: avoid;
}

table {
  width: 100%;
  border-collapse: collapse;
  break-inside: avoid;
}

th, td {
  border: 1px solid #d1d5db;
  padding: 6px 8px;
  vertical-align: top;
}

pre {
  background: #f3f4f6;
  border: 1px solid #e5e7eb;
  padding: 10px;
  white-space: pre-wrap;
  word-break: break-word;
  font-size: 8.5pt;
}

code {
  font-family: "Consolas", "D2Coding", monospace;
}

.summary-box {
  border-left: 4px solid #2563eb;
  background: #eff6ff;
  padding: 10px 12px;
  margin: 12px 0;
}

.note-box {
  border-left: 4px solid #6b7280;
  background: #f9fafb;
  padding: 10px 12px;
  margin: 12px 0;
}
</style>

반드시 참고할 기록:
- AGENTS.md
- init/context_bootstrap.md
- 2026-05-09_103000-ibex-mini-soc-implementation-flow.md
- 00_Project_Tracking/PROJECT_STATUS.md
- 00_Project_Tracking/RESULT_SUMMARY.md
- 00_Project_Tracking/RUN_LOG.md
- 00_Project_Tracking/RUN_MANIFEST.md
- 00_Project_Tracking/DECISION_LOG.md
- docs/backend_flow.md
- docs/backend_library_policy.md
- docs/ibex_backend_route_closure_case_study.md
- docs/gds_candidate_export.md
- docs/post_route_electrical_drc_closure_attempt.md
- constraints/ibex_mini_soc_10ns.sdc
- filelists/ibex_mini_soc_dc.tcl
- filelists/ibex_mini_soc_dc.f
- filelists/ibex_mini_soc_fm_ref.tcl
- filelists/ibex_mini_soc_fm_ref.f
- rtl/mini_soc/ibex_mini_soc_top.sv
- 2_Synthesis/0_Script/**/*
- 3_Formality/0_Script/**/*
- 4_Backend_ICC2/0_Script/**/*
- 4_Backend_ICC2/4_Report/**/*
- 4_Backend_ICC2/3_Log/**/*
- 5_STA/0_Script/**/*
- 5_STA/4_Report/**/*

현재 프로젝트 최종 상태:
Ibex Mini SoC는 educational FE-to-GDS implementation flow로 종료 가능한 상태다.

최종 상태:
- Final candidate: post_route_prefiller_maxcap_margin_gds_candidate
- Flow scope: Ibex RTL intake → Mini SoC top → DC synthesis → Formality R2N → ICC2 floorplan/place/PG/CTS/route → route DRC closure → post-route electrical ECO → Formality → PrimeTime SDF STA → educational GDS export
- Claim boundary: not tapeout-ready, not full foundry signoff

최종 evidence:
- DC Graphical topographical synthesis 완료
- Formality R2N PASS
- ICC2 route DRC 0
- open nets 0
- max_transition 0
- max_capacitance 0
- min_capacitance 0
- legality clean
- PG connectivity clean
- PG DRC clean
- timing positive
- Formality PASS: 34915 passing compare points, 0 failing, 0 unmatched
- PrimeTime SDF STA PASS: no setup/hold violations, SDF read errors 0
- Final educational GDS candidate generated
- GDS size: 157 MB

최종 GDS 경로:
4_Backend_ICC2/2_Output/13_gds/post_route_prefiller_maxcap_margin_gds_candidate/ibex_mini_soc_top.post_route_prefiller_maxcap_margin_gds_candidate.gds

최종 GDS reports:
4_Backend_ICC2/4_Report/13_gds/post_route_prefiller_maxcap_margin_gds_candidate

중요한 claim boundary:
이 결과는 educational final-candidate GDS다. Tapeout-ready 또는 full signoff라고 쓰면 안 된다.
빠진 항목:
- foundry signoff DRC
- LVS
- antenna signoff
- IR/EM
- metal fill
- signoff STA methodology
- full physical signoff package

보고서 첫 페이지 구성:
1. 제목: Ibex Mini SoC FE-to-GDS Implementation Learning Report
2. 부제: Front-End Flow, Backend Route Closure, Electrical ECO, and Educational GDS Candidate
3. 현재 상태 요약
4. 핵심 숫자 표
5. claim boundary

보고서에서 반드시 설명할 내용:

1. 프로젝트 전체 목표
- 왜 Ibex를 선택했는지
- 단순 RTL 합성이 아니라 Mini SoC 구성부터 FE-to-GDS flow를 따라가기 위한 목적
- 이 프로젝트에서 배우려는 것:
  - 오픈소스 RISC-V core intake
  - Mini SoC wrapper/top construction
  - DC synthesis
  - SDC/timing
  - Formality R2N
  - PrimeTime pre/post-route STA
  - ICC2 floorplan/place/PG/CTS/route
  - route DRC debug
  - library/NDM policy 판단
  - post-route electrical DRC ECO
  - GDS export
  - report/log 기반 판단
  - Tcl/Shell 자동화

2. Front-End flow 설명
각 stage별로 아래 구조로 설명해줘.
- 목적
- 입력 파일
- 핵심 script
- 사용한 주요 command
- 생성 output
- 확인해야 하는 report/log
- pass/fail 기준
- 실제 발생한 warning/note
- 왜 다음 단계로 넘어갈 수 있었는지

포함할 stage:
- Ibex upstream clone / source revision freeze
- Ibex config freeze
- Mini SoC top construction
- RTL/filelist 구성
- SDC 작성
- DC analyze/elaborate/link smoke
- DC Graphical topographical synthesis
- mapped DDC/netlist/SDC/SDF/SVF 생성
- Formality R2N
- PrimeTime pre-backend STA
- backend handoff package

3. Front-End에서 발생한 문제와 판단
아래 항목을 반드시 설명해줘.
- Ibex upstream RTL을 그대로 쓰지 않고 Mini SoC top을 구성한 이유
- frozen upstream commit을 기록한 이유
- synthesis top이 ibex_mini_soc_top인 이유
- ibex_top instance u_ibex_top의 의미
- DC topo에서 hdlin_enable_hier_map과 set_verification_top이 중요한 이유
- Formality SVF guidance가 2146 accepted / 0 rejected였다는 의미
- R2N PASS가 backend handoff 기준에서 왜 중요한지
- pre-backend max_cap/max_transition note를 backend closure로 넘긴 이유
- rst_ni recovery/removal이 현재 async reset policy에서 untested로 남은 이유

4. Back-End flow 설명
각 stage별로 아래 구조로 설명해줘.
- 목적
- 사용 script
- 핵심 app option / variable
- output report
- 확인 방법
- 발생 문제
- 판단 근거

포함할 stage:
- SAED32 NDM/reference library setup
- ICC2 init_design
- floorplan
- powerplan
- placement/legalization
- PG connectivity diagnosis
- PG rail stitch fix
- CTS
- route_auto
- check_routes
- check_legality
- check_pg_connectivity
- check_pg_drc
- post-route report extraction
- route closure baseline promotion
- GDS export

5. Backend route DRC debug chronology
시간순으로 “어떤 시도를 했고, 왜 했고, 결과가 어땠고, 왜 채택/기각했는지” 정리해줘.

반드시 포함할 trial/decision:
- initial route: route DRC 720
- DRC breakdown: Diff net spacing 251, Less than minimum area 24, Needs fat contact 347, Off-grid 92, Short 6
- lower-metal DRC matrix: M1/M2/VIA1 중심 문제
- extra detail routing reject
- M2-only reroute reject
- fat_contact_effort probe: Needs fat contact 감소, Diff net spacing 증가, total DRC around 660~672
- modified-LEF route debug: DRC 720 → 41
- residual DRC: Off-grid 39, Short 1, Diff net spacing 1
- cleanup candidate: 20 DRC = Off-grid 19, Short 1
- VIA12SQ_C row-limit NDM probe reject
- split-via ECO probes reject
- via_array_mode=off / fat-contact option combo reject
- residual Off-grid diagnosis: VIA12SQ_C 2x1 array geometry
- residual Short diagnosis on n48420
- NOR2 A1/VSS pin-access context
- targeted NOR2 resize reject: 43 DRC, 19 open nets
- NOR2 cell-use policy synthesis
- NOR2-policy backend rerun: 36 DRC reject as standalone
- NOR2-policy cleanup: 19 DRC
- PG M2 offset probe reject: signal DRC improves but PG DRC 640
- Diff-net blockage candidate: 18 DRC
- residual ECO probes reject
- off-grid bbox blockage trade-off: Off-grid 0 but Short 18
- alternate techfile NDM probes fail with TECH-006/LIB-007
- lower-utilization rerun reject
- VIA1 pitch NDM probe reject
- VIA1 pitch/no-track NDM build accepted
- VIA1 pitch/no-track NOR2-policy route: 1 Off-grid
- MUX41X2_HVT/S0 residual one-DRC context
- NOR2+MUX41 cell-use synthesis debug
- NOR2+MUX41 Formality R2N PASS
- VIA1 pitch/no-track NOR2+MUX41 route: 0 open nets, 0 signal DRC
- backend library policy accepted
- route closure baseline promotion

각 trial마다 아래를 써라.
- 목적
- 왜 이 trial을 했는지
- 실행 script/command
- 결과 숫자
- 좋아진 점
- 악화된 점
- 채택/기각 판단
- 다음 판단으로 어떻게 이어졌는지

6. 문제 해결 방법론 장
이 프로젝트의 핵심은 단순히 “DRC를 줄였다”가 아니라 “문제를 어떻게 좁히고, 어떤 기준으로 다음 trial을 선택했는가”다.

아래 흐름으로 설명해줘.
- 전체 DRC count만 보지 않는다
- DRC type/class로 분해한다
- layer matrix로 본다
- route option으로 해결 가능한 문제와 아닌 문제를 구분한다
- lower-metal M1/M2/VIA1 문제로 축을 좁힌다
- LEF/NDM/library policy를 실험한다
- PG connectivity와 signal DRC를 동시에 본다
- signal DRC가 줄어도 PG DRC가 깨지면 reject한다
- route DRC class trade-off를 기록한다
- “효과 있음”과 “production baseline으로 채택 가능”을 구분한다
- debug artifact와 promoted baseline을 구분한다
- route DRC clean 이후에도 electrical DRC, Formality, PT, GDS 검증을 이어간다

7. NDM / library policy 설명
Ibex 프로젝트의 중요한 특징은 modified-LEF / VIA1 pitch/no-track NDM policy를 통해 route DRC closure를 달성한 점이다.

반드시 설명할 것:
- 기존 SAED32/LEF-built NDM에서 route DRC가 720 발생한 이유
- modified-LEF route debug가 Needs fat contact를 제거한 의미
- libdir LEF와 original SAED32_EDK LEF 차이를 확인한 이유
- OR2X1/OR2X4 physical abstract 차이가 route에 영향을 준 이유
- VIA1 pitch = 0.36 변경의 의미
- VIA1 onGrid/onWireTrack 제거의 의미
- TECH-025가 왜 문제가 되었는지
- no-track NDM build가 왜 accepted policy가 되었는지
- PDK/ORCA techfile이 drop-in replacement가 아니었던 이유
- library policy를 production baseline으로 promotion하기 전에 어떤 evidence가 필요했는지

8. Tcl / Shell script 설명
Front-End와 Back-End 주요 script를 반드시 설명해줘.

각 script마다:
- 목적
- 주요 variable
- 주요 command
- 왜 이 설정을 썼는지
- 어떤 report를 생성하는지
- 실패/성공 판단 기준
을 설명해줘.

예:
- DC topo synthesis script
- Formality R2N script
- PT pre-backend STA script
- 4_Backend_ICC2/0_Script/07_route_closure/run_route_closure_baseline.sh
- 4_Backend_ICC2/0_Script/08_gds/run_write_gds_route_closure.sh
- 4_Backend_ICC2/0_Script/09_post_route_electrical_closure/run_post_route_electrical_drc.sh
- 4_Backend_ICC2/0_Script/10_post_route_maxcap_eco/run_post_route_maxcap_eco.sh
- 4_Backend_ICC2/0_Script/11_post_route_final_cleanup/run_post_route_final_cleanup.sh
- 4_Backend_ICC2/0_Script/12_post_route_residual_maxcap_eco/run_post_route_residual_maxcap_eco.sh
- 4_Backend_ICC2/0_Script/13_gds/run_write_gds_residual_maxcap_clean.sh
- 4_Backend_ICC2/0_Script/14_post_route_prefiller_maxcap_margin/run_post_route_prefiller_maxcap_margin.sh
- 5_STA/0_Script/run_pt_post_route_residual_maxcap_eco_sdf.tcl
- 5_STA/0_Script/run_pt_post_route_prefiller_maxcap_margin.tcl

9. ECO 수행 방법 상세 설명
Back-End 보고서에는 ECO를 별도 장으로 자세히 설명해줘.

9.1 ECO가 필요한 이유
- route DRC 0만으로 끝이 아닌 이유
- GDS candidate after-filler에서 max_transition/max_capacitance violations가 남은 이유
- post-route electrical DRC closure가 필요한 이유
- route_opt와 ECO의 차이
- max-cap ECO가 route DRC를 깨뜨릴 수 있는 이유

9.2 ECO 대상 선정 방법
- report_constraints 결과 확인
- max_transition/max_capacitance violator 확인
- route_opt iteration 결과 비교
- residual max-cap net 확인
- driver-pin margin target 선정
- buffer insertion / size_cell 적용 판단
- filler 이후 capacitance가 다시 증가할 수 있다는 점을 고려한 margin ECO

9.3 ICC2/PT ECO 흐름
실제 흐름을 설명해줘.

예시 command/action:
- open_lib / open_block
- report_constraints -all_violators
- route_opt 반복
- size_cell
- insert_buffer
- legalize_placement
- route_eco 또는 route cleanup
- check_routes
- check_legality
- check_pg_connectivity
- check_pg_drc
- report_timing
- report_constraints
- write_verilog / write_sdc / write_sdf or export
- Formality verification
- PrimeTime SDF STA

9.4 이번 프로젝트 ECO chronology
아래 결과를 표로 정리하고 해석해줘.

- route closure baseline:
  route DRC 0, but max_transition 8 / max_capacitance 227

- GDS after filler:
  max_transition 8 / max_capacitance 228
  filler가 main cause가 아니라 기존 electrical closure 부족이 주원인

- route_opt iter1:
  max_transition 3 / max_capacitance 174

- route_opt iter2:
  max_transition 0 / max_capacitance 137

- route_opt iter3:
  max_transition 0 / max_capacitance 120

- route_opt iter4:
  max_transition 0 / max_capacitance 120
  stalled

- max-cap ECO:
  max_transition 0 / max_capacitance 2
  but route DRC 31
  reject as final

- final route cleanup:
  route DRC 0 recovered
  max_capacitance 2 remains

- residual max-cap ECO:
  inserted 1 buffer and issued 1 size_cell command
  max_transition 0 / max_capacitance 0 / min_capacitance 0
  route DRC 0
  legality/PG clean
  timing positive

- residual max-cap ECO FM/PT:
  Formality PASS
  PT SDF STA no setup/hold violations

- residual max-cap GDS refresh:
  GDS stream-out completed but after-filler max_capacitance 4 reintroduced
  superseded

- pre-filler max-cap margin ECO:
  5 driver-pin margin targets fixed by 5 NBUFFX2_RVT buffers
  final reports show route DRC 0, electrical DRC 0, legality clean, PG clean, timing positive

- pre-filler margin ECO FM/PT:
  Formality PASS
  PT SDF STA no setup/hold violations

- final electrical-clean GDS candidate:
  after-filler route DRC 0, max_transition 0, max_capacitance 0, min_capacitance 0, legality clean, PG clean, timing positive

9.5 ECO에서 배운 점
- route DRC clean과 electrical DRC clean은 다르다
- filler insertion 후 capacitance가 다시 증가할 수 있다
- max-cap ECO가 route DRC를 깨뜨릴 수 있다
- ECO 후에는 route cleanup이 필요할 수 있다
- near-limit net은 margin을 줘야 한다
- final candidate는 after-filler 기준으로 다시 검증해야 한다
- ECO 후 Formality와 PT SDF STA가 필요하다

10. Formality / PrimeTime 설명
최종 검증 단계는 별도 장으로 자세히 설명해줘.

포함할 것:
- Formality R2N이 왜 필요한지
- post-route/residual ECO 후 Formality가 왜 필요한지
- passing compare points 34915, failing 0, unmatched 0의 의미
- SVF guidance 2146 accepted / 0 rejected의 의미
- PT SDF STA가 왜 필요한지
- SDF read errors 0의 의미
- setup/hold violations 없음의 의미
- ICC2 timing positive와 PT STA clean의 차이

11. GDS export 설명
Final educational GDS candidate export를 별도 장으로 설명해줘.

포함할 것:
- final source block: post_route_prefiller_maxcap_margin
- final GDS output path
- GDS size 157M
- filler insertion
- PG reconnect
- check_routes after filler
- check_legality after filler
- check_pg_connectivity after filler
- check_pg_drc after filler
- report_constraints after filler
- write_verilog
- write_def
- write_sdc
- write_gds
- GDS/DEF/VG/SDC output path
- post-filler checks
- GDS claim boundary

12. 실무 관점 해석
이 프로젝트를 실무적으로 어떻게 봐야 하는지 설명해줘.

포함할 관점:
- route DRC와 electrical DRC를 분리해서 보는 이유
- PD/CAD/library 이슈로 분리하는 기준
- NDM/library policy를 바꿀 때 필요한 evidence
- route option으로 해결 가능한 문제와 아닌 문제 구분
- route DRC clean 이후에도 electrical closure가 필요한 이유
- ECO 후 Formality/PT를 최종 검증에 포함해야 하는 이유
- educational GDS와 tapeout-ready signoff GDS의 차이
- “full signoff clean”이라고 말하면 안 되는 이유

13. 권장 목차

문서 1: ibex_frontend_flow_report.html
1. 현재 상태 요약
2. 프로젝트 개요
3. Ibex source/config freeze
4. Mini SoC top 구성
5. RTL/filelist/constraint 구성
6. DC Graphical Topographical Synthesis
7. Formality R2N
8. PrimeTime pre-backend STA
9. Front-End handoff package
10. Front-End에서 배운 점
11. 주요 Tcl/Shell script appendix

문서 2: ibex_backend_route_gds_report.html
1. 현재 상태 요약
2. Backend 목표와 최종 closure 상태
3. ICC2 init/floorplan/place/PG/CTS/route flow
4. 초기 route DRC 720 분석
5. modified-LEF / VIA1 no-track NDM policy
6. 실패한 trial과 reject 이유
7. 효과 있었던 trial과 채택 이유
8. route DRC 0 baseline promotion
9. post-route electrical DRC closure
10. residual max-cap ECO와 pre-filler margin ECO
11. Formality / PrimeTime SDF STA 검증
12. final educational GDS candidate export
13. 실무식 판단: route DRC / electrical DRC / library policy / signoff boundary
14. 최종 결과와 claim boundary
15. 주요 Tcl/Shell/report appendix

14. 품질 기준
보고서는 단순 요약이 아니라, 내가 읽고 다음을 설명할 수 있어야 한다.

- Ibex source/config/top 구성 이유
- DC, Formality, PT, ICC2가 각각 무슨 역할인지
- 어떤 report를 봐야 PASS/FAIL을 판단하는지
- route DRC가 생겼을 때 어떻게 분해해야 하는지
- modified-LEF / VIA1 no-track NDM policy가 왜 필요했는지
- 왜 어떤 trial은 reject이고 어떤 trial은 accepted candidate인지
- route DRC 0 이후에도 electrical DRC closure가 필요한 이유
- max-cap ECO가 route DRC를 깨뜨릴 수 있는 이유
- pre-filler margin ECO가 왜 final candidate가 되었는지
- GDS export 후 어떤 check를 다시 해야 하는지
- 왜 educational FE-to-GDS closure라고 말할 수 있는지
- 왜 tapeout-ready/full signoff라고 말하면 안 되는지

15. 최종 산출물
아래 중 하나로 만들어줘.

선호:
- HTML 파일 2개
  - ibex_frontend_flow_report.html
  - ibex_backend_route_gds_report.html

또는:
- HTML 파일 1개
  - ibex_fe_to_gds_learning_report.html

추가:
- 브라우저 Print to PDF 기준으로 A4 출력이 자연스럽게 되도록 작성해줘.
- 표와 코드 블록이 깨지지 않게 해줘.
- 긴 script는 appendix로 빼도 됨.
- 문서 맨 앞에 “현재 상태 요약 1페이지”를 넣어줘.
```
