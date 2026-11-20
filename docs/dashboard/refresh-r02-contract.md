# R02 — Refresh continuity for Concentration estimate and current-player dot

## Goal

Prevent unnecessary across-frame hide/restore of the cyan Concentration estimate/approximate
label and current-player dot during an ordinary asynchronous refresh. Preserve data/source/
identity/generation/render ownership and fail-closed behavior. This is a bounded display-only
exception to retained=observed-only, not a general removal of retained/build guards.

## Why

[PLAN](../../PLAN.md) records focused P03 native acceptance and explicit user approval for
the combined fix. [Investigation](concentration-refresh-investigation.md) reproduces both
indicators hidden across a pending-build callback, including unchanged and collector-
invalidated contexts. Periodic native trigger/frequency remain unknown; do not invent them.

## Run state

**READY2026-11-19 — user answers “Yes” to the combined fix.** One synchronous implementer,
no children; independent review then primary acceptance. No source edits/new full-suite/
native execution at approval. Task statuses/results maintained in TASKS.

Primary freezes accepted **uncommitted P03** actual tree (NOT initial HEAD5f98f5e) locally:
`artifacts/r02-comparison/before-files.json`, `preimage-paths.json`, `git-before.json`.
Writer/reviewer read-only access; artifacts primary-owned, no external managed-log/path retry.
Existing unrelated planning/archive/source work must remain untouched. Four base SHA256s:

```text
4f6f1a1229ffa07b1bd8f361198e67a3525ed7b6859b8298c24f6fe4b227c99e CraftArmy/Dashboard.lua
d16224d09a75536446f01389d621fe8272e0e98989cf26cfa6e872265752bbcf CraftArmy/SelfTests.lua
318dbd74cc2c0cbe3a955548148019fdd172ab13d1657f726533103b9b9ab9dc README.md
91f11d8bcc0bf78f7ba96202ebe3062cebd4d3a75f2e8e32ba18e58b59f7ecfe docs/dashboard/README.md
```

New `tests/refresh_continuity.lua` absent;10accepted P03 targets unchanged. No Git mutation,
installation, guide work, new profession/enchant capability or native broad sign-off.

## Design — numbered pieces

### 1. Baseline and rejecting regressions

Read instructions/full contract/manifests/test scripts. Verify actual tree/base hashes/
Git state, run full existing serial baseline, then add private standalone runner that
meaningfully rejects unchanged Dashboard for BOTH ordinary refresh indicators. No harness
failure, coverage/limit reduction or fake production bypass. Retain all old suites.

### 2. Private last-successful-paint cache and eligibility — depends on1

Implementation stays entirely in Dashboard.lua, using existing Storage read APIs. Design:

- Maintain private runtime-only last-paint and active-refresh-continuity records, never
  saved fields or mutations of row/view-model/collector/fresh/storage tables. Cache at most
  the12current visible widgets. Install last-paint only after a fully successful completed/
  nonretained Render with matching context (including initial publication); do not cache
  a partial/failed/retained/artificial pending-job paint. Replaced completed view replaces
  its cache; DropCompleted, generic failed/cancelled/hidden retention and failed rendering
  clear it. Do not keep failed-view predictions available for a later retry to revive.
- Cache source handle/completed/rows/widget/row references, exact options/current GUID,
  row GUID/id/generation, and bounded scalar copies of actual rendered estimate provenance/
  value/geometry/label and dot geometry/visibility. No whole-list walk, graph copy, future
  acquisition, native query per row, or extra UnitGUID read. Use the existing guarded
  capturePlayerGUID at refresh boundaries and existing one-clock normal Render.
- Only an **ordinary StartBuild preparation/pending build** may explicitly arm continuity.
  Pin its own build version, completed/rows/cache, validated current source/context and
  options/GUID. General Retain(why), failures/cancellation/hide/source drift never opt in.
  Preserve pending status, historical tooltip gate, disabled lifecycle/Details actions,
  confirmation clearing, fresh-marker demotion and ordinary build coalescing/publication.
