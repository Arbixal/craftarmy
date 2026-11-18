# Session 9 — preserved PLAN history

> Archived 2026-11-17 from original PLAN.md lines 1182–1618.
> Historical approval/blocker/next-step statements below are not current instructions.
> Current requirements, acceptance limits and open work remain in PLAN.md/TASKS.md.
> Wording is intact; only relative Markdown link targets were mechanically rebased.

[Current plan](../../PLAN.md) · [Current tasks](../../TASKS.md) · [History index](README.md)

<!-- BEGIN PRESERVED PLAN BLOCK -->
### Session 9 — 2026-11-06 — further table iteration requested

- User explicitly prioritizes more table experimentation before knowledge work;
  theme later. Requested Name/Realm split, separate Tool/Stat/Enchant with full names
  and no stat amounts/prefixes, quality-icons-only gear with rarity background,
  Last Updated column and profession dropdown. Recorded latest D07/Q05 refinement.
- Clarify unknown enchant marker and Last Updated date/time vs relative-age format
  before executable R6 handoff. No implementer launched or source files changed;
  R5's accepted normal-case evidence remains historical, not the new layout's gate.

#### Table iteration display choices settled

- User selects lone? for unknown enchant (blank only confirmed absent) and relative
  age under Last Updated. Theme and knowledge work remain deferred for this visual
  iteration. R6 pieces21–23 READY:14columns, full labels/no stat amounts, rarity cell
  fills/quality icons, relative age and source-verified native profession dropdown.
- Scoped writer owns only ViewModel/Dashboard/SelfTests and dashboard README/evidence
  plus task state. No collection/schema/mapping/API data changes; no source work yet.

#### R6 table revision delivered and reviewed

- Fourteen-column view/rendering, full Stat/Enchant names, glyph-only gear with
  translucent rarity fills, relative Last Updated and native profession dropdown
  delivered. Changed only ViewModel/Dashboard/SelfTests and dashboard README/evidence
  plus task state; no data/schema/collector/mapping changes.
- Independent focused static review PASS; primary Python/hash/baseline checks PASS.
  Reviewer execution denied;50 new-suite definitions/native UI checks NOT RUN.
- Next user reviewed three-file update after backup, reload/selftest and14-column/
  dropdown/hover check. Prior46/46 is not R6 evidence. Theme/knowledge still deferred.

#### R6 user fixture failure: test identity setup

- User supplies49/50, one rarity-fill retention failure. Static trace finds accessory
  seed/retry omit item identity; approved storage correctly clears unidentifiable
  history. Fixture expectation, not demonstrated production rendering, is wrong.
- R6a24–25 READY: verified same-instance setup must retain colour/time as before,
  separate unknown/changed identity cases must clear it. Test/docs only; production
  guard frozen, no data/reset/schema changes. Review/user retest pending, live pause.

#### R6a fixture correction reviewed

- Same-item fixture now supplies verified identity; original retained-colour/time
  assertions stay, separate unidentifiable/changed identity cases require clearing.
  Only SelfTests and update docs changed; all production code frozen.
- Focused static review PASS, primary Python/hash checks PASS. Corrected50cases NOT
  RUN; historical49/50 retained. Next SelfTests-only user update/reload/retest.

#### R6a user fixture gate clears

- User supplies all50 PASS lines and50passed/0failed. Corrected identified-item
  rarity fixture and all regressions pass; original49/50 failure retained as history.
  No production source/policy change or local Lua execution inferred.
- Next native14-column screenshot and Profession All/Inscription/All dropdown check
  using existing snapshots. New layout/hover/opacity still unobserved; other gates
  and theme/knowledge deferrals remain. No source/data/release changes.

#### Revised native table and dropdown observed

- User supplies R6 two-row screenshot, reports no errors/dropdown appears working.
  Requested Name/Realm and Tool/Stat/Enchant split, full names, icon-only quality/
  rarity fill and relative Last Updated visible; PASS for supplied ordinary case.
- Remaining field/native edge gates incomplete. Gather further visual feedback;
  theme/knowledge still deferred. Sanitized evidence only, no source/data changes.

#### Table pass accepted; Inscription knowledge investigation resumed

- User: “Let's call this pass done and move on to the next item.” Accept the current
  table pass for the supplied native cases and50/50 injected fixtures, not all field/
  native edge gates. No further visual iteration requested; theme remains deferred.
