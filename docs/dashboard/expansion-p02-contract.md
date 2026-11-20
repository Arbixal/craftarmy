# P02 — Verified gathering field activation

## Goal

Activate evidenced Moxie, numeric Knowledge/unspent and Finesse/Perception Tool stats for
Herbalism, Mining and Skinning. Preserve P01's five-profession foundation and the accepted
crafting dashboard. This is a bounded activation milestone, not complete acceptance of
every new profession/capability. Cooking/Fishing Moxie, Deftness and new enchant warnings
remain unresolved; they do not block these verified fields.

## Why

[PLAN](../../PLAN.md) prioritizes all-profession dashboard coverage before Concentration
flicker and guides. The [native gathering evidence](gathering-native-evidence.md) records
three complete/stable reports on70961 and user-confirmed native numeric agreement.
P01 is locally accepted, not an active writer task or permission to guess pending fields.

## Run state

**Current disposition: locally ACCEPTED2026-11-19.** All5pieces complete; independent full
STATIC review PASS/no findings and separately attributed PRIMARY full suites/preservation/
post-review freeze PASS. Independent executable verification INCOMPLETE after shell denial.
No further executable piece/writer; approval/start instructions below are history, not a
permission to rerun the queue. TASKS/[review](expansion-p02-review.md) retain current gates.

**READY2026-11-19; implementation and local tests approved.** After preparation user
explicitly answers “Yes” to scoped P02 implementation and local tests. No production/test
edits or new Lua/native execution at approval. Earlier preparation-only gate is resolved.
Piece statuses/run state belong in [TASKS](../../TASKS.md), not a second queue here.

Use one synchronous implementer, then independent review and primary
acceptance. No children or parallel writers. Primary first supplies a repo-local ignored
comparison snapshot/manifest of the actual working tree; no external-path access/retry.
Writer has read-only access to that comparison data, not ownership of its artifacts.
Paths: `artifacts/p02-comparison/before-files.json`, `preimage-paths.json`, `git-before.json`.
Primary verifies snapshot before dispatch; eight immutable preimages stay local/read-only.

Comparison base is the **accepted uncommitted P01 working tree**, not HEAD. Initial
commit5f98f5e remains the Git base but predates P01 and unrelated planning/archive work.
Preserve all staged/unstaged/untracked user work; no reset/clean/stage/commit/push.
Eight existing implementation-owned path hashes at preparation:

```text
7abc18c4b633d9df83b3877f389ad46305c4535106b4310ea433af630d11c515 CraftArmy/Core.lua
ffa36e82ded170e094045bed94f08ac97f821312b94319c708cb6d066b99de7d CraftArmy/Data.lua
453e70421a419fc730232f6debd07f9d5e1b17b325d8f49fd9dbe3a857912cd2 CraftArmy/Collectors.lua
8aaafdcb7b710214a725758d5253861ea0baa528f89ef3a649cf36c3454d3ea6 CraftArmy/KnowledgeCheck.lua
21b0714639563d4fd543aa31262be9a95cc0f405d9e07bdc80058f58a642b263 CraftArmy/SelfTests.lua
90bcad85b095aee1fac664a3df7769950054df6b4218c10bfe56b2bb0df67c66 tests/profession_expansion.lua
19f9598cd3ab165564e08b96fcb99ebda0354e291451355a95894672e88399ca README.md
e72fa0c8494eddf8c887f1bad906a4d2137d7e726dd5981130449319d7e0d7c4 docs/dashboard/README.md
```

New `tests/gathering_activation.lua` is absent. All11accepted P01 source/test/README hashes
matched at preparation; fresh full suites have not run. Drift must be investigated with
primary, never overwritten. Primary updates the manifest pointer in TASKS before launch.

## Design — numbered pieces

### 1. Baseline, rejecting regressions and preservation snapshot

Read conductor/PLAN/TASKS/this complete contract and test scripts before executing them.
Verify primary's actual-tree manifest and the eight hashes above. Run full local baseline
serially. Add standalone `tests/gathering_activation.lua` regressions against unchanged
production; require meaningful failures for missing maps/capabilities/Tool categories,
not harness errors. Preserve tests' real rejection predicates and original workloads.

### 2. Activate exact data/Core catalogues — depends on1

| Exact child/parent/family/expansion | Active Moxie | Native Knowledge spend |
| --- | --- | --- |
|2912/182/4/11 Herbalism |3260 |3778 |
|2916/186/6/11 Mining |3264 |3784 |
|2917/393/11/11 Skinning |3265 |3889 |