- Global eligibility requires the same valid schema2 handle, same completed/rows/cache,
  visible/out-of-combat frame, unchanged requested options INCLUDING valid current GUID
  compared with cached completed paint, and a current, non-superseded preparation/job
  context. Collector serial/revision/fresh may differ from the OLD completed context;
  validate the NEW job context. This is needed for ordinary invalidation-only refreshes.
  Missing/invalid/different GUID, changed filters/View/order/options, hidden/combat/unknown
  safety or detached/invalid source reject the exception. Do not bypass original guards.
- Validate only cached visible rows using protected `S.Active(db,guid,id)` and `S.Token`
  calls (at most12active reads per eligibility preparation). Pin/check ownership/context/
  storage revision and token before/after protected operations; no newer reentrant work
  may be overwritten. Active row must exist, remain nonarchived at the same generation
  and exact supported identity (Data.Capabilities of current identity; row id/family agree).
  Removed/retired/replaced-generation/invalid rows cannot borrow cached indicators.
- Dot continuity is eligible only for a cached actually displayed dot on a row matching
  the unchanged captured current GUID and current active generation. Dot denotes player
  identity, not fresh profession data; unrelated field changes in that generation need
  not remove it. Unseen/newly scrolled rows without eligible cached paint use old fallback.
- Estimate continuity additionally requires the exact SAME successful current last
  Concentration observation as cached row: observed status/generation/time, currency id,
  quantity/cap/recharge duration/amount and attempted status/time/source agree with cached
  row state. Current capability must still have Concentration; cached projection must
  have been valid, nonarchived, applicable and actually visible/increased. Changed/new/
  failed/unknown/invalid observation or amount/rate provenance rejects only the estimate,
  not an otherwise valid identity dot. Genuine new values must not be covered by old
  projections. Preserve all original invalid-rate/clock/archived/N/A/no-estimate fallbacks.

### 3. Continuity lifecycle and painting — depends on2

- Freeze eligible indicators at their last successful displayed values for the brief
  pending build; no retained-view estimate recomputation or extra ticker/clock/collection.
  Active continuity tokens/context must remain valid across every callback/widget/native
  boundary. Storage/context/GUID/options/row/owner drift revokes it; stale callbacks must
  not clear, publish or repaint over a newer build/paint/hover/scroll owner.
- demoteVisible and retained Render must NOT Hide/SetShown(false) eligible estimate/dot or
  reset the eligible approximate label/geometry and then restore it. Preserve only a
  verified cached widget+row match. Other widgets still follow existing safe demotion.
  Reused widgets/different row/scroll destination without cache must clear old decoration.
- Keep current-player dot identity separate from estimate provenance: e.g. a new stored
  Concentration quantity may invalidate old estimate while same active player's dot stays.
  Do not advance observed values or mark data fresh during the retained display.
- Successful publication replaces old rows and indicators through the existing atomic
  completed-view publication; new normal estimates use current shared clock as before.
 30second ready estimate repaint and frame-coalesced scrolling stay intact. No synchronous
  rebuild fallback, new render loop, source event/timer frequency adjustment or scheduler
  budget/limits change. Only12visible-row continuity work, never sort/filter all rows in UI.
- StopBuild clears the previous active exception before cancellation callbacks; ordinary
  replacement may explicitly re-arm from still-valid last completed paint. Fail/setup/
  scheduler/render errors, explicit cancel/hide/DropCompleted and bare Retain revoke both
  preservation and reusable cache as appropriate BEFORE fail-closed cleanup. Validate
  pending continuity in the frame/build/Render paths before allowing it to survive a
  callback; do not leave invalid frozen indicators visible until an unrelated later tick.
  If a protected read/widget operation throws or eligibility becomes uncertain, revert
  through original robust demotion/drop behavior, not optimistic marker retention.
- Archived current-player dot behavior in NORMAL completed views stays unchanged. Archived
  views are simply not eligible for the new RETAINED continuity exception. Keep all normal
  tooltips/selection/Details/scroll/current-first layout/actions and existing safety cues.

### 4. Scoped legacy adaptation and regression coverage — depends on2+3

