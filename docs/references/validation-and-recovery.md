# Validation and recovery — operational reference

Read [current TASKS](../../TASKS.md), [PLAN](../../PLAN.md) and [AGENTS](../../AGENTS.md)
before using [historical task records](../tasks/README.md). This extracts reusable
knowledge from finished queues, not a new implementation or testing authorization.

## Local checks and what they establish

| Entry point | Purpose | Does not establish |
| --- | --- | --- |
| `lua5.1 tests/dashboard.lua` | Full production-addon pure fixtures plus K6/K7 stress supplements | Native APIs, serialization durability or client performance |
| `lua5.1 tests/run.lua` | Diagnostic pure fixtures | Live profession or Auctionator behavior |
| `python3 tools/check_dashboard.py` | TOC/order/metadata, local links, saved-variable separation and diagnostic hash checks | Lua execution/syntax or native UI correctness |
| `python3 tools/check_diagnostics.py` | Diagnostic packaging/order/path/metadata checks | Lua execution or client evidence |

Use only an already-installed Lua5.1, inspect scripts first, and retain all original
scenario workloads. Completion and zero failures are separate: INCOMPLETE is not PASS.
Document exact command/result, source revision and who performed it. Historical463/463
or23/23 counts are not evidence that a new revision was run.

## Evidence and review

- Primary execution/comparison and independent static review are different evidence.
  If reviewer execution is denied, say so; never reattribute primary results.
- Record denied operations once; do not retry through another tool/role to bypass them.
  Missing derivative bundles/snapshots remain missing. A documented alternate delivery
  in an authorized project document is not proof the missing bundle was generated.
- Freeze actual source/files before review, persist findings before advancing, then
  verify reviewed hashes after review. Preserve rejecting reproductions and failed-run
  chronology. Don't silently rewrite old tests to make a changed policy pass.
- Use focused user-run normal-use/API/snapshot checks rather than a full-client timing
  chase. Historical full native suite stays INCOMPLETE87/149; all-rank costs UNVERIFIED.
  Neither is a blanket block on unrelated native work or an invitation to raise limits.

## Snapshot and migration safeguards

- Preserve known values on transient failures; unknown/nil is not zero or confirmed
  absence. Attempts, successful observation times and archive/scan times are distinct.
- Equipment is an instance-coherent unit. Same-instance transient metadata failure and
  changed/unidentifiable gear must not borrow values under the same rule. An explicit
  empty enchant field is not the same as a missing/malformed field; see current schema.
- Zero purchased points alone do not establish locked state; meeting a perk requirement
  does not establish an actually learned recipe. Don't infer either from totals.
- Share only compatible immutable definitions; personal allocation/state/context stays
  personal. Don't reconstruct discarded diagnostic graphs as fictitious native evidence.
- Discovery's eight-tree bound is not a historical-field cap. Old fields may survive
  changed indexes. Catalogue reuse must validate touched ownership/aliases/content even
  for a new character with no prior active record to validate.
- Guard identity/generation/context at acquisition and commit. Scheduled job cleanup
  can be reentrant: stale callbacks must not cancel, hide or overwrite newer state.
- Back up SavedVariables before migration. Failed/cancelled migration retains original
  data; no reset, silent eviction or rescan-to-recover fallback. Older schema-only addon
  rollback needs its matching pre-upgrade data backup. Exact policy lives in the
  [storage contract](../dashboard/storage-s01-contract.md), not archived schema1 defaults.
- Per-Step work bounds and frame batches are distinct. A measured2ms between-unit
  budget cannot preempt an indivisible unit, and zero-clock fixtures aren't native timing.

## Planning recovery

Keep one settled authorized serial queue and its stop/resume state in TASKS. Do not let
an implementer invent architecture or rewrite the active contract while it runs.
Completed work follows **check → collapse → evict** after a confirmed maintenance manifest.
Before archiving partially accepted history, carry genuine open conditions forward and
link back; don't erase them or reactivate superseded blockers. Preserve relative-link
meaning, original history and an inverse content/source-freeze proof. Current status,
active queue/run state, open issues and deferred work never disappear into an archive.

## Equipment metadata and tooltip lessons (U10–U15)

- Hyperlink display labels may contain quality-atlas markup and extra pipe characters.
  A `[^|]*` label assumption can reject an otherwise valid equipped link. Parse the
  anchored single-link payload/identity safely; do not weaken instance guards just to
  tolerate decorative label markup. [U11 review](../dashboard/gear-u11-review.md).
- Optional metadata failures must not erase otherwise valid base gear. Retain an old
  optional observation only for the exact same equipped instance under the current
  schema's rule; replaced, empty or unidentifiable items never inherit old metadata.
- Tool intrinsic categories and enchant categories are separate evidence. Never infer
  a base stat from an enchant label, double-count a total, or promote a supplied ID/list
  to universal native verification. Gathering category labels alone do not verify API keys.
- Normal equipped-gear hovers remain native/third-party-only; addon detail/provenance is
  Shift-only. Unknown/no-link fallbacks must not reuse stale links or hide meaningful
  unavailable/stale cues. [U15 review](../dashboard/tooltips-u15-review.md).

## Presentation, estimates and repaint lessons (R01/U13/U14)

- Retain the completed dashboard while an incremental scan/redraw is in progress. A
  scheduled old-generation callback must not clear or replace newer completed UI state.
- Filter before current-character grouping; sort inside the current/other groups. Reused
  visible row frames and scroll ranges are not character/profession storage limits.
- Concentration estimates are display-only, explicitly approximate and distinct from
  observed values. Predictions never drive sort order, attention/filter membership or
  saved observations. Unknown recharge inputs must not become fabricated predictions.
- Suppress identical-offset paints and coalesce drag work per frame; keep the thumb inside
  the full scroll bounds. Synthetic stress clocks and user-reported good performance do
  not establish measured native latency or an exact cause. [U14 review](../dashboard/scroll-u14-review.md).
- Gear-slot roles and field applicability are profession-specific evidence, not a fixed
  three-slot crafting assumption. Missing API/mapping/snapshot data does not prove N/A.

These are reusable safeguards extracted during the approved2026-11-18task cleanup,
not new implementation tasks, proof for the five pending professions or repeat native
test requests. Current artifact inventories remain in the dashboard/diagnostic READMEs
and packaged icon manifest; scripts/assets were not moved.
