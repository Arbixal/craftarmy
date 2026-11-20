# P01 — Profession foundation and consolidated gathering evidence

## Goal

Extend the dashboard foundation to the thirteen confirmed Midnight professions without
guessing unverified gathering currencies/accounting/stats or changing accepted crafting
behavior. Deliver one bounded, copyable gathering evidence report per profession through
the existing `/ca knowledgecapture` workflow, not another chain of manual dump commands.
P01 is a foundation/evidence milestone, **not complete native acceptance of all new fields**.

## Why

PLAN's full-dashboard-before-guides priority and Nov19 confirmed `—`/attention policy;
[native capability audit](profession-expansion.md). User has multiple Skinning characters.
Existing eight-profession dashboard sign-off remains accepted. No more ID/flag/Fishing
slot discovery, profession training/unlearning, gear changes or old native retests.

## Run state

**Current disposition: P01 locally accepted2026-11-19.** TASKS/review record final results,
attribution limits and the pending native gate; no writer or further executable piece.
The approval/start description below is historical, not authority to rerun the queue.

**2026-11-19: READY; implementation/local checks explicitly approved.** User says “Yes,
proceed” to this scoped foundation/read-only capture update and local tests. At approval,
no code/test changes or new Lua/native execution; all five pieces are unstarted.
One synchronous implementer executes the TASKS queue serially, no children.
Task piece/run-state updates belong in TASKS, not a second competing queue in this file.

Comparison base: `main` initial commit `5f98f5e`; source still at that baseline. Working
tree also contains prior uncommitted planning, audit and approved archive work. Preserve
all of it. Snapshot actual starting paths/hashes before writing; do not reset/clean/stage.
If a source hash differs, investigate with the primary before changing that file.

**Scoped access resolution2026-11-19:** initial implementer read of the external primary
snapshot was denied (`external_directory`); no bypass/retry. User explicitly approves
primary copying its150-path manifest/nine preimages to ignored `artifacts/p01-comparison/`
and implementer/reviewer reading that local copy. Primary owns artifact creation/updates;
writer must not modify artifacts or retry the external path. Compare immutable code
preimages from that copy; TASKS has later legitimate execution notes. Other primary-owned
approval/access notes may have changed after the original snapshot and are attributed
in TASKS before resume, not silently counted as writer drift.

### Primary engineering amendments — 2026-11-19, writer stopped

These resolve concrete implementation conflicts within the approved five-profession
feature; they do not authorize a schema redesign, new currency/stat mappings or looser
validation. Preserve all original rejecting cases and failure chronology.

1. **Core slot-only exception:** `CraftArmy/Core.lua` may change only its private
   `metadataSlots` declaration to add `[26]="tool",[27]="accessory1",[28]="tool"`, plus
   a short P01 provenance comment. Every other Core byte/validator/category/currency rule
   stays frozen. Current validator rejects valid Cooking27 optional metadata without
   these verified role entries. No29/30, Head1, arbitrary-slot acceptance or weaker guards.
   Add rejecting coverage for those excluded slots, wrong roles, optional metadata on
   empty/unready/unidentified instances and toolStat on accessories. Core original SHA256:
   `65b5b05b82a8f9155b4abb51b5c98f825926753db9d2911babddf866e3146253`.
2. **Legacy registry expectation exception:** exact E02 identities/families block around
   original8273–8283, E03 known-family assertions around8501–8503 and E04 family/skill
   registry assertions around8776–8780 may enumerate the five new verified tuples/labels
   and13count. Preserve original eight entries/provenance, all conflicting/unknown tuple
   rejection assertions, Moxie active count8, stat-key count4, unrelated count8 assertions,
   original case count/order/workloads and immutability proofs. Mark each P01 adaptation
   and prove exact preimage reconstruction. The E04 case label's obsolete “no gathering
   identities” wording may be corrected only to describe broadened registry/no new keys.
   Any other unexpected legacy failure still needs primary review.
   **Final narrow addition after terminal511/512 run:** E01's original7986–7988 exact
   expansion-map enumeration may add the same five verified IDs and expect13, marked
   P01. Preserve Inscription/Enchanting identity/Moxie checks and the following synthetic
   unknown/base-ID rejection loop unchanged. This is a registry enumeration, not an
   unrelated count8 assertion; no other new adaptation authority.