First old-test change permitted: SelfTests active U13 own-GUID/marker scenario around13793,
the exact line `view:Refresh(); eq(marker:IsShown(),false); redrawPump(view,checkpoint)`
now expects TRUE during unchanged eligible refresh. Bracket exact original bytes with
recoverable R02 ORIGINAL/ADAPT markers, prove whole-file reconstruction. All following
invalid/missing GUID tests, reentry/native boundaries, old generic Retain/archived/clock/
failure expectations unchanged. Preserve512case order/all19workloads/K6K7 and all older
P01/P02/P03/Uxx original-marker payloads. Additional unexpected old failures need primary
review; never broadly rewrite tests to bless the new implementation.

**PRIMARY narrowly scoped engineering amendment2026-11-19 (writer stopped):** initial
legacy rerun511/512 stops at U13 MARKER_NATIVE's failed-marker assertion. Its Hide/IsShown
fault/reentry subcases call ordinary unchanged Refresh, so the new explicit no-Hide path
can intentionally avoid their injected boundary. This is a test-setup conflict, not
authority to weaken fail-closed runtime cleanup. In that SAME block, the exact dispatch
line `if boundary=="Hide" or boundary=="IsShown" then view:Refresh() else view:Render() end`
may be replaced with the same branch that FIRST sets
`view.options.character="R02 force unsafe demotion"` and THEN calls Refresh for Hide/IsShown.
All other boundaries still call Render. Wrap ONLY this line/setup in recoverable
`R02 ADAPT U13_MARKER_NATIVE_DISPATCH` original/active markers. Keep all8boundaries,
both fault/reentry modes, original injection, required fired reentry, failed-marker
hidden assertion, newer rows/job checks and frozen-storage assertions verbatim. Do not
skip/relax assertions, shrink matrix or change any other old test. Whole SelfTests must
reconstruct from these TWO authorized R02blocks to the original P03 preimage.
Add separate new-runner tests asserting eligible pending refresh executes neither marker
Hide nor marker IsShown demotion queries, while ineligible/changed-options refresh still
executes those boundaries and survives their faults/reentry safely. Current blocked partial
green was preliminary and must be rerun on final source; full negative coverage still due.

New standalone tests exercise actual production Dashboard and schema2 driver/widgets:
- Both estimate/label and own dot stay visible at EVERY pending callback for unchanged
  refresh, collector-only serial/revision/fresh invalidation, same in-flight coalescing
  and valid stored updates to unrelated row/field. Before/after successful publication
  correct; no hidden-call/reset between frames for eligible decorations. At least46mixed
  rows,12visible pool, hidden/filtered/new widgets never inherit old marker geometry.
- Current Concentration observation/amount/rate/time/status change clears old estimate
  while unchanged same-generation current dot stays; removed/archived/replaced-generation
  rows clear both. Source detach/replacement/corruption, invalid/different GUID, options/
  filters/View/sort changes, combat/unknown safety, hide/cancel/fail, manual Retain and
  absent cache reject continuity. Unknown/N/A and ordinary observed0/full retain semantics.
- Build setup/Step/batch/publication/render/clock/widget/Storage Active/Token faults and
  reentry at eligibility, Hide/Show/SetShown/SetText/SetPoint/width/visibility/combat/time/
  token boundaries. No previous stack erases newer rows/job/status/cache/hover/scroll.
  Fail-closed cleanup must remain robust even when early widgets throw. Test mutation
  during cached eligibility read and during preserved paint, not just at StartBuild entry.
- Same GUID versus valid other GUID versus nil/invalid GUID, multiple own professions,
  alt records, archived rows, generation/token drift and changed current stored fields.
- Pending actions/confirmation/Details stay disabled and pending hovers historical even
  while marker/approximate text remain. Sort/filter/attention/generation/value/timestamps
  untouched; no runtime acquisition except existing guarded own-GUID refresh lookup,
  shared ready clock and bounded Storage reads. Full saved-root/token identity checks.
