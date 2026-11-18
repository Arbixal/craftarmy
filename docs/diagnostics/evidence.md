# T01 evidence and recovery point

Date: 2026-11-05. Delivery: **PARTIAL overall**. R1 fixture/capture correction:
**PASS for the supplied user results (23/23; complete Inscription path capture)**.
Overall client/API feasibility remains **INCOMPLETE** for other fields/scenarios.
Initial independent static review found no concrete blocking issue; the subsequent
user-run scan exposed capture limitations documented below. User reports 18/18 fixture
passes. No agent performed game installation, client actions, Git operations, or release.

## Delivered files / scope

Exactly the nine-file T01 manifest plus TASKS.md execution-state edits:

- `CraftArmy_Diagnostics/{Core.lua,Probes.lua,SelfTests.lua,Commands.lua,CraftArmy_Diagnostics.toc}`
- `tests/run.lua`, `tools/check_diagnostics.py`
- `docs/diagnostics/{README.md,evidence.md}`

There was no baseline code/test suite, Git repository, revision or comparison base.
Existing planning/user files were not rewritten; PLAN/AGENTS/question files remain
primary-owned. All probes are manual and read-only. Writes are limited to this
addon's bounded schema-1 SavedVariables and its own report UI. No Auctionator
methods are called, including candidate read methods. No async item requests,
periodic scans, filters, spending, equipment changes, bank actions, uploads,
other-alt stock inspection, dependency installation or runtime download exists.

## Local validation

| Command/check | Result | Meaning |
| --- | --- | --- |
| `python3 tools/check_diagnostics.py` | **PASS**, exit 0 | Script inspected; 9 required files, exact TOC order/paths/metadata, one SavedVariables name; not Lua parsing |
| Inline Python AST / negative structural / docs check (exact command below) | **PASS**, exit 0 | Seven negative scenarios each exit 1; 3 local links; 18 definitions, not fixture execution |
| PATH-only runtime discovery (exact command below) | All seven tools **NOT FOUND** | No installation attempted |
| `lua5.1 tests/run.lua` | **NOT RUN** | No approved Lua interpreter in PATH; shared fixtures written, not passed |
| `/cad selftest` | **USER-REPORTED PASS, 18/18** | Diagnostic 0.1.0, first client report below; does not cover the newly exposed capture-volume case |
| Lua compiler/linter and client loading | **NOT RUN** | No lua/luac/luajit/luacheck/stylua; no install approval |
| All live checklist scenarios in README | **NOT RUN** | Implementer must not perform live WoW testing |

The fixture runner currently defines 18 cases covering zero/nil, optional missing/
error APIs, last-success preservation, sample limits/reload/character separation,
bounds, deterministic escaping/type/cycle filtering, export whitelist, empty/loading
slots, rarity vs crafted rank including rank 5/unknown rank, multiple stats and
unknown enchant attribution, unsafe contexts, committed/staged and purchased/free
knowledge, nullable currency capacity, exact bank/Warband flags, Auctionator
absent/candidate-read-capable/unsupported with zero method invocations, and an
unverified currency candidate, and explicit injected-state/action isolation. All collector fixture environments are injected
local tables, never `_G`; tests do not load Commands or touch real saved data.
Mock behavior is not target-client API evidence, even when execution later passes.

### Exact additional local checks and results

Executed from the repository root after inspecting the checker. No generated
files or bytecode caches were written; negative cases replace reads in memory only.

```sh
python3 - <<'PY'
import ast
import contextlib
import io
from pathlib import Path
import re
import runpy
from unittest.mock import patch

root = Path.cwd()
script = root / 'tools/check_diagnostics.py'
ast.parse(script.read_text(encoding='utf-8'), filename=str(script))
toc = root / 'CraftArmy_Diagnostics/CraftArmy_Diagnostics.toc'
original_read = Path.read_text
original_is_file = Path.is_file
text = toc.read_text(encoding='utf-8')
cases = {
    'missing entry': text.replace('Core.lua\n', ''),
    'duplicate entry': text + 'Core.lua\n',
    'out-of-order': text.replace('Core.lua\nProbes.lua', 'Probes.lua\nCore.lua'),
    'placeholder': text.replace('0.1.0-diagnostic', '@project-version@'),
    'SavedVariables mismatch': text.replace('CraftArmyDiagnosticsDB', 'WrongDB'),
    'escaping entry': text + '../PLAN.md\n',
    'missing required file': text,
}
for name, changed in cases.items():
    def read(path, *args, **kwargs):
        return changed if path == toc else original_read(path, *args, **kwargs)
    def is_file(path):
        if name == 'missing required file' and path == root / 'tests/run.lua':
            return False
        return original_is_file(path)
    output = io.StringIO()
    with patch.object(Path, 'read_text', read), patch.object(Path, 'is_file', is_file), contextlib.redirect_stderr(output), contextlib.redirect_stdout(output):
        try:
            runpy.run_path(str(script), run_name='__main__')
        except SystemExit as result:
            assert result.code == 1, (name, result.code)
        else:
            raise AssertionError(name + ' did not exit nonzero')
    assert 'FAIL:' in output.getvalue(), name
print('PASS: Python AST and 7 in-memory negative structural scenarios (exit 1); no file writes')
links = 0
for relative in ['docs/diagnostics/README.md', 'docs/diagnostics/evidence.md']:
    path = root / relative
    for target in re.findall(r'\]\(([^)]+)\)', path.read_text(encoding='utf-8')):
        if '://' not in target and not target.startswith('#'):
            assert (path.parent / target.split('#')[0]).exists(), (relative, target)
            links += 1
fixtures = (root / 'CraftArmy_Diagnostics/SelfTests.lua').read_text(encoding='utf-8')
assert len(re.findall(r'^    test\(', fixtures, re.M)) == 18
print(f'PASS: {links} diagnostic local document links; 18 fixture definitions (execution NOT RUN)')
PY
```

Output: `PASS: Python AST and 7 in-memory negative structural scenarios (exit 1);
no file writes` and `PASS: 3 diagnostic local document links; 18 fixture definitions
(execution NOT RUN)`. Exit 0. Structural command output: `PASS: 9 required files;
exact TOC order/paths/metadata; one SavedVariables name` followed by `Structural
only: Lua syntax, fixtures and installed-client APIs NOT validated` (exit 0).

```sh
printf '\nRuntime discovery (PATH only):\n'
for tool in lua lua5.1 lua5.4 luajit luac luacheck stylua; do if command -v "$tool"; then :; else printf '%s: NOT FOUND\n' "$tool"; fi; done
```

