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