- Data: change only these three moxieCatalog provenance strings to
  `User native gathering capture/UI agreement 2026-11-19; 70961`; reference those entries
  from Data.moxie. Original eight active Moxie entries/provenance stay byte-identical.
  Active Moxie count becomes11; no Cooking/Fishing or inferred currencies.
- Exact gathering capability tuples change knowledgeMode and moxieMode to `enabled`.
  All five additions remain concentration=false and enchantAttentionMode=pending.
  Cooking/Fishing policies/slots/roles/N/A remain unchanged. Capability copies stay isolated;
  unknown/conflicting/base/old-expansion identities cannot activate fields.
- Add only ITEM_MOD_FINESSE_SHORT and ITEM_MOD_PERCEPTION_SHORT to Data.statNames,
  referring to existing Finesse/Perception category entries. Six keys total; Deftness
  stays unmapped. Existing D/F/P presentation labels and six enchant catalogue entries
  do not establish other API keys, enchantability or enchant amounts/ranks.
- Core: add only Finesse/Perception to private toolCategories and the three exact tuples
  above to nativeCurrencies, with short70961 provenance comments. All other Core bytes
  are frozen. No validator/schema/slot/policy/PIN/limit change. Prove exact Core preimage
  reconstruction after removing these additions/comments. Reject Deftness and arbitrary
  categories, accessory toolStat, wrong metadata source/role/slot, empty/unready instances.
- Keep all existing tree colors; gathering uses the existing neutral fallback in P02.
  A palette redesign is not needed for numeric activation.

### 3. Preserve collector safeguards while enabling scans — depends on2

P01 currently uses `moxieMode==pending` for **three unrelated safety choices**. Turning
Moxie on must NOT remove them. Add a private exact-five-ID predicate for2912/2916/2917/
2908/2911, used only after existing Data.Identity/Capabilities validation:

1. Context retains usable observed skill/cap checks for those five professions, regardless
   of Moxie mode. Zero/invalid caps, negative/fractional skill and skill>cap remain rejected.
2. Scan retains bounded/plain/dense/duplicate-aware knIDs slot parsing for those five.
3. Scan still skips reads/writes for their unknown `slotN` roles, regardless of Moxie mode.
   Returned1/29/30/33 must not start gear acquisition just because gathering is enabled.

Original eight professions keep their existing paths. Do not weaken learned-roster,
own-character, frame/readiness, combat/linked/guild/NPC/source-changing, identity/config/
sourceCounter/serial/revision/staging or async equipped-instance guards.

Use existing currency collection, Knowledge projection/evaluation, Core validation and
schema1/schema2 storage paths. No new parallel accounting algorithm. Knowledge.lua,
Storage.lua, ViewModel.lua and Dashboard.lua need no edits for these mappings and remain
frozen. If a genuine blocker requires changing one, stop that dependent piece and return
the concrete conflict to primary; do not relax its guard.

Knowledge uses `native-rank-reconciled-v1`, costRule=unknown and existing all-or-nothing
coverage/identity/shared-spend guards. Exclude unlock ranks, compare shared spent once
per profession, never once per tab; auxiliary current unlock costs are not Knowledge.
Unspent stays an independent observed read with existing staging protections. Do not add
a new cross-field equality rejection policy or silently change crafting semantics.

Moxie maxQuantity0 is not a usable cap: save actual observed balance and show plain balance,
not245/0 or a clamped0. Never import sample character balances as defaults. Skill105/105
and modifier40 stay separate observations. Failed reads retain coherent prior values and
their own timestamps; no reset/backfill/retraining/forced recovery scans.

Tool F/P uses the existing validated enchant-neutral query, single recognized positive
category, metadata source/time and same-instance retention rules. Raw totals/enchant
metadata remain separate; no adding/subtracting an enchant amount or parsing labels to
guess an intrinsic stat. Existing ambiguity/error/loading/change-of-instance behavior
must still hold. No new missing-enchant attention for the five additions.

KnowledgeCheck wording-only exception: replace its four obsolete activation-state text
literals, without changing capture logic/output fields/bounds/completeness/scheduling:
`P01 diagnostic candidate only; no production activation` becomes
`P02 read-only evidence; capture does not change activation or snapshots`;
`gatheringEvidence candidate-only` becomes `gatheringEvidence read-only`;
`gathering unspent observation (not activated)` becomes `gathering unspent observation`;
`gathering Moxie candidate (not activated)` becomes `gathering Moxie observation`.
This avoids falsely reporting production fields inactive after P02. Prove exact whole-file
preimage reconstruction on reversal; candidate API helper remains unchanged/read-only.