Output: lua, lua5.1, lua5.4, luajit, luac, luacheck and stylua each `NOT FOUND`.
No fixture command was attempted; no dependency manager or runtime download used.

### Frozen content identity (no Git revision exists)

Command executed, exit 0:

```sh
sha256sum CraftArmy_Diagnostics/CraftArmy_Diagnostics.toc CraftArmy_Diagnostics/Core.lua CraftArmy_Diagnostics/Probes.lua CraftArmy_Diagnostics/SelfTests.lua CraftArmy_Diagnostics/Commands.lua tests/run.lua tools/check_diagnostics.py docs/diagnostics/README.md
```

```text
1545b0ed3973b70947b708841f2144eb66647da0fcfcae6083a615393d7d515e  CraftArmy_Diagnostics/CraftArmy_Diagnostics.toc
74c3649355a674a8040279569a038a7ab1fa66fcdf635dfc5156cb4a502e05f7  CraftArmy_Diagnostics/Core.lua
8889b9540390ce40e18ee84c95f8d0d3f462b6807e4cf5dbf72bf61f38878403  CraftArmy_Diagnostics/Probes.lua
ea43bc020d5eb955b35e1b21fff69e0a7bb94164b265c80765fa827b8dfdce7d  CraftArmy_Diagnostics/SelfTests.lua
52fbeca954fdf992ef0923999190dcc7b602ba6488bd8a256bd4bcfdddb4ebc3  CraftArmy_Diagnostics/Commands.lua
8d3210e44846b0fb0e45aa7e78526abbed74d6dc3207bcbb348746f448fd26bc  tests/run.lua
66253a0403fe29078f1b41f99ba295cbcf3c3f3e54f7a060d76b6c3df02ef6f3  tools/check_diagnostics.py
4b09875d63b650d7cdd4b563fd82a35e2080a647dc1c35996c286a1e1cd20f54  docs/diagnostics/README.md
```

This evidence file and TASKS.md hold delivery state and are deliberately excluded
from the self-referential hash list. No implementation/guide edits after hashing.

## Public source corroboration (read-only; retrieved 2026-11-05)

