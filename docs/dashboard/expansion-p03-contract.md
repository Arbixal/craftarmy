# P03 — Profession N/A, gathering colours, Deftness and enchant warnings

## Goal

Finish the four approved profession refinements: Cooking/Fishing Moxie N/A, coloured
gathering Knowledge bars, Deftness Tool recognition and gathering missing-enchant warnings.
Preserve accepted P01/P02 data/safety/layout behavior. Cooking/Fishing enchant eligibility
remains provisional; their missing-enchant warnings stay disabled.

## Why

[PLAN](../../PLAN.md) and [latest native evidence](gathering-native-evidence.md) record:
gathering dashboard numbers match, grey bars use unregistered-palette fallback, secondary
professions have no Moxie, older Skinning Tool raw ITEM_MOD_DEFTNESS_SHORT110 matches
its tooltip, and user definitely confirms gathering permanent Tool enchant support.
No newer Tool, repeated reports, purchases/applications/swaps or older-profession rows.

## Run state

**Current disposition: locally ACCEPTED2026-11-19.** All5pieces complete; independent
STATIC review PASS/no findings plus separately attributed PRIMARY full suites/exact
preservation/post-review freeze PASS. Independent executable verification INCOMPLETE after
shell denial. No writer/further executable piece. Approval/start instructions below are
history, not authority to rerun. TASKS/[review](expansion-p03-review.md) retain current gates.

**READY2026-11-19; user explicitly answers “Yes” to implementing this four-part batch.**
No source/test edits or new Lua/native execution at approval. One synchronous implementer
executes TASKS numbered queue, no children. Independent review then primary acceptance.
Primary supplies actual-tree snapshot before dispatch, read-only to writer/reviewer:
`artifacts/p03-comparison/before-files.json`, `preimage-paths.json`, `git-before.json`.
Primary owns artifacts/contract/planning; no denied external-path retry or artifact edits.

Comparison base is accepted **uncommitted P02**, not initial Git HEAD5f98f5e. Preserve all
existing user/planning/archive/code changes. Nine owned existing path SHA256s at approval:

```text
8d95fa3f740d0e474b941c23584994748c22c309e59ff85f7927497b0795db8a CraftArmy/Core.lua
92f1558492e65a769896841aa000a04d4aba672f3b7b6b4f09f22e89e5b66e15 CraftArmy/Data.lua
ece23816e159301a79d4aa92e5f36154def23c5fe777a4dd329542d455ef9f39 CraftArmy/Collectors.lua
366bde4db3f688c1d769370c79b1c4688123a78a3f2afc5422562a7fc881a533 CraftArmy/ViewModel.lua
fd520e1c084139d10f6ecb29c7e0c7c6e824633193b6bfedaaad9be51b830a97 CraftArmy/SelfTests.lua
e3664af689df0eeb764263fb4237dcd57474e9303e3dad14d83dc5163aa2718f tests/profession_expansion.lua
93af470bc2df086b0afd5ead9082be3054d9ee501e5876fcece9ad61ec75841f tests/gathering_activation.lua
e4047ac5a80a477c4be10a877276e4f34eb158a906023f9e097f8fc3a338a5b3 README.md
b01dae9537c813b116cd964bfe1130b28763de20675746eb4784f19a0fecb0cb docs/dashboard/README.md
```

New `tests/profession_completion.lua` absent. All9accepted P02 targets unchanged. Task
piece/run state/report is maintained in TASKS, not a competing execution queue here.

## Design — numbered pieces

### 1. Baseline and rejecting regressions

Read full contract/AGENTS/PLAN/TASKS, comparison manifests and test scripts. Verify actual
baseline hashes/inventory/Git state before writes. Run complete existing local baseline
serially. Add private standalone completion runner with meaningful failures against
unchanged production for each approved behavior, not harness errors. Retain all suites.

### 2. Data/Core activation — depends on1

- Data.Capabilities: exact Cooking2908/185/5/11 and Fishing2911/356/10/11 moxieMode becomes
  `not_applicable`. No Moxie currency added/removed, no other identity/Knowledge policy
  changes. Unknown/conflicting identities still return nil; never infer N/A from missing API.
- enchantAttentionMode becomes enabled for exact Herbalism2912/182/4/11, Mining2916/186/6/11
  and Skinning2917/393/11/11; original eight stay enabled. Cooking/Fishing remain pending,
  NOT confirmed ineligible/N/A and NOT enabled. Use existing observed-absent warning logic;
  no new applicability API, profession/item/level heuristic, enchant catalogue IDs/amounts.
- Add `ITEM_MOD_DEFTNESS_SHORT=Data.statCategories.Deftness` (seven keys total). Keep
  all six current stat keys/category references and all existing enchant provenance intact.
  Screenshot supplies raw key evidence; do not claim a separate native neutral-query result
  or build not shown. Reuse guarded neutral-query/one-positive-category/instance retention;
  if neutral observation unavailable or ambiguous, fail safely, not infer from item text.