### 4. Focused regression adaptation and presentation coverage — depends on2+3

Preserve512legacy top-level cases/order,19U07workloads and supplements. SelfTests edits
are restricted to the following expectation/provenance adaptations, plus narrow case-label
wording; bracket each with P02 original/active markers and prove exact preimage recovery:

- U10 invalid tool metadata mutation around628: replace unsupported `Perception` example
  with still-unsupported `Deftness`; every other invalid mutation/rejection stays intact.
- E02 catalogue provenance around8272–8275: accept the exact new provenance for ONLY
  Herbalism/Mining/Skinning. Catalogue entries/unique-ID count remain11.
- E02 active Moxie list/count around8279–8285: add2912/2916/2917 and expect11, retaining
  all original eight object-identity comparisons. Do not change registry/exclusion blocks.
- E04 active case label and stat-key list/count around8807/8816–8819: add exact F/P keys
  and expect6. Original seven stat categories, six enchants and13identities unchanged.
  Preserve all pre-existing P01/Uxx original-marker payloads verbatim.

`tests/profession_expansion.lua` keeps all16groups in order, unchanged stress workloads,
private-data/cancellation/bounds/reentry/N/A checks and fixture helpers. Only these
activation-dependent blocks may change, each marked with recoverable P02 preimage:

- Registry group: expect enabled gathering Moxie/Knowledge, three active maps, F/P keys;
  secondaries stay pending/no currency and Deftness stays nil. Existing-eight check loop
  must explicitly enumerate/exclude the three newly active gathering entries, not assume
  every Moxie profession has Concentration/enchant-attention. Keep rejecting tuple tests.
- Guarded schema1/schema2 scan group: gathering now queries currency/graph/unspent;
  secondaries still skip them. Default synthetic graph remains unreconciled (wrong currency),
  so no numeric tree success is asserted. Keep N/A/empty-slot/skill-invalid/absence tests.
  For its historical retention phase, inject nil Moxie/unspent APIs before the scan for
  gatherers, so last values/timestamps remain unchanged under actual failed reads rather
  than demanding old values survive new successful observations.
- Read-only candidate-report group: replace dormant-map nil assertions with exact active
  mapping checks and before/after registry/collector/storage immutability. Capture is still
  read-only candidate evidence, not an activation switch or saved scan.
- Core secondary metadata group: F/P now valid on named ready Tool slots; Deftness and
  all other rejecting source/role/slot/instance predicates remain rejected.
- Historical indexed-tree retention group: inject nil Moxie/unspent reads; retain default
  wrong spend currency so raw/index/tree attempts fail. Expect graph acquisition occurred,
  not skipped; preserve five independent timestamps/coherent history/stale display assertions.
- Case labels may describe enabled/failed-read behavior instead of obsolete pending wording.
  No other fixture edits without primary approval; no disabling production activation in
  the fixture to make old expectations pass, omitted workloads or helper bypasses.

New standalone runner covers exact positive/negative cases below with actual production
modules. It may build private API/widget fakes, never use client globals or real snapshots.

### 5. Full checks and delivery docs — depends on4

Run all validation terminally/serially; record failures and later fixes separately. Update
only current-status/P01 introductory documentation in both READMEs; preserve historical
sections verbatim. State active gathering fields, residual unknowns, local-vs-native gate
and normal-use new-profession steps; remove current instructions to repeat already-returned
three gathering reports. Add the standalone runner command. Freeze source hashes/diff,
preservation proofs and exact resume/report state in TASKS before independent review.

## Files

| Owner | Writable scope after implementation approval |
| --- | --- |
| Implementer | CraftArmy/Data.lua; CraftArmy/Core.lua (two private maps/comments only); CraftArmy/Collectors.lua (three safeguard decouplings/private exact-ID helper only) |
| Implementer | CraftArmy/KnowledgeCheck.lua (four listed text literals only) |
| Implementer | CraftArmy/SelfTests.lua and tests/profession_expansion.lua (listed marked adaptations only); new tests/gathering_activation.lua |
| Implementer | README.md current-status/evidence/development lines; docs/dashboard/README.md introductory P01 section before U15 |
| Implementer | TASKS P02 piece statuses, execution/run state and result section only |
| Primary | PLAN, AGENTS, this contract, evidence/audit/question docs and comparison artifacts |
| Frozen | Every other path, including Knowledge/Storage/ViewModel/Dashboard/Commands/Details, Lua runners other than listed, Python tools, diagnostics, .toc, agents, assets and archives |

