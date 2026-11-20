# CraftArmy

A World of Warcraft **Retail** addon for managing crafting alts and their profession
progress in one dashboard.

Source repository: [Arbixal/craftarmy](https://github.com/Arbixal/craftarmy).

## Current status

The existing eight-profession crafting dashboard is implemented and user-signed-off:
Alchemy, Blacksmithing, Enchanting, Engineering, Inscription, Jewelcrafting,
Leatherworking and Tailoring. P01 adds a **thirteen-family foundation**, including Herbalism,
Mining, Skinning, Cooking and Fishing; new-profession native acceptance is still pending.
P02 activates verified gathering Moxie, numeric Knowledge/unspent and Finesse/Perception
intrinsic Tool stats using native70961 capture/UI agreement. P02 is locally accepted after
independent static review and primary local tests; independent execution was unavailable.
P03 implements Cooking/Fishing Moxie N/A, gathering Knowledge colours, guarded Deftness
Tool recognition and gathering missing-enchant warnings. P04 enables **Cooking-only Missing
enchant** warnings/filter membership for confirmed absence, using existing freshness/history
safeguards. Fishing enchant-warning eligibility stays pending, not enabled or ineligible.
No Cooking intrinsic stat/letter or enchant-ID mapping changes. See [P04](TASKS.md#p04--cooking-missing-enchant-warning)
for local delivery gates and [P03](TASKS.md#p03--profession-na-colours-deftness-and-gathering-enchant-warnings)
for current validation/acceptance; the four P03 behaviors have focused user acceptance,
not blanket acceptance of every new-profession field or procedure.
R03 extends R02 continuity across explicitly signalled ordinary collector handoffs. The
current-player dot is independently revalidated; a renewed successful Concentration
observation can replace its complete visible cell using the existing shared render clock,
then freeze while the full view builds. Unchanged projections remain frozen without
recalculation. A new observation with no additional estimated gain correctly shows only
the observed blue bar, not obsolete cyan. Pending actions and hovers remain historical,
not fresh. Generic drift, invalid source/options/GUID/generation or failures still fail
closed; unsafe estimate clocks drop predictions independently of identity. Implementation,
review and native gates are separate in [R03 run state](TASKS.md#r03--collection-handoff-continuity-follow-up).
R03 native continuity remains unaccepted: both indicators still disappeared on confirmed
r03.1. R04 corrects a concrete empty-FontString API mismatch: a successful nil text read is
normal blank text, not a paint failure. Thrown reads and other invalid types still fail
closed; collection and continuity policy are unchanged. Native-compatible regressions
reproduce the previous failure locally, not the exact client call. Implementation, review,
primary acceptance and native follow-up are recorded in [R04 run state](TASKS.md#r04--empty-fontstring-read-incorrectly-invalidates-continuity).
The user confirms R04 fixed both indicators; focused native continuity acceptance is complete.
Profession guides, shopping calculations and Auctionator
export are planned but **not implemented**; Inscription will be the first complete guide.

The dashboard includes:

- Saved character/profession snapshots, with no fixed character cap.
- Skill, profession gear, Moxie, Knowledge and Concentration.
- Filters, sorting, current-character priority and scrollbar navigation.
- Distinct observed and estimated Concentration portions. Estimates are approximate;
  sorting and attention filters use observed values.
- Native item tooltips, with additional diagnostics available on Shift-hover.

Offline characters show saved observations, not live inspection. Unknown data is not
treated as zero or confirmed absence. Existing snapshots are retained on failed reads.
Confirmed nonapplicable cells show `—`, with no field-specific attention: all five new
Concentration fields, Cooking/Fishing Moxie/Knowledge, Cooking's second accessory and both
Fishing accessories. Cooking tracks Tool26/accessory27; Fishing tracks rod28 only,
never API-returned29/30 or regular Head gear. Nonmax secondary Skill still matches the
Skill-below-max filter. Only a guarded own learned profession scan creates a new row.

All three gathering reports and native value agreement are already received; do not repeat
them or the accepted P03 colour/N/A/Tool-letter/warning and R04 refresh checks. Cooking Tool
permanent-enchant applicability is now user-confirmed; Fishing remains unverified. No new
captures, purchases, enchant applications or gear changes are needed or authorized.
Moxie with reported max0 displays the observed balance, not a clamped0 or balance/0.
`/ca knowledgecapture` remains read-only evidence, never a saved scan or activation switch.
See the dashboard guide for focused normal-use steps and remaining native gates.

## Installation and use

1. With WoW closed, back up existing CraftArmy SavedVariables before updating.
2. Copy `CraftArmy/` into `World of Warcraft/_retail_/Interface/AddOns/`.
3. Optionally install `CraftArmy_Diagnostics/` alongside it for the separate diagnostic
   harness. It is not a dependency of the main addon.
4. Open the dashboard with `/ca`; `/ca help` lists commands. Open your own supported
   profession normally to collect its data; `/ca scan` requests a guarded refresh.

See the [dashboard documentation](docs/dashboard/README.md) for behavior, current
validation evidence and update/recovery notes. Do not reset SavedVariables to refresh data.

To identify loaded Dashboard code, hold **Shift**, then hover the status line directly
beneath the title. Expect `Loaded dashboard build: 0.2.0-mvp+p04.1`. This is not the TOC
version or verification of the whole installation. Future changed Dashboard deliveries
must deliberately advance this identifier.

## Development

Run from the project root, using an **already-installed Lua 5.1** runtime:

```sh
lua5.1 tests/cooking_enchant.lua
lua5.1 tests/fontstring_continuity.lua
lua5.1 tests/collection_continuity.lua
lua5.1 tests/refresh_continuity.lua
lua5.1 tests/profession_completion.lua
lua5.1 tests/gathering_activation.lua
lua5.1 tests/profession_expansion.lua
lua5.1 tests/dashboard.lua
lua5.1 tests/run.lua
python3 tools/check_dashboard.py
python3 tools/check_diagnostics.py
```

Latest dashboard validation completed 512 top-level cases, all 19 grouped U07 workloads,
744 K6 and 565 K7 supplemental checks; diagnostics completed 23/23 cases. Python checks
are structural only. Local tests do not establish native client behavior or measured
performance. Full native suite remains INCOMPLETE87/149; all-rank costs UNVERIFIED and
quantified offline estimate accuracy unverified. P01/P02/P03/P04/R02/R03/R04 command results and separate
review/acceptance gates are recorded in [TASKS](TASKS.md).

## Project layout

| Path | Purpose |
| --- | --- |
| `CraftArmy/` | Main addon |
| `CraftArmy_Diagnostics/` | Independent diagnostic addon |
| `tests/`, `tools/` | Local fixtures and structural checks |
| `media/` | Preserved original branding assets |
| `docs/` | Design, decisions, validation evidence and history |
| `PLAN.md`, `TASKS.md`, `AGENTS.md` | Requirements and development workflow |

The original and packaged icon assets are documented in the
[asset manifest](CraftArmy/Media/Icons/README.md).
