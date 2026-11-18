# R01 — redraw-only implementation contract

Settled by primary under user “Yes fix redraw first”, 2026-11-17.
[Current task](../../TASKS.md), [PLAN](../../PLAN.md),
[reproduction and historical proposal](redraw-investigation.md).
No new product choice or follow-up dashboard feature delegated to the implementer.

## 1. Scope and display state

Implement inside Dashboard.lua; leave collectors, Commands, ViewModel and storage
unchanged. The display has a **last completed row list/context** separate from a
replacement job. Track whether a completed result exists even when its row list is
empty. Track its source handle and captured options/context, plus a pending/retained
presentation flag; these are ephemeral UI state, not persisted fields.

On schema2 Refresh, preserve a completed view **only if its original ready handle is
still the collector's handle and S.Check accepts it**. Storage revision changes from
normal scans can retain prior values with the explicit historical presentation below;
they must still invalidate the replacement build. Different/unavailable/invalid storage
must drop the old completed view, cancel work and clear stale scope. Never display a
prior account/handle as the new source. The legacy schema1 path keeps existing behavior;
switching source/path retires schema2 work/state so callbacks cannot overwrite it.

Initial load without a completed view may show loading/empty. During ordinary refresh
do **not** set rows={} or hide populated row widgets/shrink the table to one row. Retain
the existing list by reference; do not copy/rebuild/demote every row or any saved graph.
Only the fixed 12-row render surface may perform synchronous presentation adjustments.

## 2. Honest retained presentation and interactions

