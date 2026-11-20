# Gathering native evidence — P01 capture batch

**Received2026-11-19 from user-run `/ca knowledgecapture` reports.** Mining, Herbalism
and Skinning all report `captureComplete=true`, `gatheringEvidenceComplete=true`,
`stable=true`, `outputTruncated=false`, complete discovered/captured path counts and a
provisional shared-spend reconciliation match. No activation/implementation permission
or broad normal-use acceptance is inferred from receiving reports.

## Provenance and boundary checks

- All three: Retail12.1.5 **build70961**, Interface120105, localeenUS. Static-source pin
  remains `297d7aaaa736f346b3e036f38ee088eaf7f8c07f`; it is not the native build identifier.
- Coherent start/finish exact Midnight tuples: Mining2916/186/6/11,
  Herbalism2912/182/4/11, Skinning2917/393/11/11. Config/sourceCounter unchanged within
  each report; staging and explicit staging reads false at both boundaries. Runtime
  revision/serial unchanged. Ephemeral config/character identifiers are not persisted here.
- Mining12/12paths, Herbalism14/14, Skinning10/10, each across3complete tabs;36paths total.
  No omission/truncation is indicated. This is user-supplied native evidence, not agent
  client execution, measured latency or proof of every failure path/build/API.
- Numeric projection below transcribes the report evidence for durable planning and
  later regressions; it is not a snapshot write or independent raw-report parser replay.

## Observed own-character metadata

| Profession | Skill/cap | Separate skill modifier | Moxie currency / name | Quantity / reported max | Returned gear / equipped tool | Total and enchant-neutral Tool stat |
| --- | --- | --- | --- | --- | --- | --- |
| Mining |86/100 |0 |3264 / Artisan Miner's Moxie |245 /0 |23,24,25 / slot23,item222481,cached/existing | ITEM_MOD_FINESSE_SHORT / Finesse79 in both queries |
| Herbalism |86/100 |5 |3260 / Artisan Herbalist's Moxie |300 /0 |20,21,22 / slot20,item222480,cached/existing | ITEM_MOD_FINESSE_SHORT / Finesse79 in both queries |
| Skinning |105/105 |40 |3265 / Artisan Skinner's Moxie |55 /0 |20,21,22 / slot20,item238016,cached/existing | ITEM_MOD_PERCEPTION_SHORT / Perception110 in both queries |

These supplied Moxie IDs/names/balances now have native evidence on build70961, not just
catalogue provenance. User subsequently confirms all reported numbers match native UI
(Nov19; focused value agreement only). The reported maximum0 is not a
usable balance cap: do not clamp positive balances to0 or display them as245/0 etc.
Skill/cap and modifier are separate observed fields. Skinning105/105 must not be normalized
to100/100, nor should the40modifier be added to its saved base skill. No racial/class
cause is inferred. Identical total/neutral stat values do not prove absence of an enchant
or a universal base/enchant rule. Deftness's intrinsic API key is not evidenced by this
batch; existing D enchant labels/catalogue entries do not supply that missing proof.

## Knowledge reconciliation

Tree totals exclude the automatic unlock rank, not a point of actual Knowledge spend.
Shared currency is compared **once per profession**, never summed across repeated tab
currency rows. Quantity agrees with the independent unspent observation in each report.

| Profession | Native spend currency | Shared spent / quantity | Tree ID / name / candidate purchased-capacity | Total candidate |
| --- | --- | --- | --- | --- |
| Mining |3784 |69 /5 |1107 Plentiful Ores29/170;1105 Meticulous Mining40/110;1106 Over-LODED0/200 |69/480 |
| Herbalism |3778 |81 /4 |1074 Bountiful Harvests40/240;1073 Botany41/120;1080 Midnight Overload0/200 |81/560 |
| Skinning |3889 |61 /0 |1120 Thorough Tanning0/120;1119 Gainful Gathering0/160;1121 Talented Tracker61/120 |61/400 |