3. **Local backup artifact correction:** the two copied README backups are now named
   `README.md.preimage` instead of `.md`, with identical bytes/hashes. They are source
   comparison data, not project documents to link-check at a different relative root.
   Tools/actual project docs/link coverage remain unchanged. Use primary-owned
   `artifacts/p01-comparison/preimage-paths.json` to locate all10immutable preimages,
   including Core; do not edit artifacts or retry any external path. The manifest mapping
   source paths remains unchanged. This resolves the38backup-only broken links, not a
   production-document error. Primary will record an amended protected-file manifest;
   original preimages remain the code/legacy-assertion comparison authority.

Before any further production write, acknowledge the terminal result of the previously
launched legacy suite via its automatic completion notification. Do not poll or start a
duplicate suite while it runs. Record its partial-source failures/results separately;
they are not final validation. Then resume pieces2–5 within the amended exact ownership.

## Design — numbered pieces

### 1. Baseline and rejecting regressions

Inspect scripts before running checks. Add `tests/profession_expansion.lua`: standalone
Lua5.1, fresh private namespace loaded in the same eleven-module order as tests/dashboard,
plain injected environments and explicit assertions/counts, nonzero exit on failure. Do
not touch real client APIs, global math fields, live runtime collectors or SavedVariables.
Cover the cases in Tests below. Run against unchanged production first and record actual
rejecting failures; do not simulate red results. Retain the legacy512-case runner, all19
U07 workloads and both K6/K7 supplements without regrouping, lowering coverage or limits.

### 2. Registry, capabilities and guarded collection — depends on1

Add the five native-observed family/child/parent identities, expansionID11:
Herbalism4/2912/182; Mining6/2916/186; Skinning11/2917/393;
Cooking5/2908/185; Fishing10/2911/356. Cite the user evidence dates, not an invented build.
Do not hardcode observed skill/caps1/100 or1/300 as universal values.

Add `Data.Capabilities(identity)` returning a fresh plain capability table only for an
exact registered skillLineID/parentID/profession/expansionID tuple; unsupported/incoherent
identity returns nil. Keep the canonical policy private; nested maps must also be fresh.
Table fields:
`primary`, `concentration`, `knowledgeMode`, `moxieMode`, `enchantAttentionMode`,
`roles` (tool/accessory1/accessory2 booleans), `slotRoles` (eligible numeric slot→role).

| Identities | primary | concentration | knowledgeMode | moxieMode | enchantAttentionMode | Applicable roles / eligible slots |
| --- | --- | --- | --- | --- | --- | --- |
| Existing eight |true |true |enabled |enabled |enabled | All three; existing20–25 named role mapping |
| Three gatherers |true |false |pending |pending |pending | All three; primary20–25 roles, only returned slots |
| Cooking |false |false |not_applicable |pending |pending | Tool26/accessory1=27; accessory2 false |
| Fishing |false |false |not_applicable |pending |pending | Tool28 only; accessories false |

Add26/27/28 named roles to Data.slotRoles for the existing optional-metadata helper, but
use identity-specific capability.slotRoles plus actual API membership to select reads.
No mapping29/30, no ordering guesses or regular Head reads. The three primary equipment
roles are selected from the actual returned20–25 group, never hardcoded to primary1/2.

Roster: inspect first two GetProfessions results plus fourth Fishing/fifth Cooking,
ignoring third Archaeology. Preserve holes/pcall failures and presence-only semantics;
never mark the roster authoritative/complete or retire missing records. Context must
require the matching primary boolean and own learned-parent presence for that exact
family, coherent base/child registry identity, current player, shown own profession UI,
ready state, combat safety and all existing linked/guild/NPC/source-changing rejections.
For a new identity, require a usable observed child skill/cap (nonnegative skill within
a positive cap) before creating a learned Midnight row. Unavailable data blocks/retries
safely, not zero/absence/reset. Keep the original eight's collection/failure behavior.

Only request specialization config/staging when knowledgeMode is enabled or pending.
Config/staging absence is not an error for Cooking/Fishing. Same/context invalidation,
async token and equipment-instance rechecks must remain coherent across both branches.

Confirmed false capabilities emit existing `not_applicable` envelopes with no numeric
value and explicit registry/evidence provenance during a guarded scan. Skip their APIs:
all five new Concentration fields; Cooking/Fishing Knowledge index/raw/unspent;
Cooking accessory2; both Fishing accessories. For new identities, do not read inventory
for unknown/excluded API-returned slots; retain slot-index evidence, not fake gear units.
In particular, Fishing28/29/30 must only inspect rod28. An applicable role absent from
the returned mapping remains unknown, never automatically empty or N/A.