Retail sources are pinned to Gethe revision
[`297d7aaaa736f346b3e036f38ee088eaf7f8c07f`](https://github.com/Gethe/wow-ui-source/commit/297d7aaaa736f346b3e036f38ee088eaf7f8c07f),
identified in Q03 as 12.1.5 (70783). That is not the user's installed build.
The generated/source files were read via public raw-source HTTP retrievals
(webfetch and Python stdlib `urllib.request` snippets); no source/runtime was
installed or vendored. Abbreviations below all refer to this exact revision:

- **T** — [TradeSkillUIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/TradeSkillUIDocumentation.lua)
- **TT** — [TradeSkillUITypesDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/TradeSkillUITypesDocumentation.lua)
- **I** — [ItemDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua)
- **L** — [ItemLocation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_ObjectAPI/Mainline/ItemLocation.lua)
- **P** — [ProfessionSpecUIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/ProfessionSpecUIDocumentation.lua)
- **PC** — [ProfessionSpecConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/ProfessionSpecConstantsDocumentation.lua)
- **R** — [SharedTraitsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/SharedTraitsDocumentation.lua)
- **C** — [CurrencyInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/CurrencyInfoDocumentation.lua)
- **Tip** — [TooltipInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoDocumentation.lua) and [TooltipInfoSharedDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoSharedDocumentation.lua)
- **F** — [Blizzard_ProfessionsFrame.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_Professions/Blizzard_ProfessionsFrame.lua), including no-argument linked/guild/changing guards. No guessed `IsTradeSkillReady` is used.
- **A** — [AddOnsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/AddOnsDocumentation.lua)
- **B/U/Loc/Time** — [BuildDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/BuildDocumentation.lua), [UnitDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua), [LocaleDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/LocaleDocumentation.lua), [SystemTimeDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_APIDocumentationGenerated/SystemTimeDocumentation.lua)
- **Realm** — [GetRealmName documentation](https://warcraft.wiki.gg/wiki/API:GetRealmName?oldid=6886085), no arguments, string return. Metadata signatures also corroborated using wiki pages for GetBuildInfo/GetLocale/UnitGUID/GetServerTime.
- **Q04** — [planning research](../questions/Q04.md): candidate `Auctionator.API.v1.GetShoppingListItems(callerID,listName)` from secondary consumers only. [Upstream API wiki](https://github.com/Auctionator/Auctionator/wiki/API-Documentation) again returned **404**. No current installed/read API contract is established; do not trial-call it.

### Interface packaging gate: source corroborated, client loading NOT RUN

TOC `120105` is explicit in both:

1. [BigWigs.toc at d8a51d2fb631d457276fa22677c5c1d0bce56d68](https://github.com/BigWigsMods/BigWigs/blob/d8a51d2fb631d457276fa22677c5c1d0bce56d68/BigWigs.toc), current upstream retrieved by GitHub API; its supported Interface list includes `120105` (also other client/PTR numbers).
2. [Warcraft Wiki 12.1.5 API changes, oldid 6919763](https://warcraft.wiki.gg/wiki/Patch_12.1.5/API_changes?oldid=6919763), Resources explicitly says **TOC: 120105**. The [GetBuildInfo page](https://warcraft.wiki.gg/wiki/API:GetBuildInfo?oldid=6877254) also lists Standard 12.1.5 with Interface 120105 and distinguishes PTR 120107.

This is not a number inferred from the patch name. Packaging-source gate is
resolved; installed-client Interface/load compatibility is still NOT RUN.
Failed exploratory paths (not relied upon): WeakAuras mainline TOC and BigWigs
`BigWigs_Mainline.toc`, several guessed generated filenames returned 404; Python
direct wiki API-page requests returned 403, while webfetch retrieved cited pages.

## Baseline field/API feasibility matrix (before first client report)

“Harness behavior” describes the original implementation. Its NOT RUN column is
the pre-client baseline; the appended first-client section below records current
evidence and supersedes that baseline only for specifically observed fields.
No independent UI comparison or completion of unobserved scenarios is implied.

| Field/API | Source | Harness behavior/status policy | Live status/sample | Limitation / production follow-up |
| --- | --- | --- | --- | --- |
| Version/build/date/Interface: GetBuildInfo() | B | First four returns separately named | **NOT RUN — none** | Compare actual installation; source pin is not installed build |
| Locale: GetLocale() | Loc | Observed or unavailable | **NOT RUN — none** | Validate localization |
| GUID: UnitGUID("player") | U | Current player only; save refused without GUID | **NOT RUN — none** | Verify stable character separation/relog |
| Name: UnitName("player") | U | First return only | **NOT RUN — none** | Private identifying field; never inspect targets |
| Realm: GetRealmName() | Realm | String evidence | **NOT RUN — none** | Redact identifiers before sharing |
| Time: GetServerTime() | Time | Sample/field time; unavailable sample time has timeKnown=false and 0 sentinel; API status records failure | **NOT RUN — none** | No zero-time observation claim if time API unavailable |
| Addon versions: GetAddOnMetadata(name,"Version") | A | Only diagnostic/Auctionator/professions/templates names | **NOT RUN — none** | Missing metadata not proof addon absent |
| Addon load state: IsAddOnLoaded(name) | A | Both loadedOrLoading and loaded flags | **NOT RUN — none** | No force-loading; compare disabled/enabled sessions |
| API presence | T/I/P/R/C/A/B/U | Fixed allowlisted callable flags | **NOT RUN — none** | Presence is not compatibility |
| IsTradeSkillLinked()/IsTradeSkillGuild() | F | Require explicit false; otherwise unknown context | **NOT RUN — none** | Verify inspected/linked behavior; no player assignment when unsafe |
| IsNPCCrafting()/IsDataSourceChanging() | T/F | Require explicit false | **NOT RUN — none** | Unavailable guards fail closed |
| ProfessionsFrame:IsShown() | F / widget read | Require visible normal frame, not inspect frame | **NOT RUN — none** | Extra readiness gate only; not sole ownership evidence |
| GetChildProfessionInfo() | T/TT | Current expansion identity/skill/cap/modifier/sourceCounter whitelist; positive ID | **NOT RUN — none** | Verify ID is active expansion skill line |
| GetBaseProfessionInfo() | T/TT | Base identity/skill/cap/modifier whitelist; positive ID | **NOT RUN — none** | Verify base/current distinction and modifier meaning |
| GetProfessionSlots(profession enum) | T | Bounded returned numeric indices; never skillLineID as enum | **NOT RUN — none** | Role/order remains unknown; establish tool/accessory evidence later |
| ItemLocation:CreateFromEquipmentSlot(slot) | L | Method called with receiver, used ephemerally only | **NOT RUN — none** | Never serialize item location object |
| DoesItemExist(location) | I | Explicit false -> empty; nil/error -> unknown/error | **NOT RUN — none** | Validate empty/readiness behavior |
| GetItemLink(location) | I | Equipped instance link, not base ID | **NOT RUN — none** | Nil/loading not empty |
| IsItemDataCached(location) | I | Explicit cache flag; no load request or event retry | **NOT RUN — none** | User manually rescans after data loads |
| GetItemQuality(location) | I | Rarity separate from crafted quality | **NOT RUN — none** | Verify actual gear examples |
| GetItemCraftedQualityByItemInfo(instanceLink) | T | Rank or unknown, never inferred from rarity | **NOT RUN — none** | Verify applicable 1–5 ranks/exceptions |
| GetItemCraftedQualityInfo(instanceLink) | T/TT | quality/icon/iconSmall/iconInventory/iconChat whitelist | **NOT RUN — none** | Verify atlas availability on installed client |
| GetItemStats(instanceLink) | I | Bounded numeric ITEM_MOD_* key/value map | **NOT RUN — none** | Enchant/base contribution and stat identity unverified |
| GetInventoryItem("player",slot) / permanent enchant enum | Tip | Only matching permanent lines' type/leftText/rightText; zero lines not absence proof | **NOT RUN — none** | No verified enchant ID/stat attribution; no numeric enum fallback |
| GetConcentrationCurrencyID(skillLineID) | T | Candidate mapping only from positive current ID | **NOT RUN — none** | Confirm profession mapping/readiness |
| GetCurrencyInfo(id): concentration quantity/cap/recharge | C | quantity/maxQuantity/rechargingCycleDurationMS/rechargingAmountPerCycle and name | **NOT RUN — none** | Milliseconds retained; no phase/rounding/offline projection |
| Moxie profession mapping | Q03 unresolved | **unknown**; no hardcoded currency ID | **NOT RUN — none** | Primary needs evidenced profession-specific mapping |
| User-supplied currency GetCurrencyInfo(id) | C | Explicit unverified candidate, not Moxie mapping | **NOT RUN — none** | UI/name/balance evidence required to promote mapping |
| GetConfigIDForSkillLine(skillLineID) | P | Positive config ID gates dependent trait calls | **NOT RUN — none** | Verify player/expansion configuration |
| GetCurrencyInfoForSkillLine(skillLineID) | P/PC | numAvailable/currencyName | **NOT RUN — none** | Unspent evidence, no invented earned total |
| GetSpecTabIDsForSkillLine(skillLineID) | P | Bounded numeric IDs | **NOT RUN — none** | Confirm completeness/truncation |
| GetTabInfo(tabTreeID) | P/PC | rootNodeID/name/rootIconID | **NOT RUN — none** | No speculative aggregation |
| GetRootPathForTab(tabTreeID) | P | Nullable root ID | **NOT RUN — none** | No root is not empty tree proof |
| GetChildrenForPath(pathID) | P | Seen-set traversal bounded to 64 paths/tab | **NOT RUN — none** | Check path coverage, avoid cyclic/excess traversal |
| ConfigHasStagedChanges(configID) | R | Nodes marked committed only on explicit false | **NOT RUN — none** | Unknown/true keeps raw ranks uncommitted |
| GetTreeCurrencyInfo(configID,tabTreeID,true) | R | Excludes staged; traitCurrencyID/quantity/spent/nullable maxQuantity | **NOT RUN — none** | Currency spent/cap not automatically a tree-wide purchased-point bar |
| GetTreeNodes(tabTreeID) | R | Up to 64 numeric nodes/tab | **NOT RUN — none** | Check tab/tree correspondence and coverage |
| GetNodeInfo(configID,nodeID) | R | ID/ranksPurchased/ranksIncreased/currentRank/activeRank/maxRanks/totalMaxRanks | **NOT RUN — none** | Free/perk/current ranks never become purchased total; capacity unknown |
| GetItemCount(id,false,false,false,false) | I | Bag-only API count; flags saved | **NOT RUN — none** | Compare equipped/usable semantics to UI; no stock arithmetic |
| GetItemCount(id,true,false,true,false) | I | Personal+reagent-bank-inclusive API count | **NOT RUN — none** | Cached output does not prove current bank usability |
| GetItemCount(id,true,false,true,true) | I | Only explicit `warband` enables this third call | **NOT RUN — none** | Warband freshness unknown; no other-alt queries |
| BankFrame:IsShown() | Widget read | Visibility only; missing frame unsupported | **NOT RUN — none** | User records bank type; visibility doesn't establish fresh account-bank counts |
| Auctionator API.v1 namespace and candidate read-method presence | Q04 | Read-only type checks, no calls | **NOT RUN — none** | Installed public API/version needed |
| Existing CraftArmy list GetShoppingListItems | Q04 | **unsupported** when addon present; not_applicable when absent | **NOT RUN — none** | Current authoritative read signature unavailable; do not infer empty list |
| Auctionator mutations/search/purchase | T01 safety contract | **Excluded; no invocation** | **NOT RUN — prohibited** | Separate approval-gated integration task required |
| Persistence/report UI/reload/multi-alt | T01 | Bounded schema-1 storage; current-character manual export | **NOT RUN — none** | Client verifies survival, identity and selectable report |
| Offline concentration change | C / Q03 | Observations only; predicted value not implemented | **NOT RUN — none** | Human before/after relog observations required |

## First user-run client report — 2026-11-05

Source: user-pasted console result and complete, internally truncated JSON report.
Sample label `inscription-open`, time 1793851527, schema 1, `truncated=true`, console
field count 259. Character name/realm/GUIDs, config ID, and full item/crafter links
are deliberately omitted from this durable summary; no raw identifying report file
was created. IDs below identify game content, not characters.

| Observation | User-reported evidence | What this establishes / does not establish |
| --- | --- | --- |
| Shared fixtures | `18/18 pure fixture cases passed; no live API evidence` | Existing fixtures execute in the user's WoW runtime; not an exhaustive integration test. |
| Client | 12.1.5, build 70783, Interface 120105, enUS | Actual reported build matches packaging/source target for this run. |
| Addons | Diagnostics 0.1.0-diagnostic and Auctionator 341 loaded | No disabled-Auctionator case or version portability tested. |
| Open-profession guards | Frame visible; linked/guild/NPC/changing flags all false | Open-player path worked; closed/linked/unsafe handling still not exercised live. |
| Current profession | Midnight Inscription, skill-line 2913, parent 773, enum 13; skill 100, cap 100, modifier 40 | Base skill and bonus can be kept separate. Parent API separately returned skill 100/cap 75 with expansion Unknown; do not use that parent cap as Midnight cap. |
| Concentration | Currency 3165; 415/1000; amount/cycle 1; duration 345600 ms | Amount/cap/recharge fields available. One observation does not verify offline rounding/phase or regeneration. |
| Equipment slots | 20, 21, 22; all exist and cached | Numeric slot evidence for this profession/session, not a universal slot-role mapping. |
| Slot 20 | Sin'dorei Quill, item 245776, rarity 3 (rare), crafted rank 5; `ITEM_MOD_MULTICRAFT_SHORT=110` | Link/content identify this equipped item as the tool; do not hardcode slot order across all professions. |
| Slot 21 | Improved Right-Handed Magnifying Glass, item 240958, rare/rank 5; crafting speed 53 and resourcefulness 35 | Accessory rank/rarity/stat outputs observed. |
| Slot 22 | Sin'dorei Scribe's Spectacles, item 240957, rare/rank 5; ingenuity 53 and multicraft 35 | Accessory rank/rarity/stat outputs observed. |
| Quality atlases | Tier5 icon, small, inventory, and chat atlas names returned | Rank icon metadata available; no mixed rarity/rank or unloaded/empty case tested. |
| Enchantment | No matching permanent-enchant lines; `absenceVerified=false` | Inconclusive: do not label confirmed unenchanted or infer a stat mapping. |
| Knowledge identity | 1122 Blueprints; 1124 Calm Hands; 1182 Perfected Products; 1125 Darkmoon Curiosity | Four top-level trees identified. |
| Unspent/staged | Midnight Inscription Knowledge available 0; staged changes false | Observed unspent/current-state evidence, not a tested staged-edit case. |
| Trait currency | Currency 3902 has spent 260 and quantity 0 repeated in multiple tabs | Appears shared; never sum repeated 260 across trees or claim it is each tree's allocation. |
| Purchased/free distinction | Several nodes currentRank=1 but ranksPurchased=0; other nodes purchased 21/11 | Distinct raw fields work. Currency costs/unlock ranks still prevent assuming raw ranks equal KP or capacity. |
| Auctionator | API.v1 and two candidate read methods present; readback unsupported | Presence only. No methods invoked or list behavior verified. |
| Moxie/inventory/persistence | Mapping unknown; inventory probes and relog comparison not supplied | Still pending, not zero or passed. |

### Capture findings requiring correction

1. `Core.lua` sets a 65,536-byte sample budget and 512-field cap. The 259-field
   truncated sample is consistent with byte-budget exhaustion, not field-count
   exhaustion. The closing JSON and explicit flag show capture omission, not merely
   a malformed clipboard paste.
2. `Probes.lua` records up to 128 node IDs but requests details only for the first
   64. Blueprints' list has 72 IDs; root path 106192 and other path nodes occur beyond
   that cutoff. The report contains mostly perk nodes and omits several invested-path
   candidates. Perfected Products' root 109660 is likewise later than the prefix.
3. Global budget consumption also starves later tabs. Darkmoon Curiosity has a tab-info
   field but no captured currency/root/node detail in this report. Missing fields
   cannot support allocation totals, progress bars, or zero-investment conclusions.
4. Keep the original limits and observation honesty; proposed next repair is compact,
   path-first capture plus all-tab summary priority and explicit omissions. Add a
   regression for 72-node trees/late roots and budget exhaustion before retesting.
   This repair is proposed, not implemented or runtime-validated.

The initial fixture-execution and basic load/scan/export gates now have user-reported
evidence. Full knowledge capture, user UI comparisons, bank flags, persistence,
regeneration, other alts/professions, enchants/Moxie, and integration behavior remain
INCOMPLETE. Source hashes above still identify unchanged diagnostic 0.1.0 files.

## Review history and current next action

### 2026-11-05 — independent static review and primary execution

Verifier `ses_e5628cd74ffe4pIThxKd61a52F` read all nine files and compared relevant
APIs with the pinned Retail sources, including independent source corroboration
of Interface 120105. No concrete blocking implementation defect was established.
The verifier's shell tool denied execution: its structural command, hashes, and
additional executable checks are **NOT RUN**, not independently executed passes.

The primary then inspected and executed:

- `python3 tools/check_diagnostics.py` — **PASS**, exit 0, expected two-line structural
  output. This is primary validation, not Lua parsing/runtime validation.
- The exact eight-path `sha256sum` command in the frozen-content section — **PASS**,
  exit 0; all eight hashes match the recorded delivery identity. No hashed source,
  fixture, checker, manifest, or README changed during review. Only primary-owned
  evidence/planning/status records are being updated afterward.

At the time of static review, all runtime checks were NOT RUN. The appended client
report now supplies 18/18 fixture execution and initial load/scan/export evidence,
but exposes knowledge-capture limitations. Initial static review is not approval of
the newly observed coverage issues. Current capture acceptance is CHANGES REQUIRED;
overall feasibility stays INCOMPLETE. No release approval.

- **Primary/verifier:** static inspection is complete and primary structural/hash
  checks passed as above. No Git revision exists; use the frozen content identities.
  Any implementation changes invalidate affected evidence and require re-review.
- **Primary:** propose the bounded path-first capture repair before requesting a
  repeat large export. Do not discard the first sample or mark missing nodes as zero.
- **Primary/user:** after an approved/reviewed repair, repeat fixtures and the open
  Inscription scan. Remaining README scenarios are still pending. Local standalone
  Lua tests are NOT RUN even though the user executed fixtures successfully in WoW.
- **Primary:** persist client samples, installed versions, API/role/currency/rank/
  readiness findings and open questions in Q03/Q04. Source-only evidence does not
  close them. Auctionator public readback and Moxie mapping remain explicit gaps;
  staged/free knowledge and spendable denominators need actual UI comparison.
- Packaging and existing in-client fixtures have evidence; live capture completeness
  needs correction. Broader client feasibility remains incomplete. No production
  feature or mutating integration work is implicitly authorized.

## R1 delivery — 2026-11-05 — 0.1.1-diagnostic

**Delivery PARTIAL; fresh runtime/client acceptance INCOMPLETE; independent R1
review NOT RUN.** Earlier sections and their hashes/results describe diagnostic
0.1.0 and are preserved as history, not evidence that R1 passes. The original
capture acceptance finding remains CHANGES REQUIRED until the primary reviews and
records a successful fresh retest. No raw user identifiers or JSON were persisted.

### Comparison, changes and safety

- Before edits, `python3 tools/check_diagnostics.py` passed and all eight original
  content hashes matched the first hash block above. This recorded content state is
  the comparison base; there is no Git repository/revision or saved source diff.
- Changed: `CraftArmy_Diagnostics/Core.lua`, `Probes.lua`, `SelfTests.lua`,
  `CraftArmy_Diagnostics.toc`, `docs/diagnostics/README.md`, this evidence file and
  TASKS.md execution/status/delivery fields. No other files created or edited.
  Commands.lua, tests/run.lua and tools/check_diagnostics.py remain byte-identical.
- Knowledge metadata for every bounded tab precedes detail: identity, committed
  currency observations, root and raw node-list count/inspection flags. Discovered
  paths, including roots beyond raw index 64, select `.node.<id>` detail. Bounded
  breadth-first traversal is round-robin across tabs. Non-path perk-node detail is
  deliberately omitted; `.nodeList` count metadata replaces the full `.nodes` list.
- One `knowledge.coverage` field identifies `paths_only` policy, raw/unknown counts,
  captured vs discovered bounded paths, known/unknown non-path omissions, per-tab
  API failures, budget drops, list/traversal/tab limits, repeated references and
  conservative completeness flags. Unknown counts remain strings `unknown`, not 0.
  Its observed status establishes bookkeeping only, not verified tree totals.
- Ordinary knowledge writes reserve 4096 bytes/one field for final coverage. Core's
  optional section ceilings only tighten limits; all writes still obey 65536 bytes /
  512 fields. Final accounting is also constrained to the reserved byte allowance.
  If full accounting cannot fit, a compact error fallback is attempted and exported
  `knowledgeCoverageFailed=true` plus `truncated=true` make the failure explicit even
  when no field fits. Normal non-knowledge limits and sanitization are unchanged.
- DB schema 1, Interface 120105, 20 samples per character and 20 characters are
  unchanged; no migration, history rewrite or data reset. Existing retention on a
  21st manual save still applies. Version alone changes to `0.1.1-diagnostic`.
- No derived KP totals/capacities, free-rank promotion, staged-rank commitment or
  summing repeated shared currencies. Existing APIs and source references P/PC/R
  above are reused; no new gameplay API/signature or Auctionator invocation added.
  No dependency/alternate runtime, install, game execution, game mutation, uploads,
  child agents, Git operation or release performed. Primary-owned docs untouched.

### R1 fixtures and remaining gates

The **same** runner now defines 23 cases: original 18 plus five synthetic R1 cases.
The existing nullable/staged fixture now identifies its node as a path and retains
its excluded-staged, zero, nullable-capacity and uncommitted-rank assertions.

| New regression / gate | Written assertion or procedure | Execution/result |
| --- | --- | --- |
| Late root/path in 72 raw nodes | Captures last two invested paths; no first-prefix perk queries; 70 intentional non-path omissions; raw/current/purchased distinction retained | **NOT RUN — new Lua fixtures** |
| Four tabs / last tree | All metadata exists before node calls; root of tab 4 is the fourth node request; later paths survive; prior sample unchanged; no other-addon actions/shared-currency total | **NOT RUN — new Lua fixtures** |
| Byte/field reserve and extreme exhaustion | Coverage/omissions exported after byte loss; total bounds hold; slot 512 stores reserved coverage after 511 prior fields; no global-limit relaxation; a prefilled 512-field sample explicitly flags missing accounting | **NOT RUN — new Lua fixtures** |
| Cycles and failed root/children/node calls | No completeness or empty-tree inference; failed node writes are error records, unknown counts preserved, no action calls | **NOT RUN — new Lua fixtures** |
| Child/path/raw-list/tab limits and unknown list | Explicit flags/counts, max 64 discovered paths, max 8 tabs, unknown omission counts, no full-capture claim on limits/failure | **NOT RUN — new Lua fixtures** |
| `lua5.1 tests/run.lua` and `/cad selftest` | Fresh 23-case result required; original 18/18 is not carried forward | **NOT RUN — no approved local runtime; no client execution** |
| Fresh load/open-Inscription capture | User manually opens profession, runs `/cad scan inscription-open-r1`, `/cad export`; compare version, all four tab/path scopes and coverage with UI | **NOT RUN — primary/user next after review** |
| Independent R1 verification | Review exact content hashes below and rerun structural checks | **NOT RUN — primary coordinates** |

Synthetic fixtures use local fake tables/IDs only. Fixture definitions, Python
arithmetic and static checks are not Lua execution or installed-client API proof.
Broader live scenarios, Moxie, enchant attribution, spendable knowledge capacity,
bank/Warband freshness, persistence and regeneration remain pending as before.

### Exact R1 local validation commands/results

Inspected the unchanged stdlib-only checker before execution. It performs local
read-only packaging inspection, not addon imports, network calls or writes.

`python3 tools/check_diagnostics.py` — **PASS**, exit 0 before and after correction:

```text
PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name
Structural only: Lua syntax, fixtures and installed-client APIs NOT validated
```

Initial comparison command (exit 0, eight original hashes matched before edits):

```sh
python3 - <<'PY'
from pathlib import Path
import hashlib,re
text=Path('docs/diagnostics/evidence.md').read_text()
rows=re.findall(r'^([0-9a-f]{64})  (.+)$',text,re.M)
assert len(rows)==8
for expected,name in rows:
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==expected,name
print('PASS: all 8 original content hashes match before R1 edits')
PY
```

Additional read-only command (exit 0; negative cases replace reads in memory, no
temporary files/bytecode caches). Historical initial-hash command above is only
valid for the pre-R1 state; the following command remains reproducible for R1:

```sh
python3 - <<'PY'
import ast, contextlib, hashlib, io, json, re, runpy
from pathlib import Path
from unittest.mock import patch
root = Path.cwd()
script = root / 'tools/check_diagnostics.py'
ast.parse(script.read_text(), filename=str(script))
toc = root / 'CraftArmy_Diagnostics/CraftArmy_Diagnostics.toc'
text = toc.read_text()
original_read, original_is_file = Path.read_text, Path.is_file
cases = {
    'missing entry': text.replace('Core.lua\n', ''),
    'duplicate entry': text + 'Core.lua\n',
    'out-of-order': text.replace('Core.lua\nProbes.lua', 'Probes.lua\nCore.lua'),
    'placeholder': re.sub(r'(?m)^## Version: .+$', '## Version: @project-version@', text),
    'SavedVariables mismatch': text.replace('CraftArmyDiagnosticsDB', 'WrongDB'),
    'escaping entry': text + '../PLAN.md\n',
    'missing required file': text,
}
for name, changed in cases.items():
    def read(path, *args, **kwargs):
        return changed if path == toc else original_read(path, *args, **kwargs)
    def is_file(path):
        return False if name == 'missing required file' and path == root / 'tests/run.lua' else original_is_file(path)
    output = io.StringIO()
    with patch.object(Path, 'read_text', read), patch.object(Path, 'is_file', is_file), contextlib.redirect_stdout(output), contextlib.redirect_stderr(output):
        try:
            runpy.run_path(str(script), run_name='__main__')
        except SystemExit as result:
            assert result.code == 1, name
        else:
            raise AssertionError(name)
    assert 'FAIL:' in output.getvalue(), name
print('PASS: Python AST; 7 in-memory negative structural cases each exit 1')
fixtures = (root / 'CraftArmy_Diagnostics/SelfTests.lua').read_text()
assert len(re.findall(r'^    test\(', fixtures, re.M)) == 23
links = 0
for name in ['docs/diagnostics/README.md', 'docs/diagnostics/evidence.md']:
    path = root / name
    for target in re.findall(r'\]\(([^)]+)\)', path.read_text()):
        if '://' not in target and not target.startswith('#'):
            assert (path.parent / target.split('#')[0]).exists(), target
            links += 1
print(f'PASS: {links} local diagnostic document links; 23 fixture definitions (NOT RUN)')
core = (root / 'CraftArmy_Diagnostics/Core.lua').read_text()
assert 'samples = 20, characters = 20, fields = 512, sampleBytes = 65536' in core
assert 'D.SCHEMA = 1' in core
assert '## Version: 0.1.1-diagnostic' in text and '## Interface: 120105' in text
assert '## SavedVariables: CraftArmyDiagnosticsDB' in text
baseline = dict((name, digest) for digest, name in re.findall(r'^([0-9a-f]{64})  (.+)$', (root / 'docs/diagnostics/evidence.md').read_text(), re.M)[:8])
for name in ['CraftArmy_Diagnostics/Commands.lua', 'tests/run.lua', 'tools/check_diagnostics.py']:
    assert hashlib.sha256((root / name).read_bytes()).hexdigest() == baseline[name], name
print('PASS: original limits/schema/Interface/SavedVariables; 3 mechanically unchanged file hashes')
# Static JSON-size arithmetic for the declared coverage shape, not Lua execution.
row = dict(id=9007199254740991, rawNodeCount=9007199254740991,
           pathsDiscovered='unknown', pathsCaptured=64, nonPathOmitted='unknown',
           pathComplete=False, failures=1030, budgetDrops=1030, childLimit=False,
           pathLimit=False, nodeListLimit=False, listInvalid=False, repeated=False)
coverage = dict(policy='paths_only', tabCount=9007199254740991, tabLimit=False,
                tabListInvalid=False, budgetDrops=1030, tabs={str(i): row for i in range(1, 9)},
                limits=dict(tabs=8, paths=64, children=16, nodeList=128), reserveBytes=4096,
                reserveFields=1, configStatus='unsupported', tabsStatus='unsupported', pathCaptureComplete=False)
record = dict(status='observed', time=9007199254740991, timeKnown=True,
              source='diagnostic path-capture accounting', value=coverage)
size = len(json.dumps(record, separators=(',', ':'))) + len(json.dumps('knowledge.coverage')) + 2
assert size <= 4096, size
print(f'PASS: conservative 8-tab coverage shape {size}/4096 bytes (static arithmetic only)')
PY
```

Output:

```text
PASS: Python AST; 7 in-memory negative structural cases each exit 1
PASS: 3 local diagnostic document links; 23 fixture definitions (NOT RUN)
PASS: original limits/schema/Interface/SavedVariables; 3 mechanically unchanged file hashes
PASS: conservative 8-tab coverage shape 2728/4096 bytes (static arithmetic only)
```

PATH-only discovery command:

```sh
for tool in lua lua5.1 lua5.4 luajit luac luacheck stylua; do if command -v "$tool"; then :; else printf '%s: NOT FOUND\n' "$tool"; fi; done
```

All seven tools: **NOT FOUND**. No standalone/client fixture command attempted,
dependency installed, alternate embedded Lua invoked or runtime downloaded.

### R1 frozen content identities

Executed `sha256sum` with the same eight-path command as the original delivery
(exit 0). New R1 identities follow; the original block is retained above. Evidence
and TASKS.md are excluded from self-referential hashes. No hashed-file edits after
this command; independent review must compare against this new block.

```text
7535ac339322765645ae0b27f3da926ccffc2baf3a30105c63683a82b9a99434  CraftArmy_Diagnostics/CraftArmy_Diagnostics.toc
7782b4d825c7f54c75bf46da623eaf227badf640abe922a713d3116eaf891aa0  CraftArmy_Diagnostics/Core.lua
187bc42b19a891e02b3ef62ab40892aaf355f438edf2c2074a83b2984fa1ac3d  CraftArmy_Diagnostics/Probes.lua
7e665f64195a7ab4e2c9bf67c188917aee4b34aad3ee2084f8a9b248ce288a93  CraftArmy_Diagnostics/SelfTests.lua
52fbeca954fdf992ef0923999190dcc7b602ba6488bd8a256bd4bcfdddb4ebc3  CraftArmy_Diagnostics/Commands.lua
8d3210e44846b0fb0e45aa7e78526abbed74d6dc3207bcbb348746f448fd26bc  tests/run.lua
66253a0403fe29078f1b41f99ba295cbcf3c3f3e54f7a060d76b6c3df02ef6f3  tools/check_diagnostics.py
e5f811497e579cd9a27c3087184e10a024b29c613a73e92e17d9d97269784b29  docs/diagnostics/README.md
```

### Final durable-evidence check

After appending R1 evidence, reran `python3 tools/check_diagnostics.py` (PASS, exit 0)
and this read-only check (PASS, exit 0):

```sh
python3 - <<'PY'
from pathlib import Path
import hashlib,re
text=Path('docs/diagnostics/evidence.md').read_text()
rows=re.findall(r'^([0-9a-f]{64})  (.+)$',text,re.M)
assert len(rows)==16
for expected,name in rows[-8:]:
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==expected,name
assert len(re.findall(r'^    test\(',Path('CraftArmy_Diagnostics/SelfTests.lua').read_text(),re.M))==23
links=0
for name in ['docs/diagnostics/README.md','docs/diagnostics/evidence.md']:
    path=Path(name)
    for target in re.findall(r'\]\(([^)]+)\)',path.read_text()):
        if '://' not in target and not target.startswith('#'):
            assert (path.parent/target.split('#')[0]).exists(),target
            links+=1
assert links==3
print('PASS: original 8 identities retained; new 8 hashes match; 3 local links; 23 fixture definitions NOT RUN')
PY
```

Output: `PASS: original 8 identities retained; new 8 hashes match; 3 local links;
23 fixture definitions NOT RUN`. This is content/document inspection only, not
execution of any Lua fixture or client/API validation.

### R1 exact resume point / owner

Primary coordinates **independent review of these R1 identities first**, then the
user safely updates only addon files, runs `/cad selftest`, manually opens their own
Inscription, `/cad scan inscription-open-r1`, `/cad export`. Check all four tabs and
the last tree's root/path observations against the UI and inspect coverage flags,
not just sample field count. Share only manually reviewed/redacted evidence; keep
the original report historical. Piece 9 runtime execution, revised client behavior
and independent acceptance remain pending. No additional coding/design decision,
production feature, mutating integration, installation or release is implicitly
authorized. Primary owns Q03/Q04 findings and all remaining live coordination.

### R1 independent static review and primary checks — 2026-11-05

Verifier `ses_e5628cd74ffe4pIThxKd61a52F` completed static review of all nine R1
manifest files against the original delivery and approved correction contract.
No blocking code defect identified; suitable for a controlled, backed-up user retest.
Review completion is **COMPLETE**; runtime/client acceptance remains **INCOMPLETE**.

Primary inspected and executed the unchanged structural checker, **PASS, exit 0**,
then executed the eight-path `sha256sum` command: every R1 hash matched the newest
block above. These executions belong to the primary. The verifier's own shell
command was permission-denied (**NOT RUN**), with no alternative bypass attempted.
No hashed source, fixture, manifest, tool, runner or README changed during review.
There is no Git revision; the eight R1 hashes identify the reviewed content.

Review covered all-tab metadata priority, late-index path roots, round-robin detail,
conservative failures/limits/completeness, explicit deliberate omissions, reserved
coverage within unchanged limits, history preservation, safe export and fixture
assertions. Moxie/enchant attribution/slot-role inference and Auctionator readback
remain intentionally unverified, not silently implemented.

The revised **23 fixtures have not been executed**. Original user 18/18 success is
historical 0.1.0 evidence only. Original live capture finding still needs a fresh
0.1.1 report showing the intended paths/coverage; static review does not close it.
Next: user follows the safe update/retest guide, stops on self-test failures, and
after 23/23 supplies `inscription-open-r1` evidence. No release approval granted.

### R1 user-run validation — 2026-11-05 — supplied regression resolved

User supplied the old saved sample plus `inscription-open-r1` (time 1793854098,
diagnostic 0.1.1-diagnostic, Retail 12.1.5/70783/120105/enUS), followed by the console
line `23/23 pure fixture cases passed; no live API evidence`. All revised fixtures
are **USER-REPORTED PASS**; local standalone Lua remains NOT RUN. Sanitized analysis
only: no raw JSON file, character names/realm/GUIDs, config ID or full item links
persisted. Original 0.1.0 reports/hashes/results above remain historical.

New capture reports `truncated=false`, `knowledgeCoverageFailed=false`,
`knowledge.coverage.pathCaptureComplete=true`, and zero budget drops. All four tabs
report complete paths, zero failures, and no list/child/path/tab limits or repeated
references. Actual node records include the late-index roots and final Darkmoon
tree omitted by the previous implementation.

| Tree | Raw nodes | Paths captured/discovered | Non-path nodes intentionally omitted | Root |
| --- | --- | --- | --- | --- |
| Blueprints (1122) | 72 | 9/9 | 63 | 106192 |
| Calm Hands (1124) | 22 | 4/4 | 18 | 106280 |
| Perfected Products (1182) | 72 | 9/9 | 63 | 109660 |
| Darkmoon Curiosity (1125) | 78 | 13/13 | 65 | 106358 |

**R1 correction acceptance: PASS for the demonstrated Inscription capture and revised
fixture set.** Complete path capture does not establish per-tree knowledge arithmetic,
all node semantics, all professions, or untested negative/bank/integration scenarios.
No source or diagnostic version changes occurred while recording this evidence.

Additional observations:

- Slot 20 now contains Gilded Sin'dorei Quill (item 259209), rarity 4/epic,
  crafted rank 5, `ITEM_MOD_MULTICRAFT_SHORT=152`. Slots 21/22 remain rare/rank5
  with previous accessory stat keys. This supplies a mixed-rarity example and
  demonstrates rarity changing independently of crafted rank.
- Concentration changed 415→422 over 2571 seconds. This is consistent with the
  reported 345600 ms/point cycle but is not a controlled no-spend/offline test;
  regeneration phase/rounding/offline behavior remains unverified.
- Unspent knowledge remains 0; no staged changes. Shared currency 3902 again reports
  spent=260 for multiple tabs and must not be summed across them.
- Historical and revised samples coexist in the export, supporting retained history
  through the user's update workflow. Explicit reload/multi-alt tests remain separate.
- No permanent-enchant lines, with absence unverified. Moxie mapping and inventory
  probes remain unobserved; Auctionator remains presence-only without method calls.

#### Knowledge unlock-rank semantics — new static evidence

Primary read pinned Blizzard
[specialization templates](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_Professions/Blizzard_ProfessionsSpecializationsTemplates.lua),
function `ProfessionsSpecPathMixin:GetRanks()`. Its comment states the first path
tier is the unlock entry and its maxRanks **can be 0 or 1**. The code uses
`C_ProfSpecs.GetUnlockEntryForPath(nodeID)` and
`C_Traits.GetEntryInfo(configID,entryID)`, then subtracts that entry's `maxRanks`
from positive `currentRank` and from `maxRanks`. The
[specialization frame](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_Professions/Blizzard_ProfessionsSpecializations.lua)
uses `GetRanks()` for displayed points. Source inspection invoked no game action.

Current diagnostic lacks per-path unlock-entry metadata, so **do not hardcode minus
one in production**. In this unstaged sample currentRank equals ranksPurchased for
captured paths. Read-only Python arithmetic over sanitized user rank vectors gives
the following *candidate*, conditional on one unlock rank per path:

| Tree | Raw purchased-rank sum | Positive-rank paths | Candidate KP / capacity (not per-entry validated) |
| --- | --- | --- | --- |
| Blueprints | 3 | 3 | 0/270 |
| Calm Hands | 54 | 4 | 50/70 |
| Perfected Products | 219 | 9 | 210/270 |
| Darkmoon Curiosity | 1 | 1 | 0/260 |

Raw 277 minus 17 positive-path unlock ranks equals 260, matching shared currency
spent once. This is reconciliation evidence, not verified denominators or a general
KP formula. Exact entry metadata/cost semantics and UI comparison are still needed;
free/increased/staged effects must not be promoted to purchased knowledge.

Local check in this update: read-only Python arithmetic PASS for 35 paths, raw sum
277, conditional net 260. No addon/fixture execution by the primary. Next evidence:
targeted Inscription Moxie candidate currency 3261, knowledge UI comparison and actual
tool enchant status; no duplicate full scan needed now.

### Targeted Moxie and enchant clarification — 2026-11-05

User reports the exact output `Artisan Scribe's Moxie 240` from the requested
read-only `C_CurrencyInfo.GetCurrencyInfo(3261)` name/quantity query. This establishes
a user-observed Inscription currency mapping for the tested 12.1.5 client:

- Profession: Midnight Inscription, expansion skill-line 2913 (prior scan).
- Currency: 3261, Artisan Scribe's Moxie, balance 240 at the subsequent query.
- Scope: this profession/client only; other-profession mappings remain untested.
- No exact query timestamp or raw structured currency response was supplied; do not
  replace the earlier sample's unknown mapping/value as if observed at its timestamp.
- Implementation still emits unknown Moxie mapping: evidence registration is not a
  source-code change or production collector implementation.

User also confirms their Gilded Sin'dorei Quill was **unenchanted during the supplied
diagnostic**, then enchanted afterward. This corroborates the previous empty
permanent-enchant line result as a negative example. It does not prove every empty
tooltip result establishes absence, nor identify the newly applied enchant/stat.
Positive-case tooltip evidence remains pending. The user changed their own item;
no agent equipped/enchanted/spent resources or requested such an action.

Next targeted check: with the same character's own Inscription open, read permanent
enchant tooltip lines from observed slot 20 and compare to the user's applied enchant
name/stat. No full report or unrelated tooltip contents are required. This tests
the existing typed-line approach, without writing SavedVariables or invoking a
gameplay action. Knowledge unlock-entry semantics and other live scenarios stay open.

### Positive permanent-enchant tooltip observation — 2026-11-05

User ran the requested `C_TooltipInfo.GetInventoryItem("player",20)` line filter
using `Enum.TooltipDataLineType.ItemEnchantmentPermanent` and reported:

```text
Enchanted: Enchant Tool - Haranir Multicrafting [icon not copied] nil
```

`[icon not copied]` is a descriptive placeholder for the user's visible icon, not
literal API output. No raw atlas markup or enchant rank was supplied.

- Matching the typed filter supports permanent-enchant **presence** for this tool
  on the tested client. The reported localized name is Enchant Tool - Haranir
  Multicrafting; stat category is Multicrafting/Multicraft.
- The trailing `nil` is the absent `rightText` argument printed alongside `leftText`,
  not an API error or part of the name. The actual enchant text was in the left column.
- User previously confirmed the tool was unenchanted during the scan and enchanted
  afterward. Both negative and positive examples now exist, without agent-directed
  spending/equipping/enchanting. This is not validation of all enchant/localization cases.
- The inline icon is rendered tooltip formatting; its identity/rank cannot be
  reconstructed reliably from this paste. Do not confuse any enchant quality with
  the equipped tool's crafted rank or infer a value from a missing icon.
- Stable numeric enchant-ID→stat attribution has not been observed. A small
  read-only extraction from the same equipped instance link can provide that ID,
  rather than relying solely on English text. No source change is authorized here.

Knowledge unlock-entry/capacity semantics, other professions, bank freshness,
offline regeneration and Auctionator method behavior remain separate open checks.

### Numeric enchant identifier — 2026-11-05

User's requested read-only equipped-instance-link enchant-field extraction returned
**8005** for the same tool after the typed tooltip observation. The combined evidence
supports this mapping on the tested client:

| Enchant ID | Reported enchant | Stat category |
| --- | --- | --- |
| 8005 | Enchant Tool - Haranir Multicrafting | Multicraft (`ITEM_MOD_MULTICRAFT_SHORT` category) |

This is the enchant ID field, not the item ID, spell ID, crafted item rank, or a
numeric stat amount. Do not infer enchant quality/bonus value or apply it to other
IDs. An ID-keyed category avoids using the English enchant label as the sole key;
other IDs/locales/families are not validated by this example.

Inscription Moxie mapping 2913→3261 and this one tool-enchant mapping now have client
evidence. No further enchant check is needed for this item. Exact per-path unlock
entry accounting remains the main knowledge-bar implementation question; broader
bank/regeneration/other-profession/Auctionator checks stay open. No source code,
fixture results, existing samples, or release state changed with this evidence.