- Resume exact Inscription knowledge accounting under D10/Q03. Pinned native UI
  excludes each path's observed unlock-entry maxRanks0/1 and labels the adjusted
  rank/max as points spent/capacity. This is not permission to assume every unlock
  costs one or to mark current node costs as an all-rank cost proof.
- Next targeted read-only node/unlock/spend-entry client evidence; numeric bars
  remain unknown until the scoped rule and reconciliation are justified. No new
  executable queue/source changes, installations or release authorization.

#### Inscription first-root evidence: unlock and spend entries distinguished

- User dumps root106192: purchased/current1, increased0, max31; committed unlock
  entry cap1, next spend entry cap30, both entryCost tables empty. Native-source
  adjustment is0/30 for that node. User's Perfected Products30/30 is not yet a
  same-path comparison; verify first-tab name/main-node display before accepting it.
- One node does not establish full cost/currency coverage; production numbers stay
  gated. Next targeted read-only tab identity check, no source or gameplay changes.

#### Blueprints native0/30 confirmed

- User corrects0/0 as a typo and supplies native Blueprints main-node0/30 screenshot.
  This matches root106192's observed ranks after excluding its1-rank unlock. Accept
  this sample's displayed-rank/cap comparison, not full tree/all-path cost accounting.
- Next read-only node-cost/spend-currency and per-tab committed currency checks;
  production numeric eligibility remains gated. No source or gameplay changes.

#### Inscription cost/currency sample received

- Root106192 costs1 of trait currency3902 and identifies3902 as its spend currency.
  All four tabs repeat3902 available0/spent264: count once, not per tab. Other trait
  currencies remain separate pending role verification; historical260 is not current.
- Current collector keeps only8 currency rows; observed per-tab counts11/6/11/15
  expose incomplete raw capture. Propose a bounded read-only full-tree evidence
  check, awaiting approval; no numeric eligibility/source changes yet.

#### Read-only full-tree knowledgecheck approved

- User approves adding `/ca knowledgecheck` to collect bounded full-tree evidence,
  not enabling numeric bars. Use one copyable local report, complete currency capture
  or explicit omissions, and same-scan staging/coverage checks. No snapshot writes,
  spending/unlocking, automatic profession switching or diagnostic-baseline edits.
- Isolate this under a new KnowledgeCheck module; existing collector/accounting/UI
  semantics remain unchanged. Candidate arithmetic is explicitly provisional even
  when it matches shared spent. Primary prepares serial K1 pieces26–28 and uses one
  implementer, then independent review and user-run tests/capture. Theme deferred.

#### K1 evidence command delivered and static-reviewed

- Isolated `/ca knowledgecheck` and copy window delivered; full bounded currency/path
  capture and provisional reconciliation do not write snapshots/enable numeric bars.
  Independent static review PASS after hash-verified original-source comparison.
- 66 shared fixture definitions (original50 retained +16 new), structural/hash checks
  PASS; Lua/user66/native capture/copy NOT RUN. Next user four-file update after backup
  and `/ca selftest` before native report validation. No diagnostic/production snapshot
  collector changes or release; factual all-rank costs still open.

#### K1 user fixtures pass

- User reports66passed/0failed for the injected suite. Next native read-only report
  capture/manual complete copy; client API/currency/all-rank semantics remain open.
  No source/snapshot/numeric-eligibility change or new diagnostic run inferred.

#### Full Inscription evidence capture received

- User native K1 report captures35 paths/all currency rows without clipping, stable
  unstaged boundaries. Candidate trees0/270,50/70,214/270,0/260 sum264/870 and match
  shared3902 spent264 once. Accept native normal capture/manual full-copy sample.
- Alternate current costs occur on18 locked paths' unlock entries; all17 opened paths
  cost3902×1. Keep unlock costs separate from KP spend currency. All-rank proof is
  not inferred. Next production accounting proposal/approval; no source change yet.

#### K2 guarded Inscription bars authorized

- User approves the scoped native-rank/shared-spent-reconciled dashboard correction.
  This explicitly supersedes the earlier all-rank-cost-proof prerequisite for this
  narrow observed-point policy; it never asserts verified future spend-rank costs.
- K2 pieces29–32: bounded production metadata/currency capture, distinct pure policy,
  typed backward-compatible schema1 evidence and honest hover labels, fixtures/review/
  user scan comparison. No layout/theme/other profession/diagnostic changes. Preserve
  all14 K1 baseline bytes for independent textual review; use one serial implementer.

#### K2 correction delivered and static-reviewed