Pending modes remain unknown/unsupported with precise reason and normal last-observation
retention. Do not activate gathering Data.moxie entries, NativeKnowledgeCurrency mappings,
or D/F/P intrinsic stat keys yet. For pending gathering Knowledge, do not traverse/save
numeric graphs/totals in ordinary scans: leave raw/index/unspent unsupported and mark any
prior indexed tree attempt unknown without deleting its last observation. Full graph
evidence is acquired by piece4 only. Existing eight's Knowledge path is unchanged.
Do not overwrite `not_applicable` unspent with a later generic staging error.

Moxie is pending for all five, including secondaries: absence of a verified mapping alone
is NOT an N/A determination. Tool enchant presence may be observed normally, but do not
enable new-profession Missing-enchant attention while its applicability is pending; that
does not label the enchant itself N/A. Preserve old eight-profession warning rules.

No storage format bump, migration/reset, eviction, shared-definition/accounting rewrite,
offline API reads or mutation of historical snapshots. Storage/Knowledge stay frozen;
Core has only the three-entry metadataSlots exception above.

### 3. View model and renderer — depends on2

Keep shared columns and exact accepted geometry. Known false capabilities display `—`
with concise “Not applicable” normal tooltip; preserve diagnostic provenance under Shift.
Unknown/pending values stay `?`/existing unknown presentation. Failed reads retain coherent
known values with current stale cues. Capability-driven N/A projection may mask an old
inapplicable value for display but must not mutate saved data while building/rendering;
retain its underlying diagnostics/history. N/A is not a successful fresh numeric read,
does not increment numeric-known priority, and contributes no numeric sort key or warning.
Keep existing unknown-last sorting; never compare dash strings as numeric values.

Concentration N/A has no observed/estimate fill, recharge tooltip or estimate computation.
Knowledge N/A has no fake zero trees/aggregates. Fishing/Cooking N/A accessory cells must
clear reused icons/borders/quality/enchant/native links, and never become empty-slot cues.
An ordinary valid Tool/Accessory hover remains native/third-party-only. No new normal
Observed/Attention/diagnostics hint clutter. Keep full Shift diagnostics/assumptions.

Field-specific attention filters exclude N/A; no stale hidden value may create a warning.
Cooking/Fishing still match Skill-below-cap when an observed usable skill is below cap:
the existing Progression selector is Skill-only, not an “entire profession inapplicable”
test. Preserve filter-before-current grouping, dot, sorting inside groups, wheel/scrollbar,
range counts, row reuse, frame-coalesced repaint and observed-only prediction invariants.
Profession dropdown contains all13 families, with no automatic row for an unlearned family.
Change only the title's “observed crafting snapshots” wording to “observed profession
snapshots”; do not move the icon, change title dimensions or TOC branding.

### 4. One read-only gathering capture profile — depends on2

Reuse KnowledgeCheck.NewProfessionCaptureJob and Commands' existing knowledgecapture
scheduler, guards, cancellation, copy window and disposal; no new slash command, module,
TOC or competing runner. Three gatherers become eligible through the new registry/own
context, not a weakened guard. No-spec secondaries remain ineligible for Knowledge capture.
Commands may change explanatory/help wording to “specialization profession” only;
do not change selftest/capture clocks, limits, scheduler topology or output durability.

In KnowledgeCheck's PROFESSION_MODE capture only, add `gatheringEvidence` for exact tuples
2912/182/4,2916/186/6,2917/393/11 (expansion11). Existing eight report payload/body remain
unchanged except explicitly identified generic context-error wording if necessary.
Capture with protected reads and existing unit boundaries, no raw exception retention:
- Current child skill/cap/modifier, plus current GetCurrencyInfoForSkillLine numAvailable,
  with explicit read statuses. Existing report already includes exact build/locale/time,
  sourceCounter, staging/runtime boundaries and the full bounded Knowledge graph/currencies.
- A **candidate-only** Moxie lookup:3260 for Herbalism,3264 Mining,3265 Skinning. Expose
  this via `Data.GatheringMoxieCandidate(identity)` returning a fresh id/provenance unit
  only for these exact tuples. Reuse supplied catalogue provenance, never production
  Data.moxie. Report candidate ID, read status, sanitized name, quantity and nullable max.