Zero purchased/unspent values are observed, not unknown or proof that a profession/tree
is absent. All shared maxQuantity values are nullable/nil. Auxiliary currencies are not
Knowledge balances/capacity: Mining3783spent3/max3, Herbalism3779spent3/max3 and Skinning
3888spent3/max3 recur separately. Other per-tab auxiliary rows have their own quantities/
spent/max; do not combine them with shared currency or use their max as a Knowledge cap.

### Complete path projection

Columns: profession, tab, path, children (`-` means observed empty), purchased/max node
ranks, unlock/spend entry IDs, current cost currency. All36paths: node type1/flags0,
availability true (not proof of unlocked state), ranksIncreased0, currentRank/activeRank
equal ranksPurchased, totalMaxRanks equal maxRanks; exactly two distinct unlock/spend
entries with increased maps0. Unlock entry type9/max1, spend entry type7/max(node)-1,
positive definitions, both entryCost arrays observed empty. Current cost arrays each
contain one amount1. GetSpendCurrencyForPath always returns the profession's shared
currency, including paths whose CURRENT cost is an auxiliary unlock token.

```text
Mining,1107,105568,105567|105566|105565,30,51,130286,130282,3784
Mining,1107,105567,-,1,41,130285,130270,3784
Mining,1107,105566,-,1,41,130284,130260,3784
Mining,1107,105565,-,0,41,130283,130250,3875
Mining,1105,105475,105474|105473,41,41,130184,130181,3784
Mining,1105,105474,-,1,36,130183,130171,3784
Mining,1105,105473,-,1,36,130182,130161,3784
Mining,1106,105526,105525|105524|105523|105522,1,41,130240,130235,3784
Mining,1106,105525,-,0,41,130239,130225,3871
Mining,1106,105524,-,0,41,130238,130215,3871
Mining,1106,105523,-,0,41,130237,130205,3871
Mining,1106,105522,-,0,41,130236,130195,3871
Herbalism,1074,104481,104480|104479|104478|104477|104476,41,41,129113,129107,3778
Herbalism,1074,104480,-,1,41,129112,129097,3778
Herbalism,1074,104479,-,1,41,129111,129087,3778
Herbalism,1074,104478,-,1,41,129110,129077,3778
Herbalism,1074,104477,-,1,41,129109,129067,3778
Herbalism,1074,104476,-,1,41,129108,129057,3778
Herbalism,1073,104421,104420|104419,41,41,129047,129044,3778
Herbalism,1073,104420,-,1,41,129046,129034,3778
Herbalism,1073,104419,-,2,41,129045,129024,3778
Herbalism,1080,104707,104706|104705|104704|104703,1,41,129367,129362,3778
Herbalism,1080,104706,-,0,41,129366,129352,3816
Herbalism,1080,104705,-,0,41,129365,129342,3816
Herbalism,1080,104704,-,0,41,129364,129332,3816
Herbalism,1080,104703,-,0,41,129363,129322,3816
Skinning,1120,106089,106088|106087,1,41,130827,130824,3889
Skinning,1120,106088,-,0,41,130826,130814,3896
Skinning,1120,106087,-,0,41,130825,130804,3896
Skinning,1119,106059,106058|106057|106056,1,41,130794,130790,3889
Skinning,1119,106058,-,0,41,130793,130780,3893
Skinning,1119,106057,-,0,41,130792,130770,3893
Skinning,1119,106056,-,0,41,130791,130760,3893
Skinning,1121,106119,106118|106117,41,41,130860,130857,3889
Skinning,1121,106118,-,22,41,130859,130847,3889
Skinning,1121,106117,-,1,41,130858,130837,3889
```

For each node, candidate points are purchased>0 ? purchased-1 :0, capacity=max-1.
This projection gives Mining29+40+0=69, Herbalism40+41+0=81, Skinning0+0+61=61,
matching shared spent69/81/61. It corroborates the existing guarded native-rank accounting
policy for these captured graphs, not a verified future/all-rank cost rule. Entry active/
next rank fields are not a substitute for purchased-rank/unlock evidence (partial examples:
Mining105568 current30/active-entry29; Herbalism104419 current2/active-entry1;
Skinning106118 current22/active-entry21). Maxed paths have nullable nextEntry.