- Distinct native-rank/shared-reconciled Inscription policy implemented with complete
  bounded metadata, typed schema1 provenance and stale fallbacks. Initial review's
  next-rank bound/stale-index/global-budget findings corrected; alias-safe assembled
  preflight preserves user data. Independent corrected static review PASS.
- 96 fixture definitions, original66 unchanged; standalone/client new suite NOT RUN.
  Next user five-Lua update after backup/reload/selftest before native bars/hover/
  unspent comparison. No future-cost proof, other-profession or release acceptance.

#### K2 assertions pass; client selftest responsiveness correction

- User reports96passed/0failed but extended game lockup and insecure-script execution
  warning naming BugGrabber. Assertion gate PASS, client performance CHANGES REQUIRED;
  warning path alone does not establish cause. No current-suite rerun requested.
- User requests continue after usage reset. K3 runner-only correction: cooperative
  safe units across frames, progress/timing/cancel and slow-unit fail-safe, preserving
  all96 assertions/stress sizes and production accounting unchanged. Independent review
  and actual safe user completion needed before native-bar comparison resumes.

#### K3 responsive test runner delivered/static PASS

- Frame-stepped safe checkpoints, timing/progress/cancel/slow-unit INCOMPLETE stop
  delivered; original96 assertion/stress coverage retained,15 added cases (111total).
  Independent static review PASS. Production accounting unchanged; warning cause and
  actual client performance remain unverified.
- Next controlled two-Lua update/selftest after backup, share explicit completion/
  timing/warning evidence; native-bar testing remains paused pending safe completion.

#### K3 native diagnostic stop isolates case42

- User frame-stepped run:42passed/0failed of111, INCOMPLETE at109.7ms unit/wall5860.4ms.
  Safe-stop works for supplied case; full suite/responsiveness/warning recurrence not
  accepted. Offending R5paging fixture still groups many operations without checkpoints.
- K3a39 splits that fixture/setup and neighboring R5 refresh variants, preserving111
  assertions/stress/100ms limit and production code. No repeat currentversion; review
  then SelfTests-only update. Native bars remain paused.

#### K3a R5 checkpoints static-reviewed

- Case42/setup and neighboring R5 refresh work split into safe units;26 checkpoints
  added, all111 cases/assertions preserved. Independent static PASS; only test fixture/
  update docs changed, production/Commands/100ms limit frozen.
- Next SelfTests-only user update after backup/reload and controlled run. Full safe
  completion/timing/warning evidence pending;42/111 historical stop is not fullPASS.

#### K3a reaches62 cases; maximum-report unit needs deeper slicing

- User run62passed/0failed of111, INCOMPLETE at case63 maximum-report unit140.4ms,
  wall20823.1ms. R5cases41–44 pass; full performance/warning resolution not accepted.
- Maximum fixture builds512paths and calls atomic protected Capture including Format.
  Propose resumable read-only capture/format jobs with synchronous compatibility,
  unchanged stress/assertions/100ms limit and production accounting. Expanded module
  scope awaits user approval; no source changes/currentversion rerun.

#### Resumable read-only report refactor approved

- User approves broader KnowledgeCheck refactor: bounded resumable capture/format
  jobs; existing synchronous Capture/Format remain compatibility drains with the same
  report semantics. Maximum512-path/byte/line stress remains, now cooperatively driven
  by fixtures. No production accounting, Commands scheduler,100ms/10000step limits,
  schema/mapping/diagnostic changes.
- K3b40–42 prepares separate bounded jobs, read-only error/cancel/stability semantics,
  compatibility and job regressions, then independent review/native validation.
  Preserve exact K3a source baseline for textual review; no current-version rerun.

#### K3b resumable report jobs delivered/static-reviewed

- Capture/format Step/Cancel jobs and synchronous compatibility delivered; maximum
  fixture fully sliced without reducing512path/600record stress. Original111 cases
  retained plus12 job regressions (123definitions). Production/Commands/limits frozen.
- Independent static PASS, no blocking finding; structural checks PASS, Lua/client
  execution NOT RUN. Next controlled KnowledgeCheck+SelfTests two-file update and
  explicit completion/timing/warning/interactivity evidence. Native bars stay paused.

#### K3b client progresses66/123; grouped command fixture refinement

- User summary INCOMPLETE66passed/0failed of123, case66 unit102.8ms/wall65297.9ms.
  Maximum report case63 passed, not full suite or new-job-regression acceptance.
  Warning recurrence and game interactivity still not explicitly reported.