- Current returned slot list (bounded16), unique verified primary tool role and equipped
  instance existence/itemID/cache status. Retain link privately only for instance checks.
  Report raw GetItemStats keys/values and the same query using Collectors.ToolStatLink's
  validated enchant-neutral payload. No payload parser change. Validate plain maps at
  most32 bounded ITEM_MOD keys with finite values; emit sanitized env[key] labels only
  as diagnostic text, never use localized labels to infer a production stat category.
- Re-read the equipped instance after queries. If it changed/unloaded, mark this evidence
  incomplete/unknown; never combine old/new item values or display a synthetic payload
  as equipped evidence. No gear changes, purchasing, learning or spending actions.

Keep local metadata completeness separate from the existing Knowledge captureComplete
flag and provisional reconciliation. Unknown optional evidence must not become PASS or
fabricated values, nor silently rewrite the meaning of the existing Knowledge flag.
Format the added header/Moxie/skill/tool units and individual stat rows through existing
bounded add/unit helpers, not a giant unbounded nested encode or slash-stack loop. Caps
remain tabs8/paths64/children16/entries32/currencies64/costs16/262144bytes/4096lines with
the existing reserve. Yield across report work and preserve frame/time/total job limits.

No DB writes, runtime Roster/Context mutations, saved observations, currency-map activation
or numeric Knowledge eligibility from a diagnostic candidate. Existing runtime tokens,
own context, equipment coherence, stable/unstaged start/end and cancellation still apply.
No character names/GUIDs, raw item links/payloads, private SavedVariables or raw exception
strings in the new exported profile. Dispose private references on every stop.

### 5. Validate, document and report — depends on3+4

Run all approved local checks below on the final exact sources. Record failures and fixes,
not just final totals. Update root/dashboard README accurately:13-family foundation and
pending native gathering fields, no claim that P01 completed all-field/native acceptance.
Give focused user instructions: ordinary own new-profession scans for new collection/UI;
one knowledgecapture report each for Herbalism, Mining and an available Skinning character,
on an own ready Midnight profession with valid config/unstaged state. Compare only new
Moxie/Knowledge/Tool observations against native UI. If blocked/incomplete, report it;
do not ask the user to train, respec, spend, swap gear or repeat accepted old checks.

Stop after local delivery. Primary freezes/reviews, persists findings and coordinates
user-run capture. A later task activates only evidence-verified mappings/accounting/stats.
No P02 task is executable merely because P01 tests pass. Platform review is inapplicable:
no workflows, IAM, hosting or release behavior change. Independent verification and local
primary acceptance remain separate from implementation; no publication authority.

## Files — one writer after approval

Allowed implementation: `CraftArmy/{Data,Collectors,ViewModel,Dashboard,KnowledgeCheck}.lua`.
Core.lua only the exact metadataSlots exception above; prove all other Core bytes intact.
`CraftArmy/Commands.lua`: only necessary capture eligibility/help/error wording; freeze
scheduler/limits/selftest runner behavior. `CraftArmy/SelfTests.lua`: only narrow original
dropdown count/list/selection, title text and generic blocked-context message expectation
adaptations necessitated above, marked P01 and enumerated in the report. Preserve all
original scenarios; unrelated old-test failures require primary review, not broad edits.
The three exact original registry-list/count/exclusion blocks listed in the primary
amendment above are also authorized; no broader legacy-test rewrite.
New regressions belong in **new** `tests/profession_expansion.lua`, not new top-level cases
that exceed the512 safety bound. New fixture runner is an additional local suite, not a
claim of new in-client fixture execution. `tests/dashboard.lua` remains frozen.

Allowed docs: root `README.md`, `docs/dashboard/README.md`; TASKS execution boxes/run-state/
report only. Primary owns PLAN, AGENTS, this contract, audit/Q threads, archives and review
records; do not edit them. No other files. All remaining Core bytes, Storage, Knowledge, Details, diagnostic
addon/evidence, TOCs, existing runners/tools, media/assets/manifest and agent definition
are read-only. Escalate any perceived need to change a frozen file.