- Core: add only `Deftness=true` to private toolCategories, with short screenshot-provenance
  comment. Every other Core byte, validator, metadata slot, currency/PIN/schema/limit frozen.
  Prove exact whole-file preimage reconstruction after removing this addition/comment.
- Add only these native-ID treeColors entries, with provenance comment:
  Herbalism `[2912]={1074,1073,1080}`, Mining `[2916]={1107,1105,1106}`,
  Skinning `[2917]={1120,1119,1121}`. Palette remains blue(.20,.65,.95), green(.20,.78,.48),
  orange(.98,.62,.20) in recorded order. Original eight palettes/IDs and unknown fallback
  unchanged. Match profession+tab identity, never row/tab order/localized names; this is
  visual only, not accounting/collection eligibility or saved topology.

### 3. Secondary Moxie acquisition/presentation — depends on2

- Collectors: ONLY add the `moxieMode==not_applicable` branch invoking existing na("moxie")
  before pending fallback. Secondary scans skip all Moxie currency APIs, record evidenced
  N/A with existing observation semantics. Keep exact-five skill/cap/strict slot/unknown-slot
  safeguards independent of mode. No other Collectors bytes/logic changes beyond this branch.
- ViewModel.Row: add secondary Moxie to existing capability-derived `na` mask and
  notApplicableColumns[I.Moxie]. Set Moxie cell `—`, row.moxie nil, no numeric sort key/
  Moxie warning/filter match/green balance cue, on both active and archived/historical rows.
  Known real crafting/gathering zero/max0 remains observed0, not N/A. Nonmax secondary Skill
  remains in Skill filter and unrelated fields/actions behave as before.
- Reuse existing normal/Shift tooltip handling: normal N/A hover is “Not applicable.”,
  Shift includes underlying masked Moxie history/ID/quantity and existing source/timestamps.
  Add a narrow `field("moxie")` underlying-history diagnostic branch as needed; do not
  expose hypothetical old Moxie balances to summaries/sort/attention. Reading/masking an old
  row must not mutate its storage or observation times; no migration/backfill/reset.
