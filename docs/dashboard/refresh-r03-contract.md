# R03 — Verified collection handoffs without unnecessary indicator blanking

## Goal

Preserve a verified current-player dot across ordinary collector handoffs, and replace a
renewed Concentration display directly from its new verified observation instead of first
clearing it while the full asynchronous view builds. Preserve fail-closed safety and R02 fixes.

## Why

User confirms `0.2.0-mvp+r02.1` and continued flicker, then explicitly approves this focused
correction. [Investigation](concentration-refresh-investigation.md) reproduces actual
Commands/Collectors/Dashboard sequences with synthetic scheduling. Native triggering event,
order/cadence/latency unknown. Prior local suites remain valid, not native success evidence.

## Run state

**READY2026-11-20 — user says “Yes.”** One synchronous implementer, no children; independent
review then primary acceptance. Primary freezes accepted **uncommitted V01/R02** actual
tree, not HEAD, in ignored `artifacts/r03-comparison/`. Five immutable preimages: Dashboard,
Collectors, refresh runner, root README, dashboard README. New collection runner absent.
Artifacts primary-owned/read-only to writer/reviewer; no external denied-path retry.

## Design — serial pieces

### 1. Baseline and meaningful rejecting production-sequence regressions

Verify comparison packet/preimages/HEAD/index and accepted V01 hashes. Inspect existing
runners; run existing serial baseline before edits. Add new `tests/collection_continuity.lua`
using actual production Commands.Event → Collectors.Request/Scan/ItemResult/Expire where
applicable, real schema2 Storage and Dashboard frame/build callbacks with private synthetic
API/widgets. No fake collector-only stand-in for the reported path. Meaningful red tests:
event during unfinished build with dashboard frame before queued Scan; reverse ordering;
verified renewed observation with an increased valid projection during pending replacement.
Do not require cyan when the correct new estimate adds no gain. Preserve prior61groups.

### 2. Explicit collector handoff signal — depends on1

Keep broad context/token drift fail-closed. Add a small **private runtime-only** handoff
record in Collectors.New and a read-only `self:DashboardHandoff()` accessor. It signals an
ordinary requested transition or successful observed publication, not permission to ignore
source/generation/provenance safety. No SavedVariables/schema/native acquisition added.

- Private record contains kind (`requested`/`observed`), exact db/fresh references, serial,
  collector revision and current Storage.Revision; successful record additionally scope
  guid/id/generation of the committed observation. New record identity on each publication.
  Consumers never mutate it. No graph copy, source walk or extra own-GUID/clock query.
- Bare Invalidate clears it. Request calls Invalidate as before, then may arm requested
  record for its scheduled/coalesced ordinary work. Combat/unknown, storage-pending or
  unavailable scheduler paths must not grant unsafe continuity. Do not change request
  scheduling, changed-callback frequency, scan timing, event list or native query counts.
- Scan clears previous record on entry, including all failure returns. Arm observed only
  after successful S.Apply and fresh state established, **before StartLoads**, because
  StartLoads/Expire can synchronously notify changed. Scope/generation from actual commit.
- Successful item retry/timeout commits may publish an updated observed handoff scoped to
  that committed row; no changed Concentration is inferred from unrelated item updates.
  Failure paths never manufacture a successful record. Stale record/context/revision/token
  mismatch does not grant permission. Existing collector freshness/scan guards unchanged.

### 3. Bounded Dashboard handoff and verified replacement paint — depends on2

- Continue private last-successful-completed paint ownership. Ordinary new context can
  rearm from it only through complete existing eligibility and a protected, current
  DashboardHandoff record matching the new collector/source/store context. Missing accessor,
  throw, malformed/stale signal or bare generic drift retain old fail-closed behavior.
- When a **pending** continuity validation sees signalled ordinary context drift, request
  the existing guarded StartBuild replacement **before** generic Retain discards cache.
  It retires previous job through existing ownership machinery, captures current GUID at
  this actual refresh boundary, and revalidates at most12cached visible active rows/tokens.
  No recursive rebuild loop or repeated rearm in a single callback: one bounded attempt;
  uncertain/change-again/fault/reentry falls back or yields to newer owner. No new timer,
  collection request, synchronous full-list build, scheduler limits or frequency changes.
- Dot: only cached actually painted dot, unchanged options/GUID/source/widget/row and same
  supported active generation; independently revalidated through S.Active and tokens. No
  reuse across detached/corrupt source, removed/archived/replaced generation or owner drift.
- Unchanged successful Concentration provenance keeps R02's frozen geometry/label without
  Hide/reset. Changed provenance is NOT eligible for the old projection. Only a current
  `observed` handoff whose committed scope/generation matches that visible active row may
  prepare a replacement scalar Concentration display from its current successful last/
  attempt record. Exact statuses/generation/time/source/build/currency/quantity/cap/rate
  provenance pinned alongside tokens; row/model tables never mutated. No capability guess.
- At that pending Render's **existing shared clock**, compute a changed-observation
  projection once with unchanged V.ConcentrationEstimate. Update the complete Concentration
  cell (observed bar, cyan gain geometry, label/colours) from this new scalar display in
  one guarded synchronous paint, without preliminary Hide/reset of valid old decorations.
  Once painted, freeze this new pending display until a verified successor/publication.
  Do not recompute it on every callback/retained repaint or promote it into reusable
  completed cache. No old cyan over a new observed bar/amount. Normal full publication
  still replaces rows atomically and uses its existing shared clock.
