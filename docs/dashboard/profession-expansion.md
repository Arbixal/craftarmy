# Gathering and secondary dashboard expansion — feasibility

**2026-11-19: P03 follow-up locally accepted; four-feature native check pending.** User prioritizes a full dashboard
before guide work: the existing eight crafting professions plus Herbalism, Mining,
Skinning, Cooking and Fishing. Existing dashboard sign-off remains accepted. Inscription
is still the first complete guide. This is the evidence audit, not the executable contract.
The separate [P01 foundation/capture contract](expansion-p01-contract.md) is locally accepted
Nov19 (independent static review + separately attributed PRIMARY checks); native acceptance pending. Follow TASKS;
unverified fields stay unknown and report candidates do not activate production mappings.
The separate [P02 activation contract](expansion-p02-contract.md) is locally accepted after
independent static review and PRIMARY full tests/preservation; independent execution was
denied/NOT RUN. Numeric report/UI agreement is resolved; new active dashboard fields and
broader new-profession native acceptance remain pending. No repeat captures needed.
Latest native feedback confirms gathering dashboard numbers; grey Knowledge bars need
palette entries. User confirms no Cooking/Fishing Moxie and supplies the exact Deftness
raw stat key on an older Tool. The approved [P03 follow-up](expansion-p03-contract.md) is
now locally accepted after independent STATIC review/PRIMARY full checks/preservation;
independent execution remains NOT RUN. New colours/D/N/A/warnings native check pending.
User definitely confirms permanent enchants for gathering Tools; gathering missing-enchant
warnings are active in P03 under existing observed-absence safeguards.
Cooking/Fishing enchant support is only tentative; keep their warnings pending. No gold,
enchant application or gear change needed/authorized just to gather evidence.

## Evidence and capability matrix

Family enums below are static identifiers, NOT Midnight expansion skill-line IDs.
“Pending” is a research gap, not a claim that a field applies or is unavailable in game.

| Profession | Family enum | Own learned presence | Midnight identity / skill-cap | Equipment evidence | Moxie | Concentration | Knowledge / unspent |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Herbalism | 4 | Own ready/unstaged stable capture received |2912 / parent182;86/100,modifier5 observed |20/21/22,tool20/item222480 cached; Finesse79 total/neutral |3260 Artisan Herbalist's Moxie300 native/UI-agreed; P02 active | Currency ID0 returned |14complete paths; spend3778;81/560 total,unspent4; P02 active/new dashboard use pending |
| Mining | 6 | Own ready/unstaged stable capture received |2916 / parent186;86/100,modifier0 observed |23/24/25,tool23/item222481 cached; Finesse79 total/neutral |3264 Artisan Miner's Moxie245 native/UI-agreed; P02 active | Currency ID0 returned |12complete paths; spend3784;69/480 total,unspent5; P02 active/new dashboard use pending |
| Skinning | 11 | Own ready/unstaged stable capture received on Skinning character |2917 / parent393;105/105,modifier40 observed |20/21/22,tool20/item238016 cached; Perception110 total/neutral |3265 Artisan Skinner's Moxie55 native/UI-agreed; P02 active | Currency ID0 returned |10complete paths; spend3889;61/400 total,unspent0; P02 active/new dashboard use pending |
| Cooking | 5 | User explicitly learnt Midnight before child lookup; guarded collector context pending |2908 / parent185 / secondary flag observed; child skill/cap1/100 returned |26/27 returned, matching pinned named tool/accessory roles | No Moxie user-confirmed Nov19; P03 N/A active | Currency ID0 returned | Specialization flag false after learning; no specialization trees indicated |
| Fishing | 10 | User explicitly learnt Midnight before child lookup; guarded collector context pending |2911 / parent356 / secondary flag observed; child skill/cap1/300 returned | Rod-only profession gear user-confirmed;29/30 not dashboard accessories; hat uses regular Head | No Moxie user-confirmed Nov19; P03 N/A active | Currency ID0 returned | Specialization flag false after learning; no specialization trees indicated |

The complete batch now evidences ITEM_MOD_FINESSE_SHORT and ITEM_MOD_PERCEPTION_SHORT
in both total and validated enchant-neutral queries. Latest older Skinning Tool screenshot
evidences ITEM_MOD_DEFTNESS_SHORT110 raw total/no enchant, matching +110Deftness; separate
neutral result/build not shown. P03 guarded Deftness recognition is active; separate native
neutral result/visible D acceptance remains unreported, never inferred from raw key alone.
P02 activates only F/P keys/categories and the exact three gathering currency tuples.
No category inference from labels, enchant IDs or neighbouring keys.
Full capture projection and native70961 provenance: [gathering evidence](gathering-native-evidence.md).