No assigned-file/active-contract changes by primary while a writer is active.

## Tests

Required local commands from repo root, using already-installed runtimes only:

```sh
lua5.1 tests/gathering_activation.lua
lua5.1 tests/profession_expansion.lua
lua5.1 tests/dashboard.lua
lua5.1 tests/run.lua
python3 tools/check_dashboard.py
python3 tools/check_diagnostics.py
git diff --check
```

Baseline runs all existing commands before edits; the new runner must first reject
unchanged production. Long runs may use background execution, with automatic terminal
notifications, no polling/duplicate runs. Final success requires all legacy cases/workloads,
K6/K7 and diagnostics retained, no coverage/limits cut. Prior P01 passing counts are not
fresh P02 evidence. Independent execution/comparison, if denied, stays NOT RUN.

New runner minimum acceptance:
- All three exact Moxie/Knowledge tuples; wrong parent/family/expansion/old/base/unknown
  identities rejected. F/P mapped; D absent; original eight mappings/provenance preserved.
- Complete normalized36path/9tree evidence projection yields Mining29/170,40/110,0/200;
  Herbalism40/240,41/120,0/200; Skinning0/120,0/160,61/120. Native evaluator, payload checks,
  schema1/schema2 scans, storage reopen and view rows agree; totals69/480,81/560,61/400,
  unspent5/4/0 and Moxie245/300/55. Clearly label any reconstructed fixture-only metadata
  versus actual report facts; not a raw-report parser replay or all-rank proof.
- Current auxiliary unlock costs accepted only under existing locked-path guard; duplicate/
  shared/unreachable/missing/clipped paths, bad node/entry/rank/free ranks/currencies,
  wrong spend, inconsistent shared rows/spent sums and staged/unstable context remain
  nonnumeric/failed and preserve prior tree/index values and their independent timestamps.
- Both storage facades/reopen retain known values on nil/error/unsupported/invalid currency
  or graph reads. Moxie max0/nil, balance0/600/601, Skinning cap105/modifier40; no synthetic
  zero, positive-balance clamp, sample defaults, or hidden character cap.
- All five Context skill/cap rejections and bounded slot parsing remain after activation;
  forbidden1/29/30/33 never read/write for new professions; duplicate/sparse/metatable/
  overlimit/unknown-role lists do not invent gear absence. Original-eight behavior retained.
- Actual F/P optional Tool metadata, F/P letters, raw total versus neutral query separation,
  ambiguous/nonpositive/malformed/error/loading/changed-link cases, same-instance history
  and noninheritance across changed instances. Accessories cannot store Tool metadata.
- Cooking/Fishing stay skill/gear-supported with pending Moxie, N/A Concentration/Knowledge/
  Unspent and correct accessory roles; all five still lack missing-enchant attention/filter
  matches. Existing Moxie/progression/skill/filter/sort behavior works on observed values.
- Reused actual widget fixtures clear prior decorations on N/A rows; normal gear hovers
  stay native-only, Shift exposes diagnostics. Native fonts/timing not inferred. At least
  one mixed46character active-field workload supplements existing46/100/200 P01 workloads.
- Read-only gathering capture cannot mutate maps/collector/storage or write snapshots;
  full bounds, completeness, privacy, cancellation and scheduler tests still run.

Preservation: exact marked preimage reconstruction for both adapted fixtures; exact Core
map/comment reversal; exact four-literal KnowledgeCheck reversal; all nonowned paths
unchanged; packaged/original icon pairs unchanged;
HEAD/index unchanged. Platform review is not applicable: no CI/hosting/IAM/deployment scope.

## Out of scope

No Concentration flicker/estimate/timer work; no new guide or Details support; no storage
migration/reset/eviction/forced scans, real SavedVariables import/edits, installation or Git
mutation. No new Deftness key, Cooking/Fishing Moxie mapping/N/A inference, missing-enchant
eligibility, extra API family/slot/stat/enchant IDs, all-rank proof, new build/PIN, UI layout
redesign or repeat accepted crafting checks. Residual capability evidence is primary-owned
later work, not a blocker on this bounded verified activation.

## Report back

Use agent-handoff envelope and persist in TASKS: piece/run state, exact changed files and
hashes, comparison base/manifest, final actual diff, command outcomes with full workload/
supplement attribution, red/green evidence, preimage/protected-file proofs, failures/denials,
remaining gates and exact resume point. Implementation COMPLETE is not independent review,
primary acceptance, native five-profession sign-off or release approval. Primary coordinates
focused normal-use new-field feedback after acceptance; no repeat dumps or gear changes.