### Alternate CURRENT costs: not failed captures

Zero-rank paths use auxiliary current unlock costs in these reports:
- Mining105565 uses3875;105525/524/523/522 use3871.
- Herbalism104706/705/704/703 use3816.
- Skinning106088/087 use3896;106058/057/056 use3893.

These paths have an unlock entry of max1 and candidate0Knowledge. The diagnostic's narrow
current-cost consistency line correctly flags a cost currency differing from the spend
currency. Do not equate that label with truncation, wrong profession attribution or a
shared-spend reconciliation failure. Future/all-rank costs remain **UNVERIFIED**.

## Pending focused acceptance / next action

User confirms Nov19: “Yes, all these numbers match up.” Native UI/value agreement is
resolved for the reported Moxie, tree Knowledge/unspent and tool stat values. Do not ask
again or request more dumps. Capture error-free/responsive behavior was not separately
stated; no broad normal-use, dashboard row/N/A or all-rank acceptance is inferred.
No full-client suite, changed gear or profession training.

The same response reports estimated Concentration disappearing and being redrawn during
apparently periodic dashboard refreshes; frequency/trigger uncertain. This is a separate
[refresh presentation investigation](concentration-refresh-investigation.md), not failed
gathering arithmetic or authorization to activate fields/change addon code.

User subsequently directs Nov19: finish other-profession dashboard coverage first and
follow up with the Concentration flicker fix afterward. Profession activation scope is
the next planning step; flicker investigation/fix is deferred, not a prerequisite.

The separately approved [P02 activation contract](expansion-p02-contract.md) is now locally
accepted: exact gathering Moxie/Knowledge/F/P mappings active, independent STATIC PASS plus
PRIMARY full suites/preservation/freeze PASS. Independent executable verification remains
INCOMPLETE/NOT RUN after shell denial; [review](expansion-p02-review.md). Next is ordinary
new active dashboard-field normal use, not another report/value interview. Latest user
feedback below resolves secondary Moxie applicability and supplies the Deftness raw key;
latest gathering enchant-attention applicability is confirmed below, secondary eligibility
remains provisional. Preserve all existing snapshots;
new known values must come from ordinary
guarded scans, not importing these character balances as defaults. Receipt of these reports
alone authorized no code work; subsequent P02 approval/delivery is separately recorded.
No new native run, Git mutation, release, guide or flicker work inferred.

Documentation validation: PRIMARY arithmetic/graph check of the normalized transcription
passes36unique paths/9trees, exact per-tree totals and shared69/81/61 spent matches. This
is not a raw-report parser replay. Python structural check PASS88Markdown/483links/8
diagnostic hashes; git diff whitespace PASS. All11accepted P01 source/test/README hashes
unchanged. No fresh Lua/client execution from this evidence-only update.

## 2026-11-19 — Dashboard values agree; secondary Moxie and Deftness evidence

- User confirms Herbalism/Mining/Skinning **dashboard values match** after P02. Focused
  numeric native acceptance received; no repeat reports/value checks requested. Error-free/
  freeze-free behavior and full normal-use acceptance were not separately stated.
- User reports Knowledge bars grey. Static Data.TreeRGB lookup has no2912/2916/2917 tab
  entries, so all nine gathering tabs use neutral fallback. P02 deliberately preserved
  that fallback. Proposed presentation follow-up maps already-evidenced tab IDs to the
  existing palette in captured order; no new topology/accounting discovery required.
- User explicitly confirms **Cooking/Fishing have no Moxie**. Applicability question is
  resolved: proposed Moxie N/A display uses the accepted neutral dash and excludes
  Moxie-specific attention/sort values. No missing-data-to-N/A guess or currency-ID hunt.
