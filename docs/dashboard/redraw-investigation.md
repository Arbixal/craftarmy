# Dashboard redraw investigation — 2026-11-17

**Status:** focused primary reproduction followed by implemented/locally accepted R01;
user now confirms stable table visibility during scans and profession open/close.
[Current review/acceptance](redraw-review.md); broader native acceptance remains separate.
Implementation contract: [R01](redraw-r01-contract.md); the proposed
direction below is historical where refined by that contract. Three dashboard
refinements afterwards. [Current tasks](../../TASKS.md), [requirements](../../PLAN.md),
[user discussion](../questions/Q05.md).

## Observed mechanism

- `CraftArmy/Dashboard.lua:475–477`: schema2 Refresh always enters StartBuild.
- `Dashboard.lua:504–510`: StopBuild cancels earlier work; StartBuild clears selection,
  confirmation and **self.rows**, then immediately Render hides every row widget.
  A replacement is not available until later frame callbacks.
- `Dashboard.lua:539–570`: context/revision/options guards validate the completed job;
  only then do rows replace the empty list and Render show them again.
- `Dashboard.lua:530–537`: failure also clears rows, leaving an empty view on errors.
- `CraftArmy/Commands.lua:520–527`: profession close/data-source changing/combat entry
  invalidate the collector and explicitly Refresh. Other events request a coalesced
  scan; successful/failed collection notifies the same dashboard Refresh callback
  (`Commands.lua:433`, `Collectors.lua:395–418,528–555,655–664`). Thus ordinary profession
  changes can trigger a whole display rebuild even without changed persisted data.
- Refresh during a build cancels/restarts it. Model publication guards compare collector
  serial/revision/freshness identity and storage revision/options. Repeated events can
  prolong blank time; obsolete callbacks correctly cannot publish old results.
- `Dashboard.lua:579–582,281`: Toggle refreshes while hidden and OnShow refreshes again
  for schema2. The hidden call currently clears rows then returns without building.
  Avoid treating the hidden preparation call as a second completed rebuild.

This explains a reproducible blank/repopulate path consistent with the user report;
it does not measure native latency or establish that no other redraw source exists.
Nothing in this finding authorizes suppressing freshness invalidation or scan safety.

## Focused local execution

Executed with already-installed `lua5.1`, isolated namespace and existing synthetic/
native-derived fixture helpers only. No game, private SavedVariables or production
runtime was accessed. No tracked source/tests were edited.

The inline harness loaded modules as the standalone runner does, located the existing
`S01 dashboard bounded driver pending supersession hidden scheduler failures no reset`
case, and used Lua debug upvalue access to reuse its `seed`, `opened`, `fixtureAPI`,
`mockWidgets` and `frozen` helpers. Native-style Show/Hide script dispatch matched that
case. It instantiated the real Dashboard/Collectors/Commands against the eight-row
schema2 fixture, drained the initial build, and called the real Commands Event method.

```text
Initial completed dashboard: 8 rows, first row visible.
Immediately after TRADE_SKILL_CLOSE: 0 rows, row widgets hidden, rebuild pending.
After 52 synthetic clockless frame callbacks: 8 rows visible; persisted fixture graph unchanged.
Repeated refresh: earlier build cancelled, old callback cannot publish; table stays blank until latest completion.
PASS: focused PRIMARY fixture reproduction of blank/repopulate on unchanged storage. Not native timing or a fix validation.
```

Assertions checked visible widget state, row counts, pending/cancelled jobs, stale
callback behavior and unchanged fixture graph identity/content before/after both flows.
Clockless one-Step fallback is deliberately in effect: **52 callbacks is not 52 native
frames or a measured duration**, and is not a reason to raise batching limits.
This is new focused primary evidence, not a full-suite rerun or independent validation.