- A renewed observation at now with zero additional gain correctly becomes observed-only;
  it is not a failure to keep cyan permanently visible. Invalid/missing/future/backward clock,
  failed/unknown observation, invalid rates/cap, N/A/archive retain truthful observed/unknown
  fallbacks and no obsolete estimate. Dot remains independent if otherwise verified.
- Preserve pending/historical status and hover gates, disabled selection/actions/Details,
  fresh-warning demotion, scroll/uncached widget safety, same-build newer render/hover/scroll
  ownership, public self-only wrapper compatibility, private one-shot dispatch and F1/F2/F3
  cleanup. Any failure/explicit cancel/hide/drop clears appropriate reusable paint before
  callbacks; older stacks cannot clear newer work. Mid-paint un-signalled mutation still
  fails closed; do not turn arbitrary mutation into a valid handoff.
- Bounded scalar work only: <=12Active reads per genuine preparation/replacement, no
  additional Active reads or estimate recalculation on unchanged retained renders, no
  whole-root/list/row graph copying, no acquisition beyond existing refresh GUID/shared
  clocks and collector's unchanged native reads. Saved observations/sort/attention untouched.

### 4. Regression coverage and exact version update — depends on3

New production-sequence runner covers both timer/frame orderings, repeated/coalesced
events, multiple scans and item-update callbacks,46mixed visible/hidden rows/two own
professions, verified unchanged/changed observation (time/build/source/currency/amount/
cap/rate) and zero-gain/full/zero/future/unknown/error/N/A. Assert no intermediate marker
Hide/reset for safe dot/unchanged projection; changed cell is coherent by callback return.
Check current source/generation/options/GUID removal/replacement, stale/malformed/throwing
handoff, generic Invalidate/drift without signal, read-bound/token/source checks, failures
and reentry at signal/Active/Token/clock/native painting/setup/cancel/publication boundaries.
Test mutation during preparation and painting, newer same-build/new-build hover/scroll/
job/status preservation and wrapper failures. Saved root and tokens unchanged by UI work;
intentional collector writes separately accounted. Synthetic callbacks are not native proof.

Advance loaded Dashboard literal to **`0.2.0-mvp+r03.1`**, README expected marker likewise.
Only permitted edit to old refresh runner: replace its TWO V01 expected-version literals
`0.2.0-mvp+r02.1` with `0.2.0-mvp+r03.1`, preserving every other byte, all61groups and helpers.
No SelfTests/older runner/fixture adaptation. Unexpected legacy failure stops for primary.

### 5. Full final checks, docs and frozen report — depends on4

Root README current R03 status/version instruction; dashboard README add current R03 intro
before existing R02, preserving all old sections. Explain signal/verified replacement versus
historical pending state and legitimate blue-only no-gain case, not a blanket flicker claim.
Run all commands serially to terminal completion, exact diffs/reversal/protection proofs,
final hashes, then independent review/primary acceptance before focused native follow-up.

## Files

Writer: CraftArmy/Dashboard.lua (handoff/visible Concentration/private build integration),
CraftArmy/Collectors.lua (private signal lifecycle/accessor ONLY, no collection-policy/math
changes), new tests/collection_continuity.lua, tests/refresh_continuity.lua (TWO literal
version replacements ONLY), README current R03/version lines, docs/dashboard/README intro
beforeR02, TASKS R03 execution/status/report. Primary owns PLAN/AGENTS/this contract/evidence/
review/artifacts. No competing writes while writer active. All other paths frozen, including
Core/Storage/ViewModel/Data/Knowledge/KnowledgeCheck/Commands/Details/SelfTests/old fixtures/
other runners/tools/TOC/assets/archives. Preserve all unrelated uncommitted user work.

## Tests

Installed runtimes only, inspect commands first; baseline all existing commands before edits.
New runner rejects unchanged production first; final serial commands:

```sh
lua5.1 tests/collection_continuity.lua
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

No test skips/limits/coverage reduction. Whole refresh-runner reconstruction by reversing
ONLY TWO literals; all SelfTests bytes frozen. Immutable preimages/protected paths/README
history/icons/inventory/HEAD/index and full actual diff including new runner/final hashes.
No permission-denial retry/bypass; independent denied execution remains NOT RUN, never
reattributed from writer/primary. Platform review N/A. Native full suite INCOMPLETE87/149,
all-rank UNVERIFIED and measured offline accuracy unverified remain unchanged.

## Out of scope

No install/copy/Git mutation/release/deployment/guides, new native evidence dumps/gear or
profession changes, broad dashboard redesign, schema/currency/estimate maths, predictive
saves/sort/attention, collector query or scheduling policy changes, global drift-guard
removal, unlimited-source synchronous acquisition, stronger native-cause/success claim.

## Report back

agent-handoff envelope, durable TASKS numbered piece/run states at every stop: completed,
blocker, remaining/exact resume, baseline/red/green/failure chronology, commands/results,
actual files/diff/hashes/protected/old-runner reversal/Git/icon proofs. Artifacts read-only;
primary generates review diff. Freeze complete delivery; implementation COMPLETE never
grants review/primary/native acceptance or publication. No child agents.