- Screenshot: Artisan Skinning Knife, item222490, equipped Tool slot20, item expansion10
  (older), +110Deftness. CraftArmy's Shift raw total reads **ITEM_MOD_DEFTNESS_SHORT:110**
  and reports no enchant/ID0. This is raw API-key evidence, not just localized item text.
  Current registry lacks that key; normal diagnostic “Unknown stat”/own-stat unavailable
  is consistent with inactive recognition. Older equipment does not invalidate the key,
  authorize older profession rows or require gear changes/a newer Deftness item.
- Screenshot does NOT show a separate enchant-neutral query result or build number; do
  not attribute build70961 or a neutral-query110 observation to this image. Existing
  guarded neutral-query recognition can fail safely if unavailable; no bypass is proposed.
  Enchant absent on one Tool is not proof whether that profession's Tools are enchantable.
  Third-party tooltip/BIS messages are not attributed to CraftArmy defects.

Next proposed three-part follow-up: secondary Moxie N/A, gathering Knowledge colours,
Deftness key/category recognition with existing instance/neutral/stat guards. No source
edits/new implementation approval or writer from receiving this feedback. Permanent-tool
enchant eligibility for the five additions remains a separate, primary-owned question;
no buying/applying enchants, swapping gear or more gathering dumps needed. Concentration
flicker remains after profession coverage. No Lua/native run or Git mutation in this update.

## 2026-11-19 — Permanent Tool enchant applicability confirmation

User definitely confirms Herbalism, Mining and Skinning support **permanent enchants**.
Treat “Minding” in the response as Mining in this established three-profession context;
no new profession/category inferred. This resolves gathering profession-level warning
eligibility for a scoped follow-up, not exact enchant amounts/ranks, every item/expansion
restriction or a fresh observed equipped-enchant read. Keep all existing validity/instance/
freshness and observed-positive/observed-absent/unknown distinctions when enabling warnings.

For Cooking/Fishing, user says “I believe” and has no characters with enchanted Tools.
Their applicability remains **provisional**, neither enabled nor confirmed N/A. Do not
convert belief into native enchant evidence or infer missing-gear/enchant absence from
availability. Keep secondary missing-enchant warnings disabled pending reliable evidence.

User offers to enchant Tools if useful. No gold spending/purchase/application/gear change
is needed or authorized just to continue verified work. A naturally encountered existing
enchanted secondary Tool could later supply evidence without a dedicated acquisition
procedure. No additional query/dump requested now; Cooking/Fishing uncertainty does not
block the independently verified gathering warning activation.

Proposed next batch is now four pieces of product scope: secondary Moxie N/A, gathering
Knowledge palette entries, guarded Deftness recognition, gathering missing-enchant warnings.
Implementation task/approval was still pending at this evidence stop. Subsequent P03
approval/delivery below supersedes that run state. Concentration remains deferred.

## 2026-11-19 — P03 approved, implemented and locally accepted

User explicitly approves the four-part follow-up. P03 implements secondary Moxie N/A,
native-ID gathering colours, guarded D recognition and gathering missing-enchant eligibility.
Secondary warnings stay pending/disabled; no new evidence or permission for enchant
purchases/applications. No raw110-to-neutral result inference; synthetic tests label79as
fixture-only. [Contract](expansion-p03-contract.md), [review/attribution](expansion-p03-review.md).

Independent full-diff/new-runner/old adaptations STATIC PASS/no findings; executable
verification INCOMPLETE after shell denial/NOT RUN, no bypass or reattribution. PRIMARY
P03=15/31244,P02=12/13223,P01=16/220990,512/all19/K6K7/23/Python and exact preservation/
post-review freeze PASS. No writer; implementation locally accepted, not broad native
sign-off. Next ordinary new colours/N/A/D/warning check, not repeated values/reports/old
checks, newer Tool or gear changes. No install/Git/publication/flicker/guide work.

## 2026-11-19 — All four P03 native behaviors accepted

User confirms Cooking/Fishing Moxie dash, gathering colours, D letter and gathering-only
missing-enchant behavior, as expected. Focused P03 native acceptance complete; no repeated
tests or broader error-free/timing/overall dashboard sign-off inferred. Disabled secondary
warnings are not proof of Cooking/Fishing permanent-enchant ineligibility; that remains
provisional. No purchases/gear changes needed to continue.