### Static sources inspected

Pinned Gethe mirror revision `297d7aaaa736f346b3e036f38ee088eaf7f8c07f`, labeled
`12.1.5 (70783)`. Not proof of the installed client's current behavior. Paths below
are relative to `Interface/AddOns/` at that revision:

- `Blizzard_APIDocumentationGenerated/ProfessionConstantsDocumentation.lua`: family enums.
- `Blizzard_APIDocumentationGenerated/TradeSkillUIDocumentation.lua`: all-profession
  skill lines, by-skill-line info, child info, profession inventory slots and Concentration
  currency query signatures. No offline-alt guarantee or field applicability conclusion.
- `Blizzard_APIDocumentationGenerated/TradeSkillUITypesDocumentation.lua`: ProfessionInfo
  includes skill/cap/modifier, primary flag and nullable parent identity.
- `Blizzard_APIDocumentationGenerated/ProfessionSpecUIDocumentation.lua`: the documented
  SkillLineHasSpecialization(skillLineID) query returns a boolean. Its presence alone
  does not establish applicable Knowledge currencies/topology or committed accounting.
- `Blizzard_ProfessionsBook/Blizzard_ProfessionsBook.lua`: named unpacking of
  `GetProfessions()` as primary1, primary2, Archaeology, Fishing, Cooking. Presence only;
  no authoritative absent/unlearned inference from transient nils.
- `Blizzard_Professions/Blizzard_ProfessionsCrafting.xml`: named equipment roles, including
  active Cooking26/27 and Fishing28; Fishing29/30 are inside an XML comment.
- `Blizzard_Professions/Blizzard_ProfessionsCrafting.lua`: auto-equip groups agree with
  those active roles; ConfigureInventorySlots displays membership in GetProfessionSlots.

Do not activate candidate mappings solely from these declarations. Reuse the established
rule: only inspect equipment slots actually returned for the verified profession.

## Code changes that will be needed (not yet authorized as a task queue)

- Data: five families plus verified expansion identities; capability-specific fields,
  currencies and equipment roles, with evidence provenance.
- Collectors: include learned Cooking/Fishing presence, separately validate own-character
  collection contexts, and collect only applicable fields. Do not simply remove primary,
  readiness, linked/guild/NPC/source-changing or combat protections.
- Core/Knowledge: safely extend stat-category and Knowledge currency validation where
  evidenced. Inscription-only Details remains unchanged; no new guides.
- ViewModel/Dashboard: preserve accepted layout, native normal gear hovers and Shift
  evidence. Correctly render absent capabilities without fake empty-slot/attention cues.
- Storage: preserve every existing snapshot and failed-read retention. Prefer existing
  schema/envelopes if sufficient; any migration requires an explicit contract first.

### Confirmed display policy — user approval2026-11-19

Keep the shared columns. Use a neutral dash with a short “Not applicable” tooltip only
for an evidenced nonapplicable capability; missing API/mapping/snapshot stays unknown,
and a failed refresh keeps the last known observation with existing stale cues. A
nonexistent accessory is not an empty equipped slot. Nonapplicable fields should not
create gear/progression/Concentration attention or match those specific filters.
Observed/estimated Concentration separation and observed-only sorting remain unchanged.

## Next focused native evidence

### Initial query — historical; truncated excerpt received2026-11-18

Requested one **read-only identity query** on a logged-in character who knows one or
more of the new professions. No addon update, `/ca scan`, reset, spending, crafting,
unlearning or full suite. The 239-character command filters to the five new family enums:

```text
/dump (function()local u,t=C_TradeSkillUI,{};for _,id in next,u.GetAllProfessionTradeSkillLines()do local p=u.GetProfessionInfoBySkillLineID(id);if p and ({[4]=1,[5]=1,[6]=1,[10]=1,[11]=1})[p.profession]then t[id]=p end end return t end)()
```

Return the output and which of the five professions that character actually knows.
Empty results/errors are evidence gaps, not absence/N/A. This query's returned set is
not assumed to be a learned roster or necessarily an expansion identity; inspect it
before choosing the next probe. It does not write CraftArmy observations. Current-build
identity, own-presence/context, currencies, gear and specialization evidence must still
be reconciled before their implementation pieces can run. Result and next query below.