Original nine-file pre-writer SHA256 comparison base (Core's additional hash is above):
```text
7e889a35cf485041c6c127a408792a3b1c5982bf96cd3d05c39b26f8fabc419f CraftArmy/Data.lua
b716d27c799aa30e12c281ff09b35aa6395705273d306cc229ee06bd56742023 CraftArmy/Collectors.lua
22a612e22f3b2afab9ce2440e157c030a5810532b3acbedbcb404874cb8deb59 CraftArmy/ViewModel.lua
9a217542746bd1fd53128167a76186e78a05b8b110c23c9bdf62362d8cfe744e CraftArmy/Dashboard.lua
9d004416860fb09405cbe031847eacc9a55c7067b6eca056d3f63d27c23574b6 CraftArmy/KnowledgeCheck.lua
43a3dca252696d5f596727133028ddc96804bac82b8331d03fad6b84aba4d707 CraftArmy/Commands.lua
760fa8a0eabcd4a0f48f69e5957b74f42c8b39849fc7a263be4b27cdec43224b CraftArmy/SelfTests.lua
7ec2c6ae4b112f52d71ce4c38c68e1f061532f4a8f34538cc884b7533f16d605 docs/dashboard/README.md
dacf53044831db59455c79bfd3c9f6d067b7549fc471bae4acd0e8823e742a58 README.md
```

## Tests and acceptance criteria

New additive fixtures must reject unchanged production and cover:
- All5 identities, conflicting tuple/unknown family/older expansion rejection, immutable
  capability results, exact defaults for the old8 and no production gathering map activation.
- Learned primary2 plus Fishing/Cooking4th/5th roster results, holes/failures, wrong primary
  flag, missing parent/usable cap, linked/guild/NPC/changing/unready/combat rejection;
  no orphan/unlearned rows, authoritative-absence inference or automatic retirement.
- Cooking/Fishing scan success with no specialization config/staging requirement; confirmed
  N/A APIs skipped, applicable absent roles unknown, Fishing28/29/30 reads28 only, no Head.
- Gathering pending currency/Knowledge/stat values stay unknown; old values/times/indexed
  trees survive failed attempts. Exercise schema1 and schema2 handles without migration.
- N/A labels and clean normal/complete Shift tooltips, no false numeric sorts/attention,
  Skill-only filter inclusion for nonmax secondary skills, reusable widget decorations
  cleared, existing13-family filtering/current grouping/scroll/range/prediction semantics.
- Gatherer metadata/candidate Moxie/total-vs-neutral stat reporting, no fake mappings,
  unsafe/changed/staged contexts, changed gear/nil/error/oversize/malformed API responses,
  clipping/completeness labels, async cancellation/reentrancy and zero live-DB writes.
- Mixed eight/new professions over46/100/200characters with at most two learned primaries
  plus Cooking/Fishing per character; no new count cap or silent eviction. Retain old19
  workloads independently; do not substitute smaller samples for the full suites.

Approved commands after script inspection (installed Lua5.1 only; no dependency installs):
```sh
lua5.1 tests/profession_expansion.lua
lua5.1 tests/dashboard.lua
lua5.1 tests/run.lua
python3 tools/check_dashboard.py
python3 tools/check_diagnostics.py
git diff --check
```
Also verify exact owned-path inventory, final hashes and protected-path equality against
the actual pre-writer snapshot. All9original/packaged icon pairs remain hash-identical.
Latest recorded baseline512/all19/744K6/565K7/23/Python passed; no new baseline run claimed
by this planning document. Full native suite remains INCOMPLETE87/149; all-rank costs and
quantified offline estimate accuracy remain unverified, not blanket P01 blockers.

## Out of scope

No guide/Details expansion, purchases/crafts/learning/spending, Lua installs, game addon
installation, private data reads, external services, schema changes/reset/history eviction,
fixed character caps, other expansions/Archaeology, guessed stat/enchant/Knowledge/Moxie
mappings, in-client timing chase, raised limits, blanket native acceptance, archive cleanup,
git add/commit/branch/push/tag/merge/release/workflows/deployment. No parallel writers.

## Report back

Update TASKS at each stop: piece statuses, what changed, actual red/green commands/counts,
all19 workload completions, K6/K7/diagnostic counts, baseline failures/fixes, exact changed
paths/final hashes, each authorized legacy assertion adaptation and original-byte retention
proof, protected-file comparison, native evidence still pending and exact resume point.
Do not dump thousands of log lines into TASKS; concise results plus explicit evidence
artifact paths suffice. Failed/incomplete/skipped results stay distinct from PASS.

Return the full agent-handoff envelope: Status, Task, Summary, Durable updates, Validation,
Blockers or open questions, Next action. No independent/native/release proof inferred from
implementation. Primary persists review evidence before acceptance or a follow-on task.