- Existing estimate30second ticker, scroll wheel/frame-coalesced drag, range/current-first
  grouping and no character cap retained. Instrument eligibility reads <=12 and reject
  a whole-source walk/collector Scan/Context/Request/API traversal or graph copying.
- New tests label all timings/callbacks synthetic, not native trigger/frequency/latency
  proof or measured offline estimate accuracy. Preserve all P03 accepted features.

### 5. Full serial validation, docs and frozen report — depends on4

Run all final checks to terminal completion, retain red/failure/fix chronology. Update root
README current status/dev and dashboard README introduction BEFORE U15 only. Explain safe
pending continuity (frozen eligible decorations, not live/fresh observations) and all unsafe
fallbacks; current validation links TASKS rather than hardcoded review-pending claims.
Keep old U13/R01 history verbatim, latest policy explicitly supersedes unconditional
retained=observed-only ONLY for this approved safe exception. Native focused flicker check
after local acceptance, no repeat accepted profession checks/dumps/gear changes.

## Files

Writer: CraftArmy/Dashboard.lua (private continuity/cache/eligibility and integration into
existing retain/render/build/ticker cleanup only), CraftArmy/SelfTests.lua (TWO exact
marked blocks: refresh expectation and amended unsafe-demotion dispatch), new tests/refresh_continuity.lua, README current-status/development
lines, docs/dashboard/README.md intro beforeU15; TASKS R02 execution/status/report only.
Primary: PLAN/AGENTS/this contract/evidence/investigation/review docs/comparison artifacts.
Every other path frozen: Core/Storage/Data/Collectors/ViewModel/Knowledge/KnowledgeCheck/
Commands/Details, existing runner scripts/P01–P03fixtures, tools/diagnostics/.toc/assets/
agents/archives. Primary does not edit assigned files/contract while writer works.

## Tests

Installed runtimes only, inspect scripts first. Full baseline of existing commands before
edits; new runner first rejects unchanged production; final commands serially:

```sh
lua5.1 tests/refresh_continuity.lua
lua5.1 tests/profession_completion.lua
lua5.1 tests/gathering_activation.lua
lua5.1 tests/profession_expansion.lua
lua5.1 tests/dashboard.lua
lua5.1 tests/run.lua
python3 tools/check_dashboard.py
python3 tools/check_diagnostics.py
git diff --check
```

No workload/limit reduction, polling/duplicate background jobs, installation or external
service. Exact whole SelfTests marker reversal; nonowned paths/old README suffix/9icon
pairs and HEAD/index unchanged; complete actual diff/new runner and final target hashes.
Independent execution if denied stays NOT RUN, no bypass or primary evidence reattribution.
Platform review N/A (no CI/hosting/IAM/deployment scope). Full native INCOMPLETE87/149,
all-rank UNVERIFIED and offline estimate accuracy unverified remain unchanged.

## Out of scope

No observed/saved concentration, model estimate mathematics, storage policy/schema/token
implementation, sorting/attention/filter changes, cached observations published as fresh,
profession capability/stat/enchant changes, gathering revalidation, new permanent enchants/
gear changes, UI redesign, full-list synchronous acquisition/rendering, reset/eviction/
forced rescans, guide/Details work, install/dependencies, Git mutations/releases/deployment.

## Report back

### Primary correction scope after first independent review

First delivery is implementation COMPLETE but **CHANGES REQUIRED**, not accepted.
[Independent static findings F1/F2](refresh-r02-review.md) are persisted; independent shell
execution was denied/NOT RUN, no retry/bypass. One synchronous writer resumes only these
corrections and dependent validation/report; no further SelfTests adaptations.

- F1: use the existing single shared Render clock to reject frozen estimate preservation
  when `now < cached successful observedAt` (or invalid observation time), retaining normal
  observed-only label/geometry fallback. Do not recompute predictions or read another clock.
  Keep identity-dot eligibility separate; a valid same-generation dot need not disappear
  merely because its estimate clock is unsafe. Do not revive a rejected estimate from an
  invalid paint cache before a successful normal paint. New tests must reject first-delivery
  code for backward valid integer clocks before Refresh and during pending Render.