User also reports current-player dot flickers during refresh; include it with Concentration
estimate in [combined investigation](concentration-refresh-investigation.md). Profession-first
ordering is satisfied for this follow-up. Primary local read-only probe reproduces both
hide/restore across retained-build callbacks, full saved root/token unchanged. No source
fix/implementation approval yet; native trigger/frequency unknown. Do not reopen P01–P03.

## 2026-11-20 — Existing enchanted Cooking Tool; fixed secondary Tool stats

User independently discovers an existing **Cooking Tool with a Multicraft enchant**.
This confirms permanent Tool enchant applicability for Cooking, superseding the earlier
tentative Cooking belief. No purchase/application/gear change was needed or requested.
The report is sufficient for the profession-level Cooking missing-enchant warning gate;
it does not establish an enchant ID/rank, exact amount or universal historical item rules.
Current source still leaves secondary warning eligibility pending; activation is a proposed
scoped change, not implemented or newly user-authorized here. Existing positive/absent/
unknown, item-instance and freshness safeguards must remain.

User additionally reports:

| Tool family | Intrinsic stat finding | Quantity finding | Enchant evidence |
| --- | --- | --- | --- |
| Cooking | Fixed multi-stat mix, not a selectable single-stat variant | Changes with rarity/quality | Existing Multicraft-enchanted Tool confirms applicability |
| Crafted Fishing Tools | Perception | Changes with rarity/quality | Not tried; applicability still unverified |

Do not infer the Cooking base mix's exact names/numbers: none were supplied. In particular,
the Multicraft **enchant** is not proof of intrinsic Multicraft or a sole base M category.
Intrinsic stats and permanent enchant remain independent, using existing guarded neutral
query/actual equipped evidence. The Fishing report applies to crafted Tools described by
the user, not every old/dropped rod, an exact native key/neutral query capture or a hardcoded
Perception amount. No extra report/screenshot/key interview or newer Tool requested.

Fishing enchant eligibility remains pending/unverified, not confirmed ineligible. No need
or authority to buy/apply an enchant or change gear to test it. These new facts do not alter
accepted Moxie/Knowledge N/A, rod-only equipment or R04 refresh acceptance. No source writer,
implementation, installation, Git mutation or guide work authorized by this evidence update.

## 2026-11-20 — Cooking-only warning approved and locally accepted (P04)

User explicitly approves enabling Cooking's existing Missing enchant warning/filter, leaving
Fishing unchanged. Exact Cooking eligibility is now enabled in Data; Fishing remains
pending/unverified, not ineligible. All existing observed-absence, unknown, same-instance/
history/freshness/archive safeguards reused unchanged. No new enchant ID/amount, Cooking
single-stat choice or Fishing/stat presentation rule introduced. Dashboard loaded marker
advances to `0.2.0-mvp+p04.1`; accepted R04 refresh fix bytes otherwise unchanged.

Independent full STATIC PASS/no findings; independent executable/comparison checks NOT RUN
after denial, no retry/bypass or evidence reattribution. Separately attributed PRIMARY full
12serial commands/pass plus scoped reconstruction/protected/Git proofs in TASKS P04.
Local acceptance is not new native warning acceptance. Next ordinary use only; no buying,
applying an enchant, changing gear, repeated reports/accepted refresh checks or new dump
needed. No installation/copy/Git/publication/guide authority.

## 2026-11-20 — P04 focused native acceptance

User answers “Confirmed” to the delivered Cooking-only Missing enchant warning/filter.
Accept that focused behavior. Fishing enchant eligibility remains pending/unverified, not
ineligible. R04 refresh continuity acceptance remains complete. No repeat warning/refresh/
profession checks, purchases/applications/gear changes or new dumps needed. The same message
reports scrolling stalls; that is a separate performance investigation, not failure of
the accepted warning or authority for installation/Git/guides. Broader unreported native
checks, full native suite completion, all-rank costs and estimate accuracy are not inferred.