- K3c43 adds checkpoints between case66's two real synchronous commands and complete
  combat/UI assertion groups; all123 coverage/production/100ms limit preserved.
  Individual command timings unknown; review before SelfTests-only update/retest.

#### K3c command fixture checkpoint refinement static-reviewed

- Four outer case66 checkpoints separate complete command/combat assertion groups;
  both synchronous35path commands/all123cases retained. Independent static PASS.
- Next SelfTests-only update/reload/controlled123case run; individual command latency,
  full completion, warning recurrence/interactivity remain unverified. Limits and
  production unchanged; native bar comparisons still paused.

#### K3c client reaches79/123; case80 setup checkpoint correction

- Latest user summary INCOMPLETE79passed/0failed of123, case80 firstunit123.1ms,
  wall70914.9ms. Case66 passes;44cases uncompleted (80started), fullperformance and
  warning/interactivity evidence still pending.
- K3d44 separates completed fixture/raw/apply/reload/archive setup operations before
  case80's existing first checkpoint; full123coverage/production/100ms limit frozen.
  Individual operation timings unknown. Review before SelfTests-only update/retest.

#### K3d case80 setup correction static-reviewed

- Seven outer checkpoints split completed setup/reload/archive operations; all123
  cases/assertions/workloads and production/limits retained. Independent static PASS.
- Next SelfTests-only controlled update/run; Lua/client K3d not executed, individual
  operation latency and full completion/warning/interactivity still unverified.
  Native bars remain paused. No planning-history relocations performed.

#### Latest client stop64/123; protected command fixture refinement

- Latest user INCOMPLETE64passed/0failed of123, case64 groupedunit100.5ms,
  wall102289.1ms. Case80 not reached this run; prior79/123 remains separate evidence.
- K3e45 separates case64's two real synchronous commands into independently trapped
  scopes with safe outer checkpoints, restores shared overrides beforeyield. All123
  coverage/production/limits preserved; individual command timing still unknown.

#### K3e protected command scopes static-reviewed

- Four safe outer checkpoints/two independently guarded synchronous commands retain
  all123cases/workloads/read-only traps. Independent static PASS; production frozen.
- Next SelfTests-only controlled123case run; fullcompletion/warnings/interactivity and
  individual-command latency unverified. Nativebars paused; no limit/coverage changes.

#### Client reaches81/123; scan/reload fixture grouping correction

- Latest INCOMPLETE81passed/0failed of123, case81 combined385.3ms/wall73206.2ms;
  case80passes thisrun,42cases uncompleted/new12jobregressions unexecuted.
- K3f46 splits complete real scan/copy/reload/archive/viewmodel groups in81 and its
  immediate stale-snapshot neighbor82. Full123coverage/production/limits retained;
  individualatomiclatency/warnings/interactivity still unknown. Review beforeupdate.

#### K3f scan/reload fixtures static-reviewed

- Case81ten/case82seven outercheckpoints retain all123cases/operations/assertions.
  Independent static PASS; production/100ms cutoff/10000step cap unchanged.
- Next SelfTests-only123case controlledrun. Lua/client K3f/fullcompletion/warnings/
  interactivity and atomicoperationlatency unverified; nativebarspaused.

#### K3f isolates final synchronous scan; broader scope decision pending

- Latest INCOMPLETE81PASS0FAILof123, case81finalscan/assert group122.4ms/
  wall67041.5ms.42cases uncompleted. Caller-only checkpoints cannot divide Scan.
- Production collector/Core stage timings and dominantcost unknown. Propose scoped
  measurement then safe performance fix preserving atomiccommit/allguards/123coverage/
  100ms limit. Existing productionfreeze remains; await userapproval and settleddesign
  before new executabletask. No currentrerun/nativebars/fullperformanceacceptance.

#### Broader scan-performance investigation/fix approved; measure first

- User Yes to broader performancework. K4 starts fixture-only staged timing of actual
  case81secondScan with full123coverage/validation/atomiccommit/100ms limit retained.
  Bounded non-yielding terminal annotation preserves report through existing slowstop.
- No approved localLua runtime; actualstageevidence requires revieweduser-run. No
  productionoptimization/resumablearchitecture settled untiltimings; Core/Collectors
  remain unchanged for measurement. Investigationapproval != successfulfix evidence.

#### K4 stage measurement delivered/static-reviewed