- F2: keep preparation ownership pins across post-eligibility visibility, Retain/status and
  initial paint/setup callbacks. Track expected render/hover/scroll ownership alongside build
  version through synchronous preparation. Intentional local counter changes may be
  accounted for at their exact owned mutation sites, not by unconditionally rebaselining
  after a callback that might have reentered. Once a newer same-build paint/hover/scroll wins,
  older stacks must stop without clearing it or installing an older job/cache. Preserve
  normal coalescing/publication and async job ownership. New one-shot post-eligibility
  visibility and initial status/paint reentry tests must reject first-delivery code, proving
  newer rows/paint/status/hover/queued scroll survive by callback return and frame update.
- Freeze first-delivery artifacts; primary supplies a separate correction-start manifest.
  Same original P03 preimages, same five writable implementation/doc targets and TASKS
  execution fields; primary owns review/contract/planning/artifacts. All other files frozen.
  Additive regressions, all final serial suites and exact two-block reconstruction/protected/
  Git/icon/history proofs on corrected hashes, then independent reassessment. Preserve every
  failure chronology and source of evidence. No native/install/Git/guide authority.

**Primary runtime-compatibility direction after correction stop:** preserve the frozen
SelfTests; do not adapt its Render wrappers. Existing public methods must remain compatible
with transparent wrappers such as `ui.Render=function(w) ...; return originalRender(w) end`
that forward only the original self argument. Optional private owner arguments must not be
required to complete an ordinary wrapped refresh or timer recovery. Keep F2's ownership
pins, but carry intentional owned-render dispatch through private, scoped one-shot runtime
state rather than requiring third-party/test wrappers to forward a new parameter. Consume
the dispatch at the production method entry and restore/retire it safely around nested
invocations; validate the exact expected owner before adopting any intentional mutation.
A nested/reentrant Render remains a newer owner; never blindly adopt arbitrary final
counters or use ambient owner inheritance for all renders. New standalone regressions
cover self-only Render wrappers during normal refresh, source replacement/Refresh/Hide
reentry and timer recovery; all five F1/F2 rejecting regressions remain mandatory. Public
Retain/StopBuild wrappers, if used for internal owner dispatch, obey the same compatibility
and no-ambient-inheritance rule. This is an in-scope runtime correction, not broader test
or architecture authority. Recheck all original matrices/final suites before review.

**F3 correction after corrected-delivery reassessment:** persisted review confirms F1/F2
statically addressed but pre-entry owned Retain wrapper exceptions escape with continuity/
lastPaint armed. Correct owner-checked exception cleanup for failed preparation dispatch,
not only Render. Revoke continuity/reusable cache immediately while the exact preparation
still owns state; perform robust historical demotion through a private production cleanup
path, never through the same potentially throwing public wrapper. A private forward cleanup
closure/captured production Retain implementation is permitted within Dashboard. Recheck
owner before/after protected cleanup boundaries; older exception stacks must not touch newer
paint/job/status/hover/scroll. Do not merely catch the exception and continue installing work.
Test pre-entry Retain failure meaningfully against current corrected delivery, immediate
observed-only fallback, no old-cache revival on retry, successful normal-paint recovery,
and throwing wrapper with newer reentry. Audit analogous owned StopBuild/Render dispatch
exceptions under the same rule; add coverage rather than leaving method-specific cleanup
holes. Preserve public-signature compatibility, prior43groups and all original safety
matrices. Same files/full serial validation/freeze/reassessment gates, no further SelfTests
adaptation or native/install/Git authority. Primary supplies F3-start manifest; all earlier
delivery artifacts/preimages immutable and primary-owned.

agent-handoff envelope; durable TASKS R02 statuses/run state at every stop: completed work,
exact blockers/remaining/resume point, files/diff/hashes, baseline/red/green/failures and
terminal command evidence, protected/preimage/Git/icon/read-bound proofs. Freeze delivery
for independent review; primary persists findings/acceptance before focused native check.
Implementation COMPLETE never grants review/native/global dashboard/publication acceptance.