- A later successful own scan can record N/A using existing Merge semantics (replace that
  active field's successful value). Do not demand retention of a superseded active value
  after a SUCCESSFUL N/A observation; failed reads/archives/unscanned snapshots still retain
  their coherent history. No storage special case or hidden backup field.
- No Dashboard changes required: existing generic text/N/A tooltip/moxieRGB handling and
  TreeRGB call consume the new model/palette. Dashboard, Knowledge, Storage, Commands,
  KnowledgeCheck and Details frozen. If genuine conflict found, return exact blocker to
  primary; no redesign, global guard weakening or Concentration lifecycle edits.

### 4. Fixture adaptations and new coverage — depends on2+3

Preserve original512cases/order, all19U07workloads, K6/K7 and all16P01/12P02groups/workloads.
Only listed activation-dependent expectations may change. Each P03 adaptation brackets
exact before bytes in recoverable P03 ORIGINAL/ADAPT markers; preserve every older
P01/P02/Uxx original-marker payload verbatim, including when nesting inside an active block.
Prove exact whole-file reconstruction against current P02 preimages. Narrow active case
label wording may be adjusted only if now factually obsolete, also marked.

SelfTests: U10 invalid-category mutation currently Deftness becomes `P03Unsupported`
(retain every other rejection); E04 active label reflects D/F/P support and active key map
adds exactly Deftness/count7. No other SelfTests edits. Existing U05 palette tests untouched.

P01 standalone fixture:
- Active capabilities row: secondary Moxie not_applicable, gathering enchant enabled,
  secondary enchant pending; Knowledge unchanged. Active stat-key expectation now maps D.
- Guarded schema scan active expectations: secondary Moxie attempt/last N/A, default neutral
  Deftness Tool metadata now observed Deftness (fixture already returns that key). Preserve
  currency skip/read counts and all other field/slot/context expectations.
- Historical Moxie phase after ordinary scan: gatherers still retain700/time90 on injected
  failed reads; secondaries instead assert successful N/A and nil successful value after
  the legitimate scan. Keep seed, no-auto-retire and other independent history tests.
- Core Tool-category loop: all D/F/P valid on appropriate Tool slots; retain accessory,
  wrong source/role/slot/instance rejection predicates. Add arbitrary unsupported-category
  rejection rather than deleting invalid-category coverage. Helpers/workloads untouched.

P02 standalone fixture: only unmapped-Deftness expectation becomes exact mapped reference
in first Tool-category group, and invalid Tool-category mutation in F/P rejection loop
becomes `P03Unsupported`. All other scenarios/helpers/12groups and46active workload unchanged.
If additional unexpected failure, stop and return concrete conflict rather than broad edits.

New completion runner minimum coverage:
- Exact capabilities and copy immutability; no secondary Moxie API reads under nil/error/
  absent APIs; schema1/schema2 scan, reopen, active/archived N/A, synthetic700history masked
  read-only before scan and successful N/A semantics afterward; preserved independent values.
- Real reused Dashboard widgets across gathering/secondary rows: `—`/neutral colour,
  normal concise N/A/Shift historical diagnostic, no Moxie filter/sort key; no stale prior
  decoration/tooltip; nonmax secondary Skill still matches. Snapshots unchanged by rendering.
- All9gathering tab colours with swapped order/identical localized names; existing eight
  colours unchanged, wrong profession/tab, unknown/nil/string IDs use neutral fallback.
  Actual bar widgets receive correct stable RGB; totals/ratios/sort/saved graphs unchanged.
- Deftness raw totals/neutral query separation, D letter, older-expansion10 Tool red border
  and metadata source/time; seven recognized keys only. Synthetic fixture neutral result
  clearly labelled fixture-only, not screenshot proof. Single positive D accepted; D+F/P
  ambiguity, zero/negative/malformed/nil/error/loading, changed link/source/context and
  same-instance history preserve existing safety. No accessory Tool stat or arbitrary key.
- Gathering warning for observed unenchanted ready Tool (ID0/explicit empty field), none
  for unknown/loading/absent Tool or observed enchanted Tool; inherited older observed
  absence is last-observed, not fresh proof. Archive excludes attention/filter. Secondary
  known unenchanted Tool creates no warning despite displaying actual observed enchant
  state. Existing crafting behavior unchanged, no inferred permanent enchant categories.
- At least46character mixed new/old-profession fixture: no cap/eviction/recovery scans;
  existing current-first/filter/sort/scroll behaviour, observed-only saved/attention values.

### 5. Full serial checks, docs and frozen report — depends on4

Run every final suite to terminal completion. Update root README current-status/evidence/
development lines and dashboard README introduction ONLY before `# U15`; preserve historical
suffix verbatim. State implemented P03 scope, secondary enchant pending, native new-feature
acceptance pending and no repeat captures/gear changes. Avoid future review-status claims:
link TASKS for current validation/acceptance, not hardcode “review pending” in delivered docs.
Record exact scope/diff/hashes/preimage/protected/Git results and run state before review.

## Files

Writer: Data; Core(one category/comment only); Collectors(one Moxie N/A branch only);
ViewModel(Moxie mask/cell/history only); SelfTests/P01fixture/P02fixture(listed marked
adaptations only); new tests/profession_completion.lua; root README current lines and
dashboard README introduction before U15; TASKS P03 execution/status/report only.
All paths are the exact repository paths listed in hashes above. Primary owns PLAN,
AGENTS, this contract, evidence/audit/question/review docs and comparison artifacts.
All other files frozen, including Dashboard/Knowledge/Storage/KnowledgeCheck/Commands/
Details, old runner scripts, Python tools, diagnostics, .toc, agents, assets and archives.
No primary edit to assigned files/active contract while writer runs.

## Tests

Inspect scripts first; installed Lua5.1/Python only. Baseline runs existing suites before
edits; new runner first rejects unchanged production, then all final commands serially:

```sh
lua5.1 tests/profession_completion.lua
lua5.1 tests/gathering_activation.lua
lua5.1 tests/profession_expansion.lua
lua5.1 tests/dashboard.lua
lua5.1 tests/run.lua
python3 tools/check_dashboard.py
python3 tools/check_diagnostics.py
git diff --check
```

No polling/duplicate background runs; automatic completion notifications only. Preserve
all suite limits/assertions/workloads; report baseline/new failures honestly. Exact Core/
Collectors reversals and fixture3whole-file marker reconstruction; nonowned paths unchanged,
9icon pairs unchanged, old README suffix unchanged, actual inventory and HEAD/index unchanged.
Primary artifacts only; reviewer independent execution, if denied, stays NOT RUN. Native
INCOMPLETE87/149, all-rank UNVERIFIED and offline estimate accuracy unverified unchanged.
Platform review not applicable (no CI/hosting/IAM/deployment changes).

## Out of scope

No Cooking/Fishing enchant-warning activation/N/A claim, new currency/enchant/key/slot IDs
beyond listed D/tree entries, new permanent enchant acquisition/gear changes or spending,
old-expansion profession support, UI/layout/sort redesign, snapshots migration/reset/import/
eviction/forced scans, Concentration flicker/estimation work, guides or Details redesign.
No install/dependencies, Git mutations/push/release/deployment or external secret access.

## Report back

Use agent-handoff envelope; durable TASKS P03 piece/run state at every stop, commands/
terminal outcomes/red-to-green and failure chronology, exact files/diff/delivery hashes,
comparison manifests, all preimage/protected/Git/icon proofs, blockers/remaining/exact
resume point. Freeze delivered targets for independent review; primary persists read-only
findings and acceptance. COMPLETE is not native/review/release acceptance. Focused user
normal-use check after local acceptance, not repeat reports/numbers or gear changes.