- Fixture-only Scan timing plus bounded terminalannotation independentlystaticPASS;
  original123cases/workloads retained+11instrumentationregressions=134definitions.
  Productionfiles/100ms/10000stepcap unchanged. No performanceoptimization delivered.
- Next reviewedSelfTests-only measurementrun; userstageevidence then settledfixdesign.
  ActualLua/native timings NOTRUN, optimization48blocked; nativebars remainpaused.

#### Local Lua5.1 now available; complete fixture execution PASS

- User installed Lua5.1.5; approved localdashboard134/134 anddiagnostics23/23 fixtures
  executedPASS onunchanged reviewedsource. No agentinstall/shim or scopeexpansion.
- Nativeclock unavailable in standaloneLua as expected; localcorrectness PASS doesn't
  resolve WoW Scan latency/warnings. Next reviewedmeasurementbuild's native scan2stage
  line; optimization48stillblocked timings/design, nativebars paused.

#### Native measurement run stopsbeforeScan atcase51

- Latest INCOMPLETE50PASS0FAILof134, case51combinedcapture/formatunit102.7ms/
  wall8668.2ms.84cases uncompleted/51started;81Scan timings NOT MEASURED.
- K4a49 separates case51's actualcapture/firstformat/deterministicformat assertions
  into protectedgroups, restoresoverrides beforeouterpauses. Full134coverage/native
  measurement/production/limits unchanged; localLua5.1fullsuites required beforereview.
  Optimization48stillblocked realstageevidence/design; no currentrerun/nativebars.

#### K4a guarded report groups reviewed and locally executed

- Case51capture/firstformat/determinism groups split safely; all134cases/workloads
  unchanged. IndependentstaticPASS/localLua134/134+diagnostics23/23PASS.
- Next reviewedSelfTests-onlynative run forscan2 if81reached; no nativeperformance
  fix/acceptance.48stillblocked actualstageevidence/design, nativebars paused.

#### Native stages measured; Core allocation/owned-merge correction settled

- Latest81PASS0FAILof134 INCOMPLETE/unit147.2ms, innerT147.1; exclusiveCopy70.8,
  Open28.4,Apply37.3 (~92.8% combined), knowledgecollection4.1/evaluation6.1ms.
  Timingsincludeprobes/injectedfixtures;53uncompleted, warnings/interactivityunknown.
- Underapprovedbroaderfix K5retainsfullboundedvalidation butavoidsdiscardedclone
  allocations andrecopyingprivatealreadyvalidatedApplyinputs/candidatefields. Public
  Merge/observationguards/nativefinite/typedvalidators/aliaspreflight/singlecommit
  unchanged. No trustedpublicbypass/cache/async/relaxedbounds.48→50READY.
- Localfullregressions+independentreview thenCore/SelfTests-onlynativeupdate/totalT
  comparison; categoryshiftingaloneisn'timprovement. Nativebars/fullperformancepending.

#### K5 Core correction delivered/reviewed, native performance pending

- Validation-onlyallocation andprivateownedApplymerge delivered; allguards/commit
  retained, original134casesbytefrozen+15regressions=149. Independentstatic/designPASS;
  localLua149/149+diagnostics23/23PASS. No nativeK5latencymeasurement yet.
- Next Core+SelfTests-only controlled149run; compareTOTALT147.1/unit147.2 baseline,
  collectfullsummary/warnings/interactivity. Bucketshiftsaren'tspeedup; bars paused.

#### K5 native improves30%, residualprotected-call optimization settled

- Latest81PASS0FAILof149 INCOMPLETE,T102.8/unit103.0ms/wall73689.9ms; O36.5 A37.1
  C18.2 K4.2 E6.3 G0.2 B0.1 R0.2. Tdown44.3ms(~30.1%) vs147.1, still>100ms.
  68casesuncompleted/warnings/interactivityunknown; no acceptanceorunchangedrerun.
- K6usesexistingwhole-walkpcall ratherthannestedpcall PERnumericguard, preservingEVERY
  nativefinite/integer/type/order/zero-boundcheck/failclosed semantics andpublicguards.
  Privateper-walkexceptions sanitize; no realmathpatch/cache/typed-passremoval.
- IsolatedLua5.1nativepredicateparity/pcallcounts tests, all149casesbytefrozen, fulllocal
  checks/independentreview beforeCore-onlyupdate/nativeTOTALT comparison. Bars paused.

#### K6 protected numeric walks delivered/reviewed