From refresh start until current replacement publication, including failure/supersession,
mark the retained view **previous saved view / last observed; updating or refresh failed**.
Use the existing status/selection areas, no overlay animation/new layout. State clearly
that requested filters/View/order may not yet match the retained rows. Keep values,
gear/quality and numeric bars, but render existing fresh amber `!` prefixes muted gray
while retained (presentation substitution only; don't mutate row/state graphs). A retained
row must never appear as a current observation merely because its old model said fresh.

Hide an already-open GameTooltip when entering retained mode. While retained, intercept
**all row-cell and tree-bar hovers, including Shift**, with a short generic explanation
that these are previous saved values pending replacement and detailed freshness/gear
tooltips are temporarily unavailable. Do not expose old current/fresh claims via normal,
Shift or native item-link content. Header/control tooltips remain usable; status tooltip
must include the retained/pending/failure state, not just collector's old status.

Block row selection, Profession-to-Details opening and lifecycle actions while retained.
Enforce at callback AND method entry (`Confirm`, `Lifecycle`, `FinishConfirmation`),
including a confirmation created before refresh. Clear/hide obsolete confirmation.
Disable lifecycle buttons where APIs permit, but guards are authoritative even in mocks
or programmatic calls. Recheck display/source coherence before row actions; source
serial/revision/freshness/storage/options drift cannot leave actions enabled simply
because the next scheduled build callback has not run yet. No stale selected scope.
Existing independently open Details behavior is not redesigned or re-collected.

Preserve previous selected key ephemerally, not an active actionable row during refresh.
On successful publication, restore only if that exact key/generation appears among the
new visible page's <=12 rows; otherwise clear. Keep current offset/clamp to completed
row count; existing explicit filter/sort/page offset changes remain intentional.

## 3. Rebuild/coalescence

For an already running build, coalesce Refresh only when its exact handle, storage
revision, collector serial/revision/freshness table and option key/values still match.
Do not reset its progress or create a duplicate job/driver for an identical request.
Update status honestly without restoring old interactive/fresh mode. Completed-context
refreshes may rebuild to update relative age; no new persistent cache/clock policy needed.

Real input changes cancel/supersede and start a replacement with the existing incremental
V.NewBuildJob/S.NewFrameBatch. Keep native guards, max16 Steps/<2ms between-unit budget,
clockless fallback, combat/unknown pauses and no synchronous fallback. Do not change
collector invalidation or suppress real profession events to hide the symptom.

Hidden Refresh must not clear a completed table or build offscreen; cancel obsolete
in-flight work, mark retained mode and await OnShow. Preserve Toggle/OnShow compatibility
with both native Show scripts and existing mocks; avoid starting two actual visible jobs.

## 4. Publication and reentrant ownership

Only a completed current job may replace rows/options/display context, after existing
collector/storage/options/visibility/combat guards **and** post-StopBuild cleanup guards
pass. Never publish partial rows, resurrect cancelled output, or let an old callback
clear/label/overwrite replacement state. Guard setup, rendering/status callbacks and
cleanup reentry consistently; view retirement/version checks must remain in force after
any overridable job/widget/driver call that can trigger Refresh/Hide/source replacement.

After successful atomic state publication, render the complete list, restore coherent
interaction/tooltips/freshness and existing status. A successful zero-row result becomes
the new authoritative empty view; never fall back to an older nonempty list after that.
Preserve sorting/filter comparison semantics and diagnostic values, not just row count.

## 5. Failure and source transitions

Setup/Step/selected-clock/scheduler failure, supersession or cancellation cannot erase a
safe same-handle completed view. Retain it as historical/noninteractive with an explicit
reason and retry instruction; initial loads without completed data keep a proper failure
message. Hide cancels without losing completed view; reopen rebuilds safely. No unbounded
automatic retry loop. A genuinely invalid/replaced/unavailable handle discards its view
as in section 1, even during fail/cleanup/reentry paths; don't retain detached-source rows.

Do not make every status update a full synchronous snapshot rebuild. Don't expose stale
rows as live because job cleanup ran, or clear retained mode prematurely on job=nil.
No formatting/render exception may enable actions against an incompletely published view.

## 6. Explicit lifecycle changes

After successful dashboard retire/delete, explicitly retire the completed display cache
and selected/confirmation scope before scheduling the new view. Deliberate removal may
show loading rather than keep the removed data; don't resurrect the deleted/archived row
as active during refresh/failure/reopen. Only invalidate display on successful mutation;
failed or cancelled confirmation preserves valid data. Keep existing storage validation,
confirmation, generation checks and atomicity. No collection/write by sort/filter/render.

## 7. Tests and evidence

Add isolated regressions to SelfTests, reusing fixture helpers. Retain all 463 original
case bodies/workloads verbatim and unchanged K6/K7 supplements. No original assertion
changes authorized; escalate a genuine conflict. Record one test failing against frozen
pre-R01 Dashboard before fix; run the new regression block against baseline again by
isolated load/overlay if needed, never overwriting current files to demonstrate failure.

Cover all of these, grouping matrices only with proper checkpoint/yield restoration:

- Completed eight-row real Commands profession-close → immediately still eight visible
  rows/same heights, retained status; eventual current eight-row publication. Initial
  loading/empty still valid. Same retained behavior on normal post-scan replacement.
- Repeated same-input Refresh preserves running job identity/progress; changed collector
  serial/revision/freshness identity, actual saved revision, filters/sorts/View supersede
  without blanking valid prior rows or changing saved data. Confirm real empty commits.
- Retained fresh amber markers become muted; normal/Shift cells, item links, trees,
  preexisting/open tooltips/status do not report obsolete current/fresh. Underlying row/
  saved graphs are unmodified. Once complete, ordinary tooltip behavior returns.
- Block every row selection/Details/lifecycle/old confirmation route while pending,
  failed or context-drifted; restore only valid visible-page selection after commit.
- Same-source factory/Step/frame/clock/driver failures retain prior rows; no-prior cases
  preserve errors. Retry works. Old callbacks cannot overwrite a newer pending/complete
  view; inject Refresh/Hide/source replacement during setup, cancellation/cleanup,
  status/Render and publication guards to check no stale row/status/action publication.
- Combat/unknown safety pause without clearing retained data; hidden/reopened behavior
  cancels old work and preserves values without duplicate actual jobs. Different/nil/
  invalid handles discard detached rows. Schema1 fallback remains correct.
- Explicit successful retire/delete never resurrects removed rows; failed/cancelled
  lifecycle does not lose valid view. Offset clamp, changed filter/sort/View and 12-widget
  reuse remain correct. Renders/retention/coalescence do not write storage or collect.

Run installed `lua5.1 tests/dashboard.lua`, `lua5.1 tests/run.lua`,
`python3 tools/check_dashboard.py`, `python3 tools/check_diagnostics.py` after inspection.
Report baseline/new exact counts and failures honestly. Compare frozen source/full-file
scope and old-case preservation. Focused native open/close/refresh acceptance is later,
not implied by synthetic frames or tests. Fullnative INCOMPLETE87/149/allrank UNVERIFIED
remain unchanged; don't regenerate denied/missing old external artifacts.

## 8. Ownership and boundaries

Only Dashboard.lua/SelfTests.lua and TASKS execution fields assigned to implementer.
Primary owns this contract and later review/evidence/navigation docs. All other source,
runners/tools/fixtures, schema/budgets, agents and archives frozen. No child agents,
Git/release/install/private data actions. Platform review N/A for this local UI-only fix.
Skill/Concentration bars and old-expansion gear red remain queued, unimplemented here.

## 9. Round1 review correction — settled primary amendment

Both independent findings were reproduced by primary; see redraw-review.md. Implement
as task piece5 with the same source ownership; preserve the original 463 and first 17
R01 cases verbatim. Add rejecting cases before changing the reviewed source this round.

1. **Hover provenance begins before any overridable operation.** Capture invocation/
   completed-display identity, build version and exact row/tree pointer at the start of
   each row-cell/tree OnEnter, before retainedTooltip/ActionsReady/Shift lookup or native
   tooltip calls. Propagate that original ownership through focusedTooltip and tooltip;
   do not recapture a newer completed display as ownership of old content. Check before
   and after diagnostic lookup, row/tree dereference and every tooltip-widget call.
   A changed version/completed view/row/tree aborts the obsolete invocation. Do not hide
   or append over a tooltip owned by a newer hover invocation during cleanup. Pending
   historical generic tooltip behavior remains, with no old diagnostic/native-link leak.
   Test both cell and tree with synchronous **completed** replacement from Shift lookup,
   same-handle and new-handle contexts, normal and Shift, and old item hyperlink sentinel.
   Preserve pending-replacement tests and existing safe native item tooltip behavior.
2. **Historical safety cannot depend on successful ordinary Render traversal.** Entering
   retained mode (including a rendering-failure transition) must first independently
   demote known fresh amber markers on the bounded visible surface. No whole-list scan,
   model/saved-graph mutation, or full row rebuild. Use a bounded per-visible-cell safety
   sweep with protected individual calls and version/source checks; one early Name/
   layout/widget failure cannot prevent remaining visible Skill/Moxie/Concentration
   markers from becoming muted. If a marker label cannot accept safe text, hide that
   individual faulty label, falling back to hiding its affected row if necessary; never
   leave a visible fresh claim on failed historical presentation. Keep retained data;
   rare fault isolation is not permission to blank every row during ordinary refresh.
   Explicit failure status/actions stay historical. Restore fault-hidden labels/rows on
   successful retry, with ownership checks; cleanup cannot change a newer invocation.
   Test persistent early Name/layout failure before initial Refresh, marker-label SetText
   failure, multiple later visible rows/currencies, rendering failure at publication,
   retry restoration, no graph mutation, and safety-sweep reentry to completed/pending
   replacement. Normal retained refresh must still preserve all visible values.

After correction rerun all four approved checks. Record initial reviewed-source failures,
new tests/counts and exact updated hashes, then stop for renewed independent static
review. No original tests weakened, budget changes, game/user data access or extra features.