Relevant existing regression coverage checks initial-empty pending builds, no partial
publication, cancellation, combat and failure guards (`SelfTests.lua:9334–9354,9773–9797`),
but not retention of an already completed table during refresh. Any correction needs
additive coverage for that lifecycle, with explicit adaptations only if old assertions
actually conflict; retain original failing reproductions and safety workloads.

## Proposed correction direction — approval/contract pending

1. Separate **displayed completed view** from **in-progress replacement**. Do not clear
   a valid completed table merely because another build starts. Initial load may show
   loading/empty state when no completed view exists.
2. While retained, label it updating/last-observed, not live/current. Do not retain
   obsolete fresh amber attention/diagnostic cues. Changed filters/View must not imply
   the old rows already match the new request; current lifecycle/Details actions need
   disabling or safely revalidating until the displayed scope is coherent.
3. Keep bounded asynchronous work and coalesce redundant redraw requests without
   ignoring genuine collector/storage/freshness/options changes. No full-account
   synchronous fallback or safety-limit change.
4. Swap rows only after a complete current build, preserving all serial/revision,
   visibility/combat, invocation ownership and post-cleanup/reentrant guards. Failed,
   cancelled or superseded jobs cannot publish. Report failure while retaining only
   an honestly labeled safe prior view; unavailable/replaced storage is a distinct case.
5. Preserve page/selection when still valid, not stale action scopes. Confirmed empty
   results and deliberate archive/delete actions must not resurrect removed data.

Required tests include populated refresh, profession open/close/event bursts, status-only
updates versus actual writes, combat/unknown safety, hidden/reopened windows, changed
filters/sorts/View, failures/retries and stale/reentrant callbacks. Keep full local
correctness/stress suites. After reviewed implementation, use a focused user-run
profession-open/close normal-use check, not a repeated Knowledge/full-selftest chase.

## Dashboard follow-ups — after redraw

- **Skill:** progress bar, color approaches green as observed skill approaches maximum.
- **Concentration:** progress bar, turns green when full.
- **Older-expansion gear:** red background overrides rarity background for both
  accessories and tool. Quality indicators/rarity detail remain distinct.

User confirmed these outcomes, not exact gradients, non-full colors or a classification
API. Preserve numeric values and unknown/stale/cap distinctions; don't invent a cap or
gear age. Establish reliable expansion metadata before implementing older-gear red.
These are queued requirements, not part of the proposed redraw-only correction.

## Source identity / evidence limits

Source at reproduction, unchanged from accepted S01:

```text
f00ca5756654b1909e49538a7c0ac5f28f221e7de8ed76b7996d047e0afaa3ac CraftArmy/Dashboard.lua
43a3dca252696d5f596727133028ddc96804bac82b8331d03fad6b84aba4d707 CraftArmy/Commands.lua
aa00b24526c9fd6f9b3af85cc685120ba66eb66d15054f410a74b5288e7deb27 CraftArmy/Collectors.lua
91a9d9646716032545448c7c2a2e39cd80c092798f324509a65a047c3b86d9aa CraftArmy/ViewModel.lua
d907ef6bce9459109072e2474a89e63dd1b870dd2bc3f187ce711bba2ce6b83a CraftArmy/SelfTests.lua
7033a1eab99d2b2adbb6a76e8bb8afb6d29e541184227564107242b094577dde tests/dashboard.lua
```

Pre-document-edit hash manifest:
`/tmp/opencode/craftarmy-redraw-investigation-t22ualf6/before-files.json`.
Previous full-suite results remain historical; full native INCOMPLETE 87/149, all-rank
UNVERIFIED, missing external bundle and independent-execution limitations are unchanged.
No code fix, release, Git action or game installation follows from this investigation.

Documentation validation: both Python structural checks PASS; dashboard check inspected
56 Markdown documents / 269 local links and unchanged diagnostic hashes. Scope comparison
against the manifest confirms only PLAN/TASKS/Q05 changed plus this new investigation;
97 other original file hashes unchanged. Q05's original bytes remain an exact prefix.
These checks are not additional Lua/native execution or acceptance of the proposed fix.