- Everyguard/nativecall/order retained underexistingwalkerpcalls; publicguards and
  all149addonfixturesbytefrozen. Independentstatic/designPASS; local149/149,744isolated
  standalonepredicatechecks and23/23diagnosticsPASS. NativeK6performance NOTRUN.
- Next Core-onlynative149run; TOTALTvs102.8/unit103.0/latest147.1initial baseline and
  fullsummary/warnings/interactivity. Same100ms/10000cap, nativebars paused.

#### K6 native advances86/149; conservative overbudget rejection next

- Latest86PASS0FAILof149 INCOMPLETE/case87oversizedApply123.4ms/wall86561.3ms.
  Case81passesunderlimit, no newTprovided;63uncompleted/warningsunknown.
- K7countsownentries ONLYwhenplainarraylengthhintshuge, rejectswhenone50000-entry
  tablealoneprovesexistingglobal50000budgetexceeded. Sparsehintisn'tproof; bounded
  probemissalwaysfulloldvalidator. All149casebytes/50001fixture/nativeguards frozen.
- ThischangesONLYearlyfailureprecedenceformultiplyinvalidoverbudgetgraphs, notwhat
  canbesaved. Localsoundness/149+744+supplement checks+review beforeCore-onlyupdate.
  No currentrerun/raisedlimit/nativebaracceptance.

#### K7 conservative rejection delivered/reviewed

- Soundoverbudgetproof andfullfallback independentlystatic/designPASS; original149
  casebytes/full50001stress/nativeguards frozen. Local149/149+K6744/K7565+diag23/23PASS.
- Next Core-onlynative149run; nativeK7latency/fullcompletion/warnings/interactivity
  stillunknown. Same100ms/10000cap/no unchangedreruns; nativebars paused.

#### Approved validation policy: local stress suites + focused WoW checks — 2026-11-07

- User explicitly agrees to stop chasing full in-client stress-suite timing completion.
  Keep every correctness/stress assertion and workload in the full installed-Lua5.1
  suites. Local PASS is correctness evidence, not proof of WoW APIs or responsiveness.
- Full `/ca selftest` stays **INCOMPLETE** on its existing safety stop; do not raise
  100ms/10000-step limits, filter/reorder/skip work, or manufacture a client PASS.
  Completing that entire synthetic suite within the cutoff is no longer a prerequisite
  for all other native validation. No further patch solely to clear case88 is requested.
- Latest native result:87passed/0failedof149, case88unit2 `K2 next rank boundary`
  134.4ms/wall77323.9ms;62cases uncompleted(88started). No actual assertion failure,
  full-suite PASS, new Scan-stage timing, warning resolution or interactivity inferred.
- Resume focused **user-run** checks on the current reviewed build: normal own ready
  Midnight Inscription scan/dashboard, native data/hover/unspent comparison, closed-
  context known-snapshot preservation and reload persistence. Stop/report on a real
  mismatch, freeze, execution warning, load error or disabled DB; never reset data.
- Native APIs, target-client numeric behavior and normal-use responsiveness remain
  separate gates. Historical incomplete results remain intact, not retroactively
  passed or deleted. Other seven identity mappings/required-field semantics/guides/
  release remain unaccepted. Current checklist: TASKS V01 and dashboard README.

#### V01 first focused observation — 2026-11-07

- User reports tree bars **0/270, 50/70, 214/270, 0/260** in supplied order,
  all matching native UI, with responsive gameplay. Their sum is264/870; this is
  current observed agreement, not a fixed expected balance or all-rank cost proof.
- All tooltips work, but user finds them very verbose and debug-heavy. Record this
  as an unresolved usability issue, not approval for a tooltip rewrite or a fix.
- Follow-up: Unspent KP is **0**, matching native UI; user reports no errors during
  normal use in response to the errors/execution-warning question. This supports
  proceeding to Round2, not a claim that historical warnings can never recur.
- Round2: user reports four bars and Unspent KP remain intact and Last Updated did
  not change after the closed-window check. This supports known-snapshot preservation
  without a falsely advanced update time; explicit stale wording/scan message wasn't
  reported.
- Round3: user confirms all data, including Last Updated, remained as expected after
  the requested closed-profession reload check. V01's three-round focused sequence
  is complete for reported native values, normal-use responsiveness, closed-context
  preservation and reload persistence on this character. No broader API/mapping or
  full-dashboard acceptance inferred; explicit stale wording remains unconfirmed.
- Full native selftest remains INCOMPLETE87/149; no rerun.

<!-- END PRESERVED PLAN BLOCK -->