### User-returned excerpt — partial metadata, not learned/current-expansion evidence

The user supplied part of the initial query output ending in `<skipped 9>`. Visible
records include Draenor/Pandaria/Cataclysm Herbalism, Skinning and Mining, Khaz Algar
Skinning2882, and base Skinning393. They corroborate older-record parent/family pairs
Herbalism182/4, Mining186/6 and Skinning393/11. Visible skill/cap fields are zero and
sourceCounter0; current learned professions, open context and exact build were not given.

No Midnight record is visible in the supplied excerpt; this is not evidence that the
client lacks them or that the character has not learned them. Cooking/Fishing may be
among omitted output; neither absence nor applicability can be concluded. Do not
activate expansion identities, currencies or collection from this excerpt. No addon
code change or CraftArmy observation write follows from receiving metadata.

### Compact Midnight-only query — returned2026-11-18; do not repeat

To avoid a large nested-table dump and its skipped entries, use one short line per
Midnight record. This English-client discovery filter uses the localized expansion label
only for a diagnostic query, not production identity/eligibility logic. It is read-only,
234characters, and does not require an addon update, scan, reset or profession change:

```text
/run local u=C_TradeSkillUI;for _,i in next,u.GetAllProfessionTradeSkillLines()do local p=u.GetProfessionInfoBySkillLineID(i);if p and p.expansionName=="Midnight" then print(i,p.profession,p.parentProfessionID,p.professionName)end end
```

Return the lines (skill-line ID, family enum, parent ID, name) and which of Herbalism,
Mining, Skinning, Cooking and Fishing this character actually knows. Existing crafting
records may also print; this is not a rescan or repeat acceptance test. No learned-presence
or usable current skill/cap is inferred from the enumeration. If no lines appear, report
that rather than teaching/unlearning professions or resetting any data. User result below.

### Compact native result — gathering identities observed

User returns eleven short Midnight rows, the existing eight crafting identities plus:

| Profession | Expansion skill-line ID | Family enum | Parent ID | Returned name |
| --- | --- | --- | --- | --- |
| Herbalism |2912 |4 |182 | Midnight Herbalism |
| Mining |2916 |6 |186 | Midnight Mining |
| Skinning |2917 |11 |393 | Midnight Skinning |

User explicitly says this character knows **Herbalism and Mining**. Skinning appearing
in the enumeration despite not being in that learned set reinforces that this API result
must not be used as an own-character learned roster. These three metadata identities are
native-observed, not guesses based on adjacent IDs. Current skill/cap, collection context,
currencies/Knowledge, gear and exact installed build remain separate pending evidence.
Cooking/Fishing did not appear in these eleven output lines; the name-filtered result
does not prove they lack current-expansion support, or that they use the same enumeration
or expansion label. No gathering registry/currency activation or collector changes yet.

### Cooking/Fishing family-specific lookup — returned2026-11-18

Use the documented family5/10 lookup instead of guessing secondary expansion IDs or
repeating the eleven-primary list. This217-character read-only query records each lookup
ID and its info when a positive numeric ID is returned; nil/zero results are gaps, not
confirmed absence. It does not assume the returned ID is an expansion skill line:

```text
/dump (function()local u,t=C_TradeSkillUI,{};for _,p in ipairs({5,10})do local id=u.GetProfessionSkillLineID(p);t[p]={id=id,info=type(id)=="number" and id>0 and u.GetProfessionInfoBySkillLineID(id)}end return t end)()
```

Can run on the same character; learned Cooking/Fishing presence is not inferred from
these metadata lookups. No addon update, scan/reset, crafting/spending, profession change
or full suite required. User result below.

### Secondary base-identity result

The user returns both records, each sourceCounter1, `isPrimaryProfession=false`,
skillModifier0 and `expansionName="Unknown"`, without a parentProfessionID:

| Family | Returned lookup / profession ID | Name | Skill / cap in base record |
| --- | --- | --- | --- |
|5 |185 | Cooking |0/0 |
|10 |356 | Fishing |6/75 |

This query resolves base identities on this client, not Midnight child skill lines.
Fishing6/75 is a base-record observation with unknown expansion, not a Midnight skill
observation. Cooking0/0 does not establish authoritative unlearned/absence status.
No learned-secondary roster or own ready collection context has yet been verified.

### Public candidate discovery and direct native check — returned2026-11-18

Public web search results identify these Wowhead skill records:

