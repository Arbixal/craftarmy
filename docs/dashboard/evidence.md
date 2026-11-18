# T02 dashboard evidence — 0.2.0-mvp

Current U04 gate (2026-11-10): numeric/wider/flat bars and hierarchicaltooltip delivered;
primary local220/220+744/565+23/23 and independent scopedstaticreview PASS/no blockers.
User “Oh yeah, that looks a lot better”: U04appearance accepted/scopediteration complete;
no further U04update/retest or recollection/fullclientselftest requested.
U03userreportsvaluesmatch and responsiveDetailsrefresh/noerrors/executionwarnings;
closedcontext+reloadDetailscachepreservation confirmed, onlyexpectedrelativeagechanges.
FocusedU03reported-scopevalidation COMPLETE; no furtherround/update/retest requested.
V01 and historical fullsuite context follows:

Current gate: latestuser **INCOMPLETE87passed/0failedof149**, case88unit2
134.4ms/wall77323.9ms;62casesuncompleted. User approves local full stress suites plus
focused WoW normal-use/API/snapshot checks instead of further full-suite timing chase.
V01 Round1: user reports0/270,50/70,214/270,0/260 all native-matching, responsive game,
working but verbose/debug-heavy tooltips. Follow-up confirms Unspent KP0/native match
and no normal-use errors. Round2 values/Unspent KP intact, Last Updated unchanged;
Round3 all data/Last Updated persisted as expected. V01 three-round sequence COMPLETE
for reported scope on this character; no further V01 retest or broad acceptance.
Historical full-completion-before-bars gates below are superseded, not erased.
Primary has settled34's discovered shared-alias preflight gap: alias-preserving bounded
temporary clone, simulate exact character replacement, then unchanged Core.Copy budget
before real commit. No alias rejection/key omission/eviction or larger limits.33 already
delivered;34–35 resumed READY. Historical partial blocker/freeze remains below.
Corrections33–35 are now delivered, awaiting independent re-review of the final96-case
freeze; prior review findings are not cleared by delivery alone. Primary generated
workspace `docs/dashboard/k2-review.diff` from exact original K1 bytes for review.

Status: **PARTIAL**. K1 knowledgecheck delivered, independent static review **PASS**;
user66-case suite **66 passed/0 failed**; native complete35-path report/copy received
and reviewed for this capture. All-rank costs/production numeric eligibility still open.
Corrected R6a user fixtures
**50/50 PASS** remain historical, not the new suite's execution.
Historical R6 49/50 failure retained; fixture gate now clears for this user execution.
User has accepted the table pass for the supplied cases; current work is exact
Inscription knowledge-accounting investigation, not further visual iteration.
Native R6 two-row table supplied; user reports no errors and dropdown appears to
work, accepted for this ordinary case only. Prior R5 user46/46 and supplied native one-/two-row/Tool checks remain
historical scoped PASS, not R6 validation. Remaining native edge/data gates pending. Prior R4 40/40 and separate
diagnostic23/23 remain historical scoped evidence. Historical R3 failure retained.
Standalone Lua remains NOT RUN; limited Inscription live display/field agreement,
reload retention and two-character separation are user-observed. Broader live/field
validation remains INCOMPLETE. Earlier sections are historical;
the final primary review entry below is the current controlled-test gate.
Diagnostic 0.1.1 is an immutable baseline; historical 23/23 is not T02 execution.

## Source pin and exact read scope

Read-only upstream source inspected 2026-11-05 at Gethe revision
[`297d7aaaa736f346b3e036f38ee088eaf7f8c07f`](https://github.com/Gethe/wow-ui-source/commit/297d7aaaa736f346b3e036f38ee088eaf7f8c07f)
(12.1.5 / 70783). Paths below are under `Interface/AddOns/` at that revision.
Reads used Python stdlib `urllib.request.urlopen` against raw GitHub and the pinned
recursive tree API, decoded in memory, printing matching source lines. No source
files, runtimes or dependencies downloaded into the workspace. This is source
evidence, not execution on the target client. Four guessed documentation paths
returned HTTP 404 (TradeSkillInfo, Professions, SharedTraitsTypes,
ProfessionSpecUITypes); none were treated as an API contract.

| Field | Pinned source/signature | Interpretation / gate |
| --- | --- | --- |
| Families | `Blizzard_APIDocumentationGenerated/ProfessionConstantsDocumentation.lua:232–253` | enum 1/2/3/7/8/9/12/13 names verified; eight-family registry is not eight-profession runtime acceptance |
| Expansion | `ExpansionLevelConstantsDocumentation.lua:24` Midnight=11; T01 user evidence in [diagnostic matrix](../diagnostics/evidence.md) | Only skill line 2913/parent773/enum13 mapped. Other IDs explicitly pending, no range/name/cap heuristic |
| Identity/skill | `TradeSkillUIDocumentation.lua` GetChildProfessionInfo(), GetBaseProfessionInfo(); `TradeSkillUITypesDocumentation.lua:361–376` ProfessionInfo | Read skillLevel/maxSkillLevel/skillModifier separately; sourceCounter checked at both boundaries |
| Own context | `Blizzard_ProfessionsTemplates/Blizzard_Professions.lua:274–279,370–375,1616–1626`; `Blizzard_Professions/Blizzard_ProfessionsFrame.lua:120,215–220` | IsTradeSkillReady true; linked/guild/guildMember/NPC/changing explicitly false; visible frame and learned-primary presence required; unavailable API fails closed |
| Roster | `Blizzard_ProfessionsBook/Blizzard_ProfessionsBook.lua:58–63,387` GetProfessions() first two indices; GetProfessionInfo(index) seventh result skillLine | Presence only. Authoritative absence/readiness contract unproven; no automatic unlearning in production; manual retirement available |
| Equipment role | `Blizzard_Professions/Blizzard_ProfessionsCrafting.xml:245–298`; `Blizzard_ProfessionsCrafting.lua:1051–1064` | Named Prof0/1ToolSlot 20/23; Gear0 21/24; Gear1 22/25. Only apply to returned profession slot membership; never sorted index position. Accessory #1 is Gear0, #2 Gear1, presentation order independent |
| Item instance | `ItemDocumentation.lua` DoesItemExist(location), GetItemLink(location), GetItemID(location), GetItemQuality(location), GetItemIcon(location), IsItemDataCached(location); `Blizzard_ObjectAPI/Mainline/ItemLocation.lua` CreateFromEquipmentSlot | False existence only at a verified location is empty. Unloaded/replaced instance replaces unit, no old stats/enchant carried across |
| Crafted rank | `TradeSkillUIDocumentation.lua:319–345` GetItemCraftedQualityByItemInfo(itemInfo), GetItemCraftedQualityInfo(itemInfo) | Instance link input. Rank1–5 separate from rarity/item level; explicit text fallback, no invented atlas |
| Stats/enchant | Item GetItemStats(link); TooltipInfo GetInventoryItem("player",slot), TooltipDataLineType.ItemEnchantmentPermanent | Preserve numeric ITEM_MOD keys. Observed total explicitly attribution unknown, no bonus subtraction/addition. Valid link zero field supports absence; positive typed line plus zero conflicts. 8005 category only from T01 user evidence |
| Currencies | GetConcentrationCurrencyID(skillLineID), C_CurrencyInfo.GetCurrencyInfo(currencyID) | Dynamic concentration ID; maxQuantity nullable. Recharge evidence retained, not projected. Only Moxie2913→3261 seeded, no balances |
| Paths | `ProfessionSpecUIDocumentation.lua` GetConfigIDForSkillLine, GetSpecTabIDsForSkillLine, GetTabInfo(tab), GetRootPathForTab(tab), GetChildrenForPath(path), GetUnlockEntryForPath(path) | 8 tabs/64 paths/16 children; all roots/locked children traversed once. Missing/cycles/limits invalidate coverage |
| Ranks | `SharedTraitsDocumentation.lua:1008–1040` GetNodeInfo(configID,nodeID), GetEntryInfo(configID,entryID) | Raw purchased/increased/current/max and exact unlock entry maxRanks retained; missing entry never zero |
| KP eligibility | `Blizzard_Professions/Blizzard_ProfessionsSpecializationsTemplates.lua:315–335`; `SharedTraitsDocumentation.lua:307–320,953–959` GetNodeCost(configID,nodeID)→{ID,amount}[] | Display excludes observed unlock maxRanks0/1, but current node cost does **not** establish all-rank unit-spend cost semantics. Production costRule remains unknown; numeric aggregates field-blocked. Pure verified-rule fixtures are not API evidence |
| Unspent/shared | GetCurrencyInfoForSkillLine→numAvailable (`ProfessionSpecConstantsDocumentation.lua:86–92`); GetTreeCurrencyInfo(configID,treeID,true) | Zero unspent valid. Raw trait currencies per tab retained; no summed shared spent. Pure engine reconciles one profession shared-spent value only with explicit applicability evidence; production applicability pending |
| Staging | ConfigHasStagedChanges(configID) (`SharedTraitsDocumentation.lua:107–119`) | Must be explicitly false both boundaries; trait/config events invalidate same-scan tokens |
| Async | RequestLoadItemData(itemLocation) (`ItemDocumentation.lua:1663–1670`); ITEM_DATA_LOAD_RESULT(itemID,success) `1817–1825` | ≤16 unique requests/scan, one completion retry/item, one 5s timeout; full GUID/profession/generation/revision/slot/link match; no polling |

### Event contracts

TradeSkillUIDocumentation: TRADE_SKILL_SHOW, CLOSE, DATA_SOURCE_CHANGING,
DATA_SOURCE_CHANGED, LIST_UPDATE (no payload used). CurrencyInfoDocumentation:
CURRENCY_DISPLAY_UPDATE(currencyType?,quantity?,quantityChange?,quantityGainSource?,destroyReason?)
(payload ignored). SharedTraitsDocumentation: TRAIT_CONFIG_UPDATED(configID),
TRAIT_NODE_CHANGED(nodeID), TRAIT_NODE_CHANGED_PARTIAL(ID,info),
TRAIT_NODE_ENTRY_UPDATED(nodeEntryID), TRAIT_TREE_CURRENCY_INFO_UPDATED(treeID)
(payloads ignored). Item load payload above. PaperDollFrame.lua:329,1580–1583 verifies
PLAYER_EQUIPMENT_CHANGED(equipmentSlot,hasCurrent) (ignored). PlayerFrame.lua:59–60
verifies PLAYER_REGEN_DISABLED/ENABLED (no payload used). PLAYER_LOGIN initialization
uses `Blizzard_SharedXML/EventUtil.lua:83`
`EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_LOGIN", callback)` (no payload
used).
All change callbacks invalidate/coalesce, never open/switch professions or mutate UI.

## Validation and delivery log

- Baseline `python3 tools/check_diagnostics.py`: PASS, exit0 (script read first).
- `command -v lua5.1 || true`: no path. Approved Lua commands NOT RUN (absent runtime).
- `/ca selftest`, `/cad selftest`, WoW load, collection, UI, persistence, async races,
  multi-alt and all live comparisons: NOT RUN by agent. User-only after static review.

Final inspected local commands (2026-11-05):

```text
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated

python3 tools/check_dashboard.py
PASS: 14 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 70 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
```

Each command exited0. Both Python scripts inspected before execution: stdlib,
read-only file inspection; no addon execution/network/writes. The new checker also
checks all nonhidden Markdown local links/anchors and the latest eight diagnostic
hashes from the retained R1 evidence list. Earlier in-progress output counted24
Markdown files including a skipped hidden file; final checker counts23 actually
inspected nonhidden documents. No baseline failures were found. No Git repo or
comparison revision exists; manifest files were all absent before this run.

Runtime gate discovery/check command:

```sh
if command -v lua5.1 >/dev/null 2>&1; then
  lua5.1 tests/run.lua
  lua5.1 tests/dashboard.lua
else
  printf '%s\n' 'NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH'
fi
```

Output was the NOT RUN line; neither Lua command executed. No package install,
runtime download, alternate runtime, Lua compiler/linter or live WoW test was used.
No claim of Lua syntax correctness, fixture success or target API correctness.

Read-only fixture-count command (exit0):

```sh
python3 - <<'PY'
from pathlib import Path
import re
print('Shared dashboard fixture definitions:',len(re.findall(r'^case\(',Path('CraftArmy/SelfTests.lua').read_text(),re.M)))
print('Production files:',len(list(Path('CraftArmy').glob('*'))))
PY
```

Output: `Shared dashboard fixture definitions: 27`, `Production files: 9`.
Counting definitions is not executing them.

## Regression coverage (definitions, NOT RUN)

27 shared cases include table-driven subcases. They use isolated DBs, synthetic IDs,
injected player-only API spies, fake native widgets/timers and forbidden-action
sentinels. `/ca selftest` calls the same runner as `tests/dashboard.lua`; it never
passes the real DB/API environment to the fixtures.

- Zero/false vs nil/error, attempt vs success time, malformed/future DB, invalid
  times/generations, cycles/metatables/functions/nonfinite values, GUID separation.
- Explicit empty vs unloaded, all rarity2/3/4 × crafted ranks1–5, unknown rank/role,
  changed equipped instance invalidation, late callbacks, closed/switch/trait races,
  linked/guild/NPC/changing/unready/missing API/combat guards.
- Zero/present/unmapped/conflicting/unready enchant;8005 category no amount/rank;
  multiple stats retained as observed totals without base/enchant arithmetic.
- Mixed unlock0/1, locked zero, whole subtrees, max spend, unknown unlock/cost,
  increased/free/staged/unknown inputs, cycles/duplicate/shared paths, late roots,
  four-tab35-path shape, children/path/tab limits and malformed/incomplete lists.
- Shared spent reconciled once, absent/mismatched shared spent, separate zero/missing
  unspent, independent trees, and last-coherent aggregate/index retained on failures.
- Moxie599/600/601; concentration899/900/1000 against verified1000 plus missing/zero/
  negative caps; fresh vs historical warning labels; stale preservation; sorting,
  filters, archive isolation; concentration never projected.
- Exact Accessory #1→Accessory #2→Tool columns; distinct inline tool stats/enchant;
  Unspent KP; 12 reusable22px UI rows with14px inline bars, unknown fill hidden;
  scoped confirm/cancel/retire/delete, immutable archive/relearn new generation.
- Event coalescing, request16 limit, one request/ID, one retry/ID,5s timeout, no
  polling loop; commands/rendering use fake widgets and never gameplay mutations.

## Acceptance gaps and precise resume inputs

| Gate | Current result | Owner / resume action |
| --- | --- | --- |
| Delivery | 14 new files delivered, T02 state updated | Primary freezes exact hashes below for independent review |
| Independent review | NOT RUN / INCOMPLETE | Primary dispatches read-only verifier; source/fixtures need review before client use |
| Lua syntax/fixtures | NOT RUN / INCOMPLETE | User `/ca selftest` and separate `/cad selftest`; no historical23/23 carryover |
| Inscription requested KP totals | FIELD-BLOCKED / CHANGES REQUIRED for numeric feature completion | Source-verified all-rank spend entry/currency costs, committed purchased semantics excluding unlock/free ranks, per-path observed unlock maxRanks0/1, complete same-scan data, shared-currency applicability and native UI comparison. Current GetNodeCost result alone is insufficient. Production never asserts unit eligibility |
| Other seven Midnight identities | FIELD-BLOCKED | Pinned authoritative expansion skillLine→parent/enum/expansion mappings needed; discovery explains pending IDs, never treats names/ranges/caps as Midnight |
| Automatic unlearning | FIELD-BLOCKED | Authoritative complete roster/absence readiness contract needed. Current login roster establishes presence only, no auto archival; manual retirement works by explicit scope |
| Base-tool vs enchant stat amounts | FIELD-BLOCKED | Exact API attribution evidence needed. Observed totals marked `*`, enchant category separate; no double count. Enchant8005 category is known, amount/rank not known |
| Async readiness | Static/injected only, NOT RUN | User observes existing slow-load case; missing initial link cannot be matched to a later different link, so that completion is discarded and manual refresh required. Nil link is not an empty item |
| Native layout/tooltips | NOT RUN | User confirms single-line density, scaling, scrolling and tooltip overflow. Large raw KP tooltips may overflow; no acceptance inferred from fake widgets |
| Persistence/multi-alt/lifecycle | Fixture definitions only, NOT RUN | User reload/relog and available alt checks; lifecycle boundaries can remain honestly fixture-only if unavailable without gameplay changes |
| Eight-profession product, guides, Q03/Q04 | INCOMPLETE / outside T02 completion | No broad feasibility closure or guide/inventory/bank/Auctionator work |
| Release/publication | NOT AUTHORIZED | Separate explicit approval required; no Git/install/release performed |

### Implementation limitations

No real addon-load, slash-command, frame rendering, event/API, async, roster,
timestamp persistence or offline-alt behavior has been run for T02. Unknown expansion
IDs intentionally cannot create attributed rows. Unknown unit-cost semantics
intentionally prevent production numeric knowledge bars, even where ranks look
plausible. Role evidence comes from pinned named slot XML membership, not display
order; target-client role comparison still required. Concentration is last observed,
not regenerated. Bounded schema traversal can disable further writes on oversized
data rather than evict any character/archive; recovery is backup/report, not reset.

Next owner: **primary**, independent static review of the frozen manifest and these
limitations, then coordinate the user-only [manual checklist](README.md). Numeric KP
and other field blockers remain unresolved until exact source/client evidence is
recorded and a reviewed eligibility/mapping follow-up is approved.

See [schema](schema.md) and [manual guide](README.md). File hashes follow; this
document's final hash is recorded in T02's TASKS.md delivery entry to avoid self-hashing.

## Frozen delivery hashes

Exact read-only command, exit0:

```sh
sha256sum CraftArmy/CraftArmy.toc CraftArmy/Core.lua CraftArmy/Data.lua CraftArmy/Knowledge.lua CraftArmy/Collectors.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/SelfTests.lua CraftArmy/Commands.lua tests/dashboard.lua tools/check_dashboard.py docs/dashboard/README.md docs/dashboard/schema.md
```

```text
5f0ba92ce9aac13edcece96e4a063c7ea3344667ceba85b56a028640f42daa1b  CraftArmy/CraftArmy.toc
e891c553ae44465d5a2c1c27a1e38021e182af44dff422abc623fd04151b533c  CraftArmy/Core.lua
7168a17322fbc9de3033b5135e6c23db4394891988f1f4537dadad4fb62bcb4f  CraftArmy/Data.lua
1bf9930ea8272e46b6147ba96afcb16467a915d1a10e5295a68db1f2a9f9c4e0  CraftArmy/Knowledge.lua
a7de9e0701aff297c62ed54233f3be806b5259270f3899ac53e4e0c36ade2196  CraftArmy/Collectors.lua
07541cb7f05e7e00fce0f5e3f8273f683fc8e396415f47974f39d34bc378d0a5  CraftArmy/ViewModel.lua
1fb20da97ba6a3da9f31ff6d2cb98f6ead52e9063dd24379b68c5b7f4cc0eff5  CraftArmy/Dashboard.lua
24a1dace2b2495b0bcdc69f59b87e8e9b430ac5c059b0cc75caa542aacd384ee  CraftArmy/SelfTests.lua
b436b0e56cb605b5dfba85ebc95da9f94abd7fdeecf8141bc30dedbbc751652d  CraftArmy/Commands.lua
75a65ba61fa53c2b8f681196e64e059c7640c3d0c0a00c31b55f6156c55897a0  tests/dashboard.lua
0b6da6c9887df3aec68744bc37eeb76809345d5c149ba11ee3a6be5ab9d7ce6a  tools/check_dashboard.py
ca0a9a495022e367fd5e2f940bd385bfb13df1509be1e767fb2eccb46c9b9ef7  docs/dashboard/README.md
e0c91c344430bbd1d11acf8e08d1ced5595e78479a1f16d63608bd59a2cc5e64  docs/dashboard/schema.md
```

No primary-owned planning/agent/question files, T01 implementation/history or
diagnostic samples were edited. TASKS.md changes are confined to T02 execution state
and this delivery report. No commits, publication, deployment or release occurred.

## Initial independent review — 2026-11-05

Reviewed freeze: all 13 hashes above and this document's original SHA256
`fcd4a2a01e7e09b8edfc37ff364fbbea41abed624748cc3bf479c80d7b5440de`.
Verifier inspected all 14 files and selected pinned signatures/XML; static review
finished but execution/hash checks were permission-denied and NOT RUN by verifier.
No alternate execution route used. Handoff PARTIAL; review **CHANGES REQUIRED**,
runtime/field acceptance **INCOMPLETE**. Primary persists this report.

1. **Medium:** same-item metadata failures (`Collectors.lua:147–180,265`) replace
   prior known gear stats/rarity/rank with empty/unknown values as fresh. Error fixture
   at `SelfTests.lua:205–214` does not test preservation. Require original successful
   values/time plus failed attempt/stale status, without copying metadata to new items.
2. **Medium:** schema validation (`Core.lua:69–85,120–147`) accepts wrong field payload
   shapes/identity labels; `skill.last.value=true` can crash `ViewModel.lua:138`.
   Require typed load/write validation, invalid existing DB untouched/writes disabled,
   safe disabled-data UI and atomic rejection of malformed incoming scans.

Primary separately reran inspected Python diagnostics/dashboard checks (PASS exit0,
23 docs/70 links/eight diagnostic hashes unchanged) and matched all 13 delivery hashes
plus original evidence hash. Primary found no lua5.1; Lua/client checks NOT RUN.
Do not attribute these executions to the verifier. Platform review not applicable
(local addon only, no infrastructure/workflow/release changes).

T02 correction pieces 9–11 are READY within the same user-approved manifest; one
implementer corrects these existing-contract defects and adds regression assertions,
then freezes a new revision for review. Original source hashes/evidence above remain
historical. Client testing recommendation is deferred until correction/re-review.

## T02 R1 correctness delivery — 2026-11-05

**PARTIAL**, correction pieces9–11 delivered for independent re-review. This append
supersedes the initial source freeze for implementation review, **not** the original
hashes, primary review findings or validation history. The original evidence hash
`fcd4a2a01e7e09b8edfc37ff364fbbea41abed624748cc3bf479c80d7b5440de` remains historical.
No acceptance is asserted by the implementer; all client/runtime gates remain open.

### Corrections and regression scope

- Finding1: `Collectors:Gear` now records nil/error/unsupported (and malformed)
  required metadata as a failed unit attempt. Stats are not replaced by a fabricated
  empty map. Rarity/rank, icon/quality and stat failures remain explicit. Existing
  cache/timeout handling also uses failed attempts. `Core.Apply` preserves an older
  **whole** successful unit and timestamp only for equal positive item ID, exact
  valid instance link and slot within that same active GUID/profession generation.
  Changed/removed/unidentifiable equipment clears old dependent metadata; current
  partial existence evidence can remain, never borrowed old-item stats/enchant.
- Finding2: shared registered-field validators now gate active **and** archived load
  data and pre-commit writes: skill, currencies, equipment/dynamic slot keys, slots,
  knowledge index, raw tabs/paths/nodes/children/unlock/cost/currency evidence, complete
  tree/dynamic tree keys, environment and labels. Unknown field keys are rejected.
  Bounded dense lists, matching IDs, typed stat/enchant/quality/tooltip values and
  coherent numeric tree sums are checked. Raw unknown metadata stays absent rather
  than zero; shape checks do not grant production unit-cost eligibility.
- Malformed scans are rejected atomically. Generic primitive `Core.Merge` still
  preserves zero/false; production fields require their own proper type. Invalid
  saved globals remain unchanged, with writes disabled and no attributed rows.
  ViewModel validates at its rendering boundary; native refresh/confirmation and
  collection fail closed with a visible explanation, not a DB reset.
- Same schema1, version0.2.0-mvp, manifest/file order, native single-line UI layout
  and source-evidenced mappings; no new APIs/events or architecture. Dashboard edits
  are only validation/error-path plumbing for finding2. No diagnostics/T01, primary
  review entry or other planning docs changed.

The shared suite now has **32 fixture definitions** (initial27 plus5 R1 cases with
table-driven subcases). **NOT RUN**; a definition count is not execution evidence.

1. Same-instance success→nil/error/unsupported for stats, rarity and rank (9
   combinations): assert both actual stat values, actual rarity/rank/enchant,
   successful time100, attempt time120/status/reason and nonfresh/stale presentation.
2. Changed item/removal/missing link/missing item ID/missing location: assert old
   metadata cannot survive onto a new/unidentified item. Existing late-callback and
   timeout cases now assert coherent retention/time/staleness, not an overwritten
   error-status field masquerading as preservation.
3. Malformed registered payload matrix across active and archive generations:
   booleans/strings/wrong nested shapes in skill, currencies, tool/slot evidence,
   stats/enchant/quality/tooltip lines, index/tree/raw tab/path/node/unlock/currencies
   and environment. Assert invalid open, unchanged DB, empty safe view and explanation.
4. Same matrix as incoming scans plus malformed dynamic/unregistered keys: assert
   atomic rejection with deep structural equality before/after.
5. Active/archive profession labels, character labels, incoming identity labels;
   legitimate zero/false positions; invalid-data native UI path using fake widgets,
   no saved-global mutation, no rendered rows and visible writes-disabled reason.

Original fixtures were adapted to valid typed production shapes (real synthetic
currency IDs/complete skill and tree payloads) rather than using arbitrary fields as
a schema bypass. Generic false-value coverage remains separate from production
field validation; negative caps now assert rejection instead of a typed saved value.

### R1 implementer validation

Scripts/runners inspected before checks: both Python tools are unchanged read-only
stdlib structure/docs/hash inspection; the Lua runners load only the shared addon
modules/isolated fixtures. No installs, alternate runtimes, compiler/linter, downloads,
game actions, other-addon calls, Git or release operations.

```text
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated

python3 tools/check_dashboard.py
PASS: 14 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 70 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
```

Both exited0, run by **implementer** for R1. These are not verifier/primary executions.
No structural baseline failures. Existing diagnostic source/test/README hashes still
match all eight retained reviewed hashes. No claim of Lua syntax/fixture/API behavior.

```sh
if command -v lua5.1 >/dev/null 2>&1; then
  lua5.1 tests/run.lua
  lua5.1 tests/dashboard.lua
else
  printf '%s\n' 'NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH'
fi
```

Output: `NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH`.
Neither Lua command executed. `/ca selftest`, `/cad selftest`, addon/native UI load,
target API behavior, persistence/multi-alt, async races and every live comparison are
**NOT RUN** by the implementer. Historical diagnostic23/23 still proves nothing about R1.

Read-only count command, exit0:

```sh
python3 - <<'PY'
from pathlib import Path
import re
print('Shared dashboard fixture definitions:',len(re.findall(r'^case\(',Path('CraftArmy/SelfTests.lua').read_text(),re.M)))
PY
```

Output: `Shared dashboard fixture definitions: 32`.

### Remaining gates and exact resume point

**Primary** must independently re-review this corrected freeze against the two
findings and the added fixture assertions, preserving attribution and recording
acceptance separately. Only after satisfactory re-review coordinate user-only README
checks; no install recommendation or release is made here. Numeric KP all-rank cost
eligibility, other seven Midnight maps, authoritative roster absence/unlearning,
base/enchant stat attribution and all original client evidence gaps remain unchanged.
Safe unknowns still do not complete those fields. No new API facts were researched or
inferred by these regression corrections. Corrected source hashes follow; the final
current evidence hash is recorded only in T02's R1 delivery entry in TASKS.md.

### R1 current source hashes

Exact read-only command (exit0):

```sh
sha256sum CraftArmy/CraftArmy.toc CraftArmy/Core.lua CraftArmy/Data.lua CraftArmy/Knowledge.lua CraftArmy/Collectors.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/SelfTests.lua CraftArmy/Commands.lua tests/dashboard.lua tools/check_dashboard.py docs/dashboard/README.md docs/dashboard/schema.md
```

```text
5f0ba92ce9aac13edcece96e4a063c7ea3344667ceba85b56a028640f42daa1b  CraftArmy/CraftArmy.toc
27f2960ac0641a8cc73b4404afd112552fd9bbb99eab33d0370a9fcb6c1651a4  CraftArmy/Core.lua
7168a17322fbc9de3033b5135e6c23db4394891988f1f4537dadad4fb62bcb4f  CraftArmy/Data.lua
1bf9930ea8272e46b6147ba96afcb16467a915d1a10e5295a68db1f2a9f9c4e0  CraftArmy/Knowledge.lua
248e0890543405f4a9672f64d6f710a08cee94042d9cacc06046193bfcd50074  CraftArmy/Collectors.lua
956eed011161f55aee24ae629b263c4a8d6e265dc8db67b18c3d6519d976aa0e  CraftArmy/ViewModel.lua
6cf1889f1369f25b4aeb58a3092b44e9eda262b89d1623f3fab61727506275dc  CraftArmy/Dashboard.lua
07e430ed6ebeacafe12648bec3160e9d56ca66ed87f8e33d3759df072b15e26f  CraftArmy/SelfTests.lua
b436b0e56cb605b5dfba85ebc95da9f94abd7fdeecf8141bc30dedbbc751652d  CraftArmy/Commands.lua
75a65ba61fa53c2b8f681196e64e059c7640c3d0c0a00c31b55f6156c55897a0  tests/dashboard.lua
0b6da6c9887df3aec68744bc37eeb76809345d5c149ba11ee3a6be5ab9d7ce6a  tools/check_dashboard.py
6e8c1e3ae95231e78583151ebe75fb063ef7871a028698b3c07cf5aa317f7d7b  docs/dashboard/README.md
a92dfdd319a390c7b4ccdfad2e139a1a379c36587a9041333210d7c6c3745f79  docs/dashboard/schema.md
```

R1 changed eight existing manifest files: Core, Collectors, ViewModel, Dashboard,
SelfTests, README, schema and this evidence document, plus only T02 execution-state/
delivery entries in TASKS.md. The other six manifest files are unchanged. No new file,
schema/version bump, source API/mapping change or permission expansion. Original
delivery/hash sections and primary initial-review entries remain intact above.

## R1 independent re-review — 2026-11-05

Reviewed freeze: latest 13 R1 source hashes above plus original R1 evidence hash
`b55715e482d9fe72b1c8116ded9f3992ac564dc13da1e96f7c76a6b3c9db7b2e`.
Original two reported scenarios are resolved in static inspection, including added
preservation/time/stale assertions and typed atomic validation/disabled UI negatives.
32 fixture definitions remain NOT RUN. Verifier shell/hash execution denied again;
no alternate route. Primary separately matched the R1 freeze and ran both Python
checks PASS exit0, 23 docs/70 links/eight diagnostic hashes unchanged.

**CHANGES REQUIRED:** medium async-freshness defect at `Collectors.lua:350–351,
383–397`: successful ItemResult commits observed gear but omits the corresponding
session freshness flag, so confirmed missing-enchant warnings remain historical.
Existing async case (`SelfTests.lua:313–327`) asserts rank recovery but not freshness.
Require promoting only successful retry fields after successful apply with matching
GUID/profession/generation token, preserving unrelated freshness. Failed/invalidated/
late callbacks must not restore freshness; add view/warning assertions.

Primary persisted report before READY scoped R2 correction pieces 12–13. Same
14-file manifest/permissions, no new APIs or architecture. Review handoff PARTIAL,
runtime/feature acceptance INCOMPLETE; other semantic gates and platform-review
non-applicability unchanged. User client-test recommendation remains deferred.

## T02 R2 async freshness correction — 2026-11-05

**PARTIAL** for focused re-review/client validation. Scoped pieces12–13 correct the
reported retry freshness defect; no new file, architecture, API/event/mapping,
schema/version or permission. Changed code only in `Collectors.lua` and shared
`SelfTests.lua`, plus this evidence append and T02 execution-state/delivery entries.
README/schema and the other original manifest files are unchanged from R1. Original
and R1 delivery hashes, initial review and R1 re-review entries remain intact above.
The historical R1 evidence hash is not the hash of this appended document.

### Implementation and fixture coverage

- `ItemResult` first validates its token before changing freshness. For the matching
  GUID/profession/generation session, only affected pending fields are cleared before
  a retry. Failed events, mismatched reads, failed retry statuses and failed commits
  cannot retain an affected flag or promote one; unrelated flags are not replaced.
- A retry can promote only its `observed` fields **after** `Core.Apply` returns a
  matching generation and the context/token is revalidated after the commit. It
  reuses the matching current session, never creates/restores a session from an old
  token. Invalidated/late/duplicate completions cannot restore freshness.
- Timeouts clear only affected flags under a valid token. A consumed completion's
  old timeout cannot demote it. Valid callback paths notify the view, including a
  mismatch with no commit. No timer/request/event signatures or bounds changed.

The shared suite now has **34 definitions**: the prior async case was strengthened
and two R2 table-driven cases added. All are injected fixtures, **NOT RUN**; these
assertions are not target-client API behavior evidence.

- Positive completion: recovered rank **and** matching session generation, per-slot
  flags, untouched concentration/skill flags, view-model `fresh=true` and exact
  `confirmed Missing enchant` warning. A duplicate completion/consumed timeout leaves
  the completed valid read unchanged.
- Event failure, nil-metadata retry, timeout, actual atomic Apply rejection (invalid
  fixture token build, no production function stub), and mixed observed/failed
  per-slot retry statuses: failed tool flag cleared, known values/time retained,
  unrelated session flags/object preserved, view `fresh=false` and exact
  `last observed Missing enchant`. Only successful accessory fields promote in the
  mixed case. Apply failure cannot advance the saved tool attempt/success.
- Late callback after invalidation, changed item link, invalidation during item read,
  invalidation during post-commit context validation, old generation token and
  duplicate after invalidation: no freshness restoration. View/session/warning
  assertions cover historical labels, and observation times distinguish discarded
  reads from successful commits that were subsequently invalidated.

### R2 implementer checks and remaining gates

Both unchanged Python scripts were inspected again before execution (stdlib,
read-only files/TOC/docs/hash inspection; no Lua execution or writes). Runners remain
the approved shared-fixture loaders. Commands run by **implementer**, not verifier:

```text
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated

python3 tools/check_dashboard.py
PASS: 14 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 70 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
```

Each exited0; no structural baseline failures. Approved-runtime discovery:

```sh
if command -v lua5.1 >/dev/null 2>&1; then
  lua5.1 tests/run.lua
  lua5.1 tests/dashboard.lua
else
  printf '%s\n' 'NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH'
fi
```

Output: `NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH`.
Neither Lua command ran. No dependency/runtime install, download, alternate runtime,
compiler/linter or game action. `/ca selftest`, `/cad selftest`, native load/render,
API/async behavior, persistence/multi-alt and all live comparisons remain **NOT RUN**
by the implementer. Historical diagnostic23/23 does not validate these definitions.

Read-only fixture definition count (exit0):

```sh
python3 - <<'PY'
from pathlib import Path
import re
print('Shared dashboard fixture definitions:',len(re.findall(r'^case\(',Path('CraftArmy/SelfTests.lua').read_text(),re.M)))
PY
```

Output: `Shared dashboard fixture definitions: 34` (count, not execution).

Resume owner **primary**: focused independent review of this R2 source freeze and
freshness/warning assertions, then coordinate user-only README checks only after
satisfactory review. Numeric KP all-rank unit-cost eligibility, other seven Midnight
identity mappings, authoritative automatic unlearning, base/enchant stat attribution
and all earlier client gaps remain intentional blockers; no safe unknown completes
those fields. Review/feature acceptance remains primary-owned and unasserted here.
No Git, publication, deployment/release, new permission or scope expansion. Current
hashes follow; this document's current final hash is recorded in T02's R2 delivery
entry in TASKS.md, not self-hashed here.

### R2 current source hashes

Exact read-only command (implementer, exit0):

```sh
sha256sum CraftArmy/CraftArmy.toc CraftArmy/Core.lua CraftArmy/Data.lua CraftArmy/Knowledge.lua CraftArmy/Collectors.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/SelfTests.lua CraftArmy/Commands.lua tests/dashboard.lua tools/check_dashboard.py docs/dashboard/README.md docs/dashboard/schema.md
```

```text
5f0ba92ce9aac13edcece96e4a063c7ea3344667ceba85b56a028640f42daa1b  CraftArmy/CraftArmy.toc
27f2960ac0641a8cc73b4404afd112552fd9bbb99eab33d0370a9fcb6c1651a4  CraftArmy/Core.lua
7168a17322fbc9de3033b5135e6c23db4394891988f1f4537dadad4fb62bcb4f  CraftArmy/Data.lua
1bf9930ea8272e46b6147ba96afcb16467a915d1a10e5295a68db1f2a9f9c4e0  CraftArmy/Knowledge.lua
5388171c20c1167411fe9aae36a718c4be43a3c207419fdc8ac21551baca24d6  CraftArmy/Collectors.lua
956eed011161f55aee24ae629b263c4a8d6e265dc8db67b18c3d6519d976aa0e  CraftArmy/ViewModel.lua
6cf1889f1369f25b4aeb58a3092b44e9eda262b89d1623f3fab61727506275dc  CraftArmy/Dashboard.lua
74b2350566e9ed388997fa54f4d0b167c1331dd22bdeeb5d733ffc72981e5e71  CraftArmy/SelfTests.lua
b436b0e56cb605b5dfba85ebc95da9f94abd7fdeecf8141bc30dedbbc751652d  CraftArmy/Commands.lua
75a65ba61fa53c2b8f681196e64e059c7640c3d0c0a00c31b55f6156c55897a0  tests/dashboard.lua
0b6da6c9887df3aec68744bc37eeb76809345d5c149ba11ee3a6be5ab9d7ce6a  tools/check_dashboard.py
6e8c1e3ae95231e78583151ebe75fb063ef7871a028698b3c07cf5aa317f7d7b  docs/dashboard/README.md
a92dfdd319a390c7b4ccdfad2e139a1a379c36587a9041333210d7c6c3745f79  docs/dashboard/schema.md
```

This R2 freeze supersedes R1 only as the current implementation review target.
All prior delivery/hash/review evidence stays historical and unchanged. No diagnostic
or primary-owned acceptance/planning/agent/question entries were edited; no new files.

## R2 final static review and primary controlled-test gate — 2026-11-05

Reviewed freeze: latest 13 R2 source hashes above; this evidence document's reviewed
hash **before** the primary append/header update was
`23e4e9373b303da04a0cb228531d9987bbbd5b616dae4de406fb56b8aed9552d`.
No source/test/check/README/schema file changed after that review.

- **Static acceptance PASS:** verifier inspected the actual R2 ItemResult/Expire,
  fixtures and affected Core/ViewModel interactions. Async freshness finding resolved;
  prior metadata-preservation and typed-validation findings remain resolved. No new
  concrete blocking static defect identified. Suitable for controlled user selftests.
- **Runtime/feature acceptance INCOMPLETE:** all 34 fixture definitions unexecuted;
  Lua syntax/native addon load/render/API/persistence/multi-alt checks NOT RUN.
  Numeric KP eligibility, seven other Midnight identity maps, automatic unlearning
  and base/enchant stat attribution remain explicit evidence blockers. A static pass
  does not complete these features or eight-profession release readiness.
- Verifier handoff PARTIAL: execution/hash tools denied, Python/Lua/hash checks
  NOT RUN by verifier, no bypass. **Primary separately** matched all 13 R2 source
  hashes and the reviewed evidence hash, and reran both inspected Python checks
  PASS exit0 (23 documents/70 links/eight reviewed diagnostic hashes unchanged).
- Platform review not applicable (local addon only, no hosting/workflow/release changes).
  No package/runtime/game installation, live gameplay action, Git or release performed.

Next owner **primary/user**: user follows README backup/manual installation and runs
`/ca selftest` plus separate `/cad selftest`, then shares exact counts/errors. Stop
on failed fixture/addon-load errors before any live comparisons. Primary records
actual results before coordinating own ready Midnight Inscription scan/UI checks.
No purchasing/crafting/enchanting/equipping/unlearning/knowledge spending requested.

## T02 R3 compact stat presentation — 2026-11-05

**PARTIAL**, pieces14–15 delivered for focused presentation re-review. R2's static
PASS remains historical evidence for that freeze, not acceptance of these changed
files. Original/R1/R2 source hashes and primary review entries above are unchanged.

### Scoped changes and fixture definitions

- `Data.lua`: explicit **presentation-only** category labels C=Crafting Speed,
  I=Ingenuity, M=Multicraft, R=Resourcefulness. The four existing stable stat keys
  reference the same label/full-name pairs used by the enchant category renderer;
  no localized-name first-letter extraction. Existing enchant8005 still maps only
  to the Multicraft category, now displayed as M. No new enchant IDs, API stat keys,
  profession/expansion/currency mappings or collector behavior.
- `ViewModel.lua`: known category summaries use that same presentation map; complete
  tool/enchant names remain in tooltips. Numeric tool values, multiple stats, observed
  total `*`/attribution-unknown explanation, enchant yes/no/? and unknown-category
  fallback remain distinct and unchanged. Accessory-first single-line Tool grouping,
  knowledge/accounting and errors are unaffected.
- `SelfTests.lua`: existing grouped-Tool assertion updated from MC to M. Two new
  pure cases assert all four stable-key labels and matching synthetic category
  display, full tool/enchant tooltip names, actual8005→M, only the existing enchant
  registry entry, multiple stats and exact numeric values, attribution markers,
  unknown stat identifier/zero, unmapped/nil category and yes/no/unknown states.
  Category-only renderer fixtures do not establish other enchant mappings.
- README adds the crafting legend and future-only gathering D=Deftness, F=Finesse,
  P=Perception naming. Gathering remains **outside D05/T02 support**: no runtime
  stat keys/registry/collector/profession support was added. No schema/version/UI
  layout/API or architecture change; only the five authorized manifest files and
  T02 execution-state/delivery entries changed. All other source/docs/T01 frozen.

**36 shared fixture definitions**, including the two R3 cases, remain **NOT RUN**.
Counting definitions is not Lua syntax/fixture/client evidence.

### R3 implementer validation

Both unchanged Python scripts inspected before execution: dependency-free stdlib,
read-only structure/TOC/docs/hash inspection, no addon execution or generated files.
Exact commands and results (implementer, each Python command exit0):

```text
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated

python3 tools/check_dashboard.py
PASS: 14 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 70 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
```

No structural baseline failures; all eight reviewed diagnostic hashes unchanged.
These executions are not verifier/primary results. Approved runtime discovery:

```sh
if command -v lua5.1 >/dev/null 2>&1; then
  lua5.1 tests/run.lua
  lua5.1 tests/dashboard.lua
else
  printf '%s\n' 'NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH'
fi
```

Output: `NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH`.
Neither runner executed. No install/download/alternate runtime, compiler/linter,
native client/game action, Git or release. `/ca selftest`, `/cad selftest`, native
render/load and every live/API/persistence check remain **NOT RUN** by implementer;
historical diagnostic23/23 is not R3 evidence.

Read-only definition count (exit0):

```sh
python3 - <<'PY'
from pathlib import Path
import re
print('Shared dashboard fixture definitions:',len(re.findall(r'^case\(',Path('CraftArmy/SelfTests.lua').read_text(),re.M)))
PY
```

Output: `Shared dashboard fixture definitions: 36`.

### R3 current 13-file source freeze

Read-only command (implementer, exit0):

```sh
sha256sum CraftArmy/CraftArmy.toc CraftArmy/Core.lua CraftArmy/Data.lua CraftArmy/Knowledge.lua CraftArmy/Collectors.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/SelfTests.lua CraftArmy/Commands.lua tests/dashboard.lua tools/check_dashboard.py docs/dashboard/README.md docs/dashboard/schema.md
```

```text
5f0ba92ce9aac13edcece96e4a063c7ea3344667ceba85b56a028640f42daa1b  CraftArmy/CraftArmy.toc
27f2960ac0641a8cc73b4404afd112552fd9bbb99eab33d0370a9fcb6c1651a4  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
1bf9930ea8272e46b6147ba96afcb16467a915d1a10e5295a68db1f2a9f9c4e0  CraftArmy/Knowledge.lua
5388171c20c1167411fe9aae36a718c4be43a3c207419fdc8ac21551baca24d6  CraftArmy/Collectors.lua
3672c606e47272518efc523884d3e886538e9d1d408fe951209c22471c1a25de  CraftArmy/ViewModel.lua
6cf1889f1369f25b4aeb58a3092b44e9eda262b89d1623f3fab61727506275dc  CraftArmy/Dashboard.lua
5c27ee8e694f5443ffc07cdcb1c09bb24f706b232941c972fcb8a741742d2cbd  CraftArmy/SelfTests.lua
b436b0e56cb605b5dfba85ebc95da9f94abd7fdeecf8141bc30dedbbc751652d  CraftArmy/Commands.lua
75a65ba61fa53c2b8f681196e64e059c7640c3d0c0a00c31b55f6156c55897a0  tests/dashboard.lua
0b6da6c9887df3aec68744bc37eeb76809345d5c149ba11ee3a6be5ab9d7ce6a  tools/check_dashboard.py
fee661339f2c5a802a307dd64a1caedeb04ca0b7bfc0c3461aa8cacd50cd06a2  docs/dashboard/README.md
a92dfdd319a390c7b4ccdfad2e139a1a379c36587a9041333210d7c6c3745f79  docs/dashboard/schema.md
```

Final current evidence hash is recorded in T02's R3 delivery entry in TASKS.md to
avoid self-hashing. Resume owner **primary**, focused read-only review of Data,
ViewModel, affected assertions and legend against D07/R3, then coordinate user-only
selftests/client checks only after satisfactory review. Numeric KP cost eligibility,
other seven Midnight identities, authoritative unlearning, base/enchant attribution
and all earlier runtime/field gaps remain unchanged. No acceptance, gathering
support, new gameplay permissions or release inferred from this naming refinement.

## R3 primary-persisted presentation review — 2026-11-05

Focused read-only verifier inspection of changed Data/ViewModel, affected fixtures,
README/evidence and D07/Q05: **static acceptance PASS**, no blocking static defect.
Prior R2 review coverage applies to unchanged files. Shared C/I/M/R and full tooltip
names consistent, values/attribution and unknown states preserved, known8005→M only.
No gathering keys/support or new enchant IDs. Reviewed freeze: latest 13 hashes above
plus this document's pre-append hash
`7223789be89bbb652e3be9af0516be978acaa70ddbcea3ee625d552317d67778`.

Reviewer executions/hash checks permission-denied, NOT RUN; no bypass. Primary
separately matched current hashes and reviewed evidence, reran both inspected Python
checks PASS exit0 (23 docs/70 links/eight diagnostic hashes unchanged). No Lua/client
execution; all36 definitions unexecuted. Review handoff PARTIAL; runtime/field
acceptance INCOMPLETE. No new platform review applicability or release permissions.

Next primary/user: update addon files per backup guide, user `/ca selftest` and
separate `/cad selftest`, report exact outcomes and stop on failures before live
comparisons. Existing numeric KP/identity/unlearning/stat-attribution gaps unchanged.

## First user-run fixture evidence — 2026-11-05

User supplied all 36 console case outcomes and summary: **35 passed; 1 failed**.
Failed case: `invalid future schemas and bounded primitive sanitization do not reset`.
Reported `SelfTests.lua:5` is the generic equality assertion: a table was returned
where nil was expected. Table address deliberately omitted. No source hash/exact
run timestamp/build supplied; names/count match R3, but installed byte identity is
not independently established. This is user-run Lua evidence, not agent execution.

The grouped source test (158–167) checks invalid schemas, cycle/function/NaN/metatable
rejection, invalid observation timestamp and generation mismatch. Current output does
not identify the exact assertion. Other35 cases PASS as supplied, including R1/R2/R3
regressions. Do not claim the whole suite passed, repeat NOT RUN for that user suite,
or treat injected fixtures as native API/render/persistence evidence. Separate
`/cad selftest` result has not been supplied. No real DB reset is established.

**Acceptance CHANGES REQUIRED; pause live comparisons.** Primary read-only research:
[12.1.5 API notes](https://warcraft.wiki.gg/wiki/Patch_12.1.5/API_changes) list native
math.isfinite/isnan/isinf; [historical WeakAuras issue2621](https://github.com/WeakAuras/WeakAuras2/issues/2621)
reports unusual WoW NaN comparison behavior. This is a hypothesis/source reference,
not confirmation of the user's current failing assertion or runtime semantics.

Next targeted user-only read: print `0/0` string, self-equality, strict ±infinity
bounds and optional native math.isfinite result. No production or diagnostic source
changed, no tests weakened and no saved data touched. Depending on output, primary
will prepare the minimal scoped correction or context-label instrumentation while
preserving original failure evidence. Local Lua, live APIs and overall acceptance
remain separately gated.

## User confirms NaN comparison mismatch — 2026-11-05

User's read-only query returned exactly:
`NaN: -nan(ind) self: true bounds: true finite: false`.
NaN passes this runtime's self-equality and strict infinity bounds, while native
math.isfinite returns false. The existing Core.Copy guard accepts values satisfying
exactly those comparisons, reproducing the reported NaN rejection failure. Similar
guards in integer/typed validation, collectors and presentation require auditing.
No current build/time/source hash or actual saved-data mutation inferred.

R4 pieces16–17 READY: shared native-aware Core.Finite, portable fallback only absent
native predicate; protected strict results, production caller audit and stronger
isolated regressions. Original failure/assertions remain; no schema/version/mapping/
diagnostic change or DB reset. Correction execution stays NOT RUN until actual results;
independent review and user retest required. Same approved manifest/safety permissions.

## T02 R4 numeric safety correction — 2026-11-05

**PARTIAL**, pieces16–17 delivered for independent review, then user retest. Historical
R3 user result **35 PASS / 1 FAIL of36** and exact follow-up output remain unchanged:
`NaN: -nan(ind) self: true bounds: true finite: false`. This is user evidence, not
agent-run client execution; no current query build/time/source byte identity or
actual saved-data mutation inferred. The correction has **not** been executed in Lua
or WoW by the implementer; no corrected client PASS is claimed.

### Shared rule and production audit

- `Core.Finite(value, optionalMathLibrary)` rejects nonnumbers first. It prefers
  native `math.isfinite` via protected call with a strict boolean result. Native
  false, throw, malformed/nonboolean result or present nonfunction fails closed;
  none falls back to comparisons. Only a missing native predicate uses portable
  IEEE Lua5.1 self-equality/±infinity bounds. Library injection uses isolated tables,
  not mutation of real math/globals; native scalar classification is not collection.
- `Core.Integer` classifies value and lower bound before modulo/comparison, preserving
  nonnegative/positive/integral field bounds. Copier numeric values and numeric keys
  (via Integer), all typed finite stats/node/currency/modifier validators and their
  arithmetic gates now share this rule. Invalid existing data still disables writes
  untouched; incoming malformed scans remain atomic rejections.
- Collector primitive `pick`, required skill modifier, whole-stat-map validation and
  bounded stat evidence projection use the shared rule. Bad required numeric reads
  become unknown failed attempts; prior coherent gear/skill/currency values and
  successful timestamps remain stale/nonfresh, never fabricated NaN/zero.
- View numeric attention checks delegate to the same predicate. Age/ID/rank checks
  already route through Integer. Knowledge traversal/rank integer guards already use
  Integer, so no Knowledge edit was needed. No formula/mapping/cap/UI changes.
- Read-only source audit of `CraftArmy/*.lua` searched finite/type/modulo and
  self-equality/infinity guards. Only the intentionally native-absent fallback in
  Core retains a comparison-only finite guard; remaining math.huge occurrences are
  actual non-finite fixture samples. The diagnostic implementation is frozen and
  unchanged; its historical checks are not evidence of R4 behavior.

Changed exactly Core, Collectors, ViewModel, SelfTests, dashboard README/schema/evidence
and T02 execution-state/delivery entries. Data, TOC, Knowledge, Dashboard, Commands,
runners/checkers, diagnostics and all primary-owned review/planning history remain
unchanged. Same schema1/version0.2.0-mvp and original manifest; no new file, dependency,
architecture/API behavior beyond the specified scalar predicate, game action or release.

### Regression definitions and capability distinction

**40 shared definitions** (36 prior +4 R4), **NOT RUN** for the corrected freeze.
The original failing group retains its unconditional `Copy({x=0/0}) == nil`
assertion with an explicit actual-NaN subcase label. Other grouped rejection assertions
also gained labels; none was removed or weakened. NaN generation is actual `0/0`,
never conditionally accepted/omitted based on `n==n` in WoW.

- Native dispatch: nonnumeric type gate before native calls, injected true/false,
  thrown exception, nil/numeric/string/table results and present nonfunction. Native
  errors/malformed results cannot trigger a fallback. Real math predicate untouched.
- Actual-runtime NaN/+infinity/-infinity rejection is mandatory for Finite, Copy
  primitive/table values and Integer before modulo. Zero/negative/fraction finite
  values and legitimate integer bounds remain covered. Numeric key insertion is
  protected: a VM rejection is safe; if the VM allows a non-finite key, Copy must
  reject it. Fractional keys remain invalid and numeric key0 remains valid.
- Capability-aware **injected portable fallback**: finite values are checked on all
  hosts; non-finite portable IEEE assertions run on a native-absent host. On WoW,
  intentionally hiding its native predicate is not a supported numeric guard and is
  not claimed to repair its demonstrated non-IEEE comparisons. Crucially, mandatory
  actual/default-path NaN/±infinity and original copier rejection run on every host,
  without a self-equality gate. No actual-client rejection assertion is skipped.
- Direct typed validators plus active/archive load and incoming scan rejection cover
  non-finite skill modifier, currency quantity/cap, unspent, gear stats, index IDs,
  raw node ranks and complete path totals. Existing invalid DB pointers/envelopes and
  bad scalar representation stay unchanged; restoring only the fixture-injected leaf
  verifies no other mutation. Valid DB remains deeply equal after failed writes;
  disabled-data view has no rows and a writes-disabled explanation. Direct pure view
  attention input also cannot confirm a non-finite Moxie warning.
- Injected collector NaN/±infinity in stats, rarity, rank, skill modifier and Moxie
  quantity preserves actual prior values/time100, records unknown attempt/time120,
  rejects non-finite persistence, and asserts field nonfresh/stale and visible stale
  status. Retained observed zero is asserted as original evidence, not a NaN default.

These are fixture definitions, not proof of corrected Lua execution, target APIs,
native rendering or persistence. User35/36 applies only to the earlier supplied run.

### R4 implementer validation

Unchanged approved scripts inspected before running: read-only dependency-free stdlib
structure/docs/hash checks, no Lua execution or generated files. Commands/results
below were executed by **implementer**, not verifier/primary (each Python exit0):

```text
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated

python3 tools/check_dashboard.py
PASS: 14 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 70 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
```

No structural baseline failure; original runtime sanitization failure remains a
historical failure awaiting corrected retest, not erased by structural success.

```sh
if command -v lua5.1 >/dev/null 2>&1; then
  lua5.1 tests/run.lua
  lua5.1 tests/dashboard.lua
else
  printf '%s\n' 'NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH'
fi
```

Output: `NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH`.
Neither Lua command ran. No installation/download, alternate runtime, Lua compiler/
linter, game action, Git or publication/release. Corrected `/ca selftest`, separate
`/cad selftest` retest, addon reload/render and all live/API/persistence comparisons
are **NOT RUN** by implementer. Separate current diagnostic result remains unsupplied.

Read-only fixture count (exit0):

```sh
python3 - <<'PY'
from pathlib import Path
import re
print('Shared dashboard fixture definitions:',len(re.findall(r'^case\(',Path('CraftArmy/SelfTests.lua').read_text(),re.M)))
PY
```

Output: `Shared dashboard fixture definitions: 40` (count, not execution).

### R4 current 13-file source freeze

Read-only command (implementer, exit0):

```sh
sha256sum CraftArmy/CraftArmy.toc CraftArmy/Core.lua CraftArmy/Data.lua CraftArmy/Knowledge.lua CraftArmy/Collectors.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/SelfTests.lua CraftArmy/Commands.lua tests/dashboard.lua tools/check_dashboard.py docs/dashboard/README.md docs/dashboard/schema.md
```

```text
5f0ba92ce9aac13edcece96e4a063c7ea3344667ceba85b56a028640f42daa1b  CraftArmy/CraftArmy.toc
01dff992dff95787e2bc7cd257a9243c2e4eacd92193aea97c83681bd33e5615  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
1bf9930ea8272e46b6147ba96afcb16467a915d1a10e5295a68db1f2a9f9c4e0  CraftArmy/Knowledge.lua
6cca77eb72148d49adda1ebb391649c51c11859c4bd9cd347775004937e45138  CraftArmy/Collectors.lua
fb79073a516d68dfdf5ee1fbc36b6e983188d37f13e50666033f415e59a00def  CraftArmy/ViewModel.lua
6cf1889f1369f25b4aeb58a3092b44e9eda262b89d1623f3fab61727506275dc  CraftArmy/Dashboard.lua
cc6a07e4e2b47e6bec3c0f9e7ce919d387a28d6ffa48b82cd262a762be171877  CraftArmy/SelfTests.lua
b436b0e56cb605b5dfba85ebc95da9f94abd7fdeecf8141bc30dedbbc751652d  CraftArmy/Commands.lua
75a65ba61fa53c2b8f681196e64e059c7640c3d0c0a00c31b55f6156c55897a0  tests/dashboard.lua
0b6da6c9887df3aec68744bc37eeb76809345d5c149ba11ee3a6be5ab9d7ce6a  tools/check_dashboard.py
05c1b08ba7877e835fc485cc5b5a949a138ce3fc72bc5ea78982207a5c5f598e  docs/dashboard/README.md
5d5f0619d264c67abd8aa9ab202957f1b2753e17303f68f433978fae85bd288d  docs/dashboard/schema.md
```

Current evidence hash is recorded in TASKS.md R4 delivery to avoid self-hashing.
All previous hashes/review/user evidence remain historical and unchanged. Resume
**primary** for independent static review of this numeric guard, audit and assertion
design, then **user-only** README update/reload/retest: quit/back up WTF, replace only
reviewed addon files, preserve both SavedVariables, login/reload, `/ca selftest` actual
40-case outcomes and separate `/cad selftest` result. Stop on any error; do not reset
data or resume live comparisons before primary records satisfactory review/results.
All-rank KP cost eligibility, seven other Midnight identities, authoritative unlearning,
base/enchant attribution and all existing client gaps remain blocked. No acceptance
or broader feature/API/release readiness is inferred from this correction.

## R4 primary-persisted correction review — 2026-11-05

Independent focused static acceptance **PASS**, no blocking static defect found.
Reviewer inspected native-aware shared finite rule, production call sites, actual
assertions and affected docs; no module-load native invocation or schema change.
Original NaN rejection assertion remains unconditional/labeled, branch/data-safety
fixtures substantive. Corrected40 definitions **NOT RUN**; historical35/36 remains
failure evidence. Runtime/feature acceptance INCOMPLETE pending actual user retest.

Reviewed freeze: latest13 R4 source hashes above plus pre-append evidence SHA256
`c19363908a33ae61b77fff5db2d11d386e0bdf0d0ab7af690ac368384a09f028`.
Primary independently matched those hashes and ran both inspected Python checks
PASS exit0,23docs/70links/eight diagnostic hashes unchanged. Reviewer execution/hash
tools denied, NOT RUN; no bypass; handoff PARTIAL. No source changed after review.
Platform review not applicable; other field-semantic/client gates stay open.

User next: README backup/addon-files-only update, `/reload`, `/ca selftest` and
separate `/cad selftest`; share exact counts and complete failure lines. No reset
or SavedVariables deletion. Stop on errors before live comparisons; no release.

## R4 user-run fixture results accepted — 2026-11-05

User supplied all40 PASS lines plus:

```text
CraftArmy: 40 passed; 0 failed (pure injected fixtures, not client API evidence)
CraftArmy Diagnostics: 23/23 pure fixture cases passed; no live API evidence
```

Both corrected dashboard and separate diagnostic **fixture gates PASS for these
user executions**. The original failing invalid-schema/primitive sanitization group
and all four R4 cases pass: native dispatch/failure/portable capability, actual
nonfinite copy/integer rejection, collector preservation and typed load/write safety.
Other R1/R2/R3 and original cases also pass as supplied. Historical35/36 and exact NaN
query remain evidence of the original defect, not current failure status.

No exact new build/timestamp/source hashes supplied; do not invent installed byte
identity. User, not agents, executed the pure Lua cases in WoW. Local standalone Lua
remains NOT RUN; these fixtures do not prove native collection/rendering, persistence,
offline/multi-alt behavior, async live behavior or required knowledge-cost semantics.
No code/schema/version/data changes accompany this evidence registration.

Next **primary/user**: with own Midnight Inscription normally open, `/ca scan` then
`/ca`. Share dashboard screenshot and scan status/errors; compare supported values/
gear ordering against native UI without purchases/crafts/equipping or knowledge spend.
Unknown KP/unsupported mappings remain incomplete features; full dashboard acceptance
and eight-profession readiness remain INCOMPLETE. No publication/release inferred.

## First live Inscription row — user screenshot — 2026-11-05

User supplied a native dashboard screenshot and console status:
`CraftArmy: Guarded snapshot collected; knowledge cost eligibility pending evidence.`
This is user-observed collection/rendering evidence for one supplied profession case,
separate from pure fixture results. No agent-run client action or new implementation.

Sanitized visible fields (character labels and raw screenshot deliberately not stored):

| Display | Screenshot observation | Acceptance limitation |
| --- | --- | --- |
| Profession/skill | Midnight Inscription,100/100 | Native profession UI comparison still required |
| Equipment | Three separate R5 indicators, accessory1/accessory2/tool display order | Numeric API slot roles, item identity and native rarity/rank comparison still separate |
| Tool | M152*; Ench:Yes M | Presentation works; * remains observed-total attribution unknown, not verified base/enchant amounts |
| Concentration | 507/1000 | Screenshot observation, not cap/regeneration/offline validation |
| Moxie | 260 | Subsequent displayed value, not old scan's timestamped240 |
| Knowledge | Four labels Blu/Cal/Per/Dar with ? | Expected blocked eligibility; not complete knowledge bars or confirmed capacities |
| Unspent KP | 4 | Displayed observation; compare native UI, do not backfill older0 |
| Status | TRADE_SKILL_CLOSE; snapshot7s | Compatible with context-close invalidation; not an explicit scan error |

Exact capture time/build/source hashes not supplied. The screenshot does not alone
prove live values match native UI, all events are safe, persistence/multi-alt behavior,
tooltip/filters/sorting or overall dashboard acceptance. No error text shown, but do
not infer every runtime error path is cleared. No alert expected from these displayed
currencies under verified thresholds; that is not new boundary testing.

Presentation review findings: gear headers crowded, much unused window space for a
single row, and internal event name exposed as status. These are proposed polish
follow-ups, not new implementation authorization or an assumed final layout change.
Next user check compares displayed skill/currencies/unspent against native Inscription
UI, then gear/tooltips and remaining checklist as available. KP cost semantics and
other field-evidence gates remain INCOMPLETE. No raw identifiers/full screenshot file
persisted, gameplay mutation or release inferred.

## Native-UI field agreement confirmed — 2026-11-06

User replied “Yes it does” to the explicit question whether screenshot values
**100/100 skill,260 Moxie,4 unspent knowledge** match native Inscription UI. Mark
these three field comparisons PASS for that supplied case; no new build/time/source
hash supplied. Concentration507/1000 was not part of the confirmation question and
remains screenshot-only. No gear/stat/enchant/native tooltip, other profession,
persistence, cap, knowledge accounting or broader acceptance inferred.

Next user check: hover Tool cell and share tooltip screenshot to review actual
item/rank, full stat/enchant labels and readability. No code/schema/mapping/data
changes, gameplay mutation or implementation/release approval from this confirmation.

## Tool item text corroboration; hover context pending — 2026-11-06

User supplied a tooltip screenshot. Sanitized public item observations:
Gilded Sin'dorei Quill (item259209), purple/epic name, itemlevel258, Inscription Tool,
displayed+152 Multicraft, Enchant Tool - Haranir Multicrafting, +18 Midnight Inscription
Skill. This corroborates the dashboard's M152 and enchantYesM text for that item.
Visible quality/enchant icons do not independently supply exact numeric rank/bonus;
no rank/amount, base/enchant decomposition or new enchant-ID mapping adopted.

The capture contains third-party tooltip sections and BIS error text. CraftArmy
source does not emit those strings; attribution to a particular addon is unverified.
CraftArmy-generated observation time, Slot/role/rank and observed-total explanation
are not visible. Need hover origin (CraftArmy Tool cell vs native profession UI)
before judging tooltip integration; no confirmed hook conflict/clipping/root cause.
Readable native item text alone is not PASS for CraftArmy's appended tooltip details.

No raw screenshot file, maker/character/realm names, inventory-alt labels or unrelated
stock data stored. No new exact capture time/build/hash supplied. Primary next asks
hover context; other gear/quality/cap/persistence/knowledge gates remain incomplete.
No source edits or gameplay/release actions performed.

## CraftArmy Tool-cell tooltip integration observed — 2026-11-06

User clarifies previous screenshot came from native profession slot; new capture
explicitly comes from CraftArmy Tool cell. It shows native Gilded quill item text
and appended CraftArmy details together: observed attempt/last-observed status,
field time1793883881,slot20/roletool/rarity4/craftedrank5,Multicraft152 observed total,
base/enchant-attribution-unknown explanation, enchantyes/ID8005/Multicraft with
amount/rank unknown. Full stat/enchant labels and timestamps are visible/readable.
The timestamp is a field observation, not an assumed capture date/build identity.

This resolves the hover-context ambiguity and demonstrates native-plus-snapshot
tooltip integration for this item. It does not independently verify every recorded
metadata field against native numeric values or establish enchant amount/quality.
Other tooltips, accessory roles, long knowledge overflow and general UI acceptance
remain pending. The raw enchant atlas markup visible at bottom is a formatting
polish finding; don't solve it by permitting arbitrary untrusted markup execution.

Shared third-party tooltip sections/BIS messages remain outside CraftArmy-generated
strings; no particular-addon blame or runtime fault inferred. No raw screenshots,
maker/character/realm/alt inventory names retained. No code/mapping/schema changes.
Next user closes profession UI, reloads and opens `/ca` without scan, to check saved
row retention and last-observed labeling. No resource spend/data reset/release.

## Reload persistence/labeling user confirmation — 2026-11-06

User replies “Yes it does” to the instructed profession-close, `/reload`, `/ca`
without rescan check asking whether the same row returns labeled snapshot. Mark
that limited user-run reload retention/snapshot-label scenario PASS. No exact new
field values, source hashes/build/time supplied. This is not acceptance of logout/
full restart, other characters, numerical regeneration behavior or all SavedVariables
error paths. No production source/schema changes accompany evidence registration.

Next: if another existing Midnight Inscription character is available, user logs in,
opens its own profession and runs `/ca scan`, `/ca`; confirm two distinct rows,
original retained and marked snapshot. Do not request learning/unlearning or resource
spending to create a test case. Leave multi-alt validation pending if unavailable;
other mapping/knowledge/UI polish and remaining lifecycle gates remain incomplete.

## Two-character snapshot rows retained — 2026-11-06

Following the second-existing-Midnight-Inscription-character test, user confirms two
separate rows, both displayed as snapshots with different ages; user suggests the
profession window was closed. PASS for that limited two-character row separation/
retention scenario. Both-snapshot presentation is consistent with context closure;
exact event sequence/absolute age accuracy or fresh-open-row behavior not established.

No new values, identifiers, capture time/build/source hash supplied. No broader
profession mapping, all-field isolation, long-offline regeneration or complete
lifecycle/async acceptance inferred. Existing evidence is not live offline-alt
inspection. No code/schema/data changes or release permissions.

Next primary proposal is a compact UI polish pass addressing already-visible
crowded gear headers, unused space and raw status/atlas text; user confirmation and
a fully scoped queue are required before execution. Numeric knowledge eligibility,
other mappings and remaining field/client gates stay incomplete.

## T02 R5 approved compact UI polish — 2026-11-06

User approved “Yes proceed” on2026-11-06; executable scope is pieces18–20 in TASKS.
**PARTIAL**, delivered for independent review, then user selftests/screenshots/hover
checks. Only Dashboard.lua, SelfTests.lua, dashboard README/evidence and T02 execution
state/delivery changed. Core (including validated native Finite), Data, Knowledge,
Collectors, ViewModel, Commands, TOC/checkers/schema/diagnostics and all primary-owned
review/planning entries remain frozen. No new files, architecture/data/mapping/API
expansion, other writer/children, install, game action, Git or release.

### Presentation delivered

- Exact11 widths136/144/64/44/44/244/96/56/232/74/112 sum1246; outer1276 with15px
  margins. Visible A1/A2/Tool headers retain canonical full hover labels; existing
  GameFontHighlightSmall, no font shrink. Tool children58/96/90 stay inline within244.
  Canonical ViewModel columns, rarity/rank, C/I/M/R, knowledge/unspent and values unchanged.
- Twelve reusable22px row widgets remain. Filtered visible height is22×min(12,max(1,N));
  outer height176+viewport, so zero/one198,two220,twelve+440. Refresh/filter/archive
  changes grow/shrink and clamp paging offset; wheel/page controls retain access.
  Toolbar/status/header/viewport/footer/confirmation derive widths from shared content.
  Separate selection, ordinary footer/paging and one-line confirmation bands fit
  below the viewport without overlap even at198. Full long identity/scope labels
  remain available on hover when text clips.
- Both positive finite UIParent screen dimensions constrain local scale≤1 with30px
  margin on refresh, using existing Core.Finite and protected dimension reads. Invalid,
  missing, throwing or nonpositive space after margin imposes no usable constraint;
  scale stays strictly positive (safe default1 if none). A margin cannot be guaranteed
  on a screen with no positive room after30px; that fallback is explicit, not a claim
  of fitting impossible dimensions. No global UI scale/size persistence change.
- Dashboard-only exact context mapping supplies saved-profession-closed/changing/
  combat messages. Successful scan text still says knowledge totals pending verification.
  Unknown/error/unsupported/write-disabled reasons stay precise; blockReason wins and
  original raw reason remains on hover. Collector/Commands reasons are not rewritten.
- Only complete atlas/texture tokens in addon-appended plain tooltip lines are removed.
  Literal escaped pipes, malformed/nested/unrecognized/hostile markup remain escaped;
  no arbitrary markup is activated. Tooltip lines clear before rebuilding; unchanged
  raw SetHyperlink runs before appending our sanitized observations. Native/third-party
  rebuilt content is not sanitized or suppressed. No BIS/chat troubleshooting, stat
  amount/enchant rank inference or raw observation/SavedVariables mutation.

### Regression definitions — not execution evidence

**46 shared definitions** (prior40 retained +6 R5). Strict fake widgets now record
points/sizes/scale/styles/tooltips and resolve unscaled parent/anchor bounds; unknown
methods fail rather than silently accepting calls. Scale/size setters reject invalid
values. These are injected native-widget models, not proof of target-client behavior.

1. 0/1/2/12/13/37 rows: actual frame/viewport sizes, all column/header offsets and
   widths, A1/A2/full hover labels, small-font template,12-widget pool and22px rows,
   Tool child adjacency/containment, toolbar/status/footer/confirmation bounds and
   separate vertical bands. No12-row blank viewport with one/two records.
2. Filter shrink/grow, empty filter, archive2/active35, wheel/paging over37, offset
   clamp and preserved reusable widgets. Selection clears when filtered out; existing
   scope confirmation/Cancel remains reachable after shrink, without deleting data.
3. Small/invalid/nonfinite/missing/throwing screen dimensions,30px feasible margin,
   positive local scale≤1, refresh fit recomputation and unchanged global UI scale.
4. Recognized contexts, successful-KP-pending, raw unknown/unsupported/error/write-
   disabled and blocked-success paths. Original reason on hover, no collector DB/
   freshness/pending/revision/serial mutation for presentation of valid snapshots.
5. Complete atlas/texture cleanup with surrounding labels retained; empty/unclosed/
   wrong-terminator/newline/nested/literal-escaped and hostile link/color pipes escape.
6. Tracked native hyperlink + third-party BIS sample remains raw/intact; appended
   full tool/enchant category, stat values, slot/time/unknown attribution survive
   decoration removal. Tooltip rebuild clears old header/item text; long full
   character/profession labels remain on hover; raw DB is deeply unchanged.

All prior numeric/NaN/typed/async assertions remain. Historical user R4 **40/40** and
diagnostic **23/23**, limited native Inscription field/tool/reload/two-row observations
above remain valid only for their recorded scope; they do not validate this changed
suite, size/fit/native rendering or third-party tooltip behavior. R5 fixture/client
results are **NOT RUN** by implementer, not passed.

### R5 implementer validation and baseline comparison

Unchanged approved check scripts inspected before execution: stdlib read-only
structure/TOC/docs/hash checks, no Lua execution or generated files. Exact results
(implementer, each Python exit0; not verifier/primary executions):

```text
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated

python3 tools/check_dashboard.py
PASS: 14 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 70 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
```

No structural baseline failure. Approved-runtime discovery:

```sh
if command -v lua5.1 >/dev/null 2>&1; then
  lua5.1 tests/run.lua
  lua5.1 tests/dashboard.lua
else
  printf '%s\n' 'NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH'
fi
```

Output: `NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH`.
Neither Lua command executed. No runtime/package installation, download, alternate
runtime/compiler/linter, agent WoW test or new native result. R5 `/ca selftest`, native
load/render/screenshots/tooltip/filter/confirmation checks remain NOT RUN by agent.

Read-only R4 comparison/count command (exit0):

```sh
python3 - <<'PY'
from pathlib import Path
import hashlib,re
text=Path('docs/dashboard/evidence.md').read_text()
section=text.partition('### R4 current 13-file source freeze')[2]
base=re.findall(r'^([0-9a-f]{64})  (\S+)$',section,re.M)[:13]
assert len(base)==13 and len({p for _,p in base})==13
allowed={'CraftArmy/Dashboard.lua','CraftArmy/SelfTests.lua','docs/dashboard/README.md'}
changed=set()
for digest,path in base:
    if hashlib.sha256(Path(path).read_bytes()).hexdigest()!=digest:
        assert path in allowed, 'frozen R4 file changed: '+path
        changed.add(path)
assert changed==allowed, changed
print('PASS: R4 comparison — exactly Dashboard/SelfTests/README changed; ten other frozen hashes unchanged')
print('Shared dashboard fixture definitions:',len(re.findall(r'^case\(',Path('CraftArmy/SelfTests.lua').read_text(),re.M)))
PY
```

Output: `PASS: R4 comparison — exactly Dashboard/SelfTests/README changed; ten other frozen hashes unchanged`
and `Shared dashboard fixture definitions: 46`. Count is not execution. The eight
reviewed diagnostic hashes also match via the dashboard checker. Same0.2.0-mvp,
schema1/TOC; no Git base exists. Evidence itself is append-only and hashed in TASKS.

### R5 current13 source freeze

Read-only command (implementer, exit0):

```sh
sha256sum CraftArmy/CraftArmy.toc CraftArmy/Core.lua CraftArmy/Data.lua CraftArmy/Knowledge.lua CraftArmy/Collectors.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/SelfTests.lua CraftArmy/Commands.lua tests/dashboard.lua tools/check_dashboard.py docs/dashboard/README.md docs/dashboard/schema.md
```

```text
5f0ba92ce9aac13edcece96e4a063c7ea3344667ceba85b56a028640f42daa1b  CraftArmy/CraftArmy.toc
01dff992dff95787e2bc7cd257a9243c2e4eacd92193aea97c83681bd33e5615  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
1bf9930ea8272e46b6147ba96afcb16467a915d1a10e5295a68db1f2a9f9c4e0  CraftArmy/Knowledge.lua
6cca77eb72148d49adda1ebb391649c51c11859c4bd9cd347775004937e45138  CraftArmy/Collectors.lua
fb79073a516d68dfdf5ee1fbc36b6e983188d37f13e50666033f415e59a00def  CraftArmy/ViewModel.lua
b8eb1e5475dbbdbdb96fd2c72c21e3313b1fc39200092d041d23db26560bc3df  CraftArmy/Dashboard.lua
0978add71f99f4f3c5b6d647c851dd7937b76089f7a622b0d4120911a8cd8f4a  CraftArmy/SelfTests.lua
b436b0e56cb605b5dfba85ebc95da9f94abd7fdeecf8141bc30dedbbc751652d  CraftArmy/Commands.lua
75a65ba61fa53c2b8f681196e64e059c7640c3d0c0a00c31b55f6156c55897a0  tests/dashboard.lua
0b6da6c9887df3aec68744bc37eeb76809345d5c149ba11ee3a6be5ab9d7ce6a  tools/check_dashboard.py
a1b39a63b29d902f9ab5f5d1f7b8e650823ed4177ba0bfd329f73424d3c8915b  docs/dashboard/README.md
5d5f0619d264c67abd8aa9ab202957f1b2753e17303f68f433978fae85bd288d  docs/dashboard/schema.md
```

Resume owner **primary**, focused independent read-only review of geometry/helpers/
fakes/evidence before user update. Then user follows README backup/addon-files-only
update/reload, `/ca selftest` actual46-case results, one-/two-row screenshots and
Tool/status/header tooltip checks (confirmation Cancel only, no data reset/deletion).
All prior primary review/user history remains intact; current evidence hash is in
TASKS R5 delivery. Numeric KP eligibility, seven other Midnight mappings, verified
concentration cap/role/stat coverage and lifecycle/async/native rendering gates remain
explicitly incomplete as before. No API/data acceptance or release inferred.

## R5 primary-persisted focused review — 2026-11-06

Independent focused static acceptance **PASS**, no blocking defect identified in
geometry, paging/filter resizing, selection/confirmation/footer placement, finite
local fit, short/full headers, status mapping/raw/error preservation or safe tooltip
rebuilding. Strict mocks/assertions meaningfully cover changed behavior without an
obvious false-failure hazard. Reviewed changed Dashboard/SelfTests/README/evidence
against R4; prior review coverage applies to unchanged files. No Git base exists.

Reviewed freeze: latest13 R5 hashes above plus this document's pre-append SHA256
`4886cf8c5f5e8f3cb9c615113e75bae9a4e480542eff631b5bc0f51b63f32e8e`.
Primary independently matched all13/evidence, confirmed exact Dashboard/SelfTests/
README delta (ten other frozen hashes unchanged) and reran both inspected Python
checks PASS exit0 (23 docs/70 links/eight diagnostic hashes unchanged).

Reviewer code/docs/script inspection completed; execution/hash tools permission-denied,
NOT RUN, no bypass. Handoff PARTIAL; **R5 46 fixture definitions and native UI tests
remain NOT RUN**. Runtime/feature acceptance INCOMPLETE; old40/40 and limited field/
tooltip/reload/two-character results do not validate these presentation changes.
No source changed after review, platform review N/A, no release/install permission.

Next user follows README backup/addon-files-only update (Dashboard/SelfTests), reload
and `/ca selftest`; report actual counts/errors and stop on failure. Then one-/two-row
screenshots and header/status/Tool hover plus confirmation Cancel, without deleting
or retiring data. Remaining KP/mapping/field gates unchanged, no gameplay mutation.

## R5 user-run fixture gate PASS — 2026-11-06

User supplied all46 PASS lines and final output:

```text
CraftArmy: 46 passed; 0 failed (pure injected fixtures, not client API evidence)
```

Mark R5 fixture gate **PASS for this user execution**, including six added UI model
cases (geometry/full hover labels, filter/archive/paging/confirmation, local screen
fit, status/no-mutation, icon sanitization/hostile text, native-plus-appended tooltip
model) and all earlier regressions. No new build/timestamp/source hashes supplied;
no independent installed-byte proof. User executed Lua in WoW; agents/local standalone
Lua did not. Prior diagnostic23/23 is unchanged, not a new diagnostic run in this log.

Fake-widget success does not establish native R5 frame sizing, text clipping, screen
scale, hover readability or actual third-party tooltip rebuilding. Next user `/ca`
from existing snapshots and screenshot one/two rows (filter for one if convenient),
then header/status/Tool hover. No rescan, crafting, lifecycle mutation or data reset
needed for layout review. Remaining knowledge/field/mapping/client gates incomplete;
no source changes/publication permissions inferred from passing fixtures.

## R5 native two-row layout and Tool cleanup observed — 2026-11-06

User supplies native dashboard and Tool tooltip screenshots. Sanitized presentation:
two compact single-line rows within a much shorter fitted frame; clear A1/A2/Tool
headers and grouped Tool stats/enchant; toolbar, selection/footer/lifecycle/paging
controls show no visible overlap. Friendly top status reads
`Profession closed — showing saved snapshots.` Knowledge totals remain unknown, not
invented progress. Mark shown two-row presentation PASS for this supplied layout,
not all screen sizes/filter transitions/control behavior.

Displayed observations: skill100/100 both; M152* both; concentration597/1000 and171/1000,
Moxie260 and275,unspent0/0,snapshot9s/7h. Second enchant summary is ?, not No. These
new displayed values are not independent native-UI comparisons or retroactive
replacements for prior screenshot quantities. No failure/data-loss inference from
changed amounts. No new absolute capture time/build/source hashes supplied.

Tool screenshot retains native Gilded quill item/third-party sections and appended
observation/slot20/rarity4/rank5/Multicraft152, observed-total attribution explanation,
enchantyes/ID8005/Multicraft with amount/rank unknown. Field time1793914369 remains an
observation timestamp, not the screenshot time. Raw atlas markup no longer appears
in the final addon-appended enchant line. Mark tooltip cleanup/integration PASS for
this supplied case. Third-party BIS messages persist, correctly outside polish scope.

No raw screenshots, character/realm/maker/alt inventory labels stored. No code/data/
schema changes. Next user native filter-to-one-character and clear-filter check for
shrink/grow retention; header/status raw-context hover, small screens/large lists/
confirmation-Cancel and broader data/knowledge/mapping checks remain separate.
Overall acceptance INCOMPLETE; no release or gameplay permissions inferred.

## R5 native filter sizing/retention confirmed — 2026-11-06

User answers “Yes it does” to filtering Character to one row then clearing the filter:
window shrinks to one row, expands to two and neither snapshot is lost. PASS for
this user-run native filter/size/retention check. No exact additional values, capture
time/build/source hashes supplied, no source or SavedVariables edits.

R5's requested normal-case compact polish now has static PASS, user46/46 and native
one-/two-row/filter/status/clean Tool observations for the supplied cases. Do not infer
all screen sizes, long-list paging, precise raw-header/status hover or confirmation
Cancel were natively exercised; their fixture results remain separately scoped.
Overall T02/data acceptance remains PARTIAL: numeric knowledge eligibility, other
profession mappings and outstanding field/cap/lifecycle checks are still unresolved.

Primary proposes targeted Inscription knowledge-accounting verification next rather
than more visual changes. No new implementation queue/data policy/release permission
is established by this test reply; no gameplay actions or resets requested.

## T02 R6 fourteen-column table iteration — 2026-11-06

**PARTIAL**, pieces21–23 delivered for independent review and then user validation.
User-requested visual iteration and both display clarifications are recorded in
D07/Q05 and the active R6 contract. This supersedes R5's grouped Tool/letter main
cells, not its historical results. R5 user46/46, limited native screenshots/Tool
hover/filter sizing and prior numeric/diagnostic evidence remain valid only within
their recorded scopes. No R6 Lua/native test PASS is claimed.

Changed only ViewModel.lua, Dashboard.lua, SelfTests.lua, dashboard README/evidence
and T02 execution-state/delivery. Core/native Finite, Data, Knowledge, Collectors,
Commands, TOC/checkers/schema/diagnostics and primary review/planning history remain
frozen. Same0.2.0-mvp/schema1/manifest; no new files, children, architecture, collection,
numeric/formula/ID mappings, theme, installs, gameplay, Git or release operations.

### R6 presentation and pinned menu source

- Shared `ViewModel.index` names all14 columns in canonical order: Name, Realm,
  Profession, Skill, Accessory#1, Accessory#2, Tool, Stat, Enchant, Concentration,
  Moxie, Knowledge trees, Unspent KP, Last Updated. Separate labels do not change GUID/
  skill-line keys. Main Stat uses full names joined with commas, no amounts/asterisk;
  unknown categories remain?. All raw keys/values and attribution-unknown evidence
  stay on hover, with no bonuses inferred from rank or double-counted.
- Tool is gear only. Enchant shows full known category, blank for explicit none/
  no-tool/not-applicable, lone? for unknown/unloaded/unmapped. Known8005 remains only
  Multicraft, no rank/amount inference. Confirmed missing attention retains model,
  sorting/filtering and fresh/historical hover labels, using amber alpha0.12 instead
  of a text marker in the blank Enchant cell. Unknown never becomes missing; archives
  have no active attention. Other warning semantics stay unchanged at named columns.
- Gear uses item icon and matching valid quality atlas without R#. A known1–5 rank
  without usable matching atlas uses bare rank; unknown rank?, confirmed empty blank.
  Only A1/A2/Tool use known uncommon/rare/epic RGB backgrounds at alpha0.18. Every
  rendered cell resets transparent before applying current evidence; failed attempts
  retain last-observed rarity rather than erasing a known coherent snapshot.
- Last Updated uses relative `g.scannedAt` age only, not archive time. Exact scan/
  per-field observation/attempt times, snapshot/fresh/stale/archive and failure context
  remain in model/hover. Character text matches name, realm, combined name-realm or
  GUID. Family filter uses saved profession enum independent of localized labels;
  legacy pure text/ID filter remains only for compatibility, not as visible input.
- Widths110/100/150/64/44/44/44/180/130/96/56/232/74/100 sum1424, outer1454. Buttons
  top60, native dropdown top55/height25, input61/labels65, headers96, viewport118.
  Height194+22×min(12,max(1,N)): zero/one216,two238,twelve+458. Same12 reusable22px
  rows, bounded shared-width footer/selection/confirmation, paging/fit, small fonts,
  R4 numeric guard and R5 status/tooltip sanitation remain. Tool/Stat/Enchant all
  share native item plus sanitized full evidence; native/third-party text untouched.
- Native `DropdownButton`/`WowStyle1DropdownTemplate` uses SetupMenu generator and
  root CreateRadio, All plus eight alphabetically ordered Data.families labels with
  stable enum data (`nil` All). Selection resets page/refreshes, no scan/DB write.
  Creation, SetupMenu/SetDefaultText and root CreateRadio are capability checked/
  protected. Missing/failing capability shows noninteractive All placeholder with
  explanation, clears family/legacy hidden filters and ignores stale callbacks.

Read-only in-memory public source research used pin
`297d7aaaa736f346b3e036f38ee088eaf7f8c07f` at
`https://raw.githubusercontent.com/Gethe/wow-ui-source/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_Menu/`:

- `DropdownButton.lua:234–248` documents SetupMenu(generator) and generator signature
  `(dropdown,rootDescription)`; generation runs immediately if shown, otherwise on show.
- `MenuTemplates.lua:345` defines CreateRadio(text,isSelected,onSelect,data);
  `:738` defines SetDefaultText. `Mainline/MenuTemplates.xml:3–10` defines native
  dropdown template/height and background extending7px above/9px below (8px sideways).
- `MenuUtil.lua:84–89,133–136` forwards registered inserters onto root descriptions;
  `:224–229,263–275` registers template inserters including CreateRadio. This resolves
  root forwarding statically, not with a guessed root method or forced addon load.

These were source-text reads via Python urllib (no files written/installed), not
installed-client API/render evidence. The primary's earlier wrong-path404 remains
non-evidence; no new404 or alternate API behavior was used to justify implementation.

### R6 regressions — 50 definitions, not executed

Prior46 definitions retained/adapted where presentation was intentionally superseded;
four new table-driven R6 cases yield **50 shared definitions**. No original numeric/
NaN/typed/retention/async guard was weakened. Frozen Core/native Finite is unchanged.

1. Exact14 headers/order/cells, separate identity and full Stat/Enchant, age-only scan
   time with independent field timestamps, failed/stale and fresh guarded observations,
   archive time distinct from scan, no archive warnings. Prior adapted label cases
   cover each crafting full name, multiple values/raw keys on hover, no main amounts/
   asterisk, unknown stat keys/category and known8005 without inferred bonus.
2. All ranks1–5 × uncommon/rare/epic: item+quality glyph, bare-rank absent/mismatched
   atlas fallback, no R#, exact RGB/alpha; same reused widgets reset to transparent
   for unknown rarity/empty/new evidence. Failed attempts explicitly preserve known
   last-observed rarity. Both accessories and Tool receive independent fills.
3. Known/absent/no-tool/not-applicable/unloaded/unknown/unmapped enchant main strings;
   blank amber missing only, named-column filter/sort, fresh/historical hover evidence,
   no archived attention and shared Tool/Stat/Enchant tooltips. Prior currency warning
   cases now explicitly check fresh/historical named-column markers too.
4. Name/realm/combined/GUID and stable family filters, synthetic localized-name row
   with no production mapping added, legacy pure ID filter. Strict native-widget fake
   invokes SetupMenu generator with root receiver and actual radio data/callbacks,
   selection predicates, All/reset/page/active+archived filtering and selected text.
   It covers creation/method/setup/root/radio failure fallback, cleared hidden filters,
   noninteractive explanation and stale callback rejection, no snapshot/scan effects.

Adapted R5 geometry/paging cases still cover0/1/2/12/13/37 rows, all14 header/cell
bounds and full hover labels, native background opposing-anchor rectangle/decoration
clearance, footer/confirmation/Cancel, shrink/grow/page clamp, small/invalid-screen
positive fit, raw/friendly/blocking status, safe icon cleanup and native+appended
tooltip rebuild without DB mutation. Unknown methods in fakes still fail; recorded
geometry/styles/callbacks are asserted rather than silently accepted. These mocks
are **not** evidence that the installed WoW menu or native rendering works.

### R6 implementer validation and baseline comparison

Both approved Python scripts and both optional Lua runners inspected first. Python
scripts are read-only stdlib structure/docs/baseline checks; they do not parse Lua,
create build artifacts or validate APIs. Exact **implementer** commands/results below
(not independent verifier/primary executions; each Python command exit0):

```text
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated

python3 tools/check_dashboard.py
PASS: 14 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 70 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
```

No structural baseline failure. Historical35/36 sanitization failure/reproduction
and subsequent R4 user40/40 resolution remain recorded above, not rewritten as R6
execution. Approved runtime gate (exit0):

```sh
if command -v lua5.1 >/dev/null 2>&1; then
  lua5.1 tests/run.lua
  lua5.1 tests/dashboard.lua
else
  printf '%s\n' 'NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH'
fi
```

Output: `NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH`.
Neither runner executed. No alternate runtime, install/download/compiler/linter or
agent WoW test. R6 Lua syntax/execution, `/ca selftest`, native menu/render/hover/
screenshots/filter/fit/confirmation and live API/persistence checks remain **NOT RUN**.
Prior user46/46 and diagnostic23/23 are historical, not a new50-case/diagnostic result.

Read-only latest R5 comparison/count command (exit0):

```sh
python3 - <<'PY'
from pathlib import Path
import hashlib,re
text=Path('docs/dashboard/evidence.md').read_text()
section=text.partition('### R5 current13 source freeze')[2]
base=re.findall(r'^([0-9a-f]{64})  (\S+)$',section,re.M)[:13]
assert len(base)==13 and len({p for _,p in base})==13
allowed={'CraftArmy/ViewModel.lua','CraftArmy/Dashboard.lua','CraftArmy/SelfTests.lua','docs/dashboard/README.md'}
changed=set()
for digest,path in base:
    if hashlib.sha256(Path(path).read_bytes()).hexdigest()!=digest:
        assert path in allowed, 'frozen R5 file changed: '+path
        changed.add(path)
assert changed==allowed,changed
print('PASS: R5 comparison — exactly ViewModel/Dashboard/SelfTests/README changed; nine other frozen hashes unchanged')
print('Shared dashboard fixture definitions:',len(re.findall(r'^case\(',Path('CraftArmy/SelfTests.lua').read_text(),re.M)))
PY
```

Output: `PASS: R5 comparison — exactly ViewModel/Dashboard/SelfTests/README changed; nine other frozen hashes unchanged`
and `Shared dashboard fixture definitions: 50`. Counts are not execution. All eight
diagnostic hashes separately match through the dashboard checker; no Git base exists.

### R6 current13 source freeze

Read-only command (implementer, exit0):

```sh
sha256sum CraftArmy/CraftArmy.toc CraftArmy/Core.lua CraftArmy/Data.lua CraftArmy/Knowledge.lua CraftArmy/Collectors.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/SelfTests.lua CraftArmy/Commands.lua tests/dashboard.lua tools/check_dashboard.py docs/dashboard/README.md docs/dashboard/schema.md
```

```text
5f0ba92ce9aac13edcece96e4a063c7ea3344667ceba85b56a028640f42daa1b  CraftArmy/CraftArmy.toc
01dff992dff95787e2bc7cd257a9243c2e4eacd92193aea97c83681bd33e5615  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
1bf9930ea8272e46b6147ba96afcb16467a915d1a10e5295a68db1f2a9f9c4e0  CraftArmy/Knowledge.lua
6cca77eb72148d49adda1ebb391649c51c11859c4bd9cd347775004937e45138  CraftArmy/Collectors.lua
195de6fb5ae289e3bdb543b915c6bcbaac8b3c551e695ac1487b1bf0b3f85b55  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
1adede06820c6fb6cd5b5c75b1f21a8c07f15ca282be30902b2309e381f17896  CraftArmy/SelfTests.lua
b436b0e56cb605b5dfba85ebc95da9f94abd7fdeecf8141bc30dedbbc751652d  CraftArmy/Commands.lua
75a65ba61fa53c2b8f681196e64e059c7640c3d0c0a00c31b55f6156c55897a0  tests/dashboard.lua
0b6da6c9887df3aec68744bc37eeb76809345d5c149ba11ee3a6be5ab9d7ce6a  tools/check_dashboard.py
368ef34b0311cfc88c887808a53887bb5f0b37aadad5e8ebe0fcac6d58eaa728  docs/dashboard/README.md
5d5f0619d264c67abd8aa9ab202957f1b2753e17303f68f433978fae85bd288d  docs/dashboard/schema.md
```

Final evidence hash is in TASKS R6 delivery, avoiding self-hashing. Resume owner
**primary**: independent read-only R6 review of the frozen view model/UI/fakes/docs,
then coordinate user-only reviewed three-file update/reload, `/ca selftest` actual
50-case outcomes,14-column one-/two-row screenshots, dropdown/All/archived/filter
checks and Tool/Stat/Enchant/Last Updated/status hover. Confirmation Cancel only;
no saved-data reset or gameplay mutation needed. Review/runtime acceptance remain
INCOMPLETE. Numeric KP all-rank cost eligibility, seven other Midnight mappings,
automatic unlearning, base/enchant attribution, verified cap/role coverage and
remaining lifecycle/async/native edge gates stay open. Unknowns are not completed
required fields; theme/knowledge work remains deferred, no release authorized.

## R6 primary-persisted focused review — 2026-11-06

Independent static acceptance **PASS**, no blocking defect identified in named14-
column indexes, full labels/blank-vs-unknown handling, quality glyph/fallback/rarity
reset, warning/filter/sort remapping, relative age or native menu callbacks/fallback.
Actual view model/UI/tests/strict menu fakes/docs/pinned interfaces reviewed; prior
review coverage applies to unchanged files, no Git base. New50 fixtures and native
dropdown/render/hover **NOT RUN**, runtime/field acceptance **INCOMPLETE**.

Reviewed freeze: latest13 R6 hashes above plus pre-append evidence SHA256
`e35b1b483bec975454e04422713b48200ec38c18604534cbfd305bedd5c55f16`.
Primary matched13/evidence and exact ViewModel/Dashboard/SelfTests/README delta vs
R5 (nine other hashes unchanged), reran both inspected Python checks PASS exit0,
23docs/70links/eightdiagnostic hashes unchanged. Reviewer execution/hash tools denied,
NOT RUN/no bypass; handoff PARTIAL. No source changed after review; platform review N/A.

Next user backup/update only ViewModel/Dashboard/SelfTests, preserve SavedVariables,
reload and `/ca selftest`, share actual50-case outcomes and stop on errors. Then
check14columns, profession All/family dropdown, filters, rarity fills and Tool/Stat/
Enchant/Last Updated hover. No new knowledge/mapping/API compatibility, retirement/
deletion/data reset or release inferred. Theme/knowledge remain deferred as requested.

## R6 user49/50 and identity-fixture diagnosis — 2026-11-06

User supplies all50 outcomes:49PASS and one failure in
`R6 quality glyphs bare rank fallbacks rarity RGB and reused cell transparency`:
`failed attempt retains last-observed rarity, not invented unknown: 0 ~= 0.18`.
Reported generic assertion helper5; source-specific assertion1247. All other49
outcomes PASS as supplied. No exact current build/time/source hashes supplied.
User Lua execution, not local/agent execution or native widget evidence.

Static trace establishes inconsistent fixture input: accessory seeds1241–1244 have
no itemID/link; retry1246 is unknown/nil. Existing Core.sameInstance90–93 requires
matching positive ID/exact link/slot, and mergeEquipment95–112 deliberately discards
unidentifiable prior equipment metadata. Renderer transparency is correct for that
input, not a demonstrated production bug. Retaining colour without identity would
undo the approved replacement-safety guard. No actual saved-data loss established.

Acceptance CHANGES REQUIRED. R6a24–25 correct fixture setup with identified seed and
same-instance failure, retaining0.18/success-time/stale assertions; add distinct nil/
changed identity cases requiring transparency/no borrowed metadata. Only SelfTests,
README/evidence and task execution state writable; all production source frozen.
No weakened guard/skipped assertions, schema/data/API changes or permissions expanded.
Review and user retest before live comparisons; historical failure remains preserved.

## T02 R6a identified-equipment fixture correction — 2026-11-06

**PARTIAL**, pieces24–25 delivered for focused read-only review and user retest.
The initial R6 user result remains **49 PASS / 1 FAIL of50**, not NOT RUN or a passing
suite. Failed case `R6 quality glyphs bare rank fallbacks rarity RGB and reused cell
transparency`, specific prior assertion1247:
`failed attempt retains last-observed rarity, not invented unknown: 0 ~= 0.18`.
Other49 supplied outcomes remain historical user-run pure fixture results, not native
UI/API evidence. The corrected50-case suite has **NOT RUN** in Lua/WoW by implementer;
no corrected user result is supplied yet.

### Diagnosis and bounded correction

Read-only trace of frozen `Core.lua:90–112` confirms positive matching itemID, exact
instance link and slot/existence are required to preserve prior gear metadata across
failed reads. Initial accessory seed lacked ID/link and retry passed unknown/nil,
so storage correctly dropped the unidentifiable old unit and renderer showed alpha0.
This was an inconsistent fixture, not demonstrated production rendering/data loss.
No Core/merge/view/renderer changes or weakened identity guards were made.

Only the existing quality/fill case in `CraftArmy/SelfTests.lua` changed:

- Both accessory seeds now carry coherent positive itemID, full synthetic instance
  link, matching slot/role/exists, known rarity/rank/icon and metadataReady=true at110.
  Seed/retry helpers assert successful Apply and use its returned current generation,
  also checking it matches the active DB generation, never stale cloned references.
- Positive retry at115 is unknown with matching itemID/link/slot/role/exists and
  metadataReady=false. Assertions retain prior rarity4/rank3/icon4321 and successful
  observedAt110, record attempt status unknown/time115/reason, and check view stale/
  nonfresh even with a session freshness flag. Actual reused accessory cell retains
  alpha0.18; the original critical0.18 assertion remains unchanged, not flipped to0.
- Four separate negative subcases reseed known identified/coloured equipment before
  nil identity, unidentified partial instance, changed ID/link or changed instance
  link with same ID. Apply must succeed and retries stay nonfresh. Nil has no last
  unit; partial evidence has current timestamp115/identity with no inherited rarity,
  rank, icon, quality or stats. All render `?`/transparent, never confirmed missing.
- All prior ranks1–5 × uncommon/rare/epic, glyph/fallback/mismatched-atlas and reused
  transparency/empty/unknown checks remain. All other49 fixture definitions are
  unchanged; still **50 definitions**, no dropped/skipped assertions, extra case,
  real DB/API/math-global writes or altered production behavior.

Changed only SelfTests.lua, dashboard README/evidence and T02 execution-state/delivery.
All production Lua including Core/native Finite, Collectors, ViewModel and Dashboard
remain frozen, as do Data/Knowledge/Commands/TOC/schema/checkers/diagnostics and primary
review/planning history. No new files, children, collection/formula/mapping/theme/
knowledge work, install/download/alternate runtime, gameplay, Git or release.

README now distinguishes already-installed R6 (replace only reviewed SelfTests.lua,
preserve every production file and both SavedVariables, reload/selftest50) from users
not yet on R6 (prior reviewed three-file update with corrected SelfTests). Stop on
failures, no reset/reinstall. Review and actual corrected results precede native
screenshots/dropdown/hover comparisons; these remain separate acceptance gates.

### R6a implementer checks

Both approved Python scripts and optional Lua runners inspected first. These are
read-only stdlib structural/docs/hash checks, not Lua parsers/runtime/native API
validators. Exact implementer commands/results (each Python exit0; not verifier/
primary executions):

```text
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated

python3 tools/check_dashboard.py
PASS: 14 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 70 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
```

No structural baseline failure. The initial49/50 failure above remains historical;
structural success is not evidence the corrected assertion executed successfully.
Runtime discovery (gate exit0):

```sh
if command -v lua5.1 >/dev/null 2>&1; then
  lua5.1 tests/run.lua
  lua5.1 tests/dashboard.lua
else
  printf '%s\n' 'NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH'
fi
```

Output: `NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH`.
Neither suite ran; no substitute runtime/install/compiler/linter or agent WoW action.
Corrected Lua syntax/execution, `/ca selftest` and all native UI/API/persistence checks
are NOT RUN. Previous diagnostic23/23 is unchanged, not a new diagnostic run.

Read-only R6 comparison/count (exit0):

```sh
python3 - <<'PY'
from pathlib import Path
import hashlib,re
text=Path('docs/dashboard/evidence.md').read_text()
section=text.partition('### R6 current13 source freeze')[2]
base=re.findall(r'^([0-9a-f]{64})  (\S+)$',section,re.M)[:13]
assert len(base)==13 and len({p for _,p in base})==13
allowed={'CraftArmy/SelfTests.lua','docs/dashboard/README.md'}
changed={path for digest,path in base if hashlib.sha256(Path(path).read_bytes()).hexdigest()!=digest}
assert changed==allowed,changed
print('PASS: R6 comparison — exactly SelfTests/README changed; eleven other frozen hashes unchanged')
print('Shared dashboard fixture definitions:',len(re.findall(r'^case\(',Path('CraftArmy/SelfTests.lua').read_text(),re.M)))
PY
```

Output: `PASS: R6 comparison — exactly SelfTests/README changed; eleven other frozen hashes unchanged`
and `Shared dashboard fixture definitions: 50`. Eight diagnostic hashes separately
match via dashboard checker. Counts/hashes do not execute fixtures; no Git base exists.

### R6a current13 source freeze

Read-only command (implementer, exit0):

```sh
sha256sum CraftArmy/CraftArmy.toc CraftArmy/Core.lua CraftArmy/Data.lua CraftArmy/Knowledge.lua CraftArmy/Collectors.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/SelfTests.lua CraftArmy/Commands.lua tests/dashboard.lua tools/check_dashboard.py docs/dashboard/README.md docs/dashboard/schema.md
```

```text
5f0ba92ce9aac13edcece96e4a063c7ea3344667ceba85b56a028640f42daa1b  CraftArmy/CraftArmy.toc
01dff992dff95787e2bc7cd257a9243c2e4eacd92193aea97c83681bd33e5615  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
1bf9930ea8272e46b6147ba96afcb16467a915d1a10e5295a68db1f2a9f9c4e0  CraftArmy/Knowledge.lua
6cca77eb72148d49adda1ebb391649c51c11859c4bd9cd347775004937e45138  CraftArmy/Collectors.lua
195de6fb5ae289e3bdb543b915c6bcbaac8b3c551e695ac1487b1bf0b3f85b55  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
ba8580e7e24adadd31bfd4a01d3a6c843835cfeea4328140c6282761c209efdc  CraftArmy/SelfTests.lua
b436b0e56cb605b5dfba85ebc95da9f94abd7fdeecf8141bc30dedbbc751652d  CraftArmy/Commands.lua
75a65ba61fa53c2b8f681196e64e059c7640c3d0c0a00c31b55f6156c55897a0  tests/dashboard.lua
0b6da6c9887df3aec68744bc37eeb76809345d5c149ba11ee3a6be5ab9d7ce6a  tools/check_dashboard.py
40aedafd52ce8e8a0527c7c4ab2f2f220f5fb13b997d94759b57cfee1a601428  docs/dashboard/README.md
5d5f0619d264c67abd8aa9ab202957f1b2753e17303f68f433978fae85bd288d  docs/dashboard/schema.md
```

Evidence's final hash is recorded in TASKS R6a delivery, not self-hashed here.
Resume **primary**: focused independent read-only review of corrected fixture/README/
freeze, then user-only SelfTests update/reload and actual50-case report. Corrected
fixture/runtime acceptance INCOMPLETE; original failure stays CHANGES REQUIRED until
retest. Native R6 screenshots/dropdown/hover remain pending; knowledge costs, seven
other Midnight maps, attribution/cap/role/lifecycle gates unchanged. Theme/knowledge
deferred, no production fix or release inferred from a fixture-only correction.

## R6a primary-persisted focused review — 2026-11-06

Static acceptance **PASS**, no blocking finding. Reviewer inspected corrected identity
seed/retry, retained0.18/success-time/stale assertions, distinct unidentifiable/changed
identity negatives, original quality/reset coverage and SelfTests-only README update.
It models the approved contract instead of weakening it; no production code changed.

Reviewed freeze: latest13 R6a source hashes above plus evidence pre-append SHA256
`c952933fe36d0304572bd90b8ee6ee9a485644bf10d315a9304c18ff1dde73bd`.
Primary matched13/evidence and exact SelfTests/README delta vs R6, eleven other hashes
unchanged; both inspected Python checks PASS exit0,23docs/70links/eight diagnostic
hashes unchanged. Reviewer execution/hash tools denied, NOT RUN/no bypass; handoff
PARTIAL. No source change after review, platform review N/A.

Historical user49/50 failure preserved; corrected50-case execution NOT RUN, runtime
acceptance INCOMPLETE. Next existing-R6 user replaces only SelfTests.lua, preserves
production files/SavedVariables, reloads and `/ca selftest`; stop on errors. No new
data/schema/native UI/field acceptance, reset, gameplay or release inferred.

## R6a corrected user fixture gate PASS — 2026-11-06

User supplies all50 PASS lines and final summary:

```text
CraftArmy: 50 passed; 0 failed (pure injected fixtures, not client API evidence)
```

Corrected fixture gate **PASS** for this user run, including the retained0.18
same-instance assertion and separate unidentified/changed identity transparency
subcases. All other49 cases also PASS. Historical49/50 remains recorded, not current
failure status. No production changes required to achieve this result. No new exact
build/timestamp/installed-byte hashes supplied; local standalone Lua NOT RUN.

Injected UI/menu fixtures still do not prove actual R6 native layout/opacity/quality
glyphs/menu availability/selection/hover. Next user opens `/ca` from existing snapshots,
shares14-column screenshot and tries Profession All→Inscription→All, reporting any
errors. No rescan or gameplay/resource/lifecycle mutation needed. Broader knowledge/
mapping/field acceptance INCOMPLETE, theme/knowledge still deferred. No source change,
new diagnostic run (previous23/23 unchanged), reset or release implied.

## R6 native revised table and dropdown reported working — 2026-11-06

User supplies native two-row screenshot and says “No errors and dropdown appears
to work.” Accept ordinary native render/reported menu operation for this supplied
case; no open menu or exact option-selection sequence is in the capture.

Visible requested changes: separate Name/Realm and Tool/Stat/Enchant columns; full
Multicraft labels without stat amounts or Ench: prefixes; known enchant stat vs lone?
unknown; item/quality glyphs without R#, rarity cell fills, Last Updated relative10m/
8h; native All professions dropdown. Selected-row highlight and controls remain
visible, no obvious overlap. This does not measure exact alpha or independently
verify each displayed data field, all-family/archived filtering or all tooltip paths.

No raw screenshot, character/realm labels stored; no new build/time/source hashes
supplied. No source changes/new API mappings/data migration or release permission.
Existing50/50 gate remains; broader field/native edge/knowledge gates incomplete.
Next primary gathers any further visual feedback; theme/knowledge work stays deferred.

## Table pass accepted; Inscription knowledge investigation — 2026-11-06

User: “Let's call this pass done and move on to the next item.” Accept current R6/R6a
table for supplied native cases and50/50 injected fixtures. No further visual pass;
theme deferred. Broader field/native edge acceptance remains PARTIAL.

Primary read pinned path/frame/trait/specialization/shared-button sources. Findings
and exact references are appended to [Q03](../questions/Q03.md). Native GetRanks
excludes observed unlock maxRanks0/1; adjusted values feed points-spent text. Current
collector omits spend-entry identity/cap and path spend-currency identity. GetNodeCost
has no entry/rank parameter; its current result alone does not prove all-rank unit
spend. Shared talent tiered cost combination is an additional reason not to infer
costs from missing metadata. No settled new numeric eligibility rule is asserted.

Proposed targeted client checks (NOT RUN), each under255 characters including `/dump`:

```text
/dump C_Traits.GetNodeInfo(C_ProfSpecs.GetConfigIDForSkillLine(2913),C_ProfSpecs.GetRootPathForTab(C_ProfSpecs.GetSpecTabIDsForSkillLine(2913)[1]))
/dump C_Traits.GetEntryInfo(C_ProfSpecs.GetConfigIDForSkillLine(2913),C_ProfSpecs.GetUnlockEntryForPath(C_ProfSpecs.GetRootPathForTab(C_ProfSpecs.GetSpecTabIDsForSkillLine(2913)[1])))
/dump C_Traits.GetEntryInfo(C_ProfSpecs.GetConfigIDForSkillLine(2913),C_ProfSpecs.GetSpendEntryForPath(C_ProfSpecs.GetRootPathForTab(C_ProfSpecs.GetSpecTabIDsForSkillLine(2913)[1])))
```

User opens own Midnight Inscription Specializations, no pending changes, executes
separately without spending/unlocking/switching profession, shares outputs and first
tree's main-node points display or locked state. No helper globals, DB writes,
installation, rescan or full diagnostic export needed. Nil/error stops investigation;
no fallback-to-zero. Sampling does not establish all35 paths/shared-currency scope or
all-rank costs. Numeric bars remain unknown pending justified rule/contract and client
comparisons. Production code/tests/diagnostics frozen; no new implementation queue,
delegation, game action, Git or release. Only planning/evidence docs changed.

Primary validation after these doc updates: `python3 tools/check_dashboard.py` PASS
(23Markdown documents/71local links/eight diagnostic hashes unchanged). Read-only
SHA256 comparison PASS for all13 latest R6a frozen files; proposed command lengths
147/183/182 characters. These are structural/content checks only; no Lua or client
query executed and no new fixture result claimed.

## First-root knowledge metadata supplied; compare like paths — 2026-11-06

User executed the three proposed dumps and supplied their outputs. Sanitized game
metadata only, no character/realm identifiers:

| Observation | Value |
| --- | --- |
| First tab root/node |106192, type1, available |
| Purchased/current/active ranks |1/1/1; increased0 |
| Node max/total max |31/31 |
| Entries |130942 and130933 |
| Committed/active entry |Only130942 committed; active130942 rank1 |
| Next entry |130933 rank1 (not evidence of a purchased spend rank) |
| Unlock entry |maxRanks1/type9/definition135743; entryCost={} |
| Spend entry |maxRanks30/type7/definition135734; entryCost={} |
| User's native report |Perfected Products30/30 |

Pinned native GetRanks produces0/30 for106192: positive current1 minus unlock1,
max31 minus unlock1. This validates observed metadata for a separate unlock/spend
capacity, not the supplied30/30 native comparison. Earlier diagnostics associated
106192 with Blueprints,109660 with Perfected Products; current first-tab name was
not dumped. API first-tab order and currently selected native tab are distinct.
Do not attribute30/30 to106192, change arithmetic to fit it or mark UI agreement PASS.

Next user read-only query (NOT RUN):

```text
/dump C_ProfSpecs.GetTabInfo(C_ProfSpecs.GetSpecTabIDsForSkillLine(2913)[1])
```

Compare the named first tab's main/root node points display, clarify whether30/30
was from a different tab. No new scan/install/spending/unlocking required. Explicit
empty entryCost is limited to entry-specific metadata; node costs, spend currency,
stable unstaged boundaries, all35-path cost rules/shared reconciliation are not
established. No exact new build/time/source hashes supplied. No agent Lua/client
execution, new test pass, numeric eligibility or production source change.

## Blueprints0/0 reported; native counter identification pending — 2026-11-06

User's exact follow-up: “Blueprints0/0”. No requested tab-info dump or native capture
included. This is a user-reported display value, not proof of a zero-capacity path;
prior root106192 metadata/source arithmetic still gives0/30. Do not substitute0/30
for the report, infer a typo or claim a same-node/same-state API/UI defect. Request
native Blueprints screenshot with main/root node selected and its points counter
visible, before further queries. No source/test/data changes or numeric eligibility;
no gameplay actions required beyond ordinary UI selection. Store sanitized findings
only if a screenshot is supplied, not character/realm identifiers or raw captures.

## Blueprints0/30 correction and native agreement — 2026-11-06

User explicitly says0/0 was a typo and supplies native Midnight Inscription
Specializations with Blueprints tab selected and main-node detail **BLUEPRINTS0/30**.
This is visible same-path agreement with the supplied root106192 metadata and pinned
GetRanks adjustment (current1−unlock1)/(max31−unlock1). Native main-node rank/cap
comparison **PASS for this sample**, not full tree allocation/capacity or all35 paths.
Prior0/0 remains correction history, not an unresolved native/API mismatch. Perfected
Products30/30 is a separate reported node. No GetTabInfo dump was supplied; the native
label is visible. Top-right available counter shows0, without proving currency ID or
unstaged API state. No raw capture or character/realm identifiers stored.

Next proposed read-only client queries, NOT RUN (lengths76/49/235 characters):

```text
/dump C_Traits.GetNodeCost(C_ProfSpecs.GetConfigIDForSkillLine(2913),106192)
/dump C_ProfSpecs.GetSpendCurrencyForPath(106192)
/run local c=C_ProfSpecs.GetConfigIDForSkillLine(2913);for _,t in ipairs(C_ProfSpecs.GetSpecTabIDsForSkillLine(2913)) do for _,v in ipairs(C_Traits.GetTreeCurrencyInfo(c,t,true)) do print(t,v.traitCurrencyID,v.quantity,v.spent) end end
```

Own Midnight Inscription open, no pending changes, no spending/unlocking; stop/report
any error. Last command prints **tabID, traitCurrencyID, quantity, spent** for each
returned row using excludeStagedChanges=true. No helper globals/DB writes, automatic
profession switching or gameplay actions. Inspect repeated shared currency rather
than add repeated spent values. All-rank/other-path cost eligibility, full traversal,
explicit stable unstaged boundaries and shared applicability/reconciliation remain
gated. No production/test/source changes or new fixture pass; no exact build/time/
installed hash evidence or agent client execution implied.

## Root cost and four-tab currency evidence received — 2026-11-06

User supplies all three requested query results. Root106192 node costs:
`{{ID=3902,amount=1}}`; path spend currency3902. One sampled current unit cost is now
observed, not an all-rank/all35-path cost rule. Currency rows follow; notation is
**traitCurrencyID:quantity/spent**, preserving supplied per-tab order.

| Tab | Count | Returned currency rows |
| --- | --- | --- |
|1122|11|3902:0/264;3900:0/4;3912:0/1;3911:0/1;3910:0/0;3909:0/0;3908:0/0;3907:0/0;3906:0/0;3905:0/0;3904:0/0|
|1124|6|3902:0/264;3900:0/4;3923:0/3;3922:0/0;3921:0/0;3920:0/0|
|1182|11|3902:0/264;3900:0/4;4204:0/2;4203:0/3;4202:0/0;4201:0/0;4200:0/0;4199:0/3;4198:0/0;4197:0/0;4196:0/0|
|1125|15|3902:0/264;3900:0/4;3936:1/0;3935:0/0;3934:0/0;3933:0/0;3932:0/0;3931:0/0;3930:0/0;3929:0/0;3928:0/0;3927:0/0;3926:0/0;3925:0/0;3924:0/0|

All four tabs repeat3902 quantity0/spent264. This supports a single shared spent
reference264 for sampled currency3902, not a four-times1056 sum. Historical260 stays
historical.3900 also repeats spent4 but is not proven to be purchased knowledge;
keep it and the remaining currencies separate until applicability is established.
No per-tree purchased totals/capacities or all-path spend-currency identity proven.
True in GetTreeCurrencyInfo requests committed currency values but does not establish
explicit unstaged/stable boundaries for node/entry collection. No exact fresh build/
time/installed hashes, new fixture result or agent client execution inferred.

Primary inspected current Collectors.lua214–217: raw currencies are copied only
through math.min(#currencies,8), without a truncation marker. Three supplied tabs
exceed8. Shared3902 appears first here, but that ordering must not become a default.
This is a capture-completeness gap; production numeric totals remain disabled, so
no wrong displayed numeric total is demonstrated. Existing snapshots untouched.

Proposed next user-approved scope: bounded read-only full-tree evidence command,
capturing all35 paths' node/unlock/spend metadata, node/entry costs and spend currency,
complete bounded currency rows and explicit coverage/staging/stability/failure state.
Compare derived candidate totals with shared3902 once without asserting production
eligibility from current costs alone. Await approval before preparing executable
queue/delegating implementation. No snapshot/DB writes, numeric-bar enablement,
diagnostic-baseline changes, installations, automatic spending or release. Planning/
evidence docs only changed this turn.

## K1 read-only knowledgecheck authorized / pre-edit base — 2026-11-06

User answers Yes to adding `/ca knowledgecheck`. TASKS K1 pieces26–28 READY; primary
verified latest13 R6a hashes still match and KnowledgeCheck.lua does not exist before
handoff. New isolated module + command/copy window/fixtures and exact packaging/check
updates only. Snapshot collector/Core/accounting/table/diagnostics remain frozen;
no numeric eligibility inference. Capture includes up to64currencies per tab or
explicit omissions; provisional reconciliation never asserts all-rank cost proof.
One writer exclusively owns K1 manifest/status/delivery while running. Primary owns
PLAN/Q03/reviews and will persist independent findings. Approved local structural
checks and already-present Lua5.1 only; no install/gameplay/Git/release. Normal raw
currency first8 gap remains documented separately. No K1 execution/native PASS yet.

## T02 K1 isolated knowledge evidence delivery — 2026-11-06

**PARTIAL**, pieces26–28 delivered for independent read-only verification, then
primary-coordinated user fixtures/capture. No implementation acceptance, installed
byte identity, target-client API behavior or release is inferred. Historical R6a
user50/50 and diagnostic23/23 remain scoped prior results, not a K1/new diagnostic run.

Changed exactly the eight assigned manifest paths: new `CraftArmy/KnowledgeCheck.lua`,
Commands.lua, SelfTests.lua, CraftArmy.toc, tests/dashboard.lua, tools/check_dashboard.py,
dashboard README/evidence, plus K1 statuses/current run state/new delivery in TASKS.
No other source/schema/diagnostic/planning/review history changed. One synchronous
writer, no children. No Git repository/base; no staged/unstaged/untracked comparison
is available. No installation, alternate runtime, live WoW/API/DB testing, gameplay,
resource spending, automatic scans/timers, uploads, Git mutation or release occurred.
Platform review N/A (no hosting/CI/IAM/release boundary).

### K1 delivered boundaries and analysis

- `Capture(env,runtimeCollector)` requires an existing bounded integer revision/serial
  token. It creates `Collectors.New(env,nil)` solely for guarded Context/Same; the
  ephemeral Context's own roster is never the runtime collector's roster. No Scan,
  Request, Login, Core.Apply, Knowledge.Evaluate, item-load, freshness, pending or
  real DB operation occurs. Invalid/future saved data is not opened/reset by the new
  pre-Login command branch. The command retains only ephemeral report text/window.
- Own visible ready primary Midnight Inscription2913, supported identity/config/
  sourceCounter, current-player attribution and matching start/end Context plus
  unchanged runtime revision/serial are required. Staging must be explicitly false
  in both Context tokens and the additional protected boundary staging reads. Missing,
  staged, invalidated or changing inputs prevent passing complete totals. Early unsafe
  context failures record blocked/not-attempted boundaries, never synthesize an end.
- Bounds are8tabs,64paths/tree,16children/path,32IDs per node entry list/increased map,
  64currency rows/tree and16costs per node/entry. Dense validation inspects at most
  limit+1 keys and at most limit indexed positions; metatable/sparse/keyed/invalid/
  duplicate/truncated/nil/unsupported/error states are explicit. Counts describe
  discovered valid IDs, globally unique captured paths, and observed per-tab list
  keys (a lower bound on truncated key lists), not unknowable omitted descendants.
  Cycles/duplicate children/shared tab ownership block completeness. No GetTreeNodes
  prefix is used. Currency order and original row index/status are retained, including
  a shared row beyond8/last. Actual K1 runtime omissions have NOT been measured.
- Whitelisted raw node ranks/type/flags/availability/active+next entries, entry IDs/
  committed IDs/increased map, unlock/spend entry metadata and separate entryCost
  lists, node costs, spend currency and all bounded per-tab committed currency rows
  are captured. Nil entryCost remains unavailable, explicit{} remains observed empty.
  IDs are1..2147483647; ranks/currency/cost amounts0..2147483647, native-aware finite
  integers before arithmetic. False/zero survive where typed. Nullable maxQuantity
  and active/next-entry absence retain explicit nil status.
- Build version/build/interface use protected multi-return GetBuildInfo; locale and
  both server times are protected reads. Only sanitized <=256-byte game tab labels,
  numeric allowed identities, source metadata and rank/cost evidence are exported.
  No character GUID/name/realm, gear, saved snapshots, runtime reason or error payload
  is serialized. Every failure records a bounded safe status/reason instead.
- Candidate arithmetic is confined to this module/report: mixed unlock0/1, distinct
  unlock/spend entries with no third node entry, coherent rank/capacity guards,
  current==purchased and no increases. Committed/map/active/next IDs must belong to
  those entries; nextEntry.rank is raw evidence, never purchased points. Candidate
  path/tree/grand results remain explicitly NOT verified all-rank costs. Aggregate
  publication requires complete dependent capture and stable unstaged boundaries.
- Current unit-cost consistency is separate: both observed entryCost lists, the node
  costs and spend currency are required; empty/multiple/alternate/zero/non-unit/
  unavailable evidence is distinguished. Current consistency NEVER proves other
  ranks. Provisional shared reconciliation requires all candidate guards, a common
  spend currency from every path and a unique identical spent/quantity row in every
  tab; spent is compared ONCE. Other currencies stay separate, mismatch does not
  adjust ranks. A match does not change costRule, bars or production eligibility.
- Pure deterministic Format returns text plus effective summary, capped256KiB and
  4096lines with4096bytes reserved for the final summary/header/footer. Detail/key/
  line/byte clipping marks capture incomplete and reconciliation unknown; aggregate
  success never survives clipping. Capture also applies that effective clipping state
  to its report. Begin/end version1 warnings, bounds, completeness and no-write notice
  remain present. Protected unexpected capture failures produce incomplete evidence.
- The copy UI is native/injected, lazy and explicit out of combat, with multiline
  scrolling, select-all/manual copy, Escape/Close, immutable restored text and repeat
  replacement. No clipboard/file/network API or timer is used. Combat/unknown safety
  makes no capture/window/focus/deferred work. Missing UI methods return a clear
  limitation plus the report/text to the caller, not a chat dump masquerading as full
  evidence. Native multiline sizing/scroll/copy behavior is still unverified.
- Normal Collectors.lua first8 raw currency truncation remains intentionally unchanged;
  K1 bypasses that collector path, not a production snapshot correction. Same schema1,
  Version0.2.0-mvp, Interface120105; exact nine-Lua order inserts KnowledgeCheck after
  Collectors/before ViewModel in TOC and standalone runner. Checker now requires15
  paths without weakening old metadata/path/DB/dependency/docs/diagnostic protections.

Source pin remains `297d7aaaa736f346b3e036f38ee088eaf7f8c07f`, as recorded in Q03.
Implementer also read the pinned SharedTraitsDocumentation.lua via read-only webfetch:
`https://raw.githubusercontent.com/Gethe/wow-ui-source/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/SharedTraitsDocumentation.lua`.
Its node fields and read signatures corroborate the projection; TraitEntryInfo does
not document entryCost. Neither that omission nor nil is evidence of zero cost. This
source-text read is not installed-client/API evidence. Q03/PLAN were not edited.

### K1 regression definitions — 66, NOT RUN

All50 prior fixture cases/assertions retained;16 appended K1 definitions cover:

1. Four tabs9/4/9/13 including late/locked/mixed unlock0/1 paths, root1/max31 and
   unlock1/spend30 candidate0/30, next rank1 not counted; full11/6/11/15 currencies,
   shared row last, provisional264 once, other3900 excluded, source metadata/privacy.
2. Explicit empty vs missing entryCost, variable/entry-specific/multiple/zero/alternate/
   non-unit/empty current node costs; no all-rank proof or numeric enablement.
3. Shared mismatch, conflicting spent/quantity, duplicate/missing rows, different path
   spend IDs, other-currency spent ignored rather than added.
4. Rank/entry/capacity guards, missing/third/same/foreign entries and increased maps;
   candidate eligibility remains distinct from raw capture completeness.
5. Start/end staging nil/true/nonboolean/errors, with payload privacy.
6. Unsafe/closed/linked/guild/member/NPC/changing/combat/unready/nonprimary/unsupported
   contexts, missing config/sourceCounter/roster/safety and unavailable runtime token.
7. Changed player/config/sourceCounter/runtime revision/serial or closed finish.
8. Missing/nil/throwing APIs and an unexpected protected failure, no secret export.
9. Actual NaN/±infinity, negative/fraction/nonnumber/overflow IDs/ranks/maps/costs/
   currencies, native guard retained with no real math mutation.
10. Sparse/keyed/metatable/invalid/duplicate arrays/maps and typed row rejection.
11. Every capture limit, inspected<=limit+1, bounded output prefixes,64/65 paths and
    explicit omitted coverage rather than a smaller complete denominator.
12. Cycles/duplicate children/shared ownership and one global node query per ID.
13. Byte and line output caps, reserved end summary, no clipped success, pure Format.
14. Pre-Login command with invalid DB/missing runtime, no dashboard refresh, brief chat,
    help usage and report returned when native UI is absent.
15. Strict native-widget model, scrolling content vs viewport, selection/manual-copy
    state, repeat replacement, Escape/Close/OnHide, edit restoration and UI failure.
16. Combat makes no capture/UI/focus/timer/deferred work; explicit repeat reuses the
    copy window and restores correct report contents after leaving combat.

Successful/failed repeated capture definitions deep-check the entire reachable runtime
collector/DB graph (including methods/table identities) and install traps on mutating
collector/gameplay/item/timer/Apply/Evaluate paths. Traps and tracked widgets are test
definitions, NOT executed no-mutation or real-client API evidence. Fake methods were
extended explicitly, with no permissive unknown-method catch-all; prior assertions
remain intact. No real saved data, real game API or global math mutation in fixtures.

### K1 implementer checks and comparison

Scripts/runners inspected first. Actual commands/results (implementer; Python exit0):

```text
python3 tools/check_dashboard.py
PASS: 15 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 71 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated

python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
```

No structural baseline failure. Actual runtime gate (exit0):

```sh
if command -v lua5.1 >/dev/null 2>&1; then
  lua5.1 tests/run.lua
  lua5.1 tests/dashboard.lua
else
  printf '%s\n' 'NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH'
fi
```

Output: `NOT RUN: lua5.1 tests/run.lua; lua5.1 tests/dashboard.lua — lua5.1 absent from PATH`.
Neither Lua suite executed. Lua syntax/fixtures, `/ca selftest`, `/cad selftest`, addon
load/native UI/copy window, actual API capture and no-mutation/client behavior are
**NOT RUN** by implementer. No runtime installed/downloaded/substituted. Historical
user50/50 and diagnostic23/23 do not validate these changed files or66-case suite.

Read-only pre-edit SHA256 comparison matched all13 latest R6a hashes and confirmed
KnowledgeCheck.lua absent. Current comparison/count command (exit0):

```sh
python3 - <<'PY'
from pathlib import Path
import hashlib,re
s=Path('docs/dashboard/evidence.md').read_text().partition('### R6a current13 source freeze')[2]
base=re.findall(r'^([0-9a-f]{64})  (\S+)$',s,re.M)[:13]
allowed={'CraftArmy/CraftArmy.toc','CraftArmy/Commands.lua','CraftArmy/SelfTests.lua','tests/dashboard.lua','tools/check_dashboard.py','docs/dashboard/README.md'}
changed={p for h,p in base if hashlib.sha256(Path(p).read_bytes()).hexdigest()!=h}
assert len(base)==13 and changed==allowed,changed
print('PASS: exactly six allowed prior13 deltas; seven frozen hashes unchanged')
print('Fixture definitions:',len(re.findall(r'^case\(',Path('CraftArmy/SelfTests.lua').read_text(),re.M)))
PY
```

Output: `PASS: exactly six allowed prior13 deltas; seven frozen hashes unchanged`
and `Fixture definitions: 66`. Frozen seven are Core/Data/Knowledge/Collectors/
ViewModel/Dashboard/schema. Diagnostic eight-hash baseline separately matches through
the checker. Counts/hashes are not Lua/API validation.

### K1 in-memory checker negative sentinels

Actual `python3 - <<'PY'` command below completed exit0. It runs the inspected checker
against read-only in-memory Path mocks, without changing fixture/source files, creating
a local test file or executing Lua. Positive exact nine-Lua/15-path control and15
negative scenarios PASS; this tests checker protections, not game API semantics.
The schema sentinel means required schema documentation/unchanged diagnostic source
hash, NOT a new claim that this structural script parses production Lua schema rules.

```python
from pathlib import Path
from unittest.mock import patch
import runpy
m=runpy.run_path('tools/check_dashboard.py')
root=m['ROOT']; addon=m['ADDON']; toc=addon/'CraftArmy.toc'
real_file,real_text,real_bytes=Path.is_file,Path.read_text,Path.read_bytes
original=toc.read_text()
scenarios=[
 ('missing new module',{'missing':addon/'KnowledgeCheck.lua'},'missing required file: CraftArmy/KnowledgeCheck.lua'),
 ('required schema document',{'missing':root/'docs/dashboard/schema.md'},'missing required file: docs/dashboard/schema.md'),
 ('wrong load order',{'toc':original.replace('Collectors.lua\nKnowledgeCheck.lua','KnowledgeCheck.lua\nCollectors.lua')},'exact nine-file manifest'),
 ('duplicate module',{'toc':original+'KnowledgeCheck.lua\n'},'exact nine-file manifest'),
 ('escaping TOC path',{'toc':original.replace('KnowledgeCheck.lua','../outside.lua')},'unsafe/missing TOC entry'),
 ('unchanged version gate',{'toc':original.replace('Version: 0.2.0-mvp','Version: 9.9.9')},'expected Version'),
 ('unchanged interface gate',{'toc':original.replace('Interface: 120105','Interface: 1')},'expected Interface'),
 ('isolated DB metadata',{'toc':original.replace('SavedVariables: CraftArmyDB','SavedVariables: OtherDB')},'expected SavedVariables'),
 ('additional saved variables',{'toc':original+'## SavedVariablesPerCharacter: OtherDB\n'},'additional saved variable'),
 ('hard dependency',{'toc':original+'## Dependencies: OtherAddon\n'},'dependencies not allowed'),
 ('optional dependency',{'toc':original+'## OptionalDeps: OtherAddon\n'},'dependencies not allowed'),
 ('production DB isolation',{'extra_db':True},'production saved-variable references inconsistent'),
 ('diagnostic source/schema hash',{'diagnostic_bytes':True},'diagnostic baseline changed'),
 ('diagnostic reviewed hash count',{'diagnostic_evidence':True},'expected eight reviewed diagnostic hashes'),
 ('retained documentation links',{'broken_link':True},'broken local link'),
]
assert len(m['ORDER'])==9 and len(m['REQUIRED'])==15
assert m['ORDER'][3:6]==['Collectors.lua','KnowledgeCheck.lua','ViewModel.lua']
assert not m['check']()[0],m['check']()[0]
for name,changes,expected in scenarios:
 def is_file(p):
  if p==changes.get('missing'): return False
  return real_file(p)
 def read_text(p,*a,**kw):
  if p==toc and 'toc' in changes: return changes['toc']
  text=real_text(p,*a,**kw)
  if changes.get('extra_db') and p==addon/'KnowledgeCheck.lua': text+='\nlocal other=ForeignDB\n'
  if changes.get('diagnostic_evidence') and p==root/'docs/diagnostics/evidence.md': text='no reviewed hashes'
  if changes.get('broken_link') and p==root/'docs/dashboard/README.md': text+='\n'+chr(91)+'invalid'+chr(93)+'(missing-k1-sentinel.md)\n'
  return text
 def read_bytes(p):
  data=real_bytes(p)
  if changes.get('diagnostic_bytes') and p==root/'CraftArmy_Diagnostics/Core.lua': return data+b' schema mutation sentinel'
  return data
 with patch.object(Path,'is_file',is_file),patch.object(Path,'read_text',read_text),patch.object(Path,'read_bytes',read_bytes):
  errors,_,_=m['check']()
  assert any(expected in error for error in errors),(name,errors)
 print('PASS in-memory negative sentinel:',name)
print('PASS: 15 negative checker sentinels; exact nine-Lua/15-path positive control; no files changed')
```

### K1 current14 source freeze

Actual read-only command (implementer, exit0):

```sh
sha256sum CraftArmy/CraftArmy.toc CraftArmy/Core.lua CraftArmy/Data.lua CraftArmy/Knowledge.lua CraftArmy/Collectors.lua CraftArmy/KnowledgeCheck.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/SelfTests.lua CraftArmy/Commands.lua tests/dashboard.lua tools/check_dashboard.py docs/dashboard/README.md docs/dashboard/schema.md
```

```text
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
01dff992dff95787e2bc7cd257a9243c2e4eacd92193aea97c83681bd33e5615  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
1bf9930ea8272e46b6147ba96afcb16467a915d1a10e5295a68db1f2a9f9c4e0  CraftArmy/Knowledge.lua
6cca77eb72148d49adda1ebb391649c51c11859c4bd9cd347775004937e45138  CraftArmy/Collectors.lua
0583a6ec9966f19bb53f506042b48fb8f688e3e0117f67187205ddbd45d47da3  CraftArmy/KnowledgeCheck.lua
195de6fb5ae289e3bdb543b915c6bcbaac8b3c551e695ac1487b1bf0b3f85b55  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
347348ed578dd3899dcdf2b9b20d8c78bbb68da1ea99588e6c6622363b369227  CraftArmy/SelfTests.lua
fb4bdcd48b0f53ecdfde18b7928fa967959d5383f0ee6e8b32a5e0edba639b70  CraftArmy/Commands.lua
601990e4a67b4fc3fb048bbf86cb8337974dd3323e771ea20adfcfd18a8edab4  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
9c1690a6e7eac46d910346ff55c3b86deea4a98d70a7c8a91b11b99a6386a4b3  docs/dashboard/README.md
5d5f0619d264c67abd8aa9ab202957f1b2753e17303f68f433978fae85bd288d  docs/dashboard/schema.md
```

Final evidence SHA256 is recorded in the TASKS K1 delivery, avoiding self-hashing.
**Resume primary:** independently verify this frozen K1 manifest/66 definitions,
especially capture immutability, status/coverage/stability, formatter clipping and
native copy UI boundaries; persist findings before user recommendations. Then user
backup/four-addon-file update/reload, actual66-case `/ca selftest`, and only after
satisfactory fixtures own ready unstaged Inscription `/ca knowledgecheck`, manual
review/copy. No fresh diagnostic run claimed or required by this delivery.

Remaining factual gates: actual full-path/currency capture and native copy/load
behavior; source/client all-rank unit-cost justification and native path/tree/shared
comparison; seven other Midnight identity mappings, authoritative unlearning,
base/enchant attribution and other field/cap/role/lifecycle/native edge checks.
No numeric eligibility, acceptance/release or Q03/Q04 closure inferred. Theme remains
deferred; unknown fields are still incomplete required features, not passed by safety.

### K1 final durable-document recheck

After appending this delivery/freeze, the documented sentinel block was replayed
verbatim from this file (exit0; all15 negative scenarios and positive control PASS):

```sh
python3 - <<'PY'
from pathlib import Path
text=Path('docs/dashboard/evidence.md').read_text().partition('### K1 in-memory checker negative sentinels')[2]
source=text.partition('```python\n')[2].partition('\n```')[0]
assert source.startswith('from pathlib import Path')
exec(compile(source,'<K1 in-memory checker sentinels>','exec'))
PY
```

Both `python3 tools/check_dashboard.py` and `python3 tools/check_diagnostics.py`
were rerun after the appended docs, exit0, same PASS output above (23docs/71links/
eight diagnostic hashes unchanged). Read-only Python SHA256/set/count assertions
also passed:14 unique current freeze paths exactly equal prior13 plus KnowledgeCheck,
every current hash matches, exactly the six permitted prior13 deltas, seven old files
unchanged and66 definitions. No Lua/client result was produced by any of these checks.

## K1 independent static inspection / comparison gap — 2026-11-06

Verifier inspected Capture/Format/Show, pre-Login command branch, appended16 fixtures,
packaging/checker/README/contract and pinned APIs. No concrete blocking source defect
identified; isolation, privacy, coverage/staging, bounds/clipping and provisional-only
arithmetic appear consistent. Handoff PARTIAL / acceptance INCOMPLETE: reviewer
execution denied, no bypass; no independent pre-edit source/textual comparison to
establish retention of every old assertion. Primary must close that comparison gap
before advancing. This is not full regression/native approval.

Reviewed freeze: K1 current14 above and evidence pre-review SHA256
`185ea0d61444f9d82a18cdeb7291000927d923478309a11cdd7b67d11252376f`.
Primary separately ran both inspected Python checks PASS23docs/71links/eight unchanged
diagnostic hashes, matched14/evidence/exact six permitted R6a deltas and66definitions.
Reviewer attempted both Python checks but permission denied before either ran; those
PASS results are primary/implementer evidence only. Writer's15 negative sentinels +
positive control remain writer-attributed. Reviewer found pinned API signatures match;
missing entryCost is not treated as empty. No source changes from review.

Primary next obtains preserved pre-edit bytes or a hash-verified reconstruction/diff,
especially SelfTests, and sends focused follow-up; snapshot/production source frozen.
Actual66-case results and native complete-report scrolling/copy/API capture remain
NOT RUN; injected text-height model is not native proof. All-rank eligibility still
unverified; platform review N/A; no install/gameplay/Git/release approval implied.

## K1 hash-verified original-source reconstruction — 2026-11-06

Implementer reports no saved originals, but identifies exact inverse edits for
SelfTests. Primary independently reconstructs ALL SIX changed prior files in memory
and verifies each against the recorded R6a SHA256. No implementation files written;
the original-byte comparison gap can now be reviewed using this reproducible recipe.
Current source14 freeze remains unchanged. No Lua/runtime evidence is implied.

```python
from pathlib import Path
from hashlib import sha256
import re
text=Path('docs/dashboard/evidence.md').read_text()
rows=re.findall(r'^([0-9a-f]{64})  (.+)$',text,re.M)
oldhash={name:digest for digest,name in rows[-27:-14]}
reconstructed={}
p='CraftArmy/SelfTests.lua'
lines=Path(p).read_bytes().splitlines(keepends=True)
old=b'    function methods:SetText(value) assert(type(value)=="string","fake SetText needs real text"); self.labelText=value end\n'
reconstructed[p]=b''.join(lines[:684]+[old]+lines[689:731]+lines[738:1407]+lines[1812:])
p='CraftArmy/Commands.lua'; t=Path(p).read_text()
start=t.index('        if command=="knowledgecheck" then\n')
end=t.index('        self:Login()\n',start)
reconstructed[p]=(t[:start]+t[end:]).replace('; /ca knowledgecheck (read-only provisional Inscription evidence, out of combat).','.').encode()
p='CraftArmy/CraftArmy.toc'
reconstructed[p]=Path(p).read_bytes().replace(b'KnowledgeCheck.lua\n',b'')
p='tests/dashboard.lua'
reconstructed[p]=Path(p).read_bytes().replace(b'"Collectors","KnowledgeCheck","ViewModel"',b'"Collectors","ViewModel"')
p='tools/check_dashboard.py'
reconstructed[p]=Path(p).read_bytes().replace(b'"Collectors", "KnowledgeCheck", "ViewModel"',b'"Collectors", "ViewModel"').replace(b'exact nine-file manifest',b'exact eight-file manifest').replace(b'PASS: 15 required files;',b'PASS: 14 required files;')
p='docs/dashboard/README.md'; t=Path(p).read_text()
start=t.index('### K1 knowledge evidence (current; user only, after independent review)\n')
end=t.index('### R6a fixture-only correction',start); t=t[:start]+t[end:]
t=t.replace('TOC and nine Lua files','TOC and eight Lua files').replace('- `/ca knowledgecheck` captures read-only, provisional Midnight Inscription evidence\n  into a local copy window, out of combat only. No scan or snapshot write is required.\n','').replace('### R6a fixture-only correction (historical update instructions)','### R6a fixture-only correction (current; user only, after focused review)')
reconstructed[p]=t.encode()
for p,data in reconstructed.items():
    assert sha256(data).hexdigest()==oldhash[p],p
    print('PASS exact R6a original bytes:',p,len(data),sha256(data).hexdigest())
```

Primary executed the equivalent recipe plus unified-diff generation, exit0. Baseline
bytes / exact matching R6a digests:

| File | Bytes | R6a SHA256 |
| --- | --- | --- |
|SelfTests.lua|95027|`ba8580e7e24adadd31bfd4a01d3a6c843835cfeea4328140c6282761c209efdc`|
|Commands.lua|2903|`b436b0e56cb605b5dfba85ebc95da9f94abd7fdeecf8141bc30dedbbc751652d`|
|CraftArmy.toc|257|`5f0ba92ce9aac13edcece96e4a063c7ea3344667ceba85b56a028640f42daa1b`|
|dashboard.lua runner|543|`75a65ba61fa53c2b8f681196e64e059c7640c3d0c0a00c31b55f6156c55897a0`|
|check_dashboard.py|5375|`0b6da6c9887df3aec68744bc37eeb76809345d5c149ba11ee3a6be5ab9d7ce6a`|
|README.md|19864|`40aedafd52ce8e8a0527c7c4ab2f2f220f5fb13b997d94759b57cfee1a601428`|

Exact original50-prefix diff (K1 helpers/16 cases are appended at current1408–1812;
original Tests.Run tail remains byte-identical). No old case body/assertion changed:

```diff
@@ -682,7 +682,11 @@
     function methods:CreateFontString(_,_,font) return widget("FontString",self,font) end
     function methods:CreateTexture() return widget("Texture",self) end
     function methods:SetScript(event,fn) self.scripts[event]=fn end
-    function methods:SetText(value) assert(type(value)=="string","fake SetText needs real text"); self.labelText=value end
+    function methods:SetText(value)
+        assert(type(value)=="string","fake SetText needs real text"); self.labelText=value
+        if self.multiline then local _,n=value:gsub("\n",""); self.height=(n+1)*14 end
+        if self.multiline and self.scripts.OnTextChanged then self.scripts.OnTextChanged(self,false) end
+    end
     function methods:GetText() return self.labelText end
     function methods:SetSize(x,y)
         assert(C.Finite(x) and x>0 and C.Finite(y) and y>0,"invalid fake widget size")
@@ -725,6 +729,13 @@
         local key=name
         methods[key]=function(self,...) self.style[key]={...} end
     end
+    function methods:SetMultiLine(v) eq(type(v),"boolean"); self.multiline=v end
+    function methods:SetFontObject(v) eq(type(v),"string"); self.fontObject=v end
+    function methods:SetMaxLetters(v) assert(C.Integer(v)); self.maxLetters=v end
+    function methods:SetScrollChild(v) eq(v.parent,self); self.scrollChild=v end
+    function methods:SetFocus() self.focused=true end
+    function methods:ClearFocus() self.focused=false end
+    function methods:HighlightText(a,b) self.selection={a or 0,b or #self.labelText} end
```

Other inverse edits above prove scope exactly: Commands inserts pre-Login branch and
help suffix only; TOC/runner add module immediately after Collectors; checker changes
exact module order/count/error wording only; README adds K1 command/checklist, updates
nine-file count and marks R6a checklist historical. No original docs/source omissions.
Primary supplies this evidence to the reviewer for focused comparison follow-up;
reviewer denied checks remain NOT RUN unless subsequently actually authorized/run.

## K1 final primary-persisted static review — 2026-11-06

Focused verifier follow-up **COMPLETE**, static acceptance **PASS**, runtime acceptance
**INCOMPLETE**. Prior comparison gap CLOSED. Reviewer inspects inverse recipe/diff and
actual modified source; primary's six exact original-digest matches establish R6a
bytes. Original50 case bodies/assertions and Tests.Run tail retained; prefix edits
only explicit fake-widget methods, multiline-only SetText height/event behavior.
No assertion weakening, permissive fallback or blocking static finding. No source
fix requested. Prior isolation/privacy/coverage/stability/clipping/provisional-only
findings stand. Source target unchanged K1 current14; SelfTests baseline
`ba8580e7e24adadd31bfd4a01d3a6c843835cfeea4328140c6282761c209efdc`, target
`347348ed578dd3899dcdf2b9b20d8c78bbb68da1ea99588e6c6622363b369227`.

Reviewer read-only, no commands retried/executed or files written during follow-up;
all original reconstruction/hash/diff execution and Python PASS attribution remains
primary/implementer, not reviewer. Earlier pre-review evidence digest is historical
because documentation was appended, not a claim the whole document stayed identical.
Platform review N/A. No changed implementation after review or release authorization.

Next user only: quit/back up, add KnowledgeCheck.lua and replace CraftArmy.toc,
Commands.lua,SelfTests.lua in existing addon; preserve all SavedVariables/diagnostics/
other files. Reload and `/ca selftest`, report66-case actual summary/failures. Primary
records satisfactory results BEFORE own ready unstaged native `/ca knowledgecheck`
capture and complete long-report scrolling/manual-copy validation. Standalone Lua,
new user66-case/native APIs/capture/copy remain NOT RUN. All-rank cost semantics and
numeric eligibility remain unverified, normal first8 collector behavior unchanged;
K1/T02 overall acceptance PARTIAL. No saved-data reset or gameplay mutation required.

## K1 user66-case fixture gate PASS — 2026-11-06

User supplies summary `CraftArmy: 66 passed; 0 failed (pure injected fixtures, not
client API evidence)`. Accept injected fixture gate for this user run; individual
PASS lines/current build/time/installed hashes not supplied. No agent/standalone Lua
execution or native API/UI result inferred. Static review PASS remains separate.

Next own ready Midnight Inscription Specializations, out of combat/no pending changes,
explicit `/ca knowledgecheck`. User manually selects/copies/reviews the full report,
including BEGIN/END markers/end summary, and shares text or attachment plus any errors.
No `/ca scan`, spending/unlocking, DB reset or source update required. Native report
completeness/scroll/copy/staging/currency evidence remains pending; matching candidate
totals never establish all-rank cost semantics or enable numbers. Existing diagnostic
23/23 remains latest historical run, not rerun by this summary. No source changes.

## K1 complete native Inscription report received — 2026-11-06

User supplies the full version1 BEGIN-to-END text, including all path/currency rows
and END SUMMARY. Source pin297d7aaaa736f346b3e036f38ee088eaf7f8c07f; observed Retail
12.1.5/build70783/Interface120105/enUS, both server times1793922479. Same config and
sourceCounter7 at both boundaries, staged=false and separate stagingRead=false at both;
runtime revision6/serial3 unchanged. No character/GUID/realm/raw screenshot stored;
dynamic config ID omitted here because equality, not identity, is relevant.

CaptureComplete=true/outputTruncated=false/stable=true;4 tabs,35 discovered/captured
paths, tab counts9/4/9/13 and currencies11/6/11/15, all complete/flags empty. User's
successful full text submission establishes normal native capture/manual complete
copy for this report, not every scrolling/focus/Close/Escape/combat/UI edge branch.
Native timestamp/build metadata now available for this capture; installed file-byte
hash identity still not independently proven. No new local/agent Lua or diagnostic run.

### Sanitized per-path observations

All35 nodes: type1/flags0/isAvailable=true, ranksIncreased0, currentRank/activeRank equal
ranksPurchased, totalMaxRanks equal maxRanks; exactly unlock/spend IDs, unlock type9/
maxRanks1, spend type7. All70 entryCost arrays explicitly empty; all increased-entry
map values0; all path spend currencies3902. Each current node-cost array contains
exactly one row of amount1; its currency varies as below. Next entries/committed
entries were captured, not treated as purchased points. Header abbreviations:
RP=ranksPurchased, NM=node maxRanks, SM=spend-entry maxRanks, NC=node-cost currency.

| Tab | Path | Children | RP | NM | Unlock entry | Spend entry | SM | NC |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|1122|106192|106191,106187|1|31|130942|130933|30|3902|
|1122|106191|106190,106189,106188|1|31|130941|130925|30|3902|
|1122|106187|106186,106185,106184|0|31|130937|130893|30|3912|
|1122|106190|-|0|31|130940|130917|30|3911|
|1122|106189|-|1|31|130939|130909|30|3902|
|1122|106188|-|0|31|130938|130901|30|3911|
|1122|106186|-|0|31|130936|130885|30|3907|
|1122|106185|-|0|31|130935|130877|30|3907|
|1122|106184|-|0|31|130934|130869|30|3907|
|1124|106280|106279,106278,106277|11|11|131041|131037|10|3902|
|1124|106279|-|1|21|131040|131029|20|3902|
|1124|106278|-|21|21|131039|131021|20|3902|
|1124|106277|-|21|21|131038|131013|20|3902|
|1182|109660|109659,109655|31|31|135911|135902|30|3902|
|1182|109659|109658,109657,109656|31|31|135910|135894|30|3902|
|1182|109655|109654,109653,109652|31|31|135906|135862|30|3902|
|1182|109658|-|31|31|135909|135886|30|3902|
|1182|109657|-|1|31|135908|135878|30|3902|
|1182|109656|-|5|31|135907|135870|30|3902|
|1182|109654|-|31|31|135905|135854|30|3902|
|1182|109653|-|31|31|135904|135846|30|3902|
|1182|109652|-|31|31|135903|135838|30|3902|
|1125|106358|106357,106354,106351,106348|1|21|131132|131119|20|3902|
|1125|106357|106356,106355|0|21|131131|131113|20|3936|
|1125|106354|106353,106352|0|21|131128|131095|20|3936|
|1125|106351|106350,106349|0|21|131125|131077|20|3936|
|1125|106348|106347,106346|0|21|131122|131059|20|3936|
|1125|106356|-|0|21|131130|131107|20|3935|
|1125|106355|-|0|21|131129|131101|20|3935|
|1125|106353|-|0|21|131127|131089|20|3932|
|1125|106352|-|0|21|131126|131083|20|3932|
|1125|106350|-|0|21|131124|131071|20|3929|
|1125|106349|-|0|21|131123|131065|20|3929|
|1125|106347|-|0|21|131121|131053|20|3926|
|1125|106346|-|0|21|131120|131047|20|3926|

### Reconciliation and meaning

| Tree | Paths | Raw purchased | Unlock-excluded candidate points/capacity |
| --- | --- | --- | --- |
|Blueprints1122|9|3|0/270|
|Calm Hands1124|4|54|50/70|
|Perfected Products1182|9|223|214/270|
|Darkmoon Curiosity1125|13|1|0/260|
|Total|35|281|264/870|

All four tabs repeat shared3902 quantity0/spent264, counted ONCE; candidate total264
matches exactly. Seventeen positive-purchased nodes each exclude their observed1-rank
unlock;18 locked zero-purchased nodes contribute0, not−1. Do not replace this rule
with subtract35 from raw281 or subtract1 universally (other captures may have unlock0).
Capacities are all branches, not just currently unlocked paths. Individual native
Blueprints root0/30/Perfected Products root30/30 are not these full-tree totals.

All17 positive-purchased nodes currently cost3902×1. All18 zero-purchased nodes have
nextEntry equal the unlock entry and current node cost in a different trait currency:
Blueprints3912/3911/3907; Darkmoon3936/3935/3932/3929/3926. All still identify3902 as
their SPEND currency. Source path mixin315–335 and frame758–781 distinguish unlock
purchase from spend purchase. This pattern supports next-unlock costs rather than
bad KP accounting; K1's literal alternate-currency inconsistency label must not be
read as a proved defect. It also demonstrates why GetNodeCost alone cannot verify
future spend-rank costs on a locked node. No actual spending/unlocking requested.

At maxed Calm Hands root106280, committed-entry list contains only spend131037,
active spend rank10 while node purchased/current11 still includes unlock1. Analogous
maxed spend entries occur elsewhere. Do NOT require unlock ID in committed-entry list
as proof the unlock rank is present; use observed metadata/rank coherence.

Accept this native K1 normal capture/copy and provisional reconciliation sample;
not arbitrary-rank unit costs or production numeric eligibility. Next primary defines
a narrowly evidenced production accounting proposal covering locked/unlocked cost
semantics, full traversal, conditional unlock subtraction and shared reconciliation;
do not merely flip costRule. No further dumps needed to explain this supplied report.
New executable correction/implementation requires its own scoped approval/contract.
No source changes, snapshot writes, new mappings, installs/gameplay/Git/release.

Primary post-transcription checks PASS: Python recomputed the sanitized35-row table's
unique root/child coverage, raw281/17excluded/264points/870capacity,17opened/18locked
cost partition and four per-tree summaries; all14 reviewed source hashes unchanged.
This validates the transcribed table, not automated parsing/execution of the user's
report. `python3 tools/check_dashboard.py` PASS15paths/23docs/71links/eight diagnostic
hashes unchanged. No new Lua execution. Q03 records a proposed distinct native-rank/
shared-reconciled production policy, not yet adopted; earlier all-rank-cost gate must
not be silently waived. Await scoped user approval before executable correction.

## K2 native-rank correction authorized / pre-edit base — 2026-11-06

User explicitly answers Yes to guarded Inscription native-rank bars with shared-spent
reconciliation. Policy distinct native-rank-reconciled-v1, not verified-unit-spend or
future all-rank cost proof. PLAN D10/Q03 adopted refinement and TASKS29–32 READY.
Production can now fix complete currency capture within K2; K1/diagnostics unchanged.

Primary verified every current14 K1 frozen hash and preserved byte-exact originals at
`/tmp/opencode/craftarmy-k2-baseline/<repository-relative path>` for independent diffs.
No implementation source changed before delegation. One synchronous writer owns K2
manifest/status/delivery; primary owns planning/acceptance and freezes assigned files
during execution. Only Core/Knowledge/Collectors/ViewModel/SelfTests/README/schema
may differ among the14 hashed files; all seven others and diagnostics frozen. Evidence/
TASKS may append delivery, PLAN/Q03 owned byprimary. No new files/schema/version,
installs, gameplay/Git/release, archival or parallel writer authorization.

Required acceptance remains independent source review, actual expanded fixture suite
and native scan/hover comparison on user client. Historical66/66 and normal K1 capture
are baseline evidence, not new K2 passes. Preserve stale coherent snapshots on failure;
do not enable numeric values by toggling old costRule or trusting K1 match flags.

## K2 implementation delivery — 2026-11-06

**PARTIAL — pieces29–32 delivered; independent verification and user acceptance
INCOMPLETE.** No local Lua/client/API PASS is claimed. Prior user66/66 and native
35-path K1 report are historical baseline evidence, not K2 execution. Platform
review N/A: no CI/hosting/IAM/deploy/release effects. No installs/downloads/substitute
runtime, live WoW/API testing, real saved-data or gameplay/resource mutation, children,
parallel writers, new files, Git operation or release occurred.

### K2 policy, provenance and failure safety

- Existing Collectors:Knowledge is enhanced directly, with no K1 capture/report/UI
  calls. Knowledge-only projection inspects at most limit+1 keys and bounded indexed
  prefixes:8tabs,64paths/tree,16children/path,32entry IDs/maps,64currency rows/tab,
  16costs/node/entry. Dense plain typed lists, duplicate/cycle/shared ownership and
  omissions are explicit. Invalid fields are omitted, duplicate rows never become
  complete, raw API error payloads are discarded. Explicit false/zero/empty survive;
  nil/error/unsupported never means empty. Misattributed node IDs are omitted with
  failed metadata rather than passed to Core as contradictory path data. currencyCount
  counts copied rows, not unknowable omissions. Prefixes never assert completeness.
- Raw policy is **native-rank-reconciled-v1**, separate from verified-unit-spend;
  costRule stays **unknown**. Scope is only2913/773/profession13/expansion11. Raw carries
  config/sourceCounter, numeric identity, complete typed source/path/currency flags,
  stable unstaged boundaries and bounded node/entry/active/next/committed/cost data.
  Final Context follows all external environment/knowledge reads. Identity/config/
  source/revision and Scan-entry serial must agree before commit; reentrant/invalid/
  changed serials discard attribution and cannot restore freshness.
- Pure native mode independently validates source/list/graph/rank/state data, not
  supplied flags or K1/shared matches. Unknown/non-string policies never fall through
  to legacy. Node type1/flags0, totalMax==max, active/current/purchased coherence and
  zero increases are required, with exact unlock9/max0or1 and spend7/positive-cap
  pair, complete empty entry costs, zero map covering both entries and unique committed
  subset containing active for RP>0. **Spend-only committed at max is valid.** Next
  ranks are entry evidence, never purchases or assumed points+1; fixture109656 has
  purchased5/active spend4/next6. Availability is boolean, **not** lock classification.
- RP>0 subtracts observed unlock max; RP0 contributes0. Capacity excludes unlock ranks.
  Locked RP0/unlock1 uses active unlock0, next unlock and one current unit cost in a
  **different uniquely observed token currency**. Opened or unlock0/RP0 paths target
  spend currency; maxed nodes have no next. Missing/extra/zero/nonunit/entry-specific
  costs or unknown combinations fail closed. No affordability requirement, future
  cost claim, currency/tree/path/count/balance defaults or spending is introduced.
- Every path dynamically identifies one spend currency; every complete tab has one
  matching committed row, identical spent/quantity. Grand purchased sum reconciles
  **ONCE**, never once/tab. Other currencies never add to KP; separate unspent need
  not be known. Any failure makes **all** native trees nonnumeric. Complete tree units
  retain own paths/currencies, accountingPolicy and required typed accountingEvidence
  (currencyID/spent/quantity/totalPurchased/sourcePin). Core validates shape, rank-derived
  paths/sums/provenance and scoped active/archive/candidate generations, rejecting
  malformed/wrong-scope direct payloads atomically. Legacy schema1 remains loadable
  without migration/reset/native inference; Core is not an API proof or K1 dependency.
- All discovered **and prior indexed** tree fields fail together, retaining whole
  prior values/times nonfresh. Incomplete tabs preserve prior index. Retained hover
  uses its own evidence, never newer raw. Global Copy depth20/50,000-value bounds
  remain: oversized direct payloads reject atomically; oversized combined scan evidence
  records failed attempts instead of increasing limits or promoting new numbers.
- Only knowledge hover/status changes: native rank/shared-spent/once, NOT verified
  future/all-rank costs, distinct locked unlock tokens, genuine zero versus unknown.
  No table/layout/theme/columns/gear/enchant/filter/relative-age changes. General gear
  list/collection, other currency reads, async retry and roster behavior stay unchanged.
  K1 Capture/command/report remain read-only **PROVISIONAL**, with all16 cases unchanged.
  Data/mappings/TOC/version0.2.0-mvp/schema1/Interface120105/diagnostics stay frozen.

### K2 regression definitions — 87, NOT RUN

All original66 cases/helpers/assertions and Tests.Run tail are byte-exact retained;
**21 separate K2 definitions** are appended. The isolated fixture reproduces all35
sanitized path rows and real topology/costs above:17 opened3902×1,18 locked alternate
tokens,11/6/11/15 currencies,70 explicit empty entry costs. Active/committed states
model adopted guards, including spend-only at max and observed partial next6. Fixture
data are NEVER production defaults. Added cases cover:

1. Native35 tree totals0/270,50/70,214/270,0/260 and264 once, with complete provenance.
2. Changed balances/ranks/caps/currency IDs/order/sharedlast, mixed unlock0/1 including
   unlock0/RP0 spend-ready; other currency spent excluded.
3. Every rank/type/flags/cap/availability/entry-pair/increase-map/committed guard.
4. Active/next/locked/max/partial and missing/extra/zero/alternate/nonunit/entry costs.
5. Full64/sharedlast/beyond8; missing/duplicate/conflicting/mismatching shared rows,
   different path currencies,65limit and ignored supplied shared-match authority.
6. Unsupported policy/scope/source/config/staging/stability/coverage, legacy dispatch.
7. Cycles/shared ownership/unreachable/missing/duplicate/tab and list limits.
8. Projection field-failure sanitization, including contradictory node IDs, into
   valid incomplete raw Core input, never zero or mistyped evidence.
9. Missing/nil/throwing trait reads, private generic failures and unknown withoutprior.
10. Costs16/17 (node AND entry), entries/maps32/33, currencies64/65, sparse/keyed/
    invalid/duplicate/metatable lists and bounded sanitized output prefixes.
11. Paths64/65, tabs8/9, children16/17, capture cycles/shared ownership.
12. Actual NaN/±infinity projection and direct raw/provenance atomic rejection.
13. Malformed direct new fields, policy/provenance/derived sums reject without writes.
14. Core.Open active/archive failures, incoming wrong scope and old schema1 loading.
15. Scan/reload/archive/ViewModel native zero/time/evidence/hover/unspent separation.
16. Success→failure retains ALL trees/times, including omitted tabs; prior index on
    incomplete tab read, stale/nonfresh and no newer raw borrowing; no-prior unknown.
17. Player/source/config/revision/serial/closed changes, actual isolated recursive Scan.
18. Staged/unknown/error boundaries, missing/false source, unsafe/missingDB safety,
    unchanged gear/currencies and unavailable unspent without fabricated quantity.
19. Negative/fraction/overflow/string/false scalars, metatable node/entry/map and
    nonfinite scan-token rejection, with no math/global mutation.
20. Missing/nil/throwing specialization APIs stay typed unknown, not observed empty.
21. Global copy-budget atomic rejection and failed-scan coherent-history retention.

These are isolated synthetic definitions, **not executed here** or proof of APIs.

### K2 validation and actual baseline comparison

Inspected both approved scripts before execution. Baseline and post-edit commands:

```text
python3 tools/check_dashboard.py
PASS: 15 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 71 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
command -v lua5.1
(no path)
```

Both Python checks **PASS exit0**. `lua5.1 tests/dashboard.lua` and `lua5.1 tests/run.lua`
**NOT RUN**, absent approved runtime; no install/download/alternate embedded runtime.
Expanded `/ca selftest`87, fresh `/cad selftest`, load/scans/bar/hover/native comparisons
**NOT RUN** by agent. No syntax/lint/runtime success inferred.

Read-only `python3 - <<'PY' ... PY` byte/hash/difflib/content comparisons:

- All14 pre-edit files matched preserved K1 originals before coding. Actual bytes,
  not Git/staged state or guessed originals, are the comparison base.
- Original66 prefix and full Tests.Run tail equality **PASS**; prefix SHA256
  `eb630e78928d30e91bf0402add411ab1a35504159055ce876198cd0dd63a78e8`.
  Definition count **87=66+21**. Reproduce prefix proof with
  `old[:old.index(b'function Tests.Run()')] == new[:new.index(b'-- K2 fixtures are separate additions.')]`,
  plus equality from each file's `function Tests.Run()` to EOF.
- Removing the native helper block and four-line policy dispatch reconstructs
  byte-exact original Knowledge.lua: legacy rules/assertions were not rewritten.
- Collector New/Context/Same/Gear region and TokenValid-to-EOF are byte-exact unchanged.
  ViewModel before treeDetail and from V.Row-to-EOF is byte-exact unchanged.
- Static Python comparison **PASS**: all35 new fixture row tuples match the nine-column
  native table, including children/order/RP/max/entry IDs/caps/costs. Static sums are
  0/270,50/70,214/270,0/260. This is content checking, NOT Lua execution. Initial static
  comparison exited1 because its regex also selected a four-column currency table
  (`ValueError` parsing currency text); limiting it to nine-column rows corrected the
  harness, rerun exit0. No implementation/fixture change hid that script failure.
- Actual in-memory unified diffs show exactly seven permitted deltas among14, seven
  others unchanged. Originals remain read-only at
  `/tmp/opencode/craftarmy-k2-baseline/<repository-relative path>` for full review diffs.
  No Git repository/base exists. Evidence is append-only; TASKS edits only K2 piece/
  current-state/new-delivery fields. PLAN/Q03/AGENTS/prior review history untouched.

| Actual K1 baseline delta | Added lines | Removed lines |
| --- | ---: | ---: |
|CraftArmy/Core.lua|165|9|
|CraftArmy/Knowledge.lua|184|0|
|CraftArmy/Collectors.lua|188|49|
|CraftArmy/ViewModel.lua|17|3|
|CraftArmy/SelfTests.lua|663|0|
|docs/dashboard/README.md|56|10|
|docs/dashboard/schema.md|67|2|

### K2 current 14-file source freeze

```text
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
0ddcae3a728cf6e4b75127eb1b9372750d7101fbd70d25830885f1000251e722  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
9c9c33011e14e3c923d331a26bcb7bee4e0211bcb139b2bf0b3309b77473a61d  CraftArmy/Knowledge.lua
d1b6868b10be518825960507848f4fdb94c81e38f8074b67894643c4233107c1  CraftArmy/Collectors.lua
0583a6ec9966f19bb53f506042b48fb8f688e3e0117f67187205ddbd45d47da3  CraftArmy/KnowledgeCheck.lua
2d14092528ced39e0ccadbf21d8cc2f500ff510ab235845b635beedccd12aa3e  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
45356c677f8781872d1cfc7caf7c90feaaeee6f9dbb2cc7298cf5bbee1cfa3a3  CraftArmy/SelfTests.lua
fb4bdcd48b0f53ecdfde18b7928fa967959d5383f0ee6e8b32a5e0edba639b70  CraftArmy/Commands.lua
601990e4a67b4fc3fb048bbf86cb8337974dd3323e771ea20adfcfd18a8edab4  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
3050c4d45940257e78bb42418e71f8bbf05cc67aa4ebda0d4f73ad4e2ab558aa  docs/dashboard/README.md
7765b54ae78b321f5cde339c2e83ff233fc34535eae8560fc5881afdfc86840c  docs/dashboard/schema.md
```

Evidence final hash is in TASKS K2 delivery (not self-hashed here). Resume **primary**:
independent read-only review of these exact bytes against preserved K1 originals,
particularly native guards, typed atomic rejection, all-tree stale safety,21 added
definitions and unchanged66/K1 isolation. Persist findings before correction or user
recommendations. Then user-only five-Lua update after backup/review, expanded selftest
**first**, followed by own ready unstaged `/ca scan` and current four-bar/hover/unspent
comparison per README. No all-rank proof, full T02 acceptance or release.

## K2 initial independent review CHANGES REQUIRED — 2026-11-06

Verifier current-source inspection finished; handoff PARTIAL / acceptance CHANGES
REQUIRED, runtime INCOMPLETE. Three medium findings accepted byprimary:

1. Knowledge.lua98–115/Core374–375 impose entry-local max on nextEntry.rank despite
   no established purchased-rank unit convention (native RP5/active4/next6). Near-cap
   RP30/nodeMax31/spendCap30/next31 would be rejected. This is an unsupported guard,
   not a claim the client necessarily emits31. Separate active coherence from positive
   bounded known-pair/state-specific next evidence; add pure/Core/collector cases.
2. Collectors454–474 replaces prior4-tab index with a failed1-tab result when tab API
   list itself claims complete. All prior values get unknown attempts but ViewModel
   iterates the reduced index, hiding3 stale bars; failed tab names may become IDs.
   Preserve coherent prior index on failed native evaluation, use retained names and
   test rendered count/names/time/evidence, not only stored fields.
3. Core.Apply489–525 validates old DB and incoming input separately against copy
   budget but not the assembled candidate. Combined can exceed50,000 values and make
   next Open reject entire DB. Existing structural gap exposed by larger metadata,
   introduction not attributed without baseline read. Check full assembled proposal
   before single commit, reject unchanged/no eviction/limit raising; cumulative test.

Primary specifies READY33–35 corrections in TASKS before writer follow-up. User update
blocked until corrected review; no new gameplay/feature authorization. Reviewer shell
execution and external baseline-directory access denied; NOT RUN/no bypass/no retry.
Primary had independently verified current14/evidence SHA
`a1a089cac1ad6729e9d4bfdcaa31af833d156bfae526d977ac0c5332c64d6da7`, exact7 scoped
deltas/seven frozen and original66 prefix/tail byte-exact; both Python checks PASS
15paths/23docs/71links/eight unchanged diagnostic hashes. Those are not reviewer-run.
87 fixtures/native K2 remain NOT RUN. Distinct policy direction accepted, no demand
for universal all-rank proof. Platform review N/A. No source changes byreviewer.

After writer stops, primary provides generated workspace k2-review.diff from actual
preserved K1 bytes for re-review; no denied external reads retried and no actual
baseline hashes guessed. Documentation review artifact is not an addon/load change.

## K2 correction33–35 partial delivery / alias blocker — 2026-11-06

**PARTIAL;33 delivered,34 partially implemented/BLOCKED,35 dependent/BLOCKED.**
Primary's original three medium findings and CHANGES REQUIRED remain recorded above;
this is not re-review acceptance. No user update recommendation. The scoped approved
shallow-proposal fix exposed an additional design case that cannot be safely settled
by the implementer. Primary owns the next decision; no new architecture was selected.

### Done within the settled correction

- Knowledge.NativePathPoints separates next-entry evidence from active-entry cap
  checks: next is a positive finite integer<=2147483647, with known pair/state-specific
  ID; maxed still requires nil. Active coherence/caps are unchanged. Core native tree
  validation removes only its next-entry local max bound. The appended K2 negative
  expecting next31 rejection now uses the genuinely invalid2147483648; no old66 case
  was edited. New synthetic RP30/nodeMax31/unlock1/spend30/active29/next31 and nextMAX
  pass-expectation definitions cover pure arithmetic, Core.Apply/Open and collector.
  Next0/nonfinite/overflow/foreign/wrong-state and incoherent active remain rejection
  expectations. This is not evidence that a client necessarily emits the boundary.
- Any failed native evaluation with a coherent prior index now records an unknown
  index attempt and retains the entire previous index/time, even when returned tab
  IDs claim complete. Every prior indexed tree still gets a failed nonfresh attempt.
  ViewModel uses a stale retained tree's own name when available. Reduced-tab, nil/
  throwing/changed-name fixtures assert all4 old bars remain visible with their own
  names/paths/numbers/time and no fresh flags; no-prior identities stay unknown.
- Core.Apply now validates the approved temporary shallow proposal, preserving all
  old root keys and other characters after cloned generation validation and before
  its single real character assignment. A failing Core.Copy returns the bounded
  explanation `Assembled snapshot exceeds bounded saved data limits`, with no reset,
  key omission, eviction, raised limit or root/characters replacement. Two added
  fixtures derive padding from actual native candidate value counts: old DB and
  incoming scan each fit separately,50001-value shallow proposal rejects unchanged
  (including references, root extras and other character),50000-value proposal fits
  and reopens. Old Open/ViewModel/archive/delete remain testable after rejection.
  **This fixes ordinary nonaliased assembly but does not close the case below.**

### Precise remaining design blocker — primary decision required

Core.Copy accepts noncyclic shared aliases (it clears its seen marker after each
copied subtree); Core.Open permits unknown finite/plain root keys. Therefore this
existing shape is valid: `db.userAlias = db.characters`.

The approved shallow proposal replaces `proposal.characters` with a new candidate
table, but preserves `proposal.userAlias` pointing to the **old** original characters
table, as required by the current instructions. Core.Copy(proposal) counts the new
character once and the old character under that alias. The actual single commit is
`db.characters[guid] = candidate`; since the original characters table remains in
place, **both** `db.characters` and `db.userAlias` now see the larger candidate. Its
actual postcommit copied size can exceed the proposal's size. If replacing that
character adds D values, shallow proposal size can be B+D while actual size is B+2D;
there are valid boundaries with B+D<=50000<B+2D. Preserving unknown keys alone does
not resolve their shared-reference semantics.

This is a **static code-path finding**, not an executed Lua reproduction. No alias
rejection policy, alias-aware proposal reconstruction or other resolution was
authorized. The implementer stopped rather than invent one or silently drop aliases/
replace original containers. Primary must settle how Apply accounts for reachable
aliases of the mutated characters container while preserving the required failure
identity/atomicity and existing-load compatibility, then authorize resume at34 and
dependent35. A focused alias regression should accompany that decision. The current
shallow guard remains as partial work; it is NOT claimed to guarantee every accepted
DB can reopen after a new commit. No client/user install should proceed on this freeze.

### Fixtures and validation actually performed

**93 definitions = initial87 +6 correction cases, all NOT RUN here.** The six cover:
near-cap next31/MAX through pure/Core/collector; invalid next/active rejection;
four-visible-tree/index/own-name retention; no-prior unknown identities; assembled
50001 rejection/reference/management safety; assembled50000 fit/reopen/root-extra
retention. Boundary counts are derived inside fixtures, not guessed/hardcoded native
payload sizes. The shared-alias case is a blocker, not a passing regression claim.

Inspected both approved scripts, then ran before and after this correction:

```text
python3 tools/check_dashboard.py
PASS: 15 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 71 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
command -v lua5.1
(no path)
```

Both Python commands PASS exit0. `lua5.1 tests/dashboard.lua` / `lua5.1 tests/run.lua`
NOT RUN (approved runtime absent); no installs/downloads/substitute runtime. Expanded
selftest93, native K2 scan/hover/UI and fresh diagnostics NOT RUN. Historical66/66,
initial87 NOT RUN and prior K1 native report are not correction runtime evidence.

Read-only `python3 - <<'PY' ... PY` hash/content checks PASS:

- All14 initial K2 hashes matched before edits. Exactly7 allowed paths differ versus
  BOTH initial K2 and recorded K1 hashes; other7 remain frozen, diagnostics unchanged.
- Removing K2 additions (prefix before its marker plus current Tests.Run tail)
  reconstructs exact K1 SelfTests SHA256
  `347348ed578dd3899dcdf2b9b20d8c78bbb68da1ea99588e6c6622363b369227`, proving all
  original66 cases/helpers/assertions **and runner tail** are retained byte-exact.
- Removing only the new correction block and restoring the single appended next31
  negative reconstructs initial K2 SelfTests SHA256
  `45356c677f8781872d1cfc7caf7c90feaaeee6f9dbb2cc7298cf5bbee1cfa3a3`.
  Actual count93. No old66 assertion change, K1 helper change or permissive test skip.
- No external baseline-directory read was attempted in this correction; no permission
  denial bypass/retry. Primary still owns generation of workspace k2-review.diff from
  actual preserved K1 bytes after this stop. Implementer did not create/edit it.

Changed exactly the existing five scoped Lua files, README/schema/evidence and allowed
TASKS statuses/current run/new delivery. Data/Dashboard/K1/Commands/TOC/runner/checker/
all diagnostics and primary planning/reviews stay frozen. Same schema1/version0.2.0-mvp/
Interface120105 and native scope/policy; costRule unknown, no all-rank/future-cost proof.
One writer, no children/new files, game/API/real DB/math mutation, gameplay, installs,
Git or release. Platform review N/A. README retains the five-Lua update, but explicitly
blocks installation pending primary resolution/completion/re-review and selftest first.

### K2 correction PARTIAL current14 freeze

```text
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
80e6bf6ce392978e194d2d705fecb8101f4acb858d46f483f7aa70740d3539c7  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
4fa5c2d0817be04c55eada64934f70f680cbc2c6d0a83943cf4411153ac9e60c  CraftArmy/Collectors.lua
0583a6ec9966f19bb53f506042b48fb8f688e3e0117f67187205ddbd45d47da3  CraftArmy/KnowledgeCheck.lua
a9116a628a7168ec6b3cf0a7ef9be4878350da8cf87a15b39b16ca600b7d38f0  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
4028a9fc9f293406529eb382a9e382a78c5ad777c696b2bad5ad508fd5aeb9fc  CraftArmy/SelfTests.lua
fb4bdcd48b0f53ecdfde18b7928fa967959d5383f0ee6e8b32a5e0edba639b70  CraftArmy/Commands.lua
601990e4a67b4fc3fb048bbf86cb8337974dd3323e771ea20adfcfd18a8edab4  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
047d81c0c98d9a506fc99c2c7077cf955ad0f437a3f357fd223d7605ee1e5c67  docs/dashboard/README.md
cab9267d57f91b2609e78b64566663f5da7b486b1196cde3dad880c13e8edad8  docs/dashboard/schema.md
```

Final evidence hash is recorded in TASKS correction partial delivery. Resume owner
**primary** at the alias-handling decision for34; writer must not resume dependent35
completion or user update recommendation until that decision is durable and READY.

## K2 alias-safe correction34–35 delivery — 2026-11-06

**PARTIAL — correction34–35 delivered for independent re-review;33 remains delivered.**
The primary's authoritative memoized-mirror refinement resolves the earlier design
blocker. No implementer design fork remains. The old blocker, partial freeze and
original three review findings above remain history; CHANGES REQUIRED is not cleared
by this delivery. Independent corrected review, user fixtures and native K2 comparison
remain INCOMPLETE. No installation/release recommendation or all-rank proof inferred.

### Exact alias-safe preflight delivered

- Core.Apply first uses its existing Core.Open, input, cloned candidate generation
  and typed/scope checks. Its private `candidateMirror` then clones the validated
  current graph with a source-table→mirror-table memo, preserving every valid key,
  primitive, unknown user field, other character and shared table reference. It does
  not use ordinary alias-duplicating Core.Copy to create that mirror. Traversal is
  protected by pcall, depth20 and50000 visited-value bounds; finite primitives,4096-byte
  strings and128-byte/nonnegative-integer keys follow existing constraints. Any
  failure returns a bounded reason before any real write, without raw error payloads.
- Only `mirror.characters[guid]=candidatec` is simulated. All root/nested aliases of
  that mirror map see the replacement, while aliases of the old character object
  continue pointing to its old mirror object. No global old-character reference
  rewriting is performed. Existing unchanged Core.Copy then checks the whole assembled
  mirror against the original global budget, including every repeated alias occurrence.
  The temporary graph is discarded; the real single commit remains
  `db.characters[guid]=candidatec` on the original characters table.
- Preflight failure leaves the original graph identities, keys, generations and times
  unchanged. Fitting writes keep the original root/characters map and its aliases;
  old-character aliases remain old after replacement. No alias rejection policy,
  unknown-key omission, archive eviction, reset, raised limits or DB replacement.
  Ordinary Core.Copy/Open/Archive/Delete/CompareRoster/other alias behavior is unchanged.
- Piece33 next-entry/active coherence guards and full failed-index/own-tree-name
  retention are untouched in this pass. Native policy/scope, bounded evidence,
  all-tree shared-spent once, unknown costRule, K1 read-only PROVISIONAL report,
  schema1/version0.2.0-mvp/Interface120105 and normal dashboard layout remain unchanged.

### Regression definitions — 96, NOT RUN

All preceding93 cases/helpers/assertions and Tests.Run tail remain byte-exact. Three
separate alias definitions are appended:

1. Root, nested and multiple characters-map aliases, with separately valid old DB
   and incoming native scan whose assembled alias expansion has50001 values. The
   fixture derives counts from actual native candidate growth and explicitly asserts
   that the old shallow/alias-duplicating single-occurrence preflight would fit. New
   rejection must leave the complete graph/reference identity unchanged, keep old
   timestamps/unknown root primitives/other character and remain Open/ViewModel usable.
2. The same root/nested/multiple alias modes at an assembled50000-value fit boundary:
   successful write/reopen, unchanged original map/container/reference identities,
   every map alias sees the new generation, old-character alias stays old, and unrelated
   shared primitive tables remain aliased with observed false/zero preserved.
3. Separate root+nested old-character aliases without map aliases: successful fitting
   replacement keeps both old-object references and old graph/time/unspent8 untouched,
   while the new character has current unspent0/native tree0. It must reopen immediately.

Padding is derived inside fixtures, not from guessed native payload sizes. Original93
near-cap, stale-index, ordinary cumulative-budget, malformed/nonfinite, legacy/K1 and
all other regressions are retained; there is no test weakening or old66 edit. These
are definitions only: no approved Lua runtime is available to execute any of the96.

### Actual checks and comparison

Both approved scripts inspected before execution; baseline and post-edit runs:

```text
python3 tools/check_dashboard.py
PASS: 15 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 71 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
command -v lua5.1
(no path)
```

Python commands **PASS exit0**. `lua5.1 tests/dashboard.lua` and `lua5.1 tests/run.lua`
**NOT RUN**, runtime absent; no installation/download/alternate embedded runtime.
Expanded selftest96, new native scan/hover/client comparison and fresh diagnostics
NOT RUN by agent. Static success is not Lua syntax/execution or target-client evidence.

Read-only `python3 - <<'PY' ... PY` hash/content comparisons PASS:

- All14 preceding partial hashes matched before edits. Exactly Core/SelfTests/README/
  schema differ among14 in this pass; ten other paths are byte-identical by hash.
  Total K1 comparison still permits exactly7 changed paths (Core/Knowledge/Collectors/
  ViewModel/SelfTests/README/schema), other7 frozen. Eight diagnostic hashes unchanged.
- Strip only the appended alias fixture block and keep current Tests.Run tail:
  reconstructed preceding93 SelfTests hash is exactly
  `4028a9fc9f293406529eb382a9e382a78c5ad777c696b2bad5ad508fd5aeb9fc`.
  Strip all K2 additions the same way: original66 full-file reconstruction is exact K1
  `347348ed578dd3899dcdf2b9b20d8c78bbb68da1ea99588e6c6622363b369227`.
  Definition count **96=93+3**, including unchanged near-cap/index/K1 fixtures.
- Reverse only the private mirror helper and exact Apply preflight replacement:
  reconstructed preceding partial Core matches SHA256
  `80e6bf6ce392978e194d2d705fecb8101f4acb858d46f483f7aa70740d3539c7`.
  Thus no unrelated Core/Archive/Delete/ordinary Copy or policy changes in this pass.
- No denied external baseline access attempted/retried/bypassed. K1 baseline comparison
  uses recorded hashes; actual unified-diff workspace artifact remains primary-owned
  and is not created/edited by the implementer. No new files/Git base assumed.

Changed files this pass: `CraftArmy/Core.lua`, `CraftArmy/SelfTests.lua`, dashboard
README/schema/evidence, plus allowed34–35/current-run/new-delivery TASKS fields. No
other implementation/primary planning/review history changed. One writer, no children,
no real DB/math/game/API or gameplay mutation, dependency install, Git or release.
Platform review N/A (no CI/hosting/IAM/deploy/release effects). README now records96
definitions and delivered/re-review-pending (not a writer blocker), preserving the
five-Lua backup/update/selftest-first instructions and primary review authorization gate.

### K2 alias-safe correction current14 freeze

```text
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
68fa0719550f6befbf1f094966c5115d1425e1f9fdad1a30737bab67dfc7d441  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
4fa5c2d0817be04c55eada64934f70f680cbc2c6d0a83943cf4411153ac9e60c  CraftArmy/Collectors.lua
0583a6ec9966f19bb53f506042b48fb8f688e3e0117f67187205ddbd45d47da3  CraftArmy/KnowledgeCheck.lua
a9116a628a7168ec6b3cf0a7ef9be4878350da8cf87a15b39b16ca600b7d38f0  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
2a64e3a25d425dc90bbe607565b4e8ad07e30d18a261f8ad17bad5ee220713f5  CraftArmy/SelfTests.lua
fb4bdcd48b0f53ecdfde18b7928fa967959d5383f0ee6e8b32a5e0edba639b70  CraftArmy/Commands.lua
601990e4a67b4fc3fb048bbf86cb8337974dd3323e771ea20adfcfd18a8edab4  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
80e49eddff61ebb598d7321ea47cf963be001d10e611fdb8855ab71dfbb50bc2  docs/dashboard/README.md
7f9e414fddc43c1533b5b05f0b09f39723e6f579f8506b3ab20b0162b22f23cb  docs/dashboard/schema.md
```

Final evidence hash is recorded in TASKS alias-safe delivery. Resume **primary**:
generate/provide the actual K1→current seven-file unified diff via the allowed workspace
artifact, obtain independent read-only re-review of this exact freeze (including alias
counting/atomicity, preserved93/66, next-rank and stale-index fixes), persist findings
before any user update. After satisfactory review, user-only five-Lua update following
backup, selftest96 first, then own ready unstaged current four-bar/hover/unspent native
comparison. No remaining executable writer piece or design blocker; acceptance/release
remain separate and not granted by this implementation.

## K2 corrected comparison artifact and primary recheck — 2026-11-06

Primary generated `docs/dashboard/k2-review.diff` (1964lines/122331bytes) from actual
preserved K1 original bytes to current seven scoped targets. SHA256:
`d4e0ae1703973197bae67a2554740a47a06055cdaf9d18c1c3fa1413dfe1bcef`.
Each section names baseline/target digests and actual unified hunks. No secret/user
data; source comparison only, not a new addon/packaging dependency. This primary-owned
artifact was explicitly allowed by correction contract and is workspace-readable;
reviewer need not retry denied external-directory access.

Primary matched current14 hashes, exact7 K1 deltas/seven frozen, original66 prefix/
runner tail byte-exact and96 definitions. Both inspected Python checks rerun PASS:
15 dashboard paths/23Markdown docs/71links/eight unchanged diagnostic hashes, separate
diagnostic structure PASS. These are primary executions, not reviewer or Lua/client
results. Pre-artifact evidence SHA256 was
`b54d33187a49e0bb4930eccb8906dd00fc75ae367a3ef208c6b147e8e601b93b`;
later evidence documentation changes that digest, not the source14 freeze. Send frozen
source+artifact for independent re-review before any update recommendation.

## K2 corrected independent static PASS — 2026-11-06

Verifier re-review COMPLETE / static acceptance **PASS**, runtime **INCOMPLETE**. All
three initial findings resolved with no additional blocking static defect identified:
separate positive bounded next-entry evidence vs strict active rank; failed native
index preserved with all retained stale bars/names; protected bounded alias-preserving
mirror plus exact assembled-budget preflight before the single real character commit.
No raised limits/eviction/real-graph preflight writes. New fixtures meaningfully cover
near-cap/visibility/cumulative budget and root/nested/multiple map/old-character aliases,
but are NOT RUN. Original66 prefix unchanged;96 definitions now require user execution.

Reviewer read all1964 lines of actual K1→corrected seven-file diff, corrected production
paths, appended correction/alias fixtures, contract/docs. Artifact SHA supplied and
checked byprimary: `d4e0ae1703973197bae67a2554740a47a06055cdaf9d18c1c3fa1413dfe1bcef`.
Target is the latest alias-safe current14 freeze above. No Git base/staged distinctions.
Primary current14/exact7deltas/sevenfrozen/old66/count/hash and Python PASS attribution
remains primary; reviewer commands NOT RUN, earlier denials not retried/bypassed.
No reviewer edits; final inventory expected artifact only. Platform review N/A.

Next user-only quit/backup, replace Core/Knowledge/Collectors/ViewModel/SelfTests Lua
files (already onK1), preserve all data/diagnostics/other files, reload/selftest96 and
share actual summary/failures. Primary records satisfactory fixture results BEFORE
own ready unstaged `/ca scan`, four current tree bars/hover/unspent/native comparison.
No forced264sample, future/all-rank cost proof, allprofession support, full T02
acceptance, install/gameplay/Git/release or data reset inferred. Source frozen after
review; subsequent changes require affected rechecks/re-review.

## User96/96 assertions PASS; extended selftest lockup/warning — 2026-11-06

User supplies `CraftArmy: 96 passed; 0 failed (pure injected fixtures, not client API
evidence)` BUT reports an extended game lockup and UI warning:

```text
69x LUA_WARNING: !BugGrabber/BugGrabber.lua:-1: insecure scripts exceeded execution limit for addon !BugGrabber
```

Accept assertion success for that run, **NOT** safe client performance/full K2 native
acceptance.69x is supplied warning multiplicity, not69 fixture failures. Warning names
BugGrabber but does not prove root cause there or elsewhere. No measured durations,
offending case, fresh build/time/source hashes or native bar comparison supplied.
Do not disable BugGrabber/suppress warnings or request another existing-suite run.

Static trace: Commands21–25 calls synchronous Tests.Run; SelfTests2718–2725 loops all96
cases without frame breaks. Exact-budget/alias tests repeatedly Copy/Open/Apply/
ViewModel/management-check large50000-value synthetic graphs. Whole-suite blocking is
established by source; exact per-operation cost and warning attribution unmeasured.
K3 proposed/settled runner correction is documented in TASKS36–38, following user's
continue steering: cooperative subcase units across native frames, progress/timing/
cancel/slow-unit fail-safe. No yielding under pcall or temporary namespace overrides;
no skipped assertions, reduced stress sizes or changed production bounds/accounting.

Primary verified all14 reviewed K2 source hashes unchanged and preserved byte-exact
originals at /tmp/opencode/craftarmy-k3-baseline before delegation. New writer scope
ONLY Commands/SelfTests/README/evidence/K3taskstate, no schema/TOC/production arithmetic
changes. All11 other source hashes and diagnostic baseline frozen; primary may create
workspace k3-review.diff after writer stops for permitted independent review. User
native responsiveness/complete expanded suite/warning/timing validation remains open;
native four-bar comparison paused. No new local Lua, gameplay/install/Git/release.

## K3 runner-only implementation delivery — 2026-11-06

**PARTIAL: pieces36–38 delivered; independent review and safe native execution are
INCOMPLETE.** This does not replace the historical user96/96 functional PASS or the
extended lockup/69x warning above. Exact cause/per-operation timings remain unmeasured.
No request to rerun that synchronous suite; no BugGrabber attribution or disabling.

### Changes and safety boundaries

- Changed only Commands.lua, SelfTests.lua, dashboard README/evidence and K3 task
  statuses/current run state/new delivery. Production accounting, Core numeric/copy
  predicates and limits, all schema/TOC/standalone runner/checkers/diagnostics and
  primary planning/review histories remain frozen. No new files/children or Git base.
- `SelfTests.NewRunner(cases?)` snapshots ordered names/functions, with512case and
  10000Step caps. Native Lua5.1 coroutine.resume advances one checkpoint-sized unit;
  case counts/result lines advance only on whole-case return/error. Ordinary case
  assertion errors count FAIL once; malformed input, unexpected yields, cancellation,
  caps and unexpected function drift are explicit INCOMPLETE, never truncated success.
  Cancel releases coroutine/case-list references. Synchronous `Run(cases?)` drains
  these same units, keeps passed/failed/lines compatibility and adds completion status;
  incomplete drains include an explicit INCOMPLETE line for legacy print-only callers.
-105 explicit pause call sites include parameter matrices, native35-path variants,
  repeated captures/large formatting variants, every large-budget Copy/Open/Apply/
  ViewModel/Archive/Delete operation and synthetic boundary counts. The exact50000/
  50001 stress sizes, alias guards and all existing parameter combinations remain.
  No production copier mocks, reduced stress, assertion skips or alternate math guard.
- Checkpoints are only after complete Lua/production operations, never inside a
  protected C/pcall call. Each case's entry C.Apply/K.Evaluate identities are checked
  before yielding and after every resume/return. Unsafe checkpoint attempts throw
  before yielding so existing protected-helper finally cleanup runs. Unknown drift
  stops with reload required; runner never overwrites unknown function changes.
  The K1 repeated-capture loop now wraps each iteration separately in trappedCapture,
  restoring overrides before its inter-iteration checkpoint; the final negative
  capture has its own identical protected wrapper. No yield while those traps live.
- `/ca selftest` remains pre-Login and starts only on explicit out-of-combat request,
  requiring protected finite clock and native Frame capability. Private nonvisual
  OnUpdate executes at most ONE Step, with no drain loops/synchronous timer fallback.
  Repeat=status; cancel/combat/unknown safety stop with no auto-resume. Completion,
  slow units, setup/clock/output/callback failure all detach/hide the driver, retire
  active state and release fixture/clock/frame references (cleanup calls protected).
  Other commands/events/collector behavior is unchanged except usage and combat stop.
- Preferred debugprofilestop ms or GetTimePreciseSec×1000 fallback is protected and
  finite/monotonic checked; invalid/missing clocks do not assume zero. Measured wall
  time and max-unit timing plus case/index/unit/boundary labels are ephemeral/bounded,
  not per-unit append-only histories. Final clock failure explicitly shows last-valid
  wall time. Progress is every10 completed cases or1second in a multi-unit case.
  A unit **>100ms** stops INCOMPLETE after return, including a last passing/error case;
  no completed-suite PASS is printed for that stop. Error case output is retained.
  Max/slow diagnostics show both boundary identities to contextualize variant labels.
  Atomic operations cannot be preempted: source/fixtures do NOT establish native
  responsiveness, warning cause or a hard per-frame CPU guarantee.

### Regression definitions and actual assertion-retention comparison

**111 definitions =96 retained +15 isolated K3 additions. All111 NOT RUN here.** New
fixtures use only small local fake-case runners, never recursively execute the actual
suite. Coverage: multi-unit/count/error/exactly-once results; synchronous parity and
case snapshots; cancel/no-resume; malformed/sparse/512case/10000step caps; unexpected
yields; unsafe-checkpoint finally restoration and unknown drift; strict fake native
Frame one-unit callbacks, lazy start/repeat/cancel/restart/normal/error completion;
no Login/DB/timer/gameplay work; argument/safety/clock/frame no-start; seconds fallback,
invalid/missing/throwing/nonfinite/backward/end-of-unit clocks; slow yielded/LAST pass/
LAST fail stops; ten-case/one-second progress; combat poll/event/no-auto-resume; frame
creation/SetScript/Show, factory/Step/output/status callback exceptions and cleanup.
These definitions are NOT executed Lua or target-client API behavior evidence.

Read-only actual-byte/difflib and token comparisons against preserved originals at
`/tmp/opencode/craftarmy-k3-baseline` **PASS**. Baseline access succeeded; no denied
external read was retried/bypassed. No guessed/staged/Git original was used.

| Actual K2 delta among14 hashed files | Added lines | Removed lines |
| --- | ---: | ---: |
| CraftArmy/Commands.lua |136|8|
| CraftArmy/SelfTests.lua |550|93|
| docs/dashboard/README.md |49|9|

All11 other files are byte-identical. Original SelfTests SHA256 is
`2a64e3a25d425dc90bbe607565b4e8ad07e30d18a261f8ad17bad5ee220713f5`.
Not merely name counting: inverse-plumbing comparison retains **46913 original Lua
tokens**, SHA256 of newline-joined tokens
`547555458124d645c6cba782c21b0ae233839217d31351bfd479c3d79a89459d`.
All original96 ordered names, assertions/literals, calls and loop parameter tokens
match. Only comments/whitespace/optional statement separators, explicit checkpoint
calls/signatures/helper arguments and the documented protected-wrapper relocation are
normalized. Original first96 executable tokens otherwise compare exactly. Reproduce:

```python
from pathlib import Path
import re, hashlib
old = Path('/tmp/opencode/craftarmy-k3-baseline/CraftArmy/SelfTests.lua').read_text()
new = Path('CraftArmy/SelfTests.lua').read_text()
a = old[old.index('local function nonfiniteSamples'):old.index('function Tests.Run()')]
b = new[new.index('local function nonfiniteSamples'):new.index('-- K3 fixtures use ONLY')]
b = re.sub(r'pause\(checkpoint,"(?:[^"\\]|\\.)*"(?:\.\.[a-zA-Z_][a-zA-Z0-9_]*)?\);?\s*', '', b)
b = b.replace('function(checkpoint)', 'function()').replace('extra,checkpoint', 'extra')
b = b.replace('1,checkpoint', '1').replace('0,checkpoint', '0')
pat = r'--[^\n]*|"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'|[A-Za-z_][A-Za-z0-9_]*|\d+|[^\s;]'
def tokens(s): return [x for x in re.findall(pat,s) if not x.startswith('--')]
at, bt = tokens(a), tokens(b)
def locate(seq, sub, start=0):
    return next(i for i in range(start,len(seq)-len(sub)+1) if seq[i:i+len(sub)]==sub)
start = bt.index('"K1 complete 35 paths full currencies provisional264 once privacy and immutable runtime"')
loop, trap = tokens('for _=1,2 do'), tokens('trappedCapture(env,runtime,function()')
i = locate(bt,loop+trap,start); bt[i:i+len(loop+trap)] = trap+loop
end = tokens('eq(#s.timers,0) end) end trappedCapture(env,runtime,function() f.entries')
i = locate(bt,end,start); bt[i:i+len(end)] = tokens('eq(#s.timers,0) end f.entries')
assert at == bt
assert len(at) == 46913
assert hashlib.sha256('\n'.join(at).encode()).hexdigest() == '547555458124d645c6cba782c21b0ae233839217d31351bfd479c3d79a89459d'
names = r'^case\(("(?:[^"\\]|\\.)*")'
assert re.findall(names,a,re.M) == re.findall(names,new,re.M)[:96]
assert len(re.findall(names,new,re.M)) == 111
```

Primary-owned `docs/dashboard/k2-review.diff` remains SHA256
`d4e0ae1703973197bae67a2554740a47a06055cdaf9d18c1c3fa1413dfe1bcef`.
Implementer did NOT create/edit k3-review.diff. Primary generates the actual workspace
comparison after this writer stops for permitted independent-review reads.

### Checks actually run / not run

Inspected both full Python scripts first, then ran (including reruns after code/docs):

```text
python3 tools/check_dashboard.py
PASS: 15 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 71 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
command -v lua5.1
(no path)
```

Both Python checks **PASS exit0**, no baseline failure observed. Read-only Python
hash/difflib/token comparison commands PASS as above. `lua5.1 tests/dashboard.lua` and
`lua5.1 tests/run.lua` **NOT RUN**: approved runtime absent. No install/download/embedded
or substitute runtime, game/API execution, real DB/math mutation, profiling CVar/error
handler changes, gameplay, release/deploy/Git action. Platform review N/A.
Expanded native selftest111, real frame scheduling/timing/cancel behavior, safe
responsiveness/warnings and K2 current bars/hover/unspent comparison all **NOT RUN**.

### K3 current14 source freeze

```text
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
68fa0719550f6befbf1f094966c5115d1425e1f9fdad1a30737bab67dfc7d441  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
4fa5c2d0817be04c55eada64934f70f680cbc2c6d0a83943cf4411153ac9e60c  CraftArmy/Collectors.lua
0583a6ec9966f19bb53f506042b48fb8f688e3e0117f67187205ddbd45d47da3  CraftArmy/KnowledgeCheck.lua
a9116a628a7168ec6b3cf0a7ef9be4878350da8cf87a15b39b16ca600b7d38f0  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
fda95e1fe727d224371f57e0f2f0cf9777b7b78b6fcffefa04c00b2cfe3c428b  CraftArmy/SelfTests.lua
b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3  CraftArmy/Commands.lua
601990e4a67b4fc3fb048bbf86cb8337974dd3323e771ea20adfcfd18a8edab4  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
1026bde1bfb709dace442c0820f0d11d378972a5916cfe52f361516e975c8f6a  docs/dashboard/README.md
7f9e414fddc43c1533b5b05f0b09f39723e6f579f8506b3ab20b0162b22f23cb  docs/dashboard/schema.md
```

Final evidence SHA256 is recorded in TASKS K3 delivery, not self-hashed here. Resume
**primary**: generate actual K2→K3 workspace diff, request independent read-only review
of this frozen pair/checkpoints/assertion retention/clock/error lifecycle, and persist
findings before any user update recommendation. After review only, user backs up and
updates Commands/SelfTests (two Lua files), preserving K2/DB/diagnostics. Native bars
stay paused until satisfactory safe complete expanded fixture execution. No full T02
acceptance or release inferred from this delivery or structural checks.

## K3 primary comparison/checkpoint preservation recheck — 2026-11-06

Primary verified all14 current hashes, exact Commands/SelfTests/README delta and11
byte-frozen files vs preserved K2 originals. Pre-append evidence SHA256:
`8ca38283c85b78f44a5b43d5c00b97344a4730e9068c4ad9af22c46eed9b6f87`.
Generated actual workspace `docs/dashboard/k3-review.diff`1541lines, SHA256
`3d742fcc86c5c829e9409be179a772fd20cfd554a8c07eae890a5f65b55b59b3`,
for permitted independent reads; no external permission retry or guessed source base.
Primary read/replayed the documented Python inverse-plumbing token comparison:
46913 original assertion/parameter tokens and96 ordered names retained,111definitions.
Both inspected Python checks rerun PASS15paths/23Markdown docs/71links/eight unchanged
diagnostic hashes. These are source/structure checks, not Lua scheduling/execution or
native performance proof. Frozen runner changes sent for independent review before
two-Lua user update recommendation; production accounting remains untouched.

## K3 final primary-persisted static review — 2026-11-06

Reviewer COMPLETE / static acceptance **PASS**, Lua/client/performance **INCOMPLETE**.
Read all1541 actual diff lines, current runner/command/checkpoints and all15 added
fixtures. No concrete blocking source/test defect found. Safe checkpoint placement
avoids protected C/pcall yield and active namespace override; count/cancel/drift/
one-Step-frame/slow-LAST-unit semantics match contract.10000-step fixture checkpoints
every100 inner steps. Backward profile-clock resets stop safely. Atomic operations
non-preemptible; no native responsiveness or warning resolution established.

Reviewed target current14 freeze above; SelfTests
`fda95e1fe727d224371f57e0f2f0cf9777b7b78b6fcffefa04c00b2cfe3c428b`, Commands
`b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3`.
Actual K2→K3 artifact SHA256
`3d742fcc86c5c829e9409be179a772fd20cfd554a8c07eae890a5f65b55b59b3`.
Original96 assertion/stress changes are checkpoint plumbing/wrapper relocation, not
weakened coverage. Primary verified14/exact3deltas11frozen/46913tokens96names111count;
reviewer did not execute those checks. Reviewer attempted both Python checks but
permission denied before execution; NOT RUN/no bypass/retry. Prior Python PASS remains
primary/implementer evidence. No reviewer edits; platformreview N/A.

Next user only: quit/back up, replace Commands.lua/SelfTests.lua, preserve all other
addon files/K2/SavedVariables/diagnostics; reload then explicit out-of-combat selftest.
111 definitions, NOT RUN. Wait for explicit COMPLETE/INCOMPLETE, share final counts/
wall/max-unit/identity and whether freeze/warnings recur. Cancel command available;
slow-stop or clock/error/combat incomplete is not a pass and should be reported once,
not repeatedly rerun. Native bars comparison stays paused until satisfactory safe
completion. No CVar/error-handler/BugGrabber changes, new warning attribution, saved
data mutation, gameplay/installation/Git/release or full T02 acceptance.

## K3 native42/111 slow-stop; R5 fixture refinement — 2026-11-06

User supplies started111/progress/42PASS lines and final **INCOMPLETE42passed/0failed
of111**, wall5860.4ms, maximum109.7ms. Case42 `R5 filter shrink grow archive paging
selection and confirmation stay reachable` unit1/case-return exceeds100ms. Max boundary
starts with previous case41 geometry's finalreturn, ends in42; this does not implicate
the alreadycompleted41 fixture. Earlier progress wall4819.4/max18.8ms,42slowstep caught
andreported rather than claimed full success. All first42 assertion outcomes PASS;
remaining69 NOT RUN. No new build/time/installed hashes or explicit warning-recurrence/
gameinteractivity report; do not infer original69x warning resolved from timing alone.

Source trace: case42 SelfTests1179–1207 has no checkpoint parameter;37-row helper plus
many complete paging/filter/Refresh/Archive/UI transitions execute in one unit. K3a39
settles optional setuphelper checkpoints and individual case42 operation boundaries,
plus nearby R5geometrysetup/screenfit/status variant boundaries. Preserve111cases/all
assertions/parameters/real synthetic work and unchanged100ms cutoff. No production/
Commands/errorhandler/clock-policy changes or skipped cases. User should not rerun
this same version. Primary matchedall14 currentK3hashes and preservedexactbaselines
at /tmp/opencode/craftarmy-k3a-baseline beforeonewriterhandoff. Allowedhashedchanges
SelfTests/README only;12othersfrozen. Review then userSelfTests-only update/reload/test;
new native timing remains unverified. Native bars/hover/unspent comparison stillpaused.

## K3a piece39 checkpoint-only delivery — 2026-11-06

**PARTIAL — implementation delivered, independent review and native safe completion
pending.** Only SelfTests.lua, dashboard README/evidence and authorized piece39/current
run state/new delivery in TASKS changed. No new implementation files, duplicate heavy
fixtures, children, installs, alternate runtime, game/real DB/math mutation, profiling,
error-handler changes, Git or release. Platform review N/A. Production/Commands and
all other assigned frozen paths remain unchanged.

### Exact helper/case scope and checkpoint safety

- `dashboardRows(count,checkpoint?)` retains no-argument callback compatibility. Four
  new pause sites: after each complete fixture `C.Apply` plus its assertion, before
  collector/UI construction, after construction/before Toggle, after complete Toggle.
  All callbacks use existing `pause` and unchanged NewRunner safety checks.
- Case41 geometry: passes its existing callback to the helper, with identical
  `{0,1,2,12,13,37}` variants, geometry/header/confirmation assertions and order.
- Case42 filter/paging: callback signature/helper argument plus18 pauses, after initial
  state, each of3 Next clicks, selected Lifecycle/delete confirmation, shrink filter,
  cancel click, growth filter, offset-clamping Refresh, both mousewheel calls, Previous
  click, both profession selections, each of2 Archives, and each archive-view toggle.
  Each operation and its associated original assertions finish before pausing. Same37
  rows, event handlers, ordered state assertions and `first` widget-identity check.
- Case43 screen fit: callback/helper argument;3 pause sites after each of7 existing
  variant Refresh/assertion groups and the2 post-loop unavailable/recomputed Refresh
  groups. Case44 status: callback/helper argument;1 pause site after each of9 existing
  status Refresh/hover/immutability assertion groups. No other cases changed.
- **26 added pause sites** =4 helper+18 case42+3 case43+1 case44; **131 total calls**
  (formerly105; raw regex count includes1 extra helper definition). Four optional
  callback signatures total (helper+cases42–44),4 helper call arguments (cases41–44).
  SelfTests textual delta **39 added/12 removed lines**, wholly checkpoint plumbing.
  No yields under pcall, inside C.Apply/Archive/UI handlers or shared namespace
  overrides; synthetic fixture-local state persists between completed operations.
  Atomic work remains non-preemptible; no hard per-frame latency promise.

### Actual readable pre-edit workspace retention proof

The external directory read `/tmp/opencode/craftarmy-k3a-baseline` was permission-denied.
No retry, alternate access or denied-directory content reconstruction was attempted.
Instead, BEFORE editing, a read-only Python hashlib check matched **all14 current
workspace files** to the exact primary-persisted K3 freeze above and computed full
SelfTests tokens/ordered names from those readable actual bytes. Pre-edit SelfTests
SHA256 `fda95e1fe727d224371f57e0f2f0cf9777b7b78b6fcffefa04c00b2cfe3c428b`.
The following inverse of ONLY this pass's plumbing reproduces those same workspace
bytes exactly, not a guessed baseline; primary still owns actual preserved-baseline
workspace diff generation after this writer stops. No review artifact was written.

Read-only Python retention/difflib command **RAN/PASS**: **52830 full-file original
tokens**, including all111 cases/assertions/parameters/stress literals, retained;
ordered111 names retained, no weakening, skipped cases or reduced counts. This is
stronger than name counting: inverse-plumbing whole-file SHA256 equals actual pre-edit
bytes. Reproduce without external reads or writing files:

```python
from pathlib import Path
import re, hashlib
sha = lambda b: hashlib.sha256(b).hexdigest()
s = Path('CraftArmy/SelfTests.lua').read_text()
a = re.sub(r'^ +pause\(checkpoint,"K3a [^"\n]*"\)\n', '', s, flags=re.M)
a = a.replace('local function dashboardRows(count,checkpoint)', 'local function dashboardRows(count)')
for arg in ['count', '37', '13', '1']:
    a = a.replace('=dashboardRows('+arg+',checkpoint)', '=dashboardRows('+arg+')')
for name in ['R5 filter shrink grow archive paging selection and confirmation stay reachable',
             'R5 screen fit uses shared Finite and positive local scale on small invalid screens',
             'R5 friendly status keeps raw unknown error block reasons and does not mutate collector']:
    a = a.replace('case("'+name+'",function(checkpoint)', 'case("'+name+'",function()')
a = a.replace('    local ui=NS.Dashboard.New(env,collector)\n    ui:Toggle()\n',
              '    local ui=NS.Dashboard.New(env,collector); ui:Toggle()\n')
assert sha(a.encode()) == 'fda95e1fe727d224371f57e0f2f0cf9777b7b78b6fcffefa04c00b2cfe3c428b'
pat = r'--[^\n]*|"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'|[A-Za-z_][A-Za-z0-9_]*|\d+|[^\s;]'
tokens = [x for x in re.findall(pat,a) if not x.startswith('--')]
assert len(tokens) == 52830
assert sha('\n'.join(tokens).encode()) == '01a225503d8b6d9f264223dfaf185624b9993b3a2b45bb63fc58ef4b8aff9919'
names = re.findall(r'^case\(("(?:[^"\\]|\\.)*")', s, re.M)
assert len(names) == 111 and names == re.findall(r'^case\(("(?:[^"\\]|\\.)*")', a, re.M)
assert sha('\n'.join(names).encode()) == '99a1dd609ee1c5f89712c794fe3c5a327fa817e5e0cf67f7d9ca8a41e9b2d3bb'
assert len(re.findall(r'^ +pause\(checkpoint,"K3a ',s,re.M)) == 26
assert len(re.findall(r'\bpause\(checkpoint,',s))-1 == 131
```

### Checks RAN / NOT RUN and native evidence boundary

Inspected both complete scripts, then ran `python3 tools/check_dashboard.py` and
`python3 tools/check_diagnostics.py`: **PASS exit0**. Dashboard:15 required paths,
exact9-Lua TOC/metadata/isolated DB,23 Markdown/71 local links/eight diagnostic hashes
unchanged. Diagnostics:9 paths/exact4-Lua TOC/metadata/DB. No check failure observed.
Read-only Python pre-edit14/hash, post-edit2-delta/12-frozen, old artifacts, inverse
whole-byte/token/name retention and difflib checks **PASS**. `command -v lua5.1` returned
no path (exit1); `lua5.1 tests/dashboard.lua` and `lua5.1 tests/run.lua` **NOT RUN**.
No installation/alternate runtime. Python is not Lua syntax/execution/API evidence.

Historical native K3 **INCOMPLETE42passed/0failed of111**,109.7ms max/wall5860.4ms,
remains unchanged; it correctly stopped at100ms rather than claiming full PASS.
Warning recurrence/interactivity were not supplied. **K3a all111 Lua/native execution,
frame timings/responsiveness/warning recurrence NOT RUN**; no fix-performance claim.
No new diagnostic run or native bars/hover/unspent comparison. Existing K3 runner
regressions retained, no duplicate expensive regression introduced for this plumbing.

### K3a current14 source freeze

Exactly SelfTests/README differ from the hash-verified pre-edit K3 workspace;12 frozen:

```text
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
68fa0719550f6befbf1f094966c5115d1425e1f9fdad1a30737bab67dfc7d441  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
4fa5c2d0817be04c55eada64934f70f680cbc2c6d0a83943cf4411153ac9e60c  CraftArmy/Collectors.lua
0583a6ec9966f19bb53f506042b48fb8f688e3e0117f67187205ddbd45d47da3  CraftArmy/KnowledgeCheck.lua
a9116a628a7168ec6b3cf0a7ef9be4878350da8cf87a15b39b16ca600b7d38f0  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
8d2e9be128ddd18d73a1bb8f71c8a974ed246872b5d3d283b0924f888aa97426  CraftArmy/SelfTests.lua
b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3  CraftArmy/Commands.lua
601990e4a67b4fc3fb048bbf86cb8337974dd3323e771ea20adfcfd18a8edab4  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
1a3ad3ad6c28644a7d11fe1da4dc58ed95ef6e75ea4a2fc50f8c8d3f099c4da5  docs/dashboard/README.md
7f9e414fddc43c1533b5b05f0b09f39723e6f579f8506b3ab20b0162b22f23cb  docs/dashboard/schema.md
```

Old k2-review.diff SHA256 `d4e0ae1703973197bae67a2554740a47a06055cdaf9d18c1c3fa1413dfe1bcef`
and k3-review.diff SHA256 `3d742fcc86c5c829e9409be179a772fd20cfd554a8c07eae890a5f65b55b59b3`
remain unchanged. Final evidence hash is recorded in TASKS, not self-hashed here.

**Exact resume: primary generates `docs/dashboard/k3a-review.diff` from actual preserved
K3 bytes, obtains independent read-only review and persists findings before user update.**
README conditions on that review: already-on-K3 user quits/backs up, replaces ONLY
SelfTests.lua, keeps Commands/K2/DB/all SavedVariables/diagnostics, reloads and explicitly
selftests out of combat.111 definitions, wait for COMPLETE/INCOMPLETE/timing/recurrence
report, cancel available; new slow-stop shared once, no repeat unchanged version. No
threshold raise, skipped tests or automatic resume. Native bars stay paused until
satisfactory safe complete fixture/performance evidence. No writer piece/design blocker
remains; independent review/native evidence are pending gates, not release approval.

## K3a primary frozen comparison and retention recheck — 2026-11-06

Primary generated actual K3→K3a workspace diff `docs/dashboard/k3a-review.diff`,227lines/
15071bytes/SHA256 `33fc9137b676f6d17efe04e4fb87e4a4649d406da2ed948f1f7093776d92767e`.
All14 current hashes/evidence pre-append
`8aaeb31ad1c082e21a554bd743047110f4106fbba910eddc8f345291d14b2569`
matched; exact SelfTests/README delta/12frozen. Primary inspected/replayed the inverse
recipe: exact original pre-K3a SelfTests SHA recovered,52830 oldtokens/111 orderednames
retained,26 new pause sites,131 total. Both inspected Python checks PASS15paths/23docs/
71links/eight diagnostic hashes unchanged; separate diagnostic structure PASS.
No Lua/native timing result. Send frozen helper/cases41–44/diff to independent reviewer;
no denied external-directory access required or retried. No new production change.

## K3a final primary-persisted review — 2026-11-06

Reviewer COMPLETE/static **PASS**, Lua/native/performance **INCOMPLETE**. Read full
227-line actual diff/current helper+cases41–44/README and contract. No blocking finding.
Checkpoints follow completed operations/assertions outside pcall/UI handlers/shared
overrides; synthetic state remains isolated across yields.37-row workload, widget
identity and all111 assertions preserved. No guarantee future units stay below100ms.

Reviewed actual K3→K3a diff SHA256
`33fc9137b676f6d17efe04e4fb87e4a4649d406da2ed948f1f7093776d92767e`;
SelfTests target `8d2e9be128ddd18d73a1bb8f71c8a974ed246872b5d3d283b0924f888aa97426`,
README target `1a3ad3ad6c28644a7d11fe1da4dc58ed95ef6e75ea4a2fc50f8c8d3f099c4da5`.
No Git/staged distinctions;12 other hashes frozen perprimary. Reviewer read-only, no
commands/edits/permission retries/bypasses; primary's Python/hash/inverse-token checks
remain primary-attributed. No moving source observed; platform review N/A.

Next primary confirms frozen scope then already-onK3 user backs up/quits, replaces
ONLY SelfTests.lua, preserves Commands/K2/SavedVariables/diagnostics, reloads and runs
explicit out-of-combat selftest111. Report final COMPLETE/INCOMPLETE/timing and warning/
interactivity evidence; new slowstop reportonce without unchangedversion rerun. Native
bars/hover comparison remains paused. No performance/warning resolution/fullacceptance/
source policy/threshold change, release or newdiagnosticrun implied.

## K3a user62/111; maximum report unit140.4ms — 2026-11-06

User supplies full progress/PASS output through case62 and final INCOMPLETE62passed/
0failed of111, wall20823.1ms, maximum140.4ms. Case63 `K1 byte and line budgets retain
reserved end summary never clipped success and pure format`, unit1 label `K1 maximum
capture` crosses unchanged100ms. Previousmax84.2ms. Starting boundary names completed
case62 but finalcase63 work is the measured unit. R5cases41–44 PASS, including earlier
slow case42;42/111109.7ms report remains history.49 cases notcompleted,63 alreadystarted;
not111PASS. No explicit gameinteractivity/warning recurrence/build/time/hash report.

Source case63 SelfTests1875–1894 constructs8×64=512-path synthetic fixture then calls
KnowledgeCheck.Capture before first checkpoint. Capture413–427 wraps capture in pcall
and performs Format before returning. Combined fixture-construction/capture/format
unit took140.4ms; individual phase timings unmeasured. More pauses outside Capture
alone cannot split protected internal work. No claim one atomic sub-call alone took
140.4ms or that BugGrabber caused/is cleared by this report. Do not rerun unchanged.

Primary proposes a scoped KnowledgeCheck refactor into bounded resumable read-only
capture/format jobs, with current synchronous Capture/Format preserved as compatibility
drains and identical report/result semantics. Maximum stress fixture can drive these
jobs through existing safe checkpoints; no yield across pcall/active overrides. Keep
all512paths/byte+line budget stress, old111 assertions and100ms cutoff; no reduced
stress, skipping, production accounting/bounds/schema changes or diagnostic edits.
This expands earlier frozen-module scope and requires user approval/complete contract
before implementation. No new source edits/delegation/quality PASS claimed. Native
bars/hover/unspent still paused; remaining per-unit performance remains a user gate.

## K3b read-only job refactor authorized / pre-edit base — 2026-11-06

User Yes to broader resumable capture/formatter fix. TASKS40–42 READY; distinct
Step/Cancel jobs preserve synchronous API/output semantics, full512-path/byte/line
stress and old111 assertions. Source collection/serialization privacy/bounds stay;
no production K2 accounting/Commands/scheduler/100ms/10000step changes. Job completion
doesn't mean report data complete; no partial/cancelled candidates promoted.

Primary verified current14 hashes and preserved exact originals under
/tmp/opencode/craftarmy-k3b-baseline. One writer owns KnowledgeCheck/SelfTests/README/
evidence/taskstate;11otherhashedfiles/diagnostics/oldartifacts frozen. Primary owns
planning/review and later generated workspace k3b-review.diff. No source changed
beforehandoff or native/performancePASS. Report input to format jobs is borrowed
immutable until completion; capture owns private report through terminal state.
All current slowstop history remains; no unchanged-version rerun or release implied.

## K3b implementation delivery / review freeze — 2026-11-06

**PARTIAL**: pieces40–42 implemented; independent static review and Lua/native
acceptance **INCOMPLETE**, not a performance PASS. Only KnowledgeCheck/SelfTests/
README/evidence and authorized K3b task-state/new-delivery text changed. One serial
writer, no children. Platform review N/A. No installs, alternate runtime, game/API/DB
execution, profiling/error-handler changes, Git, publication or release.

### Exact jobs, lifecycle and bounds

- `NewCaptureJob(env,runtime,options?)` / `NewFormatJob(report,options?)` return
  `Step`/`Cancel` jobs with status, completed, steps, phase, bounded label and per-unit
  `pathUnits`/`lineAttempts`. Generic methods retain no per-job closures. Only the
  running coroutine owns work/env/runtime/input/buffers; terminal state clears it.
  Success publishes report or text/effective summary only at completion. Error,
  invalid options, cap exhaustion and cancellation publish no partial result;
  repeated terminal Step/Cancel are inert. Native resume catches worker errors and
  validates a private yield token; no error/yield payload is retained.
- Plain options recognize only `stepLimit`: integer1..10000, default10000, never a
  higher cap. Unknown keys, metatables, wrong types/nonfinite/out-of-range values
  fail closed before work starts; at most two option keys inspected.
- Capture units: start metadata/boundary; per-tab currencies/root; **one complete
  path maximum**; finish boundary; candidate reconciliation per tab; shared currency
  reconciliation per tab; transition to formatting. All8tabs/64paths pertab/
  16children/32entries/maps/64currencies/16costs and limit+1 inspections remain exact.
  Every bounded path is captured even when later text clips. The initial context,
  config/source and runtime revision/serial/staging token spans the whole collection
  interval. Time ends at collection finish; pure formatting never requeries context.
- Format units: **at most eight add attempts, including clipped no-ops**, or a
  bounded body/summary/footer transition (summary trees also split every8). Each
  bounded record encode and final<=256KiB concat remain atomic.256KiB/4096lines/
  4096byte reserve, body4080line guard, deterministic labels/field order/trailer and
  clipped candidate/shared/tree suppression are unchanged. No latency guarantee.
- Capture report stays private. Format borrows caller-owned immutable input through
  terminal; no global Core.Copy of oversized reports. Work completion is distinct
  from report.captureComplete: missing API/data, unstable/staged boundaries or output
  clipping can finish the job normally but never claim complete evidence.
- `Capture` and `Format` synchronously drain these jobs. Public `/ca knowledgecheck`,
  copy UI and Commands stay synchronous/unchanged; production K2 accounting, schema,
  mapping/collection/UI, DB/SavedVariables and diagnostics remain frozen.

### Exceptional fallback differences (intentional, not ordinary-data changes)

Old unexpected capture exceptions retained the sanitized prefix collected before
the exception, clearing aggregate candidates. New incomplete jobs expose no report;
the compatibility Capture wrapper returns a **fresh blank incomplete version1** with
the existing `protected capture failure (payload omitted)` reason and no prefix or
path candidates. Ordinary missing/nil/throwing API statuses still complete the worker
and retain the same evidence/statuses as before. Old unexpected Format errors could
escape; new Format returns a fresh bounded version1 fallback, outputTruncated=true,
captureComplete=false, `format incomplete (payload omitted)`, unknown reconciliation
and no candidate/shared/trees. Step cap/invalid-yield failures likewise cannot return
a passing prefix. No raw private error/yield payload, global monkeypatch or borrowed
candidate is used to manufacture fallback success.

### Fixtures and actual-pre-edit retention proof (source only)

**123 definitions = original111 +12 appended job cases**, not execution. Only case63
changes old call plumbing: full8×64=512 fixture setup can checkpoint after each
complete synthetic path/tab; capture and BOTH subsequent real formatting operations
use outer Step/checkpoint loops. All8tabs/512discovered/512captured plus64per-tab are
new stronger assertions. Original600minimal records remain, built in chunks of8;
all old byte/line/summary/truncation/purity assertions and stress values remain.
Extra max-report privacy assertions added. No yield while trappedCapture overrides
are active; the new trap regression protects just one returned job Step at a time,
restores namespaces, then pauses. All other old cases and runner bytes are untouched.

The12 additions cover fresh normal35/zero/API-error/mismatch report and format
parity, explicitly clipped format inputs (without a duplicate maximum capture),
actual per-Step node-read counts, exact8-attempt accounting including early-clipped
no-ops, no partial outputs, independent jobs/repeated terminal calls, capture cancel
before start/between paths/during formatting and format cancel, terminal reference
release, lower cap/invalid options, unexpected exceptions/yields and private fallback,
between-slice identity/source/config/revision/serial/staging/closure invalidation,
job-vs-data completeness with empty/nil/error/unsupported reads, no context/time
refresh during formatting, immutable borrowed graphs/read-only traps/privacy, and
summary-reserve overflow/footer fail-closed behavior. New sizable compatibility
calls and every returned job Step have outer checkpoints. These are injected fixture
definitions, never evidence of native API behavior or frame timing.

BEFORE writing, Python hashlib matched all14 actual readable workspace files to the
primary K3a freeze and retained their exact bytes in
`/tmp/opencode/craftarmy-k3b-writer-preedit`. No external baseline permission denial
occurred or was retried/bypassed; primary's separately preserved base remains
`/tmp/opencode/craftarmy-k3b-baseline`. No writer-generated review.diff artifact.

Read-only Python inverse/difflib/token checks **RAN/PASS** against those actual bytes:

- Invert ONLY optional knowledgeFixture callback/pauses, added steppedJob helper,
  case63 Capture/Format-to-job plumbing, new512 coverage/privacy assertions and
  eight-record setup checkpoints; remove only the appended K3b definitions/helper.
  Exact whole original SelfTests bytes recovered, SHA256
  `8d2e9be128ddd18d73a1bb8f71c8a974ed246872b5d3d283b0924f888aa97426`.
  All **52999 original full-file tokens** retained, newline-joined token SHA256
  `1d9bccede2297012138e61a6787c60842e58c0d545da283bf8ff19b8c1259f48`.
  Original111 ordered quoted names SHA256
  `99a1dd609ee1c5f89712c794fe3c5a327fa817e5e0cf67f7d9ca8a41e9b2d3bb`.
- KnowledgeCheck helpers through blank(), encode and Show byte-identical. Remove
  only capture unit callbacks/signature/early-return callback plumbing: **1762 old
  capture algorithm tokens** match exactly, SHA256
  `b776a3610b64822678da2056fa5d5277341177b0c06ee4e023633a9c7a54dfc7`.
  Invert formatter signature/add-attempt accounting/body unit/8-tree loop plumbing:
  **775 old formatter algorithm tokens**, SHA256
  `c59467375071ff5ba4ed7f266c33fb1ad06ee313e1a61283aa838af849caebaa`.
  Compare old literal serializer labels/order and every add clipping guard explicitly:
  same budget.clipped,4080line,262144-4096byte guards and append byte arithmetic.
  New add's accounting is outside the old early returns, so clipped no-ops also yield.
- Tokenization recipe is the K3a regex above (quoted strings/identifiers/numbers/
  punctuation excluding comments/whitespace/semicolons). Whole-byte SelfTests inverse
  is stronger than a name-only comparison. Algorithm correspondence is source
  evidence, **not** a claim that two callers of the new implementation alone prove
  old behavior, Lua correctness or measured performance. Exceptional differences are
  enumerated above; normal parity definitions remain NOT RUN.
- Actual textual deltas: KnowledgeCheck124added/25removed; SelfTests242added/6removed;
  README57added/14removed. Exactly3 allowed deltas among14;11 byte-frozen.

### Approved checks RAN / NOT RUN

Inspected full `tools/check_dashboard.py`, `tools/check_diagnostics.py` and both Lua
runner scripts before running checks. Python tools are read-only stdlib packaging/
docs/hash inspection, not Lua parsing/execution. Implementer ran:

```text
python3 tools/check_dashboard.py
PASS: 15 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 71 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated

python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
```

Both exit0, no observed structural failure. Runtime gate `command -v lua5.1` found
no path; `lua5.1 tests/dashboard.lua` and `lua5.1 tests/run.lua` **NOT RUN**. No install,
download/substitute runtime/compiler/lint/game/API action. All123 Lua fixtures,
native scheduling/timing/responsiveness/warning recurrence, public-command native
capture/copy and K2 bars/hover/unspent comparison **NOT RUN** for K3b. No new diagnostic
result. Historical K3a62/111,0FAIL, case63 combined140.4ms/wall20823.1ms remains
INCOMPLETE; no individual phase timing or warning/interactivity evidence inferred.

### Current14 freeze and exact resume

```text
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
68fa0719550f6befbf1f094966c5115d1425e1f9fdad1a30737bab67dfc7d441  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
4fa5c2d0817be04c55eada64934f70f680cbc2c6d0a83943cf4411153ac9e60c  CraftArmy/Collectors.lua
214550def55ff05025c933fe1375cdd969cce954736dbd87403e0e9d6ba43f89  CraftArmy/KnowledgeCheck.lua
a9116a628a7168ec6b3cf0a7ef9be4878350da8cf87a15b39b16ca600b7d38f0  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
1987100363dd229b130ee352523060950fe3d85745e362d24a063dcbec77e933  CraftArmy/SelfTests.lua
b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3  CraftArmy/Commands.lua
601990e4a67b4fc3fb048bbf86cb8337974dd3323e771ea20adfcfd18a8edab4  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
3758d4cc17558fac6d8f09ffbd07898d78421c53eb15fee82a8ebec5c8e21c54  docs/dashboard/README.md
7f9e414fddc43c1533b5b05f0b09f39723e6f579f8506b3ab20b0162b22f23cb  docs/dashboard/schema.md
```

Old artifacts byte-unchanged: k2-review.diff
`d4e0ae1703973197bae67a2554740a47a06055cdaf9d18c1c3fa1413dfe1bcef`, k3-review.diff
`3d742fcc86c5c829e9409be179a772fd20cfd554a8c07eae890a5f65b55b59b3`, k3a-review.diff
`33fc9137b676f6d17efe04e4fb87e4a4649d406da2ed948f1f7093776d92767e`.
Final evidence hash is recorded in TASKS, not self-hashed here.

**Primary next:** after writer stops, generate permitted `docs/dashboard/k3b-review.diff`
from actual preserved K3a bytes; obtain independent read-only review of frozen jobs,
whole-interval stability, bounded formatting, terminal reference release, algorithm/
old111 retention and all123 definitions; persist findings before recommending update.
No executable design blocker remains. Only after review: already-on-K3a user quits/
backs up, replaces ONLY KnowledgeCheck.lua/SelfTests.lua, keeps Commands/allK2/DB/
SavedVariables/diagnostics, reloads and explicitly selftests out of combat. Report
actual COMPLETE/INCOMPLETE counts, wall/max timings, case/unit/label and warning plus
interactivity evidence. Cancellation stays `/ca selftest cancel`; any new slow stop
is shared once, no unchanged rerun/threshold raise/skips/autoresume. Native bars stay
paused until satisfactory safe complete fixture/performance evidence. Delivery is
not independent verification, acceptance or release.

## K3b primary comparison and independent review — 2026-11-06

Primary generated actual preserved K3a→K3b comparison `docs/dashboard/k3b-review.diff`,
659lines/41190bytes, SHA256
`7aadd2399ee73e0753f66596fae01886b8ec2909a1ca7ff76ce2622b140b06e0`.
Before review all14 target hashes and evidence
`c2423e27615c5449789b2ef7376d97ddfbf3e96e0fa5d5a3ef2536c60065f6a4`
matched. Actual3deltas KnowledgeCheck/SelfTests/README,11others and3oldartifacts frozen;
111 ordered names preserved plus12new. Primary inspected/ran both approved Python
checks PASS15paths/23docs/71links/eightdiagnostichashes and separate9diagnosticpaths.
Structural/source evidence only, not Lua parsing/execution or client responsiveness.

Independent verifier COMPLETE/static **PASS**, overall **INCOMPLETE**, no blocking
finding. Reviewed full actual diff/current jobs/tests/contract/docs and relevant
runner/collector behavior. Confirmed yield boundaries outside protected API operations,
outer fixture checkpoints after namespace restoration;1path/8addattempt units including
clippednoops; bounded footer/concat; terminal worker/unpublished result release and
sanitized errors. Whole collection attribution spans slices without formatting-time
context refresh. Old collection/candidate/serializer/clipping guards retained, not
merely new-vs-new parity. Case63 still512paths/600records/both real formatting workloads;
123definitions, no forced suite cap exhaustion found statically. Existing synchronous
API/command behavior and documented exceptional fallbacks accepted statically.

Reviewed source hashes are the14freeze above, artifact SHA above. Verifier no edits;
attempted approved Python execution permission-denied, no retry/bypass. Python/hash
success attributed to primary/implementer, not reviewer. No independent post-check
hash command available to reviewer; primary rechecks before recommending update.
Lua suites NOT RUN, approved lua5.1 absent; no substitutes/installs. No moving source
observed. Platform review N/A; no publication approval.

Next: user quits/backs up, replaces ONLY KnowledgeCheck.lua and SelfTests.lua, keeps
Commands/K2/DB/all SavedVariables/diagnostics, reloads/outcombat `/ca selftest`123.
Wait explicit COMPLETE/INCOMPLETE with counts/wall/max/case/unit/label; report warning
recurrence and whether game remained interactive. Cancel unchanged, newslowstop
reportonce/no unchanged rerun/thresholdraise/skips. No guarantee atomic units<100ms.
Historical62/111140.4ms remains INCOMPLETE; native bars/hover/unspent comparisons stay
paused pending satisfactory safe full completion/performance evidence.

## K3b user66/123 slow-stop; K3c case66 checkpoints READY — 2026-11-06

User supplies final summary only: INCOMPLETE66passed/0failed of123, wall65297.9ms,
max102.8ms at case66 `K1 combat command does no capture UI focus timer or deferred
automatic work`, unit1/case return.66 completedPASS,57notcompleted. Case63 maximum
stress and64–65 passed in this run; no claim123PASS or acceptance of appended cases
112–123. Start boundary names completedcase65, endboundary66; don't attribute timing
to65 alone. Individual setup/command/UI phase timings unmeasured. No explicit build/
installedhash/interactivity/warning report, no BugGrabber causality/resolution inferred.

Source1955–1971 case66 groups fixture setup, blocked combat checks, two real synchronous
35path command captures/formats/copy-window operations, and final combat assertions.
K3c43 adds four safe OUTER pauses between completed groups, preserving both actual
commands/widget reuse and every assertion/123case size. No stubs/jobs substituted for
command integration, no yields inside command/Show/pcall/namespace overrides. Production
KnowledgeCheck/Commands/K2/100ms/10000suitecap remain frozen. Per-command latency not
established or guaranteed<100ms; a future atomic slowstop requires review, not skips.

Primary verified all14 current K3b frozen hashes and preserved actual pre-K3c bytes
at /tmp/opencode/craftarmy-k3c-baseline. Writer owns only SelfTests/README/evidence/
43taskstate;12otherhashedfiles/all4priorartifacts frozen. Exact inverse fourpause+
callback plumbing must recover original SelfTests bytes. Primary makes actual workspace
k3c-review.diff after writer stops, then independent review before SelfTests-only
userupdate. Do not repeat currentversion. Native bars/hover/unspent comparisons stay
paused pending satisfactory safe complete suite/performance evidence.

## K3c43 NEW implementation delivery — 2026-11-06

**PARTIAL — implementation delivered, independent review and client gates pending.**
One synchronous writer, no children. Changed only SelfTests.lua, dashboard README,
this append and authorized43/current run/new delivery in TASKS. Platform review N/A.
No new files or review artifact; primary owns the later actual k3c-review.diff.

### Exact checkpoint scope and retention proof

Only case66 `K1 combat command does no capture UI focus timer or deferred automatic work`
changes: `function(checkpoint)` and four complete-operation outer pauses, in order:

1. `K3c first combat checks` after the original initial combat/Show assertions.
2. `K3c before first command` after `s.combat=false` and the unchanged widget assertion.
3. `K3c first command complete` after the first real Run/assertions/window/text/count setup.
4. `K3c repeat command complete` after the second real Run and all repeat assertions,
   before the final combat transition.

Both real synchronous35-path commands, capture+format+Show, remain atomic and fully
exercised. No job substitution/monkeypatch, helper/case/runner change or pause inside
command/Show/pcall/temporary override. Every original assertion/operation/parameter/
count and all other source bytes retained;100ms/10000suite-step limits unchanged.
No source proof guarantees an individual command<100ms; a later atomic slow-stop
must return to planning, not weaken integration coverage or raise thresholds.

BEFORE editing, read-only `python3 - <<'PY'` hashlib inspection matched all14 current
workspace files to the K3b delivery freeze. Actual pre-edit SelfTests SHA256:
`1987100363dd229b130ee352523060950fe3d85745e362d24a063dcbec77e933`.
Pre-edit evidence SHA256:
`0ec7ae3d168871404491ff8b57efe130850b94284cdfef21c92390cc5d0d178f`.
Primary's preserved actual base is `/tmp/opencode/craftarmy-k3c-baseline`; writer
did not access that external directory, encounter/retry denied access, or generate
an alternative artifact. No Git/staged base exists.

Read-only Python inverse/hash/difflib inspection **RAN/PASS**: remove precisely the
four complete new pause lines and change only that case's function argument back
to `function()`. Whole-file inverse SHA256 equals the actual pre-edit hash above,
not merely matching case names/tokens. Unified diff contains only those five edits
(SelfTests5added/1removed). **123 definitions and exact order retained**, newline-joined
quoted-name SHA256 `86a5b580d97ee9055ec6a73631f46be3b707b36489c197535b53d358236eea22`.
Direct indented `pause(checkpoint,` call sites134→138, exactly four additions.
This byte inverse also protects the unchanged runner, other cases, assertion details,
fixture sizes and synchronous operations; no regression definitions were added.

### Approved checks RAN / NOT RUN

Inspected complete Python check scripts and both Lua runners before execution.
Implementer ran the read-only stdlib checks:

```text
python3 tools/check_dashboard.py
PASS: 15 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 71 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated

python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
```

Both exit0; no structural baseline failure observed. Two initial inline Python
inspection snippets had an unmatched-parenthesis SyntaxError before any inspection
executed; corrected snippets subsequently PASS, with no file writes by those snippets.
`command -v lua5.1` found no path. `lua5.1 tests/dashboard.lua` and
`lua5.1 tests/run.lua` **NOT RUN**: approved runtime absent; no install/substitute.
K3c123-case Lua execution, native timing/scheduling/interactivity/warning recurrence,
real APIs/DB and native bars/hover/unspent comparison **NOT RUN**. Structural/source
checks are not Lua syntax/execution or target-client evidence. No new diagnostic
result, game/profiling/error-handler action, Git mutation or release.

### Freeze, history and exact resume

Current14 hashes and this document's final hash are recorded in TASKS K3c NEW delivery
(not self-hashed here). Read-only comparison **PASS**: only SelfTests/README differ
among14;12 frozen, including KnowledgeCheck/Commands/all K2 code/schema/TOC/runner/
checker. All four previous review artifacts byte-unchanged:

```text
d4e0ae1703973197bae67a2554740a47a06055cdaf9d18c1c3fa1413dfe1bcef  docs/dashboard/k2-review.diff
3d742fcc86c5c829e9409be179a772fd20cfd554a8c07eae890a5f65b55b59b3  docs/dashboard/k3-review.diff
33fc9137b676f6d17efe04e4fb87e4a4649d406da2ed948f1f7093776d92767e  docs/dashboard/k3a-review.diff
7aadd2399ee73e0753f66596fae01886b8ec2909a1ca7ff76ce2622b140b06e0  docs/dashboard/k3b-review.diff
```

Historical K3b **INCOMPLETE66passed/0failed of123**, case66 combined102.8ms,
wall65297.9ms remains incomplete. Case63 maximum stress passed;57 cases uncompleted,
appended112–123 not executed. Historical K3a **62/111,0FAIL**, combined140.4ms at
case63/wall20823.1ms also remains incomplete. No individual command/phase timing,
warning recurrence/interactivity or timing causality supplied; no BugGrabber or
preceding-case65 attribution and no retroactive full-suite/performance PASS.

**Exact resume — primary:** generate actual preserved K3b→K3c workspace
`docs/dashboard/k3c-review.diff` after writer stop; obtain independent read-only review
of the five source edits/exact inverse/four safe boundaries/123 retention/docs/freeze,
then persist findings before recommending any update. No executable design blocker
remains. After review only, already-on-K3b user quits/backs up, replaces ONLY
SelfTests.lua, keeps KnowledgeCheck/Commands/all K2/DB/SavedVariables/diagnostics,
reloads/outcombat `/ca selftest`123. Report explicit COMPLETE/INCOMPLETE counts,
wall/max/case/unit/label, warning recurrence and interactivity. Cancellation unchanged;
new slow-stop report once, no unchanged rerun/threshold raise/skips/autoresume.
Native bars remain paused until satisfactory safe complete performance evidence.
Implementation is not independent verification, acceptance or release.

## K3c primary comparison and independent review — 2026-11-06

Primary actual preserved K3b→K3c comparison `docs/dashboard/k3c-review.diff`,123lines/
8855bytes/SHA256 `087a460424bb7da1a136288764a4ceca21cac797f0d7aeaf4f8efe01109342a3`.
Exact inverse callback+fourpause removes only authorized edits and recovers original
SelfTests bytes. All123definitions retained. Current14sourcefreeze is in TASKS K3c
NEWdelivery; onlySelfTests/READMEdelta12frozen/all4oldartifacts verified. Initial primary
overbroad last14 evidence parser included artifact rows and failed a read-only assertion;
corrected TASKS-delivery-scoped check PASS, no source discrepancy/change. Primary
both inspected Python checks PASS15dashboardpaths/23docs71links/eightdiaghahes and
separate9diagnosticpaths. These are structural/source checks, not Lua/runtime evidence.

Verifier COMPLETE/static **PASS**, runtime/performance **INCOMPLETE**, no blocker.
Read full diff/affectedfixture/helpers/runner/synchronous command integration/docs.
Exactly callback+four outer pauses; both actual synchronous35path command/capture/
format/Show operations/assertions intact, outside protected calls/temporary overrides.
Synthetic state isolated acrossframes/cancel, no production behavior/latency guarantee.
README correct reviewedSelfTests-onlyupdate/123count/data preservation and future
completion/timing/warning/interactivity evidence. Platform N/A, no releaseapproval.

Reviewed target SelfTests `44a0e7905d760b32729ec98a26651c8c6b424d0dc3bfd718aec514e5133295dd`,
README `15e3e9299437dab0e30c7b7ee1784490b2928f8a3ba4702eedab2fdf2dd793b6`, preappend
evidence `c188d52d4a8d9ac2c4597c6da60c8882600533de8250d8bb91de901ce6a2d921` andartifact
above. Reviewer no writes, shellcheck permission-denied/no retrybypass; successful
execution/hash/inverse results primary/implementer-attributed. Visible reread stable;
primary final digest recheck beforeupdate. Lua5.1absent, suites/client K3c NOT RUN.
Historical66PASS0FAILof123/102.8ms/wall65297.9ms still INCOMPLETE;57cases/new12job
regressions/warning/interactivity unvalidated. No guarantee each atomic command<100ms.
Next quit/backup SelfTests-onlyupdate, keepKnowledgeCheck/Commands/K2/DB/diag, reload/
outcombat123selftest finalsummary plus warning/interactivity. Newslowstop reportonce
no unchanged rerun; native bars remainpaused until satisfactory safefullcompletion.

## K3c user79/123 slow-stop; K3d case80 setup checkpoints READY — 2026-11-06

User supplies finalsummary INCOMPLETE79passed/0failed of123, wall70914.9ms/max123.1ms,
case80 `K2 Core reload archive wrong-scope native values reject untouched and legacy
schema1 stays valid`, unit1 [K2 scope variant].79completedPASS,44uncompleted;80started
but not completed. Case66 nowpasses this run; new112–123regressions still unexecuted.
Case79 in startingboundary is completed, not proof of causality. No explicit warning
recurrence/interactivity/build/installedhash evidence. Don't rerun currentversion.

Source2466–2489: case80 firstpause follows fixture/raw/evaluate, dbOpen/Apply, valid
Open, Archive and archivedOpen.123.1ms measures combinedinitialsetup, no separate
operation timing. K3d44 adds seven safe outer pause sites after completed setup
operations, at incoming scope loop variants and beforelegacy setup. Preserve all123
assertions/operations/native35pathworkloads, real Core functions atomic, no yields
inside protected operations/temporary overrides. No performance guarantee or stubs/
skipped stress/changed100ms/10000suitecap/production accounting/Commands/KnowledgeCheck.

Primary verified current14 K3c sourcehashes and preserved actualpreeditbytes under
/tmp/opencode/craftarmy-k3d-baseline. OnlySelfTests/READMEdelta12frozen/all5priorreview
artifacts frozen. Exact inverse sevenpauses+Open/Archive/Open whitespace split must
recover old SelfTests bytes. One synchronouswriter owns SelfTests/README/evidence/
44taskstate; primary generates actualworkspace k3d-review.diff afterwriterstop and
persists independent review before SelfTests-only userupdate. No Lua/clientPASS yet;
native bars/hover/unspent remainpaused until satisfactory safefullcompletion.

## K3d44 NEW implementation delivery — 2026-11-06

**PARTIAL — piece44 implemented/checked/frozen; independent review and user gates pending.**
One synchronous writer, no children/new files. Changed only SelfTests.lua, dashboard
README, this append and authorized44/current run/new delivery in TASKS. Primary owns
PLAN/Q03/review history and the later actual k3d-review.diff. Platform review N/A;
no installation, game/API/real DB/profiling/error-handler/Git/release actions.

### Exact source diff and byte retention

Only case80 `K2 Core reload archive wrong-scope native values reject untouched and
legacy schema1 stays valid` changes. Seven OUTER pause sites: after raw/evaluate,
after Open(nil)+Apply/assert, after active Open, after Archive/assert, after archived
Open, at each incoming four-key scope variant, and before legacy setup. Existing
callback and `K2 scope variant` pause are untouched. Complete real Core operations
remain atomic/fully exercised, outside protected calls/temporary overrides. No helper,
neighbor case, stub/job, runner or production change; all35-path workloads retained.

Read-only Python reconstructed the baseline by removing exactly the seven new pause
lines and joining only the three Open/Archive/Open statements with their original
spaces/semicolons. The following is the complete source delta against that byte-verified
actual-baseline reconstruction (no review artifact created by writer):

```diff
@@ -2465,8 +2465,15 @@
 end)
 case("K2 Core reload archive wrong-scope native values reject untouched and legacy schema1 stays valid",function(checkpoint)
     local _,_,_,c=k2Fixture(); local raw=k2Raw(c); local r=K.Evaluate(raw)
+    pause(checkpoint,"K3d raw evaluated")
     local db=C.Open(nil); assert(C.Apply(db,character,identity,k2Observations(raw,r,100),100,"fixture"))
-    eq(C.Open(db),db); assert(C.Archive(db,character.guid,2913,110,"fixture")); eq(C.Open(db),db)
+    pause(checkpoint,"K3d applied")
+    eq(C.Open(db),db);
+    pause(checkpoint,"K3d active reopened")
+    assert(C.Archive(db,character.guid,2913,110,"fixture"));
+    pause(checkpoint,"K3d archived")
+    eq(C.Open(db),db)
+    pause(checkpoint,"K3d archive reopened")
     for _,mode in ipairs({"active","archive"}) do
         for _,target in ipairs({"scope","raw","tree"}) do
             pause(checkpoint,"K2 scope variant")
@@ -2480,10 +2487,12 @@
         end
     end
     for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
+        pause(checkpoint,"K3d incoming scope variant")
         local wrong=C.Copy(identity); wrong[key]=999
         local empty=C.Open(nil); local verify=unchangedGraph(empty)
         eq(C.Apply(empty,character,wrong,k2Observations(raw,r,100),100,"fixture"),nil,"incoming scope "..key); verify()
     end
+    pause(checkpoint,"K3d before legacy")
     local old=dbWith({knowledgeRaw=scan(),["tree:11"]=treeValue(11,0,10)})
     eq(C.Open(old),old,"old schema1 no migration or native inference")
 end)
```

BEFORE edits, all14 actual readable workspace hashes matched the authoritative TASKS
K3c NEW delivery14 table (not an overbroad last14 evidence regex). Actual pre-edit
SelfTests222797bytes/SHA256
`44a0e7905d760b32729ec98a26651c8c6b424d0dc3bfd718aec514e5133295dd`.
Exact inverse **RAN/PASS**, recovering that whole-file hash and byte length, not merely
names/tokens. Thus every original assertion/parameter/workload and all other source
bytes, including runner, remain unchanged. **123 definitions/exact order retained**;
Python `re.findall(rb'^case\(("[^"\n]+"),', source, re.M)` lists compare equal before/
after. SHA256 of these quoted names joined with LF and NO final LF:
`32204f9b7be1b75983cdad1d98dd581aaa97aff8190c7fb4a77aa1fb606d2151`.
Direct indented `pause(checkpoint,` sites138→145, exactly seven added; source diff
10added/1removed (seven pauses plus the three-line whitespace split).
No regression definitions added/removed. Primary preserved actual baseline at
`/tmp/opencode/craftarmy-k3d-baseline`; writer did not access it or encounter/retry/
bypass denied access. No Git/staged comparison exists.

### Approved checks RAN / NOT RUN

Inspected both complete Python check scripts and both Lua runners. Implementer RAN:

```text
python3 tools/check_dashboard.py
PASS: 15 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 71 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated

python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
```

Both exit0; no structural baseline failure observed. Read-only inline Python pre-edit
freeze and post-edit inverse/definition/order/seven-site/difflib/full14/five-artifact
checks **RAN/PASS**. `command -v lua5.1` found no path; `lua5.1 tests/dashboard.lua`
and `lua5.1 tests/run.lua` **NOT RUN**, approved runtime absent, no install/substitute.
K3d Lua syntax/execution, native timing/scheduling/warning/interactivity, real APIs/DB
and native bar/hover/unspent comparison **NOT RUN**. Source/structural PASS is not
Lua/client evidence; no mocked result proves target-client behavior.

### Freeze, history and resume

Current14 table and final evidence hash are in TASKS K3d NEW delivery. Only SelfTests/
README differ among14,12 frozen. All five prior artifacts unchanged, SHA256:

```text
d4e0ae1703973197bae67a2554740a47a06055cdaf9d18c1c3fa1413dfe1bcef  docs/dashboard/k2-review.diff
3d742fcc86c5c829e9409be179a772fd20cfd554a8c07eae890a5f65b55b59b3  docs/dashboard/k3-review.diff
33fc9137b676f6d17efe04e4fb87e4a4649d406da2ed948f1f7093776d92767e  docs/dashboard/k3a-review.diff
7aadd2399ee73e0753f66596fae01886b8ec2909a1ca7ff76ce2622b140b06e0  docs/dashboard/k3b-review.diff
087a460424bb7da1a136288764a4ceca21cac797f0d7aeaf4f8efe01109342a3  docs/dashboard/k3c-review.diff
```

This document's pre-edit SHA256
`08852e756c44f17541e8eb865699529dd3bb1252be9cedd5afee98e0df11e2eb`;
history preserved append-only. Latest native K3c history stays **INCOMPLETE79passed/
0failed of123**, case80 unit1 [K2 scope variant]123.1ms/wall70914.9ms,79completePASS,
80started/44uncompleted,112–123notexecuted. No individual setup-phase timings or
explicit warning recurrence/interactivity report; no preceding-case79/BugGrabber
causality or retroactive full123/performance PASS. Earlier66/123102.8ms/wall65297.9ms
and62/111140.4ms/wall20823.1ms retained. Atomic operation latency remains unmeasured,
not guaranteed<100ms; limits100ms/10000suite-steps remain frozen.

README now gates already-on-K3c user on independent K3d review: quit/back up, replace
ONLY SelfTests.lua, keep KnowledgeCheck/Commands/all K2/DB/SavedVariables/diagnostics,
reload/outcombat selftest123. Report final COMPLETE/INCOMPLETE counts/wall/max/case/
unit/label plus warning recurrence/interactivity. Cancellation unchanged; new slow-stop
report once, no unchanged-version rerun/raise/skips/autoresume. Native bars stay paused
pending satisfactory safe full completion/performance evidence.

**Exact resume — primary:** AFTER writer stop, generate actual preserved K3c→K3d
workspace `docs/dashboard/k3d-review.diff`; obtain independent read-only review of
seven outer sites/sole whitespace split/exact inverse/all123retention/docs/full14/
five-artifact freeze and persist findings BEFORE any SelfTests-only user update
recommendation. No executable design blocker remains. Implementation is not
independent verification, client acceptance or release; later atomic slow-stop must
return to planning, not weaken coverage. Maintenance history not relocated/archived.

## K3d primary comparison and independent review — 2026-11-06

Primary actual preserved K3c→K3d `docs/dashboard/k3d-review.diff`,125lines/8053bytes,
SHA256 `5a6dbbaa51a84ecbf51696e463df86b2b4d7ad7226f12a457a1fec679ba689d2`.
Full14targetfreeze matches TASKS NEWdelivery; actual2deltas SelfTests/README12frozen/
fivepriorartifacts unchanged. Sevenpause removal+sole whitespace rejoin recovers exact
baseline bytes; all123orderednames retained. Initial primary regex counted fourspace
indent only and failed read-only assertion; whitespace-aware correction PASS/no source
change. Both primary inspectedPythonchecks PASS15dashboardpaths/23docs71links/eight
diagnostichashes/separate9diagnosticpaths. Structural/source evidence only.

Independent verifier COMPLETE/static **PASS**, runtime/performance **INCOMPLETE**.
No blockers. Fullactualdiff/currentfixture/helpers/Core/runner/contract/docs inspected.
Exactly seven outerpause sites/sole whitespace split; existingcallback/checkpoint/
operations/assertions retained. Only isolatedsyntheticstate acrossframes/cancel, no
yield inside Core/protectedcalls/temporaryoverrides. No new deterministic assertion
failure identified. README correct SelfTests-only/data-preserving update with final
timing/warning/interactivity evidence, no atomiclatencyguarantee. Platform N/A/no release.

Reviewed SelfTests `38bb8ceffe91d0fa2508400dcca3bbdc828d8f14ae674201f50c4b0a86619732`,
README `066f93304e09f4c38a360d5372f28da8430dfac163d966040a01f94dcba8ea7f`, pre-review
evidence `6b03f3236700054017bfffec815f5bbda772fad07346120fde52bf20406eb84d`, artifact
above; noGit/stagedrevision. Reviewer shellvalidation permission-denied/no retrybypass,
no writes; execution/hash/inverse success primary/implementer-attributed. Visible
rereads stable; primary finalfreezecheck before userrecommendation. Lua5.1absent;
Lua/native K3d NOT RUN. Historical79/1230FAIL/123.1ms/wall70914.9ms still INCOMPLETE;
44uncompleted, new12regressions unexecuted, individualtimings/warning/interactivity
unknown. Next quit/backup/updateONLYSelfTests, keepKnowledgeCheck/Commands/K2/DB/diag,
reload/outcombat123selftest finalsummary plus recurrence/interactivity. Newslowstop
reportonce/no unchangedrerun/raise/skips; nativebars remainpaused until safefullcompletion.

## Latest user64/123 grouped command100.5ms; K3e45 READY — 2026-11-06

User finalsummary INCOMPLETE64passed/0failedof123, wall102289.1ms/max100.5ms case64
`K1 command bypasses Login real DB and dashboard even when invalid or runtime missing`
unit1/case return.64completedPASS/59uncompleted, case63completed2599units; starting
boundary63 doesnot establish63caused64unit.80notreached, no newcase80 performance
evidence; prior79/123123.1ms remains historical. New112–123unexecuted. Warningrecurrence/
interactivity/build/installedhash and individual-commandtimings still unknown.

Source1918–1935 case64 groups fixture setup, two full35path commands inside one
trappedCapture pcall/sharedoverride region, then missing-runtime/help checks. K3e45
settles four OUTERcheckpoints and two independent trappedCapture scopes so each real
command retains allforbidden-call/runtimegraph guards and restores C.Apply/K.Evaluate
beforepause. Never yield under protectedcall/activeoverride. Preserve allassertions/
123names/order/workloads/no stubs/jobsubstitution/limitraise/productionchanges. Each
command atomic, no<100ms guarantee; measured100.5ms coverscombinedunit, no causal
claim aboutmachine/BugGrabber/overload or arbitrarylatency tolerance.

Primary verified current14K3dhashes andpreservedactualpreeditbytes
/tmp/opencode/craftarmy-k3e-baseline. One writer SelfTests/README/evidence/45taskstate;
12otherhashedfiles/all6oldartifactsfrozen. Exactinverse ofcallback/fourpauses/oneextra
protectedclosureboundary mustrecoveroldbytes. Primary generatesworkspace k3e-review.diff
afterwriterstop andpersistsindependentreview beforeSelfTests-onlyupdate. Don'trerun
currentversion; fullresponsiveness/warnings/nativebars remainpending.

## K3e45 NEW implementation delivery — 2026-11-06

**PARTIAL — piece45 implemented/checked/frozen; independent review/user gates INCOMPLETE.**
Only SelfTests.lua, dashboard README, this append and45/current run/new delivery in
TASKS changed. One synchronous writer/no children/new files. Primary PLAN/Q03/review
history unchanged; later actual k3e-review.diff is primary-owned AFTER writer stop.
Platform review N/A; no Git/staged base, installs/substitute runtime/game/API/real DB/
profiling/error-handler/Git/release/maintenance archival actions.

### Exact guard boundary and byte-retention proof

ONLY case64 `K1 command bypasses Login real DB and dashboard even when invalid or
runtime missing` gains callback/four OUTER pause sites/two protected command scopes.
The full source delta against actual-byte-verified pre-edit reconstruction is:

```diff
@@ -1918,18 +1918,24 @@
-case("K1 command bypasses Login real DB and dashboard even when invalid or runtime missing",function()
+case("K1 command bypasses Login real DB and dashboard even when invalid or runtime missing",function(checkpoint)
     local env,_,f,c=knowledgeFixture(); local chat={}
     env.DEFAULT_CHAT_FRAME={AddMessage=function(_,line) chat[#chat+1]=line end}
     local commands=NS.Commands.New(env); commands.collector=c
     commands.Login=function() error("knowledgecheck must bypass Login") end
     commands.dashboard={Refresh=function() error("no refresh") end,Toggle=function() error("no dashboard") end}
+    pause(checkpoint,"K3e command setup")
     trappedCapture(env,c,function()
         local report,text,why=commands:Run("knowledgecheck")
         eq(report.captureComplete,true); eq(commands.knowledgeText,text); assert(why:find("frames missing",1,true))
+    end)
+    pause(checkpoint,"K3e valid command complete")
+    trappedCapture(env,c,function()
         f.costs[f.tabs[1].root]=nil
         incomplete(commands:Run("knowledgecheck"))
     end)
+    pause(checkpoint,"K3e invalid command complete")
     local fresh=NS.Commands.New(env); fresh.Login=commands.Login
     local before=unchangedGraph(env.CraftArmyDB)
     incomplete(fresh:Run("knowledgecheck")); before(); eq(fresh.collector,nil); assert(#chat<=6,"brief messages only")
+    pause(checkpoint,"K3e missing runtime complete")
     local e=fixtureAPI(); local help={}; e.DEFAULT_CHAT_FRAME={AddMessage=function(_,line) help[#help+1]=line end}
     NS.Commands.New(e):Run("help"); assert(table.concat(help):find("/ca knowledgecheck",1,true))
 end)
```

First helper closes AFTER valid report/text/why assertions; second surrounds original
cost mutation+invalid command/assertions. Each real synchronous35-path commands:Run
remains fully atomic, unchanged. Existing trappedCapture helper is byte-unchanged:
each call installs forbidden methods, creates its OWN full unchangedGraph(runtime)
verifier, executes fn()+verify() under pcall, restores C.Apply/K.Evaluate, then asserts
success BEFORE return. Both outer command-complete pauses are AFTER helper return,
never under shared overrides/pcall. Helper resets synthetic forbidden-function identities
per call as allowed; no verifier survives across that reset. Setup and missing-runtime
pauses likewise lie outside helper/protected regions. Original Login/DB/dashboard/
immutable-runtime/nilcollector/chat/help assertions and statement order remain intact.
No new stubs/job substitution/reduced stress/helper/neighbor/runner/global/production
changes. All numeric parameters and35-path command workloads retained.

BEFORE edits, all14 actual workspace hashes matched authoritative TASKS K3d NEW
delivery14 table, not overbroad last14 evidence rows. Actual pre-edit SelfTests
223106bytes/SHA256 `38bb8ceffe91d0fa2508400dcca3bbdc828d8f14ae674201f50c4b0a86619732`.
Read-only inline Python removed precisely four new pause lines, callback parameter
and ONLY inserted end)/second trappedCapture boundary. Recovered whole-file length/
SHA256 match **PASS**: all other code bytes/assertions/parameters preserved, not merely
names/tokens. Source delta7added/1removed. Direct indented pause sites145→149, exactly
four additions; two protected scopes/two real commands checked PASS.
`re.findall(rb'^case\(("[^"\n]+"),',source,re.M)` before/after gives equal123 ordered
names; SHA256 of quoted names joined with LF/NO final LF:
`32204f9b7be1b75983cdad1d98dd581aaa97aff8190c7fb4a77aa1fb606d2151`.
No added/removed definitions. External baseline was NOT accessed, no denied read/retry/
bypass; primary preserved /tmp/opencode/craftarmy-k3e-baseline. Writer created no artifact.

### Checks RAN / NOT RUN

Inspected full tools/check_dashboard.py, tools/check_diagnostics.py and both Lua
runners before checks. Implementer RAN:

```text
python3 tools/check_dashboard.py
PASS: 15 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 71 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated

python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
```

Both exit0, no structural baseline failures. Read-only inline Python pre-edit14freeze
and post-edit exact inverse/difflib/123orderednames/four-sites/two-scopes/full14/six-old-
artifact checks **RAN/PASS**. `command -v lua5.1` found no path. `lua5.1 tests/dashboard.lua`
and `lua5.1 tests/run.lua` **NOT RUN**: approved runtime absent, no install/substitute.
Lua syntax/execution/native K3e scheduling/timing/warning/interactivity/API/DB/native
bars NOT RUN; source/structural PASS is not Lua execution or target-client API evidence.
No fresh diagnostic/client result.

### Freeze, latest user evidence and exact resume

Current14 freeze is recorded in TASKS K3e NEW delivery; ONLY SelfTests/README differ
vs K3d,12 frozen. Current source digests:
SelfTests `79db1d7e0fd420794b968e3a2aaebad60c9c777be0499decbd1e81134c76185c`;
README `1c77ec450deec15bd1bdde0c558d278878c13b790467a1034a4db80df2a49714`.
Pre-edit evidence272917bytes/SHA256
`e230c978cadc8ed0b1c201ec77534c69bf9e747d566192c7f59b5417ef6e38d0`
retained as exact prefix (append-only); final evidence hash belongs in TASKS, not a
self-referential digest here. All6 prior artifacts byte-unchanged, SHA256:

```text
d4e0ae1703973197bae67a2554740a47a06055cdaf9d18c1c3fa1413dfe1bcef  docs/dashboard/k2-review.diff
3d742fcc86c5c829e9409be179a772fd20cfd554a8c07eae890a5f65b55b59b3  docs/dashboard/k3-review.diff
33fc9137b676f6d17efe04e4fb87e4a4649d406da2ed948f1f7093776d92767e  docs/dashboard/k3a-review.diff
7aadd2399ee73e0753f66596fae01886b8ec2909a1ca7ff76ce2622b140b06e0  docs/dashboard/k3b-review.diff
087a460424bb7da1a136288764a4ceca21cac797f0d7aeaf4f8efe01109342a3  docs/dashboard/k3c-review.diff
5a6dbbaa51a84ecbf51696e463df86b2b4d7ad7226f12a457a1fec679ba689d2  docs/dashboard/k3d-review.diff
```

Latest user history remains **INCOMPLETE64passed/0failed of123**, case64 unit1/case
return100.5ms/wall102289.1ms.64completedPASS/59uncompleted;63completed2599units, its
start boundary does not establish causality. Case80 NOT REACHED this run, no new80
validation; prior79/123123.1ms/wall70914.9ms is separate historical evidence. New
112–123 unexecuted. Individual command timings/warning recurrence/interactivity unknown.
No preceding-case/BugGrabber/machine causality, performance PASS or full123PASS inferred.
Each actual command atomic/unmeasured, NOT guaranteed<100ms; Commands/KnowledgeCheck/
Core/K2/runner/limits100ms/10000suite-step cap frozen.

README current K3e gate AFTER independent review: already-on-K3d user fully quits,
backs up WTF/SavedVariables, replaces ONLY CraftArmy/SelfTests.lua; preserves
KnowledgeCheck/Commands/K2/DB/all SavedVariables/diagnostics, reloads/outcombat selftest123.
Report final COMPLETE/INCOMPLETE counts/wall/max/case/unit/label, warning recurrence
and interactivity. Cancellation unchanged; newslowstop reportonce/no unchangedrerun/
raise/skips/autoresume. Native bars remain paused pending satisfactory safe complete
fixture/performance evidence. Any later atomic slow-stop returns planning, not reduced
integration coverage.

**Exact resume — primary:** AFTER writer stop generate actual preserved K3d→K3e
workspace docs/dashboard/k3e-review.diff, obtain independent read-only review of
four OUTER sites/two protected scopes/unchanged helper/whole-byte inverse/123ordered
cases/README/full14/six-artifact freeze and persist findings BEFORE any SelfTests-only
update recommendation. No remaining executable writer work/design blocker. Independent
verification, user acceptance and release remain separate; no release approval.

## K3e primary comparison and independent review — 2026-11-06

Primary actual preserved K3d→K3e `docs/dashboard/k3e-review.diff`,130lines/8832bytes,
SHA256 `d2d64a4daa2c6420bc2b78502d09dd5b8bc88fe8b66d514f8943c69089765a56`.
Current14 targethashes matchTASKS NEWdelivery; actual2deltasSelfTests/README12frozen/
sixoldartifactsunchanged. Exactinversecallback/fourpauses/sole extra guardclosure
boundary recovers actualoldbytes;123orderednames retained. Both primary inspected
Pythonchecks PASS15dashboardpaths/23docs71links/eightdiaghahes/separate9diagpaths.

Verifier COMPLETE/static **PASS**, performance **INCOMPLETE**, no blockingfinding.
Read fullactualdiff/currentfixture/helper/runner/commandpaths/docs/contract. Eachreal
35pathcommand retains forbidden-call traps/fullruntimegraphverification independently;
unchangedhelper restores C.Apply/K.Evaluate beforepause, no yield throughpcall or
suspendedsharedoverride. Syntheticforbiddenfunctionreset betweenhelpercalls permitted,
no retained verifier crossingreset. Fourouterpauses/123cases/assertions/order retained,
no deterministicfailure identified. Actualcommand remainsatomic/timingunknown.

Reviewed SelfTests `79db1d7e0fd420794b968e3a2aaebad60c9c777be0499decbd1e81134c76185c`,
README `1c77ec450deec15bd1bdde0c558d278878c13b790467a1034a4db80df2a49714`, pre-review
evidence `20558d159071dbae5836252baa24a3a09718574a4d3474cf994ae3c6d9a97bba`, artifact
above. NoGit/stagedbase; reviewer shellvalidation denied/no execution/retrybypass/edits;
hash/inverse/Python success primary/implementer-attributed. Finalvisible rereads stable;
primary finalfreezecheck beforeupdate. Lua5.1absent, Lua/native K3e NOT RUN. Latest
64/1230FAIL100.5ms/wall102289.1ms remainsINCOMPLETE;59uncompleted/80notreached/new12
regressionsunexecuted. Prior79/123separate, warnings/interactivityunknown. Platform N/A/
no releaseapproval. Next quitbackupSelfTests-onlyupdate keepKnowledgeCheck/Commands/K2/
DB/SavedVariables/diag,reloadoutcombat123summary+warnings/interactivity. Newslowstop
reportonce/no unchangedrerun/raise/skips; nativebars paused until safefullcompletion.

## Latest81/123 grouped scan/reload385.3ms; K3f46 READY — 2026-11-06

User summary INCOMPLETE81passed/0failedof123, case81unit1/case return385.3ms,
wall73206.2ms.81completedPASS/42uncompleted;80passes thisrun,112–123stillunexecuted.
Startingboundary80doesn'timplicate80 in81unit. Warningrecurrence/interactivity/build/
installedhash and individualoperationtimings unknown.385.3ms combinedunit, no separate
Scan/Core/ViewModel timing or runtime/BugGrabbercausality inferred. No currentrerun.

Case81 source2505–2521 groups two realScans/Copy/reloads/Archive/severalViewModels+
tooltip assertions withoutcallback. Adjacent82 repeats combinedtwo-Scan/copy/ViewModel
work per failurevariant. K3f46settles17OUTERpause sites (81ten/82seven) betweencomplete
operations; no changes to actualScan/Core/ViewModel/functions,123assertions/modes/
35pathworkloads. Atomicops stillunmeasured; futureatomicstoprequiresplanning not
stubs/reducedstress/thresholdraise. Fullproduction/100ms/10000cap frozen.

Primaryverifiedcurrent14K3ehashes, preservedactualpreeditbytes
/tmp/opencode/craftarmy-k3f-baseline. Writer onlySelfTests/README/evidence/46taskstate;
12otherhashedfiles/all7oldartifactsfrozen. Exactinverse17pauses/case81callback/sole
specifiedsemicolonwhitespace splits mustrecoveroldbytes. Primary generatesactual
workspacek3f-review.diff afterwriterstop; independentreviewbeforeSelfTests-onlyupdate.
No Lua/clientK3fPASS ornativebarsacceptance; fullsafecompletion stillpending.

## K3f46 NEW implementation delivery — 2026-11-06

**PARTIAL** —46 implemented/checked/frozen; independent review and user performance
gate **INCOMPLETE**. No executable writer remainder or design blocker. One synchronous
writer/no children/new files. Edited only SelfTests cases81–82, dashboard README,
this append and46/current run state/NEW delivery in TASKS. Primary PLAN/Q03/review
history and future k3f-review.diff untouched. Platform N/A; no Git/staged base,
installation/substitute runtime/game/API/real DB/profiling/error-handler/release or
maintenance/archive operation. Source/structural checks are not Lua/client evidence.

### Exact safe boundaries

Case81 retains its exact name, gains `function(checkpoint)` and TEN outer pauses:

1. `K3f scan fixture ready` — after complete fixture, before first real Scan.
2. `K3f first scan verified` — after Scan, g reference and zero/time/unspent/reason assertions.
3. `K3f fresh view verified` — after complete fresh ViewModel and hover assertions.
4. `K3f database copied` — after complete C.Copy, before C.Open.
5. `K3f database reopened` — after complete C.Open/assertion.
6. `K3f historical view verified` — after historical ViewModel/assertions.
7. `K3f database archived` — after complete Archive/assertion, before Open.
8. `K3f archive reopened` — after complete archived Open/assertion.
9. `K3f archive hidden verified` — after hidden archived ViewModel/count assertion.
10. `K3f archived view verified` — after archived ViewModel/state/time assertions.

Final `s.at=120`, second full Scan and old g observation assertion remain atomic
through return. The g reference and isolated reopened copy semantics are unchanged.

Case82 retains its callback and `K2 stale variant` checkpoint, plus SEVEN outer sites:

1. `K3f stale fixture ready` — per-variant fixture complete, before first Scan.
2. `K3f stale baseline scanned` — first Scan/local old complete, before Copy.
3. `K3f stale baseline copied` — Copy and s.at=120 complete, before failure injection.
4. `K3f failure injected` — full conditional injection complete, before second Scan.
5. `K3f stale scan verified` — second Scan/g and ALL four-tree/coherent/freshness/index
   assertions complete, before ViewModel. Original ViewModel/tooltip/reason assertions
   run until the next existing variant pause (or final standalone fixture boundary).
6. `K3f unknown fixture ready` — final standalone fixture and currency999 mutation,
   before its Scan.
7. `K3f unknown scan complete` — final full Scan, before final ViewModel/unknown assertions.

Every actual Scan/Copy/Open/Archive/ViewModel remains complete and atomic. No yield
inside injected functions, pcall or temporary shared override. No helper/other-case/
runner/production changes, job/stub substitution, reduced sizes/parameters/topology,
changed order/assertions/modes or skipped coverage. Individual atomic latency remains
unknown; no <100ms guarantee. Future atomic slow-stop returns to primary planning,
not threshold raising, stress reduction or weakened integration.100ms/10000cap frozen.

### Byte proof and frozen scope

BEFORE edits all14 current workspace hashes matched authoritative TASKS K3e NEW
delivery. Actual pre-edit SelfTests223360bytes, SHA256
`79db1d7e0fd420794b968e3a2aaebad60c9c777be0499decbd1e81134c76185c`.
Read-only inline Python inverse removes exactly17 `K3f` pause lines, restores only
case81's empty callback and rejoins exactly FIVE split semicolon boundaries:
case81 fixture/first Scan, Copy/Open, Archive/Open; case82 per-variant fixture/first
Scan and standalone currency mutation/Scan. Reconstructed whole-file bytes recover
that actual length/hash **PASS**. No other source bytes changed. Source delta28added/
6removed lines, direct indented pause sites149→166. **123 exact ordered quoted names**
match inverse, LF joined/no final LF SHA256
`32204f9b7be1b75983cdad1d98dd581aaa97aff8190c7fb4a77aa1fb606d2151`.
No new/removed regressions; original assertions/full35-path workloads retained.
Current SelfTests224236bytes/SHA256
`e3c3e0755ad2200ccf83df8505d092148f86e6cce28b4c20a0c71da18dbb7ccf`;
README40413bytes/SHA256
`2fb479cf06ddbb79f0680b3932d515421624c4427ecf19c4b3e08cd47dfee43d`.
Full14 current hashes and all7 old artifact digests are in TASKS K3f NEW delivery;
ONLY SelfTests/README delta,12 frozen/all7 artifacts unchanged **PASS**.
No external baseline access attempted/denied/retried/bypassed; primary preserved
`/tmp/opencode/craftarmy-k3f-baseline` and generates actual comparison AFTER writer stop.
This evidence append retains the complete pre-edit285289byte prefix/SHA256
`c71c6cb1f875a53caef0a94415f191fbcc96571e9e7cc18e7346f000ebd42a89`.
Final evidence digest is recorded in TASKS, not recursively embedded here.

### Validation and next gate

Inspected both full Python check scripts and both Lua runners before commands.
RAN `python3 tools/check_dashboard.py`: **PASS exit0**,15required files/exact9Lua,
23Markdown/71links/eight diagnostic hashes unchanged.
RAN `python3 tools/check_diagnostics.py`: **PASS exit0**,9required files/exact4Lua.
No structural baseline failure observed. Initial `python3 - <<'PY'` inverse/freeze
attempt failed with unmatched-parenthesis SyntaxError before execution; corrected
read-only inline Python RAN/PASS exact inverse/17sites/123names/full14/seven-artifact
checks. `command -v lua5.1` returned no path; `lua5.1 tests/dashboard.lua` and
`lua5.1 tests/run.lua` **NOT RUN**, runtime absent/no install/substitute.
Lua syntax/execution/native K3f timing/scheduling/warnings/interactivity/API/DB/bar
checks **NOT RUN**. No fresh diagnostic/client result or performance PASS claimed.

Latest user result remains **INCOMPLETE81passed/0failed of123**, case81unit1/case
return385.3ms/wall73206.2ms:81completePASS/42uncompleted,80nowPASS; new112–123unexecuted.
No individual Scan/Core/ViewModel timings or explicit warning/interactivity report.
Combined timing does not attribute causality to case80/runtime/BugGrabber/machine.
README now gates already-on-K3e quit/backup/replaceONLYSelfTests after independent
K3f review; keep KnowledgeCheck/Commands/K2/DB/SavedVariables/diagnostics unchanged,
reload/outcombat123selftest and report final COMPLETE/INCOMPLETE counts/wall/max/
case/unit/label plus warning recurrence/interactivity. Cancellation unchanged; new
slow-stop reportonce/no unchangedrerun/thresholdraise/skips/autoresume. Native bars
remain paused pending satisfactory safe full completion/performance.

**Exact resume — primary:** AFTER writer stop generate actual preserved K3e→K3f
workspace `docs/dashboard/k3f-review.diff`; independently review17outer boundaries/
callback/FIVE whitespace splits/whole-byte inverse/123orderedcases/full14/seven-old-
artifact freeze/README and persist findings BEFORE any SelfTests-only update.
Implementation is not independent verification, acceptance or release.

## K3f primary comparison and independent review — 2026-11-06

Primary actual K3e→K3f `docs/dashboard/k3f-review.diff`,177lines/11844bytes,
SHA256 `14bdb9d3a91a0c86f0a5f0fae69c91a10367ad89083f62c4e824b3a6f3664e2f`.
Exactbyteinverse17pauses/case81callback/fivelinejoins recovers actualbaseline;123ordered
names/full14/exact2deltas12frozen PASS. Both primaryPythonchecks PASS15paths/23docs/
71links/eightdiaghahes/separate9paths. Source/structure only, notLua/runtimeevidence.

Verifier COMPLETE/static **PASS**, performance **INCOMPLETE**, no blockers. Readfull
actualdiff/currentcases/helpers/runner/relevant Core/collector/ViewModel/contract/docs.
Tenouterpauses81/seven82/callback/fivesplits match46; references/copies/time/freshness/
modes/assertions retain semantics. All actualoperations atomic, no suspendedshared
override/injectedfunctionyield/cancellationhazard identified. README correct reviewed
SelfTests-onlyupdate/data preservation/performancegate; no latencyguarantee.

Reviewed SelfTests `e3c3e0755ad2200ccf83df8505d092148f86e6cce28b4c20a0c71da18dbb7ccf`,
README `2fb479cf06ddbb79f0680b3932d515421624c4427ecf19c4b3e08cd47dfee43d`, pre-review
evidence `dc6292ffde5f54a3e30c328746199e32f22eba46bbc65f258a133de4cb413d5c`, artifact
above. NoGit/stagedbase; reviewer shellvalidation deniedbeforeexec/no retrybypass/edits/
independenthashes; successprimary/implementer-attributed. Visiblefinalrereads stable;
primaryfinalfreeze beforeupdate. Lua5.1absent/Lua/native K3f NOT RUN, platform N/A/
no releaseapproval. Latest81/1230FAIL385.3ms/wall73206.2ms stillINCOMPLETE;42uncompleted/
new12regressionsunexecuted, individualtimings/warnings/interactivityunknown. Next
quitbackupSelfTests-onlyupdate keepallothermodules/DB/SavedVariables/diag,reloadoutcombat
123summary+warnings/interactivity. Newslowstopreportonce/no unchangedrerun/raise/skips;
nativebars paused until satisfactory safefullcompletion.

## K3f latest81/123 finalscan boundary122.4ms; broader planning gate — 2026-11-06

User finalsummary INCOMPLETE81passed/0failedof123, wall67041.5ms/max122.4ms atcase81
unit11/case return. Fromunit10 [K3f archived view verified] isolates finalSelfTests2533
s.at=120; assert(c:Scan()); eq(oldg.observedAt,100). All81assertion outcomesPASS;
42uncompleted/new112–123unexecuted. Earlier385.3ms groupedrun separate, not cumulative
or directly comparable. FirstScan andearlieroperations didn't trigger100ms thisrun;
internalfinalScan phase timings unmeasured.122.4ms includes assignment+assertions, not
an independently measured pureScan duration. No build/installedhash/warningrecurrence/
interactivity supplied. No currentversionrerun/nativebars/fullperformanceacceptance.

Read-only inspection Collectors365–484: synchronousScan validatesDB(Core.Open), collects
gear/currencies/nativeknowledge, checks context, evaluates/copies evidence and calls
Core.Apply. Core455–557 validates/copies DB/payloads/candidate, constructs alias-safe
assembledbudget preflight then commits once. Multiplevalidation/copy passes are a
candidateinvestigation area, NOT establisheddominantcost or redundant/removableguards.
Cannot divide this internalwork with morecallerpauses, reducefixture, skipsecondScan,
substitute mocks/jobs orraise100ms. No yielding underprotectedoperations/activeoverrides.

Primary requests broader scan-performance investigation/fix approval, measuredstages
first and design before any collector/Core optimization or resumablearchitecture.
Snapshot atomicity/allvalidation/aliasbudgets/stability/privacy/stale semantics must
remain. Existing productionfreeze stillapplies, no newsourcechanges/READYqueue/writer.
Await userdecision then fullysettledcontract; don't infer architectureauthorization
from proposal. No causality assigned toBugGrabber/GC/machine; actualclientfullsuite/
responsiveness/warnings remainunverified. Current reviewed46source/artifacts preserved.

## K4 approved performance investigation; fixture timing47 READY — 2026-11-06

UserYes tobroaderinvestigation/fix, startingmeasurements. Primarysettles fixture-only
temporaryfixedstage wrappers foractualcase81secondScan: CoreOpen/Apply/Copy,Knowledge
Evaluate, thisfixturecollectorKnowledge/Gear/Context; nestedinclusive/exclusive totals
plusrootresidual/callcounts. Alloriginalfunctions/workloadsstillrun, wrappersrestored
beforeanyyield/annotation evenonfailure. No nativeprofilercounterreset/CVar/errorhandler/
realDB/API/productionfile changes. Protectedfinite/monotonicclock absence/error marks
metricsunavailable withoutskippingScan; no fakefixturetime usedasnativeperformance.

NewRunnernon-yielding terminalannotation exposes compactfixedstage label through
existing unchangedCommands slowstopsummary; no extraSteps/123casecoverage loss.
Instrumentationhasoverhead; nativeunitvsinnerScan timings notidentical andno pure
productionlatency guarantee. ActualtimingNOTRUN, localapprovedlua5.1absent. Append
smallfakeclockregressions do notsubstitute actualnative35pathcase81Scan.

Primarymatched14K3fhashes/preservedactualpreeditbytes /tmp/opencode/craftarmy-k4-baseline.
Onewriter47SelfTests/README/evidence/taskstate;12otherhashedfiles/all8oldreviewartifacts
frozen. Primaryactualworkspacek4-review.diff afterstop/independentreview beforeuser
SelfTests-onlymeasurementrun.48optimizationBLOCKED onrealstageevidence/design, scope
approvalnowgivenbutnobodychoosesproductionarchitecture fromassumption. Allvalidation/
aliasbudgets/atomiccommit/staleness/stability/100ms/10000caps retained. Currenthistory
81/123122.4ms/wall67041.5ms stillincomplete42/new12unexecuted; nativebars paused.

## K4 piece47 NEW measurement delivery — 2026-11-06

**PARTIAL — measurement implemented; independent review and user stage evidence
INCOMPLETE.** This is not a production optimization or performance PASS. Piece48
remains **BLOCKED** on reviewed actual stage timings and primary-settled design.
One synchronous writer/no children. Changed only SelfTests.lua, dashboard README,
this append and authorized47/current run/new delivery in TASKS. All production,
Commands, schema/TOC/checkers/diagnostics and eight old review artifacts are frozen.
No new repository/addon files, substitute runtime/install, real DB/game/API action,
profiling setting/reset/error-handler changes, Git operation or release. Platform N/A.

### Exact measurement and exception semantics

- `Tests.MeasureScan(collector,clock)` invokes ONE original synchronous fixture Scan
  and returns its first two results unchanged plus a fresh fixed-key scalar report.
  The only original case changed is81's final second Scan plumbing: first Scan,
  full35 paths, all earlier pauses/assertions/order and the original `g` reference
  remain. Final `assert(success,why)` preserves the original success/reason assertion;
  old-generation observation must still be100. No new full35-path scans are added.
- Seven temporary bindings: Core.Open(O), Apply(A), Copy(C), Knowledge.Evaluate(E),
  this fixture's Knowledge(K), Gear(G), Context(B). Each original receives unchanged
  arguments and runs fully; packed result counts plus bounded `unpack(...,1,n)` retain
  interior/trailing nil positions. Bindings restore by reverse-order raw assignment
  on success, false, clock failure and unexpected errors, before note/output/yield.
  No wrapper/measurement checkpoint, print, annotation or timer is introduced.
- One protected initial clock probe precedes installation. A second root probe
  brackets the actual Scan after installation; a failure there restores before Scan.
  Initially unusable clocks run the original unwrapped. Mid-Scan failure disables
  observation/probes while all original operations continue. Protected supplied
  millisecond reads use unchanged Core.Finite and monotonic checks; at most10000
  probes and64 active timing frames **including the root**. No profiler reset or
  global clock/math override. Case81 resolves only real `_G.debugprofilestop`, else
  `_G.GetTimePreciseSec` converted to ms, only when the final step is reached.
- Stage inclusive=exit-entry; exclusive=inclusive-sum(direct child inclusive).
  Each complete child contributes once to its active parent. Root T=exit-entry,
  R=T-sum(top-level child inclusive); all seven exclusive totals+R must match T
  within1e-6. Every duration/aggregate is finite and nonnegative (no negative clamp).
  Thus nested Open/Copy within Apply are not double-counted. Per-stage calls and
  inclusive/exclusive totals aggregate repeated calls. Installation/cleanup and
  final assertions/formatting/runner overhead are outside T; probe/validation gaps
  within the Scan interval remain included. These are NOT pure production latencies.
- Missing/error/nonfinite/backward clock, probe/depth cap or invalid arithmetic/
  partition returns ONLY `{status="unavailable",reason=<fixed vocabulary>}`, no
  partial numeric-success fields or fabricated unknown zeros. Timing invalidity
  never rejects an otherwise valid Scan. Unexpected original Scan/wrapper errors
  instead restore first then raise exactly `timed scan failed (payload omitted)`.
  This intentional exception sanitization also applies to unwrapped bad-clock runs;
  ordinary returned success/false/reason are unchanged. No raw error/input/API data
  or collector/DB/env/clock references are in reports or persisted globals/snapshots.
- `FormatScanTiming` emits fixed O/A/C/K/E/G/B exclusive totals and T/R, one decimal,
  `>99999` for larger finite values, or fixed unavailable reason. Max numeric-note
  length103 ASCII bytes (required<=112), terminal label116 (required<=128); observed
  zero-resolution readings are not proof of zero stage cost. Unknown/malformed
  report reasons never enter text. No raw markup/control chars/IDs/labels are emitted.
- NewRunner calls `fn(checkpoint,annotate)`: annotate is non-yielding, cleans/bounds
 128 bytes, retains only the last note and checks the same Apply/Evaluate identities
  as checkpoint. It clears private note state on case start/stop/return. Annotated
  terminal label=`case return; <note>` bounded128 and existing PASS/FAIL line gains
  the note. Unannotated outputs, case counts and Step/yield counts are unchanged.
  Frozen Commands already carries this label through >100ms final slow-stop/max
  identity even when a passing line is suppressed; no scheduler/threshold change.

### Regressions and actual-old-source correspondence (NOT Lua execution)

**134 definitions = all123 retained +11 appended small instrumentation cases.** New
stubs exist ONLY in these additions, never in the original Scan workload. Coverage:
nested deterministic calls/inclusive/exclusive/partition; actual argument identities
and five returns including nils; success/false/original/stage/private errors and all
binding restoration; missing/throwing/NaN/infinity/type/backward/start/mid/end clock
failure with original continuation; observed zero clock resolution and finite-clock
elapsed overflow; exactly10000 probes with all5001 original tiny calls completed;
63 recursive stage frames+root allowed/70 original calls finish after depth cap;
independent repeated scalar reports, privacy/formatter bounds; last clean annotation,
normal/fail/reset/cancel/unannotated outputs, identity guards and restored-before-note;
unchanged injected Commands normal/fail/slow/slow-fail final identity/counts/one Step/
no extra callback, including suppressed slow PASS. No duplicate native35-path Scan.

BEFORE editing, read-only Python matched all14 actual workspace files to TASKS K3f
NEW delivery. Actual workspace bytes were retained at
`/tmp/opencode/craftarmy-k4-writer-preedit`; primary's separate preserved base remains
`/tmp/opencode/craftarmy-k4-baseline`. No denied directory read/retry/bypass or writer
review.diff generation. Actual pre-edit SelfTests224236 bytes/SHA256
`e3c3e0755ad2200ccf83df8505d092148f86e6cce28b4c20a0c71da18dbb7ccf`.

Read-only inline Python whole-byte inverse/token/difflib checks **RAN/PASS**:

1. Remove new helper block between `-- K4: fixture-only` and original native-runner
   comment; remove new fixture block between `-- K4 additions:` and `Tests.Run`.
2. In runner, remove only `note` local/resets, second callback/identity guard,
   annotated label/line append; restore original `case return` label. Revert only
   case81's second formal argument and replace its final `s.at=120` through annotation
   with the actual old `s.at=120; assert(c:Scan()); eq(g.fields["tree:1122"].last.observedAt,100,"old returned generation not mutated")`.
3. The resulting ENTIRE source equals the retained actual pre-edit bytes, not a
   newly generated expectation. All122 other old case bodies are separately
   byte-identical; case81's complete body corresponds through that exact inverse.
   This protects all original assertions/parameters/modes/stress values/order and
   real operations, not just names or new-vs-new parity.
4. Using the existing quoted-string/identifier/number/punctuation tokenizer excluding
   comments/whitespace/semicolons: **56997 original full-file tokens**, LF-joined/no
   final LF SHA256 `d31642146db0796d67e5e9d8f3eaaf3053f98b9a6371855344781fa37e5f180a`.
   Exact123 ordered quoted-name SHA256
   `32204f9b7be1b75983cdad1d98dd581aaa97aff8190c7fb4a77aa1fb606d2151`.

Full14 freeze is in TASKS K4 NEW delivery. ONLY SelfTests/README delta,12 frozen;
all8 old artifacts byte-identical, including k3f-review.diff
`14bdb9d3a91a0c86f0a5f0fae69c91a10367ad89083f62c4e824b3a6f3664e2f`.
This append retains the complete pre-edit297797-byte evidence prefix/SHA256
`7a5982a259a08413e1f30a7b95d35bcb4d5791b86c839adcd2667d1bd2fd03d9`.
Final evidence digest is in TASKS, not recursively self-hashed here.

### Validation, blockers and exact resume

Inspected BOTH full Python scripts and both Lua runners before execution. RAN
`python3 tools/check_dashboard.py`: **PASS exit0**,15 required paths/exact9 Lua,
23 Markdown/71 links/eight diagnostic hashes unchanged. RAN
`python3 tools/check_diagnostics.py`: **PASS exit0**,9 required paths/exact4 Lua.
No structural baseline failure. Read-only inline Python pre-edit/freeze/inverse/
tokens/ordered123/actual134/formatter bound checks RAN/PASS. These are source checks,
NOT a Lua parser/runtime or successful execution of the11 regression definitions.
`command -v lua5.1`: no path/exit1. `lua5.1 tests/dashboard.lua` and
`lua5.1 tests/run.lua` **NOT RUN** (approved runtime absent; no install/substitute).
Lua syntax/execution and native K4 timing/scheduling/warnings/interactivity/API/DB/
bars **NOT RUN**. No fresh diagnostic result. Latest supplied history remains
**INCOMPLETE81PASS0FAILof123**, case81unit11 finalscan/assert122.4ms/wall67041.5ms,
42uncompleted/new112–123unexecuted; warning recurrence/interactivity unknown. No
dominant stage, BugGrabber/GC/machine causality or production fix inferred.

**Exact resume — primary:** AFTER writer stop generate actual preserved K3f→K4
`docs/dashboard/k4-review.diff`; obtain independent read-only review of seven fixed
wrappers/math/caps/cleanup/privacy/exception semantics, runner note/unchanged Commands
summary, case81/full123 correspondence,11 additions/134 total, README and14/eight-
artifact freeze. Persist findings BEFORE any user update. Then reviewed user-only
quit/backup/SelfTests-only update (already on K3f), keep all other modules/DB/
SavedVariables/diagnostics, reload/outcombat selftest134; share case81 measurement
PASS line or final INCOMPLETE scan2-tagged identity, final summary/warnings/interactivity.
Stopping before81 final step means NOT MEASURED. Share new stops once, no unchanged
retry/threshold raise/skips/autoresume. Native bars remain paused. Piece48 stays
BLOCKED until reviewed user evidence and primary-settled executable production design.
Implementation is not independent verification, acceptance or release.

## K4 primary comparison and independent review — 2026-11-06

Actual preserved K3f→K4 `docs/dashboard/k4-review.diff`,586lines/33406bytes/SHA256
`756a863e0733ed28723db47035841569ea6e89ea725a5e1e1207b8d3c17b3f67` primarygenerated
afterwriterstop. Primaryfull14/exact2deltas12frozen/eightoldartifacts/evidencedigest/
wholebyteinverse/123oldorderednames+11new=134 PASS. Fulloldsource recovered afteronly
helper/addition/runnernote/final81plumbinginverse, not names-only/newcallerparity.
BothprimaryPythonchecks PASS15paths/23docs71links/eightdiagnostichashes/separate9paths.

Verifier COMPLETE/static **PASS — measurement only**, runtime/performance **INCOMPLETE**,
no blockers. Readfullactualdiff/currentcode/contract/docs/relevantproductionpaths;
manuallychecked deterministicnestedmath/Lua5.1nilreturns/cleanup/clockcaps/notes and
unchangedCommands slowstop. Allsevenwrappers preserveoriginalcalls/results; reverse
cleanup/sanitizederrors/postcleanupannotation ascontract. BothactualScans/full35paths/
123oldassertions retained,134definitions withsmallinstrumentationregressions. Production
unchanged; actualtimingsNOTRUN, deliverymeasurementNOTlatencyfix.48BLOCKED stageevidence/
settleddesign, broaderapproval doesn'tchooseoptimizer.

Reviewed SelfTests `27a1f0ca2697a1154a0036a22dbe9d01ad40465eb137b0a8eaca9fe59dbdc09f`,
README `d3080e75386787d5c75fbb54dce1ae0185700b0b42105cc7249e6ccd51c6fdcd`, pre-review
evidence `e48e0fcaa87b8e79ce53a39c58017157ae394db98503c40ccfe5f744efdde77d`, artifact
above. NoGit/stagedbase; reviewer shell/hashattempt denied/no retrybypass/edits,
executable/hashsuccess primary-attributed. Independentfinaldigestunavailable; primary
rechecksbeforeupdate. Lua5.1absent/Lua/nativeK4 NOTRUN, platformN/A/no releaseapproval.
Latest81/123122.4ms incomplete, stage/warning/interactivityunknown. Nextquitbackup
SelfTests-only134run, sharecase81measurementPASSorfinalscan2identity+summary/warnings/
interactivity. Before81finalstep meansNOTMEASURED; no unchangedreruns/raise/skips.
Nativebars paused;48awaits reviewedtimings andsettledproductioncontract.

## User-installed local runtime checked — 2026-11-06

User reports installing Lua locally. Read-only PATH/version discovery finds
`/usr/bin/lua` and `/usr/bin/lua5.4`, both Lua5.4.6. `lua5.1`/`lua5.3`/`luajit` not on
PATH; this does not exclude a user-installed5.1 elsewhere. Version commands only,
no addon/test execution. Current contract approves alreadyavailable Lua5.1, not5.4
substitution/shims. Both Lua suites still NOT RUN, no agent installation. Request
Lua5.1 or its explicitpath before running approved suites. NativeWoW stage timing/
warning/interactivity/fullperformance gates remain separate and pending;48blocked.

## Lua5.1 now available; both approved suites executed PASS — 2026-11-06

User "Try again" afterruntimeinstallation. Read-only PATH/versioncheck confirms
`/usr/bin/lua5.1` and `/usr/bin/lua`:Lua5.1.5; luajitnotonPATH. EarlierLua5.4-only/
NOTRUN entries historical, superseded forlocalexecutiononly. No agentinstallation,
download/substituteruntime/shim. Primary inspectedrunners andverified reviewed14source
hashes/eightpriorartifacts unchanged beforeexecution. Primary RAN:

```text
lua5.1 tests/dashboard.lua
134 passed; 0 failed (pure fixtures only)
exit0

lua5.1 tests/run.lua
23/23 pure fixture cases passed (not live-client evidence)
exit0
```

Dashboardproducedall134PASS lines/nofailure/incomplete, includingoriginal123/fullstress
andall11instrumentationregressions. Case81PASSannotationwas exactly
`scan2 timings unavailable (clock missing)`, expected onstandaloneLua/no clockshim.
Theseare actualsyntax/load/purefixtureexecution successes, notmere structuralcounts
or newnativeScan timings. Primaryattribution; verifierpreviousstaticreview unchanged.
No implementation/runner/testassertions/parameters weakened or fileschanged to pass.

StandaloneTests.Run drains safeunits synchronously; fakeclockthresholdregressionsPASS
doesn'testablishnativeWoW100ms/frame responsiveness/warning/APIacceptance. ActualWoW
stageevidence stillrequired, optimization48BLOCKED timings/settleddesign. Usealready
reviewedSelfTests-onlymeasurementbuild fornext usernative scan2line/finalsummary/
warning/interactivity; don'treinstallunchangedmodules orclaimbroaderperformancefix.
Nativebars remainpaused. No Git/release/gameAPI/realDB actions.

## Latest50/134 protectedcapture/format102.7ms; K4a49 READY — 2026-11-06

User finalsummary50passed/0failedof134 INCOMPLETE/wall8668.2ms/max102.7ms case51
unit1 [K1 protected capture and format].50complete/84uncompleted/51started;81NOTREACHED
soNO Scan-stage evidence.50startingboundarynotcausality. Individualoperationtimings/
warningrecurrence/interactivity/build/installedhash unknown. Prior134/134+23/23local
Lua5.1PASS remains correctnesshistory, notnative100ms acceptance. No currentrerun.

Source51 loopsTWO full35pathCaptures, eachwithinternalFormat, reportCopy+twoexplicit
Formats/purity/determinism/privacy assertions underone trappedCapture beforepause;
finalinvalidCapture retained. K4a49splits protectedcapture/asserts, firstformat/purity,
deterministicformat/remainingasserts intoindependentlyguarded scopes;3newOUTERpauses,
sharedApply/Evaluate restoredbeforeeverypause. Everyactualoperation/assertion retained;
helperunchanged fullruntimeverificationeachscope, isolatedtrapidentityreset permitted.
No mocks/jobs/reducedstress/casefilter/reordering/raised100ms10000cap toreachmeasurement.
ActualCapture remainsatomicincludinginternalFormat; noindividualdurationpromise.

Primarycurrent14K4hashesmatched, actualpreeditbytespreserved
/tmp/opencode/craftarmy-k4a-baseline. One writer onlySelfTests/README/evidence/49state;
12otherfiles/K4instrumentation/9oldartifactsfrozen. Exactoldbytesinverse required;
installedLua5.1full134+23suites nowmandatory alongsidePythonchecks. Primaryworkspace
k4a-review.diff afterwriterstop/independentreview beforenewSelfTests-onlyuserupdate.
48BLOCKED actualnativeScan-stages/design; no benchmarkcause/fix/acceptance inferred.

## K4a piece49 NEW protected-group delivery — 2026-11-06

**PARTIAL**: implementation and local regression checks done; independent review and
native gate pending. No executable writer remainder or design blocker for49.48 stays
BLOCKED on reviewed native Scan-stage evidence and primary's settled production
contract. Latest native50PASS0FAILof134/wall8668.2ms/case51unit1 max102.7ms remains
INCOMPLETE:84uncompleted/51started/81NOTREACHED => **Scan stages NOT MEASURED**.
Warnings/interactivity/build/installed-byte identity remain unknown; no native rerun.

### Exact scope and safety

- ONLY case51 source changes (now1751–1792). Three new OUTER pause sites:
  -1753 `K4a report fixture ready`, after knowledgeFixture returns;
  -1773 `K4a capture checked`, after complete capture/assertion guard returns;
  -1778 `K4a first format checked`, after explicit Format/purity guard returns.
  The first executes once, the other two once per existing two-iteration repeat.
  Original1786 `K1 protected capture and format` stays after the third guard.
- Per iteration only `r,text,summary` declarations lift before first trappedCapture.
  First guard1756–1772 runs real Capture and ALL original capture/tab/path/currency/
  rank/entry/children assertions; `p` stays local there. Second1774–1777 keeps local
  `before=C.Copy(r)`, actual Format, original deepEqual purity assertion. Third
  1779–1785 keeps original deterministic Format equality then summary/bytes/privacy/
  warnings/build/requests/timers assertions, in original order. The sole combined
  purity/determinism semicolon line is split at the new closure boundary.
- Both repeated complete35-path Captures (including internal Format), all explicit
  Formats and unchanged final invalid Capture1788–1791 execute. No assertion/operation/
  literal/workload change, jobs/stubs/mocks/reduced stress, skip/filter/reorder or extra
  heavy tests. Existing guard/job/instrumentation regressions remain unchanged.
- `trappedCapture` is byte-unchanged: EACH scope verifies the full runtime graph and
  restores C.Apply/K.Evaluate before its outer pause; no yield under pcall/override.
  Synthetic forbidden method identities reset independently between guards; no retained
  graph verification crosses a reset. Actual Capture+internal Format remains atomic;
  individual durations unknown/no<100ms guarantee. K4 MeasureScan/runner/case81/Commands/
  all production and100ms/10000-step limits unchanged. This is NOT a latency fix claim.
- Changed only SelfTests.lua, README, evidence current gate+append,49/current run/new
  delivery in TASKS. PLAN/Q03/review history and all old artifacts untouched. No child,
  new file, real DB/game API/live test, profiler reset/CVar/error-handler, install/shim/
  substitute runtime, Git/release/archive action. Platform N/A; no Git/staged base.

### Actual-baseline retention proof

Before edit, inline read-only Python hashed all14 actual current workspace source
entries from TASKS K4 NEW delivery (not the separate eight artifact entries), matched
every reviewed hash, and separately verified all9 old artifacts including k4-review.diff.
SelfTests was246537bytes/SHA256
`27a1f0ca2697a1154a0036a22dbe9d01ad40465eb137b0a8eaca9fe59dbdc09f`.
Primary-preserved external `/tmp/opencode/craftarmy-k4a-baseline` directory read was
permission-denied; NO retry/bypass. No external comparison claim. Primary generates
the actual permitted workspace review artifact AFTER writer stop.

Executed read-only whole-byte inverse, not names-only/new-vs-new parity:
1. Remove exactly one source line for each of the three named new pauses.
2. Replace the sole per-iteration declaration+first-guard assignment sequence with
   original guard+`local r=NS.KnowledgeCheck.Capture(env,runtime)` sequence.
3. Remove the two added `end)`/`trappedCapture(env,runtime,function()` boundaries;
   return `local` to `text,summary`, join purity and determinism assertions using
   original `; ` on the original single line. No other byte normalization.
Result ENTIRE246537-byte original SelfTests hash above: **PASS**. This recovers every
original assertion/operation/literal/order and all bytes outside the specified edits,
including unchanged helper/K4 timing/runner/81. **134 exact ordered quoted names**
(LF-joined, no final LF) SHA256
`11764f9426f964d008d30cd201b4992368ad539a9b471475fc4f186497ff53dd`, unchanged.
Static checks also count3 added pause sites/3 guards per repeat+unchanged final guard.
Current SelfTests246833bytes/SHA256
`cf2e1e5bf4487283c4311a117e092703b20355eaf0bf91d17542402f1dfbc99c`.
Current README45554bytes/SHA256
`285f82caf06afcd977818f339519d405a1479abf49545548a2f2d8eb5ef20d77`.
Full14 delivery freeze is in TASKS K4a NEW delivery: ONLY these2 deltas/12 frozen;
all9 prior review artifacts unchanged. Pre-edit evidence314121bytes/SHA256
`42521a7e777e29db1b464fef00cc2cdddee1b59c74314c70f5f7048cbfaac55a`;
retention check restores only the two current-gate lines then hashes that exact old
prefix; all historical evidence retained. Final evidence digest is in TASKS delivery.

### Validation — actually executed, implementer-attributed

Inspected complete tools/check_dashboard.py, tools/check_diagnostics.py and both Lua
runners before executing. `/usr/bin/lua5.1`, Lua5.1.5 already installed; no installation.

```text
python3 tools/check_dashboard.py
PASS exit0:15 required files/exact9Lua;23Markdown/71links/eight diagnostic hashes unchanged
python3 tools/check_diagnostics.py
PASS exit0:9 required files/exact4Lua/order/paths/metadata/one SavedVariables
lua5.1 tests/dashboard.lua
PASS exit0: all134 ordered PASS lines;134 passed;0 failed (pure fixtures only);no incomplete
lua5.1 tests/run.lua
PASS exit0:23/23 pure fixture cases passed (not live-client evidence)
```

No baseline check failures. Full actual suites, NOT exit-code-only inference; original
stress and all11 K4 instrumentation regressions ran. Case81 PASS note exactly
`scan2 timings unavailable (clock missing)`, expected on standalone Lua/no shim.
Inline read-only Python actual-preedit hashes/whole-byte inverse/134names/3sites/scopes/
final14/2deltas12frozen/9artifact/evidence-retention checks RAN/PASS. Python structure
alone is not Lua execution; local fixture PASS is not target-client API behavior,
native scheduling/100ms/warning/interactivity acceptance or measured Scan stages.
Native K4a/client APIs/live DB/UI/warnings/interactivity/bars **NOT RUN**.

### Exact resume — primary

AFTER writer stop generate actual K4→K4a docs/dashboard/k4a-review.diff from preserved
primary baseline; obtain independent read-only review of3 OUTER pause sites/3 guarded
scopes per repeat, unchanged helper/full runtime checks/restoration, exact whole-byte
inverse/134 ordered names/all original work, frozen K4/runner/81, README/full14/all9
artifacts. Persist findings BEFORE recommending any SelfTests-only user update.
No remaining executable writer work. After review only: already-on-K4 user quits,
backs up, replaces ONLY SelfTests.lua, keeps all other modules/DB/SavedVariables/
diagnostics, reloads/out-of-combat134 selftest. Share81 scan2 PASS or final scan2 identity
when reached plus COMPLETE/INCOMPLETE summary/counts/wall/max/case/unit/label/warnings/
interactivity; stop before81 final step means NOT MEASURED. New stop once/no unchanged
rerun/filter/skip/raised limit/autoresume. Native bars paused;48BLOCKED native stages/
settled production design. Implementation != independent verification/acceptance/release.

## K4a primary comparison, local re-execution and independent review — 2026-11-06

Actual preserved K4→K4a `docs/dashboard/k4a-review.diff`,124lines/8400bytes/SHA256
`5de4384d593e21ef573092f0f5ff791e9fe415112044b91138b82a83ab3e5be6` primarygenerated
afterwriterstop. Wholebyteinverse threepauses/declarationlift/twoextra guardboundaries/
assertionwhitespace recoversbaseline,134orderednames/current14/exact2deltas12frozen/
nineoldartifacts PASS. Primaryreran bothPythonchecks PASS15paths/23docs71links/eight
diaghahes/separate9paths, Lua5.1dashboard134PASS0FAIL/noINCOMPLETE exit0 (fulloutput
/tmp/opencode/craftarmy-k4a-dashboard.log), diagnostics23/23PASS exit0. No sourcefix
neededafterexecution; actualcases not merelycounted. NativeScan stagesNOTMEASURED.

Verifier COMPLETE/static **PASS**, native/performance **INCOMPLETE**, no blockers.
Read fullactualdiff/currentcase/helper/runner/contract/docs. Both35pathcaptures/all
Formats/assertions/finalinvalidCapture retained; iterationlocals safe. Eachguard
verifiesruntime/restoresApply/Evaluate beforepause; no pcallyield/globalleak/cancel
hazard identified. No codeoutsidecase51changed, K4instrumentation/81/productionfrozen.

Reviewed SelfTests `cf2e1e5bf4487283c4311a117e092703b20355eaf0bf91d17542402f1dfbc99c`,
README `285f82caf06afcd977818f339519d405a1479abf49545548a2f2d8eb5ef20d77`, pre-review
evidence `6ae232ceb98bf6daa545e4f01aa6f9d4ce0d8e82befff819eef1348afc2dc1f0`, artifact
above. NoGit/stagedbase; reviewershellattempt deniedbeforeexec/no retrybypass/edits;
execution/hash/inverse successprimary/implementer-attributed. Visiblesourcestable;
finalhashprimary-owned. PlatformN/A/no releaseapproval. Latestnative50/134102.7ms
remainsincomplete84cases,81NOTREACHED/noScantimings/warnings/interactivityunknown.
Next reviewedSelfTests-onlynativegate/134summary+scan2if81reached, newstoponce/no
unchangedrerun/raise/skips;48BLOCKED nativeevidence/design/nativebars paused.

## Native Scan stages received; K5 Core fix48→50 READY — 2026-11-06

User finalsummary INCOMPLETE81passed/0failedof134, case81unit11/case return,
wall79956.2ms/maxunit147.2ms. Terminalannotation:
`scan2 ms excl T=147.1 O=28.4 A=37.3 C=70.8 K=4.1 E=6.1 G=0.1 B=0.1 R=0.2`.
81completedPASS/53uncompleted. StagesNOWMEASURED; previous50/134notmeasuredrun remains
separatehistory. No warningrecurrence/interactivity/build/installedhash report.

T probe-inclusive measuredfinalScan, outerunitincludesprobeinstallation/cleanup/asserts.
O/A/C exclusive136.5ms~92.8% ofT; nativeknowledgecollection4.1/evaluation6.1ms.
TagsareEXCLUSIVE, not sumofnestedinclusiveOpen/CopyinsideApply. One-decimaldisplay
sum147.2vsT147.1 expectedrounding; no fabricatedprecision/cause. These are isolated
injectedfixturesexecutinginsideclient, notrealBlizzardAPIlatencyorproductionprofile.
Knownsnapshotpipeline dominant; don'tblameBugGrabber/GC/machine orclaimfullPASS.

SourceCore30–53/65–83/455–557 identifiesdiscardedclonevalidation and repeatedcopies
ofalreadyclonedcandidatefields/observations. Underuserapprovedbroaderfix, primary
settlesK5 SAMEboundedwalker optionalnooutputallocation forCore.Open/finalproposal,
andprivateownedmergeinsideCore.ApplyAFTERfullincomingpack/oldcharacterclones.
No skippedgraphchecks/typedvalidators/nativefinite/aliasexpandedlimits/scope/stability/
singlecommit; publicValidObservation/Mergeunchanged. No publictrustedtoken/cache/async.
candidateMirror exactbytealgorithm retained, allocationbudgetwalker stillcounts
allaliases peroccurrence. Everyremovedcopy requiresownership/priorvalidationproof.

Primarymatchedcurrent14K4ahashes/preservedactualpreeditbytes
/tmp/opencode/craftarmy-k5-baseline. One synchronouswriter ownsCore/SelfTests/README/
evidence/48-50taskstate;11otherhashedfiles/all10priorartifactsfrozen. CoreFinite/Integer/
payloadvalidators/validGeneration/candidateMirror bytefrozen. Full134oldcasesbytefrozen,
appendownership/guard/allocationregressions, localfullLua5.1+diagnostic+Pythonchecks,
primaryworkspacek5-review.diff andindependentreview beforeCore+SelfTestsupdate.
No currentrerun/latencyguarantee; newnativeTOTALT/unit/fullcompletion mustimprove, not
justCbucketmovingintoO/A. Nativebars/fullperformance/warning/interactivity stillpending.

## K5 NEW implementation delivery — pieces48→50 — 2026-11-06

**PARTIAL — implementation/local checks done; independent review and native gate NOT
RUN.** No executable writer remainder or unsettled design blocker. Piece49 was already
delivered/reviewed; only48 then50 executed this pass. Primary owns actual workspace
`docs/dashboard/k5-review.diff` generation AFTER writer stop and independent review
before recommending a user update. No claim of <100ms or native/production latency PASS.

### Actual comparison base and preservation

Before edits, read/hash-verified ALL14 current K4a source entries from TASKS K4a NEW
delivery (separate from its9 artifact entries), plus the tenth artifact k4a-review.diff.
Retained actual permitted workspace bytes at `/tmp/opencode/craftarmy-k5-writer-preedit`.
Did NOT access/retry the primary's external `/tmp/opencode/craftarmy-k5-baseline`.
Actual pre-edit Core32476bytes/SHA256
`68fa0719550f6befbf1f094966c5115d1425e1f9fdad1a30737bab67dfc7d441`;
SelfTests246833bytes/SHA256
`cf2e1e5bf4487283c4311a117e092703b20355eaf0bf91d17542402f1dfbc99c`.
No synthetic reconstructed baseline was substituted for these bytes.

Read-only Python proof against those ACTUAL pre-edit bytes:

- Split old SelfTests at its sole `function Tests.Run(cases)`. Current file starts with
  the entire old prefix, and the whole runner tail is identical. Removing ONLY the
  new22126-byte block before that function reconstructs the entire246833-byte old file
  and its SHA256 above. Thus ALL134 old case bodies/names/order/assertions/checkpoints/
  stress sizes, K4 helper/timing/clock selection and case81 are byte-exact, not merely
  new-vs-new parity.134 LF-joined QUOTED names/no trailingLF retain SHA256
  `11764f9426f964d008d30cd201b4992368ad539a9b471475fc4f186497ff53dd`.
  Unquoted-name representation hashes to
  `f0495f51591db9f78d9a9d33759553618c47f6d72286c466b4cd7a8c29fe6f42`.
- Test-only old Copy body equals actual old Core.Copy with ONLY declaration renamed
  to k5OldCopy; local `Core=C` preserves all original body bytes. Test-only sameInstance
  likewise only renamed. Old gear oracle equals actual old mergeEquipment with ONLY
  its declaration/success-table/sameInstance references renamed; it calls unchanged
  PUBLIC Core.Merge. No production old module or new-owned-path oracle was substituted.
- Production walker equals actual old Copy after ONLY helper declaration change,
  conditional `out` allocation, unconditional child recursion + conditional assignment,
  check-mode successful `true` return and public compatibility wrapper. Original
  counting/type/key/finite/ancestor-seen logic and error classes are untouched.
- Core.Open equals old Open with ONLY `Core.Copy(db)` replaced by private check-mode.
  mergeEquipment equals old algorithm with ONLY optional merge/default plumbing and
  four same-position call substitutions. Apply equals old Apply after ONLY retaining/
  rebinding inputpack, identity clone reuse, private shape/merge dispatch and final
  discarded-copy replacement. All other bytes of these functions match the actual base.
  Frozen block digests below were also compared old==new, not just recorded.

| Byte-identical Core block (start through before next named block) | Bytes | SHA256 |
| --- | ---: | --- |
| Core.Finite through before Core.Integer |696|`b2ac5778f624e12d07ab3d4724201a07b5badb52c6c28074668dfc49270b7667`|
| Core.Integer function including final LF |146|`2fcc0746b4f5ed17685b5ec541fca455e34d6ef164f966e46d15ad3c8a1cfcd5`|
| Observation/validAttempt/ValidObservation/Merge through before equipmentKey |1351|`0d1023c2cc7fd0088e0a16bc259eef246ec213eaddb5fe6707a5def4a880feea`|
| equipmentKey/sameInstance (before inserted private helpers) |494|`0718d4e255ba57978cf50512bd27d9dfa059d544ab14f373bb3e98fbb2deb3e3`|
| Registered-schema comment + ALL payload/identity/field/generation validators through before Open |19936|`39e4a47462ce77db20c5226ddd7a5d980800b3517a0ad1eaa3309db3bb46cb3e`|
| Preflight-mirror comment + candidateMirror through before Apply |1166|`91daea344f244369e5f7c10dfbc9d04c3ce7033af6e6820d6b34fc5a84c38a26`|
| Archive/CompareRoster/Delete through EOF |1929|`59f6cb16cb0c4e0a3068b61a0eb3068109e9f3920db9650c12369209ac699031`|

Proof output `/tmp/opencode/craftarmy-k5-preservation.log` records exact transformation
and oracle checks. Initial read-only proof attempt asserted because its EXPECTED walker
assembly omitted one blank line; inspecting that whitespace and correcting the expected
string made the exact comparison PASS. No source fix, failed guard or baseline mismatch
was hidden. Final post-test whole-byte/134-name proof also PASS after added coverage.

### Removed-copy ownership and guard proof

- **Open discarded db clone:** old output was unused. New `boundedData(db,false)` at
  Core492 executes the SAME recursive walk as Copy: count every value occurrence,
  count BEFORE depth/type checks, limit50000/depth20, strings4096/keys128, native finite,
  integer nonnegative keys, original getmetatable/cycle/type predicates. `seen` remains
  active-ancestors only and is cleared after each table. No memo/cache/sampling.
  Check-mode removes ONLY output tables and assignments; typed/schema/generation/archive/
  native validators at Core493–517 still run unchanged. Native-aware Finite/Integer are
  byte-frozen. Inherited truthiness behavior of `getmetatable(v)` is preserved exactly,
  including the old `__metatable=false` acceptance; this pass does not strengthen or
  weaken that pre-existing guard. Ordinary/protected-truthy metatables still reject.
- **Incoming observation deep guards:** Apply548 still Open-validates db;550 retains
  the FULL `Core.Copy({character,identity,observations})` this call under the original
  combined50000/depth20 budget.552 rebinds all three inputs to those private clones
  BEFORE typed identity/payload/shape checks. Copy expands aliases per occurrence,
  including cross-input and repeated observation/value tables. Thus the private shape
  guard at108 checks the original validAttempt + observed non-nil requirements without
  needing another deep copy; it is not callable as a public trusted-token/flag/API.
- **Previous-field copies:** Core560 STILL clones the WHOLE old character after Open,
  privately owning old active fields, other professions, archives and unknown metadata.
  No candidate subtree is borrowed from the original DB/old returned generation. New
  character candidates are fresh tables. mergeOwned113 reuses only this candidate's
  prior field; no caller-owned field can reach it. It retains shape/generation/build
  guards and exact attempt/last/success/failure/time/false/0/nil behavior. Typed payload
  checking573 and final validGeneration582 are retained; malformed candidates fail.
- **Identity and successful value copies:** incoming identity and every observation's
  value are already unique private expanded clones from550; reuse at568/571 and120
  introduces no cross-field/caller sharing. Gear's temporary observed envelope is built
  privately from the same owned observation value; the single old four-branch algorithm
  still decides preserve/replace/clear. No duplicate gear implementation ships.
- **Final proposal discarded clone:** unchanged candidateMirror523 retains aliases and
  bounded memoized copying exactly as before.588 simulates the exact one map-key write;
 589 walks the WHOLE proposal in nonmemoized check-mode, expanding every alias occurrence
  for the SAME global budget.590 is still the sole real DB write. Old-character aliases
  stay old; characters-map aliases see the replacement. No key omission/alias rejection/
  reset/eviction or bound change. Rejections leave DB/input references untouched.
- Core adds no yield, external callback, scheduler, persistence hook or early real write
  between cloning and commit; existing numeric/native predicate calls are unchanged.
  **Archive600 still actually Core.Copy's the generation**; public ValidObservation and
  Merge remain fully guarded byte-identical standalone APIs, never trusted wrappers.

### Appended regression guard map (actual149 definitions)

| Cases | Coverage |
| --- | --- |
|135|Frozen old Copy primitive nil/false/0 behavior, integer keys, repeated alias expansion and bidirectional caller/copy isolation.|
|136|Frozen-old/new Copy + check-only Open string4096/+1, key128/+1, negative/fractional/infinite/bool/table keys, function/thread, ordinary/protected metatables, cycle/indirect cycle guards; original truthiness case preserved.|
|137|Actual-runtime NaN/+infinity/-infinity samples on EVERY host reject Copy/Open/incoming Apply; no native predicate mock used as target API evidence.|
|138|Exactly50000 visits valid and50001 invalid, old Copy/new Copy/Open separately; root+schema+characters+padding=4,49996 leaves.|
|139|Alias-per-occurrence boundary:6+2×12000+25994=50000; one extra leaf rejects all three walkers, no memo undercount.|
|140|Depth20 valid/depth21 invalid in old/public/check-only paths.|
|141|Open succeeds under Core.Copy failtrap yet still rejects cyclic/typed/archive corruption; finally restoration also exercised after intentional test error; no yield under overrides.|
|142|Small Apply with1 or6 observations calls Copy EXACTLY1 time for new character (inputpack), EXACTLY2 for existing (inputpack + whole oldcharacter), proving no per-field copy loop; actual arguments asserted.|
|143–144|Whole candidate vs old DB/returned generation/archive/other profession/metadata + original character/identity/observation/attempt bidirectional mutation isolation; aliases across inputs and prior/incoming fields expand independently.|
|145|All6 statuses×nil/zero×absent/existing prior parity against unchanged public Merge; original public false/stale semantics retained.|
|146|All4 gear key forms×6 statuses×6 same/changed-ID/changed-link/unidentified/removed/nil modes×absent/existing prior =288 variants vs frozen-old gear algorithm + unchanged public Merge.|
|147|Malformed incoming shape/identity/typed values/cycle/metatable/generation/build/at and damaged old DB reject with exact retained graph edges.|
|148|Individually valid native raw payload on foreign generation scope still fails final unchanged validGeneration, with DB/inputs untouched; no fake verified costs or new mapping.|
|149|Archive actual owned copy argument/count, old returned generation isolation, reload, relearn generation2/fresh fields, retained archive isolation both directions.|
|Original1–134 unchanged|All prior typed malformed/nonfinite/attention/native coherence/index/source/staging/archive/reload checks; original exact50000/+1 assembled candidate and root/nested/multiple-map-alias budgets and old-character aliases retained. Native case81 remains the ONLY measured final Scan, unchanged; no extra heavy35-path latency test added.|

Large new setups pause every1000 insertions; complete old Copy/public Copy/Open/count
operations have separate outer checkpoints. Small oracle variants pause between complete
variants. Never yield in Core's protected walker, test pcall, or Copy override; no changed
runner thresholds/caps/cases/workload/clock. Local complete execution demonstrates the
unchanged10000-step cap was not exhausted, NOT that native unit latency is below100ms.

### Checks actually executed

Inspected the COMPLETE current scripts `tools/check_dashboard.py`,
`tools/check_diagnostics.py`, `tests/dashboard.lua`, `tests/run.lua` BEFORE execution.
`command -v lua5.1` returned `/usr/bin/lua5.1`; `lua5.1 -v` returned installed Lua5.1.5.
No install/download/alternate runtime/shim. RAN exact approved checks (including full
rerun after final regression coverage edits):

- `python3 tools/check_dashboard.py` — PASS exit0,15 required files/exact9Lua/order/
  metadata/isolatedDB/no dependencies;23 Markdown files/71 links/eight diagnostic hashes.
- `python3 tools/check_diagnostics.py` — PASS exit0,9 required files/exact4Lua/order/
  paths/metadata/one SavedVariables. Both rerun after final docs as recorded in TASKS.
- `lua5.1 tests/dashboard.lua` — PASS exit0, **149 actual PASS lines/0FAIL/no INCOMPLETE**,
  final `149 passed; 0 failed (pure fixtures only)`. Full output
  `/tmp/opencode/craftarmy-k5-dashboard.log`; original81 retains the expected standalone
  `scan2 timings unavailable (clock missing)` note. No clocks injected for latency.
- `lua5.1 tests/run.lua` — PASS exit0, exact
  `23/23 pure fixture cases passed (not live-client evidence)`; full output
  `/tmp/opencode/craftarmy-k5-diagnostics.log`.
- Inline read-only Python actual14/all10-artifact pre-edit/final allowed-delta/frozen-
  Core/exact-transform/test-oracle/whole-byte134/quoted-name149-output checks — PASS.
  AGENTS/PLAN/Q03 unchanged. No baseline fixture failure was encountered. Historical
  native81/134 INCOMPLETE and warning/interactivity gaps remain, not retroactively PASS.
- **NOT RUN:** independent K5 review, native K5 full149 scheduling/latency/warnings/
  interactivity, live client APIs/real DB/native bars. Local fixtures are not client API
  evidence, and no local duration or manufactured production cost is claimed.

### Freeze and exact next action

ONLY Core/SelfTests/README delta among14 (**11 frozen**); ALL10 prior review artifacts
including k4a-review.diff unchanged. Full14 and10 artifact digests in TASKS K5 NEW
delivery. Current Core34076bytes/SHA256
`36c6a097973c3940e1300e0fbe377c3d141984cd3fbc92a49fa71ae2b7b5706e`,
SelfTests268959bytes/SHA256
`c2d0b1f8cb27c92cc458272c209f363088aa8a59e964b9613acaed16932f23d3`,
README48532bytes/SHA256
`02978f8d198599d1419636c07e1d5c220cc0368bd211a4018da8857dabced1c0`.
Restoring ONLY the changed current-gate line5 and removing this appended section
recovers actual pre-edit325770-byte evidence prefix/SHA256
`79828074ab1095fa9f90a8be16e11e6723200b53b9820c2c9c74402b71b8c564`.
All historical evidence retained. Final evidence hash is recorded in TASKS, not here
(avoids self-hash). Writer changed only approved5 paths including task run state;
no PLAN/Q03/review history/artifact edits, children/new repo files/features/installs/
gameplay/realDB/gameAPI/profiling reset/CVars/error handlers/Git/release/archival.
Platform N/A; no Git/staged comparison base.

**Primary next:** AFTER writer stop generate actual K4a→K5 workspace k5-review.diff
from the preserved primary base; obtain independent read-only review of exact guards/
ownership/old134 retention/15new cases/freeze/README and persist findings BEFORE any
user recommendation. Then, only after review, already-on-K4a user quits/backs up and
replaces ONLY Core.lua+SelfTests.lua, preserves ALL other modules/DB/SavedVariables/
diagnostics, reloads/outcombat selftest149. Share81 scan2 PASS or final scan2 identity
(stop before final81 means NOT MEASURED), final summary/counts/wall/max/case/unit/label,
warnings and interactivity. Compare TOTAL T with147.1ms and unit with147.2ms, not Copy
alone: check-mode walk now falls within O/A, so category shifts are expected. No
unchanged-version reruns/skips/reordering/filter/raised100ms/10000cap. Native bars stay
paused until satisfactory safe full completion/performance/warning evidence. Delivery
is not independent verification, client acceptance or release.

## K5 primary comparison/local re-execution/independent review — 2026-11-06

Actual preserved K4a→K5 `docs/dashboard/k5-review.diff`,651lines/37390bytes/SHA256
`438db570bf769f18877135f211714d92a5da508412b9bd653aac724849879866` primarygenerated
afterwriterstop. Current14/exact3deltas11frozen/10oldartifacts/evidencedigest verified;
original134casebodies wholebyteidenticalafterremovingK5block,149ordereddefinitions.
NativeFinite/Integer/sameInstance/publicObservationValidObservationMerge/alltyped
validators/policies/validGeneration/candidateMirror/ArchiveCompareRosterDelete body
bytes frozen. TestoldCopyoracle exactoldbody (declarationrenamed). Initialmanifest
parser includedfunctionhashrows/failedreadonlyassert; correctedpath-prefixed14file
selection PASS/no sourcechange. PrimaryRAN149PASS0FAIL/noINCOMPLETEexit0 (fulloutput
/tmp/opencode/craftarmy-k5-dashboard.log), diagnostics23/23PASSexit0 andbothPythonchecks
PASS15paths/23docs71links/eightdiagnostichashes/separate9paths.

Verifier COMPLETE/staticdesign **PASS**, nativeperformance **INCOMPLETE**, no blockers.
Readfullactualdiff/productionCore/tests/relevantoldregressions/docs/contract. Both
walker modes retainfullbounds/nativefinite/integer/ancestorcycle/peraliasoccurrence
guards. ApplyretainsOpen/fullinputclone/fulloldcharacterclone, removedcopies useONLY
privateowneddata. Publicobservation/Merge/typednativechecks/gearbranches/aliasmirror/
fullcandidatebudget intact, rejections beforeSOLEcommit. IndependentoldCopy/publicMerge/
oldgearoracles coverownership/budget/malformedinputs ratherthannew-vs-newparity.

ReviewedCore `36c6a097973c3940e1300e0fbe377c3d141984cd3fbc92a49fa71ae2b7b5706e`,
SelfTests `c2d0b1f8cb27c92cc458272c209f363088aa8a59e964b9613acaed16932f23d3`,
README `02978f8d198599d1419636c07e1d5c220cc0368bd211a4018da8857dabced1c0`, pre-review
evidence `927fe641562ce6e85d71260ce1fd900e45850af188a3d154cb87a3c71ae6f69b`, artifact
above. NoGit/stagedbase; verifier shell/hash/externallogreads denied/no retrybypass/
edits, executable/hashsuccessprimary-attributed. Visiblesourceunchanged; primary
finalfreezecheckbeforeupdate. PlatformN/A/no releaseapproval. NativeK5 NOTRUN/localPASS
notaspeedup. Latest81/134T147.1/unit147.2 stillincomplete53cases/warnings/interactivity
unknown. Next Core+SelfTests-only149nativegate, TOTALT/unitcomparison notCshiftalone;
nativebars paused until satisfactory safefullcompletion/performance/warningevidence.

## K5 native result and K6 continuation — 2026-11-07

Latestuserresult INCOMPLETE81passed/0failedof149, case81finalunit103.0ms,
wall73689.9ms. Annotation T102.8 O36.5 A37.1 C18.2 K4.2 E6.3 G0.2 B0.1 R0.2ms.
T147.1→102.8 improves44.3ms(~30.1%), butstill>100ms;68casesuncompleted/newnative
full149 notaccepted. Warningrecurrence/interactivity/build/installedhash unknown.
Categoryshift expectedaftercheck-onlymode, TOTALimprovementrealwithinthese reported
fixturemeasurements; notpureBlizzardAPI/productionlatencyproof. No unchangedrerun.

User requestscontinue afterusagereset. Primaryverified all14currentK5sourcehashes and
exactalready-preserved /tmp/opencode/craftarmy-k6-baseline bytes; noK6sourceeditsyet.
Lua5.1.5available. SettledTASKS51→52 privateper-walknumericdispatch usesexistingouter
pcall, identicalnativecalls/strictresults/typeguards/zero-boundcheck/order andfixed
failureclassification, no guardremoval/publicFinitechange. IsolatedfreshCore/mathenv
standaloneparity/pcallcounts required, realmath/SelfTests149 remainbytefrozen. Only
Core/standalonerunner/README/evidence/taskstate writerowned; primaryreviewafterstop.
No directnativecalloutsideprotectedwalk, no nativepayloadleak/cache/raise/skip/async.
NewnativeTOTALT/fullcompletion stillrequired; nativebars remainpaused.

## K6 NEW implementation delivery — pieces51→52 — 2026-11-07

**PARTIAL**:51 then52 delivered serially. No executable writer remainder or design
blocker. **Primary resumes AFTER writer stop:** generate the actual K5→K6 workspace
`docs/dashboard/k6-review.diff` from `/tmp/opencode/craftarmy-k6-baseline`, obtain
independent read-only review and persist findings BEFORE recommending any user update.
Implementation and local execution are not independent verification, native performance/
API acceptance or release. Platform review N/A; no Git/staged comparison base.

### Actual comparison base and protected-call proof

- BEFORE editing, read/hashed all14 actual workspace sources and all11 old review
  artifacts, matched the recorded K5 hashes, and preserved relevant bytes at
  `/tmp/opencode/craftarmy-k6-writer-preedit`. Primary's external baseline was NOT
  accessed, denied or retried. Old Core34076bytes SHA256
  `36c6a097973c3940e1300e0fbe377c3d141984cd3fbc92a49fa71ae2b7b5706e`;
  old runner560bytes SHA256
  `601990e4a67b4fc3fb048bbf86cb8337974dd3323e771ea20adfcfd18a8edab4`.
- New Core32–52 is a PRIVATE factory, called only by boundedData58 and
  candidateMirror551. Its direct native call42 can execute only via their numeric
  guards in `copy`/`mirror`, wholly under the PRE-EXISTING `pcall(copy,value,0)`79
  and `pcall(mirror,db,0)`568. The factory itself makes no native calls. No helper
  escapes/exports, trusted API, module-global active flag, injected production
  library, yield or callback is added. Typed validators still use public guards.
- Old boundedData38 `Core.Finite(v)` → new64 `finite(v)`; old44
  `Core.Integer(k,0)` → new70 `integer(k)`. Old mirror530 `Core.Finite(value)` →
  new557 `finite(value)`; old536 `Core.Integer(key,0)` → new563 `integer(key)`.
  These are ALL four old numeric call sites affected. Only their nested
  `Core.Finite` native `pcall` boundary is removed, NEVER the numeric/native check.
- Each finite call keeps typegate → current `math` table type → `rawget(isfinite)`
  → presence/function checks → direct native call → strict boolean result. The
  library/predicate is reread EVERY check, not cached. Present native never takes
  an IEEE comparison fallback. Absent native delegates unchanged `Core.Finite`.
  Key integer guards remain `finite(key) and finite(0) and key%1==0 and key>=0`,
  preserving short circuit, native arguments/order/count and the literal0 check.
- Per-factory pending class is set immediately before the native call and cleared
  after EVERY normal return, including false/nonboolean. boundedData84 returns the
  fixed pending class on native exceptions (`invalid/cyclic data` for values;
  `invalid key` for keys/lower0), never raw private payload. Ordinary errors retain
  `tostring(result)`. Mirror keeps its original outer catch/nil failure; internal
  contexts are `invalid mirror value`/`invalid mirror key`. Independent closures
  prevent nested Copy/Open failures from clobbering the outer pending context.
- No other walk behavior changed: traversal50000/depth20, type/metatable/cycle/
  ancestor seen, strings4096/keys128, per-occurrence aliases, allocation flags and
  mirror memo/exact alias simulation remain. All Open/Apply/typed/owned merge/
  preflight/commit/Archive bytes are unchanged; no validation dedup or count removal.

Read-only exact inverse proof against the ACTUAL pre-edit Core **PASS**: remove only
the private helper block (`-- Private to the two whole-walk` up to `-- Both modes`),
the two factory-binding lines, reverse the four numeric call substitutions above,
and change `pendingFailure() or tostring(result)` back to `tostring(result)`.
The result is the ENTIRE original34076bytes/hash above, not new-vs-new parity.
Each reverse substitution occurred exactly once. Explicit frozen block checks:

```text
ddc9c51831f2f1ad9e4f3488bd29c5c0fc17220af5256c29ff8dea0ffc831a56  public Finite/Integer (844 bytes)
6241e5a9c128b91d05e19ea621db0d036bf346e8a396784b1499d74661bba459  Copy API/comment (142 bytes)
78d2051841544cca56728e2eb755ea9f2a2ac2e6124cad62fe05559ed5ead943  Observation through Open, including ALL merge/typed bodies (25816 bytes)
015c0b5914817fb7a40acbbd4ecd5671698a39adaec771118defc4f610ae5110  Apply/Archive/CompareRoster/Delete (4631 bytes)
```

### Standalone regression evidence (not WoW behavior)

- Existing tests/dashboard.lua560-byte loadmanifest/run/output/success-check prefix
  remains EXACT. Everything new appends AFTER it. ALL SelfTests.lua268959bytes
  remain EXACT SHA256
  `c2d0b1f8cb27c92cc458272c209f363088aa8a59e964b9613acaed16932f23d3`:
  **149 actual ordered cases**, unchanged bodies/assertions/stress/K4 timing/runner/
 100ms/10000cap. No new in-client case, clock shim or duplicate heavy Scan.
- Fresh Core chunks load with loadfile/setfenv ONLY in the standalone supplement.
  Each has its own namespace/environment, copied host math table and fake native
  predicate; standard libraries may be inherited. No NS.runtime/real DB/UI/game
  API is borrowed. Real host math/native field is NEVER modified (also asserted).
  Missing math is explicitly not inherited through the isolated environment.
- Test oracle is the ENTIRE frozen pre-K6 boundedData body using the SAME isolated
  Core's unchanged public Finite/Integer. Read-only `textwrap.dedent` comparison
  to actual old Core matched byte-for-byte (only embedding indentation differs).
  The oracle function environment uses the same counterwrapped isolated pcall.
  Copy output, nil/false/zero, immutable input values/references/metatables, fresh
  output/expanded aliases, rejection classes and exact native argument sequences/
  counts agree. A simple key/value graph explicitly asserts `[2,0,7]`.
- Native modes cover boolean true/false, IEEE host NaN/±infinity, absence,
  nonfunction, nil/numeric/string/table nonboolean results, invalid/nil math,
  rawget-vs-inherited predicate, throws separately at value/key/lower0, reject0,
  dynamic function/library replacement, dynamic absence/nonboolean, metatable/
  cycle/badtype/negative/fractional key. Deliberately always-true fake natives on
  host NaN/infinity prove native dispatch remains authoritative, NOT a valid real
  classifier or WoW NaN evidence. Old149 retain full bounds/typed regression work.
- Bounded one-shot fake callback reenters separate Core.Copy and Core.Open; nested
  private exceptions fail closed with exact classes and no payload. Fake native
  binding/counter state is restored even on error. Outer success and outer key
  exception both retain their own context. A normal key/lower native return followed
  by a bad value verifies pending key state was cleared. Direct Open value/key/
  lower exceptions separately return its exact fixed failure/no partial result.
- Real isolated Apply sentinel visits1/2/3 exercise initial full Open, mirror, final
  proposal (not spies/skipped work). Both false and throw modes at every stage
  assert exact returned reason, visits, no character commit, all original DB/input
  references/values unchanged and omitted PRIVATE payload. Additional mirror key
  and lower0 throws return `Bounded saved data mirror unavailable; scan not applied`
  with no commit. Final-proposal failures return
  `Assembled snapshot exceeds bounded saved data limits`.
- Isolated pcall counter proves accepted alias walk uses1 outer call versus oracle
  1+4 native calls=5, with the SAME4 native arguments/checks. This is overhead
  boundary-count evidence ONLY; no walltime claim. Any check assertion raises a
  Lua error/nonzero exit. Final separate summary is NON-`PASS ` prefixed:
  `K6 isolated supplement: 744 checks; 0 failed (standalone fake predicates, not native performance/API evidence)`.

### Commands actually run and remaining gates

Inspected complete Python scripts and both original runners BEFORE execution;
inspected new standalone tests before running. Already installed `/usr/bin/lua5.1`
reports Lua5.1.5. No install/alternate runtime. RAN:

- `lua5.1 tests/dashboard.lua` (stdout/stderr retained at
  `/tmp/opencode/craftarmy-k6-dashboard.log`, actual output inspected): exit0,
  **149 PASS lines,0FAIL,noINCOMPLETE**;
  `149 passed; 0 failed (pure fixtures only)` then **744 separate supplement checks,
  0 failed**. Earlier supplement run731/0 also passed; added two native-authority
  parity cases and reran the FULL command for final744/0. Case81 correctly reports
  `scan2 timings unavailable (clock missing)`; no clock shim/native timing invented.
- `lua5.1 tests/run.lua`: exit0, exact
  `23/23 pure fixture cases passed (not live-client evidence)`.
- `python3 tools/check_diagnostics.py`: exit0, PASS9 required paths, exact TOC/
  order/metadata/one SavedVariables; structural only.
- `python3 tools/check_dashboard.py`: exit0, PASS15paths/exact9Lua/order/metadata/
  isolatedDB/no dependencies;23Markdown/71local links/eight diagnostic hashes unchanged.
  Both Python checks rerun after final documentation.
- Inline read-only Python preedit14/11artifacts/hash retention, exact Core inverse,
  frozen public/body hashes, frozen old-walker oracle, entire SelfTests, runner
  prefix, actual output counts, exact3allowed deltas11frozen and11artifact/PLAN/
  AGENTS/Q03 preservation checks **PASS**. One final evidence-prefix proof attempt
  appended an extra newline in its expected reconstruction and asserted; corrected
  the read-only recipe (no source/evidence rewrite) and the whole-byte proof passed.
  No baseline/local fixture failures.
- **NOT RUN:** independent K6 review; native K6 full149/scheduling/100ms performance/
  stages/warnings/interactivity, real APIs/DB/UI or native bars. Local mocked
  predicates/regressions are not target-client API or performance evidence.

Changed ONLY assigned Core/standalone runner/README/evidence and51/52/currentstate/
NEWdelivery in TASKS. No new repository file, child agent, feature/dependency/install,
Collector/measurement change, real game/DB access, profiler reset, CVar/error-handler
change, Git/release/publication/archival. PLAN/Q03/AGENTS/primary histories unchanged.

Current14 freeze, **ONLY Core/runner/README delta,11 frozen** vs actual K5:

```text
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
50105139dfe727aee52c2f3108a16041a9f2f0928e687a25867a9e13a780b001  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
4fa5c2d0817be04c55eada64934f70f680cbc2c6d0a83943cf4411153ac9e60c  CraftArmy/Collectors.lua
214550def55ff05025c933fe1375cdd969cce954736dbd87403e0e9d6ba43f89  CraftArmy/KnowledgeCheck.lua
a9116a628a7168ec6b3cf0a7ef9be4878350da8cf87a15b39b16ca600b7d38f0  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
c2d0b1f8cb27c92cc458272c209f363088aa8a59e964b9613acaed16932f23d3  CraftArmy/SelfTests.lua
b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3  CraftArmy/Commands.lua
c6f2349120d5794ba7b4e8ed1e9c8bc68289a5f8c23f88bdcdd708072618de35  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
84ee999e6b6838866514244f4075f7685f334d7a61e5f8065bd35c6432455d5b  docs/dashboard/README.md
7f9e414fddc43c1533b5b05f0b09f39723e6f579f8506b3ab20b0162b22f23cb  docs/dashboard/schema.md
```

Final Core35310bytes/runner15453bytes/README51768bytes. Evidence final hash is recorded
in TASKS K6 NEW delivery (avoids self-reference). All11 prior review artifacts remain
byte-unchanged; hashes are the K5 NEW delivery's10-artifact table plus
`438db570bf769f18877135f211714d92a5da508412b9bd653aac724849879866`
for `docs/dashboard/k5-review.diff`. Removing ONLY this appended K6 section and
restoring sole current-gate line5 recovers the ENTIRE prior344749-byte evidence,
SHA256 `1f3a4cc6bc4f81995f860fe2a7932ed255d7ffe89114ba381aff3c2a2eed45cb`.

README after-review-only already-on-K5 quit/backup/replace ONLY Core.lua; keep current
SelfTests149/all other modules/DB/SavedVariables/diagnostics, reload/outcombat149selftest.
Share81scan2/finalsummary/warnings/interactivity; compare TOTALT102.8/unit103.0 latest
and initialT147.1/unit147.2, never buckets alone. No unchanged rerun/filter/reorder/
skip/raised100ms10000cap/autoresume. Latest native remains81/149INCOMPLETE,
68uncompleted/warnings/interactivity unknown. Bars remain paused pending satisfactory
safe full completion/performance/warning evidence. No performance PASS or release.

## K6 primary comparison/local re-execution/independent review — 2026-11-07

Actual preservedK5→K6 `docs/dashboard/k6-review.diff`,500lines/26776bytes/SHA256
`fae6544aa7a8a6b070757addc916bd3460ec226d21d59eefb8b92a68affc7a1e` primarygenerated
afterwriterstop. Full14/exact3deltas11frozen/11oldartifacts/pre-reviewevidencedigest
verified. WholeCoreinverse removesONLYhelper/numericguardplumbing andrecoversactualK5
bytes; publicFinite/Integer/typed/ownedpipeline/commit unchanged. EntireSelfTests149
bytefrozen, standaloneold149runnerprefix unchanged, supplementoracleexactoldboundedData
body. PrimaryRAN149PASS0FAIL/noINCOMPLETE+744separateisolatedchecks exit0 (fulloutput
/tmp/opencode/craftarmy-k6-primary-dashboard.log), diagnostics23/23PASSexit0 andboth
PythonchecksPASS15paths/23docs71links/eightdiaghahes/separate9paths.

Verifier COMPLETE/designstatic **PASS**, nativeperformance **INCOMPLETE**; no blockers.
Readfullactualdiff/currentcode/runner/contract/docs. Directnativecalls ONLYwithin
twoexistingwalkerpcalls; strictboolean/per-checklookup/key-literal0/pre-arithmetic
guardorder preserved. Per-walkpendingclass/nopayload/reentry isolation correct;
public/typedguards/finalcommit unchanged. Frozenoldwalker/nativeargcount-sequence/
failure-stage/immutableinput tests meaningful, no weakenedcoverage identified.

ReviewedCore `50105139dfe727aee52c2f3108a16041a9f2f0928e687a25867a9e13a780b001`,
runner `c6f2349120d5794ba7b4e8ed1e9c8bc68289a5f8c23f88bdcdd708072618de35`,
README `84ee999e6b6838866514244f4075f7685f334d7a61e5f8065bd35c6432455d5b`, pre-review
evidence `7b2b5645123e806480b224f9c71c898ec184c15e37fa4cf5f4f1b19432470530`, artifact
above. NoGit/stagedbase; reviewershellattempt denied/no execution/retrybypass/edits/
independentrehash; executable/hashsuccessprimary-attributed. Primaryfinalfreezecheck
beforeupdate. PlatformN/A/no releaseapproval. NativeK6NOTRUN; latest81/149T102.8/
unit103.0 stillINCOMPLETE68cases/warnings/interactivityunknown. NextCore-only149native
gate TOTALTcomparison/fullsummary/warnings/interactivity; no unchangedreruns/skip/
raise100ms10000cap. Nativebars paused until satisfactory safefullcompletion/performance.

## K6 native86/149; oversizedApply123.4ms; K7 READY — 2026-11-07

User finalsummary86passed/0failedof149 INCOMPLETE/wall86561.3ms/max123.4ms,
case87unit2 [oversized Apply] fromunit1 [oversized fixture construction].86completed/
63uncompleted/87started,81nowPASSwithouttriggering100ms inthisrun; its scan2Tnotprovided,
don'tinventnewstage/speedupnumbers. Warningrecurrence/interactivity/build/hash unknown.
Atomicunit isrealCore.Apply onfullyconstructed50001-zeroextraarray, not grouped
callerwork. Existingcase87stilllaterdoesrealfailed-evidenceScan/stalehistoryasserts.

PrimarysettlesK7 conservativebudgetproof: boundedshallowplain-table search, #>=50000
ONLYhint, rawnextconfirm>=50000ownentries=>table+childrennecessarily>50000existing
globalvisits. Search/counterlimits/misses alwaysfallthroughtoFULLoldwalker/allguards;
no acceptancefromprobe, no sparse-lengthassumption/fixture-key/value specialcase.
Same50001input/149casebodies/realCoreCopyApplyScan/100ms10000cap unchanged. Thisis
fasterproductionrejectionofprovablyinvaliddata, notskippedstress or manufacturedPASS.
Budgeterrorcanprecedeothererrorsonmultiplyinvalidoverbudgetgraphs; explicitintentional
fail-closedprecedence, CoreApplygenericreason unchanged. Soundness/oracle/sparse/alias/
fallback/atomicitytests mandatory, no false-reject/newacceptance permitted.

Primarycurrent14K6sourcehashesmatched, exactpreeditbytespreserved
/tmp/opencode/craftarmy-k7-baseline. Writer Core/standalonerunner/README/evidence/
53-54taskstate only;11otherfiles/149SelfTests/all12priorartifactsfrozen. FullLua149/
K6744/K7supplement+diag23/Pythonchecks thenprimaryactualk7-review.diff/independentreview
beforeCore-only149nativegate. No currentrerun/nativecompletion/warnings/baracceptance.

## K7 NEW implementation delivery — pieces53→54 — 2026-11-07

**PARTIAL**:53 then54 delivered serially; no executable writer remainder or design
blocker. **Primary AFTER writer stop:** generate the actual preserved K6→K7 workspace
`docs/dashboard/k7-review.diff` from `/tmp/opencode/craftarmy-k7-baseline`, obtain
independent read-only review and persist findings BEFORE recommending any user update.
Platform review N/A; no Git/staged base, release or native acceptance implied.

### Necessary-rejection theorem and fallback proof

- Core58–88 adds PRIVATE `provesOverBudget`; its only root invocation is116 inside
  boundedData's existing single protected boundary119. The recursive `copy`95–114
  body is BYTE-UNCHANGED. Positive proof raises existing `data traversal limit`,
  without allocating/returning a partial copy. No public API/option/trusted mode.
- True is reachable ONLY at70 after raw `next` has returned50000 distinct own keys
  from ONE reachable plain table. A formerly valid graph would have to visit that
  table once plus all50000 child values: at least50001 visits, contradiction with
  the unchanged50000 bound. Invalid keys/values/cycles can only reject earlier, not
  make such a graph valid. No prefix/sibling/alias order is assumed. Graphs without
  such a table retain the exact accepted50000 boundary (root49999 children tested).
- `#v>=50000` is ONLY a hint; sparse length never proves entry count. Depth4 is
  tested for proof BEFORE stopping descent. Search is per-call, at most64 distinct
  plain tables,256 raw discovery entries and50001 GLOBAL candidate `next` probes
  (including nil terminators) across all hinted containers. A completed proof on
  the last allowed probe is sound; otherwise exhaustion returns false/unknown.
  Discovery nil terminators do not consume the entry budget. No new saved-data limit.
- Every miss/cap/depth/cycle/alias-search dedup returns to the ENTIRE unchanged
  old copy/check-only worker. Local visited state deduplicates ONLY search, not the
  alias-expanded validation count. No valid/invalid acceptance comes from the probe.
  It cannot raise intentionally except the root's proved budget error. Type/raw
  length/next/getmetatable/table-local bookkeeping only; no native predicate, API,
  timer, metamethod, callback, input mutation, retained graph or global cache.
- ANY non-nil metatable marker, INCLUDING false, skips that search subtree before
  length/next. The old guard remains unchanged (including its falsy-lock behavior),
  not silently strengthened. Numeric factory/public Finite/Integer, every unproven
  native check/order/literal0/count and all string/key/depth/visit guards are frozen.
- Intentional error-priority difference: a multiply-invalid graph with a guaranteed
  overbudget container may report budget before type/native/cycle failure. Tests
  assert BOTH old/new reject with no partial results/private native payload, NOT
  false exact error/native-argument parity for these positive proofs. Copy proof
  can use zero native calls. Whole Apply cannot: its initial full DB Open still
  occurs first, with original reason priority and exactly one final commit.
- Copy is still the real incoming-pack/evidenceFits sanitizer; the unchanged149
  case87 constructs all50001 elements, calls real Apply and later real failed-
  evidence Scan/stale-history checks. No fixture key/zero/ID special handling,
  skipped test, reduced size, mock Apply or extra heavy35-path latency Scan.

### Actual-byte preservation and standalone tests

Before editing, hashed/read actual workspace14 K6 sources and12 old artifacts,
retained actual workspace bytes at `/tmp/opencode/craftarmy-k7-writer-preedit`.
All14 match the last K6 full14 table. Primary external baseline NOT accessed;
no denied access/retry/bypass. Exact entire old Core35310bytes SHA256
`50105139dfe727aee52c2f3108a16041a9f2f0928e687a25867a9e13a780b001` recovered by
this read-only inverse, **PASS**:

1. Remove ONLY `-- Rejection-only lower bound:` through immediately before
   `-- Both modes walk` (private helper/comment).
2. Replace ONLY the five-line root-function/pcall block with the old single line
   `local ok, result = pcall(copy, value, 0)` at its original indentation.
3. Compare the ENTIRE resulting bytes with actual preedit Core, not new-vs-new.

Additional frozen blocks, explicitly compared against actual preedit bytes:

```text
65664a25a4d241dacc3df009490a6d109f0cbdfc0daeea1fafd82e66cf9f7b75  recursive copy body (828 bytes)
4301061720eaeab4c01894876a923bc1c8b36752b45315d9cfcc5cdfcc6c07b2  protected numeric factory/comment (1044 bytes)
c3ce6c53f6cdeb0e8b9e818f42a3c2172bd2fe2aa7c6ef13e4170e9505a068cf  Copy API through END Core (31836 bytes)
c6f2349120d5794ba7b4e8ed1e9c8bc68289a5f8c23f88bdcdd708072618de35  ENTIRE old K6 standalone runner/prefix (15453 bytes)
c2d0b1f8cb27c92cc458272c209f363088aa8a59e964b9613acaed16932f23d3  ENTIRE SelfTests.lua149 (268959 bytes)
```

Thus public CopyAPI/numeric guards, observation/typed/owned merge, candidateMirror,
Open/Apply/Archive bodies, alias-safe final proposal and single real commit are
BYTE-FROZEN. All149 cases/assertions/construction/order/checkpoints/K4 instrumentation/
100ms/10000cap unchanged. Frozen oldWalker ENTIRE body also compared to actual preedit
boundedData after removing ONLY the already-reviewed K6 numeric plumbing and
indentation: SHA256 `db438e42fa67d0e367c724903609cf7a0e3e9f0e40c855ba330a7c5c27deb755`.

Standalone-only K7 block appended AFTER entire old K6 prefix; fresh Core environments,
copied math/fake predicates and frozen oldWalker reused. Separate K7 snapshot uses
raw next/rawget for identity-aware cyclic/metatable-safe immutability checks. Host
math/native, current149 namespace and global clock never patched. Tests cover:

-50000/50001 own-child necessary rejection, root49999 exact-boundary acceptance;
 depth4 positive proof/depth5 full-validator fallback; sparse retained border
 #>=50000 with18000 actual entries MUST accept; two such depth4 tables accept.
- GLOBAL50001 candidate cap across THREE holey tables falls back: exactly50001
 candidate probes plus6 discovery entries. Repeated hinted alias counted only once
 in search (18001 probes), but full alias-expanded graph still rejects.
-64-table and256-entry exhaustion with valid AND invalid inputs; exact bounded
 trace counts; full old oracle value/error/native-argument sequence/count parity
 for EVERY unproven/valid case. No random pairs-order reachability assumptions:
 single-child proof chains, symmetric candidate/fanout fixtures.
- Valid aliases expand independently; cycles defer; ordinary/locked/falsy-locked
 metatables skip probe, no __len/__pairs/__index invocation. Unproven throwing
 native sanitizes as before. Dual-invalid type/cycle/native-fault overbudget inputs
 all reject (intentional budget-first class), no partial output/native payload.
- Positive real Core.Copy proof performs0 native calls,1 outer pcall; old oracle
 walks guarded prefix. Real valid Apply/Open retains character/identity/nested typed
 value ownership after caller mutation. Real Apply with same full50001 payload
 returns `Invalid scan data`, fully validates DB first, preserves all references/
 values with no commit. Malformed schema priority and DB native-fault payload
 sanitation/no commit retained. Real oversized Open fails without partial output
 or input mutation. Unchanged149 and744 also retain assembled proposal/alias guards.

### Commands actually run and remaining gates

Inspected BOTH complete Python scripts, both original standalone runners and new
tests before execution. `/usr/bin/lua5.1` already installed, Lua5.1.5. RAN:

- `lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-k7-dashboard.log 2>&1`:
  exit0, **149 actual PASS lines,0FAIL,noINCOMPLETE**;
  `149 passed; 0 failed (pure fixtures only)`;
  `K6 isolated supplement: 744 checks; 0 failed (standalone fake predicates, not native performance/API evidence)`;
  `K7 conservative proof supplement: 565 checks; 0 failed (standalone soundness, not native performance/API evidence)`.
  First run538/0 also passed, then added hinted-alias/nested ownership/DB-input
  immutability regressions and reran entire command for final565/0. Case81 correctly
  says `scan2 timings unavailable (clock missing)`; no fabricated native stage.
- `lua5.1 tests/run.lua`: exit0,
  `23/23 pure fixture cases passed (not live-client evidence)`.
- `python3 tools/check_diagnostics.py`: PASS exit0,9 required files, exact TOC/
  order/paths/metadata/one SavedVariables; structural only.
- `python3 tools/check_dashboard.py`: PASS exit0,15 required files/exact9Lua/order/
  metadata/isolatedDB/no dependencies;23Markdown/71links/eight diagnostic hashes
  unchanged. Both Python commands rerun after final documentation.
- Inline read-only Python (`python3 - <<'PY' … PY`) whole-Core inverse/frozen
  copy/factory/CopyAPI-to-EOF, ENTIRE K6 runner prefix/SelfTests, frozen old oracle,
  preedit14 recorded-hash parity/current14/exact3delta11frozen/all12oldartifacts/
  no-newfiles/all unassigned bytes/actual output count proof: **PASS**. No baseline
  or local fixture failures; no failed validation attempt in this run.
- **NOT RUN:** independent K7 review; native K7 full149 scheduling/100ms performance/
  stages/warnings/interactivity/real API/DB/UI/bars. Local fake predicates are NOT
  client API/performance evidence. Native full-safe-completion gate remains open.

ONLY Core/standalone runner/README/evidence and53/54/currentstate/NEWdelivery in
TASKS edited. PLAN/Q03/AGENTS, all other repo files and12 old review artifacts
byte-frozen; no new repository file/child/feature/dependency/install/Collector or
measurement/clock/threshold change, real game/DB access, profiler reset, CVar/error-
handler change, Git/release/publication/archival. Primary owns later k7-review.diff.

Current14 freeze, ONLY Core/runner/README delta,11 frozen vs actual K6:

```text
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
cfb993b10e64ed9561d6cecfefbd2b5354e0d32c1c683ce79d4a469a4990607b  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
4fa5c2d0817be04c55eada64934f70f680cbc2c6d0a83943cf4411153ac9e60c  CraftArmy/Collectors.lua
214550def55ff05025c933fe1375cdd969cce954736dbd87403e0e9d6ba43f89  CraftArmy/KnowledgeCheck.lua
a9116a628a7168ec6b3cf0a7ef9be4878350da8cf87a15b39b16ca600b7d38f0  CraftArmy/ViewModel.lua
7ed773909586f1df96cc7477715d42f4688f89aafe847ab973e1db6236f60133  CraftArmy/Dashboard.lua
c2d0b1f8cb27c92cc458272c209f363088aa8a59e964b9613acaed16932f23d3  CraftArmy/SelfTests.lua
b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3  CraftArmy/Commands.lua
1a3585d83cb61171b0346bfa55319ce9fa1e8f3aea35275f3dae11ea351a8fa8  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
df5979a1c3300060d022f320c2e1b2daef712501b4804d2c0a6fd7b992f7a071  docs/dashboard/README.md
7f9e414fddc43c1533b5b05f0b09f39723e6f579f8506b3ab20b0162b22f23cb  docs/dashboard/schema.md
```

Core36946bytes/runner27688bytes/README54573bytes. Final evidence hash is in TASKS
K7 NEW delivery, avoiding self-reference. Evidence changes ONLY this appended section
and current-gate line4; reversing these recovers entire preedit361255bytes SHA256
`1592bed3fa7e411a45ca05c021cf6b00b44954840f64da644e8a16d6102e6bdb`.
All12 old artifacts match preedit; K6 current artifact remains
`fae6544aa7a8a6b070757addc916bd3460ec226d21d59eefb8b92a68affc7a1e`.

README after-independent-review-only already-on-K6 quit/backup/replace ONLY Core.lua;
preserve SelfTests149/ALL other modules/DB/SavedVariables/diagnostics, reload/outcombat
149selftest. Share finalsummary/warnings/interactivity and, if available,81scan2 line
for new T (latest summary did NOT provide it). No unchangedrerun/skip/filter/reorder/
raise100ms10000cap/autoresume. Latest native STILL86/149INCOMPLETE, oversizedApply
123.4ms/wall86561.3ms;63uncompleted/87started,81passeslimit/Tnotprovided. Warning
recurrence/interactivity unknown. Native bars paused pending satisfactory safe full
completion/performance/warning evidence. No speedup/native<100ms or release claim.

## K7 primary comparison/local re-execution/independent review — 2026-11-07

ActualpreservedK6→K7 `docs/dashboard/k7-review.diff`,377lines/22356bytes/SHA256
`a5b057e48742d04cbf9a20ffef0ede28fec9f75c561e969309022cbeefb88ba6` primarygenerated
afterwriterstop. Full14/exact3deltas11frozen/12oldartifacts/evidencedigest verified;
wholeCoreinverse removesONLYprobe/rootplumbing andrecoversactualK6bytes, entire149
SelfTests/K6standaloneprefix bytefrozen. PrimaryRAN149PASS0FAIL/noINCOMPLETE+K6744/
K7565checks exit0 (fulloutput /tmp/opencode/craftarmy-k7-primary-dashboard.log),
diagnostics23/23PASSexit0/bothPythonchecksPASS15paths/23docs71links/eightdiagnostichashes/
separate9paths. Actualcases executed, notjustcounted; no nativeperformanceclaim.

Verifier COMPLETE/staticdesign **PASS**, native/fullperformance **INCOMPLETE**, no
blockers. Fullactualdiff/currentcode/fixtures/contract/docsread. Owncount>=50000+table
proofsound, #onlyhint; caps/misses deferfullvalidator, aliases/cycles/metatables can't
accept/rejectmerelyfromsearchtruncation. Localinput-preservingprobe/oldouterpcall,
intentionalbudget-firsterrors onlyalready-invalidgraphs. DB-first/ownership/alias
proposal/solecommit retained. Sparse/cap/fallback/oracle/metamethod/atomicitytests
meaningful, noiteration-orderreachabilityassumptions. Case87same50001/realApplyScan/
stalehistoryassertions remain. No fixtureworkloadshrink or thresholdchange.

ReviewedCore `cfb993b10e64ed9561d6cecfefbd2b5354e0d32c1c683ce79d4a469a4990607b`,
runner `1a3585d83cb61171b0346bfa55319ce9fa1e8f3aea35275f3dae11ea351a8fa8`,
README `df5979a1c3300060d022f320c2e1b2daef712501b4804d2c0a6fd7b992f7a071`, pre-review
evidence `f07991533addfe9d4b4cb5872994de82bbd3ba357433a2d3ecff5f131611f417`, artifact
above. NoGit/stagedbase; reviewershell deniedbeforeexec/no tests/rehash/retrybypass/
edits; executable/hashsuccessprimary-attributed. Primaryfinalfreezecheckbeforeupdate.
PlatformN/A/no releaseapproval. NativeK7NOTRUN/latest86/149123.4ms stillINCOMPLETE63
cases,81passesbutT/warnings/interactivityunknown. NextCore-only149nativegate/full
summary+warnings/interactivity/81scan2ifavailable; nativebars paused untilsafefullfinish.

## Validation policy changed by explicit user agreement — 2026-11-07

Latestuser result INCOMPLETE87passed/0failedof149, case88unit2 [K2 next rank boundary]
134.4ms/wall77323.9ms.87completedPASS/62uncompleted(88started), notfull149PASS or
assertionfailure. Case87oversizedApply/historychecks completed inthisrun. No new81
scan2stage numbers/warningrecurrence/interactivity/build/installedhash reported.

User questions repeated timing-only patch/retest effort; primary recommends retaining
all localcorrectness/stress tests, retainingclient100ms safety stop andaccurate
INCOMPLETE status, but usingfocusednativeAPI/snapshot/normal-use checks instead of
making fullstresscompletion undercutoff a blanketprerequisitefornativeprogress.
User explicitly agrees. This replaces the earlier full-safe-suite-before-bars gate;
no historicalresult relabeledPASS, no case88patch/skip/filter/reorder/capraise/test
reduction. All149addonfixtures/K6744/K7565/diag23 localPASS evidence retained. Local
Lua isn'tproof ofWoW APIs/numericbehavior/normal-use performance; those remain gates.

Primary recordsPLAN/TASKSV01/AGENTS/README policy, notanimplementation change. Current
reviewedaddon requiresno newfileupdate; no writer/sourcepatch/newruntime/install/
gameAPI/realDB/Git/release action. Firstuserround ownreadyunstagedMidnightInscription
outcombat `/ca scan` then `/ca`, currentfourbarpoints/capacity/unspent/nativecomparison
whereavailable/onehover/readability andresponsiveness/warnings. Do notforcehistorical
264/870 or estimate unavailableUI totals. No crafting/buying/unlock/spend/realdataupload.
Afterfirstround satisfactory coordinateclosedcontext preservation thenreload historical
values; those aren't blanketproof ofeverytransientAPI failure. Anyactual mismatch,
freeze/executionwarning/load/DBdisabled error stopsfocusedtesting forinvestigation.

No broadernativeAPI/requiredsemantics/othersevenidentitymappings/guide/fullT02/release
acceptance inferred. Existingfullselfteststillavailablewithunchanged100ms10000caps,
but no repeatedrun requestedmerelytoclearcase88. Planningmaintenance/archival notpart
ofthisapproval; append-onlyquestion/evidence histories retained. Currentfocusednative
status READY/PENDING observations, notpassed. Primary verifies executablefiles remain
reviewed before advancing; documentationchanges don'tmanufactureexecutionevidence.

## V01 Round1 — native tree agreement and normal-use responsiveness — 2026-11-07

User reports: “0/270, 50/70, 214/270, 0/260. All values line up with native UI values.
Game stayed responsive. Tooltips all work thought they are very verbose and filled
with debug text.”

This establishes user-observed agreement for these four current tree bars and
responsive normal use in this round, with functional tooltips. Supplied order is
preserved; labels/build/installed hashes were not newly reported. Sum264/870 is a
derived current total, not a required balance or proof of future/all-rank costs.

Tooltip verbosity/debug text is an unresolved usability issue, not a functional
failure, authorized cleanup, or delivered fix. Current Unspent KP/native comparison
and explicit error/execution-warning recurrence confirmation were not supplied.
Do not infer warning resolution from responsiveness. Primary asks these gaps before
moving to closed-context preservation, then reload/last-observed persistence.

Round1 remains partial; Round2/3 pending. Full native selftest remains INCOMPLETE
87passed/0failedof149 at case88unit2 134.4ms. No rerun/timing patch/source update,
full-suite PASS, broader native API/other-profession/fullT02/release acceptance or
new local execution result is claimed by this documentation-only evidence update.

## V01 Round1 follow-up — Unspent KP/native match and no normal-use errors — 2026-11-07

User: “Unspent KP shows 0 which matches native UI. There were no errors during
normal sue.” This answers the pending follow-up: Unspent KP0/native agreement and
no errors reported during this normal-use round. It does not establish permanent
resolution or causality of the historical execution-limit warning.

Round1 is satisfactory for progression to Round2 closed-context snapshot preservation,
then Round3 reload persistence if satisfactory. Neither preservation check is yet
observed. Tooltip verbosity/debug text remains an unresolved usability finding with
no cleanup authorized. Full native selftest remains INCOMPLETE87/149; no source update,
rerun, full native/API/dashboard acceptance or new local execution result claimed.

## V01 Round2 — closed-window values/time preservation — 2026-11-07

User: “The four bars and unspent kp remain intact. The last updated was not changed.”
This follows the requested closed-profession-window check. Prior values survived
without Last Updated advancing. Explicit stale/last-observed wording and closed-scan
message were not reported; neither is inferred. This is bounded preservation evidence,
not proof of every transient API-failure path.

Round2 is satisfactory to proceed to Round3: `/reload` with profession closed, then
`/ca` before reopening or scanning. Check persisted values and original observation
time, allowing relative age to increase rather than appearing freshly observed.
Reload evidence is pending. Tooltip usability remains unresolved; full native selftest
remains INCOMPLETE87/149. No source/test update, rerun, full native/API/dashboard
acceptance or new local execution result claimed.

## V01 Round3 — reload persistence; scoped sequence complete — 2026-11-07

User: “All the data remained as expected (including Last Updated).” Reported in
response to `/reload` with profession closed, then `/ca` before reopening or scanning.
This supports persisted saved data and original observation time after reload.

V01 three-round focused sequence is complete for reported outcomes on this character:
four native-matching tree bars and Unspent KP0, responsive normal use/no reported
errors, closed-context values/time preservation, and reload persistence. Explicit
stale wording/closed-scan message remain unconfirmed; no all-path transient API-failure
proof or permanent historical-warning resolution claimed.

Tooltip verbosity/debug text remains unresolved, not an authorized or delivered fix.
Other profession mappings/required-field semantics/broader dashboard acceptance/guides
remain open. Full native selftest remains INCOMPLETE87/149; no rerun, limit/workload
change, source update, new local execution result or release approval. No further
V01 round requested; subsequent work requires its own scope/authorization.

## U01 local delivery — concise normal hovers / Shift diagnostics — 2026-11-08

Status **PARTIAL**: pieces55→57 local implementation/checks complete, independent
verification and focused native hover observation pending. User-approved presentation
only; primary owns comparison/review/acceptance. No native fix/performance/API/release
acceptance claimed. V01's three reported scoped rounds remain complete; the full native
selftest remains honestly **INCOMPLETE87/149**, case88unit2 at134.4ms/wall77323.9ms.
No new native suite run, timing chase, changed limits/workloads, game action or install.

Changed files only: `CraftArmy/ViewModel.lua`, `CraftArmy/Dashboard.lua`,
`CraftArmy/SelfTests.lua`, `docs/dashboard/README.md`, append-only this evidence,
U01/current run state/NEW delivery in `TASKS.md`. No new repository files, children,
Git operations, dependencies or release operations. Platform review N/A per contract.

### Presentation and regression coverage

- Added separate gear/tree `summaryTooltip` and row `cellTooltips[V.index]`, reading
  already-present values/states. Original `V.Field`, Gear/Tool diagnostics and treeDetail
  bodies are byte-identical. No table values/ratios/sorts/known-count/attention thresholds
  or snapshot/session mutation. Archived/not-observed, saved, current guarded and retained
  stale values remain distinct; summary ages use observation/scan, not attempt/retirement.
- Normal identity/numeric/status/Last Updated hovers are focused, no row dump. Tool stats
  retain full names and every observed amount (32 unknown-key amounts also tested), one
  base/enchant attribution caveat; unknown keys say `Unknown stat`. Enchant distinguishes
  confirmed absence, unknown/unmapped and no-tool/not-applicable, with at most2 nonempty
  observed text lines plus overflow, never invented amount/rank. Gear rarity and crafted
  quality remain independent. Observed0 is not unknown or empty.
- Tree summaries retain last known totals/name on refresh failure, never promote invalid
  current raw ranks; known zero capacity remains known in the summary without changing
  the existing bar ratio. At most6 individual branch lines in original traversal order,
  ordinal names, truthful locks/unknown availability, overflow count, missing-observation
  explanation, and native `Future point costs are unverified.` caveat. Default addon line
  budget16 includes the diagnostic hint; full diagnostics are not truncated.
- Shift must be held BEFORE hover entry. Protected callable `env.IsShiftKeyDown` accepts
  only boolean true; absent/false/throw/nonboolean/noncallable safely stays concise.
  Legacy row/tool/tree/status evidence and exact timestamps remain on Shift. Raw unknown
  and blocking status still appears normally when it is the meaningful failure explanation.
  No modifier event/poll/settings/command added.
- Native hyperlink/third-party content is unchanged and only attached for A1/A2/Tool in
  either mode, never Stat/Enchant. ClearLines→owner→hyperlink→addon lines, sanitization of
  addon text only, leave-hide, header transition and repeated hover/rebuild no-accumulation
  are tested through real mocked UI OnEnter handlers. Source DB/session/reference equality
  checks cover both routes; mocks are not evidence of target-client behavior.

### Checks actually run

After inspecting the runners/checkers, installed `/usr/bin/lua5.1` was used, no installs
or shims. Final commands all exit0:

```text
lua5.1 tests/dashboard.lua
  164 passed; 0 failed; no INCOMPLETE
  K6 isolated supplement: 744 checks; 0 failed
  K7 conservative proof supplement: 565 checks; 0 failed
lua5.1 tests/run.lua
  23/23 pure fixture cases passed
python3 tools/check_dashboard.py
  PASS 15 required files; 23 Markdown files; 71 local links; 8 diagnostic hashes unchanged
python3 tools/check_diagnostics.py
  PASS 9 required files; TOC/order/metadata/SavedVariables structure
```

Actual addon count is **164 =149 historical retained +15 new U01 cases**, not149.
The scan2 fixture correctly reports `scan2 timings unavailable (clock missing)` locally;
native timing is NOT RUN/unavailable, not0ms or performance PASS. WoW hover readability,
Shift handling and native item integration on these changes are NOT RUN. Independent
verification NOT RUN by the writer. Initial authoring runs failed new fixtures only
(nonconforming unknown stat key, missing test-local ViewModel binding, invalid incomplete
tree inserted through typed DB validation); fixtures were corrected, original assertions
and production validators were not relaxed. All149 old cases passed in those runs.

### Byte preservation / source freeze

Before editing, the writer retained all56 current workspace files and their SHA256 in
`/tmp/opencode/craftarmy-u01-writer-preedit` plus `writer-manifest.json`. These bytes already
include approved primary PLAN/TASKS/Q05 contract edits. A single read of the primary
`/tmp/opencode/craftarmy-u01-baseline/manifest.json` was permission-denied
(`external_directory`); no retry/bypass. Primary must compare its exact55-file pre-contract
baseline after writer stop, accounting for its own approved planning edits.

Read-only Python preservation check PASS: remove the single marked `-- U01 BEGIN:` through
`-- U01 END` additive block before `function Tests.Run(cases)` and ONLY the3 lines matching
`env.IsShiftKeyDown=function() return true end -- U01 legacy diagnostic fixture`.
The reconstructed entire SelfTests file equals all268959 original bytes, SHA256
`c2d0b1f8cb27c92cc458272c209f363088aa8a59e964b9613acaed16932f23d3`.
The3 additions are only in R5 friendly/raw status, R5 native-item/full evidence and R6
Enchant/full evidence cases. All149 case bodies/assertions/order/helpers/workload sizes/
checkpoints/100ms/10000-step runner remain intact under that exact inverse.

Entire529-line `tests/dashboard.lua` byte-frozen, including full K6 prefix/oracle and K7
supplement. Its SHA256 is below. No files added/deleted; exactly6 owned files changed,
other50 current files frozen, including PLAN/Q05, all other production/data/schema/
commands/TOC, both runners/checkers, diagnostics and all prior artifacts. Evidence old
bytes retained as exact prefix (append-only). Final source/README hashes:

```text
e29904163fd6e58d780348ae07d43e9b145d1a29fd4b756ff1698a00005f3abe  CraftArmy/ViewModel.lua
1a23bb8e7486712d388ec2ee2080107559544ba6daa32c62446eb4294132b8f0  CraftArmy/Dashboard.lua
ef1e484eee884c4d8d60bd50e4b1c44328b3d45b2224f7ebd75cd607bbd971ca  CraftArmy/SelfTests.lua
a138ea3c677f093513b942a4017ec9d756374bed15d78ccc11407acfaa6dac03  docs/dashboard/README.md
1a3585d83cb61171b0346bfa55319ce9fa1e8f3aea35275f3dae11ea351a8fa8  tests/dashboard.lua (FROZEN)
```

Resume **primary**: compare exact preserved baseline/current files, rerun approved checks,
generate the new comparison artifact after writer stop, obtain independent read-only
review and persist findings BEFORE recommending the review-gated three-file update.
Then coordinate a concise normal/Shift hover and unknown/stale usability observation
per README, not V01 restart/full-native selftest. No executable writer remainder/design
blocker; broader T02/mappings/semantics/guides/release remain unaccepted.

## U01 primary exact comparison/local re-run/independent review — 2026-11-08

Primary compared all55 preserved pre-contract files: exact8intended deltas including
primaryPLAN/Q05 and writer's6owned files,47unchanged; evidence append-only. All
unrelated addon modules/standalone runner/diagnostics/checkers/priorartifacts frozen.
WholeSelfTests inverse removing only3authorized modifier lines+newtestblock recovers
all original149case bytes;15new cases produce164actual definitions. Original V.Field/
Gear/Tool/treeDetail prefix unchanged. Four-file exact comparison
`docs/dashboard/u01-review.diff`661lines42321bytes SHA256
`1297db6351e807446d156106eca206b183b83b38ec614f73aa5babe087b71e63`.

Primary RAN all approved local commands: dashboard164actualPASSlines/0FAIL/noINCOMPLETE,
744K6/565K7 all0fail/exit0, diagnostics23/23PASSexit0, bothPythonPASS15/9paths23docs71
links/eightdiagnostic hashes. Complete dashboard log
`/tmp/opencode/craftarmy-u01-primary-dashboard.log`. Native clock unavailable, not0ms
or timingPASS. Reviewed3sources/README/artifact rehashed unchanged after reviewerstop.

Independent verifier COMPLETE; **static acceptance PASS/no blockers**, native usability
**INCOMPLETE**. Full diff/implementation/newassertions/instructions inspected. Separate
summaries preserve state/ages/observed amounts/warnings/unknown distinctions/tree caveat
and opt-in original diagnostics. Gear-only native links/protected modifier fallback/
clear-owner-link-sanitization-hide routing follow contract.15new meaningful UI-handler
cases;32stats fit logical line bound, actual wrapped readability remains user evidence.
Reviewer shell/log access denied/no bypass/retry/edits; all hash/execution evidence
above primary-attributed. Platform reviewN/A, no release approval.

Reviewed source identities match U01 delivery above. Reviewed delivery README hash
`a138ea3c677f093513b942a4017ec9d756374bed15d78ccc11407acfaa6dac03`; primary subsequently
changes only its review-gate text, not runtime behavior. Writerpre-review evidencehash
`0babb28c67a870a423f5470d3727681e48a1e863670c4e0a0a31a1bfba0f32ad` is historical.

Next primary/user: quit/back up, update ONLYViewModel/Dashboard/SelfTests, then one
focused existing-data normal-vs-Shift-before-hover usability check. Native readability/
modifier/nativeintegration not yet observed. No fullselftest rerun/V01 restart/capture/
gameplay/reset/sourceperformance change or broader T02/API/release acceptance.

## U02 local delivery — optional branch names and silent normal value cells — 2026-11-08

**PARTIAL: pieces58–60 local complete; independent review and native U02 checks
INCOMPLETE.** User's latest U01 feedback says tooltips are better and normal/Shift
hovers differ; that is scoped U01 observation, not a U02 name/API/hover PASS. Full native
selftest remains historical **INCOMPLETE87/149**, case88unit2 134.4ms/wall77323.9ms;
not rerun. Platform N/A. No installs, dependencies, new implementation files, children,
Git operations, game/API calls on the host, gameplay, data reset or release performed.

### Label provenance and presentation

- Existing guarded GetEntryInfo reads project optional valid definitionID without
  changing metadataComplete. Name selection matches only the projected node's active
  entryID against its known unlock/spend IDs; no extra entry reads or arbitrary fallback.
  At most one guarded GetDefinitionInfo(definitionID) and one C_Spell.GetSpellName(spellID)
  per path, within the existing64paths/tree and8trees. Plain definition/rawget fields,
  valid integer IDs, overrideName precedence, spell fallback, controls/pipes→spaces,
  trim and1..256byte acceptance; long names are rejected whole, never UTF-8-truncated.
- Optional p.name persists through the unchanged Knowledge full-path copy and schema1
  pipeline. Missing/nil/throwing/malformed label data leaves names absent, not numeric
  failure, and stores no API error payload. No hover/offline API reads, name cache,
  timer, locale migration, new rank/cost calls or accounting policy changes.
  Core's ONLY change is the two-line optional path-name nonblank/type/length/control/
  pipe validator. All other Core bytes are unchanged; nameless snapshots still open.
- Normal tree tooltips are all captured paths in original traversal order, each
  `name: individual purchased/capacity`, including root/locked paths. No ordinal/ID
  labels, duplicated heading/aggregate, routine age/prose/caveat or Shift hint.
  Missing names say Unknown branch; ineligible numeric data stays ?/? with a short
  explanation. At most64path lines plus one short exceptional footer (Stale data or
  Archived; combined missing explanation if needed). Failed numeric refresh retains
  the whole old named tree and points, never newer raw labels. A successful numeric
  refresh with failed labels uses Unknown branch, not cached old names.
- Knowledge-background overview uses explicit model aggregateText/name rather than
  positional summary[2]. Remaining saved summary helper says `Observed <age> ago.`;
  legacy diagnostic state.text and full treeDetail remain byte-identical.
- Moxie/Unspent/LastUpdated/Stat/Enchant normal VALUE-cell OnEnter clears/hides and
  returns without owner/AddLine/Show/hyperlink/hint. Protected callable modifier is
  sampled once; only true enables existing full Shift diagnostics. Missing/throwing/
  nonboolean support safely stays normal/silent. Mouse/selection/leave and header
  hovers remain. Native/third-party tooltips stay A1/A2/Tool only, with unchanged clear/
  owner/link/add/show order and PlainTooltip applied only to addon lines. Other normal
  hints, table values/age/ratios/priority/attention logic are untouched.

Static name-API provenance is the primary's pinned297d7 TalentButtonBase activeEntry,
TalentDisplay entry.definitionID/GetName overrideName/spellID, SharedTraits definitions
and Spell.GetSpellName evidence in Q03. Fixture results below do NOT prove native API
availability, returned labels, target numeric semantics, responsiveness or readability.

### Executed validation and test preservation

Inspected both Python checkers and complete approved Lua runners before execution.
Already-installed `/usr/bin/lua5.1` used; no shim/math/profiler/clock changes.

```text
lua5.1 tests/dashboard.lua
  181 actual PASS lines; 181 passed; 0 failed; no INCOMPLETE; exit0
  K6 isolated supplement:744checks/0failed
  K7 conservative proof supplement:565checks/0failed
lua5.1 tests/run.lua
  23/23 pure fixture cases passed; exit0
python3 tools/check_dashboard.py
  PASS15required paths; exact TOC/order/metadata; isolated DB/no dependencies
  PASS23Markdown files/71local links/anchors/eight diagnostic hashes unchanged; exit0
python3 tools/check_diagnostics.py
  PASS9required files/exact TOC order/paths/metadata/one SavedVariables; exit0
```

Complete dashboard log `/tmp/opencode/craftarmy-u02-dashboard.log`; interim run before
the final endpoint case was180PASS0FAIL+744/565, also exit0. No executed fixture failure
occurred in this run. Scan2 output correctly says `timings unavailable (clock missing)`;
not0ms or performance PASS. Native U02, full native suite and independent review NOT RUN.

Actual definitions **181 =149original +15U01 +17U02**. No cases deleted/reordered/
filtered; standalone529-line runner entirely byte-frozen (744/565 supplements included).
All pre-U01 bytes and entire Tests.Run tail match pre-edit. Removing the marked U01
and U02 blocks and ONLY the3 U01 local Shift=true fixture lines reconstructs all268959
original bytes, SHA256 `c2d0b1f8cb27c92cc458272c209f363088aa8a59e964b9613acaed16932f23d3`.
All149 assertions/stress sizes/checkpoints/100ms/10000-step caps retained. Only U01
default expectations in cases3–10,13–15 adapted (case9 renamed for superseded ordinal/
six-line prose); cases1/2/11/12 unchanged. Helper explicitly asserts real handler
silence then checks hidden normal-summary semantics directly, never claims rendering.
Diagnostic/ownership/numeric/age/state assertions remain.17 new cases cover:

- active unlock/spend argument IDs,70existing entry reads/35definition reads/no extras;
  missing/nonmatching/malformed active entries, absent active definition/no fallback;
- override precedence, spell fallback, valid ID endpoints1/MAX, all invalid ID types/
  bounds, absent/nil/throw/malformed APIs/definition tables/getters/names, controls/pipes/
  blank/256/257bytes and multibyte boundaries; full raw/numeric metadata parity;
- bounded8×64path collection:1024existing entry reads/512definition/512spell reads,
  no duplicate heavy Scan stress added;
- typed name rejection atomically preserving DB, invalid active/archive Open rejection,
  old nameless Open, Copy/Evaluate/Apply/Open/reload/archive and returned-copy ownership;
- real failed numeric refresh retains old names/points, label-only failure fresh numbers
  with Unknown branch/no history fallback; real localized duplicate names/disjoint IDs,
  root10/10 versus aggregate50/70, all>6/all64paths/locked0/Y/missing labels/unknown totals,
  stale/archive single footer, unchanged full diagnostic caveats;
- all five silent normal handlers clear/hide an existing native gear tooltip without
  owner/add/show/link, then exact original Shift arrays; selection/mouse/leave, protected
  modifier missing/error/nonboolean fallback and once-per-hover calls, no collection on
  hover or DB/session/diagnostic-array/other-addon mutation. Existing U01 keeps other
  columns/native gear/header/status coverage.

### Exact preservation / source freeze

Actual57-file pre-edit workspace preserved at `/tmp/opencode/craftarmy-u02-writer-preedit`
with manifest.json (includes pre-existing hidden `.opencode/agents/implementer.md`).
Primary56-file `/tmp/opencode/craftarmy-u02-baseline/manifest.json` was readable: its ONLY
initial differences versus writer start were primary PLAN/TASKS/Q03/Q05 contracted edits.
No denied access/retry/bypass. Exactly8owned writer deltas,49current files byte-frozen;
no add/delete. Knowledge/KnowledgeCheck/Data/Commands/TOC/schema/standalone runner/both
checkers/all diagnostics/ALL14prior review artifacts/primary planning+question files
unchanged versus writer start. Evidence old5895lines remain exact prefix. Core guard-only
whole-byte inverse and ViewModel original V.Field/Gear/Tool/treeDetail prefix PASS.
Six implementation/README files' calculated unified comparison (a/b repository-relative
headers, no artifact created) is899lines/59349bytes SHA256
`004084b5f8da7ffa6b86842eee939f9bf78f335809c9576e7cc2cfc770eeb872`.
Primary owns generating/reviewing its actual u02-review.diff AFTER writer stop.

Current14-file source/test/check/doc freeze (evidence hash recorded separately in TASKS):

```text
63152f75360ee7f035e4c903557675c3ccd8a4903e942af64f1af2193119f7b4  CraftArmy/Core.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
c1abaa639809ed2db47b84524512bb967ec573aa225eb8e0b1063c0dc1f79609  CraftArmy/Collectors.lua
214550def55ff05025c933fe1375cdd969cce954736dbd87403e0e9d6ba43f89  CraftArmy/KnowledgeCheck.lua
19d1860789752ac0a2c4c7b301a06fc51c047701907005dcd2735d2aada5a47f  CraftArmy/ViewModel.lua
cdff5b2d4c315830dcbff2c4d34575dcc84194bfcd78222cddfb2dd2659a140d  CraftArmy/Dashboard.lua
08327b6f6435d6a8bddc7007b6a2466ff2fabf8d8556f95868beca6746009025  CraftArmy/SelfTests.lua
b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3  CraftArmy/Commands.lua
382d60d2cb7d6e36584ffaaf8d34ccb0fff9cf5c78bb4203f85268d105094e67  CraftArmy/CraftArmy.toc
1a3585d83cb61171b0346bfa55319ce9fa1e8f3aea35275f3dae11ea351a8fa8  tests/dashboard.lua
610a0c42aded6b470ea9b7149d986876f780171efd000921808c3b29b81669db  tools/check_dashboard.py
f4dc22b970bc64727dd38c4ddeb465acbfd04c3848303d2c3ec0ed5bf39f9c91  docs/dashboard/README.md
7f9e414fddc43c1533b5b05f0b09f39723e6f579f8506b3ab20b0162b22f23cb  docs/dashboard/schema.md
```

Resume **primary**: compare exact primary baseline/current bytes accounting for its own
PLAN/TASKS/Q03/Q05 edits, rerun approved checks, generate new u02-review.diff, obtain
independent read-only review and persist findings BEFORE user update advice. Then only
the five reviewed Lua files after quit/backup per README; one own-ready unstaged
Inscription `/ca scan` to populate optional names, native name/X/Y comparison and five
silent normal cells/Shift access/unchanged native gear. No full native selftest, large
capture, gameplay/reset or V01 restart. No executable writer remainder/design blocker;
broader T02/API/mapping/required-field/guides/acceptance/release gates remain open.

## U02 primary comparison/local re-run/independent review — 2026-11-08

Primary exact56file pre-U02 comparison:11intended deltas(5sources/README/evidence/TASKS
+primaryPLAN/Q03/Q05),45baselinefiles frozen. Evidence append-only; all unrelated
modules/Knowledge/accounting/standalone runner/checkers/diagnostics/priorartifacts
unchanged. Coreoptionalname two-lineguard removal recovers exactpriorCore. Wholeold149
SelfTests inverse removes U01/U02 additiveblocks+3modifierfixturelines and recovers
original268959bytes/SHA256 c2d0b1f8cb27c92cc458272c209f363088aa8a59e964b9613acaed16932f23d3.
U01adaptations concern superseded normal display; numerical/state/diagnostic assertions
retained, hidden summary assertions explicitly not rendering.17U02newcases=>181actual.
Actual six-file comparison `docs/dashboard/u02-review.diff`906lines60548bytes SHA256
`65079a3a532384d4eb870e68ebb474e9b026f60c8e4f7dc93d694b55d4db385b`.

Primary RAN approvedcommands all exit0: full dashboard181actualPASSlines/0FAIL/
noINCOMPLETE,744K6/565K7 all0fail; diagnostics23/23PASS; bothPythonPASS15/9paths23docs71
links/eightdiagnostic hashes. Dashboard log
`/tmp/opencode/craftarmy-u02-primary-dashboard.log`. Native clock unavailable, not0/
performancePASS. Reviewed5sources/README/artifact rehashed unchanged after reviewerstop.

Independent verifier COMPLETE, **static/design acceptance PASS/no blockers**, native
**INCOMPLETE/U02NOTRUN**. Full906linediff/current implementation/tests/runners/checkers/
instructions plus pinned Blizzard TalentButtonBase/TalentDisplay source inspected.
Optional active-entry definition/spell labels remain separate from numeric eligibility;
stale namedtrees retained coherently. Defaultallpath individualName:X/Y, five silent
normalvaluecells retain Shift diagnostics. Meaningful failures/bounds/ownership/parity/
staleretention/realUI tests; U01 tests distinguish hiddenmodel vsrenderedsummary.
Reviewer hash/log access denied; no retry/bypass/edits/tests/hashsuccess. Execution/
hash/freeze evidence above primary-attributed. PlatformN/A/no release approval.

Reviewed source hashes match delivery14-filefreeze above; reviewed delivery README
SHA256 f4dc22b970bc64727dd38c4ddeb465acbfd04c3848303d2c3ec0ed5bf39f9c91. Primary now
updates only its review-gate wording, no runtime changes. U01 better/Shiftdifference
observations remain scoped to that earlier build. User next: quit/backup/fiveLua update,
one ownreadyInscription `/ca scan` then native branchname/individualX/Y and five normal
silent/Shift access check. No fullsuite rerun/capture/V01restart/gameplay/reset. U02
target API/nameaccuracy/wrappedreadability remain unobserved; no fullT02/release claim.

## U03 native probe61 — Calm Hands per-point rule and earned rank0 perk — 2026-11-09

User output: PATH Calm Hands106280, “Improve the efficiency of all Inscription crafts,
gaining +1 Multicraft, +1 Ingenuity, and +1 Resourcefulness per point in this
specialization.” Perk106276 rank0 state2: “Learn to craft an Thalassian Treatise on
Inscription.” followed by “Learn a sub-specialization of your choice.” User confirms
the first node of secondtabCalmHands. Exactline formatting inQ03. This establishes
sampled nativegetter/descriptions/Earned-state feasibility only, not allpathcoverage,
computedtotals/recipelearnedstate/newpanel/responsiveness/reloadvalidation.

Userapproved stagedscope now U0362→65 READY: explicit time-sliced detailrefresh and
cached perbranch ProfessionDetails panel, schema1optionalfield independent ofordinary
scans/LastUpdated. Recipecatalogue/numerictotals deferred. No newsource edit or native
featurePASS bythis evidence entry; fullclient INCOMPLETE87/149 retained. Primary
57filebaseline preserved beforeplanning/evidence at /tmp/opencode/craftarmy-u03-baseline.

## U03 NEW partial writer stop — 2026-11-09 — BLOCKED at62

**Status PARTIAL; review/acceptance INCOMPLETE; NOT DELIVERABLE.** No active writer.
Primary must resolve the contract before another implementation run. Platform N/A;
no install, game operations, dependency changes, Git, release or deployment performed.

### Exact blocker and recovery

62 requires rejecting native point changes without an event at every yield/final
boundary, while separately requiring a verify unit (one GetNodeInfo) and a later
commit-only unit with Context/token/source-object guards but no node reread. Change
native node counters after the last verify Step, keeping Context.sourceCounter,
serial/revision, saved generation object and DB unchanged: the permitted final guards
cannot observe it. The partial job commits. New adversarial case fails at `points3`
(three completed units: metadata, perk, verify; next is commit). This is a mocked
counterexample to the specified algorithm/fixture requirement, **not evidence that
the target client's sourceCounter actually behaves this way**. No native guarantee
that this token detects every rank change was supplied. A further reread also would
not establish atomic multi-path capture across arbitrary subsequent yields.

Implementer did not silently weaken the assertion, combine verify+commit against the
one-unit rule, add unapproved APIs, or claim coherent native acceptance. Primary owns
the decision/evidence needed to settle observable stability semantics or amend the
bounded-unit contract. Resume exactly at62 after that resolution. Then revalidate63,
finish64 required adversarial coverage/schema documentation, and execute65 full local
checks/evidence/combined-update guide, followed by primary actual diff and independent
review **before** any user update. No full native selftest/V01 restart/timing chase.

### Partial implementation and remaining work

- New `CraftArmy/Details.lua`: explicit Step/Cancel capture, selected-source descriptor
  projection, guarded metadata/perk/verify/commit units; cached per-branch model/view;
  explicit one-Step OnUpdate Refresh details, retirement before changed callback.
- Core adds only typed professionDetails validator/registry/native-generation guard.
  Dashboard adds lazy Profession LeftButton integration and normal Refresh integration.
  TOC/standalone initial module list/checker order+manifest count include Details.
- 17 additive U03 definitions, 198 actual total. Every old181 case/helper/runner/U01/U02
  byte is retained. Coverage is **partial**, not a claim that64 is complete: remaining
  required adversarial global-path/perk caps, cross-branch identities, additional
  boundary/UI cases and schema/rollback/combined-delivery docs still need completion
  after62 resolution. No old assertion/workload was removed or weakened.
- Passing new cases demonstrate local exact API arguments/unit boundaries, rank0
  multiline source preservation, independently timed details (observedAt300 with
  scannedAt/sourceScanAt100), unrelated fields/freshness retained, coherent failed
  attempts retaining last success, alias-budget rejection without mutation, cached
  UI/read-only/navigation/retirement and no new perk API work in ordinary Scan.
  These injected results are not target-client API or latency proof. Existing atomic
  Core.Apply can still cost time; no native performance PASS is claimed.
- README now warns not to install partial workspace. Schema document unchanged;
  finishing it and approved combined delivery instructions is remaining64/65 work.

### Commands actually run

- Inspected existing runners and both Python checker scripts before execution.
- `lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-u03-partial-dashboard.log 2>&1`
  **exit1:197PASS/1FAIL of198; no INCOMPLETE**. All old181 PASS; new16PASS/1FAIL.
  Failure: `U03 every yield scope safety cancellation source object and no-event point
  changes discard`, `CraftArmy/SelfTests.lua:5231: points3`.
  K6 744/K7 565 supplements **NOT RUN**: unchanged main runner exits on that failure.
- `lua5.1 tests/run.lua` **exit0:23/23 PASS**.
- `python3 tools/check_dashboard.py` **exit0:16 required files/exact order,23 Markdown
  files/72 local links, eight diagnostic hashes unchanged**.
- `python3 tools/check_diagnostics.py` **exit0:9 required files PASS**.
- Read-only Python byte comparisons/inverse proof **PASS** against actual writer-start
  snapshot `/tmp/opencode/craftarmy-u03-writer-preedit` (58 files including workspace
  manifest). Primary57-file baseline manifest was readable; no denied read/retry.
  Approved primary PLAN/TASKS/Q03/Q05/evidence edits preserved, not mistaken for writer
  changes. No source baseline test was run before edits; no baseline failure invented.
- One documentation patch attempt had an empty hunk and failed before any edit;
  corrected README-only patch applied. No installs/runtime shims/native clock changes.
- Native U03 feature, native API behavior/responsiveness, independent review and full
  native suite **NOT RUN**. Historical native87/149 INCOMPLETE and sample61 unchanged.

### Byte preservation and frozen partial source hashes

Removing only the marked U03 block recovers exact pre-edit SelfTests318042bytes,
SHA256 `08327b6f6435d6a8bddc7007b6a2466ff2fabf8d8556f95868beca6746009025`:
181-case/full-helper/runner retention PASS (therefore old149/U01/U02 unchanged too).
Removing Details from ONLY the initial standalone list recovers27688bytes,
SHA256 `1a3585d83cb61171b0346bfa55319ce9fa1e8f3aea35275f3dae11ea351a8fa8`;
entire main runner and744/565 supplements byte-frozen. Removing ONLY the new Core
validator, registry line and generation guard recovers37110bytes,
SHA256 `63152f75360ee7f035e4c903557675c3ccd8a4903e942af64f1af2193119f7b4`;
ALL other bodies, Copy/K6/K7/Apply/merge/budget/commit unchanged. Unassigned files and
all prior review artifacts remain byte-frozen; evidence prior content append-only.

```text
c1abaa639809ed2db47b84524512bb967ec573aa225eb8e0b1063c0dc1f79609  CraftArmy/Collectors.lua
b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3  CraftArmy/Commands.lua
a59984a289b44babcb8948447ebd77e2dd12bdfef6b8cb8eb5353ce37be57320  CraftArmy/Core.lua
1ca931e883435306225164f67a9e29081c509c7942cd2a7fccb33e5883fd01c8  CraftArmy/CraftArmy.toc
b25e4a0f4a584926f2c9822a70be0da289661b3575cbf61a49a0f64adfcb0f3b  CraftArmy/Dashboard.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
1d85f1b936c7ca875a8ba6b3a7eadae571a40dc9f08bf214631feed031a9a573  CraftArmy/Details.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
214550def55ff05025c933fe1375cdd969cce954736dbd87403e0e9d6ba43f89  CraftArmy/KnowledgeCheck.lua
12e8facd30169b187fb01509aa8cbe677383b46c153992366c79a138e96dd90e  CraftArmy/SelfTests.lua
19d1860789752ac0a2c4c7b301a06fc51c047701907005dcd2735d2aada5a47f  CraftArmy/ViewModel.lua
04d063ada82cbd0e5273f3defbeb27bfc5de976ccc466dd9effefb4b1900f9e4  tests/dashboard.lua
ca46ae2f95358e657d4dcec56b184effbf37c8a947b2a32610ddcf486784256c  tools/check_dashboard.py
```

## U03 NEW amended delivery62–65 — 2026-11-09 — local COMPLETE / overall PARTIAL

**Writer stopped. Local implementation/testing complete; independent review and native
acceptance INCOMPLETE.** Primary settled the correction amendment in TASKS/PLAN/Q03;
the original197/1 stop above remains history, not a current blocker or erased failure.
No install advice until primary actual comparison/independent review/final freeze.
Platform N/A; no children, installs, dependencies, native API/game/real-DB operations,
clock/math changes, profiler/error-handler hooks, Git, release or deployment performed.

### Implementation and amended stability boundary

- New Details module owns explicit Step/Cancel capture and cached model/view. Capture
  selects an active own native Inscription generation, validates source DB exactly once
  at startup, requires complete same-scan native-rank-reconciled raw/trees/index/config
  and copies only selected descriptors in source order. It does not clone a whole DB.
  Optional schema1 typed field has8-tree/64-total-path/32-per-path-perk/512-total-perk/
  4096-per-description/32768-total-description-byte limits. IDs/ranks/states/coherence
  and all generic alias/depth/50000-value limits remain enforced; no trusted bypass.
- Ordinary metadata/perk/verify Steps have no Core.Open/Copy. Full Context checks guard
  normal API reads; cheap plain/schema/scope/object/token checks protect immutable
  source ownership. The amended commit unit performs <=64 scalar GetNodeInfo checks
  **in the same frame as unchanged Core.Apply**, full Context only before/after batch,
  cheap checks between protected node calls. Every raw numeric node/activeEntry value
  uses the shared finite Integer guard before comparisons; booleans stay strict.
  No descriptions/perks/costs/entries are reread in the final batch. Missing/error/bad
  final data terminates without writes or retry loops, including unknown attempts.
- The original every-yield rejecting case, including `points3`, is byte-identical to
  the partial stop and now PASS. Added first-path-after-earlier-verify and multi-path
  final-gap tests pass. The64-path fixture proves129 total Steps (64 metadata+64
  verify+1 commit),64 final node calls in source order, exactly2 final Context calls,
  and one DB Open only inside unchanged Apply during that terminal Step. Startup
  Open count1 and ordinary capture/verify Open/Copy count0 are explicitly asserted.
  This bounds work/calls, **not target-client latency**. Existing atomic Apply can
  still cost time; final batch/native responsiveness remains unmeasured.
- Details-only observation time is the actual last validated clock; guards reject
  backward time within jobs and times earlier than the previous good report. Apply.at
  is the original sourceScanAt, preserving dashboard scannedAt/Last Updated. Success
  updates only details freshness; coherent unknown attempts retain whole prior last/
  observedAt and clear only details freshness. Source/context/cancel/generation changes
  discard without writes. Invalid/over-budget Apply remains atomic. Tests assert old
  character/map identities, alias preservation, unrelated field bytes/fresh flags,
  scannedAt100 versus detail observedAt300/305, and last-good retention after failure.
- Cached view resolves stable guid/id/generation/archived scope, privately projects
  report text/points and formats **one branch body at a time**. It shows full source
  rule/conditions and state2 earned milestones/rank0 text, not computed gains or recipe
  learning. Its own relative age is unknown on missing/bad/backward clock; no profession/
  Context/item/perk reads on open/navigation/offline/archive. Newer tree investment
  cannot replace an old report's points (explicit current0 versus saved10 test).
- Display cleaner strips bounded nested valid color/link/icon wrappers, preserves
  labels/paragraphs and escapes unknown markup without mutating saved source text.
  Read-only wrapping multiline EditBox/ScrollFrame, branch navigation/full names,
  parent fit, absent-detail instructions, unsupported/read-only and deleted/relearned/
  archive scopes are covered. Progress frames update status only. Close/Escape/hide/
  restart/combat retire the job/driver; combat now refreshes saved/cancelled status.
  Old callbacks cannot step newer jobs; completion retires before collector.changed.
- Dashboard changes only lazy Profession LeftButton selection/open and normal cached
  Refresh integration. Ordinary Collector.Scan/Knowledge and all U02 name/hover/
  silent-five/Shift/native gear behavior remain unchanged. TOC/loadlist include new
  Details after KnowledgeCheck, before ViewModel; checker order/count only changes.
- Schema documents field bounds, independent timestamps, failure behavior and old-code
  fail-closed downgrade caveat requiring the pre-update backup, not field stripping.
  README top gates combined U02+U03 full-folder overlay (no deletion) on independent
  review, preserving all SavedVariables/diagnostics. Focused one-normal-scan/Profession/
  Refresh/Calm Hands rank0/source-text/responsiveness/closed+reload cached checks only;
  no full native selftest, large capture, V01 restart, gameplay or reset requested.

### Actual validation and counts

Inspected runners and both structural scripts before executing installed Lua5.1:

```text
lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-u03-final-dashboard.log 2>&1
  exit0:214 passed;0 failed;214 PASS lines;0 FAIL lines;0 INCOMPLETE summaries
  original181 unchanged +33 additive U03 definitions (original17 extended +16 added)
  K6 isolated supplement:744 checks;0 failed
  K7 conservative proof supplement:565 checks;0 failed
lua5.1 tests/run.lua
  exit0:23/23 pure fixture cases passed
python3 tools/check_dashboard.py
  exit0:16 required files;exact ten-module TOC/order/paths/metadata;23 Markdown files;
        73 local links/anchors;eight diagnostic hashes unchanged
python3 tools/check_diagnostics.py
  exit0:9 required files;exact TOC/order/paths/metadata;one SavedVariables name
```

Resume intermediate full dashboard runs also PASS:210/0 with744/565 supplements
(`/tmp/opencode/craftarmy-u03-resume-dashboard-1.log`), then214/0 with744/565
(`/tmp/opencode/craftarmy-u03-resume-dashboard-2.log`). Final214/0 rerun after the
additional current0/saved10 assertion also reached both supplements. No assertion
failure occurred during the amended resume; historical197/1 is retained above.
Exact output still says `scan2 timings unavailable (clock missing)`, NOT zero timing
or native performance PASS. Isolated standalone fake predicates are not WoW API proof.

The33 U03 definitions cover payload scalar/ID/type/dense/duplicate/cap/text-byte/rank/
state/zero boundaries; old DB/load/Copy/archive/private model ownership; raw list and
512-perk/64-path/32768-byte capture boundaries; exact calls/units/final batch; every
yield/API context loss/native point changes/reentrancy/source replacement/config/
foreign/closed/staged/combat/time/cancel/stale callbacks/step cap/final exceptions;
failure atomicity/unknown retention/independent time/unrelated freshness; ordinary
Scan separation; UI real profession handlers/nav/scroll/read-only/long text/markup/
age/missing/unsupported/deleted/relearned/archive/offline/filter/reorder/retirement.
All181 existing cases and original stress workloads remain present and PASS.

### Preservation, comparison and frozen source

Original writer-start58 files retained at `/tmp/opencode/craftarmy-u03-writer-preedit`;
resume-start59 files at `/tmp/opencode/craftarmy-u03-resume-preedit`; primary's original
57-file comparison base `/tmp/opencode/craftarmy-u03-baseline` is readable. Primary
planning amendments to PLAN/Q03 between stops are preserved; no source edits by primary.
Exact read-only byte/inverse checks PASS:

- Remove only marked U03 SelfTests block: recovers exact318042-byte old181 file,
  SHA256 `08327b6f6435d6a8bddc7007b6a2466ff2fabf8d8556f95868beca6746009025`.
  Every old helper/body/runner/U01/U02 byte (therefore original149) is unchanged.
  Original rejecting `points3` case byte-identical to resume-start as well.
- Remove only Core's new validator/registry line/generation-scope guard: recovers
  exact37110 bytes, SHA256
  `63152f75360ee7f035e4c903557675c3ccd8a4903e942af64f1af2193119f7b4`.
  Copy/K6/K7/Open/Apply/Merge/assembled budget/commit and all other bodies unchanged.
- Remove Details from only initial standalone module list: recovers27688 bytes,
  SHA256 `1a3585d83cb61171b0346bfa55319ce9fa1e8f3aea35275f3dae11ea351a8fa8`.
  Entire main runner and744/565 supplements frozen. TOC Details-only and checker
  order/count-only inverses also recover exact originals.
- All48 unassigned resume-start files byte-frozen; only the11 owned paths differ over
  the full implementation (10 existing + new Details), excluding approved primary
  planning changes. All prior review artifacts unchanged versus primary baseline;
  evidence append-only against both writer starts. No u03-review.diff created by writer.

Current ten modules, TOC, runner/checker and schema/README SHA256:

```text
c1abaa639809ed2db47b84524512bb967ec573aa225eb8e0b1063c0dc1f79609  CraftArmy/Collectors.lua
b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3  CraftArmy/Commands.lua
991084ad0c48e30e9d0e51a3b3a6778c59077f53bdd2805f12908026ce4dcde1  CraftArmy/Core.lua
1ca931e883435306225164f67a9e29081c509c7942cd2a7fccb33e5883fd01c8  CraftArmy/CraftArmy.toc
b25e4a0f4a584926f2c9822a70be0da289661b3575cbf61a49a0f64adfcb0f3b  CraftArmy/Dashboard.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
77a8da07a48ba4dc8a07fe9911dfb6e34d62f83fbe99b3a977833f8c065c244a  CraftArmy/Details.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
214550def55ff05025c933fe1375cdd969cce954736dbd87403e0e9d6ba43f89  CraftArmy/KnowledgeCheck.lua
e62a18fc14d0e4c9b02e5a0db3991ec1bc58548fec5fd1b62b0ea1877c59e7c6  CraftArmy/SelfTests.lua
19d1860789752ac0a2c4c7b301a06fc51c047701907005dcd2735d2aada5a47f  CraftArmy/ViewModel.lua
04d063ada82cbd0e5273f3defbeb27bfc5de976ccc466dd9effefb4b1900f9e4  tests/dashboard.lua
ca46ae2f95358e657d4dcec56b184effbf37c8a947b2a32610ddcf486784256c  tools/check_dashboard.py
7eb149b13002072a48426449b60b893e2d7a123404a721a9b1660fcb15bdd1c0  docs/dashboard/schema.md
9e6215be2edfa2e07969522ac57a1a0c2d371c986177925a1ca324f8ff752ece  docs/dashboard/README.md
```

### Acceptance and exact next action

No executable implementation blocker remains. Native sample61 remains ONLY sampled
Calm Hands/path106280 per-point text and perk106276/rank0/state2 text/native agreement,
not all-path coverage/recipe learning/new feature acceptance. U02 installation/native
hover checks and new Details native API/readability/response/closed+reload behavior
are **NOT RUN**. Historical full native selftest remains **INCOMPLETE87/149**, not PASS.

**Primary next:** generate actual `docs/dashboard/u03-review.diff` from the preserved
primary57-file base, accounting for its own planning/evidence changes; obtain/persist
independent read-only review and acceptance evidence before user update instructions.
After review only, coordinate the README's combined full CraftArmy folder overlay
without deletion and focused native check. No agent installation/release approval.

## U03 primary exact comparison/local re-run/independent review — 2026-11-09

Primary actual57filebase comparison:13intended existing deltas+newDetails.lua,
44baselinefiles unchanged. UnrelatedCollectors/Knowledge/KnowledgeCheck/ViewModel/Data/
Commands/diagnostics/testsruntests/check_diagnostics/allpriorartifacts frozen.
WholeCore restrictedinverse (onlyvalidator/registry/scopeguard) and old181SelfTests
inverse PASS; entirestandalone main+744/565 afterinitiallistinverse frozen, TOCmodule-
only/checkerorder-count changes inspected. Whole rejectingpoints3case compared against
initialpartial/resume-preedit: byte-identical and nowPASS, no weakenedassertion.

Primary-generated actual9file `docs/dashboard/u03-review.diff`1578lines103465bytes,
SHA256 `3f0ca94a59311a910cabfa768a00710a2eb24cbb68bc0dc0becba613ab557e1c`.
NoGit/stagedscope. PrimaryRAN installedLua5.1 ALL214actualPASSlines/0FAIL/noINCOMPLETE,
744K6/565K7 all0fail/exit0; complete output
`/tmp/opencode/craftarmy-u03-primary-dashboard.log`. Diagnostic23/23PASSexit0 and both
PythonPASS16/9paths23docs73links/eightdiagnostichashes. Nativeclockmissing unavailable,
not0/performancePASS. Reviewed9files/artifact rehashed unchanged afterreviewerstop.

Verifier COMPLETE; **acceptance PASS (scoped implementation/design)**; **native
acceptance INCOMPLETE**. Full1578linediff/currentcode/tests/runners/checkers/PLAN/TASKS/
Q03/Q05/evidence/schema/README inspected. No blockingfindings. Typedpersistence,
guardedexplicitcapture/sameframefinalfingerprint+Apply/independenttimestamps/cachedUI/
cancellation/backcompat/meaningfulnegative-boundarytests match amendedcontract.
Reviewer combinedhash/check deniedbeforeexecution, no retry/bypass/edits/tests/hash
PASS. Execution/hash/freeze evidence primary-attributed, not independentlyrun.
PlatformN/A/no releaseapproval. Native full-reportlimits and finalbatchresponsiveness
are unmeasured coverageconcerns; acquisitionfailclosed, not demonstrateddefects.

Reviewed identities match15filefreeze above. Reviewed README9e6215be2edfa2e07969522ac57a1a0c2d371c986177925a1ca324f8ff752ece
is deliverybefore primaryreview-gate textupdate, not currentwhole-documenthash. Primary
subsequentlychanges only READMEgate/evidenceindex/planning acceptance, no runtimebytes.
Sample61nativefeasibility isn't newfeaturePASS. Currentusernext afterfinalfreeze:
quit/backup installedaddon+SavedVariables, overlayfullcurrentCraftArmyfolder WITHOUT
deletion/newDetails+TOC/U02included; preservepreupdatebackupforcoordinateddowngrade.
Firstfocusedcheck ownreadyunstagednormalScan→Profession→Refreshdetails/CalmHands rule/
earnedrank0/nativeagreement andresponsiveness/errors/warnings. Cachedclosed/reload
checks follow satisfactoryfirstcheck. No fullselftest/V01restart/capture/gameplay/
reset/numericstat-total/recipelearning/fullT02/API/releaseacceptance inferred.

## U03 native feedback / U04 visual refinements READY — 2026-11-09

User: “Values match correctly.” Response to U03newDetailsnativecomparison instructions;
no exactvalues/build/sourcehash or responsiveness/errors/warnings/closedreload evidence
repeated. Record bounded valueagreement, not fullcapture/performance/persistencePASS.
User requests numeric-only progressbarlabels (noBlu/Cal/Per/Dar), morebarspace with
narrowerStat/Enchant, Solid/Flatfill, hierarchyindent ontooltipnode names. U0466–67
authorizedpresentationonly; storedchildrelationships suffice, no newAPI/data/accounting.
Primary59filepre-U04baseline preserved /tmp/opencode/craftarmy-u04-baseline beforedocs.
No sourcechanges/tests/nativevisualexecution fromthisevidenceupdate; independentreview
and focusedcachedUIcheck follow implementation. No fullnative selftest/V01restart.

## U04 NEW delivery66–67 — 2026-11-10 — local complete / overall PARTIAL

### Outcome and remaining gate

One synchronous writer, serial66 then67, no children. Changed only Dashboard,
ViewModel, SelfTests, dashboard README, this append-only evidence and U04 task state/
new delivery. No installation, game API/real DB access, collection/accounting change,
dependency, Git operation or release. Platform review N/A. Primary actual-baseline
comparison and independent read-only review are **NOT RUN**, and must precede any
installed-file update. Native U04 visual readability/fill/widths/indentation NOT RUN.

User's U03 “Values match correctly” remains bounded native value agreement only;
no exact values/build/installed hash, latency, error/warning absence, complete coverage
or closed/reload cached persistence is inferred. U03 remaining checks and broader T02
acceptance stay incomplete. Full native historical87/149 INCOMPLETE remains unchanged;
no full native selftest/V01 restart/recollection requested or run for U04.

### Implementation

- Stat180→140, Enchant130→110, Knowledge232→292 only. Content1424/outer1454, all other
  column widths, row22, fonts, scale-fit, paging and controls unchanged. Eight existing
  bars reused; actual width `(widths[I.Knowledge]-4)/max(1,#r.trees)-2` (four70px,
  one286px, eight34px), no53px cap. Initial hidden widgets also use the column width.
  Height14, background, color0.2/0.65/0.95, min/max, zero and unknown fill preserved.
- Built-in `Interface\\Buttons\\WHITE8X8` flat statusbar fill. Numeric-only X/Y or `?`,
  no shortName/name/colon prefix. Model shortName provenance is retained.
- Only two ViewModel source lines change: normal path and missing-child lines prefix
  `string.rep("  ",depth)`. Root0, children2spaces/grandchildren4/siblingsequal;
  every64path line, preorder, full localized/duplicate names and individual points
  retained. Unknown/stale/archive exception footers unindented. Original treeDetail,
  Shift arrays and field/state/source-time/ratios/warnings/sorting bodies unchanged.
- README top now gates U04 on primary comparison/review. After review, already-on-U03
  user quits/backs up and updates ONLY Dashboard/ViewModel/SelfTests, preserving
  Details/Core/Collectors/all other modules/TOC/DB/diagnostics. Full-folder overlay
  without deletion is only for users not on U03. Existing cached-data `/ca` visual/
  hover check needs no scan, Refresh details or full native selftest. Historical U03
  collection steps are explicitly historical, not a new U04 request.

### Regressions and source preservation

**220 actual cases =214 retained (four authorized expectation edits) +6 additive U04.**
New helpers are confined to marked U04 do-block before Tests.Run. Shared fixture
helpers, runner, stress workloads, checkpoints, caps and all U03 final-gap rejecting
assertions are untouched. Six new real-handler cases cover:

1. Rendered0/10,10/10,unknown`?`, texture/color/background/height/bounds spies and exact
   normal/Shift hover, with no collection reads or saved/session/diagnostic mutation.
2. Real headers/cells fixed geometry and 8→4→1→0→1→0 bar reuse.1/4/8 widths286/70/34,
   same label/bar widths, containment/adjacency/no overlap, no53cap, hidden tree release,
   unknown fill hidden and zero fill visible.8tree expansion is model-only, not invalid DB.
3. Exact root `静かな手: 3/10`, child `  静かな手: 5/10`, grandchild
   `    Écriture tranquille: 0/10`, sibling `  Sibling: 0/10`; duplicate/localized names,
   locked zero, individual points vs8/40 aggregate and complete unchanged Shift arrays.
4. Stale and archived unindented footers; missing-grandchild model-only projection
   `    Unknown branch: ?/?` and unindented unavailable footer; preserved saved DB.
5. Every one of64 depths0..63 rendered and asserted, no truncation/diagnostic mutation.
6. Real guarded fixture scan followed by render/hover with collection APIs disabled;
   four native fixture labels0/270,50/70,214/270,0/260, all Shift lines preserved, DB/
   fresh session/fixture points/diagnostic sentinel identity and values unchanged.

All existing Details/U02/native gear/five-silent-cell/Profession-click regressions run.
These injected fixtures are not evidence of actual WoW APIs, font-space rendering,
texture appearance, tooltip wrapping or native responsiveness.

Read-only byte proof against actual writer-start workspace:
`/tmp/opencode/craftarmy-u04-writer-preedit` (60files, before writer changes).
External read of primary `/tmp/opencode/craftarmy-u04-baseline/manifest.json` denied
once; **no retry/bypass**. Primary must compare its actual59-file baseline separately,
accounting for approved primary PLAN/TASKS/Q03/Q05/evidence edits predating writer.

Proof RAN with `python3 - <<'PY'` (read-only assertions, results also at
`/tmp/opencode/craftarmy-u04-preservation.log`): extract all214 case bodies from actual
pre-edit/current source in order; assert precisely these four changed; delete marked
U04 block; replace ONLY these four bodies with original counterparts; compare ENTIRE
SelfTests byte-for-byte. **PASS**, original370159bytes/SHA256
`e62a18fc14d0e4c9b02e5a0db3991ec1bc58548fec5fd1b62b0ea1877c59e7c6`.
Thus all other210 cases, every old helper/runner/U03 final-gap body are exact bytes.

Allowed old case replacements (before → after SHA256):

```text
R5 geometry 0 1 2 12 13 many rows has exact compact bounds and canonical hover headers
8f3491dc0c8e6021d1a245635fc23b6d7e22347dce45b11e432c4cf029359a8d
2f64f785b3502f7439b221a4bbc2300ecb8288296d39f1cdc5c2949027f52364
U01 native tree all individual branches without default prose full Shift evidence
42b1096af7246b0554b22ee74d6f64d5c11c51d3aa02debe5d8017930d457e6a
bccd57b119dd6c1cabb7c376c70d36ba1a7bde1a861af9053a7d0ed553a0570d
U02 real named localized duplicate branches individual points full traversal and legacy diagnostics
5ebc11962c4bf26021fa25fb751243baac49e362bb1ca704270542df4cc7f5fd
eb50d402cb13ed4f9d9cf5ccd0615c19362bd9a9cb1d858ae0a97dfb4fd94806
U02 all64 default paths unknown labels totals and single stale archive exception footer
0b4db148e015975cc1a6ecd99231cf0d1a7d7ff720e722c20f7ee274db028717
159d3f9b20b4139f9e44a066e133cef9c2607bba3c80932987a156a2c3631e2b
```

R5 changes only three expected widths; all its other geometry assertions exact. U01
and U02 named loops retain every numeric/name/order/count assertion with precise depth
prefix expectation derived from stored children. U02 chain changes only leading-space
expectations and additionally asserts every depth. No assertion removed.

Whole ViewModel inverse of exactly two prefix edits **PASS**; treeDetail/all other
bodies exact. Whole Dashboard inverse of exactly six bounded replacements **PASS**,
recovers original25594bytes/SHA256
`b25e4a0f4a584926f2c9822a70be0da289661b3575cbf61a49a0f64adfcb0f3b`.
All54 unowned of60 writer-start files byte-frozen/no new workspace files; full
standalone runner, initial load list,744/565 supplements, Details/Core/Collectors/
Knowledge/KnowledgeCheck/Data/Commands/TOC/schema/checkers/diagnostics and ALL prior
review artifacts unchanged. Evidence pre-edit prefix preserved. Primary planning files
unchanged by writer; this proof does not label approved pre-writer edits as drift.

### Validation actually RAN

Scripts inspected before execution. Already-installed `/usr/bin/lua5.1` reports
Lua5.1.5 (`command -v lua5.1 && lua5.1 -v`); no install/runtime shim.

- `lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-u04-dashboard-first.log 2>&1`
  exit0:220passed/0failed,744K6/565K7. No initial U04 failing run.
- `lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-u04-dashboard-final.log 2>&1`
  exit0: actual220PASS lines,0FAIL lines, noINCOMPLETE,220passed/0failed;
  K6 isolated744checks/0failed; K7 conservative565checks/0failed. Read-only Python log
  assertions verify counts/noINCOMPLETE. Case81 reports **scan2 timings unavailable
  (clock missing)**, NOT0/timingPASS.
- `lua5.1 tests/run.lua` exit0:23/23 pure diagnostic fixtures PASS.
- `python3 tools/check_diagnostics.py && python3 tools/check_dashboard.py` exit0:
  diagnostics9required files; dashboard16required files/exact10module TOC/metadata/
  isolated SavedVariables/no dependencies;23Markdown files/74local links/anchors;
  eight diagnostic hashes unchanged. Structural checks are not Lua execution/API proof.
- Read-only inline Python exact4case/whole-file inverse, two-line ViewModel inverse,
  six-edit Dashboard inverse and full54unrelated-file/runner/artifact freeze: PASS.

Native U04 visuals/API/performance, independent U04 review, installation and release:
**NOT RUN**. No game API/real DB/clock/profiler math/reset/archive operation performed.
No baseline failure discovered; historical incomplete native stress results unchanged.

### Frozen delivery hashes

```text
c1abaa639809ed2db47b84524512bb967ec573aa225eb8e0b1063c0dc1f79609  CraftArmy/Collectors.lua
b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3  CraftArmy/Commands.lua
991084ad0c48e30e9d0e51a3b3a6778c59077f53bdd2805f12908026ce4dcde1  CraftArmy/Core.lua
1ca931e883435306225164f67a9e29081c509c7942cd2a7fccb33e5883fd01c8  CraftArmy/CraftArmy.toc
ac1d33dd8cfeddc83cac42b834b742dfb80c3eb9e6d178dbfa7b97d354ed92cd  CraftArmy/Dashboard.lua
1859f29807800f9c40347d2e2b8e2265d0c1f2653b68407cde885219d11d3d6e  CraftArmy/Data.lua
77a8da07a48ba4dc8a07fe9911dfb6e34d62f83fbe99b3a977833f8c065c244a  CraftArmy/Details.lua
fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d  CraftArmy/Knowledge.lua
214550def55ff05025c933fe1375cdd969cce954736dbd87403e0e9d6ba43f89  CraftArmy/KnowledgeCheck.lua
ad193897185f4cb626cf1026450f952f701a806e22edfb037ea014342858edf5  CraftArmy/SelfTests.lua
f4a329cb91598aed71945acd73a55db5aa7951c3af02f6a6b7bbbcdff3ddcaf2  CraftArmy/ViewModel.lua
a205a884fe5fd2725c230a5686eae01befd948f35fa64f7efcf60c48ac2f9f29  docs/dashboard/README.md
7eb149b13002072a48426449b60b893e2d7a123404a721a9b1660fcb15bdd1c0  docs/dashboard/schema.md
04d063ada82cbd0e5273f3defbeb27bfc5de976ccc466dd9effefb4b1900f9e4  tests/dashboard.lua
ca46ae2f95358e657d4dcec56b184effbf37c8a947b2a32610ddcf486784256c  tools/check_dashboard.py
66253a0403fe29078f1b41f99ba295cbcf3c3f3e54f7a060d76b6c3df02ef6f3  tools/check_diagnostics.py
```

### Exact resume

Writer stopping **PARTIAL**,66/67 locally done, no executable design blocker/writer
remainder. Primary compares actual59-file baseline, creates its own actual
`docs/dashboard/u04-review.diff`, obtains independent read-only review and persists
findings before any update advice. Then focused user cached-data visual check per
README (three-file update only if already on U03). Primary owns PLAN/Q03/Q05/review/
acceptance/new artifact after stop. No full native selftest, recollection or release.

## U04 primary exact comparison/local re-run/independent review — 2026-11-10

Primaryactual59filebase→target9intendedexistingdeltas,50baselinefiles unchanged.
Actual4file `docs/dashboard/u04-review.diff`390lines24330bytes SHA256
`c6c12b3ae0b30aff5909c293a1055cc8cf86af4134c9dc033b80cc28e5ba9ed2`.
NoGit/stagedscope. Wholeold214SelfTests recovered afterONLY4authorizeddisplaycase
replacements+remove6newcaseblock;210othercases/helpers/runner/U03finalgap/stress/
caps/checkpoints frozen. Entirestandalone744/565/backend/Details/Core/collectors/data/
schema/TOC/checkers/diag/priorartifacts unchanged. No data/acquisition work added.

PrimaryRAN ALL220actualPASSlines/0FAIL/noINCOMPLETE+744K6/565K7 all0fail/exit0, log
`/tmp/opencode/craftarmy-u04-primary-dashboard.log`. Diagnostic23/23PASSexit0; bothPython
PASS16/9paths23docs74links/eightdiagnostichashes. Missingclock unavailable, not0/native
timingPASS. Reviewed3sources/README/artifact rehashedunchanged afterreviewerstop.

Verifier COMPLETE; **scoped static implementation PASS/no blockers**, **native
INCOMPLETE**. Full390linediff/currentcode/tests/design/runners/checkers/evidence
inspected. Settledallocation/expandednumericbars/built-inflatfill/two-spacehierarchy
correct; sixnewtestbodies/fouradaptedcases meaningfulrender/hover/reuse/unknownstale/
archive/datapreservation assertions, no weakenednumericcoverage. Reviewer shell/log
access denied/no retry/bypass/noedits/tests/hashsuccess; all executable/inverse/hash
proofs primary-attributed. PlatformN/A/no releaseapproval. Nativewidth/fill/leading
whitespacefont/readability stillunverified.

Reviewedsourcehashes matchU04deliveryfreeze above; reviewed READMEa205a884fe5fd2725c230a5686eae01befd948f35fa64f7efcf60c48ac2f9f29
is historical beforeprimarygate-textupdate. SubsequentREADME/evidenceindex/planning
updates don'tchange runtime. Nextuserquit/backup/scoped3UIfileupdate ifonU03 then
cacheddataonlynumericbars/width/flatfill/indent/Shift check. Otherwisefullfolderoverlay
includesU03dependenciesperREADME. No scan/Detailsrefresh/fullnative selftest/V01restart/
gameplay/reset/release. U03nativevaluesmatchbounded, no performance/warnings/cache
acceptance inferred fromthat or thislocal/static gate.

## U04 user appearance acceptance — 2026-11-10

User: “Oh yeah, that looks a lot better.” Response to U04cachedvisualcheck. Record
positive nativeappearanceapproval for this iteration and retain layout; U04scoped
visualwork COMPLETE. This isn't per-platformfont/texture measurements, new API/data
checks, installedhash proof or U03latency/warningabsence/cachepersistence evidence.
No furtherU04sourcechange/update/retest requested. U03valueagreement retained; ask
remaining Detailsrefresh responsiveness/errors/executionwarnings fromprioruse before
coordinatingclosed/reloadcachechecks separately. Fullnative selftest staysINCOMPLETE
87/149; no rerun/broaderT02/releaseacceptance. Documentation-only evidence update,
no new Lua/nativeexecution result claimed.

## U03 normal-use responsiveness / no errors confirmed — 2026-11-10

User: “Yes it was fine,” replying to whether Refreshdetails stayed responsive without
errors or execution-limit warnings during prioruse. Record normal-use affirmative
evidence alongside priorvalueagreement; not measuredlatency/permanenthistoricalwarning
resolution/allpathcapturecoverage/API/fullT02acceptance. U04appearanceacceptedunchanged.

Nextfocusedround only: close nativeprofession and reopen cachedCraftArmyDetails without
scan/Refreshdetails; knowninvestment/perktext/originalobservationtime mustpersist as
saved/notcurrent, relativeage allowedtogrow. ReloadcachedDetails check follows after
satisfactoryclosedcontext evidence. These newfieldchecks notyetobserved, notclearedby
originalV01dashboardcachevalidation. No newsource/test/capture/selftest run requested.

## U03 closed-context Details preservation confirmed — 2026-11-10

User: “Yes, all looks good,” answering the closednativeInscription/reopenedcached
Details check without scan/Refreshdetails. Branchinvestment/perktext/original
observationtime remain, with saved/notcurrent presentation. Scoped preservation
evidence, not alltransientfailure-path or reloadproof. U03valueagreement/normal-use
responsiveness/noerrorwarning report and U04appearanceapproval retained.

ReloadcachedDetails check next: professionclosed, `/reload`, `/ca`, ProfessionDetails
before anynewprofessionopen/scan/Refreshdetails. Report/time mustpersist as saved,
relativeage mayincrease. Native reload outcome stillpending; no source/test changes
or newcapture/fullselftest/V01restart/release requested.

## U03 reload persistence / focused validation complete — 2026-11-10

User: “Yes all values remain and the only thing to change is the relative age as
expected.” Reply to reloadwithInscriptionclosed then `/ca`/ProfessionDetails before
reopening/scan/Refreshdetails. Saved investment/perktext/originalobservationtime remain;
relativeage advances normally. No fabricatedcurrentread inferred.

Focused U03 COMPLETE for this character's reported sequence: nativevalueagreement,
responsiveRefreshdetails/noerrors/executionwarnings, closed-context cachedpreservation
and reloadpersistence. U04appearanceaccepted. Scoped acceptance only, not every native
path/API/budgetlimit individuallyaudited, permanenthistoricalwarningresolution,
otherprofession/recipe/numerictotals/fullT02/guides/release acceptance. Fullnative
stresssuite remains INCOMPLETE87/149. No furthercapture/retest/sourceupdate/fullselftest
or V01restart requested; futureworkneeds separate scope. Documentation-only evidence,
no newlocalexecution/installation/nativeclock/hash result fromthis observation.

## E01 partial implementation STOP — frozen Knowledge persistence blocker — 2026-11-10

Status **PARTIAL / BLOCKED**, not installable, independently reviewed or native-accepted.
User-evidenced identity is2909/333/9, skill81/max100. Sole writer added only the
Data.expansions entry (expansion11, user child-profession-query2026-11-10 provenance)
and adjacent comment, plus10 additive cases in an E01 BEGIN/END SelfTests block.
All other non-native IDs, balances, gear, labels and Knowledge fixtures are synthetic.
No Moxie mapping or numeric Knowledge/Details scope was widened. README stays unchanged:
the dependent coverage-delivery documentation must not imply functioning Enchanting scans.

### Precise blocker / primary-owned design decision

Actual `lua5.1 tests/dashboard.lua` execution: **223 passed;7 failed**, exit1.
All original220 passed and three new identity/rejection cases passed. Seven new
scan-dependent cases fail at their successful-scan assertions (`false ~= true`),
covering generic fields, Moxie, Knowledge policy, coexistence, unsafe preservation,
failed reads and reopened rendering. The failing regressions are retained, not skipped
or rewritten to accept failed collection.

Static trace explains why a registry-only change cannot satisfy E01:

- `CraftArmy/Collectors.lua:321` always creates knowledgeRaw with policy
  `native-rank-reconciled-v1`. Lines456–475 evaluate it and persist the bounded raw
  payload as an observed field even when Knowledge.Evaluate rejects numeric totals.
- `CraftArmy/Core.lua:585–594` validGeneration rejects any saved native-policy raw
  or evaluated field unless identity is2913/773/13/11 (nativeScope at286–288).
  `Core.Apply` line692 therefore takes `Invalid candidate generation/scope` for the
  Enchanting candidate. This is a static failure-path attribution, not an error string
  printed by the generic assertion output.
- Both files are frozen. The writer stopped rather than bypassing/widening the guard,
  mocking production behavior, or changing collection/schema beyond the contract.

Primary must settle unsupported Knowledge-raw persistence semantics and explicitly
authorize the necessary source-file scope. Then amend E01 before resuming piece2.
Piece1 is done; piece2 partial/blocked; pieces3/4 dependency-blocked. No independent
implementation pieces remain. No user update advice until completion, primary actual-
baseline comparison and independent read-only review.

### Approved executable validation actually run

Scripts were inspected first; already-installed Lua5.1 used, no installs/shims.

```text
lua5.1 tests/dashboard.lua
223 passed; 7 failed (pure fixtures only)
exit1; original220PASS + new3PASS/7FAIL; K6/K7 supplements NOT REACHED

lua5.1 tests/run.lua
23/23 pure fixture cases passed (not live-client evidence)
exit0

python3 tools/check_dashboard.py
PASS: 16 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 75 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated
exit0

python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
exit0
```

Primary-supplied baseline was220/220 + K6744/K7565 + diagnostic23/23 and both Python
checks PASS. New failures are not baseline failures. No timing/performance result is
inferred from standalone Lua. Native E01 scans/fields/responsiveness/preservation/reload
are **NOT RUN**; only the supplied identity/skill command is native evidence. Moxie
mapping and numeric Knowledge remain unknown; generic-field target-client acceptance
for Enchanting remains unproven. Details behavior is unchanged/read-only unsupported.
Full native stress result remains historical **INCOMPLETE87/149**, with no rerun.

### Original/frozen-byte proof and comparison limitation

The first `functions.read` of
`/tmp/opencode/craftarmy-e01-baseline/manifest.json` returned permission.rejected /
external_directory. No retry, alternative-tool access or bypass was attempted.
Primary's original61-file baseline comparison is still pending, including its declared
post-snapshot PLAN/TASKS/Q03 changes. A separate writer-start61-file copy was created
from the working tree at `/tmp/opencode/craftarmy-e01-writer-preedit`; manifest SHA256
`4f0e26a8470f9e769c8d593dbbd1247d722be3191467df3c61b8154d2f425271`.

The executed `python3 - <<'PY'` comparison read that writer-start manifest, hashed
every current path, asserted all deltas belonged to the five-file ownership list and
asserted no new/deleted workspace paths. It removed the complete E01 marked block
and its separating blank line from current SelfTests and required exact byte equality
to original381362bytes, SHA256
`ad193897185f4cb626cf1026450f952f701a806e22edfb037ea014342858edf5`.
It counted220 original literal case registrations and10 additions. It also reversed
only the exact Data entry/comment and compared the entire original Data file, and
compared every TASKS byte following the historical-T02 separator. All assertions PASS;
all56 unowned writer-start files frozen, including PLAN/Q03/Q05, Core/Collectors/
Knowledge/Details/UI, standalone runner, diagnostics, checkers and prior review artifacts.

Source SHA256 at blocked stop:

```text
a200a66add31b7d11f5812aa639e614dc6f5ed4f61f6eb0ab8a4096e179a1cc7  CraftArmy/Data.lua
faf8c5011372be8f2a96e963bf4b7c49ca66de5b036e97c65bef980fe5ce0c54  CraftArmy/SelfTests.lua
90027c017f43347e18ba7887398da4e36e6b7ae729b9803c49cf7ba601716142  docs/dashboard/README.md (UNCHANGED)
```

Actual changed files at handoff: Data.lua, SelfTests.lua, this append-only evidence,
and E01-only TASKS state/report. Final full changed-file hashes and exact repeatable
proof command are retained in `/tmp/opencode/craftarmy-e01-writer-result.json` and
the E01 Report back; no evidence/task self-hash is embedded in its own bytes.
No client actions, dependency installs, Git operations, release or publication.

## E01 amended partial STOP — one missing fixture-scope field — 2026-11-10

Primary settled unsupported raw persistence and expanded ownership only to the
Collectors Scan knowledgeRaw observation branch. Implemented exact2913/773/13/11
original observation/evidenceFits path; other identities now emit unsupported/nil
with `Native Knowledge accounting is unverified for this profession`. Capture,
evaluation, tab/index handling, staging, commit, Core validators, Knowledge policy,
Details and schema remain unchanged. No raw report is saved for Enchanting.

The existing10 cases remain, with only the two raw-persistence assertions replaced
by unsupported/no-last plus reason assertions. Added an11th case: direct Core rejects
relabeled out-of-scope raw payload, valid Inscription raw inserted into an Enchanting
candidate, and active/archived saved out-of-scope generations, preserving input graphs.

Actual approved `lua5.1 tests/dashboard.lua` now **230 passed;1 failed**, exit1.
All original220 and10 E01 cases PASS. K6/K7 not reached. Full log retained at
`/tmp/opencode/craftarmy-e01-amended-dashboard.log`. Initial223/7 failure remains
historical, not erased. The original raw-payload guard can reject at the production
field-payload validator as well as the separate generation-scope check; the new direct
case demonstrates both without relaxing either (correcting the first partial's
overly specific inferred generation-only failure-path attribution).

The one remaining failure is **test fixture setup**, not production acceptance:
`E01 guarded synthetic Enchanting scan observes generic fields with Details unsupported`
reaches its `details.supported==false` assertion and gets nil. The scope passed to
Details.Model omits `archived=false`, required by Details.selected at28–30. Therefore
Model returns Snapshot unavailable before testing unsupported-profession behavior.
The precise correction is one fixture-scope field, no assertion or Details source
change. Current amendment restricts existing10 edits to raw-persistence assertions;
writer stops for primary authorization rather than silently expanding it.

Pieces1/2 done;3 partial/blocked;4/5 dependency-blocked. README unchanged pending those
dependencies. Resume only after primary authorizes adding `archived=false` to that
one E01 fixture scope; then rerun full suite and complete docs/validation/freeze.
No remaining production design blocker identified; no completed native acceptance
or independent review implied. Enchanting Moxie/numeric Knowledge remain unverified;
generic fields have only synthetic evidence, native E01 NOT RUN beyond supplied
identity/skill. Full native suite remains historical INCOMPLETE87/149, no rerun.

Amended writer-start61-file snapshot `/tmp/opencode/craftarmy-e01-amended-preedit`,
manifest SHA256 `37724f2ff81529f94659de79d4ac8bf3f982b84347c4cfb55ffcef2611dc6d17`.
It differs from initial writer snapshot only in prior writer4 files and declared
primary PLAN/Q03/TASKS amendments. Primary original baseline was not retried/accessed.
Final partial checks, exact changed-file SHA256 and repeatable inverse/freeze proof:
`/tmp/opencode/craftarmy-e01-amended-partial-result.json`. Proof requires original220/
helpers/runner whole-byte inverse, Data and Collector exact inverses, original10-case
inverse except authorized raw assertions,55 unowned amended-start files unchanged,
historical T02 unchanged and evidence append-only. No installs, client actions, Git,
releases or publication. Prior partial report/result artifacts retained unchanged.

Additional approved partial checks actually rerun after amendment: `lua5.1 tests/run.lua`
→23/23 pure fixtures PASS exit0; `python3 tools/check_dashboard.py` →PASS exit0,
23 Markdown/75 links/eight diagnostic hashes unchanged; `python3 tools/check_diagnostics.py`
→PASS exit0. Structural checks do not establish Lua execution/native API behavior.

## E01 final amended delivery — local COMPLETE; comparison/review/native gates pending — 2026-11-10

Primary authorized only the missing `archived=false` fixture-scope field. Applied it
without changing any assertion or Details source. All five amended E01 pieces are
complete; both preceding partial stops/failures remain historical above. No active
writer remainder or design blocker. This is implementation completion, not independent
review, primary acceptance, installation advice or release.

### Runtime boundary and additive regressions

- Data.lua adds only2909/333/9/11 and adjacent evidence comment. User child-profession
  query2026-11-10 establishes identity and skill81/max100, not other field semantics.
  Inscription/all other registry/function bytes are unchanged.
- Collectors.lua changes only the knowledgeRaw observation branch. Exact
  Inscription2913/773/13/11 executes the old observation/evidenceFits behavior. Other
  identities emit unsupported/nil with an explicit unverified-profession reason.
  Full existing bounded capture/evaluation/tab-index/staging/commit code is retained.
  Core validators, Knowledge numerical eligibility, Details and schema are unchanged.
-11 marked E01 cases:10 original additive cases retained, only authorized raw
  assertions and archived=false fixture setup amended;11th direct Core rejection
  case proves out-of-scope raw payload/candidate/active/archive rejection without
  mutation. Original220/helper/runner bytes and registration order are unchanged.
  Regressions cover localized identity vs IDs, unmapped/conflicting/unsafe context
  rejection, generic synthetic observations, unsupported Moxie/no3261/no false zero
  or attention, nil numeric Knowledge even with otherwise valid relabeled fixtures,
  same-character coexistence/filtering, old-value/time retention and saved rendering
  without collection/fresh session. Non-native IDs/balances/gear remain synthetic.
- README now leads with current partial-coverage/review gates and qualifies the
  historical K2 one-mapping statement. Older update instructions do not authorize an
  E01 update. Source hashes and this evidence are the delivery recovery point.

### Exact approved executable validation

Scripts inspected before execution; only already-installed Lua5.1, no installs/shims.
Dashboard command was wrapped to retain full stdout and propagate its exit status:

```sh
lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-e01-final-dashboard.log; result=$?; tail -n 15 /tmp/opencode/craftarmy-e01-final-dashboard.log; exit "$result"
```

Actual exit0,231 PASS lines,0 FAIL lines, no INCOMPLETE result:

```text
231 passed; 0 failed (pure fixtures only)
K6 isolated supplement: 744 checks; 0 failed (standalone fake predicates, not native performance/API evidence)
K7 conservative proof supplement: 565 checks; 0 failed (standalone soundness, not native performance/API evidence)
```

Other approved commands and exact results (exit0 each):

```text
lua5.1 tests/run.lua
23/23 pure fixture cases passed (not live-client evidence)

python3 tools/check_dashboard.py
PASS: 16 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies
PASS: 23 Markdown files inspected; 76 local links/anchors; eight diagnostic hashes unchanged
Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated

python3 tools/check_diagnostics.py
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
```

Original baseline had no local failures. Historical E01 first223/7 and amended230/1
failures are retained; current231/0 passes every original/new assertion without
weakening, removing or filtering cases or changing workload/runner/time limits.

### Exact inverses and frozen-original proof

Executed repeatable command: `python3 /tmp/opencode/craftarmy-e01-final-proof.py`.
The script is also embedded in `/tmp/opencode/craftarmy-e01-delivery-result.json`.
All assertions PASS:

- Original writer-start61-file comparison (not primary's inaccessible baseline):
  removing entire E01 block + separating blank line recovers whole SelfTests381362
  bytes/SHA256 `ad193897185f4cb626cf1026450f952f701a806e22edfb037ea014342858edf5`.
  Original220 registrations/helpers/runner exact;11 new registrations. First220
  actual PASS lines/order also match the preserved amended-partial run.
- Exact entire Data entry/comment inverse and entire Collectors authorized-branch
  inverse recover original bytes. No other collector statements changed, including
  bounded capture/evaluation/index/staging/commit. Core/Knowledge/Details/UI frozen.
- Undoing the11th case, authorized raw assertions and archived=false fixture field
  recovers the prior10-case partial SelfTests exactly. Final-resume SelfTests differs
  by only that one approved fixture field; Data/Collectors unchanged at final resume.
- All55 unowned amended-start/final-resume files byte-identical, no new/deleted
  workspace files. Relative to initial writer-start, only six owned paths plus
  declared primary PLAN/Q03 changes differ; no unapproved planning edits by writer.
  Historical T02 suffix unchanged, evidence append-only including both partials.
- Original primary-baseline access was denied once; no retry/bypass. Primary's
  actual-baseline comparison remains pending, accounting for its own TASKS/PLAN/Q03
  amendments. Writer snapshots/proofs do not substitute for that separate gate.

Final-resume snapshot61 files at `/tmp/opencode/craftarmy-e01-final-preedit`, manifest
SHA256 `5c0883e830d50926c13090a9e99799aab44560c82046a50fb3902a84743cca89`.
Earlier snapshots/results/logs retained. Final actual changed paths are Data.lua,
Collectors.lua, SelfTests.lua, dashboard README/evidence and E01-only TASKS state/report.

Frozen source/current README SHA256:

```text
a200a66add31b7d11f5812aa639e614dc6f5ed4f61f6eb0ab8a4096e179a1cc7  CraftArmy/Data.lua
ff3552881a52df8a4204aea0e7ddf049e3a6dd611fcc3c5147c80042d048a96a  CraftArmy/Collectors.lua
7405f254ad8b27568658af611224823a7494f003885ae65ff9e557113d174c96  CraftArmy/SelfTests.lua
5e745682427417517d4c0ca871f32c0ec4a6a9961e101ab4ae0299f18a211d91  docs/dashboard/README.md
```

Final six-file hashes (including this evidence/TASKS, without circular embedded
self-hashes), proof-command source/hash and dashboard log/hash are retained in
`/tmp/opencode/craftarmy-e01-delivery-result.json`.

### Remaining gates / exact handoff

Primary next compares the actual original baseline/frozen result and obtains an
independent read-only review before any update advice. Platform review N/A: no
CI/hosting/deployment/release behavior changed. No independent review performed here.
Native E01 generic gear/slot/stat/enchant/concentration/cap/unspent values, normal-use
responsiveness, closed-context and reload preservation are **NOT RUN**. Only supplied
identity/skill evidence is native. Enchanting Moxie has no mapping and remains unknown;
numeric Knowledge remains unknown, with unsupported raw and optional named unknown
bars; Details remains unavailable/read-only. Inscription reported-scope evidence is
unchanged. Full native stress suite stays **INCOMPLETE87/149**, not PASS or a rerun
request. No installs, game actions, dependencies, saved-data reset, Git operations,
publication or release. Local fixtures never establish native APIs/performance.

## E01 primary comparison / independent static review PASS — 2026-11-10

Primary actual original61-file comparison PASS:8expected changed paths,53unchanged;
whole original220/helpers/runner inverse, exactData entry/comment inverse, exact
Collectors observationbranch inverse, historicalT02 suffix and evidenceprefix PASS.
Generated `docs/dashboard/e01-review.diff`,4files344lines22112bytes SHA256
`c49eb331f0df32058084aeb135c7b0a1e79832e463cfd8704e70cade5f32f5dc`.
Proof `/tmp/opencode/craftarmy-e01-primary-proof.json`; primary actual rerun log
`/tmp/opencode/craftarmy-e01-primary-dashboard.log`:231PASS/0FAIL/noINCOMPLETE,
K6744/K7565;diagnostic23/23/bothPythonPASS. All source hashes equal deliveryfreeze above.

Independent verifier `ses_e3d91b43affelWPA0XiAkg26Wu`: COMPLETE, scoped static acceptance
PASS/no findings/blockers. Entire artifact/current integration/tests/scripts reviewed.
Nativeidentity guard and unsupportedraw persistence boundary correct;11newcases
meaningfully exercise coverage; no numericpolicy widening or Inscription mutation.
Reviewer Lua/Python/hash commands and externalproofJSON read denied, no successful
execution, retry/bypass or filewrites. Executable/freeze/hash evidence primary-attributed,
not independently reproduced. Primary rehashed all4reviewed files/artifact afterreview:
PASS/unchanged. Reviewed README5e745682... is before primarygate-only update below;
no runtime/test/artifact changes. PlatformN/A; no publication/releaseapproval.

Primary accepts bounded local/static E01 slice only. NativeEnchanting fields/normaluse/
closedreloadcache remain NOTRUN beyond identitycommand. User-scopedupdate perREADME
then ownreadyEnchanting `/ca scan`→`/ca`, compare skill/gear/concentration/Unspent and
responsiveness/errors. Moxie/numericKnowledge unknown expected; Detailsunsupported.
No fullselftest/Detailsrefresh/newcrafting/spending/reset or agentinstallation. Closed/
reloadchecks laterifneeded, fullnative stress still INCOMPLETE87/149.

## E01 user native value comparison / normal use confirmed — 2026-11-10

User: “Yes skill, equipment, concentration, and unspent KP match the native UI and
I noticed no performance issues or errors.” Response to reviewed E01 scan/dashboard
instructions. Affirmative native comparison and normal-use responsiveness/error
absence in reported scope. No current numeric balances, installed hashes, measured
latency or individual stat/enchant/cap/API/failure-path audit supplied or inferred.

Nextread-onlyround: close nativeEnchanting, close/reopen `/ca` without scan/Details
refresh; knownvalues should remain saved/lastobserved, relativeage mayincrease. Reload
persistence follows separately. Both cache checks stillpending; no source/test edits,
newinstallation/fullselftest or broaderT02/release acceptance. Moxie/numericKnowledge
remain unknown and Details unchanged/unsupported. Fullnative87/149INCOMPLETE retained.

## E01 closed-context cached values confirmed — 2026-11-10

User “Yes” confirms same saved Enchanting values after closing nativeprofession and
reopening `/ca` without scan. Scoped closed-context preservation, not reloadproof or
every transientfailure path. Native valueagreement/responsiveness evidence retained.
Nextprofessionclosed `/reload` then `/ca` before anynewprofessionopen/scan; same saved
values mustsurvive with expectedageincrease. Reloadpending; no source/test/update/
Detailsrefresh/fullselftest or broaderacceptance requested.

## E01 reload persistence confirmed; focused sequence complete — 2026-11-10

User: “Yes the same values suvive,” replying to reloadwithEnchantingclosed then `/ca`
before professionopen/scan. Record observed savedvalue survival, not localfixture
inference. Together with reportednativevalueagreement, no noticedperformanceissues/
errors and closed-contextpreservation, focused E01 validation is COMPLETE for the
bounded slice. No exactbalances, measuredlatency/allAPI/gear-stat-enchant-cap edgecase
audit or completeEnchanting/T02/release acceptance inferred. No furthercachecheck,
source/test/update/fullselftest requested by this confirmation.

Next primary/user evidence is EnchantingMoxie candidate3258 name/balance comparison;
source/query recorded inQ03. Moxie mapping not yet enabled; numericKnowledge remains
unknown. Details unchanged/unsupported/parked; fullnative87/149INCOMPLETE retained.

## E02 delivery — 2026-11-10 — implementation COMPLETE; review/native display pending

User authorizes pre-inclusion of all11 supplied Moxie IDs and checking Moxie in each
profession's initial native dashboard comparison rather than a separate discovery
round. Native user observation: `3258 Artisan Enchanter's Moxie 415`, agrees with native
Enchanting UI. This is currency evidence, **not yet acceptance of the E02 dashboard
display**. Balance415 is never a default. Older E01 unsupported-Moxie statements and
query instructions above are historical, superseded by E02, not rewritten evidence.

### Exact implementation / provenance

Only production `CraftArmy/Data.lua` changes: replace the old one-entry Moxie table
with a stable-internal-English-keyed `Data.moxieCatalog` and two numeric active
references:2913→catalogue.Inscription,2909→catalogue.Enchanting. No localized label
lookup, new profession identity, default quantity, collector/schema/UI change.

| Internal identifier | Currency | Provenance / status |
| --- | --- | --- |
| Alchemy | 3256 | User-supplied list2026-11-10; not native-verified here |
| Blacksmithing | 3257 | User-supplied list2026-11-10; not native-verified here |
| Enchanting | 3258 | User native currency query/UI agreement2026-11-10 |
| Engineering | 3259 | User-supplied list2026-11-10; not native-verified here |
| Herbalism | 3260 | User-supplied list2026-11-10; not native-verified here |
| Inscription | 3261 | Original `T01 user currency query; 70783` retained |
| Jewelcrafting | 3262 | User-supplied list2026-11-10; not native-verified here |
| Leatherworking | 3263 | User-supplied list2026-11-10; not native-verified here |
| Mining | 3264 | User-supplied list2026-11-10; not native-verified here |
| Skinning | 3265 | User-supplied list2026-11-10; not native-verified here |
| Tailoring | 3266 | User-supplied list2026-11-10; not native-verified here |

The other9 entries remain dormant; gathering remains outside crafting-only scope.
Future onboarding's initial native comparison includes then-current Moxie; activate
the catalogue entry only after its profession identity is verified. Numeric Knowledge
remains exact Inscription-only, Enchanting raw unsupported/numbers unknown, existing
Details unsupported/parked. Core/Collectors/Knowledge/Details/schema/ViewModel/
Dashboard/Commands/TOC/checkers/runners/diagnostics/review artifacts are unchanged.

### Authorized fixture adaptations and additions

Original220 cases/helpers/runner remain byte-exact. All11 E01 cases remain in order;
only these4 mapping-dependent cases change:
1. `E01 Inscription identity unchanged and other expansion identities still unmapped`:
   expect Enchanting3258 rather than nil; other identity/scope assertions unchanged.
2. Former missing-Enchanting-map case becomes genuinely missing-map regression:
   isolated `collectorContext` wrapper copies/projects identity.skillLineID to explicitly
   synthetic60009. Only this fixture's concentration/unspent mocks accept60009. No
   global/live registry mutation. Retains unsupported/no last, no3261 query, adds no3258
   query, keeps `noMoxie` unknown/nozero/noattention and repeated scan checks.
3. Failedreads: observed synthetic17 retained at originaltime100 after error at110;
   explicitly stale/nonfresh, no Moxie attention. All non-Moxie assertions unchanged.
4. ReopenedDB: saved synthetic17 rendered without freshness/collection, time100;
   all non-Moxie snapshot/gear/values/read-only assertions unchanged.

The only E01 local helper change permits3258 in its currency mock, with an explicit
synthetic17 comment (not native415). Other7 E01 case bodies, including both rejecting
Knowledge cases, are byte-identical. `noMoxie` itself is unchanged.

Separate marked `E02 BEGIN`/`E02 END` block adds7 cases: exact11-entry provenance/unique
IDs and only2 active mappings/unchanged identity scope; actual injected collector
reads3258, dynamic17/0/600/601/29 and strict>600 attention; nil/error/missing/negative/
fraction/string/NaN/infinite reads preserve last601/time or stay unknown on first
failure; successful recovery42; Inscription83→0 and Enchanting601 isolation; closed
context last-observed attention; savedDB/render API traps proving no active/dormant
currency reads. Repeated scans use checkpoints. All balances/other non-native data are
synthetic, not client evidence. No limits/workload/runner reductions or assertion skips.

### Actual local validation / historical fixture-only failure

Inspected both standalone Lua runners and both Python scripts before executing them.
Baseline supplied by primary:231/231+744K6/565K7+23/23/bothPythonPASS; no baseline failures.

- First `lua5.1 tests/dashboard.lua` exit1:235PASS/3FAIL; all231 retained cases PASS.
  Three new E02 cases expected plain601 instead of existing fresh/stale attention
  markers. K6/K7 not reached. Fixed only new E02 exact cell expectations to include
  the existing colored markers; numeric, warning and freshness assertions retained.
  Historical log `/tmp/opencode/craftarmy-e02-dashboard-first.log` retained.
- Second same command exit0:238PASS/0FAIL,744K6/565K7 PASS, noINCOMPLETE. Log
  `/tmp/opencode/craftarmy-e02-dashboard-second.log`. Subsequently added explicit
  stale/nonfresh/time assertions to the authorized E01 failedreads adaptation.
- Final command:
  `lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-e02-dashboard-final.log 2>&1; result=$?; tail -n 12 /tmp/opencode/craftarmy-e02-dashboard-final.log; exit "$result"`
  →exit0,**238PASS/0FAIL/noINCOMPLETE**, **744 K6 /565 K7** PASS. All original220 plus
  retained11 E01 and7 E02 executed; supplements are standalone fake-predicate/soundness
  checks, not target-client API/performance evidence.
- `lua5.1 tests/run.lua` →exit0,**23/23** diagnostic pure fixtures PASS.
- `python3 tools/check_dashboard.py` →exit0,PASS:16 required files, exact TOC/order/
  paths/metadata/SavedVariables/no dependencies,23 Markdown/78 links/anchors and8
  diagnostic hashes unchanged. Structural only, not Lua/native evidence.
- `python3 tools/check_diagnostics.py` →exit0,PASS:9 required files/exact packaging/
  single SavedVariables. Structural only, not Lua/native evidence.

### Byte proofs / comparison boundary / frozen hashes

External primary `/tmp/opencode/craftarmy-e02-baseline/manifest.json` read denied once
(`external_directory`), **no retry or bypass**. Primary actual62-file comparison is
still required. Permitted writer-start62-file copy at
`/tmp/opencode/craftarmy-e02-writer-preedit`, manifest SHA256
`630b84dad2fcf64f1d1f826430e5fe6a7cb90ec55941a0d62c432a6bc5a121b1`.
Primary after-baseline PLAN/TASKS/Q03 edits are intentional and already present in this
writer snapshot; writer has not edited those planning decisions or historical suffix.

`python3 - <<'PY'` read-only inline exact inverse/manifest checks executed PASS:
- Removing only catalogue/new active mapping region and reinstating the original
  single Moxie line reconstructs the **entire Data.lua** baseline byte-for-byte.
- Removing E02 and reversing only4 named E01 case chunks/local currency-helper delta
  reconstructs **entire SelfTests.lua** writer baseline. Other7 E01 bodies exact;
  failedreads/reopened cases also checked against explicit Moxie-only replacement
  strings, preserving every unrelated assertion. Missing-map Context projection and
  no-query/nozero/noattention checks present; no Data registry assignment in tests.
- Removing marked E01/E02 reconstructs original220/helpers/runner381362bytes SHA256
  `ad193897185f4cb626cf1026450f952f701a806e22edfb037ea014342858edf5`.
- All57 unowned files frozen, same62 workspace paths; README exact new-gate inverse,
  old evidence exact prefix and historical E01/T02 task suffix unchanged.

An attempted optional external proof-script creation was permission-denied; no script
was created/retried or written elsewhere. The executed proof was inline read-only,
not an alternate write to the denied path. Primary may reproduce from snapshot/files.

Frozen SHA256 (final source/test/README):
```text
dcae646c569f8b449f6ed1ddaa8d146d3d02aff8e4e7a0824ac47ecf144fea84  CraftArmy/Data.lua
b699af17c15199c517498f0cfbfde3a12f195fe09d550a0badf4fa272ea12e49  CraftArmy/SelfTests.lua
a0dda541a03424115b5966630020b7cc279d9a406edd0124e34e74732cd7ee6d  docs/dashboard/README.md
```
Final evidence hash belongs in TASKS E02 Report back, avoiding a self-referential hash.

### Stop / next gate

Implementation COMPLETE, **independent review/acceptance INCOMPLETE**. Primary compares
actual baseline then obtains independent read-only scoped review before any update
advice. Native3258 **dashboard** agreement remains pending despite native query/UI
mapping evidence. Eventual focused check after review/update: one ordinary ready own
Enchanting scan, compare dashboard Moxie to then-current native balance; report errors/
warnings/unresponsiveness/mismatch. Do not repeat E01 cached/reload checks, Details
refresh or full native selftest. Full native stress stays **INCOMPLETE87/149**.
No executable writer blocker; no native/game/install/dependency/Git/release operation
performed. Platform review N/A (no platform/CI/hosting/release effects). Publication
and broader T02 field/profession/API acceptance remain separate, not granted by tests.

### E02 final freeze confirmation / proof-harness correction

After the delivery append, repeated `python3 tools/check_dashboard.py && python3
tools/check_diagnostics.py` →exit0,bothPASS (23Markdown/78links/8 diagnostic hashes).
Read-only inline final proof initially rejected literal equality of original case81's
PASS label: the frozen runner intentionally appends `; scan2 timings unavailable
(clock missing)` in standalone Lua. Diagnostic comparison found only that one label
suffix; all220 names/counts were present. Corrected **proof expectation only**, exactly
accounting for that known suffix, and reran →PASS:238 actual PASS lines, original220
order, noFAIL/INCOMPLETE,744K6/565K7. No source/test/runner change or timing claim.

Final proof also reconfirmed source/test/README hashes unchanged since full inverse
proof,57 unowned files frozen, same62 workspace paths, evidence append-only and exact
historical E01/T02 task suffix. Changed paths are exactly Data.lua,SelfTests.lua,
dashboard README/evidence and TASKS E02 state/report. Primary actual-baseline comparison
and independent review remain pending; no writer source work remains.

## E02 primary exact comparison / independent static review PASS — 2026-11-10

Primary actual62-file pre-E02 comparison:7expected deltas,55otherpaths unchanged,
no unexpectedpaths. Data exactcatalogue-region inverse; original220/helpers/runner
inverse; only4E01cases+authorizedhelper adapted,7otherE01bodies frozen inclnegative
Knowledge checks;7newE02. READMEgateinverse/historicaltask suffix/evidenceprefix PASS.
Generated3file348line21649byte `docs/dashboard/e02-review.diff` SHA256
`c503e0047b8d660924ea133ec8a80654d4d29f5e6ae0d5353fdfa0e4a322fc68`.
Primaryproof `/tmp/opencode/craftarmy-e02-primary-proof.json`; actualfullrerun
`/tmp/opencode/craftarmy-e02-primary-dashboard.log`:238PASS/0FAIL/noINCOMPLETE,
744K6/565K7,diagnostic23/23/bothPythonPASS. Sourcehashes match deliveryfreeze above.

Independent verifier `ses_e3d77eba8ffeDnOMRQNykg6wjl`: COMPLETE/scopedstaticPASS,
no findings/blockers. Completeartifact/currentintegration/scripts/testeffectiveness
reviewed; catalogue/activation/provenance, strictthreshold/failure/staleness/isolation
semantics correct. All reviewer executable/hash attempts and externalproofJSON read
denied; none successful, no retry/bypass/filewrites. Executable/hash/freeze proofs
primary-attributed. Primary postreview3file+artifact rehash PASS/unchanged. Reviewed
READMEa0dda541... is historical before primarygate-only update; runtime/test/artifact
unchanged. PlatformN/A, no releaseapproval.

Primary accepts boundedlocal/static E02; nativeMoxiedashboard display stillpending.
User scopedData+SelfTests update ifonE01 perREADME then normalreadyEnchanting scan and
currentbalance comparison only. No newIDqueries, E01cache/reload repeat, fullselftest,
Detailsrefresh, agentinstallation or spending. Futureonboarding includes suppliedMoxie
in initialnativecheck; gatheringdormant, numericKnowledge/Details unchanged.

## E02 native dashboard balance confirmed — 2026-11-10

User: “Yes it matches the native balance.” Reply to reviewedE02update/normalEnchanting
scan/Moxiecomparison. Focused native dashboardbalance agreement observed; E02bounded
scope COMPLETE alongside local/staticPASS. No newexactbalance/installedhash/latency/
native>600 or failurepath proof inferred. No furtherE02update/cache/reload/fullselftest/
currencyquery needed. NumericEnchantingKnowledge remains unverified; Detailsparked,
broaderT02/release separate. Documentation-only update, no newsource/testexecution.

## E03 implementation delivery — 2026-11-10

**Implementation/local fixtures delivered; primary actual-baseline comparison and
independent review INCOMPLETE. No addon update advice or native acceptance yet.**

Only production `CraftArmy/Data.lua` changes: six expansion11 identities, each with
`E03 user batch child-profession query 2026-11-10` provenance, and active references
to existing supplied Moxie catalogue objects:

| Profession | Child / parent / family | Catalogue Moxie ID |
| --- | --- | --- |
| Alchemy | 2906 /171 /3 | 3256 |
| Blacksmithing | 2907 /164 /1 | 3257 |
| Engineering | 2910 /202 /8 | 3259 |
| Jewelcrafting | 2914 /755 /12 | 3262 |
| Leatherworking | 2915 /165 /2 | 3263 |
| Tailoring | 2918 /197 /7 | 3266 |

Existing Inscription2913/773/13/11→3261 and Enchanting2909/333/9/11→3258/provenance
are preserved. All catalogue values/provenance and other registries stay unchanged;
new six Moxie IDs remain user-supplied/not native-verified here. No default balances,
localized identity lookup, config/tab constants or gathering identities/families.
Core/Collectors/Knowledge/KnowledgeCheck/Details/UI/schema/limits are frozen. Numeric
Knowledge/raw persistence and Details remain exact Inscription-only; no policy leak.

Exactly two old scope cases adapt obsolete two-mapping expectations: E01 `Inscription
identity unchanged and other expansion identities still unmapped` (name now says
unknown identities) uses the exact eight-key allowlist/count; E02 `exact eleven-entry
catalogue provenance unique IDs and unchanged active scope` checks eight references
and tuples/provenance, retaining all eleven catalogue/family/currency assertions.
Other236 case bodies/helpers/runner are byte-preserved, including synthetic60009
missing-map rejection and all prior negative Knowledge/Core guards. Original220 exact.

13 marked E03 cases include six separately registered actual injected family scans,
exact tuples/localized labels, conflicts/unknown/gathering/roster rejection; dynamic
synthetic concentration/config/tab IDs and per-family Moxie balances/correct IDs;
distinct synthetic character GUIDs with prior Inscription/Enchanting and each prior
character graph/reference unchanged; family filters/real dashboard rendering; all
six nil-valued unsupported raw attempts, unknown numeric trees/read-only Details;
fully eligible Inscription control graph relabeled to each identity still rejected
by numeric policy, direct Core payload/candidate and active/archive saved scope;
nil/error/invalid first currency reads stay unknown, later generic/currency/all-three
gear failures retain coherent prior values/time; closed/reopened six-character DB
renders with API/collector traps and no fabricated freshness. Registry graph/reference
checks never mutate live Data. Repeated scan/graph units have outer checkpoints; full
workloads/limits retained. All non-native fixture values are explicitly synthetic;
no observed native config/tab IDs serve as fixture defaults or API proof.

Primary-supplied runtime baseline238/238+744K6/565K7+23/23/bothPythonPASS, no failures.
Read AGENTS/PLAN/complete E03, loaded agent-handoff, inspected both standalone Lua
runners and both Python checkers before executing. External actual primary baseline
manifest read denied once (`external_directory`); no retry/bypass. Local exact proofs
use permitted writer-start63-file copies `/tmp/opencode/craftarmy-e03-writer-preedit`,
manifest SHA256 `674fb06e8df39e3d597fc6dc878bfdf0a382f3802697b8dd3b7ec9ad283ccc7b`.
Primary must separately compare actual `/tmp/opencode/craftarmy-e03-baseline`;
PLAN/TASKS/Q03 primary changes after that snapshot are intentional.

Executed first `lua5.1 tests/dashboard.lua` (stdout/stderr retained in
`/tmp/opencode/craftarmy-e03-dashboard-first.log`): exit1,250PASS/1FAIL; original238 all
PASS,12 newPASS. New isolation fixture indexed a saved character by `.guid`, which
does not exist in the stored value (GUID is the map key). K6/K7 not reached. Corrected
only new fixture lookup; reference/no-mutation checks retained and expanded to all
prior characters, gear failure checks expanded to all three slots. No production fix.
Second identical command, log `/tmp/opencode/craftarmy-e03-dashboard-second.log`:
exit0,251PASS/0FAIL/noINCOMPLETE,744K6/565K7 PASS. This is fixture execution, not native
API, field semantics, responsiveness, Moxie acceptance or target-client timing proof.

New six initial native dashboard comparisons remain pending: normal fields plus Moxie
in one batch, normal-use/errors/warnings, then coordinated saved-data checks as needed.
No separate currency-ID queries or automatic accepted E01/E02 retest. After primary
comparison and independent review, eventual E02-based user update is Data+SelfTests
only; not advised now. Knowledge evidence capture is separate, Details parked,
full native stress INCOMPLETE87/149 unchanged, guides/release unaccepted. No child,
installation/dependencies/live WoW/gameplay/Git/publication operation performed.

### E03 final local checks / exact writer-start proofs — 2026-11-10

Approved final commands, all **exit0** (the dashboard wrapper propagates Lua's status):

```sh
lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-e03-dashboard-final.log 2>&1; result=$?; tail -n 17 /tmp/opencode/craftarmy-e03-dashboard-final.log; exit "$result"
lua5.1 tests/run.lua && python3 tools/check_dashboard.py && python3 tools/check_diagnostics.py
```

- Dashboard: **251 actual PASS /0 FAIL /no INCOMPLETE**, including all238 retained
  cases and13 E03; **744 K6 /565 K7** unchanged standalone checks PASS.
- Diagnostics: **23/23** unchanged pure cases PASS.
- Python dashboard: PASS,16 required files, exact TOC/order/metadata/paths, isolated
  SavedVariables/no dependencies,23 Markdown/79 local links/anchors,8 diagnostic hashes
  unchanged. Python diagnostics: PASS,9 required files/exact TOC/one SavedVariables.
- Python checks are structural only. Lua fixtures are synthetic correctness evidence;
  none is native API, responsiveness, complete Knowledge or Moxie field acceptance.

Executed read-only `python3 - <<'PY' ... PY` using writer-start manifest/file copies
(not the denied primary actual baseline), asserting and printing these byte proofs:

1. Same63 workspace file paths,58 unowned files hash-identical, including all frozen
   production modules, standalone runners/checkers/diagnostics/PLAN/Q03/Q05 and prior
   review artifacts. Exactly the five owned paths differ. No new/deleted paths.
2. Remove `-- E03 BEGIN:` through `-- E03 END` and its following blank line; replace
   only the two named current scope-case chunks with their writer-start chunks.
   Result equals the entire old SelfTests byte-for-byte. Thus other236 case bodies,
   every helper and Tests.Run/runner remain frozen. Prior238 registrations retained;
   E03 has7 direct registrations plus a six-family loop =13 runtime cases.
3. Exact replaced old lines are only E01 case title/two-key allowlist/count2, and
   E02 two-key active allowlist/catalogue selection/count2 plus two-identity tuple/
   provenance expectations/count2. All other lines of those cases remain verbatim.
   New explicit8-key/tuple tables/checks replace the obsolete scope expectations;
   catalogue11/unique-ID/provenance/family/unknown/synthetic60009 rejection retained.
4. Remove E01/E02/E03 blocks: full original220/helpers/runner reconstruction is
   **381362 bytes**, SHA256
   `ad193897185f4cb626cf1026450f952f701a806e22edfb037ea014342858edf5`.
5. Data inverse replaces only adjacent expansion comment, removes six exact entry
   lines and replaces expanded Moxie assignment with original two references. Entire
   result equals writer-start Data bytes. Catalogue/provenance, existing identities,
   functions/other registries all exact; no config/tab constants or production gates
   changed. README E03-prepend inverse equals complete old README bytes.
6. Evidence starts with complete old evidence bytes; entire TASKS suffix beginning
   `Historical E02/E01/T02 contracts below` and its preceding separator is byte-exact.

Frozen source/test/current README SHA256:

```text
2202fca636a9249fbfc70b05e88891566e500784fefe48d83ffbf385cfeab71d  CraftArmy/Data.lua
868af0b2d59d7d851db6f664d97bba11325d8122dda13450a334d960de1ff504  CraftArmy/SelfTests.lua
66376d7277c6e3ba70908b501e02e28670355bc507ba1dd16cabf060147168a0  docs/dashboard/README.md
```

Final evidence hash is recorded in E03 TASKS Report back, not self-hashed here. Exact
next action PRIMARY: independently compare actual63-file pre-E03 snapshot (writer
access denied once/no retry), obtain read-only scoped review and persist findings
before any update advice. No writer source remainder or design blocker. Native six-
profession initial normal-field/Moxie/normal-use/cache acceptance remains pending;
full native INCOMPLETE87/149 preserved. Implementation is not independent verification,
native acceptance or release approval. Platform review N/A: no platform/release effects.

## E03 primary comparison / independent scoped static review PASS — 2026-11-10

Primary actual63-file pre-E03 comparison PASS:7expected deltas,56baselinepaths frozen;
Data exactregistry inverse, SelfTests full238 inverse exceptauthorizedcases222/232,
236othercases/helpers/runner+original220 exact, READMEprependinverse, historicaltasks/
evidenceprefix PASS. Firstproofshell syntaxerror occurred beforeexecution; corrected
read-onlyproof PASS with no source/test changes. Generatedactual3file437line28195byte
`docs/dashboard/e03-review.diff` SHA256
`7184746a259caef05f1426a738e76f1444218b29a1838f3afd5192a6320c19b0`.
Proof `/tmp/opencode/craftarmy-e03-primary-proof.json`; primary actual rerun
`/tmp/opencode/craftarmy-e03-primary-dashboard.log`:251PASS/0FAIL/noINCOMPLETE,
13actualE03cases inclsixfamily scans,744K6/565K7,diagnostic23/23/bothPythonPASS.

Independentverifier `ses_e3d563689ffekf7MTaL24EAMDz`: COMPLETE, scopedstaticPASS,
no findings/blockers; completeartifact/currentintegration/teststrength/scripts
reviewed. Exactidentities/Moxierefs correct; no newgathering/config/tab/balanceconstants
or numericpolicy/Core/collector/Details/UI changes. All4reviewercommand/hash attempts
and externalproofJSON read denied; no successfulexecution/retry/bypass/filewrites.
Executable/hash/freeze proofs primary-attributed. Primary postreview3file+artifact
rehash PASS/unchanged. Reviewed README66376d72... precedes primarygate-only instructions
update; runtime/test/artifact unchanged. PlatformN/A; no releaseapproval.

Primary accepts boundedlocal/static E03, not six-profession nativefield/Moxie/cache/
normaluse readiness. Nextuser scopedData+SelfTests update ifonE02 perREADME, sixownready
profession scans/nativefield+Moxie comparisons inonebatch. No separateIDqueries or
repeatacceptedEnchantingcache/Moxie/fullselftest/Detailsrefresh. NumericKnowledge still
unknown outsideInscription; safecompletecapture design follows separately.

## E03 native six-profession reported values/reload; Resourcefulness gap — 2026-11-10

User checked Alchemy,Blacksmithing,Leatherworking,Tailoring,Engineering,Jewelcrafting
and confirms skill/Moxie/concentration correct and survivingreload. Accept reported
3field agreement/persistence acrosssix, not unreported equipment/UnspentKP/errorabsence/
performance/timing/allAPI readiness. Exactcurrentbalances and installedhashes not given.
Existing local/static evidence retained; no need repeat acceptedchecks.

User reports Resourcefulnessenchant showing?. StaticData registry contains only8005
Multicraft; positiveunmapped IDs preserve presence/ID and show unknowncategory, but
nativecause not proven. NextShift-hover affectedEnchantcell to obtain exactID and
typednativeenchantlabel/profession, screenshot acceptable. No newscan/capture/update/
fullselftest/source change. BroaderT02/API/Knowledge/release gates remain separate.

## E04 supplied enchant categories / Engineering7977 implementation — 2026-11-10

User's Engineering diagnostic is `Enchant: yes; ID 7977; stat: ?; amount/rank unknown`;
user identifies Resourcefulness. User explicitly supplies all six exact IDs for
pre-inclusion then ordinary display verification, not repeat ID discovery:

| ID | Canonical category | Provenance boundary |
| --- | --- | --- |
| 7977 | Resourcefulness | Engineering equipped diagnostic + user category 2026-11-10 |
| 8005 | Multicraft | Original `T01 user ID + typed line; 70783`, unchanged |
| 8035 | Ingenuity | User-supplied list 2026-11-10; not native-verified here |
| 8033 | Deftness | User-supplied list 2026-11-10; not native-verified here |
| 8003 | Finesse | User-supplied list 2026-11-10; not native-verified here |
| 7975 | Perception | User-supplied list 2026-11-10; not native-verified here |

Only Data.lua changes in production: exact six-entry enchant registry and D/F/P
category labels. Existing four stat API keys, eight crafting scope, Moxie/other
registries/functions and all collector/Core/UI/Knowledge/Details/schema bytes stay
unchanged. D/F/P synthetic display tests are not gathering/equipped compatibility
evidence. No amount/rank/quality/default/inferred variant or parsing added. Historical
one-ID/discovery-needed descriptions above are superseded, not rewritten evidence.

SelfTests changes only the obsolete final allowlist/count assertion in named R6 full
crafting names case to exact six ID/categories/count6; all other old lines remain.
Marked E04 block adds13 runtime cases: exact entries/dated honest provenance and entry
shape; seven category labels with unchanged four API keys/eight crafting scope; six
separately reported ready Enchant→actual Gear→typed Core snapshot→full-name row/ID and
typed-line diagnostics; actual own Engineering2910/202/8 scan saving7977Resourcefulness;
unknown9999 positive/confirmed absent0/missing/unready/conflicting distinctions; coherent
gear/metadata failure preservation; reopened cached dashboard under API/collector traps;
old saved nil category remains unknown until ordinary own rescan. Synthetic GUID/item/
skill/currency/config values are distinct and do not claim native behavior. Known IDs
never infer enchant amounts/ranks, main cells omit amounts, observed tool amounts and
unknown base/enchant attribution remain diagnostic. No global Data mutation; repeated
scan/commit units have checkpoints. Existing Knowledge negatives and limits retained.

Usage-limit interruption occurred after piece1 Data edit only. Primary recovery check
confirmed only Data + intentional PLAN/TASKS/Q03 planning deltas against actual64-file
baseline; same writer resumed without discarding partial work. External baseline
manifest read denied once (`external_directory`), no retry/bypass. Writer proofs use
authorized64-file `/tmp/opencode/craftarmy-e04-writer-preedit`, manifest SHA256
`a228fd4b3de57997ea771eb624c31743c0e9260d4f103ad8dbb7d1d9fd40a836`.
Primary actual pre-E04 baseline comparison remains required after completion.

First `lua5.1 tests/dashboard.lua` exit1:263PASS/1FAIL, all251priorPASS/12newPASS;
sole new unknown/unready fixture incorrectly required literal false missing-enchant
flag rather than existing nil when no enchant object is available. Corrected only
NEW assertion to require not-confirmed-missing, retaining exact `?` cell and confirmed
absence checks. No production expansion or old assertion changes; K6/K7 not reached
in that run. Log `/tmp/opencode/craftarmy-e04-dashboard-first.log`. Second identical
command exit0:264/264, unchanged744K6/565K7; log
`/tmp/opencode/craftarmy-e04-dashboard-second.log`. Final full checks/proofs below.

Engineering7977 has equipped/category evidence but **new dashboard display is native-
pending**. Other four supplied IDs have no native evidence here. Next normal own
Engineering scan after primary comparison/independent review will derive and save the
category; cached/hover/offline view does not migrate saved unknowns or query APIs.
Eventual E03-based update is Data+SelfTests only, preserving backups/saved data; no
update recommendation before review. First focused user check is Resourcefulness
display/normal-use behavior only, other categories as encountered in onboarding. No
repeated accepted Moxie/skill/concentration/cache/reload checks, new default ID queries,
full native selftest or Details refresh. Gathering stays out of scope; full native
selftest remains INCOMPLETE87/149. Platform N/A; no installation/release approval.

### E04 final approved local checks and writer-start freeze proof

Scripts were inspected before execution; existing `/usr/bin/lua5.1` only, no installs.
Primary-supplied unchanged baseline251/251+744K6/565K7+23/23/bothPythonPASS had no known
failures. Exact final commands executed from repository root:

```sh
lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-e04-dashboard-final.log 2>&1; result=$?; tail -n 17 /tmp/opencode/craftarmy-e04-dashboard-final.log; exit "$result"
lua5.1 tests/run.lua && python3 tools/check_dashboard.py && python3 tools/check_diagnostics.py
```

Both exit0. Dashboard264PASS/0FAIL/noINCOMPLETE, all251 prior cases +13new, K6744/K7565
unchanged. Diagnostic23/23PASS. DashboardPythonPASS16requiredfiles/23Markdown/80local
links/eightdiagnostichashes unchanged; diagnosticsPythonPASS9requiredfiles/oneSavedVariables.
These execute local synthetic fixtures/structure only, not native API behavior/latency.

Read-only inline `python3 - <<'PY'` exact inverse/manifest/log proof exit0/PASS; report
`/tmp/opencode/craftarmy-e04-writer-proof.json` SHA256
`4441853993a069b48513500f2d1b085fc75d46b776164c098519f606bb88ac56` records pre-final-
evidence/task hashes. Source/test/README frozen at those hashes below. Exact proof:

- Remove only marked E04 block (13449bytes) and reverse only the two-line exact six-ID
  allowlist/category/count assertion to original final one-ID assertion → entire old251
  SelfTests file429029bytes, SHA256
  `868af0b2d59d7d851db6f664d97bba11325d8122dda13450a334d960de1ff504`.
  The named R6 case's every other byte, all other250 prior cases, helpers and runner
  are byte-identical. No test skips/workload/limit/stress/Knowledge-negative changes.
- Data equals exact old Data with only original enchant line expanded to supplied six
  entries/provenance and one D/F/P category-label line inserted. Exact inverse equals
  whole writer-start file;8005 original provenance and all other registries/functions
  including four stat API keys/eight crafting scope/Moxie remain byte-identical.
- Same64 repository paths, exactly5owned deltas and59unowned frozen. README exact E04
  prepend inverse; evidence original prefix; complete historical E03/E02/E01/T02 TASKS
  suffix all exact. No primary-owned PLAN/Q03/Q05 changes by writer. Primary recovery
  TASKS edits are intentionally preserved. All64 snapshot copies match their manifest.
- Final runtime log has264actualPASS lines,251 non-E04/13E04, all six separately reported
  known-ID cases once each, noFAIL/INCOMPLETE, exact744/565 supplement counts.

Frozen implementation/README SHA256:

```text
42a256aeff21e54fe14204ec274c3aae09370d812a61b4f87b94b16830169955  CraftArmy/Data.lua
52454c27ad573698f0f17b5c2f6620b05978e2936ea2550d7140539228f95449  CraftArmy/SelfTests.lua
42c095299b2cc3a3c64c95fccda534740592c080bbc47ba590ef0b78aa263145  docs/dashboard/README.md
```

Final evidence hash is recorded in E04 TASKS Report back (no self-hash). No writer source
remainder or design blocker. PRIMARY next compares actual pre-E0464-file baseline and
obtains independent scoped read-only review before any user update advice. Writer-start
proof does not replace actual comparison. Engineering7977 new display/native normal-use
check pending; other four supplied IDs unverified. Implementation COMPLETE is not
independent review, native acceptance, installation or release. No children, native
client, game actions, dependencies, Git, release/deployment or timing chase performed.

## E04 primary actual comparison / independent static review PASS — 2026-11-10

Primary actual64-file pre-E04 comparison PASS:7expected source/docs/planning deltas,
57otherpaths unchanged; Data exactmapping/label-only inverse, whole old251SelfTests
inverse after onlyfinalregistryassertion reversal/E04removal,250othercases/helpers/
runner frozen, READMEprependinverse/evidenceprefix/historicaltasksuffix PASS.
Generated3file295line19844byte `docs/dashboard/e04-review.diff` SHA256
`f4c0084ebf7acae8988b285e1c1646fab30d44202719dca040f8aef9c83214d4`.
Proof `/tmp/opencode/craftarmy-e04-primary-proof.json`; primary actual rerun log
`/tmp/opencode/craftarmy-e04-primary-dashboard.log`:264PASS/0FAIL/noINCOMPLETE,
13actualE04results incl6IDrenders,744K6/565K7,diagnostic23/23/bothPythonPASS.

Independent verifier `ses_e3c0aad7fffeEz7AYF34RufCaK`: COMPLETE, scopedstaticPASS,
no findings/blockers. Completeartifact/currentintegration/tests/docs/scripts reviewed;
exact6IDs/labels/8005provenance and unknown/absence/readiness/persistence safeguards
correct. All reviewer executable/hash attempts and externalproofJSON read denied;
none successful, no retry/bypass/fileswritten/children. Executable/hash/freezeproofs
primary-attributed. Primary postreview3file+artifact rehash PASS/unchanged. Reviewed
README42c09529... precedes primarygate-only instructionsupdate; runtime/test/artifact
unchanged. PlatformN/A; no releaseapproval.

Primary accepts boundedlocal/static E04. NativeEngineering7977newlabel and other4
suppliedcategories remain pending; fixtures don'testablish equippedcompatibility.
Next scopedData+SelfTests userupdate ifonE03 perREADME, normalownreadyEngineering
scan and Resourcefulness Enchantlabel/error-warning-responsiveness check only. No
repeatacceptedMoxie/skill/concentration/cache/reload/fullselftest or Detailsrefresh.
No nativeclient installation/game action performed by agents.

## E04 native Resourcefulness label confirmed / absence report — 2026-11-10

User: “Yes, the enchant shows Resourcefulness.” Records observed7977labelagreement
afterupdate/scan, completing E04boundeddisplay gate; no newlatency/errorabsence or
other4IDnativecoverage inferred. User also reports known-unenchantedtools show?.
Statictrace identifies whole-toolmetadataReady gating even observedenchantID0 as a
possible cause. NextaffectedShift-hover screenshot/profession to distinguish this
from unready/missing/conflicting evidence. No source/test/update/newscan/selftest
requested. Blankconfirmedabsence vs?unknown remains required; no broadacceptance.

## E05 implementation / explicit-empty enchant fields — 2026-11-10

User reports known-unenchanted tools show `?`; affected Shift-hover says
`Enchant: unknown; invalid/missing enchant field`. Fresh observed Enchanting rod
screenshot: Runed Brilliant Silver Rod/item244176/slot20/rare/rank5; Resourcefulness110
is a tool-stat observation, not enchant evidence. Exact raw native link was not
supplied. Q03 records documented ItemLink zero-field omission and explicit empty
enchantID convention. Those establish a valid-format parser defect, not native
blank-display acceptance. E04 Engineering7977 Resourcefulness display is already
user-confirmed. Earlier empty-is-unknown/investigation statements remain historical.

Only production change: Collectors.Enchant capture `%d+` -> `%d*` for enchant field,
then `raw=="" and 0 or tonumber(raw)`. Explicit empty with its trailing delimiter is
zero; nil is never coerced to zero. Existing string/ready/integer/conflict/category
handling and return reasons/shapes retained. Missing delimiters, malformed/negative/
nonnumeric/overflow fields, unready instance and typed-positive conflicts stay unknown.
No Gear/Core/readiness/freshness/schema/ViewModel/UI/Data/Knowledge/Details changes.
Core's existing numeric exact-link same-instance preservation boundary is untouched;
this does not authorize broadening transient-failure borrowing for empty links.

SelfTests changes exactly one old valid `item:90000::0` expectation to require observed,
present=false/id0. All other bytes of that case and all263 other cases/helpers/runner
remain frozen. Nine marked E05 cases cover plain/full legacy/modern empty-vs0; missing/
malformed/nonnumeric/negative/overflow; strict readiness/conflicts; all six known
positive categories plus unknown9999 without amount/rank; real injected own Enchanting
2909/333/9 normal ready cached synthetic scan saving absence and main blank; old known
Ingenuity -> new observed empty clears it; unavailable same numeric-link metadata
retains coherent value/time, and closed-context empty snapshot retains time; first
failed/conflicting/malformed/unready readings remain?; unchanged metadataReady=false
suppresses even parsed absence; reconstructed old saved unknown renders without API
calls/migration/freshness mutation, then becomes blank only on normal ready own scan.
All IDs/stats/times/configs beyond verified identity/mapping are synthetic, not native
defaults or screenshot-payload proof. Private fixture DB/environment only, Data graph
reference guards, checkpoints between repeated scans. No registry/global mutation.

First `lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-e05-dashboard-first.log 2>&1; result=$?; tail -n 17 /tmp/opencode/craftarmy-e05-dashboard-first.log; exit "$result"`
exited0:273/273 (264 retained/one expectation adapted+9new), unchanged744K6/565K7.
No failing run or fixture correction. Preliminary read-only inverse proves entire
old264 SelfTests and exact two-line Collectors restoration. Final commands/hashes/
freeze proofs follow below; no native result inferred.

No cached migration/API reads; a normal ready own-profession scan is required for
oldunknown snapshots. Primary actual65-file baseline comparison and independent review
must precede update advice. Eventual E04-based scoped update is Collectors+SelfTests,
then one affected known-unenchanted tool's blank-vs-nativeabsence check only. Do not
repeat accepted field/Moxie/cache/reload tests or ID discovery/full native selftest/
Details refresh. Full native INCOMPLETE87/149 unchanged; required-field/API acceptance,
other supplied category coverage, Knowledge capture and Details improvements separate.

### E05 final local validation and writer-start freeze proofs

Inspected complete `tests/dashboard.lua`, `tests/run.lua`,
`tools/check_dashboard.py`, `tools/check_diagnostics.py` before execution; used existing
`/usr/bin/lua5.1`, no installation/dependencies. Primary supplied baseline264/264+
744K6/565K7+diagnostic23/23/bothPythonPASS; no baseline failures reported.
Final exact commands/results:

- `lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-e05-dashboard-final.log 2>&1; result=$?; tail -n 17 /tmp/opencode/craftarmy-e05-dashboard-final.log; exit "$result"`
  — exit0,273 actual PASS/0FAIL/noINCOMPLETE,264 old+9 E05, unchanged744K6/565K7.
- `lua5.1 tests/run.lua && python3 tools/check_dashboard.py && python3 tools/check_diagnostics.py`
  — exit0,23/23 diagnostic fixtures; dashboardPython16required/23Markdown/80links/
  eight diagnostic hashes unchanged; diagnosticsPython9required/oneSavedVariables PASS.
- Read-only inline `python3 - <<'PY'` exact inverse/manifest/pathset/prefix/suffix/log
  proof — exit0/PASS; report `/tmp/opencode/craftarmy-e05-writer-proof.json`, SHA256
  `9d1ceabb0055d5064cddfe34374c2cef95d0e9617f333b29936ea9ba130feb24`.
  Proof JSON hashes pre-final-evidence/task state; source/test/README are frozen.

External primary actual baseline manifest read denied once (`external_directory`),
no retry/bypass. Authorized writer-start snapshot
`/tmp/opencode/craftarmy-e05-writer-preedit` contains65files, manifest SHA256
`c27be310b6e1af7157f7f847b93b8d4ada9955acc1eeaf4066a600e7743de781`.
All snapshot copies match manifest. Same65repo paths, exactly5owned deltas,60unowned
files frozen, including Data/all other production/runners/checkers/diagnostics/prior
review artifacts and primary PLAN/Q03/Q05. Primary actual snapshot predates intentional
PLAN/TASKS/Q03 planning edits; primary comparison remains required.

Collectors inverse of exactly2 changed lines reconstructs whole original file; no
other production edits. Remove marked E05block12932bytes and reverse ONLY the single
valid-empty assertion line -> entire old264 SelfTests442666bytes SHA256
`52454c27ad573698f0f17b5c2f6620b05978e2936ea2550d7140539228f95449`.
All263other cases/helpers/runner and other lines of adapted case byte-frozen.
README E05prepend inverse equals original; evidence originalprefix and complete
historical E04/E03/E02/E01/T02 TASKSsuffix exact. Both dashboard logs independently
contain273PASS/9E05/noFAIL/noINCOMPLETE and unchanged supplement counts.

Frozen SHA256:

```text
10af464a948da209053c7f53443e625b127a4041586793f5f0115f7035d14d7b  CraftArmy/Collectors.lua
1b550ea572244aa9da8c2161f091429d92d4b000c436672ddf9b955e267e0309  CraftArmy/SelfTests.lua
54dd251966a1c7d8b86169690b7e7352813955b682fa3d41ba3ba11fbff9424c  docs/dashboard/README.md
```

Final evidence/task hashes are recorded in TASKS/external final-freeze report to avoid
selfhash recursion. Stop for primary actual-baseline comparison and independent scoped
read-only review before any update advice. Implementation/local PASS is not independent
verification, affected native absence/blank-display acceptance or release. Native check
NOT RUN; full native INCOMPLETE87/149 retained. PlatformN/A. No children, live game,
install, gameplay, dependency/Git mutation, release/deployment or timing chase.

## E05 amendment — rejecting valid-empty same-instance regression, 2026-11-10

Primary integration review rejects the parser-only delivery as incomplete: Core's
sameInstance still requires a nonempty enchant field, so identical valid-empty links
cannot retain coherent known history on transient metadata failures. PLAN/Q03/TASKS
authorize only that pattern alignment plus additive regressions/docs/proofs. The prior
273PASS report and hashes above remain historical, not acceptance of this gap.

BEFORE changing Core, added3separate runtime cases for ready valid-empty link seed ->
same slot/item/exact link with stats error, qualitynil, loading (isolated fixtures and
checkpoints), requiring entire original value/time/blank/nonfresh failedattempt. Added
one further case with7controls: changed item, changed link, changed slot, malformed
enchant, missing delimiter, missing link, and removed instance cannot borrow old data.
Preserved all numeric-link failure coverage and all prior assertions. New fixture's
global LastUpdated expects0s after a successful scan, while tool observation time must
remain100; corrected that setup before any run, not a weakened rejecting assertion.

Exact command:
`lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-e05-amendment-reject.log 2>&1; result=$?; tail -n 19 /tmp/opencode/craftarmy-e05-amendment-reject.log; exit "$result"`
->exit1,274PASS/3FAIL. All273prior tests plus new identitycontrols PASS. Each of stats
error/qualitynil/loading rejects on original successful time `173 ~= 100`.
K6/K7 not reached. Core byte-identical to amendment-start/original writer baseline,
SHA256 `991084ad0c48e30e9d0e51a3b3a6778c59077f53bdd2805f12908026ce4dcde1`.
Rejecting SelfTests SHA256
`0e9605e47eeb8a47d69c09045269650e1e22938b82acf736db6f18d84776dcf7`;
rejecting log SHA256
`914820d4438bf3336e416e557ddd40c382630f63eca2124a3e6e43df4342c885`.
This rejecting evidence is persisted before the authorized one-pattern Core fix.

### E05 amended correction / scope and native gate

Then changed ONLY Core.sameInstance's `a.link:match("item:%d+:%d+:")` to
`a.link:match("item:%d+:%d*:")`. Every other Core byte is frozen: same existence,
slot/itemID and exact full-link equality, merge shape, successful observation time,
readiness/freshness/schema/numeric/budget guards. No grammar normalization, missing-
field fallback, subfield borrowing or UI change. Collectors' original two-line fix
is unchanged. This amendment supersedes earlier statements that Core was frozen and
numeric-link-only failure coverage sufficed; earlier results/evidence are retained.

`lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-e05-amendment-fixed.log 2>&1; result=$?; tail -n 19 /tmp/opencode/craftarmy-e05-amendment-fixed.log; exit "$result"`
->exit0,277/277PASS/0FAIL/noINCOMPLETE,unchanged744K6/565K7. SelfTests remained byte-
identical to rejecting run SHA256
`0e9605e47eeb8a47d69c09045269650e1e22938b82acf736db6f18d84776dcf7`:
all3preservation regressions now pass with whole old values/observedtime100/blank/
failedattempt173/nonfreshstate. Seven identity negatives still reject borrowing.
Prior273cases (including numeric-link coverage) retained. Total13E05cases,264old
retained with exactly1authorized valid-empty expectation adaptation; other263 bodies/
helpers/runner unchanged. No rejecting assertion weakened after oldCore failure.

Current README manifest is now eventual **Core+Collectors+SelfTests** if onE04, only
after primary actual-baseline comparison and independent review/acceptance. One normal
ready own-profession scan of affected known-unenchanted tool then checks main blank
versus native absence; not yet requested/run. Oldcachedunknown requires normal scan,
no migration/API reads on cached/offline/hover. Screenshot/native raw payload caveats,
unknown-vs-absence/positive category/noamount-rank policy unchanged. No repeat accepted
field/Moxie/cache/reload/IDdiscovery/fullnative suite/Detailsrefresh; fullnative remains
INCOMPLETE87/149. No Data/family/Moxie/gathering/Knowledge/Details scope changes.

Amendment-start snapshot `/tmp/opencode/craftarmy-e05-amendment-preedit` has65files,
manifest SHA256 `37c17b85c34f1ee533c5a61c3070b6daa87a05c93fad74fbc958654c002d9dd0`.
It preserves primary's intentional PLAN/Q03/TASKS amendment edits. Original writer
baseline remains available only for writer-start inverses, not actual primary proof.
No retry/bypass of earlier denied primary actual baseline. Final fullchecks/inverses/
hashes/freeze results follow below. Native/display acceptance/review still pending.

### E05 amendment final validation / inverse and freeze proofs

Both previously inspected Lua runners and both Python checkers byte-confirmed unchanged
before resumed execution; existing `/usr/bin/lua5.1` only, no dependencies/install.
Exact final commands:

- `lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-e05-amendment-final.log 2>&1; result=$?; tail -n 19 /tmp/opencode/craftarmy-e05-amendment-final.log; exit "$result"`
  ->exit0,277actualPASS/0FAIL/noINCOMPLETE,264retained/13E05,744K6/565K7 unchanged.
- `lua5.1 tests/run.lua && python3 tools/check_dashboard.py && python3 tools/check_diagnostics.py`
  ->exit0,23/23diagnostic; dashboardPython16required/23Markdown/80links/8diagnostic
  hashes unchanged; diagnosticsPython9required/oneSavedVariables PASS.
- Read-only inline `python3 - <<'PY'` exact inverse/snapshot/pathset/docs/task/log proof
  ->exit0/PASS; `/tmp/opencode/craftarmy-e05-amendment-proof.json` SHA256
  `80f1a70390ffc64a316d6abff96d713c575583525b2e3e6ab6d8c6e7ce65071e`.
  JSONhashes pre-final-evidence/taskreport; source/test/README remain frozen.

All65paths and both authorized writer snapshots verified. Amendment-start comparison:
5changed ownedpaths(Core/SelfTests/README/evidence/TASKS), Collectors unchanged,59unowned
files frozen including primary PLAN/Q03/Q05. Original writer-start comparison:
6owned changedpaths plus intentional primary PLAN/Q03 amendments, no other changes.
This is NOT primary actual pre-E05 baseline comparison; its earlier denied access was
not retried or bypassed. Primary actual comparison still required.

Core exact one-pattern whole-file inverse equals original Core991084ad...; all other
Corebytes frozen. Collectors exact two-line whole-file inverse equals original; no
further amendment delta. Remove full marked E05block17109bytes and reverse ONLY the
single valid-empty expectation -> entire old264SelfTests442666bytes SHA256
`52454c27ad573698f0f17b5c2f6620b05978e2936ea2550d7140539228f95449`.
All263othercases/helpers/runner frozen. Removing ONLY new amendment tail reconstructs
initial273SelfTests exactly; numeric-link failure cases/allprior E05 assertions retained.
Final SelfTests equals rejecting-run hash exactly, proving no weakening after failure.
Final/fixed logs each277PASS/13E05/noFAIL/noINCOMPLETE/744K6/565K7. Rejecting log confirms
274PASS/3same-empty-failures, no supplements reached. README historical prependinverse,
evidence original and amendment prefixes, complete historical E04-and-olderTASKSsuffix
PASS. Entire amended TASKS inverse after only runstate/status/report edits exact.

Frozen source/test/README SHA256:

```text
c12d64410274cb043f64d473e0188051c714a60bebcfa62590a2116f42a03c10  CraftArmy/Core.lua
10af464a948da209053c7f53443e625b127a4041586793f5f0115f7035d14d7b  CraftArmy/Collectors.lua
0e9605e47eeb8a47d69c09045269650e1e22938b82acf736db6f18d84776dcf7  CraftArmy/SelfTests.lua
a0718a1842129c2eb77c6f53e5ea608766512c2aa58807e1768e8ad2def9a367  docs/dashboard/README.md
```

Final evidence hash in TASKS; postreport freeze/TASKS hash external
`/tmp/opencode/craftarmy-e05-amendment-final-freeze.json`. All amended implementation
pieces complete locally, no writer blocker. Stop for primary actual comparison and
independent scoped read-only review before update advice. Native affectedtool blank/
absence NOT RUN; no release approval. Fullnative INCOMPLETE87/149 unchanged. No children,
nativeclient/gameplay/install/dependencies/Git/release/deployment or timing chase.

## E05 restart recovery / independent static review PASS — 2026-11-15 continuation

Server restart removed original `/tmp/opencode` baseline/log/proof files. Primary did
not recreate or claim original65-file whole-tree proofs. Reconstructed exact Core,
Collectors and SelfTests preimages via authorized inverses matched durable pre-E05
hashes991084ad.../ff355288.../52454c27...; current4reviewedfile hashes match amended
delivery. README priorhash unavailable; reconstructed by documented prepend removal.
Postrestart65-file freeze/preimages/proof saved in `/tmp/opencode/craftarmy-e05-recovery`.

Generated4file348line22728byte `docs/dashboard/e05-review.diff` SHA256
`0ded0f3885554afc4c8ca35e8dd1a660eec6ba8d2cfbf61f81a71b742855874e`.
Primary fresh postrestartactual277/277+744K6/565K7,diagnostic23/23,bothPythonPASS.
Primary isolatedfixturecopies with verifiedoldCore and IDENTICALcurrentSelfTests
reproduce274PASS/3FAIL at173!=100, confirming the3preservationregressions without
editing production. Logs `/tmp/opencode/craftarmy-e05-primary-dashboard.log` and
`/tmp/opencode/craftarmy-e05-primary-old-core.log`. Historical writerwhole-tree proofs
retained as historical attribution, not independently reproduced afterrestart.

Verifier `ses_e3b6d48d1ffe1IGMBqqLMotBJe`: COMPLETE/scopedstaticPASS/no findings;
completeartifact/currentintegration/tests/docs/scripts reviewed. All execution/hash
attempts and externalrecoveryproof read denied; none executed, no retry/bypass/write.
Executable/hash proofs primary-attributed. Recoverylimitations explicitly acknowledged.
Primary postreview4files+artifact rehash PASS/unchanged. ReviewedREADMEa0718a18...
precedes primarygate-only update; runtime/test/artifact unchanged. PlatformN/A.

Primary accepts boundedlocal/static E05, not nativeblankdisplay or release. Nextuser
3fileCore+Collectors+SelfTests update ifonE04 perREADME, one ownreadyEnchanting scan
on affectedknown-unenchantedrod and blankEnchant/nativeabsence check. Genuineinvalid/
unready/conflicting data remains?. No repeatedacceptedfield/Moxie/cache/fullselftest/
Detailsrefresh or agentinstallation. Fullnative87/149INCOMPLETE remains unchanged.

### E05 final continuation freeze check — 2026-11-15

Temporary recovery proof/manifests were cleared again during limit/reset. Attempted
postrestart-manifest check failed for missingproofJSON; do not relabel it successful.
Primary instead directly checked currentCore/Collectors/SelfTests/Data/artifact against
durable recordedhashes and recomputed three authorized pre-E05 source inverses in
memory: allPASS, with the exact recorded oldCore/Collectors/old264SelfTests hashes.
Both current Python structural checks PASS. No runtime/test/artifact edits; historical
full-tree freeze/counterexample logs remain durable reported results, not available
originaltempfiles. Nativeabsence/blankcheck stillpending; scopedupdate instructions
unchanged. No implementation repeated or further nativechecks added.

## E05 native blank-display acceptance — 2026-11-15

User: “The enchant cell correctly displays blank instead of '?'”. Confirms affected
known-unenchantedtool's blankdisplay after reviewedupdate/normal scan. E05bounded
local/static/nativeblankdisplay sequence COMPLETE. No rawpayload, extra item coverage,
nativefailure-path/timing/errorabsence or broadT02/release proof inferred. Genuine
unknown/unmapped state remains?. No furtherupdate/cache/reload/fullselftest requested;
Knowledgecapture/accounting and parkedDetails remain separate. Documentation only,
no newsource/test/nativeexecution performed by agents.

## K08 implementation/local evidence — 2026-11-15 (review/native gates PENDING)

User authorized Knowledge continuation; PLAN D05/D10 and Q03 K08 settle the separate
frame-stepped read-only command. Sole writer modified only KnowledgeCheck/Commands,
one new SelfTests block, README prepend, this evidence append and K08 TASKS execution
fields. No new/deleted repository files, Data/schema/Core/Collectors/Knowledge/Details/
Dashboard/ViewModel/TOC/runner/checker changes, dependencies, game/Git/release actions.
Platform N/A. Local completion is not independently reviewed, native-accepted or released.

`NewProfessionCaptureJob` uses a module-private mode through the shared start/finish
identity gate: exact registered child/parent/family/expansion11 only. Legacy
NewCaptureJob/Capture and synchronous knowledgecheck remain Inscription-only; Format,
NewFormatJob, version1 and all capture/projection/cost/currency/ownership/truncation
bounds are unchanged. Config/tab order is read live, not taken from user observations.
No numeric Knowledge/raw persistence widening. Candidates remain provisional; current
cost consistency is never all-rank proof. Missing/error/staged/duplicate/ambiguous or
clipped evidence never obtains passing totals.

`knowledgecapture` bypasses Login/Scan/DB validation/timers. Start validates an existing
idle collector and private ephemeral Context/Same attribution (own ready unstaged,
registered identity/config/source/player); original runtime object/revision/serial stay
pinned. Slash start performs no job Step or path/entry/currency traversal, even under
reentrant frame setup. Independent OnUpdate advances one capture OR format Step per
callback; transition creates a job without stepping it. A separate publication frame
closes the final-format→UI gap. Guards run before/after each Step, throughout format,
and before/after publication. Final capture/format unit drift cannot escape. Entire
guard/Step/phase/publication work is measured; >100ms including LAST work/UI fails,
exactly100ms passes.10000 callbacks across phases stays an explicit INCOMPLETE cap.
These are post-return checks, not native preemption or latency proof.

Any Commands event retires capture BEFORE unchanged normal event flow; explicit scan
does the same. No event suppression or auto-resume. Selftest/capture overlap and legacy
capture during new capture are refused. Report/text/jobs remain closure-private until
guard/clock/UI checks pass. Previous success is retained but hidden on valid retry,
including later factory/Step/chat/UI failure; new partial output/candidates are discarded.
Cleanup retires the session first, clears private jobs/context/runtime/clock/frame refs,
and best-effort removes/hides callbacks. Throwing native cleanup leaves stale callbacks
inert. Combat/unknown stops do not create/show/focus copy UI. Error payloads/player/
runtime-private strings never appear in copied output or failure messages.
Scheduler completion is distinct from `captureComplete`: data-incomplete reports can
finish and be copied with unknown reconciliation. Successful window reuse, immutable
copy text, Close/Escape and failed publication hiding are covered.

32 additive synthetic cases retain every original277 case/helper/runner byte. Cases
cover all8 identity/config/order/full guarded graphs/entries/late currencies/locked
capacity; malformed/unsupported/gathering/old child/parent/family and caller overrides;
legacy gate; missing/error/staged/duplicate/currency/cost guards; no-Step slash,
one-unit capture+format/phase gaps; cancel/status/restart; missing/pending runtime;
22 runtime/context drift variants before path work and in format/final UI gaps;
inside-LAST-Step drift; all registered events plus arbitrary event; scan/conflicts;
clock failures/fallback/timing/cap; exceptions/cleanup; retained success/UI/privacy;
unchanged full512path clipping workload; Core/K/Collectors non-Inscription rejection.
No Data/global native/liveDB mutation. Test-local factory interceptions are restored
under pcall before any outer checkpoint. Frozen runtime checks include every runtime
edge and complete non-env state; UI/chat and private synthetic counters are expected
env-only changes. Synthetic profession graphs are NOT native profession data/defaults.

Validation history (all scripts inspected first; existing `/usr/bin/lua5.1`, no install):
- Primary supplied baseline277/277+744K6/565K7, diagnostic23/23, bothPythonPASS.
- `lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-k08-dashboard-first.log 2>&1; result=$?; tail -n 50 /tmp/opencode/craftarmy-k08-dashboard-first.log; exit "$result"`
  exited1:300PASS/1 new fixture FAIL then INCOMPLETE at existing10000 outer-runner
  steps. All old277 PASS. New freeze had included deliberately mutable fake UI/chat
  via runtime.env; corrected only new fixture freeze, retaining all runtime edges and
  non-env graphs. New policy-control setup corrected to actual Scan/k2Raw semantics.
- Second analogous command (tail39, `-second.log`) exited0 but **INCOMPLETE302PASS/
  0FAIL**, NOT success. New matrix/callback and maximumgraph fixtures had excessive
  outer checkpoints. Grouped NEW synthetic work into eight individually simulated
  callbacks/fixture units per outer checkpoint; no work, coverage, assertion, limit,
  original fixture or runner removed/changed.512 actual paths/full jobs retained.
- Third analogous command (tail12, `-third.log`)304/304; fourth (tail17,
  `-fourth.log`)307/307; fifth (tail15, `-fifth.log`)308/308; all exit0/noINCOMPLETE
  and unchanged744K6/565K7. Added meaningful failure/reentry/timing cases, no old-test
  adaptations or timing chase. Full native selftest remains INCOMPLETE87/149; not run.

Primary external66-file baseline manifest read denied once (`external_directory`);
no retries or bypass. Authorized writer-start66-file snapshot is
`/tmp/opencode/craftarmy-k08-writer-start`, manifest SHA256
`ced7197f263e470a5baaf1ca63dd326bdb7bb435d9dd4f2cf44e31133c81abef`.
Writer proofs compare this snapshot, NOT the primary actual pre-planning baseline.
Primary actual diff comparison + independent review MUST precede any user update or
native request. Eventual E05-based source manifest: Commands+KnowledgeCheck+SelfTests.
Next native gate AFTER review: ONE own ready unstaged Enchanting report, entire
BEGIN→END plus native tree investments/caps/UnspentKP comparison, errors/warnings/
responsiveness. Wait ordinary eventscan settlement; no spending/reload/accepted generic
field or currency-ID rediscovery/full native suite. Review that profession before
batching others. Numeric activation/raw persistence, broad API/required fields, Details
improvements/guides and release remain separate. Native capture/accounting/timing NOT RUN.

Final self-review added a cheap active/runtime check after the last clock read, because
a reentrant clock could cancel/dispatch an event or change serial after the last full
Context guard. A32nd new case confirms last-clock cancellation/event/runtime drift never
assigns disposed pending output or replaces previous successful fields. Final command
`lua5.1 tests/dashboard.lua > /tmp/opencode/craftarmy-k08-dashboard-final-guard.log 2>&1; result=$?; tail -n 17 /tmp/opencode/craftarmy-k08-dashboard-final-guard.log; exit "$result"`
exited0: **309PASS/0FAIL**, no terminal INCOMPLETE, unchanged744K6/565K7. Earlier
`-final.log` command (tail16) had308/308 before this additive finalguard improvement.
`lua5.1 tests/run.lua && python3 tools/check_dashboard.py && python3 tools/check_diagnostics.py`
exited0: diagnostic23/23; dashboard16required/23Markdown/80links/8diagnostichashes
unchanged; diagnostics9required/oneSavedVariables PASS. Will repeat after final docs.

Read-only inline `python3 - <<'PY'` freeze/inverse checks: initial proof harness exited1
because its in-memory status inverse also touched historical E05 piece4 while K08piece4
was still unchecked; restricted inverse to activeprefix. Second harness exited1 only
because a whole-log `INCOMPLETE` substring predicate matched deliberate PASS case names;
this was not a runner stop. No production/test edits for these proof-harness mistakes.
One targeted grep of the external final log was denied (external_directory); no retry
or alternate read of that denied log. Source/freeze proofs omit log rereads; actual
test counts/termination are taken from the successful command stdout above. An empty
shell call during interruption failed transport, no command/check execution claimed.
The successful source/freeze-only harness verified exact Commands and KnowledgeCheck
whole-file inverses, old277 whole-file inverse, all60 unownedfiles/same66paths,
README fullprepend inverse, evidence fullprefix, entire E05-and-older TASKSsuffix and
active TASKS inverse after only statuses/runstate/report. Preliminary proof
`/tmp/opencode/craftarmy-k08-writer-proof.json` SHA256
`c8f5024bf37aaab1f5fbe09c2e1eb6f1a8dc276d9e909fc61a03880749ab40fa`
preceded the finalclock addition; final frozen hashes/proofs are recorded below/TASKS.

Final approved command
`lua5.1 tests/run.lua && python3 tools/check_dashboard.py && python3 tools/check_diagnostics.py && sha256sum CraftArmy/Commands.lua CraftArmy/KnowledgeCheck.lua CraftArmy/SelfTests.lua docs/dashboard/README.md docs/dashboard/evidence.md`
exited0 after finalclock regression/docs:23/23 and bothPythonPASS, same counts above.
No code/test changes after309/309. Final source/freeze inline Python command exited0:
`/tmp/opencode/craftarmy-k08-final-guard-proof.json` SHA256
`f46e3312606baf04c95b453349890bbf680ecdf52d8b2b68d91a6cf48d6fd33a`.
All66 paths/60 unownedfiles and original history preserved; exactly6 authorizedpaths
changed.32-case K08 block32944bytes removed -> exact entire original277 SelfTests
SHA256 `0e9605e47eeb8a47d69c09045269650e1e22938b82acf736db6f18d84776dcf7`.
Commands inverse -> `b858f4d7752a06bbea55ae2127bd7011a03cd8e726abf49fcad29f7a9171eef3`;
KnowledgeCheck inverse -> `214550def55ff05025c933fe1375cdd969cce954736dbd87403e0e9d6ba43f89`.
These inverse/source/freeze proofs use the writer-start snapshot, not denied primary
actualbaseline. This final evidence append/task completion follow that proof; a final
post-report freeze rechecks permitted document deltas and records TASKS selfhash outside.

Frozen source/README SHA256:
- Commands `f92a2abe64d8b9ec0f23e639cdd35c53a0feaf189db2d80dde4b7f462fb14b83`
- KnowledgeCheck `9d004416860fb09405cbe031847eacc9a55c7067b6eca056d3f63d27c23574b6`
- SelfTests `aa83f952f56d2ea0fa91d5ff0dec42b124196a85d72cc12f4bcda923d903c5fd`
- README `b3392d77423e7c9ed1beeb5b6919a26a2c72d899fd228b1a613780c76dfb71bd`

Writer scope/local validation COMPLETE. No implementation blocker/remainder. Primary
actual-baseline comparison and independent review/acceptance PENDING; native Enchanting
report/value/responsiveness comparison NOT RUN and not requested yet. No source-update
advice issued by writer. FullnativeINCOMPLETE87/149 unchanged; no numeric activation,
install/release/publication approval. Next actor is PRIMARY for actual diff + review.

## K08 primary comparison / bounded independent static-delta review — 2026-11-15

Primary actual66-file pre-K08baseline verified, manifestSHA256
97932866cb69eeb76dbe7f2c12211dcb880682508bee157355142b14788c6441. Exactly6writerpaths+
intentionalprimaryPLAN/Q03 changed; all58otherbaselinefiles unchanged, no writernew/
deletedpaths. Exactold277inverse/READMEprepend/evidenceprefix/E05historysuffix PASS.
Primaryproof firstscript failed Pythonnon-ASCIIbytesliteral syntax, corrected harness
then PASS (not a sourcefault). Actual4filediff908lines57742bytes SHA256
e80af9066176ab111a9a34b749ac7355cebaefa736fd58022773d49ad7d3c6e8 at
`/tmp/opencode/craftarmy-k08-primary-review.diff`. Primaryfreshactual309/309,noFAIL or
terminalINCOMPLETE, unchanged744K6/565K7;23/23diagnostics,bothPythonPASS.

First independent verifier ses_e2137426effe5OCxn7fNNopr1x returned PARTIAL/
AcceptanceINCOMPLETE: completecurrentmodules/32cases/integration inspected with no
blockingfinding, but temporaryactualdiff read and all4execution attempts denied.
No retry/bypass or writes, executable/hash/fulltree proofs primary-attributed. Primary
persisted thisreport beforefollowup. Added durable [reviewrecord](k08-review.md) and
[completeproductiondelta](k08-review.diff),302lines19871bytes SHA256
4c898bcd72d73dd487687386641c78f47c0860a3479ecd913b95b562d09a251c. Primary verified
artifactbyte-equality to complete2productionfile section of actualbaseline diff and
all4reviewedhashes unchanged. Onlyprimaryowned reviewartifacts added afterwriter.

Explicit boundedstaticdelta continuation: sameverifier COMPLETE / AcceptancePASS,
no blockingfindings after directrepositorydiff inspection against priorfullcurrent
modules/testblock/README/contract. No execution, externalretry/bypass or writes in
continuation; no independentexec/hash/fulltree claim. EarlierINCOMPLETE remains
historical, not relabeled. Primary postreview4files+sourceartifact rehash PASS.
Windowcaveat: provisionalwidgetcontents can change before failedpublication; old
successfulreport/text retained and failedwindowhidden, no existingcommand reopens it.
No demonstrateduser-visibleblocker; do NOT claim widgetcontents rollback/immutability
across failedretry. PlatformN/A. Nativecapture/API/accounting/responsiveness NOTRUN,
fullnative87/149INCOMPLETE unchanged. Primary acceptance/native coordination separate.

### K08 bounded acceptance / native evidence ready — 2026-11-15

Primary persisted finalreview before accepting local/staticimplementation. Source/test/
productionartifact hashes unchanged afterboundedstaticPASS; onlycurrentREADMEgate and
planning/evidence/reviewrecords change afterward. Exact acceptedsourcehashes remain
Commandsf92a2abe..., KnowledgeCheck9d004416..., SelfTestsaa83f952... (fullvalues above).
ReviewedREADMEb3392d77... precedes gate-only instructions. All309localcases/744K6/565K7/
23diagnosticcases/bothPython and actualbaseline/freeze proofs primary-attributed, not
independentlyexecuted. EarlierreviewINCOMPLETE retained, finalreview boundedstaticPASS
not fullindependentvalidation. PlatformN/A; native/API/responsiveness/accounting NOTRUN.

README now requests onefocuseduserEnchantingcapture after reviewed3fileupdate ifonE05,
ownreadyunstagedprofession outofcombat, waitordinaryautoscans settle, keepopen/unchanged,
new`knowledgecapture` only, entireBEGIN→ENDreport/nativepoints/caps/unspent plus errors/
warnings/responsiveness. Sendrefusal/INCOMPLETEmessage; no retry/timingchase/fullselftest/
spending/repeatedacceptedfield/cache rounds. Reviewfirstreport beforebatchingothers.
No numeric/rawpersist activation, installer action, release or nativePASS implied.

Final current-doc checks: bothPythonPASS (24Markdown/84local-links/8diagnostichashes).
Primary final3source/test+productionartifact hashes unchanged; all58unownedbaseline
files frozen,old277wholefileinverse/E05suffix/READMEhistory/evidenceprefix PASS,only
2primaryreviewartifacts added. No runtime/test changes after309/309/boundedreview;
nativecapture stillNOTRUN. These finalchecks are primary-attributed.

## K08 first native Enchanting capture received — 2026-11-15

User supplies complete version1BEGIN→END report. captureComplete=true,outputTruncated=
false,stable=true,27captured/27discovered across4trees13/6/4/4paths, no coverageflags.
12.1.5/build70783/120105/enUS, sourcePin297d7a..., serverseconds1794746573 atbothends
(not measuredlatency). Exact2909/333/9/11/config37471400/sourceCounter13 unchanged;
stagedfalse+protectedstagingreadfalse bothends; runtime revision132/serial19 unchanged.
Native taborder1155/1154/1153/1152 retained. Fullsanitizedpath/entry/children/rank/cost/
currency projections appendedQ03; no playeridentifiers in suppliedreport or savedhere.

- ElevatingEquipment1155:83/270 (13paths).
- Transitories,Tonics,andTools1154:120/140 (6paths).
- DisenchantingDelegate1153:120/120 (4paths).
- SpellboundShatterer1152:120/120 (4paths).

Sum443/650; Enchanting traitspendcurrency4056 quantity0/spent443 coherent acrossall4tabs,
comparedONCE, provisionalmatch. This differs from Inscription3902 and Moxie3258: never
treat3902 as universalcraftingcurrency.25purchasedunlockranks removed from468 and
27unlockmaxranks removed from677. Twozero-rankpaths107761/107757 nextunlockcurrency
4078/4074 currentcost1 differ fromspend4056; preserve distinction, not paidKPerror or
allrankcostproof. Data completeness does NOT mean numericeligibility/nativeUIagreement.

Nativecapturedata evidenced for thiscase only. User has not reported nativefourtree/
Unspent0 agreement or responsiveness/errors/executionwarnings; those remain pending.
Nextfocusedconfirmation only, no rerun/update/fullselftest/spending or repeatedgeneric
fields. Otherprofessions wait firstcomparison; production/numeric/rawpersist unchanged.
Documentation-only evidence recording, no new testexecution, implementer or release.

## K08 focused Enchanting native agreement confirmed — 2026-11-15

User: “Yes those match up, no errors, and remained responsive.” Confirms preceding
question's fourtreevalues83/270,120/140,120/120,120/120 andUnspent0 againstnativeUI,
and responsive/error-freecapture. Focusedfirstprofession evidence sequence COMPLETE.
No quantitativelatency/allrankcost/nativefailurepath/everyAPI or numericimplementation
acceptance inferred. Nativefullsuite87/149INCOMPLETE unchanged; no rerun requested.

Proceed existingplannedbatch for other6verifiedcraftingidentities using alreadyinstalled
newread-onlycapture: Alchemy/Blacksmithing/Engineering/Jewelcrafting/Leatherworking/
Tailoring. Fullprofession-labeledBEGIN→ENDreports/nativepoints/caps/unspentcomparison
andissues perREADME, no update/newIDquery/fullselftest/spending or Enchanting/Inscription
repeat. Eachactualgraph/currency stillawaits evidence. Numeric/rawpersist policies and
parkedDetails unchanged. Documentationonly; no agentruntime/test/install/releaseaction.

## K08 Alchemy native report received — 2026-11-16

User supplies labeledfullBEGIN→ENDreport. Target12.1.5/build70783/120105/enUS/PIN297d7a...,
serverseconds1794747512 atbothends(not measuredlatency). Identity2906/171/3/11,
config33457297/sourceCounter19 unchanged,stagedfalse+stagingReadfalse bothends,
runtime6revision/2serial unchanged. CaptureComplete=true,stable=true,outputTruncated=
false,22/22paths,no coverageflags; orderedtabs1140/1142/1144/1143,paths7/7/4/4.
PotionProwess170/170;FluentinFlasks141/170;AlchemicalMastery90/90;TransmutationAuthority
0/90. Sum401/520 reconciles ONCE to sharedtraitcurrency4030spent401/quantity0 across4tabs.
Alchemy4030 differs fromEnchanting4056/Inscription3902/Moxie3256; not universalIDs.
Rawpurchased419 minus18unlockranks=401; rawmax542 minus22unlockmax=520. Fourzero-rank
nodes currentunlockcost107209→4042,107256/107255/107254→4050 distinct fromspend4030;
uninvestedtreecapacity90 retained, allrankcostsUNVERIFIED. Completepath/entry/child/rank/
currentcost/currency projection appendedQ03; no playeridentifiers copied.

Alchemy nativeUIagreement/responsiveness/errors/warnings NOT yet reported; canconfirm
with remainingfiveprofessionreports, no recapture/update/separateIDdiscovery/fullselftest.
Enchantingfocusedroundcomplete,no repeat. Blacksmithing/Engineering/Jewelcrafting/
Leatherworking/Tailoring reportsoutstanding. Numeric/rawpersist policies/parkedDetails
unchanged. Documentation-only recording; no new code/test/nativeagentexecution/release.

## K08 Alchemy numbers confirmed; Blacksmithing/Jewelcrafting reports — 2026-11-16

User confirms “Alchemy numbers match up.” Its four tree values/Unspent0 match nativeUI;
Alchemy responsiveness/errors/warnings stillnotreported. Two additional fullreports
received, both12.1.5/70783/120105/enUS/PIN297d7a...,captureComplete=true,stable=true,
outputTruncated=false,no coverageflags,unchangedunstagedattribution/runtimeboundaries.

| Profession | Identity | Config / sourceCounter | Runtime revision / serial | Paths per native-order tree | Candidate totals | Spendcurrency / unspent |
| --- | --- | --- | --- | --- | --- | --- |
| Blacksmithing | 2907/164/1/11 | 34773439/16 | 6/2 | 4/5/13/8 (30total) | 80/105,33/120,0/345,180/205 =293/775 | 3750/0 |
| Jewelcrafting | 2914/755/12/11 | 34774007/17 | 12/3 | 4/17/4/10 (35total) | 73/120,0/310,150/150,0/194 =223/774 | 3989/0 |

Each reconciles sharedspent ONCE across4tabs, othercurrencies excluded. BSserverseconds
1794747189→1794747190; JC1794747225→1794747226, not quantitativecallbacklatency.
BSraw313/805 minus20/30unlockranks=293/775,10zero-rankunlocknodes; JCraw233/809 minus
10/35unlockranks=223/774,25zero-rankunlocknodes. Fullpath/entry/child/rank/currentcost/
currency projections appendedQ03. JCfourprocessorentries type7/max1 give observed194
capacity after distincttype9/max1 unlock exclusion; no guessed20/30caps or rounding.
AuxiliaryBS3807quantity1 andJC4008quantity1 excluded fromUnspentKP, bothsharedquantity0.

NativeBS/JCvalues/behavior unconfirmed, allrankcostsUNVERIFIED. RemainingEngineering/
Leatherworking/Tailoring reports and batchconfirmations perREADME; no recaptures,
sourceupdate,fullselftest,newIDdiscovery/spending or agentimplementation. Enchanting
alreadyaccepted,Alchemyvaluesconfirmedonly; numeric/rawpersist gates/Details unchanged.
Documentationonly; no runtime/test/nativeagentexecution or releaseapproval.

## K08 BS/JC numbers confirmed; Engineering native report — 2026-11-16

User confirms both Blacksmithing and Jewelcrafting numbers match nativeUI. Accept
fourtree/Unspent0 agreement only, not unreported responsiveness/errorabsence. Alchemy
numbers alreadyconfirmed; Enchanting is the only explicit responsive/error-freecapture
confirmation so far. No repeats requested; batchbehavior may be reported together.

Engineering fullBEGIN→ENDreport:12.1.5/70783/120105/enUS/PIN297d7a...,server1794747367
bothends(not latency). Exact2910/202/8/11/config34757864/sourceCounter18, runtime6/2
unchanged; stagedfalse/stagingReadfalse bothends. Complete21/21,stable/untruncated,
no coverageflags. Nativeorder1131/1176/1132/1133,paths9/5/4/3. Candidates103/225,
0/165,70/90,30/90=203/570 matchshared3903spent203/quantity0 ONCE. Raw218/591 minus
15/21unlockranks=203/570. Sixzero-rankalternateunlockcurrentcosts distinct from3903;
allrankcostsUNVERIFIED. CombatAnalyticsroot109141 fourchildren includes110352 and
four35-pointcapacities, not assumedthree. Auxiliary3983quantity1 notUnspentKP. Full
path/entry/child/rank/currentcost/currencyprojection inQ03 includinglate4236currencyrow.

EngineeringnativeUI/behavior notyetconfirmed; remainingLW/Tailoringreports undercurrent
batch. No newupdate/recapture/newIDquery/fullselftest/spending/source/test/policy/release
action. Numeric/rawpersist gates and parkedDetails unchanged. Documentation-only.

## K08 Engineering numbers confirmed; LW/Tailoring final reports — 2026-11-16

User confirms Engineeringnumbers match nativeUI (fourtrees/Unspent0), not explicit
capturebehavior. Finaltwofullreports received; both12.1.5/70783/120105/enUS/PIN297d7a...,
captureComplete=true,stable=true,outputTruncated=false,no coverageflags,unchangedown
unstagedcontext/runtime/stagingReadfalse boundaries. Allsixbatchreports nowreceived.

| Profession | Identity | Config / source | Runtime revision / serial | Native tabs / path counts | Candidate totals | Shared currency / unspent |
| --- | --- | --- | --- | --- | --- | --- |
| Leatherworking | 2915/165/2/11 | 33804452/20 | 7/3 | 1158,1157,1159,1156 / 4,11,11,6 (32total) | 73/120,250/250,0/250,0/150 =323/770 | 4085/0 |
| Tailoring | 2918/197/7/11 | 33804477/21 | 14/5 | 1067,1070,1071,1072 / 13,5,3,5 (26total) | 0/300,130/130,80/80,86/150 =296/660 | 3736/0 |

Eachsharedspent matchedONCE across4tabs; no auxiliarycurrencysumming. LWserverseconds
1794747598→1794747599;Tailoring1794747641 atbothends,not quantitativelatency. LWraw340/
802 minus17/32unlockranks=323/770,15zero-rankalternateunlockcosts; Tailoringraw310/686
minus14/26=296/660,12zero-rankalternateunlockcosts. Fullsanitizedpath/entry/child/rank/
currentcost/currencyprojections appendedQ03. EightLastingLeatherauxiliaryquantity1rows
are NOT UnspentKP; shared4085quantity0 remainsseparate. Uninvested/lockedtreecapacities
preserved. AllrankcostsUNVERIFIED,not universalcost/accountingimplementation acceptance.

Alchemy/BS/JC/Engineering nativevalues confirmed; LW/Tailoringvalues/Unspent0 pending.
Six-professionbatch responsiveness/errors/warnings not explicitlyreported; onlyearlier
Enchantingbehaviorconfirmed. Nextcombinedconfirmationonly,no more reports/reruns/
updates/fullselftest/newIDs/spending. Numeric/rawpersist gates remain unchanged; future
accountingimplementation requires settledtask/review. No new source/test/agentnative/
releaseaction; documentationonly.

## K08 final native confirmation / scoped completion — 2026-11-16

User: “Tailoring and Leatherworking numbers match the native UI. No errors or warnings
and UI stayed responsive throughout.” Corroborates LW73/120,250/250,0/250,0/150 and
Tailoring0/300,130/130,80/80,86/150, bothUnspent0; six-professionbatch UI responsive
without reportederrors/warnings. PriorAlchemy/BS/JC/Engineering numericagreement retained,
their previouslypendingbatchbehavior nowconfirmed explicitly. EarlierEnchantingfocused
sequence complete. Sevenadditionalprofessions have complete stable/untruncated reports,
provisionalreconciliation, nativecurrentvalueagreement and reportednormalcapturebehavior.

K08 scopedimplementation/localtests/boundedstaticreview/focusednative sequence COMPLETE.
No new code/test/nativeagentexecution here; local309/309+744K6/565K7+23diagnostics and
structural/review proofs retain earlierprimary/reviewer attribution, not rerun claims.
AllrankcostsUNVERIFIED; no quantitativetiming/unobservedfailurepath/allAPI acceptance.
Fullnative87/149INCOMPLETE unchanged. No more captures/update/reload/fullselftest/
genericfield/cache/IDdiscovery/spending requested. Productionnumeric/rawpersist gate
stillInscription-only, futureaccountingdesign/task/approval/review separate. No writer
active or releaseapproval; documentation/evidence recording only.

## K09 writer partial implementation / allowlist blocker — 2026-11-16

Status **PARTIAL**, not delivered/accepted. TASKS K09 pieces1–3 implemented; pieces4–5
blocked by a historical-test allowlist gap, not by a budget or native API failure.
Core's private scalar resolver now matches the approved eight exact identities and
trait currencies, distinct from Moxie; Details stays Inscription-only. Evaluator pins
observed path currencies without filling missing reads. Typed raw/generation attribution
and Scan's typed preflight are implemented; supported typed-valid partial raw remains
independent of numeric eligibility. No safety limits, schemas, commands, Details, Data,
UI modules, runners or checkers changed. This is unreviewed partial working-tree code.

### Exact prerequisite and resume point

PRIMARY must amend K09 piece4's old-test allowlist before writing resumes. The contract
incorrectly describes all E03/E04/E05 raw fixtures as wrong3902 data. In fact:

- E03's six one-tree fixtures have incomplete node/entry metadata and **no present
  spendCurrencyID**, so the approved partial-raw validator accepts them. `unknownKnowledge`
  currently permits only an unknown attempt/nil last; the six per-profession tests fail
  on observed versus unknown. Its separate four-tree relabeled3902 use must continue
  rejecting currency with unknown/nil raw and nil numeric values.
- E03's closed/reopened six-character case separately asserts nil raw history at the
  old line6711; that assertion is outside the current allowlist and now fails on retained
  typed partial raw. No change made there.
- E04's Engineering scan and E05's Enchanting absence scan have **empty tab lists**, not
  present wrong-currency paths. Their valid incomplete raw is observed; permitted edits
  only change unsupported to unknown and retain nil last, conflicting with piece2.

Required amendment must explicitly allow testing observed typed-valid **incomplete raw**
at those sites while all numeric totals remain unknown and wrong-present-currency/owner
rejections remain intact. Writer did not broaden the allowlist, change these nil-last
assertions, require complete raw, or fabricate a policy workaround. After amendment,
resume piece4: finish adaptations and all rejecting/preservation matrices, formerly
accepted coherent70002 rejection, >=24 new overall, then piece5 docs/full validation.
README prepend and schema clarification intentionally NOT DONE; no update advice.

### Fixture provenance and combined budget

New marked K09 block has22 positive cases (three per profession plus combined-eight).
All193 new-profession Q03 path/entry/children/rank/current-cost rows and every auxiliary
currency ID/order/quantity/spent/max row were independently text-compared to Q03: exact
match. Native tab names/order and children retained, including JC106981/106980/106979/
106978 spendmax1/nodeMax2, Engineering109141's four35-point children including110352,
late4236 currency and positive auxiliary balances (not KP). Branch labels, definitionIDs,
configs and GUIDs are explicitly synthetic; dynamic states are synthetic, not evidence.
Seven independent real injected Scan→Apply→Open→offline/stale Dashboard/normal+Shift
hover→Archive→Open paths pass; Details unsupported. Synthetic config/source/order/label/
rank/cap/shared quantity7/independent API Unspent11/auxiliary quantity3 variants pass.

Actual complete eight-profession DB (unchanged K2 Inscription plus seven full new native-
derived raw+numeric snapshots, distinct synthetic characters): **29793/50000 expanded
values**, real Scan/Apply/Copy/Open and eight-row render PASS. No omitted paths, dropped
raw, hidden eviction, raised limits, compact fake aggregates or relabeled K2 graphs.

### Commands and actual results

Inspected `tests/dashboard.lua`, `tests/run.lua`, `tools/check_dashboard.py` and
`tools/check_diagnostics.py` before execution. Installed Lua5.1 only; no installs.

- Writer-start `lua5.1 tests/dashboard.lua`: completed309/309, unchanged744K6/565K7 PASS.
- Writer-start `lua5.1 tests/run.lua`:23/23 PASS; both Python checks PASS, no baseline
  failures. These are writer-executed local results, not new native evidence.
- First implementation `lua5.1 tests/dashboard.lua`: exit1,308 PASS/16 FAIL across324
  cases, no runner INCOMPLETE. Nine old partial-raw conflicts plus seven new Shift-hover
  fixture mistakes (missing injected IsShiftKeyDown). Corrected only NEW helper.
- Second dashboard run: exit1,315 PASS/16 FAIL across331 cases, no runner INCOMPLETE.
  Same nine old conflicts; seven new Details fixture scopes omitted required archived=false.
  Corrected only NEW scopes; added explicit stale rendering before archive.
- Final dashboard run: **exit1,322 PASS/9 FAIL across331 executed cases**, all22 new K09
  PASS, no runner INCOMPLETE. Nine failures are the six E03 generic scans, E03 cached
  six-character case, E04 Engineering scan and E05 absence scan described above.
  Final K6/K7 supplements NOT REACHED because frozen runner exits1 on case failures;
  only baseline supplement execution is claimed. Old309 case/scenario code retained
  except the exact11 allowed lines below; failing cases do not finish their later work.
- Final `lua5.1 tests/run.lua`:23/23 PASS.
- Final `python3 tools/check_dashboard.py`: PASS (16 files,24 Markdown,84 links,8 unchanged
  diagnostic hashes); structural only.
- Final `python3 tools/check_diagnostics.py`: PASS (9 files); structural only.

Logs: `/tmp/opencode/craftarmy-k09-baseline-dashboard.log` and
`/tmp/opencode/craftarmy-k09-dashboard-{first,second,third}.log`. Source unchanged after
third run. K09 native display/persistence NOT RUN; historical full native suite remains
INCOMPLETE87/149. K08 accepted native evidence is not erased/reopened. No native latency,
all-rank cost proof, game installation, Git action, release or publication performed.

### Writer-attributed comparison and freeze

Primary external baseline manifest read denied once (`external_directory`); no retry or
bypass. Writer-start68-file snapshot `/tmp/opencode/craftarmy-k09-writer-start/files`,
manifest SHA256 `8b71cf5dd2331def355e82fa21d10c40ff40892b6b5af9fd089e830ee35e2542`.
This is NOT independent proof against the primary snapshot; primary comparison pending.

Exact old-test delta (11 lines, all other old bytes unchanged): K2 dynamic case four
70002→3902 substitutions (spend ID, currentcost ID, sharedrow ID, evidence assertion);
E01 relabeled scan status unsupported→unknown and reason search unverified→wrong
profession spend currency; E03 unknownKnowledge same status/reason changes; E04/E05/K08
listed scan assertions each unsupported→unknown. No case names/comments changed.
Remove ONLY K09 block and reverse ONLY those11 audited replacement lines: exact start
SelfTests SHA256 `aa83f952f56d2ea0fa91d5ff0dec42b124196a85d72cc12f4bcda923d903c5fd`
restored, byte equality PASS. No retained case/scenario/runner deletion or cap changes.

Production diff from writer start (Core/Knowledge/Collectors):111 lines/6929 bytes,
SHA256 `8ab1f1ab14a4aea4e2283dab11806652af3618f3a6377f8d7d19813196200ca3`, temporary
review aid `/tmp/opencode/craftarmy-k09-writer-production.diff`. Complete source hashes:

| Source | Writer-start SHA256 | Partial target SHA256 |
| --- | --- | --- |
| Core.lua | c12d64410274cb043f64d473e0188051c714a60bebcfa62590a2116f42a03c10 | a83a16c9d9f27df1f3ecd93bc881fec32b920a78fcbc9ed19fddf58dd2661bf3 |
| Knowledge.lua | fca4582dd56101068fe022592704a89a6e26f0a669503c7fa359c318693a448d | 5c41300d521ae350ee66740c2722ca937e169bcf5f32f933a780fed96dfcc2b0 |
| Collectors.lua | 10af464a948da209053c7f53443e625b127a4041586793f5f0115f7035d14d7b | 4af664239054d94cb536e343dd1a7ab28aaa86493cdf3e5a67ed1f7552f2bf6f |
| SelfTests.lua | aa83f952f56d2ea0fa91d5ff0dec42b124196a85d72cc12f4bcda923d903c5fd | 2240b59bb65efebac713b806ea0079dcb8ba9469d4efc0028a0b6773e2c807ed |

Only six owned paths change: those four Lua files, K09 TASKS execution state/report and
this append-only evidence. 68-path set unchanged; other62 files unchanged against writer
start. K08/older TASKS suffix, README and schema entire files, and evidence old prefix
preserved. Primary must compare its actual baseline, amend contract, then resume writer;
independent verification/acceptance remain later separate gates. No delivery/update gate.

## K09 final local implementation after primary allowlist amendment — 2026-11-16

Status **COMPLETE for implementation/local checks**, independent review and primary
acceptance **PENDING**. Primary examined its actual production baseline delta and the
named historical fixtures, then narrowly amended TASKS piece4. Same writer resumed
pieces4–5; no architecture/policy change was needed to resolve the partial-raw blocker.
Historical failed runs/partial report above are retained, not relabeled PASS.

### Final validation and coverage

Inspected approved scripts remain byte-identical to writer start; no runtime install.

| Exact command | Final actual result |
| --- | --- |
| `lua5.1 tests/dashboard.lua` | completed359/359, zero failures;309 retained+50 new; unchanged744 K6/565 K7 supplement checks PASS |
| `lua5.1 tests/run.lua` | 23/23 diagnostic fixtures PASS |
| `python3 tools/check_dashboard.py` | PASS,16required files,24Markdown,86links/anchors,8 unchanged diagnostic hashes; structural only |
| `python3 tools/check_diagnostics.py` | PASS,9required files; structural only |

Final dashboard log `/tmp/opencode/craftarmy-k09-dashboard-seventh.log` contains359 PASS
lines (50 K09), no FAIL or runner INCOMPLETE, and both supplement results. Earlier
`dashboard-final.log` was a successful358-case checkpoint, not the final frozen run.
Resume run history: fourth357/0 and fifth358/0, supplements744/565 PASS. Sixth358/1
exposed a new Core attribution branch treating tolerated extra `skill.policy` metadata
as Knowledge raw and dereferencing absent identity. Retained new compatibility regression;
bounded correction restricts raw identity binding to knowledgeRaw and evidence binding
to tree fields while retaining the existing scope guard. Seventh359/0/allfour PASS.
This final Core change occurred after primary's partial review and must be included in
the final independent review. No new formula, relaxed Knowledge guard or design fork.
Initial three failed runs and baseline results remain recorded in the preceding report.

Fifty new cases comprise22 positive graph/end-to-end/dynamic/combined cases plus28
resolver, currency, preservation, attribution, drift, budget and compatibility cases:

- All eight exact tuples match unchanged Data.expansions; each identity field's missing,
  wrong type/value, metatable (including protected false), unknown/older/gathering cases
  fail closed. Localized names are independent. No Data/native global mutation.
- For each seven new professions: coherent wrong-currency rewrite (all spend/currentcost/
  shared rows), including incomplete wrong raw; missing/conflicting/duplicate shared rows,
  absent path currency with typed partial raw, and positive auxiliaries excluded.
- For each seven:25 failure variants after a successful scan, same APIs on fresh DB,
  then complete recovery. Missing node/entry/spend/shared currency, non-unit costs,
  unlock/spend types, increased/entry ranks, missing late child (Engineering110352),
  cycle/duplicate/shared/unreachable paths, tab9/path65/child17/currency65/cost17 bounds,
  incomplete tabs, staged/unknown staging and shared-row conflict/duplicate coverage.
  Whole old tree/index last values and observation times retained/nonfresh; old graph
  identities unchanged. First numeric values stay unknown, not zero/capacity. Wrong raw
  becomes unknown/no-value while valid skill advances; coherent recovery becomes fresh.
- Source/config/context/serial/revision drift on each profession discards all writes,
  retaining exact prior graph/scan time and clearing freshness; recovery passes.
- Foreign typed-valid raw, foreign trees and internally valid swapped evidence currency
  reject through Apply, active/archive Open and no-raw tree-only candidates/generations.
  Rejection checks all graph references/values/timestamps, not just nil. Valid own tree-
  only generation and independently retained tree times/balances/new partial raw load.
- Formerly accepted coherent Inscription70002 fails despite every NativePathPoints call
  succeeding. Inscription numeric values, Details success and legacy/eight-profession
  evidence command scope/privacy/no-write scenarios execute in all retained309 cases.
- Combined raw/result overbudget yields failed attempts but commits valid generic skill,
  retains old raw/trees/index, gives fresh DB no numeric values, and recovers. Real DB
  padded to exact50000 expanded values rejects a larger assembled snapshot atomically
  with no changed graph/time or fresh flags. Unsupported identity remains unsupported/
  no-value raw. Legacy no-policy schema1 loads without migration.

All193 full Q03 projections and auxiliary native-order rows remain exactly text-matched;
fixture-only labels/definitionIDs/configs/GUIDs/dynamic variants stay explicitly synthetic.
JC four1-point entries, Engineering four35-point children/110352 and positive auxiliary
balances remain intact. **Combined eight complete raw+numeric native-derived snapshots:
29793/50000 expanded values**, real Scan/Apply/Copy/Open/eight-row render PASS. No evidence
omission, aggregate substitute, hidden eviction, reduced scenarios or raised limits.

### Historical-test delta and writer freeze

Only approved sites changed; all309 original cases/scenario work retained. Eleven exact
substitution regions replace12 original lines with35 lines. K2 four70002→3902 lines;
E01 wrong3902 raw status/reason; E03 helper branches on existing distinct tree count for
one-tree observed typed-incomplete own-identity/absent-spend raw versus four-tree wrong3902
unknown/nil raw; E03 cached own typedpartial/time100/nonfresh; E04/E05 observed ownidentity/
emptytabs/incomplete raw; K08 wrong3902 unsupported→unknown. Unknown numeric/index/Details,
gear/generic/enchant and no-read/no-write assertions unchanged. No names/comments changed.

Exact complete old-test diff:108lines/6997bytes SHA256
`56e0d7e90b37b4b9cdeb7d5337819abb70dee533d6484a224bc0b4695e7c77a4`, temporary
`/tmp/opencode/craftarmy-k09-writer-oldtest.diff`. Explicit replacement replay matched
every old byte outside those regions. Remove ONLY K09 block and reverse ONLY the audited
approved changes restores exact SelfTests SHA256
`aa83f952f56d2ea0fa91d5ff0dec42b124196a85d72cc12f4bcda923d903c5fd`. Subsequent old-delta
hash recheck and inverse PASS. New block740lines/44013bytes SHA256
`c279cf2d3bf817b5c2d38c508c47f7e1513d2bfc290056765fc6fd14a61326ad`.

Primary external snapshot read was denied once, not retried/bypassed. All writer proofs
use the actual68-file writer-start snapshot/manifest recorded above, **not independent
comparison against primary's inaccessible baseline**. Final pathset remains68; exactly
8 owned paths change (four Lua, README prepend, schema/evidence appends, K09 TASKS execution
state/report; primary's K09 allowlist amendment intentional). All60 other files unchanged,
including PLAN/Q03/hidden config. Old README suffix, schema/evidence prefixes and entire
K08-and-older TASKS suffix preserved. No new implementation or repository artifact files.

| Frozen file | Final SHA256 |
| --- | --- |
| CraftArmy/Core.lua | 168653d91ab31bb991540e57082b45d78c41e690961600537395a33bf4be0856 |
| CraftArmy/Knowledge.lua | 5c41300d521ae350ee66740c2722ca937e169bcf5f32f933a780fed96dfcc2b0 |
| CraftArmy/Collectors.lua | 4af664239054d94cb536e343dd1a7ab28aaa86493cdf3e5a67ed1f7552f2bf6f |
| CraftArmy/SelfTests.lua | 71668103b8ac762b71476056197c0958fe8bb42723e7114beb218dce59b53d3e |
| docs/dashboard/README.md | 2a84ad57e4b82ff11cf60b0a7e12a62cf00092b0c8571979dac64da57d8e63f3 |
| docs/dashboard/schema.md | 80ca2be2d90025067a58435c08e40094c25822c40cd9382d42384f73f0b397f1 |

Core/Knowledge/Collectors complete writer-start production diff follows:117lines/
7340bytes SHA256 `d7f0d1a2036309dfee192d777165620b5d059f048d7ef6dc7a56ddd5859b6b23`.
Temporary exact copy `/tmp/opencode/craftarmy-k09-writer-production-final.diff`; this
durable copy makes production review independent of temporary-directory access.

```diff
--- writer-start/CraftArmy/Core.lua
+++ target/CraftArmy/Core.lua
@@ -283,8 +283,23 @@
 local SOURCE_PIN="297d7aaaa736f346b3e036f38ee088eaf7f8c07f"
 local function nativeInteger(v) return Core.Integer(v) and v<=2147483647 end
 local function nativeID(v) return nativeInteger(v) and v>0 end
-local function nativeScope(v)
+local function detailsScope(v)
     return type(v)=="table" and v.skillLineID==2913 and v.parentID==773 and v.profession==13 and v.expansionID==11
+end
+-- Q03: focused Retail 12.1.5/build70783 trait-spend evidence, not Moxie IDs
+-- or universal/all-rank cost proof. Private scalar catalogue; Core also runs alone.
+local nativeCurrencies={
+    [2906]={171,3,4030}, [2907]={164,1,3750}, [2909]={333,9,4056},
+    [2910]={202,8,3903}, [2913]={773,13,3902}, [2914]={755,12,3989},
+    [2915]={165,2,4085}, [2918]={197,7,3736},
+}
+function Core.NativeKnowledgeCurrency(v)
+    if type(v)~="table" or getmetatable(v)~=nil then return nil end
+    for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
+        if not nativeID(v[key]) then return nil end
+    end
+    local row=nativeCurrencies[v.skillLineID]
+    if row and v.parentID==row[1] and v.profession==row[2] and v.expansionID==11 then return row[3] end
 end
 local function uniqueIDs(v,limit)
     local seen={}
@@ -381,7 +396,8 @@
     if type(v)~="table" or not optional(v.configID,positive) or not optional(v.stagedStart,boolean) or
         not optional(v.stagedEnd,boolean) or not optional(v.stable,boolean) or not boolean(v.tabsComplete) or
         not optional(v.nativeComplete,boolean) or not optional(v.sourceCounter,nativeInteger) then return false end
-    if v.policy~=nil and (v.policy~=NATIVE or not nativeScope(v.identity) or not boolean(v.nativeComplete) or
+    local expected=v.policy==NATIVE and Core.NativeKnowledgeCurrency(v.identity)
+    if v.policy~=nil and (v.policy~=NATIVE or not expected or not boolean(v.nativeComplete) or
         not optional(v.configID,nativeID)) then return false end
     if v.policy==NATIVE and v.nativeComplete and (not nativeID(v.configID) or not nativeInteger(v.sourceCounter)) then return false end
     if v.identity~=nil then
@@ -401,7 +417,10 @@
             not optional(t.currencyCount,nativeInteger) then return false end
         if v.policy==NATIVE then
             if not nativeID(t.id) or not optional(t.root,nativeID) or not boolean(t.currenciesComplete) or not traitCurrencies(t.currencies) then return false end
-            for id,p in pairs(t.paths) do if not nativeID(id) or not boolean(p.metadataComplete) then return false end end
+            for id,p in pairs(t.paths) do
+                if not nativeID(id) or not boolean(p.metadataComplete) or
+                    (p.spendCurrencyID~=nil and p.spendCurrencyID~=expected) then return false end
+            end
             if v.nativeComplete then
                 if not t.coverageComplete or not t.currenciesComplete then return false end
                 for _,p in pairs(t.paths) do if not p.metadataComplete or not p.childrenComplete then return false end end
@@ -586,11 +605,23 @@
     if not (type(g) == "table" and Core.Integer(g.generation, 1) and
         validIdentity(g.identity,id) and Core.Integer(g.scannedAt) and
         validFields(g.fields, g.generation)) then return false end
-    for _,f in pairs(g.fields) do
+    for key,f in pairs(g.fields) do
         local v=f.last and f.last.value
-        if type(v)=="table" and (v.policy==NATIVE or v.accountingPolicy==NATIVE) and not nativeScope(g.identity) then return false end
-    end
-    if g.fields.professionDetails~=nil and not nativeScope(g.identity) then return false end
+        if type(v)=="table" and (v.policy==NATIVE or v.accountingPolicy==NATIVE) then
+            local expected=Core.NativeKnowledgeCurrency(g.identity)
+            if not expected then return false end
+            -- Attribution belongs to registered Knowledge fields, not tolerated
+            -- extension metadata on unrelated typed payloads (e.g. skill.policy).
+            if key=="knowledgeRaw" and v.policy==NATIVE then
+                for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
+                    if v.identity[key]~=g.identity[key] then return false end
+                end
+            end
+            if key:match("^tree:") and v.accountingPolicy==NATIVE and
+                v.accountingEvidence.currencyID~=expected then return false end
+        end
+    end
+    if g.fields.professionDetails~=nil and not detailsScope(g.identity) then return false end
     return true
 end
 function Core.Open(db)
--- writer-start/CraftArmy/Knowledge.lua
+++ target/CraftArmy/Knowledge.lua
@@ -132,9 +132,8 @@
 local function nativeEvaluate(scan)
     local out={trees={},complete=false}
     if not plain(scan) then out.reason="Malformed native scan"; return out end
-    local identity=scan.identity
-    local all=plain(identity) and identity.skillLineID==2913 and identity.parentID==773 and
-        identity.profession==13 and identity.expansionID==11 and integer(scan.configID,1) and
+    local expected=C.NativeKnowledgeCurrency(scan.identity)
+    local all=expected~=nil and integer(scan.configID,1) and
         integer(scan.sourceCounter) and scan.nativeComplete==true and scan.tabsComplete==true and
         scan.stable==true and scan.stagedStart==false and scan.stagedEnd==false
     local tabsValid=nativeList(scan.tabs,8,function(v) return plain(v) end) and #scan.tabs>0
@@ -170,6 +169,7 @@
                     r.purchased=r.purchased+points.purchased; r.capacity=r.capacity+points.capacity
                 else fail(why) end
                 if integer(p.spendCurrencyID,1) then
+                    if p.spendCurrencyID~=expected then fail("Wrong profession native spend currency") end
                     if common and common~=p.spendCurrencyID then fail("Different native spend currencies") end
                     common=common or p.spendCurrencyID
                 else fail("Missing native spend currency") end
--- writer-start/CraftArmy/Collectors.lua
+++ target/CraftArmy/Collectors.lua
@@ -470,10 +470,11 @@
             result.complete=false; result.reason="Knowledge evidence exceeds bounded snapshot payload"
             for _,tree in ipairs(result.trees) do tree.complete=false; tree.reason=result.reason end
         end
-        if ctx.identity.skillLineID==2913 and ctx.identity.parentID==773 and
-            ctx.identity.profession==13 and ctx.identity.expansionID==11 then
-            obs("knowledgeRaw",evidenceFits and raw or nil,"C_ProfSpecs / C_Traits",
-                evidenceFits and "observed" or "unknown",not evidenceFits and result.reason or nil)
+        if C.NativeKnowledgeCurrency(ctx.identity) then
+            local rawValid=evidenceFits and C.ValidPayload("knowledgeRaw",raw,"observed")
+            obs("knowledgeRaw",rawValid and raw or nil,"C_ProfSpecs / C_Traits",
+                rawValid and "observed" or "unknown",not rawValid and
+                (not evidenceFits and result.reason or "Invalid native raw metadata or wrong profession spend currency") or nil)
         else
             obs("knowledgeRaw",nil,"C_ProfSpecs / C_Traits","unsupported",
                 "Native Knowledge accounting is unverified for this profession")
```

### Remaining gates / next owner

No writer remainder/blocker. Primary must compare its actual full baseline/target,
including the final narrow Core correction, then obtain independent read-only review
and persist acceptance before any update/native advice. Later update manifest remains
Core+Knowledge+Collectors+SelfTests, not installation approval now. After those gates:
one batched focused NORMAL seven-profession numeric tree/order/hover/Unspent comparison,
responsiveness/errors/warnings and one closed/reload spot-check, no accepted generic/
capture/identifier/Inscription/fullselftest repeats. K09 native display/persistence NOT
RUN; K08 focused evidence accepted. Full native suite remains INCOMPLETE87/149; future
all-rank costs/quantitative native timing/unobserved API paths unverified. No gameplay,
game install, Git, release/publication/deployment or child agents. Writer STOPPED.

## K09 primary actual comparison, independent bounded review and acceptance — 2026-11-16

Primary independently compared actual pre-implementation68-file baseline, not writer's
substitute: eight intended changed files,60 unchanged, same paths; old README suffix,
schema/evidence prefixes and complete K08/older TASKS suffix unchanged. Primary examined
every old-test hunk under amended allowlist and reproduced exact oldSelfTests aa83f952...
inverse; all193 native fixture path/entry/child/rank/currentcost rows exactly match Q03
in order. Recomputed production diff byte-equals the durable117line/7340byte/d7f0d1a2...
diff above. Added primary-owned docs/dashboard/k09-review.md afterwards.

Fresh PRIMARY executions: `lua5.1 tests/dashboard.lua` completed359/359, unchanged744K6/
565K7 PASS, noFAIL/runnerINCOMPLETE; `lua5.1 tests/run.lua`23/23; both Python checks PASS
(24Markdown/86links before review record). Full dashboard log temporary
`/tmp/opencode/craftarmy-k09-primary-dashboard.log`. Combined eight full snapshots case
reports29793/50000 values. Script/source hashes unchanged from writer freeze. No new
native/client proof inferred from any fixture or structural check.

Verifier ses_e1e8ba2d1ffe74UyITuMqTOx1C returned COMPLETE, acceptance PASS for bounded
STATIC scope only, no findings/static blockers. Reviewed full production delta including
final Core generic-marker correction, current integration, all50 newcases/193paths/
auxiliary rows, named historical adaptations and README/schema. Permission denied before
attempted dashboard execution; no retry/workaround, other3commands not independently
run. Source hashes/fulltree/inverse/executable proofs remain primary/writer-attributed.
No reviewer edits/artifacts or independently executed post-review hash check.

Primary persisted review before advancing, then checked all6 source/docs hashes and
fulltree freeze: PASS/no moving implementation. Accept bounded implementation from
primary executable/comparison evidence plus independentstaticPASS. Four production/test
hashes and schema remain frozen; primary only updates README administrative gate and
appends acceptance/run-state docs. PlatformN/A. Review scope, hashes and limitations
durably recorded docs/dashboard/k09-review.md.

NextUSER backup saved data/update Core.lua, Knowledge.lua, Collectors.lua, SelfTests.lua
in CraftArmy, then one batched NORMAL dashboard comparison for seven newly numeric
professions: treeX/Y/nativeorder/branchhovers/Unspent and responsiveness/errors/warnings;
one newnumeric closed/reload spot-check without rescan. No DBreset/migration/diagnostic
update or repeated genericfields/captures/IDs/Inscription/fullselftest. K09 native NOTRUN;
K08 accepted focusedevidence unchanged, allrankcostsUNVERIFIED and historicalfullnative
INCOMPLETE87/149 retained. No agent-performed install, Git, release/publication/deploy.

## K09 focused user dashboard confirmation — 2026-11-16

User: “All the values match what was expected and are behaving as expected.” In response
to the delivered K09 update/focused seven-profession normal dashboard request, accept
reported value agreement and expected normal-use behavior. No outstanding issue was
reported. K09 focused user sequence is COMPLETE at this general reported scope; the
user did not separately itemize scans, hovers, closed/reload steps, timestamps or measured
latency, so no detailed per-step or quantitative/failure-path evidence is invented.

Implementation, primary local checks/comparison/freeze, independent boundedstatic
review and focused user validation remain distinct completed gates with their recorded
limits. No new Lua execution, native agent testing or source/test changes here. No more
routine Knowledge update/capture/identifier/selftest rounds requested. All-rank costs
UNVERIFIED and historical native fullsuite INCOMPLETE87/149 remain unchanged. This is
not blanket API/failure coverage, all-dashboard/guide completion or release approval.

### 2026-11-16 — U05 writer partial stop / old U04 RGB allowlist blocker

Status PARTIAL. Pieces1–4 implemented but not independently verified. Piece5 BLOCKED:
the old `U04 real bars numeric zero full unknown labels and built in flat texture`
expects blue for unmapped synthetic tree11 (original SelfTests5851/current5853).
U05 explicitly requires neutral for unknown IDs. First postchange approved command
`lua5.1 tests/dashboard.lua` completed359 cases,358PASS/1FAIL, exit1, no runner
INCOMPLETE: `0.45 ~= 0.2` at that assertion. K6/K7 not reached on this failed run.
No other old failure. The writer did NOT alter that assertion or map synthetic IDs
to work around it. Primary must amend piece5 allowlist for ONLY the expected RGB
`{0.2,0.65,0.95}` -> `{0.45,0.50,0.58}`, retaining zero/full/unknown scenarios and
all other assertions. Then resume5: add >=24 meaningful U05 cases (none added yet),
finish regressions, then6 README/schema/full checks/freeze and independent review.

Prechange scripts inspected; fresh writer-executed baseline commands:
- `lua5.1 tests/dashboard.lua`:359/359, zero failures,744K6/565K7 PASS.
- `lua5.1 tests/run.lua`:23/23 PASS.
- `python3 tools/check_dashboard.py`:PASS,25Markdown/88links/eight diagnostic hashes.
- `python3 tools/check_diagnostics.py`:PASS.
No baseline failures. Postchange diagnostics/Python NOT RUN at this stop. Native U05
NOT RUN; source evidence Q03 is not client execution. Historical native fullsuite
INCOMPLETE87/149 unchanged. No Knowledge capture/ID/API/timing chase performed.

Primary69-file baseline `/tmp/opencode/craftarmy-u05-baseline-ox5phjc_/files` was
accessible; its files match writer-start except intentional TASKS administrative
updates after primary snapshot. Separate pre-edit writer-start69-file snapshot:
`/tmp/opencode/craftarmy-u05-writer-start/files`, sibling JSON manifest SHA256
`bea73966b56136a077d35ed1105c092eae20bdc3886ff491b06ed5f9aca85a6c`.
Actual path set unchanged69; changed eight assigned paths only: Core,Collectors,Data,
ViewModel,Dashboard,SelfTests under CraftArmy; TASKS and this evidence append. Other61
paths unchanged. README/schema unchanged; evidence preexisting prefix and entire
K09-and-older TASKS suffix preserved. No new source files or unowned changes.

Exact old359 inverse PASS: reverse five historical marker literal occurrences and
four archived OnClick -> equivalent explicit radio selections, remove only the five
new actually-used mock methods and root BackdropTemplate rect support. Result is
byte-identical to primary/start SelfTests SHA256
`71668103b8ac762b71476056197c0958fe8bb42723e7114beb218dce59b53d3e`.
No old scenarios, workloads, limits or unrelated assertions altered. No U05 block yet.
Old adaptation diff at `/tmp/opencode/u05-partial-old-tests.diff`.

Partial source hashes (not a completed/accepted revision):
```text
d9ecece7d9b2dd2b0966d3c52690d430f0f2b1e249b549c640fd6667c81d0f75 CraftArmy/Core.lua
8a2aec1da6c15f52babbf781ed84c5cb7dcbfbbbc99727e72310ebb0406451c1 CraftArmy/Collectors.lua
7e889a35cf485041c6c127a408792a3b1c5982bf96cd3d05c39b26f8fabc419f CraftArmy/Data.lua
22ce00ad5de73729abd068c676957814d34a0715dcc3b1861361280b67166dd2 CraftArmy/ViewModel.lua
694a8b3da3b1e5836e85349cbe801c5187f0cda20cb5e0dde5cd8782caa6d401 CraftArmy/Dashboard.lua
c8c26f9d5584e0c95a29558051079519750f4d37d7cc9a9f85d4ff46c1d03747 CraftArmy/SelfTests.lua
```

Implemented optional schema1 classToken syntax/Open/Apply preservation and protected
current-player read/native color rendering; private visual tree palette; centered gear;
tilde-only historical marker removal; typed keys/all14 heading sort controls; native
View/Attention menus with invalidating fallback; flat HIGH dashboard and only existing
owned Details DIALOG hook. No Details/Knowledge/KnowledgeCheck/Commands source edits,
numeric/raw/freshness/threshold changes, migration/reset, installs/gameplay/Git/release.
No final docs/update advice. Platform N/A. Writer stopped; primary amendment is next.

Complete partial production diff below:375lines/21698bytes SHA256
`3bfcc716900e7e218872968e5497aaeb61e51cef13ef63a2d03341b80304c2da`;
temporary identical artifact `/tmp/opencode/u05-partial-production.diff`.

```diff
--- before/CraftArmy/Core.lua
+++ after/CraftArmy/Core.lua
@@ -624,6 +624,9 @@
     if g.fields.professionDetails~=nil and not detailsScope(g.identity) then return false end
     return true
 end
+function Core.ValidClassToken(value)
+    return type(value)=="string" and #value>=1 and #value<=32 and value:match("^[A-Z]+$")~=nil
+end
 function Core.Open(db)
     if db == nil then return {schema=1, characters={}}, nil end
     if type(db) ~= "table" or getmetatable(db) or db.schema ~= 1 or type(db.characters) ~= "table" then
@@ -633,6 +636,7 @@
     for guid, c in pairs(db.characters) do
         if type(guid) ~= "string" or guid == "" or type(c) ~= "table" or
             type(c.name) ~= "string" or type(c.realm) ~= "string" or
+            (c.classToken~=nil and not Core.ValidClassToken(c.classToken)) or
             type(c.professions) ~= "table" then return nil, "Invalid character; writes disabled." end
         for id, p in pairs(c.professions) do
             if not Core.Integer(id, 1) or type(p) ~= "table" or
@@ -693,6 +697,7 @@
     character, identity, observations = incoming[1], incoming[2], incoming[3]
     if type(character) ~= "table" or type(character.guid) ~= "string" or character.guid == "" or
         type(character.name) ~= "string" or type(character.realm) ~= "string" or
+        (character.classToken~=nil and not Core.ValidClassToken(character.classToken)) or
         type(identity) ~= "table" or type(observations) ~= "table" or not validIdentity(identity,identity.skillLineID) or
         not Core.Integer(at) or not label(build) then
         return nil, "Invalid scan identity"
@@ -700,6 +705,7 @@
     local old = db.characters[character.guid]
     local c = old and Core.Copy(old) or {professions={}}
     c.name, c.realm = character.name, character.realm
+    if character.classToken~=nil then c.classToken=character.classToken end
     local id = identity.skillLineID
     local p = c.professions[id] or {nextGeneration=1, archives={}}
     local g = p.active
--- before/CraftArmy/Collectors.lua
+++ after/CraftArmy/Collectors.lua
@@ -186,7 +186,13 @@
         local name=call("UnitName","player")
         local realm=call("GetRealmName")
         if type(guid)~="string" or guid=="" or type(name)~="string" or type(realm)~="string" then return nil end
-        return {guid=guid,name=name,realm=realm}
+        local character={guid=guid,name=name,realm=realm}
+        -- Optional own-player metadata only. Failed reads/validation never erase a
+        -- same-GUID saved token or prevent the existing guarded generic scan.
+        local token=call("UnitClassBase","player")
+        local ok,valid=pcall(C.ValidClassToken,token)
+        if ok and valid==true then character.classToken=token end
+        return character
     end
     function self:Roster()
         -- Blizzard_ProfessionsBook uses first two results as learned primaries.
--- before/CraftArmy/Data.lua
+++ after/CraftArmy/Data.lua
@@ -1,6 +1,21 @@
 local _, NS = ...
 local Data = {}
 NS.Data = Data
+-- Visual identity only: Q03 native tab observations/build70783. This private
+-- catalogue is NOT an accounting/collection eligibility or topology authority.
+local treePalette={{.20,.65,.95},{.20,.78,.48},{.98,.62,.20},{.70,.42,.92}}
+local treeColors={
+    [2906]={1140,1142,1144,1143},[2907]={1068,1069,1075,1076},
+    [2909]={1155,1154,1153,1152},[2910]={1131,1176,1132,1133},
+    [2913]={1122,1124,1182,1125},[2914]={1138,1136,1139,1137},
+    [2915]={1158,1157,1159,1156},[2918]={1067,1070,1071,1072},
+}
+function Data.TreeRGB(professionID,tabID)
+    for slot,id in ipairs(treeColors[professionID] or {}) do
+        if tabID==id then return unpack(treePalette[slot]) end
+    end
+    return .45,.50,.58
+end
 Data.revision = "297d7aaaa736f346b3e036f38ee088eaf7f8c07f"
 Data.build = "12.1.5 (70783)"
 -- ProfessionConstantsDocumentation.lua: enumeration, NOT expansion skill lines.
--- before/CraftArmy/ViewModel.lua
+++ after/CraftArmy/ViewModel.lua
@@ -7,6 +7,10 @@
 V.columns={"Name","Realm","Profession","Skill","Accessory #1","Accessory #2","Tool","Stat","Enchant",
     "Concentration","Moxie","Knowledge trees","Unspent KP","Last Updated"}
 V.roles={"accessory1","accessory2","tool"}
+function V.SortDescending(column)
+    return column==I.Accessory1 or column==I.Accessory2 or column==I.Tool or
+        column==I.Concentration or column==I.Moxie or column==I.Unspent or column==I.LastUpdated
+end
 local colors={[2]={30/255,1,0},[3]={0,112/255,221/255},[4]={163/255,53/255,238/255}}
 local function str(v) if v==nil then return "?" end return tostring(v) end
 local function number(v) return C.Finite(v) end
@@ -237,7 +241,7 @@
 
 function V.Row(guid,c,id,g,session,now,archived)
     if archived then session=nil end
-    local row={guid=guid,id=id,generation=g.generation,archived=archived==true, name=c.name,realm=c.realm,
+    local row={guid=guid,id=id,generation=g.generation,archived=archived==true, name=c.name,realm=c.realm,classToken=c.classToken,
         profession=g.identity.name or D.families[g.identity.profession] or tostring(id),professionFamily=g.identity.profession,
         cells={},warnings={},trees={},known=0}
     row.key=guid..":"..id..":"..g.generation
@@ -334,7 +338,7 @@
             row.enchantAttention=true; tool.tooltip[#tool.tooltip+1]=w.label
         else
             local col=({Moxie=I.Moxie,Concentration=I.Concentration,Progression=I.Skill})[w.category]
-            local marker=w.fresh and "|cffffbb00!|r " or "|cff999999~!|r "
+            local marker=w.fresh and "|cffffbb00!|r " or "|cff999999!|r "
             row.cells[col]=marker..row.cells[col]
         end
     end
@@ -388,6 +392,30 @@
         if w.category=="Missing enchant" then tool.summaryTooltip[#tool.summaryTooltip+1]=w.label end
     end
     for _,lines in pairs(summaries) do bounded(lines) end
+    -- Presentation-only typed keys. Never compare warning markup/age strings or
+    -- borrow raw Knowledge/skill progression as evidence of displayed tree totals.
+    local keys={[I.Name]=row.name:lower(),[I.Realm]=row.realm:lower(),[I.Profession]=row.profession:lower()}
+    local function numeric(column,value) if number(value) then keys[column]=value end end
+    numeric(I.Skill,skill and skill.skillLevel)
+    numeric(I.Concentration,row.concentration); numeric(I.Moxie,row.moxie)
+    numeric(I.Unspent,unspent); numeric(I.LastUpdated,g.scannedAt)
+    for n,role in ipairs(V.roles) do
+        local gear=row.gear[role]
+        if gear.empty then keys[I.Accessory1+n-1]=-1
+        elseif gear.exists==true and C.Integer(gear.rarity) and C.Integer(gear.rank,1) and gear.rank<=5 then
+            keys[I.Accessory1+n-1]=gear.rarity*10+gear.rank
+        end
+    end
+    for column,value in pairs({[I.Stat]=tool.statsText,[I.Enchant]=tool.enchantText}) do
+        if not value:find("?",1,true) then keys[column]=value:lower() end
+    end
+    local purchased,capacity,complete=0,0,#row.trees>0
+    for _,tree in ipairs(row.trees) do
+        if tree.purchased==nil or tree.capacity==nil then complete=false
+        else purchased=purchased+tree.purchased; capacity=capacity+tree.capacity end
+    end
+    if complete and capacity>0 then keys[I.Knowledge]=purchased/capacity end
+    row.sortValues=keys
     return row
 end
 
@@ -419,7 +447,15 @@
     end
     table.sort(rows,function(a,b)
         local mode=options.sort
-        if mode=="concentration" or mode=="moxie" or mode=="enchant" or mode=="progression" then
+        local column=options.sortColumn
+        if C.Integer(column,1) and column<=#V.columns then
+            local av,bv=a.sortValues[column],b.sortValues[column]
+            if av==nil and bv~=nil then return false elseif av~=nil and bv==nil then return true end
+            if av~=bv then
+                if options.sortDescending==true then return av>bv end
+                return av<bv
+            end
+        elseif mode=="concentration" or mode=="moxie" or mode=="enchant" or mode=="progression" then
             local key=mode=="enchant" and "enchantMissing" or mode
             local av,bv=a[key],b[key]
             if av==nil and bv~=nil then return false elseif av~=nil and bv==nil then return true end
--- before/CraftArmy/Dashboard.lua
+++ after/CraftArmy/Dashboard.lua
@@ -13,6 +13,27 @@
 local function clean(text)
     -- Labels are not executable markup. Item hyperlink rendering is separate.
     return tostring(text or ""):gsub("|","||")
+end
+local function classRGB(env,token)
+    -- Protect both native lookup/ColorMixin access and scalar validation. No
+    -- runtime color objects or RGB values cross the saved-data boundary.
+    local ok,r,g,b=pcall(function()
+        if not C.ValidClassToken(token) then return end
+        local api=env.C_ClassColor
+        if not api or type(api.GetClassColor)~="function" then return end
+        local color=api.GetClassColor(token)
+        if not color then return end
+        local red,green,blue
+        if type(color.GetRGB)=="function" then red,green,blue=color:GetRGB()
+        else red,green,blue=color.r,color.g,color.b end
+        for _,v in ipairs({red,green,blue}) do
+            if not C.Finite(v) or v<0 or v>1 then return end
+        end
+        if red==nil or green==nil or blue==nil then return end
+        return red,green,blue
+    end)
+    if ok and r~=nil and g~=nil and b~=nil then return r,g,b end
+    return 1,1,1
 end
 function Dashboard.PlainTooltip(text)
     local raw=tostring(text or "")
@@ -87,6 +108,65 @@
         local b=env.CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
         b:SetSize(width,22); b:SetText(label); b:SetScript("OnClick",fn); return b
     end
+    local function raise(frame)
+        if frame and type(frame.Raise)=="function" then pcall(frame.Raise,frame) end
+    end
+    -- Only View/Attention share this plumbing; Profession's public behavior stays
+    -- unchanged. Invalidate callbacks before exposing a noninteractive fallback.
+    local function menu(parent,alias,title,key,choices,default,x,width,clearSelection)
+        local state={available=false}
+        local placeholder=env.CreateFrame("Frame",nil,parent)
+        placeholder:SetSize(width,25); placeholder:SetPoint("TOPLEFT",x,-55); placeholder:EnableMouse(true)
+        local label=text(placeholder,width-4); label:SetPoint("LEFT",2,0)
+        label:SetText(title..": "..choices[1].label.." (unavailable)")
+        placeholder:SetScript("OnEnter",function(w) tooltip(w,{state.reason or (title.." dropdown unavailable.")}) end)
+        placeholder:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
+        local dropdown
+        local function unavailable(reason)
+            state.available=false; state.reason=title.." dropdown unavailable: "..reason.."; showing "..choices[1].label.."."
+            self.options[key]=default; self.offset=0
+            if clearSelection then self.selected=nil end
+            if dropdown then dropdown:Hide() end
+            self[alias]=placeholder; placeholder:Show()
+            if self.selectionArea then self:Refresh() end
+        end
+        self[alias.."Menu"]=state
+        local ok,result=pcall(env.CreateFrame,"DropdownButton",nil,parent,"WowStyle1DropdownTemplate")
+        if ok then dropdown=result end
+        if not dropdown then unavailable("native creation failed"); return end
+        state.dropdown=dropdown
+        if type(dropdown.SetupMenu)~="function" or type(dropdown.SetDefaultText)~="function" then
+            unavailable("SetupMenu/SetDefaultText missing"); return
+        end
+        dropdown:SetSize(width,25); dropdown:SetPoint("TOPLEFT",x,-55)
+        state.available=true; self[alias]=dropdown
+        local function selected(value) return state.available and (self.options[key]==value or (self.options[key]==nil and value==default)) end
+        local function select(value)
+            if not state.available then return end
+            local choice
+            for _,entry in ipairs(choices) do if entry.value==value then choice=entry end end
+            if not choice then return end
+            local updated=pcall(dropdown.SetDefaultText,dropdown,title..": "..choice.label)
+            if not updated then unavailable("SetDefaultText failed"); return end
+            self.options[key]=value; self.offset=0
+            if clearSelection then self.selected=nil end
+            self:Refresh()
+        end
+        local setup=pcall(function()
+            dropdown:SetDefaultText(title..": "..choices[1].label)
+            dropdown:SetupMenu(function(_,root)
+                if not state.available then return end
+                if not root or type(root.CreateRadio)~="function" then unavailable("root CreateRadio missing"); return end
+                for _,choice in ipairs(choices) do
+                    if not pcall(root.CreateRadio,root,choice.label,selected,select,choice.value) then
+                        unavailable("CreateRadio failed"); return
+                    end
+                end
+            end)
+        end)
+        if not setup then unavailable("SetupMenu/SetDefaultText failed"); return end
+        if state.available then placeholder:Hide() end
+    end
     function self:ProfessionControl(parent,x,width)
         local placeholder=env.CreateFrame("Frame",nil,parent)
         placeholder:SetSize(width,25); placeholder:SetPoint("TOPLEFT",x,-55); placeholder:EnableMouse(true)
@@ -191,12 +271,20 @@
     function self:Create()
         if self.frame then return true end
         if combat() then self.wantOpen=true; return false end
-        local frame=env.CreateFrame("Frame",nil,env.UIParent,"BasicFrameTemplateWithInset")
+        local frame=env.CreateFrame("Frame",nil,env.UIParent,"BackdropTemplate")
         self.frame=frame; frame:SetSize(G.outerWidth,G.baseHeight+G.rowHeight); frame:SetPoint("CENTER")
+        frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
+        frame:SetBackdropColor(.055,.065,.085,.98); frame:SetBackdropBorderColor(.18,.21,.26,1)
+        frame:SetFrameStrata("HIGH"); frame:SetToplevel(true)
         frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
+        frame:SetScript("OnShow",function(f) raise(f) end)
+        frame:SetScript("OnMouseDown",function(f) raise(f) end)
         frame:SetScript("OnDragStart",function(f) f:StartMoving() end)
         frame:SetScript("OnDragStop",function(f) f:StopMovingOrSizing() end)
-        frame.TitleText:SetText("CraftArmy — observed crafting snapshots")
+        self.title=text(frame,G.contentWidth-30); self.title:SetPoint("TOPLEFT",G.margin,-8)
+        self.title:SetText("CraftArmy — observed crafting snapshots")
+        self.close=button(frame,"X",22,function() frame:Hide() end)
+        self.close:SetPoint("TOPRIGHT",-G.margin,-5)
         self.statusArea=env.CreateFrame("Frame",nil,frame); self.statusArea:SetSize(G.contentWidth,16)
         self.statusArea:SetPoint("TOPLEFT",G.margin,-31); self.statusArea:EnableMouse(true)
         self.reason=text(self.statusArea,G.contentWidth); self.reason:SetAllPoints()
@@ -208,25 +296,13 @@
         self.statusArea:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
         local refresh=button(frame,"Refresh",76,function() collector:Request("Manual refresh") end)
         refresh:SetPoint("TOPLEFT",G.margin,-G.toolbarTop)
-        local sortModes={"attention","concentration","moxie","enchant","progression"}
-        local sortIndex=1
-        self.sort=button(frame,"Sort: attention",150,function(b)
-            sortIndex=sortIndex%#sortModes+1; self.options.sort=sortModes[sortIndex]
-            b:SetText("Sort: "..self.options.sort); self:Refresh()
-        end); self.sort:SetPoint("LEFT",refresh,"RIGHT",6,0)
         local categories={"All","Concentration","Moxie","Missing enchant","Progression"}
-        local categoryIndex=1
-        self.attention=button(frame,"Attention: All",176,function(b)
-            categoryIndex=categoryIndex%#categories+1; self.options.attention=categories[categoryIndex]
-            b:SetText("Attention: "..categories[categoryIndex]); self.offset=0; self:Refresh()
-        end); self.attention:SetPoint("LEFT",self.sort,"RIGHT",6,0)
-        self.archived=button(frame,"View: Active",110,function(b)
-            self.options.archived=not self.options.archived
-            b:SetText(self.options.archived and "View: Archived" or "View: Active")
-            self.offset=0; self.selected=nil; self:Refresh()
-        end); self.archived:SetPoint("LEFT",self.attention,"RIGHT",6,0)
-        self.toolbar={refresh,self.sort,self.attention,self.archived}; self.filters={}
-        local toolbarWidth=76+150+176+110+3*6
+        local choices={}
+        for _,category in ipairs(categories) do choices[#choices+1]={label=category,value=category} end
+        menu(frame,"attention","Attention","attention",choices,"All",115,176,false)
+        menu(frame,"archived","View","archived",{{label="Active",value=false},{label="Archived",value=true}},false,315,126,true)
+        self.toolbar={refresh,self.attention,self.archived}; self.filters={}
+        local toolbarWidth=450
         local filterWidth=(G.contentWidth-toolbarWidth-2*6)/2
         local function filter(label,x,key)
             local l=text(frame,76); l:SetPoint("TOPLEFT",x,-65); l:SetText(label)
@@ -245,10 +321,17 @@
         local x=G.margin
         self.headers={}
         for i,label in ipairs(V.columns) do
-            local header=env.CreateFrame("Frame",nil,frame)
+            local header=env.CreateFrame("Button",nil,frame)
             header:SetSize(widths[i],G.headerHeight); header:SetPoint("TOPLEFT",x,-G.headerTop)
             local l=text(header,widths[i]-4); l:SetPoint("LEFT",2,0); l:SetText(shortHeaders[i] or label)
+            if roleColumns[i] then l:SetJustifyH("CENTER") end
             header.label=l; self.headers[i]=header
+            header.direction=text(header,8); header.direction:SetPoint("RIGHT",-1,0)
+            header:SetScript("OnClick",function()
+                if self.options.sortColumn==i then self.options.sortDescending=not self.options.sortDescending
+                else self.options.sortColumn=i; self.options.sortDescending=V.SortDescending(i) end
+                self.offset=0; self:Refresh()
+            end)
             header:EnableMouse(true)
             header:SetScript("OnEnter",function(w) tooltip(w,{label}) end)
             header:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
@@ -272,6 +355,7 @@
                 cell:SetSize(widths[col],G.rowHeight); cell:SetPoint("LEFT",left,0); cell:EnableMouse(true)
                 cell.fill=cell:CreateTexture(nil,"BACKGROUND"); cell.fill:SetAllPoints(); cell.fill:SetColorTexture(0,0,0,0)
                 cell.label=text(cell,widths[col]-4); cell.label:SetPoint("LEFT",2,0)
+                if roleColumns[col] then cell.label:SetJustifyH("CENTER") end
                 cell:SetScript("OnEnter",function(widget)
                     local r=w.row; if not r then return end
                     local down=diagnostics()
@@ -294,7 +378,12 @@
                         if combat() then return end
                         if not self.details then self.details=NS.Details.NewView(env,collector) end
                         local r=w.row
-                        self.details:Open({guid=r.guid,id=r.id,generation=r.generation,archived=r.archived==true})
+                        if self.details:Open({guid=r.guid,id=r.id,generation=r.generation,archived=r.archived==true}) then
+                            local detailsFrame=self.details.frame
+                            if detailsFrame and type(detailsFrame.SetFrameStrata)=="function" then
+                                pcall(detailsFrame.SetFrameStrata,detailsFrame,"DIALOG"); raise(detailsFrame)
+                            end
+                        end
                     end
                 end)
                 w.cells[col]=cell; left=left+widths[col]
@@ -345,6 +434,9 @@
     function self:Render()
         if not self.frame then return end
         self:Layout()
+        for column,header in ipairs(self.headers) do
+            header.direction:SetText(self.options.sortColumn==column and (self.options.sortDescending and "v" or "^") or "")
+        end
         self.offset=math.max(0,math.min(self.offset,math.max(0,#(self.rows or {})-G.pageRows)))
         for i,w in ipairs(self.widgets) do
             local r=self.rows and self.rows[self.offset+i]; w.row=r
@@ -352,6 +444,8 @@
                 w:Show()
                 for col,cell in ipairs(w.cells) do
                     cell.label:SetText(r.cells[col] or "")
+                    cell.label:SetTextColor(1,1,1)
+                    if col==I.Name then cell.label:SetTextColor(classRGB(env,r.classToken)) end
                     cell.fill:SetColorTexture(0,0,0,0)
                     local role=roleColumns[col]; local gear=role and r.gear[role]
                     if gear and gear.exists==true and gear.rarityColor then
@@ -362,6 +456,7 @@
                 for n,b in ipairs(w.bars) do
                     local t=r.trees[n]; b.tree=t
                     if t then
+                        b:SetStatusBarColor(D.TreeRGB(r.id,t.id))
                         local width=(widths[I.Knowledge]-4)/math.max(1,#r.trees)-2
                         b:ClearAllPoints(); b:SetPoint("LEFT",(n-1)*(width+2),0); b:SetWidth(width)
                         b.label:SetWidth(width)
```

U05 partial evidence correction (same stop): the manually transcribed production
diff above has one CONTEXT-line typo in ViewModel's `@@ -388,6 +392,30 @@` hunk.
It is not a source change. Replace that context line when reconstructing the diff:
```text
         if w.category=="Missing enchant" then tool.summaryTooltip[#tool.summaryTooltip+1]="Attention: "..w.label end
```
All other diff bytes match the temporary artifact. This single correction restores
the stated21698-byte/SHA256 production diff. The raw transcription itself is not
byte-identical; first durable-diff equality check failed on exactly this typo. Full
primary69-path/eight-owned-change/61-unmodified freeze, README/schema unchanged,
evidence old prefix and K09older suffix checks passed before that failed comparison.

### 2026-11-16 — U05 final local implementation after exact RGB allowlist amendment

Status COMPLETE for writer scope only. Pieces1–6 complete, no writer blocker/remainder.
Primary actual comparison, independent read-only review and acceptance are PENDING;
native U05 appearance/control check NOT RUN. No update/install/release advice yet.
Primary inspected and authorized only the obsolete U04 synthetic tree11 expected RGB
tuple blue -> neutral. All three zero/full/unknown scenarios and every other old
assertion retained. No runtime mapping/workaround for synthetic tree11.

**Actual final execution (not an expected-count substitution):**
- `lua5.1 tests/dashboard.lua`:completed409/409, zero failures, unchanged744K6/565K7.
- `lua5.1 tests/run.lua`:23/23 PASS.
- `python3 tools/check_dashboard.py`:PASS,25Markdown/89links/eight diagnostic hashes.
- `python3 tools/check_diagnostics.py`:PASS.
Scripts inspected before baseline and checked byte-identical on resume; installed
Lua5.1 only, no installations. No final runner INCOMPLETE. Baseline359/359+744/565,
23/23/bothPythonPASS had no failures. These are writer-run local fixture/structural
results, NOT independent reviewer, target-client API, appearance or timing evidence.

**Failure history preserved:** first358PASS/1FAIL at old U04 blue assertion, stopped
for primary's exact allowlist amendment. After resume/new tests, second386PASS/21FAIL
(407 total): new synthetic ready gear omitted required itemID/link, gear variant
omitted metadataReady, and actual Details fixture lacked SetVerticalScroll. Third
406PASS/1FAIL: new unmapped stat test used an invalid non-ITEM_MOD key; changed ONLY
that new key to ITEM_MOD_UNMAPPED_SHORT. New fixture plumbing was corrected, never
production validators/old expectations. Fourth407/407+744/565; two further additive
cases made fifth409/409+744/565; final four-check run above409/409+744/565. Failed
runs did not reach supplements; no false supplement result attributed to them. A
fourth shell wrapper returned1 only because a subsequent grep found no FAIL lines;
its Lua output completed407/407. Fifth/final Lua exit0 explicitly verified. No caps,
old case/scenario loops, stress work, time limits or production policy changed.

**50 new meaningful cases**, marked `-- U05 BEGIN:` through `-- U05 END`, immediately
before Tests.Run. Eight profession-map cases verify all32 native tab/color bindings,
uniqueness, scalar/private palette, reordering/localized identical labels/two alts,
bar recycling/geometry/numeric-only labels/unknown fill/neutral fallback with no reads
or DB effects. Other visual tests cover centered headers/cells/padding, real icon/
quality/rarity/confirmed-empty/unknown behavior. Class cases cover shared ASCII syntax,
first-return player-only normal scan, missing/throwing/malformed optional reads,
protected shared-validation error, same-GUID preservation, owner isolation, invalid
Apply/Open graph-identical rejection, active/archive/reload/old DB compatibility,
ColorMixin GetRGB and RGB fields, malformed/throwing colors and strict per-cell reset
call ordering when recycling from colored to neutral owner. Colors/token stay separate
from plain name/sort/filter/tooltip strings; no persisted RGB/runtime objects.

Fourteen separate heading cases test each typed key in both directions and active/
archived views, unknowns-last and deterministic ties. Additional cases exercise zero
versus unknown, numeric keys despite formatted warnings, case-folded labels, rarity
then crafted rank/empty/unknown, stat/enchant unmapped components, weighted sum of ALL
known displayed trees versus partial/no/zero-capacity/raw-only/skill-only evidence,
numeric newest-first timestamp, GUID/id/generation tie breaks, legacy/invalid-heading
behavior and attention-first default. Real heading buttons test first/default/repeat/
other-column behavior, canonical labels/hovers, direction indicator, pagination reset
and selection rebinding. Historical marker tests retain amber versus muted exclamation,
600/601 and899/900 thresholds, stale/fresh flags, original observation time/diagnostics.

Generated native radio tests exercise all Attention options/both View choices and
combined character/profession filters, labels, offsets/selections, no DB/collection/
timers/gameplay effects. Six separate native-failure cases cover creation/missing
SetupMenu/missing SetDefaultText/SetupMenu error/missing CreateRadio/CreateRadio error;
late failure tests verify noninteractive explained fallback, All/Active reset and
stale-callback invalidation including SetDefaultText errors. Flat chrome tests verify
WHITE8X8 fill/1px border/exact colors/title/close/drag/HIGH/toplevel/safe raise, actual
existing Details Open -> only owned frame DIALOG/raise, unrelated frame unchanged,
combat creation defer, native decoration nonoverlap, unchanged1454/1424/row/header/
viewport/footer geometry, small-screen fit, confirmation cancel and widget reuse.
These mocks preserve protocol checks but do not prove native API behavior or fit.

**Exact old359 inverse, actual comparison and frozen scope:** primary baseline
`/tmp/opencode/craftarmy-u05-baseline-ox5phjc_/files` remained accessible. Same69
actual paths including hidden configuration; ten intended owned changes,59 unchanged:
```text
CraftArmy/Collectors.lua
CraftArmy/Core.lua
CraftArmy/Dashboard.lua
CraftArmy/Data.lua
CraftArmy/SelfTests.lua
CraftArmy/ViewModel.lua
TASKS.md
docs/dashboard/README.md
docs/dashboard/evidence.md
docs/dashboard/schema.md
```
README old bytes remain exact suffix; schema/evidence old bytes exact prefixes;
entire K09-and-older TASKS suffix exact. No new source files, unowned changes or
unexplained history edits. Primary's RGB amendment in U05 TASKS is intentional.
Separate writer-start manifest attribution remains in the partial entry; these are
writer-performed comparisons to accessible actual primary baseline, not independent
primary/reviewer proofs. No Knowledge/KnowledgeCheck/Commands/Details/TOC/runner/
checker/diagnostic/config changes. All safety budgets/stress workloads frozen.

Remove ONLY the U05 block; reverse ONLY five historical marker literal occurrences,
four old archived invocations -> explicit equivalent Archived/Active native radio
selections, five new actually-used mock methods and root BackdropTemplate rect support,
and the approved single U04 RGB tuple. Every other old byte is unchanged; exact result:
`71668103b8ac762b71476056197c0958fe8bb42723e7114beb218dce59b53d3e`.
Inverse script verified exact occurrence counts3 historical prefix literals plus2
601 literals,2 Archived/2Active calls,1 method-list edit,1 rect edit and1 RGB edit.
Old adaptation diff92lines/7093bytes SHA256
`f5fd580bdd24c07619600ed3ec1097d86099fe04d7d3ec9866724c6e52fe8482`, artifact
`/tmp/opencode/u05-final-old-tests.diff`. No names, old scenario logic or assertion
changes beyond the allowlist. U05 block483lines/30460bytes SHA256
`9df720854ee9b96328f0921c937f0588676f9b483491ac689bb553ddc7034be7`.

**Complete production delta remains unchanged since partial stop:**375lines/21698bytes
SHA256 `3bfcc716900e7e218872968e5497aaeb61e51cef13ef63a2d03341b80304c2da`.
The full durable diff is in the preceding partial entry; apply its explicit one-line
CONTEXT transcription correction to reconstruct the byte-exact diff. That corrected
durable reconstruction was verified against actual source comparison and temporary
artifact `/tmp/opencode/u05-partial-production.diff`. No final production source was
changed to make new fixtures pass. Full source/test/docs path diff artifact
`/tmp/opencode/u05-final-full.diff` is regenerated at freeze; its administrative
TASKS/evidence portions necessarily include these final reports and are not assigned
a self-referential digest here. Production/test/README/schema are frozen at:
```text
d9ecece7d9b2dd2b0966d3c52690d430f0f2b1e249b549c640fd6667c81d0f75 CraftArmy/Core.lua
8a2aec1da6c15f52babbf781ed84c5cb7dcbfbbbc99727e72310ebb0406451c1 CraftArmy/Collectors.lua
7e889a35cf485041c6c127a408792a3b1c5982bf96cd3d05c39b26f8fabc419f CraftArmy/Data.lua
22ce00ad5de73729abd068c676957814d34a0715dcc3b1861361280b67166dd2 CraftArmy/ViewModel.lua
694a8b3da3b1e5836e85349cbe801c5187f0cda20cb5e0dde5cd8782caa6d401 CraftArmy/Dashboard.lua
86deee99123f3a4df5b6000a5c177cf8237c02922e426777a2afc1863a0e4f79 CraftArmy/SelfTests.lua
b1856aa405a321fad6cc615dabcde4f7ea7bd5c8f21fe7905f6f8fa01e1dfd88 docs/dashboard/README.md
16752fb5a9c2af97bed0cf2ad959486dc1d29f010a576b2c979edcdafc0bc1ee docs/dashboard/schema.md
```

**Remaining gates/next action:** PRIMARY independently recomputes actual comparison
and arranges independent read-only review of frozen delta, persists review results
and acceptance BEFORE update advice. Later native check only focused appearance/
controls with existing snapshots; normal own-alt scan only if classToken absent.
No repeated Knowledge capture/IDs/fullselftest/correctness rounds. Optional schema1
classToken has no migration/reset; source-pinned UnitClassBase/C_ClassColor evidence
is not native execution. No newnumeric/raw gate, freshness/threshold or Details source
change. Existing K09 focused acceptance, allrankcosts UNVERIFIED and historical full
native INCOMPLETE87/149 unchanged. Platform review N/A. No install/gameplay/Git/
publication/releases performed or authorized. Writer STOPPED; no blocker/remainder.

## U05 primary comparison, independent static review and acceptance — 2026-11-16

Primary independently recomputed actual69-path baseline comparison: ten approved changed
files/59 unchanged, old README suffix/schema+evidence prefixes and entire K09older TASKS
suffix exact. Independently reproduced old359 SelfTests71668103... inverse with only
approved marker/menu/helper/RGB edits; every other old byte/scenario/runner unchanged.
Complete375line/21698byte productiondiff SHA3bfcc716... equals durable partial diff
after its explicitly recorded one-context-line correction. Added primary review record
docs/dashboard/u05-review.md afterwards; no implementation moved.

Fresh PRIMARY `lua5.1 tests/dashboard.lua`: completed409/409, unchanged744K6/565K7,
zero failures/no runner INCOMPLETE; `lua5.1 tests/run.lua`:23/23; both Python structural
checks PASS (25Markdown/89links before review record). Full dashboard log temporary
`/tmp/opencode/craftarmy-u05-primary-dashboard.log`. These are primary-executed local
checks, not native appearance/API/menu/priority/timing proof or reviewer execution.

Verifier ses_e1df38776ffeiyC5yH3UkXYDkI: COMPLETE, acceptance PASS for bounded STATIC
review only, no findings/static blockers. Corrected five-production-file delta, all50
newcases/namedold359adaptations, integration/menu+header protocol/ownedDetails hook and
README/schema/evidence reviewed. Shell access denied once/no retry/bypass; no tests or
hash/fulltree/inverse/postreview freeze proofs independently executed. Proof attribution
remains primary/writer as recorded. No reviewer edits/artifacts. PlatformN/A.

Primary persisted independent result, then recomputed all8reviewed hashes/fulltree:
PASS, all59unowned baselinefiles unchanged and only new primary review record. Accept
bounded implementation from primary executable/comparison proof +independentstaticPASS.
Six source/test hashes and schema stay frozen; only administrative README gate and
acceptance docs change after review. NativeU05NOTRUN; no native result invented.

NextUSER backup/update Core.lua, Collectors.lua, Data.lua, ViewModel.lua, Dashboard.lua,
SelfTests.lua in CraftArmy, then focused cached UI appearance/controls check. Normal
own-alt scan only to populate absent classToken; old/offline snapshots remain neutral
until observed. No reset/migration/diagnostic update, class guessing/offline reads or
repeated Knowledge captures/IDs/correctness/fullselftests. K09accepted/allrankcosts
UNVERIFIED/fullnativeINCOMPLETE87/149 unchanged. No agent install/Git/gameplay/release.

## U05 partial native report and account-growth reproduction — 2026-11-16

User reports most characters' class-colored names/progress bars/enchants update, while
some normal scans print “CraftArmy: Assembled snapshot exceeds bounded saved data
limits”. U05 native acceptance remains PARTIAL; no complete UI/control/behavior claim.

Read-only primary investigation confirms final Core.Apply assembled preflight walks
the WHOLE saved account with the same50000-value cap. It returns before the single
real character-map write; it does not erase old snapshots. User DB not inspected.

Local reproduction, isolated fresh namespace only: load current addon modules, execute
existing K09 combined-eight fixture (full193 non-Inscription paths plus full Inscription),
capture its synthetic DB via temporary isolated Apply wrapper then restore original.
Use real Core.Apply to add full existing Inscription observations under distinct
synthetic characters; no live native APIs, saved game data or source edits.

| Successful profession rows | Whole DB visited values |
| --- | ---: |
| 8 | 29793 |
| 9 | 34031 |
| 10 | 38269 |
| 11 | 42507 |
| 12 | 46745 |

Attempted13th returns exact assembled-limit error. Original map identity,12rows/value
count and absence of rejected character verified unchanged. This is a demonstrated
storage-scaling limitation with valid data, not a measured13-row universal capacity
or actual user DB count. Sizes vary with professions/metadata/archives/Details.

No limits, evidence, scenarios or data changed; no new full-suite/native PASS claimed.
Do not ask for resets/deletion/eviction or repeated updates/scans/captures/selftests.
Next settle a separate scalable-storage correction preserving all validation/atomicity/
snapshot guards and obtain implementation approval. No code writer or storage-policy
change authorized by this report alone. Rough roster count may help size that proposal;
no private GUID/entire SavedVariables upload is needed for this demonstrated failure.

## Storage roster target reported — 2026-11-16

User confirms six successfully refreshed characters with two professions each (12rows),
three previously scanned characters currently unable to scan, and46characters potentially
tracked later. These are user-reported counts, not inspection of live SavedVariables.
Do not infer that each blocked character has exactly two stored complete rows. Target
at least46characters/92active profession rows plus preserved history/Details.

Primary recorded a versioned lossless bounded-record storage/migration recommendation
in docs/dashboard/storage-scaling-proposal.md, not an implemented or approved fix. Current
source/caps/data/full409 test coverage unchanged; no new executable/native proof. No
deletion/reset/cap increase, private upload or additional native scan/capture/selftest
requested. Direction/migration approval and exact serial contract remain prerequisites
to an implementation writer; no game installation/Git/publication/release authorization.

## Storage shared-definition direction / sizing projection — 2026-11-16

User approves changing storage but identifies shared profession nodes and unnecessary
per-character diagnostic duplication. Revised normalized design supersedes opaque
packing of all old evidence. Meaningful personal data/history/unknowns remain; rich
live checks stay mandatory while full raw scan reports need not be normal saved data.
Repository design/evidence history is unrelated and not authorized for deletion.

Primary read-only sizing script loads current modules in an isolated namespace and
runs existing full K09 eight-profession fixture. Restores temporary Apply observation
wrapper, then projects static tree IDs/names/roots/children/spend capacities into eight
catalogues. For46synthetic characters with two professions each, copies existing other
fields/envelopes, replaces each numeric tree's repeated proof with per-node points/lock
maps +catalogue/tree reference, replaces repeated index definitions with a reference,
and omits knowledgeRaw diagnostic copies. Result:92profession rows,8catalogues,
32095visited values against current50000copier ceiling. No source/gameDB/cap changes.

This conceptual projection is NOT an implemented schema, Core.Open validation, byte-size
measurement, migration, archived/Details capacity proof or native performance result.
It demonstrates normalization may address the actual duplication before a codec or
larger budget is considered. Full legacy/live correctness/stress input coverage remains
mandatory; new saved integrity/ref/migration tests and exact adapters still need a
complete primary-owned contract. No writer/installed update/new native round yet.

## Storage growth clarification — 2026-11-16

User clarifies46 is the CURRENT character count, future growth is expected, and allows
combining deduplication with independently bounded records. Revised S01 proposal no
longer requires the entire normalized account to fit the legacy50000visit budget.
That legacy primitive and schema1 behavior remain; schema2 needs complete validation
across records/catalogues/references/directories in bounded batches, not a cap increase
or checking only an index. No fixed character-count cap or unlimited-resource claim.

Prior32095 projection remains conceptual sizing, not implemented migration, scalable
validation or growth proof. New acceptance requirements include46×2 minimum, larger
rosters and valid accounts above50000aggregate values with per-record safety, atomicity,
old snapshots/Details/archive times and full live input guards retained. No new runtime
results claimed here. Documentation only; exact schema/adapters/migration/scheduling
contract and implementation remain pending. No writer or further native evidence round.

## S01 partial writer stop — preserved tree history exceeds specified Step dependency bound

2026-11-16. **PARTIAL/BLOCKED, acceptance INCOMPLETE.** Sole writer; no children,
installation/gameplay/private SavedVariables/Git/publish/release action. No planning,
contract, question-thread or independent-review artifacts edited. Primary decision is
required; passing subset fixtures are not permission to update the addon.

### Exact blocker and resume point

The settled S01 keep map preserves all generation fields/envelopes; contract5 bounds one
record-validation Step to at most8 referenced tree definitions. Real unchanged Core.Apply
accepts8 successful legacy trees/index, then a successful changed index with tree9, retaining
all9 fields. Core.Open accepts the resulting legacy DB. The additive test `S01 required
dependency budget legacy retained nine tree fields` migrates that actual valid input,
preserves all9, and observes **9 distinct tree definitions validated inside one Step**.
The observer wraps only Core.Copy, is restored before every checkpoint, and uses no fake
production validator/native report. The legacy topology/policy in this minimal reproducer
is explicitly synthetic, not new native API evidence. Rich full native fixtures are tested
separately below. Current implementation violates the8-dependency requirement; its assertion
remains failing. No cap, history deletion, hidden omission or bound relaxation chosen.

PRIMARY must reconcile bounded dependency validation with preserving every retained tree,
and amend the settled technical contract. Then resume by re-auditing provisional pieces1–5,
finishing piece6's remaining matrices (listed in top S01 TASKS report), then piece7 final
docs/checks/freeze. All pieces are marked `[!]` for this blocker/dependency; none is claimed
complete. Independent review and primary acceptance have not occurred.

### Provisional implementation and scoped local evidence

New Storage module follows Core, whose sole edit exports existing MergeEquipment. Source
includes schema2 catalogue/record validators and owned facade, full actual empty-v1 Core.Apply
rich preflight, per-generation write/lifecycle operations, incremental open/migration/iterator,
collector/Details adapters, Commands startup and Dashboard build drivers plus bounded model
mergesort. Schema1 consumers remain on the legacy behavior. Storage migration candidates are
private and root publication is guarded. This is an unfinished implementation, not a safety
or native responsiveness acceptance claim; additional ownership/reentry/drift/freshness/
scheduler/Details/item-retry matrices and audits remain explicitly outstanding in TASKS.

All409 old SelfTests bytes/scenarios retained;14 additive cases in one S01 block,13 passing
and the required bound case failing. Legacy Core bodies and the entire K6/K7 supplement
suffix remain exact. tests/dashboard.lua has only the Storage module-list insertion; TOC
likewise; checker changes only accurate manifest/order/count wording (11sources/17required).
Knowledge, Data, KnowledgeCheck, diagnostics, agent config and unowned files remain frozen.

Growth uses the existing full K09 combined-eight fixture, invoked without checkpoints under
a temporary Apply observer (restored before yielding); rich input packs are individually
owned. Valid legacy8rows=29793visited values. Migration8rows=5466values/32catalogues/154Steps.
All larger rosters grow only by real schema2 Apply with complete original rich inputs, not
oversized invalid legacy roots or hand-made compact graphs.12->13 rows accepted. Counts:

| Characters / active rows | Compact aggregate values | Catalogues | Reload open Steps | Model build Steps |
| --- | --- | --- | --- | --- |
| 46 / 92 | 44416 | 32 | 544 | 102 |
| 100 / 200 | 94310 | 32 | 1138 | 223 |
| 200 / 400 | 186710 | 32 | 2240 | 451 |

All three sizes traverse actual reload/open/iterator/model paths; values/row keys compared,
one alt updated after reopen without replacing unrelated profession directories. Actual U03
Inscription Details sample is added with its independent200 observation time/100 scan time,
archived, relearned and reloaded;400active+1archived rows retained before scoped archive delete.
Selected corruption matrices exercise primitive limits, aliases, scope/refs/point/state/keys;
fixtures also cover owned reads, same/changed equipment retention, failed attempts, revision
lookup, changed labels/build/locale, newer raw/older trees, all14 column comparators against
legacy sorting, iterator/build cancellation/revision guards, startup cancel/retry/combat and
missing scheduler, ephemeral actual rich Details source/final-frame native-node mismatch,
and dashboard pending/superseded/hidden/missing-scheduler behavior. This list is not exhaustive
contract coverage. New work checkpoint grouping does not remove any simulated job operation.

### Exact command chronology and limitations

Approved scripts inspected; installedLua5.1 only. No known baseline failure. Initial source
scaffolding `lua5.1 tests/dashboard.lua` completed409/409+744K6/565K7, exit0; diagnostics23/23
and both Python checks exit0. Adapter stage repeated409/409+744/565, exit0. First additive
run completed417:416PASS/1FAIL because the old graph-freeze helper cannot compare a NaN to
itself; corrected only the new fixture with its own NaN-aware identity snapshot. No legacy
helper/test edit. The first growth run hit the existing10000 runner-Step cutoff at417/0:
**INCOMPLETE, not PASS**, despite shell exit0 and supplements744/565 executing afterward.
Grouped only NEW S01 fixture checkpoints (all actual work/old cases/limits retained). Next
run completed422:421PASS/1FAIL because original mock Show does not dispatch OnShow; the new
UI fixture now simulates native Show/Hide callbacks without editing old mocks. After the
real dependency-bound gap was identified, dependent coding stopped; only its reproducer,
stop documentation and comparison/check artifacts were added.

Final approved commands (logs under the artifact location below):

- `lua5.1 tests/dashboard.lua` — COMPLETED423, **422PASS/1FAIL**, exit1. All409 old cases
  and13new cases PASS; dependency-bound regression FAILS with actual9. Supplements are NOT
  reached in this failing command; their earlier successful execution is separately scoped.
- `lua5.1 tests/run.lua` —23/23, exit0.
- `python3 tools/check_dashboard.py` —PASS17required/28Markdown/97local links, exit0.
- `python3 tools/check_diagnostics.py` —PASS, exit0.

Mock fixtures/work counters/visited-value sizing are not target-client API, quantitative
frame-time, serialization-byte or crash-durability evidence. Full native remains
INCOMPLETE87/149; all-rank-costs UNVERIFIED; no new Knowledge capture/ID/fullclient test round.

### Comparison and artifacts

Actual primary72-file baseline was accessible once; comparison at writer start found only
the intentional TASKS baseline-pointer append. Primary snapshot:
`/tmp/opencode/craftarmy-s01-baseline-j71j9fts/files`; sibling manifest SHA256
`39130651d848849bfee0404fa484675dec92f0ab3b4651b560ae73bcd30831ae` (primary-supplied).
Separate writer-start72-file snapshot `/tmp/opencode/craftarmy-s01-writer-start/files`,
manifest SHA256 `ba4e26389d764ffa39481f2544149cf39fcba2eff7054b177214dba24549f893`.
Comparison target is the entire local working directory (no Git/staged distinction).

Complete primary-baseline and writer-start diffs, production/test diffs, full source/test
hash manifests, exact new S01 block, command logs and machine-readable inverse/history/
unowned/path proofs are saved at `/tmp/opencode/craftarmy-s01-partial-artifacts`. The
artifact metadata reports the final actual changed-path set and inverse hashes. Expected
retention hashes: SelfTests86deee99123f3a4df5b6000a5c177cf8237c02922e426777a2afc1863a0e4f79;
Core d9ecece7d9b2dd2b0966d3c52690d430f0f2b1e249b549c640fd6667c81d0f75; runner
04d063ada82cbd0e5273f3defbeb27bfc5de976ccc466dd9effefb4b1900f9e4. No important execution
state relies only on a chat response. These are WRITER-executed proofs, not independent
primary/reviewer verification. Stop for primary contract resolution, not update advice.

Writer comparison executed successfully:72baseline->73target paths;15authorized changed
paths (14existing+Storage),58existing paths byte-identical; no removals/unowned changes.
Old409 SelfTests exact inverse, Core one-export inverse, runner insertion inverse, full
K6/K7 suffix, TOC insertion inverse, README suffix, schema/evidence prefixes and entire
U05-and-older TASKS suffix all PASS. Production diff SHA256
`0f275ae1245fee7aa3cfb07bb48c382ef3ba2c002c9c4af05d0e4fe66e192f69`;
new S01 test-block SHA256 `936088a0fce43fa7fc29565387ee85605bcd21bf6e5b605a2208940d56a2757f`.
Complete target hashes and artifact hashes are in target-manifest.json and
artifact-hashes.json at the recorded permitted artifact directory. Scope/hash preservation
PASS does not change the required local dependency-bound FAIL or unfinished test matrices.

## S01 final local completion after primary retained-field scheduling amendment

2026-11-16. **Implementation COMPLETE; independent verification/primary acceptance PENDING.**
The initial422PASS/1FAIL and INCOMPLETE growth run above remain accurate history. PRIMARY
read the real source/reproducer and settled contract5a in PLAN/TASKS/design contract before
this writer resumed. No new user decision, cap increase, field removal, old409 assertion
edit or architectural fork was chosen by the writer. No source installation/private DB
read/gameplay/Git/publication/release action or new native test request occurred.

### Scheduling correction and provisional-source re-audit

All historical tree fields survive; the existing9-tree Core-valid reproducer now also
retains17 fields across repeated index changes. Observers inspect actual catalogue Copy
work within each migration/open/iterator Step, restoring temporary wrappers before yielding;
at most ONE distinct full catalogue definition is validated per Step. This is not a counter
incremented independently of work. Startup record validation reuses only its copied/validated
private registry; migration compacts one field per Step and runs complete candidate opening.
Iterator preparation freshly copies/validates one dependency per Step before final record
expansion. No arbitrary synchronous S.Read fallback or eight-field/history cap.

Re-audited1–5 and hardened fresh touched-unit validation/immutable-content/ownership/counters,
occupied catalogue allocation rejection, callback-safe atomic/terminal cleanup, startup
publication after cleanup guards, render setup/job/scheduler failures, model freshness
capture/verification and context-drift clearing of the one ephemeral rich scan source.
Normal read/write validation is not weakened to pointer caching. Record semantic comparisons
include all original envelopes/generation/archive/independent field times and compact evidence.
Legacy Core bodies still have one export only; original409 test bytes and K6/K7 suffix intact.

### Completed fixture coverage and actual growth counts

37 additive S01 cases complete all specified matrix classes: every compact type/status/key/
primitive guard; raw identity/context/tab summaries; tree references/ownership/topology/
coverage/points/locks/availability/accounting evidence; Details coverage/earned/perk/text/count/
byte constraints; generation/catalogue counters/overflow and occupied slots; optional legacy
lock/availability/false/zero and generic metadata; compatible definitions/different allocations/
locked-zero; build/locale/label/topology/Details revision conflicts with immutable history and
independent old tree/new raw/Details/environment times; read/input/output isolation; touched
and unrelated corruption; cross-unit aliases/cycles/metatables; late failure/cancel/reentry/
directory/wrapper drift; actual empty-v1 rich preflight and affected-only hot paths without
account/character/history copier or schema2 Core.Open; startup/render missing/throwing native
scheduler, error/unknown combat/selftest/capture pauses, final publication and stale callbacks;
owned options/freshness/revisions/filters; all14 typed mixed known/unknown/tie column sorts
both directions and views against the original full U05 fixtures; actual collector retries/
failure/timeout/changed instance/context/archive token intervals; Details actual rich source,
live node/perk/source interval and final-frame guards; cached/reload/archive views with no
profession API access. Old409 workloads are unmodified; new grouped checkpoints retain
every simulated operation and all existing limits. Mocks are not native evidence.

Legacy8 full rich rows29793visited values -> schema2 migration5466values/32catalogues/
274Steps. Real full native-derived rich inputs then grow through actual Apply only:

| Characters / active rows | Compact aggregate values | Catalogues | Complete reload open Steps | Complete model Steps |
| --- | --- | --- | --- | --- |
| 46 / 92 | 44416 | 32 | 544 | 564 |
| 100 / 200 | 94310 | 32 | 1138 | 1225 |
| 200 / 400 | 186710 | 32 | 2240 | 2453 |

All sizes include real reopen/iterator/row comparison and one-alt update with unaffected
ownership preserved;12->13 succeeds. Actual U03 Inscription Details sample, independent
times, archive/relearn/reload/scoped delete retained. Additional stress creates120 full-rich
archived generations through lifecycle/Apply, deletes two selected records to leave118 sparse
archives+active generation121:57595aggregate values, complete reopen135Steps and118 archived
rows. These are fixture sizes/work counts, not caps, serialized bytes or measured native
frame times. Directory<=128edges, one record/catalogue unit and sort<=128compare/moves per
Step remain; no account-wide job-Step cap or aggregate50000 account walker was introduced.

### Checks, chronology and comparison attribution

Approved scripts inspected and unchanged except accurate manifest insertion/count; installed
Lua5.1 only. Resumed intermediate runs completed423/423,434/434,440/440,446/446 with unchanged
744K6/565K7. One new fixture syntax error (missing `end` in the added render matrix) occurred
twice before correction; no production workaround/old-test edit/coverage reduction. Dedicated
read of that temporary external log was denied once; not retried/bypassed. A fresh approved
Lua command's stdout provided the exact parse failure; both occurrences remain recorded.
Earlier partial422/1 and INCOMPLETE results are not reclassified as PASS.

Final approved commands on frozen source:
- `lua5.1 tests/dashboard.lua` — COMPLETED446/446 (409retained+37S01),744K6/565K7, exit0.
- `lua5.1 tests/run.lua` —23/23, exit0.
- `python3 tools/check_dashboard.py` —PASS17required/28Markdown/97links, exit0.
- `python3 tools/check_diagnostics.py` —PASS, exit0.

Baseline is the original actual72-file snapshot, target the entire local directory/no staged
distinction. Resume snapshot73files at `/tmp/opencode/craftarmy-s01-resume-start/files`,
manifest SHA256 `12c1038d3c8bb103df128dcc32bb8e42742c34a0bc5a7f6d5e95f2dc9093209e`.
Only intended PRIMARY PLAN/TASKS/contract changes existed since the partial target; primary
PLAN/contract remain writer-frozen and are explicitly attributed, not reverted/unowned drift.
Writer has15assigned changed paths; primary adds PLAN/contract (TASKS mixed ownership).
Expected complete comparison72base->73target/17changed paths/56existing byte-identical;
no removals/unknown changes. Old409/Core/runner exact inverse hashes remain the original
durable hashes, all K6/K7 suffix/TOC/README suffix/schema+evidence prefix/U05-older TASKS
history proofs included. These are writer-executed proofs, not independent verification.

Complete actual primary/resume/fulltree/production/test diffs, new S01 block, changed source
copies, all logs/hashes/final manifests and machine-readable proofs are saved under
`/tmp/opencode/craftarmy-s01-final-artifacts`; original partial artifacts remain separate.
Fullnative INCOMPLETE87/149 and all-rank-costs UNVERIFIED unchanged. STOP for primary actual
comparison, independent read-only verification and acceptance before any addon update advice.

Actual writer comparison/inverse/history/freeze proofs executed PASS (not merely expected):
72base->73target/17changed/56existing unchanged; primary planning and unowned resume hashes
frozen, primary TASKS amendment retained. Exact production diff SHA256
`f4ca5326bfbe7508b2678c433c4ce15ed93cfb93b69870f5790c0f67f00b05ee`;
S01 new-block SHA256 `b6c9ef309df2130603d51cff1a0a522e151327e0e57f794f9b6709169caddded`.
Removing only S01 restores SelfTests86deee99123f3a4df5b6000a5c177cf8237c02922e426777a2afc1863a0e4f79;
Core one-export inverse d9ecece7d9b2dd2b0966d3c52690d430f0f2b1e249b549c640fd6667c81d0f75;
runner insertion inverse04d063ada82cbd0e5273f3defbeb27bfc5de976ccc466dd9effefb4b1900f9e4.
Checker manifest-only inverse/TOC/K6K7/history prefixes/suffixes exact. Complete final source
hashes and artifact hashes are retained at the final artifact location for primary review.

## S01 piece8 correction — reviewed reuse ownership and frame batching

2026-11-17. **Locally COMPLETE; renewed independent verification/primary acceptance PENDING.**
Primary persisted the independent PARTIAL/CHANGES REQUIRED review in s01-review.md/TASKS
BEFORE delegating exact contract8/5b. The reviewer's artifact/shell denials and lack of
execution remain accurately scoped; prior446 execution/comparison proofs are primary-
attributed, not retroactively independent. That initial review failure is not relabeled PASS.
No design expansion, old409/old446 adaptation, cap increase, install/private SavedVariables/
gameplay/native capture/selftest request/Git/publication/release action occurred.

### Reproducer before fix and correction

Two new rejecting cases first ran on unchanged reviewed production source. Real Apply seed
and normal compatible reuse succeed; then identical-content Copy replacement or equal-content
cross-catalogue subtree alias is introduced and the same rich input applied to a NEW GUID.
Actual `lua5.1 tests/dashboard.lua`: completed448,446PASS/2FAIL, exit1. Both new owners were
unexpectedly committed. Old446 all PASS. That log is retained, not a mocked validator or a
claim of reviewer/native execution. stageCatalog now audits registration and all nested
ownership/aliases for each reused saved dependency, freshly validates complete types/primitive
bounds and immutable content before commit. Strict nested registration preserves/strengthens
public touched-reference rejection. Job-private staged/validated definitions keep their owned
path. Added Details reuse and identical nested-clone cases reject too; normal reuse controls
pass. Rejection checks full graph identities/values, nextCatalog, generation counters, revision,
old/new active tokens and absence of the new GUID. No partial commit or silent repair.

### Bounded batches and driver/publication guards

New runtime Storage.NewFrameBatch selects protected profile milliseconds, else precise seconds
converted to milliseconds, else explicit clockless-one-step fallback. It performs no more
than16 actual Step calls per callback while observed elapsed is below2ms between units,
maintains finite monotonic samples across callbacks and actual mode/status/work counters.
Selected clocks throwing/becoming invalid/backward/overflowing and job/guard errors/reentry
fail closed without clock switching or synchronous drain. A false guard pauses additional
work. Native error payloads are not propagated through callback failure reasons. Two ms is
an observed boundary between indivisible units; a7ms synthetic unit completes once before
the budget stop, proving overshoot rather than preemption. No native timing result inferred.

ONLY Commands startup and Dashboard build OnUpdate use batching. Original selftest/capture
Commands prefix and Details/collector/Knowledge schedulers are unchanged from prior446.
Postbatch and native-cleanup guards recheck job/runtime/original root or model/db/options/
freshness/revision/show/safety. Epoch/identity retirement prevents a reentrant clock/Step/
guard/cleanup callback from publishing a cancelled/unsafe/superseded result or overwriting a
newer job/UI. Missing Frame still blocks. Existing clockless446 fixtures remain unchanged.

12 additive piece8 cases exercise root/subtree/Details ownership regressions, actual max16/
zero-resolution/terminal/counter behavior, observed2ms boundary/seconds conversion/7ms unit
overshoot, clockless fallback, invalid/nil/nonfinite/throw/backward/overflow across and within
frames, guard pause/error and clock/guard/job reentry, actual scheduled growth with per-Step
catalogue observers, terminal-clock root/options/context/store revision changes, clock errors,
combat/selftest pauses, stale callbacks, reentrant retry and cleanup-gap supersession/safety.
Shared fixture overrides are restored within each observed Step before any safe checkpoint;
native environments/clocks are injected fixture-owned values, not real game API proof.

Actual zero-clock callback counts collected through real Commands/Dashboard OnUpdate and
the real batch helper (not Step counts divided by16):

| Fixture | Startup callbacks / job Steps | Dashboard callbacks / job Steps |
| --- | --- | --- |
| Valid legacy8-row migration | 18 / 274 | Separate growth views below |
| 46characters / 92rows | 34 / 544 | 36 / 564 |
| 100characters / 200rows | 72 / 1138 | 77 / 1226 |
| 200characters / 400rows | 140 / 2240 | 154 / 2454 |

Every size grows only through full native-derived rich Apply inputs, reopens actual schema2
through Commands and renders complete rows through Dashboard. Each wrapped individual job
Step observes<=ONE distinct actual catalogue definition validation; per-callback counters
stay<=16. Different synthetic GUID ordering/fixture path versus the earlier growth case is
retained; actual one-Step sort-count differences are reported rather than hardcoded away.
Previous values/archives/Details and all original growth workloads remain in the full suite.

### Validation, snapshots and stop

First integration completed448:447PASS/1FAIL at an unchanged existing S01 render-error prose
assertion (new batch label said failure, assertion expects failed). Production label clarified;
no assertion edit. Then455/455 and458/458 completed with unchanged744K6/565K7. Final checks:
- `lua5.1 tests/dashboard.lua`: COMPLETED458/458 (446 byte-retained+12new),744K6/565K7, exit0.
- `lua5.1 tests/run.lua`:23/23, exit0.
- `python3 tools/check_dashboard.py`:PASS17required/29Markdown/97links, exit0.
- `python3 tools/check_diagnostics.py`:PASS, exit0.
Approved scripts inspected; already-installedLua5.1 only. No INCOMPLETE or known final failure.
All earlier failure/INCOMPLETE/pre-review446 history remains above, not erased or relabeled.

Correction-start actual74-file snapshot `/tmp/opencode/craftarmy-s01-piece8-start/files`,
manifest SHA256 `bc6ac9e61c6a9904198007d7c9ad40fb5f37e7075b0b8f4636d2d56f093f23cd`.
Intended primary PLAN/TASKS/contract/review edits relative to the prior446 target preserved,
including later TASKS scope/pre-correction clarification. Compare entire directory to original
actual72-file baseline and prior frozen446, no Git/staging distinction. This correction changes
only Storage/Commands/Dashboard/SelfTests and execution docs; Core one export, all old446 bytes,
full old409 inverse, runner/checker/TOC, diagnostics/config/unowned paths and cooled history
are checked. PRIMARY PLAN/contract/review are writer-frozen; TASKS ownership is shared.

Complete original/prior446/correction-start production/test/fulltree diffs, new nested piece8
block, source copies, retained failure/final command logs, manifests/hashes and machine-readable
inverse/history/ownership/freeze proofs are under `/tmp/opencode/craftarmy-s01-piece8-artifacts`.
These are writer-executed comparisons, not renewed independent verification. STOP for primary
recomparison and renewed review/acceptance before addon update advice. Fullnative remains
INCOMPLETE87/149/all-rank costs UNVERIFIED; platform N/A. No native responsiveness guarantee.

Actual writer scope/inverse/history proof PASS:72original->74current paths,18changed,
56original byte-identical, only Storage+primary review document added/no removals. Exactly8
owned paths changed during correction; PRIMARY PLAN/contract/review frozen, TASKS primary
reports preserved and shared attribution recorded. Removing only the nested piece8 block
restores old446 SelfTests `e3bc97f39ec212d9c14611ee63909c7d2580c8ddd1b33f7d557dac98138af8fe`;
removing the full S01 block restores original409 `86deee99123f3a4df5b6000a5c177cf8237c02922e426777a2afc1863a0e4f79`.
Core one-export/runner/checker/TOC inverses, K6/K7 suffix, old README/schema/evidence/U05older
TASKS history and selftest/capture/Details/collector/Knowledge scheduler freeze proofs PASS.
Full production diff SHA256 `50c18d198aff3041fcf1be1abf543891d1b4d86c15c3926d839c62ddd8e3167e`;
piece8 production diff `b3b3c8c7f000a7804e760742aaaa472d819dbf4a51de0ebea10b7418fa368571`;
piece8 test-block `9619d89e97ae91343337dadc331bea97c1992120aa392c4566a227a3f6a70c04`.
Complete source/test/target/artifact hashes and command outputs retained in the current
artifact directory. Passing writer proofs are not independent review or update permission.

## S01 piece9 startup supersession correction — 2026-11-17

**Implementation/local checks COMPLETE; renewed scoped-static review/primary acceptance
PENDING. No update/install advice.** The primary persisted renewed COMPLETE scoped-static/
CHANGES REQUIRED before contract9/piece9 follow-up. Original catalogue ownership finding
RESOLVED; no changes there. Remaining medium was stale failure-status overwrite after
Hide-triggered explicit retry, not claimed root/snapshot loss. Both old findings and prior
458 checks remain attributed history. Denied reviewer operations not retried/bypassed;
all execution/hash/comparison proofs here are WRITER, not independent verification.

### Actual rejecting reproducer and callback audit

Captured actual74-file correction-start snapshot BEFORE editing:
`/tmp/opencode/craftarmy-s01-piece9-start/files`, manifest SHA256
`ae66d19de30162471b855c90b7ea5588259e89d8d088fce4dd4997aea4da0127`.
Only intended PRIMARY PLAN/TASKS/contract/review changed since frozen458 target.
Added one nested test with unchanged reviewed production source and ran
`lua5.1 tests/dashboard.lua`: completed459,458PASS/1FAIL, exit1. Selected batch clock threw
after opening completed; captured Hide ran explicit storage retry; retired failure replaced
the new pending reason/dashboard. Failure text: `Retired failure must not overwrite new
startup status: Frame batch clock failure; original data retained... ~= Saved storage
initialization/migration pending; writes disabled; scheduler profile-ms...`.
Full actual log `/tmp/opencode/s01-piece9-before-fix.log` retained in current artifacts.

Commands-only correction implements prescribed private monotonic startup epoch. StartStorage
and explicit cancellation advance it; current checks require epoch/job/runtime and owns
also original-root pointer. Entry cancellation/SetScript/Hide operate captured old objects,
rechecking after each before clearing state. Guarded message/retirement handles batch
failure/source drift/thrown callback/finish/setup failure; CreateFrame/SetScript/Show and
status refresh returns/errors cannot overwrite a nested retry. Current source drift is
explained even when original root changed (including setup/cleanup), but retired invocations
cannot write it over a replacement. Successful publication still requires all source/safety
guards. No automatic retry, format/native/primitive limit or scheduler-budget change.

5 additive cases retain all458 previous bytes, including exact409 and all prior S01 cases:
- Exact combined terminal clock error+Hide retry.
- Source drift before batch/terminal clock/finish Hide/setup Show, retry and current-fault status.
- Setup CreateFrame/SetScript/Show reentry on return or throw; failure cleanup at SetScript/Hide.
- Explicit cancel and StartStorage entry reentry at Cancel/SetScript/Hide.
- Thrown work/reported batch failure/successful finish cleanup at applicable boundaries.
Each replacement pins job/frame/batch, running/ready/pending state, collector/dashboard reason,
step/frame counters and original root graph; stale callbacks are inert before and after
normal completion through the real startup driver. No assertion adaptation or test skip.
Fixtures are not native API behavior or responsiveness evidence.

### Actual runs and preservation freeze

First corrected-source run459/459+744K6/565K7 PASS. Expanded463-case run461PASS/2FAIL:
new source-drift/setup fixtures accessed Dashboard.reason before its widget existed.
Corrected only new fixture setup to create dashboard first (setup tests use explicit retry
after initial cancel), no production assertion weakening or old458 edit. Then463/463 and
final463/463+744K6/565K7 PASS. All logs retained, failures not relabeled PASS.
Four approved/inspected checks on frozen source, all exit0:
- `lua5.1 tests/dashboard.lua`: completed463/463,744K6/565K7; no INCOMPLETE.
- `lua5.1 tests/run.lua`:23/23.
- `python3 tools/check_dashboard.py`:PASS17required/29Markdown/97links/eight diagnostic hashes.
- `python3 tools/check_diagnostics.py`:PASS.
InstalledLua5.1 only; scripts unchanged from inspected prior revision. Retained actual batch
counts unchanged: migration18callbacks/274Steps;46x2startup34/544,view36/564;
100x2startup72/1138,view77/1226;200x2startup140/2240,view154/2454.
Max16Steps/observed2ms-between-units, clockless-one-Step fallback and overshoot honesty remain.

Read-only assertions compared complete original72/reconstructed frozen458/correction-start74
inputs and current74 target:18changed/56original exact, exactly6owned correction paths;
old458/446/409 inverses, Core one-export/runner/checker/TOC inverses, cooled history and
primary/unowned/other-scheduler freeze PASS. Prior458 reconstructed by overlaying changed
copies on original and checking its full manifest; intended primary planning/review
amendments attributed, not unowned drift. No proof/diff/manifest files written by that check.
Only Commands/SelfTests+TASKS/README/schema/evidence changed since start. PRIMARY PLAN/
contract/review and old primary TASKS reports retained. Source frozen for primary actual
recomparison and renewed scoped-static review; no independent acceptance asserted.

No private DB read, native test/capture/selftest request, source installation, dependency
install, Git or release. Fullnative INCOMPLETE87/149/all-rank costs UNVERIFIED/native storage
NOT RUN unchanged; platform N/A. Source/tests done; delivery is PARTIAL, writer STOPPED.

**Artifact delivery permission blocker:** patch Add File `/tmp/opencode/s01-piece9-freeze.py`
was denied `external_directory` once. No retry/alternate-tool write bypass. Full current
bundle NOT generated; `/tmp/opencode/craftarmy-s01-piece9-artifacts` holds initial all-pass
check logs only. Reproducer/intermediate logs still at `/tmp/opencode/s01-piece9-before-fix.log`,
`s01-piece9-first-fix.log`, `s01-piece9-matrix.log` and `s01-piece9-matrix-second.log`.
PRIMARY must grant scoped external helper/artifact write permission or generate complete
diffs/source copies/manifests/proof/log bundle from permitted context, then recompare/freeze
and renew scoped-static review. No source/test or design work remains; no COMPLETE claim.

Actual read-only hashes (external artifact bundle still incomplete):
- old458 inverse `2b115ef37e838051f601f2c08914e1f8d84ad26e4134ca644ec5b48bb059f0db`.
- old446 inverse `e3bc97f39ec212d9c14611ee63909c7d2580c8ddd1b33f7d557dac98138af8fe`.
- old409 inverse `86deee99123f3a4df5b6000a5c177cf8237c02922e426777a2afc1863a0e4f79`.
- full production diff `5892a772eb96004281c11530aa228ccfcbc793860de59798e4647e9ce618567a`.
- piece9 Commands diff `cfebde5e4296ae7140a4f67a8090882125f3ab748363e232ee9a3069db715fdc`.
- piece9 test block `6057cf9eb57684e9a4ffb7f99f813293faf6710e237e8ab1eb321c62cbfff619`.
- Commands `43a3dca252696d5f596727133028ddc96804bac82b8331d03fad6b84aba4d707`.
- SelfTests `d907ef6bce9459109072e2474a89e63dd1b870dd2bc3f187ce711bba2ce6b83a`.

After blocker documentation, all four approved commands reran directly to stdout, no
external log writes:463/463+744K6/565K7,23/23,bothPythonPASS29Markdown97links, all exit0.
Exact source hashes unchanged. Handoff PARTIAL only for permission-blocked artifact delivery.

## S01 primary final evidence, review and bounded acceptance — 2026-11-17

Primary did not grant/retry/bypass the denied external-helper write. Extra derivative
bundle remains ungenerated, NOT a completed artifact. Instead primary performed approved
read-only actual comparisons/checks and delivered evidence in owned project review/TASKS
documents. This administrative evidence-delivery disposition supersedes the writer's
artifact-only handoff blocker, not any safety coverage or permission boundary.

Actual primary72baseline->74target paths,18authorized changed/56unchanged/no removals;
since piece9 start only Commands/SelfTests/TASKS/README/schema/evidence changed. Primary
PLAN/contract/review freeze, exact old458/409/Coreoneexport/runner/history proofs PASS.
Full96708-byte production/checker diff independently reproduced5892a772...; entire13235-
byte Commands correction diff cfebde5e... also independently recomputed/read. Existing
actual snapshots/current source remain authoritative; no derivative bundle proof invented.

Fresh PRIMARY executed463/463+unchanged744K6/565K7,diagnostics23/23,bothPython PASS
(17required/29Markdown/97links), all exit0. Full old409 bytes retained,54newS01cases.
Independent accumulated scoped-static review COMPLETE/PASS, original catalogue ownership
and subsequent startup cleanup-status findings RESOLVED; all correction matrices read.
Reviewer executable/hash/fulltree/inverse/freeze remains INCOMPLETE after permission
denials, not primary results relabeled independent. Full review record s01-review.md.

Primary persisted scoped-static PASS BEFORE recomputing all16 frozen source/check hashes,
source delta/path scope/old409 inverse: unchanged/PASS. No source/test edits after review.
Primary accepts bounded implementation; following changes are administrative acceptance
docs only. User-managed whole CraftArmy folder/TOC/11Lua update requires SavedVariables
backup; migration automatic/candidate-validated, failures retain original root. Next one
previously blocked normal own-profession scan plus older snapshot/normal-use retention
check, no reset/capture/identifier/fullselftest chase. Native storage remains NOT RUN;
synthetic46/100/200×2growth and zero-clock batching counts are not native latency proof.
FullnativeINCOMPLETE87/149/allrankUNVERIFIED/U05nativePARTIAL unchanged. No private DB/
agent installation/gameplay/Git/publication/release action; platform N/A.

## User storage confirmation and redraw report — 2026-11-17

User reports scans succeeding on multiple previously blocked characters and correct older
snapshots. Record focused native normal-scan/preservation confirmation, not a measured
roster/migration/reload/timing result or all-path acceptance. No extra capture/private
data/selftest round requested. No source change accompanies this evidence update.

User also reports the table often disappearing/reappearing, particularly when professions
open/close. This is an unresolved redraw/normal-use issue; no data loss or root cause is
established. User asks for TASKS cleanup before further work and approves the manifest.
Preserve current open issues and acceptance gaps in lean TASKS, archive original logs with
mechanical link-only corrections, and retain historical failures/permission limitations.
Source463/463+744K6/565K7/23/Python outcomes remain the previous source revision's checks,
not new Lua execution during docs cleanup. FullnativeINCOMPLETE87/149/allrankUNVERIFIED
and overall dashboard nativePARTIAL remain; storage refresh/retention confirmation is new.

## R01 redraw-only correction — locally accepted, 2026-11-17

User “Yes fix redraw first” authorized retaining completed rows during guarded incremental
replacement. Only Dashboard source and additive SelfTests changed. Original463 case bytes
retained;17 initial +8 correction cases added. Rejection chronology, both independent
findings, primary reproductions, exact source hashes and gate limitations are preserved
in [R01 review](redraw-review.md) and current TASKS report.

Primary final actual commands after renewed scoped-static review:
`lua5.1 tests/dashboard.lua`488/488+unchanged744K6/565K7;
`lua5.1 tests/run.lua`23/23; both Python structural checks PASS. Primary recorded-digest
check confirms all16 source/check inputs at exact reviewed target; removing only new
blocks reconstructs both480-case and original463-case SelfTests hashes. Source unchanged
after full checks. These are PRIMARY proofs, not independently executed comparisons.

Independent read-only scoped-static review PASS after both hover/render-failure findings
resolved. Independent execution/manifest/hash/full-tree comparison unavailable after denied
operations; not retried/bypassed. Earlier failed/invalid fixture attempts remain failures,
with first-round test-first chronology exception explicit. Existing checker cache retained.
No old denied rejection-artifact read or missing external S01 bundle generation.

R01 local acceptance PASS only; no schema/budget/collector/gameplay change. Same-source
retained rows are visibly last-observed and actions/tooltips guarded while pending;
source replacement/lifecycle removal/confirmed empty never resurrect deleted data.
Focused user open/close/normal refresh check remains NOT RUN, not automatic native PASS.
Fullnative INCOMPLETE87/149/allrank UNVERIFIED unchanged. Skill/Concentration bars and
older-expansion red gear queued, not implemented. No agent install/private data/Git/release.

## R01 user visibility confirmation — 2026-11-17

User: “Table no longer disappears during a scan (or opening and closing the profression
windows)”. Focused native scan/open/close visibility accepted; targeted redraw symptom
resolved. Do not infer unreported hover/action recovery, absence of errors/freezes,
measured timing or full dashboard native acceptance. No additional routine redraw test,
Knowledge capture/IDs/fullselftest requested. Source/hashes unchanged; no new Lua execution.
Other native gates/independent-execution limits remain unchanged. Follow-up bars/red gear
remain queued, not implemented by this evidence update.

## U06 Skill-column progress bar — locally accepted,2026-11-17

User approved Skill-only approach. One implementer delivered Dashboard plus20 additive
SelfTests; all488 previous case/helper bytes retained by block-removal exact digest.
Before source correction, focused new suite1 PASS/19 FAIL, including actual bar-count
missing feature proof. Full rejecting/final chronology preserved in TASKS U06 report.

Independent scoped-static review PASS, no blocking findings; no independent execution/
hash/baseline comparison attempted or claimed. Primary then actually executed dashboard
508/508+unchanged744K6/565K7, diagnostic23/23 and both Python checks PASS. Primary local
recorded-digest proof confirms exact reviewed target/original488 bytes and other14 source/
check inputs unchanged. No denied external manifest/artifact read or full-tree claim.
[U06 review](skill-u06-review.md) holds hashes, attribution, limits and bounded acceptance.

Skill bar uses existing saved level/cap, no bonuses/new APIs/schema; unknown neutral/?;
retains row/label/hover/action/sort/freshness/R01 guards. Native appearance and real hit
testing NOT RUN; one focused cached-table visual/normal+Shift hover/selection check next,
not new scan/capture/fullselftest. Other two dashboard refinements unimplemented. No
agent install/private data/Git/release; fullnative INCOMPLETE87/149/allrank UNVERIFIED.

## U06 focused user acceptance and refinement request — 2026-11-17

User reports “Everything looks good” in response to the requested Skill-bar visual/input
check. Accept that focused round at reported scope; do not invent individual clicks/
hovers, timing or error/freeze observations. They request removing the redundant Skill
`!` and suggest filtering non-max Skill instead of combined Knowledge/Skill Progression.
Those follow-up changes are not implemented; exact proposal is in Q05. No source/check
hash changes or new Lua execution with this feedback update. Broader native gates and
fullnative INCOMPLETE87/149/allrank UNVERIFIED remain; no routine U06 retest requested.

## U07 Skill marker/filter refinement — locally accepted,2026-11-17

User approved removing Skill-only `!` and visible Skill below max filter with known
Skill/cap membership independent of Knowledge; other indicators/default ordering remain.
Implementation in ViewModel/Dashboard plus SelfTests. Exact proofs/three target hashes,
four authorized old expectation adaptations, pre-fix rejection and first full INCOMPLETE
are in TASKS and [U07 review](skill-u07-review.md). No failure relabeled PASS.

All508 prior scenarios preserved except those four explicit expectation substitutions.
All19 new workloads grouped into4 cases under existing512-case guard, bodies/order/
checkpoints unchanged. Independent scoped-static PASS; primary then executed full512/512,
asserting512 PASS lines, no INCOMPLETE/FAIL, and all5+10+2+2 workload-completion annotations.
Unchanged744K6/565K7, diagnostics23/23 and both structural checks PASS. Primary exact3
reviewed-digest check plus13other source/check inputs unchanged; grouping reversal and
original508-case reconstruction proven without external denied artifact/manifest access.
These are PRIMARY proofs, not independent execution/full-tree inventory. No cap raise,
runner/workload reduction, schema/new API/collector change, install/Git/release action.
Focused native marker/menu check remains NOT RUN; no rescan/capture/IDs/fullselftest needed.
Concentration/gear-red unimplemented; fullnative INCOMPLETE87/149/allrank UNVERIFIED persist.

## U07 focused user confirmation — 2026-11-17

User “Yes it all looks good” accepts the requested plain Skill text and Skill below max
filter round at reported scope. No individual steps/timing/all-native proof inferred or
repeat check requested. Source/hashes unchanged; no new Lua/native execution by agents.
User next requests icon ZIP import from another ChatGPT chat; archive unavailable here,
pending upload/link/path, no extraction or source integration performed.

## M01 import and U08 title icon locally accepted — 2026-11-17

User supplied9 extracted images in root media, imported byte-for-byte to addon Media/Icons
with manifest README; originals preserved, no conversion. User then requested dashboard
title-bar icon at top left. U08 adds optional22px ARTWORK main64px TGA, title shifted/
shrunk28px with unchanged right edge/wording; protected setup failure retains plain title.
Only Dashboard/SelfTests source changed for U08, three additive blocks inside existing
cases, no case-cap/runner/workload reduction. Independent scoped-static PASS/no findings
persisted in [U08 review](title-icon-u08-review.md), not independent execution proof.

Fresh PRIMARY reviewed-target execution:512/512 top-level PASS, all19 U07 workloads in
5/10/2/2 annotations,744K6/565K7, diagnostic23/23 and both Python checks PASS. Actual
completed cases confirmed, no terminal incomplete result. Exact source hashes and original
Dashboard/SelfTests byte reconstruction PASS;19 protected source/TOC/runner/checker hashes,
9 image pairs/header/manifest equality and asset README preservation PASS. No new native
rendering/input evidence. Full native INCOMPLETE87/149/all-rank UNVERIFIED unchanged.
Update including Media/Icons while WoW closed, preserve SavedVariables, restart, inspect
icon and normal title-bar drag/close. No rescan/full-client selftest/install/Git/release.

## U08 appearance accepted; additional gear polish requested — 2026-11-17

User “It looks good” confirms focused title-icon appearance; no repeat check requested.
Unreported drag/close procedures/timings are not inferred. User adds dashboard backlog:
accessory/tool icons close to full row height, rarity-colored border, quality badge top
left of the item icon, merged **Gear** header across the three equipment slots. Preserve
existing older-expansion red-background requirement; exact geometry/sorting is unsettled.
Concentration bar green when full remains next, older-expansion red backgrounds and new
gear polish queued before guides. Documentation only; no new source/test execution.

## U09 Concentration bar and tooltip-only estimates locally accepted — 2026-11-17

User agreed observed blue/green bar, removed visible Concentration `!`, then approved
tooltip-only predictions with predicted bar deferred. Only Dashboard/ViewModel/SelfTests
source changed:12 reusable bars, observed numeric keys/90% attention/default priority
unchanged, pure saved-rate/field-time estimator and guarded dynamic normal hover. Clear
approximate/no-spending/unchanged-rate/not-live-read caveat; invalid metadata/time and
archived snapshots unavailable; failed attempts retain stale own successful baseline.
No schema/collector/storage/TOC/timer change. Shift diagnostics remain observed.

Implementer reported3 direct unchanged-source rejections, correctedfocused12/12, full512/
all19U07/744K6/565K7/23/Python PASS. Independent scoped-static reviewer returned PASS,
no findings; primary persisted it before proceeding. Fresh PRIMARY exact-reviewed-target
dashboard execution confirms512 completed PASS/0failed, all4 U07 annotations5/10/2/2,
744K6/565K7 and no FAIL/terminal INCOMPLETE; diagnostic23/23/Python PASS. PRIMARY exact
hashes,8block+3expectation full preimage reconstruction and39-input scoped inventory/content
freeze PASS, including all original/copied media/README. No evidence relabeled independent.
[Review and pinned targets](concentration-u09-review.md). Native appearance/input and
recharge phase/rounding/offline accuracy NOT RUN; full native INCOMPLETE87/149/all-rank
UNVERIFIED unchanged. User whole-addon update/observedbar+tooltip check next, no reset,
forced rescan/full-client selftest or repeated accepted UI rounds. No install/Git/release.
Combined gear redesign remains next, red-border replacement still proposed pending design.

## U09 focused user result confirmed — 2026-11-17

User “Everything looks good and as expected” accepts the delivered Concentration bar/no!
and tooltip-only estimates at reported scope. No itemized procedures, measured offline
recharge accuracy or blanket native acceptance inferred. No repeat check requested;
source/hashes unchanged, no new Lua/native execution by agents. Combined gear redesign
planning is next; predicted bar/sort/filter remains deferred, no new writer authorized.

## U10 combined gear redesign locally accepted — 2026-11-17

User approved32px rows/28px icons, no Gear sorting, older-expansion red-border override,
and narrower instead of stretched dashboard. Delivered those changes with single Gear
header, no visible Stat/Enchant columns, large Tool-only intrinsic-stat letter, quality
top left and positive E top right. Full tooltip distinctions retained; absent E may mean
unenchanted or unknown as requested. Optional observed metadata uses protected exact-item
API reads and own timestamps; same-instance transient failure retains known metadata,
changed/empty/unidentified never inherits. No reset/schema bump/new offline reads.

Initial implementation stopped511/1 on obsolete U02 mouse expectation outside allowlist;
primary approved exact removed-column adaptation. Primary also reproduced/corrected IQ/
crafterGUID link rejection. Independent static review found quality/stat layer overlap;
foreground child frame correction directly rejected oldsource then passed. Renewed scoped
static PASS explicitly resolves finding. Fresh PRIMARY reviewed-target512 completedPASS,
all19U07 annotations5/10/2/2,744K6/565K7,diagnostic23/23/Python PASS;5 exact hashes and
41inline-original adaptations+6additions reconstruct entire pre-U10 test base;37unassigned
inventory/content and9media original/copy/header/README preservation PASS. Proof remains
primary-attributed, not independent execution/full-tree/stat/native evidence.
[Review/targets](gear-u10-review.md). Native API attribution/expansion/appearance/input
NOT RUN; fullnative INCOMPLETE87/149/allrankUNVERIFIED unchanged. User update wholeaddon,
preserve SavedVariables, normal cached-display/own-scan spot check next; no forced account
rescan/reset/full-client suite. No Git/install/publication/release performed.

## U11 decorated item labels and compact spacing locally accepted — 2026-11-17

User reports no Khaz Algar red border/Tool letter, quality/E badges work; confirms scan
with updated addon, tooltip expansion unknown/own-stat unavailable. Requests24px icons/
28px rows and tighter equal gaps. No raw link/freshness evidence; not assumed cache-only.
Primary locally reproduced plain label success vs identical payload/quality-atlas label
rejection. U11 parser ignores decorated labels safely, exact crafted payload retained;
same-instance metadata/model/guards unchanged. Layout24/26/28/28 gives4px icon and2px border
gaps bothaxes,84Gear and48px narrower frame. Quality foreground preserved/E unchanged.
Independent scoped-static PASS/no findings then PRIMARY full512completedPASS/all19U07
5/10/2/2/744K6/565K7/23/Python; exact3targets/38orig+6addition full preimage/39frozeninput/
9media preservation PASS. Proof not relabelled independent/native. Known parser defect
corrected locally; actual client cause/fix/new appearance pending targeted user update/
one ordinary affected profession scan. No reset/account rescan/full suite required.
[Review/targets](gear-u11-review.md). FullnativeINCOMPLETE87/149/allrankUNVERIFIED unchanged;
no source correction after review, no Git/install/release/publication.
## U11 focused user result / U12 presentation request — 2026-11-17

Red borders now show; Resourcefulness Tool R displays correctly.24px/28px internal icon
spacing accepted. Multicraft consistently `...` across multiple characters; Gear cramped
between Skill/Concentration bars. Accept only those reported observations; no blanket
API/input/native suite acceptance. U12 removes fixed Tool-letter text dimensions and adds
6px outer Gear gutters while keeping internal gaps/bar widths unchanged; native clipping
cause plausible, not proven. No repeat metadata scan needed; implementation not yet run.

## U12 presentation correction locally accepted — 2026-11-18

Natural-size Tool letter/no fixed text dimensions, single center anchor/same14px OUTLINE,
guarded font-before-text;6px outer Gear gutters while accepted24px/28px/4px internal gaps
and bars/metadata/snapshots unchanged. Independent scoped-static PASS/no findings, then
PRIMARY512completedPASS/all19U07 annotations5/10/2/2/744K6/565K7/23/Python and exact2targets/
25original+3addition full preimage/whole Dashboard reversal/40-input preservation PASS.
Native M fit and padding appearance not established by local mocks; focused user check
after update/reload next, no scan/reset/full suite. Red borders/R/internal-gap acceptance
retained. [Review](gear-u12-review.md). No Git/install/release/publication; historical full
nativeINCOMPLETE87/149/allrankUNVERIFIED unchanged.

## U12 focused native result accepted — 2026-11-18

User: “M is visible and the gaps look great.” Multicraft M visibility and outer Gear
spacing user-confirmed; U12 focused correction complete. No repeat check/update/scan
requested. Red-border/R/internal-spacing acceptance preserved. Exact font-engine cause,
unreported interactions/timings and broader native acceptance not inferred. Documentation
only, no addon edits/new Lua run; fullnativeINCOMPLETE87/149/allrankUNVERIFIED unchanged.
[Review](gear-u12-review.md).

## U13 locally accepted — 2026-11-18

User approves Moxie/no!/green>600, blue observed+cyan estimated gain/~total, scrollbar/
wheel/range without paging buttons, filtered current-GUID professions first/name dot.
Delivered as display/runtime ordering only; observed sorting/attention/filter/saved data
unchanged except intentional current/other partition before within-group comparisons.
Independent scoped-static PASS/no findings then PRIMARY fresh512completedPASS/all19U07
5/10/2/2/744K6/565K7/23/Python/exact3targets/40original+22addition preimage/whole ViewModel
reverse/39 frozen-input preservation PASS. Neither writer nor primary proof relabelled
independent/native. Two old GUID-count conflicts resolved by primary-approved narrow
separate identity/acquisition counters/error spies; previous499/13 and511/1 kept as history.
Native Moxie/segments/dot/thumb/drag/fit/accuracy not yet user-confirmed. Existing snapshots
after user update/restart suffice; no scan/reset/fullclientselftest. Checklist C2/C3 revised,
C7 new. [Review](refinements-u13-review.md). No Git/install/publication; fullnative87/149
INCOMPLETE/allrankUNVERIFIED/quantified estimate accuracy unverified remain unchanged.

## U13 focused feedback and U14 locally accepted correction — 2026-11-18

User confirms current-first/dot, Moxie center/no!/likesgreen>600, visually distinguishable
observed/estimated portions, expected sorting/filtering, visible moving draggable scrollbar
and correct row count. Wants equal historical green brightness; reports drag overhead vs
wheel and misleading thumb gaps at track ends. No unreported procedures/timing inferred.
U14 uniform green value cue, duplicate-offset suppression/frame-coalesced drag and opaque
thumb delivered. Independent scoped-static/PRIMARY full512/all19U07/744K6/565K7/23/Python,
exact2targets/13original+13addition preimage/wholeDashboardreverse/40-input preservation PASS.
Primary direct synthetic100same-offsetrequests dispatch1Render vs100 old; dispatch proof
only, not native FPS/causality/pixel evidence. Native brightness/drag/endpoints pending user
update/restart check; no repeat accepted U13 checks or scan/reset/fullsuite. No other source,
Git/install/publication. [Review](scroll-u14-review.md). FullnativeINCOMPLETE87/149/
allrankUNVERIFIED/quantified accuracy limitations unchanged.

## U14 focused native result accepted — 2026-11-18

User: “Moxie colour looks good, the scrollbars go to the full bounds now, and performance
is good.” Moxie brightness/full thumb travel/normal-use performance accepted at reported
scope. U14 correction complete; no repeat update/retest/scan. No exact causal proof,
measured timing/FPS, unreported procedures or full dashboard sign-off inferred. Remaining
C4/C5/C6 separate. Documentation-only/no addon edits/new Lua run; broader evidence limits
unchanged. [Review](scroll-u14-review.md).

## C4/C6 accepted; U15 tooltip cleanup locally accepted — 2026-11-18

User confirms C4/window and C6/Cancel function as expected; no repeat/destructive action
acceptance inferred. C5 normal gear clutter requested diagnostics-only extras and removal
of routine Observed/Attention/hint/caveat normal. U15 delivered native/third-party-only
normal gear, full Shift detail/assumptions, compact normal statuses/estimated values with
~labels and real unknown/stale/archive safety. No native/user text stripping/math/data/
filter/priority/control changes. Independent scoped-static PASS then PRIMARY512/all19U07/
744K6/565K7/23/Python/exact3targets/27original+7addition full test preimage/whole Dashboard+
ViewModel reverse/39-input preservation PASS. No independent/native proof inferred.
Only focused C5 style/Shift/dismissal check remains, then explicit overall sign-off. No
rescan/reset/fullsuite/guide/install/Git/release. [Review](tooltips-u15-review.md).

## U15/C5 focused native result accepted — 2026-11-18

User: “Tooltips look a lot cleaner now and Shift reveals the diagnostic tooltip as before.”
Normal cleanliness and Shift diagnostic availability accepted at reported scope; U15/C5
cleanup closed. No repeat update/retest/scan. Dismissal/scroll procedure, every field/item
edge and broad native proof not inferred. C4/C6 stay accepted. Ready for explicit overall
sign-off decision with limits retained; no guide/release authorization inferred. Evidence
update only/no addon edits/new Lua run. [Review](tooltips-u15-review.md).

## Dashboard milestone user sign-off — 2026-11-18

User explicitly happy to sign off dashboard; requests GitHub Arbixal/craftarmy before the
next section. Current scope accepted, no routine retest. Historical INCOMPLETE/UNVERIFIED/
quantified-accuracy limits and unreported procedures unchanged. Repository preflight
read-only: CLI identity Arbixal, no target/local repo found; visibility/initial commit-push
scope pending. No Git/GitHub mutation, addon edits/new Lua run or guide work.

## GitHub bootstrap authorization and repository creation — 2026-11-18

User explicitly chooses PUBLIC Arbixal/craftarmy and initialize/initial commit/push of
current code/tests/assets/project docs, no tags/releases/deployment. Public repository
created at https://github.com/Arbixal/craftarmy; local main/origin and repo-local noreply
identity configured. Root README/ignore added. Sensitive-path/token/private-key/assignment
heuristic check found no candidates; no symlinks. Not a guarantee or source validation.
Ignore8excluded/6retained paths PASS; caches/local files preserved rather than deleted.
Initial Git snapshot/push authorized; Git log/status/remote branch SHA record actual
delivery. No addon implementation, guide work or blanket future Git approval.