- [Midnight Cooking2908](https://www.wowhead.com/skill=2908/midnight-cooking).
- [Midnight Fishing2911](https://www.wowhead.com/skill=2911/midnight-fishing).

These are external database/search-index candidates, not pinned Blizzard documentation
or proof of the user's current client. Do not activate them or infer either child from
numeric adjacency. Direct by-skill-line lookup can now test both candidates without
opening/learning/changing professions or repeating the base-family query:

```text
/dump C_TradeSkillUI.GetProfessionInfoBySkillLineID(2908), C_TradeSkillUI.GetProfessionInfoBySkillLineID(2911)
```

Return both records, including names, parent IDs and primary flags. Metadata for an
unlearned profession may still be returned; zero/nil/unknown data must not become a
fabricated learned row, zeroed old snapshot or nonapplicable capability. No CraftArmy
scan/reset/update or gameplay action requested. User result below.

### Secondary child result — all five Midnight identities now observed

User returns both full child records:

| Profession | Child ID | Parent ID | Family | Primary flag | Skill / cap | Expansion |
| --- | --- | --- | --- | --- | --- | --- |
| Midnight Cooking |2908 |185 (Cooking) |5 |false |1/100 | Midnight |
| Midnight Fishing |2911 |356 (Fishing) |10 |false |1/300 | Midnight |

Both sourceCounter1/skillModifier0. These identities are now native-observed, not merely
external candidates. Preserve the distinction from base Cooking185/0/0 and Fishing356/6/75.
The returned child skill/caps are observations, not fixed caps to hardcode or proof of a
guarded own learned-secondary collection context. Exact installed build was not supplied.
No more profession-ID discovery is needed for the five named additions. No code/mapping
activation, guide work or Git mutation follows automatically from receiving these values.

### Capabilities and returned equipment slots — returned2026-11-18

One228-character read-only query prints one line for each new profession. Columns are
**child skill-line ID, Concentration currency ID, specialization flag, returned slot IDs**.
It uses the five native-observed identity/family pairs, no localized label matching:

```text
/run local u=C_TradeSkillUI;for id,p in pairs({[2912]=4,[2916]=6,[2917]=11,[2908]=5,[2911]=10})do print(id,u.GetConcentrationCurrencyID(id),C_ProfSpecs.SkillLineHasSpecialization(id),table.concat(u.GetProfessionSlots(p),","))end
```

Run on the same character; return the five lines or any error. Nil/zero/false/empty results
must be reconciled with own learned presence/readiness and other evidence, not immediately
converted into N/A/zero/absence. Unlearned Skinning may not return usable slots on this
character. An error/partial output is a gap, not a failed CraftArmy scan or lost data.
No update, scan/reset, spending/crafting or profession change required. User result below.
Moxie mapping, Knowledge currency/accounting, gear stats and own collection contexts remain
separate checks; these three API results do not establish all dashboard field support.

### User clarification and capability result

User explicitly clarifies they **learnt Midnight Fishing and Midnight Cooking on this
character before running the direct child-identity query** that returned1/300 and1/100.
Record learned presence as user-confirmed for these secondaries, in addition to earlier
Herbalism/Mining presence. Do not backdate this to earlier base lookups or treat the
clarification as a verified collector roster/readiness/linked-source guard. The user
performed that learning themselves; no further learning/unlearning/profession changes
are requested or needed for these already-observed identities.

Returned capability rows, in reported order:

| Child ID | Concentration currency ID | Has specialization | GetProfessionSlots result |
| --- | --- | --- | --- |
|2917 Skinning |0 |true | Empty list |
|2911 Fishing |0 |false |28,29,30 |
|2912 Herbalism |0 |true |20,21,22 |
|2908 Cooking |0 |false |26,27 |
|2916 Mining |0 |true |23,24,25 |

All five have no positive mapped Concentration currency in this result. Do not save
that as an observed Concentration balance of0 or apply crafting-specific recharge bars/
attention. Cooking/Fishing's false specialization flags were obtained after learning;
these support a capability-specific no-tree display rather than fake Knowledge0/cap.
Final neutral-dash presentation remains proposed, not a user-confirmed visual decision.

The slot results are character-dependent: this character does not report Skinning as a
learned primary, so its empty list cannot establish that Skinning lacks equipment. Keep
own learned-presence/identity checks; do not invent a Skinning row from the metadata list.

**Fishing discrepancy:** native GetProfessionSlots returns28/29/30, whereas the pinned
XML/Lua only instantiates/enables tool28 and comments out accessories29/30. Preserve both
facts. Returned indices alone do not prove visible/equippable accessory roles; commented
old UI alone does not override this native result. Do not assume either one usable slot
or three usable slots, and do not mark29/30 as empty/missing/N/A until reconciled.

Next focused evidence: ask whether the game's Fishing equipment view exposes accessory
slots alongside the rod, preferably a screenshot if available; if no equipment view can
be opened, report that instead of forcing one. Exact current build can help reconcile
the older source, but neither version nor cause is inferred. No repeat identity/flag/
slot query, gear change or further profession learning requested. Independent Moxie/
Knowledge/accounting/stat and collector-context work can proceed without treating this
Fishing-specific uncertainty as a blanket block.

### Fishing equipment question resolved — user screenshot/report2026-11-18

User supplies a Fishing-window screenshot and explicitly states there is **only one slot
in the UI**. They can craft a fishing hat, but equipping it uses the **regular Head slot**.
This resolves the dashboard capability question at the reported scope: Fishing has a
profession rod/tool slot, not two profession accessories. Retain the raw API28/29/30
result as evidence, but do not turn29/30 into active accessories just because they were
enumerated. Their exact reserved/hidden implementation reason is not established.

The screenshot shows Midnight Fishing1(+8)/300 and an equipped fishing-rod tooltip with
Perception and +Midnight Fishing Skill. This is visual evidence, not an intrinsic stat
API-key/base-vs-enchant attribution, universal cap, exact current build or performance
proof. Do not copy unrelated character/account/third-party tooltip details into project
docs or infer third-party warnings to be CraftArmy errors.

Implementation constraint for the later contract:
- Only the evidenced Fishing rod role (slot28) is part of profession gear collection.
- Both dashboard accessory cells are nonapplicable, not empty/missing/unknown, and must
  not create gear attention or match missing-gear filters. Neutral-dash appearance is
  still proposed; the semantic distinction is now established.
- Do not collect head-slot hats as profession accessories or expand to regular armor
  tracking. The hat's ordinary slot is not a new requested dashboard feature.
- Add a regression where Fishing returns28/29/30 yet only rod28 is inspected/rendered;
  no accessory29/30 or regular Head reads, false missing-gear cues or invented row data.
- Preserve the shared row layout and all accepted crafting profession gear behavior.

No repeat Fishing identity/flag/slot/UI screenshot or gear-change procedure requested.
Remaining expansion work is Moxie applicability/mappings, gathering Knowledge accounting/
stats, guarded acquisition and a settled implementation contract, not this resolved slot
question. No addon code, scan/reset, guide or Git mutation performed.

### 2026-11-19 — N/A policy approved; Skinning characters available

User accepts `—` for genuinely nonapplicable cells and exclusion from field-specific
attention/filter matches; unknown data stays distinct. This supersedes earlier dated
“neutral dash proposed” wording in this audit. A nonmax observed secondary skill still
matches the Skill-only filter; no entire-profession exclusion is implied by no Knowledge.
User confirms a number of Skinning characters are available for the next focused capture.
No new learning/unlearning, character cap or repeat completed identity/flag/UI checks.

P01 is now a fully specified foundation plus consolidated read-only gathering-evidence
proposal, awaiting explicit scoped implementation approval in TASKS. It deliberately leaves
unverified Moxie (including secondary applicability), gathering numeric Knowledge and
intrinsic stat keys pending. Report candidates are not production eligibility. A later
evidence-gated task is required to activate verified data; local foundation tests alone
will not establish full new-field/native acceptance. No writer/source edits yet.

## Planned regression gates

- Retain full local correctness/stress suites; add rejecting fixtures for new capabilities,
  secondary own-presence/context, unsafe sources, transient nils and unknown vs N/A.
- Exercise mixed-family rows across46/100/200 characters with up to two primaries plus
  Cooking/Fishing per character. These are workloads, never storage ceilings.
- Prove legacy snapshots remain valid and byte-equivalent where untouched; no silent
  retirement, eviction, reset, forced rescan or history reinterpretation.
- Cover13-family dropdown, filtering/current-first grouping, scrolling and range counts;
  unchanged accepted crafting layout, gear cues, tooltips and prediction invariants.
- Add focused native normal-use checks for NEW professions only. Do not repeat accepted
  crafting checks or reclassify existing INCOMPLETE/UNVERIFIED evidence.

Next contract needs explicit file ownership, serial pieces/dependencies, native evidence
provenance, rejecting tests, validation commands and report requirements before delegation.
No writer, source changes or Git commit/push are active.
