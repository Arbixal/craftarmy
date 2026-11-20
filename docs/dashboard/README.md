# P04 — Cooking missing-enchant warning

Cooking Tool permanent-enchant applicability is user-confirmed from an existing
Multicraft-enchanted Tool. P04 enables the existing **Missing enchant** warning/filter
only for Cooking, in addition to previously enabled professions. Confirmed zero/empty
enchant IDs warn; positive IDs suppress the warning even if their category is unknown.
Unknown/unloaded/conflicting evidence is not absence. Retained same-instance absence
may warn as **last observed**, never fresh; archives have no attention warnings.

Fishing eligibility stays **pending**, not ineligible, even with observed absence.
Cooking Tool26/accessory27, Fishing rod28 only, N/A cells and secondary Skill filtering
are unchanged. No stat UI, guessed Cooking base letter, new enchant ID or rank/amount
mapping is added. Test IDs and multi-stat amounts are synthetic, not new native proof.

Loaded Dashboard build: `0.2.0-mvp+p04.1` in the existing Shift/status tooltip. All R04
empty-FontString and R03 handoff/continuity bytes are unchanged apart from that literal.
R04 refresh continuity is already user-accepted; no repeat refresh/marker interview.

`lua5.1 tests/cooking_enchant.lua` covers actual collection/storage/view/widget paths
in both schemas, fresh/history/unknown/changed-instance/archive/filter safety and native
normal versus Shift diagnostic hovers. Local fixtures are not native-client acceptance.
Implementation, independent review and primary acceptance remain separate in
[P04 run state](../../TASKS.md#p04--cooking-missing-enchant-warning).
No purchases, applications, gear changes, dumps, install/copy, Git or guide authority.
Full native87/149 remains INCOMPLETE; all-rank costs and estimate accuracy unverified.

Earlier documentation below is preserved history; current P04/R04 acceptance and limits
above supersede older pending/follow-up wording, not the existing safety boundaries.

# R04 — Empty native FontString continuity correction

R03 native follow-up failed on confirmed r03.1: both indicators disappeared until refresh
completion. The screenshot showed an ordinary saved-view build, not a build-failure status.
A controlled local reproduction found that an intentionally blank icon-only gear label
returns nil under the documented native FontString contract. Previously that successful
read was misclassified as failure and discarded verified continuity/cache.

R04 normalizes only successful nil reads to blank **after** the existing ownership check.
Thrown reads and other invalid types still fail closed; warning recolouring, ownership,
cache revocation, collection handoffs and continuity policy are unchanged. Loaded Dashboard
build: `0.2.0-mvp+r04.1`, in the existing Shift/status tooltip; header/layout/TOC unchanged.
This is a deterministic local API-contract reproduction, not a native call trace or a
claim that the user's client symptom is fixed.

`lua5.1 tests/fontstring_continuity.lua` exercises native-compatible blank labels with
actual Dashboard/Storage and collector callbacks, including failed closed-profession Scan,
ordinary pending builds, invalid reads and reentry. It is synthetic evidence only.
Implementation, independent review, primary acceptance and native gates are recorded in
[R04 run state](../../TASKS.md#r04--empty-fontstring-read-incorrectly-invalidates-continuity).
After local acceptance, only focused ordinary-refresh dot/coherent-Concentration feedback
is needed. No repeat screenshot/version interview, profession checks/dumps, spending,
gear changes, installation or Git action is authorized. Native trigger/cadence/latency and
estimate accuracy remain unknown; full native INCOMPLETE87/149 and all-rank UNVERIFIED stay.

All earlier documentation below is preserved history; this narrow correction does not
supersede R03's safety boundaries or infer native acceptance from local tests.

# R03 — Verified collection-handoff continuity

R03 follows the user-confirmed loaded R02 build's continuing dot/estimate flicker. It adds
private collector transition evidence, not a general permission to ignore revisions or
tokens. A pending build may hand off once to the existing guarded replacement path;
at most twelve cached visible rows are independently checked against the current active
source, generation, options and player identity. Unknown, unsigned, stale or malformed
handoffs retain fail-closed behavior. No collection schedule, event list or timer cadence
changes. The loaded Dashboard marker is `0.2.0-mvp+r03.1` (Shift-hover the status line).

An unchanged valid projection keeps its frozen paint. A renewed successful Concentration
observation can instead replace the **whole cell** coherently using its new observed amount
and one estimate at the existing shared Render clock, then freeze that private display
until a verified successor or normal publication. It never overlays old cyan on a new
observation. At the exact observation time, zero additional gain correctly means blue-only;
full observed capacity is green. Invalid clocks/rates and failed/unknown observations do
not invent regeneration. The identity dot remains independently guarded.

Pending rows, status, hovers, fresh-warning demotion and disabled actions/Details remain
historical even when the replacement cell is visible. Predictions never alter saved data,
rows, sorting or attention. All prior documentation below is preserved history; R03 narrowly
supersedes the old changed-observation blanking rule, not its safety boundaries.
Current implementation/review/primary/native gates are recorded in
[R03 run state](../../TASKS.md#r03--collection-handoff-continuity-follow-up).
Additional local runner: `lua5.1 tests/collection_continuity.lua` uses actual production
collection callbacks with synthetic APIs/widgets, not native API/order/latency proof.

Only after local acceptance, observe ordinary dot/cell continuity and report the result or
any error; a truthful zero-gain blue-only renewal is not itself a missing-cyan failure.
No repeated loaded-R02 marker check, profession checks/dumps, spending, gear changes or full
native suite timing chase. Native trigger/frequency/latency and estimate accuracy remain
unknown; full native **INCOMPLETE87/149** and all-rank **UNVERIFIED** are unchanged.

# R02 — Guarded refresh continuity

Ordinary incremental refreshes may preserve the **last successfully painted** current-player
dot and approximate Concentration segment/label on the twelve visible widgets. This is a
private, frozen display-only exception to older unconditional retained=observed-only wording
below, not a live read or a fresh observation. Current validation, independent review and
primary/native acceptance are separate gates in the
[R02 run state](../../TASKS.md#r02--safe-refresh-continuity-for-estimate-and-current-player-dot).

The dot requires unchanged current GUID, options/source and the same supported active
generation. The estimate additionally requires exactly unchanged successful Concentration
observation/time/currency/amount/cap/rate provenance. A new Concentration observation can
remove the old estimate while the same-generation identity dot remains. Publication paints
the replacement normally. A backward/invalid estimate clock drops the projection without
removing an otherwise valid identity dot; rejected cache estimates cannot revive before a
successful normal paint. Pending values are not recalculated, saved, sorted or filtered
as predictions. Pending status, historical hovers, disabled actions/Details and fresh-warning
demotion remain in effect.

Changed filters/View/order/GUID, invalid/detached source, removed/archived/replaced rows,
hidden/combat/unknown safety, missing completed paint, explicit cancellation, generic
retention or failures do not borrow old decorations. Reused/scrolled widgets without a
matching cached paint fall back safely. The ready 30-second estimate repaint and scrolling
cadence are unchanged. Synthetic callback tests do not establish the native trigger,
refresh frequency, latency or measured offline estimate accuracy.

# P03 — Profession N/A, gathering colours, Deftness and enchant warnings

The accepted eight-profession crafting dashboard is preserved. P01 adds Herbalism,
Mining, Skinning, Cooking and Fishing registry/collection/display support, not blanket
native acceptance of all new fields. Implementation/local fixtures, independent review,
primary acceptance and user-run native evidence are separate gates; see current
[P03 run state](../../TASKS.md#p03--profession-na-colours-deftness-and-gathering-enchant-warnings).

**P02 locally accepted2026-11-19:** independent static review PASS/no findings plus
separately attributed PRIMARY full local suites/preservation PASS. Independent execution
remains NOT RUN after shell denial. [Review and limits](expansion-p02-review.md).
P03 implements the four approved follow-ups below, now focused-user-confirmed. Current
validation/acceptance is in TASKS; broader unreported new-profession native checks remain
partial. No repeat captures or accepted feature checks are needed.

- Own learned primary2 plus Fishing/Cooking roster presence is guarded; missing reads
  never prove unlearning or automatically retire snapshots. New rows require usable
  observed Midnight skill/cap and coherent own ready profession context.
- `—` means **confirmed Not applicable**, never unknown/zero: all five new Concentration
  fields; Cooking/Fishing Moxie, Knowledge and Unspent KP; Cooking accessory2; Fishing accessories.
  No numeric sort key, estimates or field-specific attention comes from those cells.
  Cooking/Fishing nonmax Skill still matches **Skill below max**.
- Cooking uses Tool26/accessory27; Fishing uses **rod28 only**, even if29/30 are returned.
  Fishing hats in regular Head are not profession gear. Unmapped/absent applicable roles
  remain unknown, not confirmed empty. Reused N/A cells clear old item decoration/links.
- P02 activates gathering Moxie3260/3264/3265, native Knowledge spend3778/3784/3889 and
  independent observed Unspent KP. Finesse/Perception intrinsic Tool keys provide F/P
  letters through the existing enchant-neutral query; raw totals/enchant metadata stay
  separate. P03 adds guarded Deftness recognition/D letter from the evidenced raw key.
  Its screenshot does not separately prove a native enchant-neutral query result or build.
  Ordinary own ready, unstaged scans use existing
  guarded native-rank reconciliation, not verified future/all-rank costs. Failed reads
  retain coherent values and independent times. Cooking/Fishing Moxie history is masked
  read-only until an ordinary successful own N/A scan supersedes that active field.
- Gathering Knowledge bars use the observed native profession/tab IDs for blue/green/orange
  identity, independent of tree position or localized name; unknown IDs remain neutral.
- Herbalism/Mining/Skinning Missing-enchant attention now uses existing confirmed ready-Tool
  absence and freshness rules; unknown/loading/absent Tools do not invent missing enchants.
  Retained absence is last-observed, not fresh proof; archived rows have no attention.
  Cooking/Fishing warning eligibility remains **pending**, not enabled or confirmed N/A,
  even when a Tool's actual observed enchant state is displayed. No new enchant IDs/amounts.
- Moxie reported max0 is not a usable cap: show actual balance, never clamp to0 or show
  balance/0. Saved base Skill/cap and modifier stay separate, including Skinning105/105
  and modifier40; no universal100cap or sample-character balance defaults.
- Normal valid gear hovers stay native/third-party-only; N/A fallback is concise. Shift
  retains provenance and masked historical diagnostics. No layout/control redesign,
  storage reset/migration, offline collection or forced old-profession rescan is needed.

## Focused R02 normal use after local acceptance

1. During ordinary dashboard use, with a current-character crafting row and an already
   valid cyan estimate visible, observe whether the dot/estimate unnecessarily disappear
   and return across an ordinary refresh. Report the visible result and any error; no
   spending, gear changes, forced rescan or timing chase is requested.
2. Pending rows remain last-observed/noninteractive, even when eligible decorations stay
   visible. Real new observations or unsafe contexts may legitimately remove an old
   estimate/dot. Keep snapshots; report an unavailable refresh instead of resetting data.
3. Do not repeat accepted profession values/reports, P03 features, old crafting checks or
   full native suites. Gathering evidence and P03's four focused behaviors are already
   accepted. Secondary enchant-warning eligibility stays pending; `/ca knowledgecapture`
   remains read-only evidence, not an activation switch or saved scan.

Local regression runners: `lua5.1 tests/refresh_continuity.lua`,
`lua5.1 tests/profession_completion.lua`,
`lua5.1 tests/gathering_activation.lua` and
`lua5.1 tests/profession_expansion.lua`, additional to the
unchanged full legacy runner/supplements and diagnostics. Pure fixtures/mock widgets are
not target-client API/font/timing proof. Full native suite remains **INCOMPLETE87/149**;
all-rank costs **UNVERIFIED** and quantified offline estimate accuracy unverified.

---

# U15 — Concise tooltips locally accepted; focused C5 user-confirmed

**Dashboard user sign-off2026-11-18:** current dashboard milestone accepted. No further
routine checklist/retest requested; known evidence limitations remain documented. User
requests GitHub Arbixal/craftarmy setup before starting guide work.

Normal equipped Tool/Accessory hovers now show **only the native item tooltip**, preserving
third-party additions. CraftArmy stats/enchant/expansion/rarity/quality/timestamps are under
**Shift-hover**. No-link/unknown/empty slots have a concise fallback, not an old item link.

Removed routine Observed-age/Attention/Shift-diagnostics-hint prose from normal summaries.
Concentration keeps observed value, explicitly `~Estimated now`/time-to-full or unavailable
reason; its long assumptions sentence is diagnostic-only. Real unknown/stale/archive/
pending/blocked cues and full provenance remain; no native/user text filtering or data change.

C4/window and C6/Cancel are user-confirmed. Independent scoped-static/PRIMARY512/all19U07/
744K6/565K7/23/Python/preservation PASS. [Review](tooltips-u15-review.md). User confirms
cleaner tooltips and Shift diagnostics as before2026-11-18. Focused C5/U15 accepted;
no repeat update/retest/scan/fullselftest. Exact dismissal/scroll procedures not separately
reported; no broader native proof inferred. Next is explicit overall dashboard sign-off,
not automatic guide implementation. [Checklist/results](completion-checklist.md).

---

# U14 — Moxie snapshot brightness and scrollbar corrections locally accepted

Known Moxie **above600 now uses the same green brightness** for current scans, snapshots,
stale/retained and archived values. Unknown stays neutral;600/below stays white. This is a
value cue only: field freshness remains in tooltips and archived attention stays excluded.

Scrollbar drag now combines native value events into one latest-target paint per frame;
unchanged offsets skip redraw, wheel changes stay immediate and cancel pending drag.
Thumb is solid/opaque, without padded knob artwork. Native range, geometry, proportional
size, row count and12-row reuse are unchanged. PRIMARY same-source synthetic100 repeated
offset requests dispatch1Render, not100; this is NOT native timing or endpoint proof.

Independent scoped-static and PRIMARY512/all19U07/744K6/565K7/23/Python/exact-target/
preimage/40-input preservation PASS. [Review](scroll-u14-review.md). User confirms **Moxie
color looks good, scrollbar reaches full bounds and performance is good**2026-11-18.
Focused U14 acceptance complete; no further update/retest/scan/fullselftest requested.

U13 current-first/dot, Moxie alignment/no!, observed-versus-estimated distinction,
sorting/filtering and row count already have focused user acceptance. Scrollbar visibility/
draggability and the U14 performance/endpoints correction now have focused user acceptance.
Do not repeat accepted checks because older delivery instructions remain below.

---

# U13 — Dashboard refinements locally accepted; focused native PARTIAL

- **Moxie:** centered/no `!`; green strictly above600 (U14 supersedes historical dimming).
- **Concentration:** blue last-observed portion plus cyan estimated gain; approximate
  total prefixed `~`. Confirmed full remains green; projected full remains estimated.
  Invalid estimates/archives/temporarily retained views fall back to observed-only.
  Locally repaints every30seconds while visible/ready/out of combat; no scans or live alt
  reads. Sorting/attention/saved values use observed amounts, never projections.
- **Scrolling:** draggable right-side scrollbar + mouse wheel, row-range footer; Previous/
  Next removed.12 visible reused rows, no character cap. Slider hides when all rows fit.
- **Current character:** eligible saved profession rows first after filtering; sort within
  current/other groups. Small green dot after the name. Group scrolls normally, not sticky;
  identity does not mean fresh observations. No missing rows invented or filters bypassed.

Column/icon/bar dimensions and accepted Gear gaps unchanged; only16px scrollbar rail added
(1184px window). Independent scoped-static PASS; PRIMARY512/all19/744K6/565K7/23/Python/
exact-target/test-preimage/39input checks PASS. [Review](refinements-u13-review.md).

With WoW closed update the whole CraftArmy addon folder, keep SavedVariables, then restart.
On existing snapshots check Moxie/estimated portion/dots/current grouping/scrollbar drag.
No profession scan/reset/fullselftest required. Native appearance/drag/font fit still
pending. Use [completion checklist](completion-checklist.md), especially C2/C3/new C7;
already confirmed fixes stay accepted. Earlier pending procedures below are historical.

---

# U12 — Tool-letter sizing and outer Gear padding locally accepted

**Current next step:** [Dashboard completion gap checklist](completion-checklist.md).
Remaining normal-use checks only; accepted visual/storage/redraw checks stay accepted.
Use current saved rows; no scan, reinstall, full selftest or confirmed deletion requested.
Checklist prepared2026-11-18; user results/dashboard sign-off still pending.

The Tool letter now uses natural text sizing instead of a fixed18×18 box, retaining its
14px outlined font and position. This addresses the reported Multicraft `...` constraint
without changing stat attribution. User confirms **M is visible**2026-11-18.

Added **6px outer padding on each side of Gear**. Icons remain24px in28px rows, with4px
internal icon gaps unchanged; Skill/Concentration bars keep their widths. Gear header96px,
content1138px/window1168px (+12 only), no stretching or Gear sorting.

Independent scoped-static and full PRIMARY512/all19U07/744K6/565K7/23/Python/preservation
checks PASS. [Review](gear-u12-review.md). User says **“M is visible and the gaps look
great.”** Focused U12 appearance accepted; no further check/scan/reset/fullselftest needed. Red borders,
Resourcefulness R and internal icon spacing already have focused user acceptance.
Older delivery checks below are historical and do not require another metadata scan.

---

# U11 — decorated-link correction and smaller gear icons locally accepted

Gear now uses **24px icons in28px rows**, with4px icon gaps horizontally and vertically
(26px borders,2px border gaps). Gear heading84px; dashboard48px narrower again, no stretch
or Gear sorting. Quality stays foreground/top left, Tool-only letter larger/central,
positive E top right; no Stat/Enchant columns. Skill/Concentration/Knowledge unchanged.

Fixed a locally reproduced parser defect: quality/texture/color markup inside a crafted
item's display label prevented optional expansion and Tool-only stat queries. Labels are
now ignored safely while exact item payload/modifiers remain intact. No guessing, schema
change or new API; existing snapshots and same-instance failure retention preserved.

Independent scoped-static PASS; PRIMARY512/512/all19U07/744K6/565K7/23/Python and exact-
target/preimage/39-input/media preservation PASS. [Review](gear-u11-review.md).

## U11 focused check for the reported missing metadata

User reports missing Khaz Algar red borders/Tool letter even after an updated U10 scan,
with expansion unknown/own-stat unavailable; quality/E work. This is not assumed cache-only.
The parser defect is corrected locally, but native cause/fix and24px appearance remain
unverified. With WoW closed, update whole CraftArmy folder, preserve SavedVariables and
restart. On one affected character, do an ordinary profession scan and check the red
border/Tool's own letter and tooltip metadata; also inspect smaller icons/equal gaps.
No reset/account-wide rescan/full-client selftest needed. If metadata remains unavailable,
report the tooltip lines/freshness; no speculative native PASS claimed. No agent install.

---

# U10 — gear icon redesign locally accepted

Historical U10 dimensions below are superseded by U11 above.

Gear now has28px icons in32px rows, rarity borders (red overrides rarity for confirmed
older-expansion items), quality top left, positive-only green **E** top right and a
larger centered **Tool-only** stat letter. No accessory stat letters. No E can mean
unenchanted or unknown; tooltip distinguishes them. One **Gear** header, no Gear sorting;
visible Stat/Enchant columns removed and dashboard250px narrower, not stretched.

Full item/rarity/quality/stat/enchant information remains in native/normal/Shift hovers.
Tool letter uses an enchant-neutralized link preserving crafted modifiers; it never
uses enchant category or a guessed primary stat. Optional item expansion/tool stat comes
from ordinary own-character scans. **Existing snapshots remain intact:** if metadata
is missing/ambiguous, no letter or older-gear classification is invented. Failed optional
reads retain known metadata only for the same equipped instance, with its own timestamp.

Renewed scoped-static PASS (quality-layer finding resolved); PRIMARY512/512/all19U07/
744K6/565K7/23/Python and exact-target/preservation PASS. Native new API/appearance/input
still NOT RUN. [Review/acceptance](gear-u10-review.md).

## U10 focused user check

With WoW closed, update the whole `CraftArmy` folder; preserve SavedVariables and restart.
Open `/ca` with cached rows: check size/fit, icons/borders/badges, no separate Stat/Enchant
columns, non-sortable Gear, normal/Shift hovers and row selection. New metadata fills on
ordinary own scans; on a character you normally refresh, check Tool letter matches the
tool itself even when enchant differs, and known older gear gets red border. If metadata
is unavailable, blank letter/normal rarity border is expected, not data loss. No forced
account-wide rescan/reset/full-client selftest or repeated accepted U09 check needed.
No agent installation/release performed. Guides/predicted Concentration bar remain deferred.

---

# U09 — Concentration bar and tooltip estimates user-confirmed

Concentration now has a flat observed-value bar: blue below capacity, green when full,
centered current/max and no `!`. Unknown cap stays neutral/unfilled.90% attention filter,
default priority and numeric sorting still use observed data, not predictions.

Normal hover adds **Estimated now** and **Estimated full in**, calculated from the saved
recharge rate and successful observation time. Clearly approximate: assumes no spending
and unchanged rate, not a live offline read. Re-hover recalculates; bar stays observed.
Missing/invalid metadata/time or archived snapshots show **Estimate unavailable** while
retaining observed information. Shift remains observed diagnostics; no timers/scans.

Independent scoped-static PASS; PRIMARY512/512/all19 U07 workloads5/10/2/2,744K6/565K7,
diagnostics23/23, Python and exact-target/preservation checks PASS. User “Everything looks
good and as expected” accepts the focused bar/tooltip result. No measured offline accuracy
or unreported procedures inferred. [Review/acceptance](concentration-u09-review.md).

## U09 focused user check — accepted; reference only

Feedback above accepts the reported result; these steps are reference, not a repeat request.

With WoW closed, update the whole `CraftArmy` addon folder, keeping SavedVariables intact.
Restart/open `/ca` with existing snapshots. Check the bar/no!, normal-hover estimate/ETA
and normal cell hover/selection. Re-hover later: estimate may grow, observed bar must not.
If recharge metadata is absent, unavailable is expected; no forced rescan/reset/full-client
selftest needed. During ordinary play, a later native amount can help assess prediction
accuracy, accounting for any spending. No exact offline phase/rounding guarantee yet.
No agent installation/publication performed. Combined gear redesign remains next; predicted
bar/filter/sorting remains deferred.

---

# U08 — title-bar icon appearance user-confirmed

The dashboard now shows the supplied22px icon at the top left beside its unchanged
title. Only title position/width changed; optional loading failure keeps the plain title.
Independent scoped-static review and PRIMARY512/512 dashboard cases +all19 U07 workloads,
744K6/565K7,23/23 and both Python checks PASS. User “It looks good” confirms focused
icon appearance; no unreported drag/close procedures or timings inferred.
[Review/acceptance](title-icon-u08-review.md).

## U08 focused user check — accepted; reference only

With WoW closed, update the whole `CraftArmy` addon folder, including `Media/Icons/`.
Keep SavedVariables intact; restart WoW and open `/ca` using existing snapshots.
Confirm the top-left icon looks right, and normal title-bar dragging/close still work.
Feedback above accepts appearance; these steps are reference, not a repeat request.
No rescan or full-client selftest needed. No agent installation/release performed.
Next is Concentration bar green when full, then one combined gear redesign: near-row-height
icons, rarity borders, top-left quality badges, merged **Gear** header and older-expansion
warning. Red border instead of old red background is the user's proposed direction;
final treatment/reliable classification remain to settle. Not implemented here.

---

# U07 — Skill indicator/filter refinement user-confirmed

Icon pack now packaged under `CraftArmy/Media/Icons/`:
[asset manifest/texture paths](../../CraftArmy/Media/Icons/README.md). Nine exact copies
of user-supplied root media assets; originals preserved. U08 now uses the main64px TGA
in the title bar; appearance user-confirmed, no TOC branding metadata. Other variants
and PNGs remain supplied assets, without conversion.

User confirms “Yes it all looks good” after the focused marker/filter check. Accept
that round at reported scope; no routine repeat or broader unreported timing/API proof.

**2026-11-17:** Skill now shows plain current/max over its bar, with no `!` attention
prefix. Attention option **Skill below max** replaces visible Progression and selects
only known saved Skill below its positive known cap. Knowledge cannot add rows to this
filter; unknown/equal/above-cap Skill is excluded. Stale known values remain last-observed.
Archived rows stay excluded from attention filters; Archived+All remains available.

Concentration/Moxie/missing-enchant indicators, combined default attention ordering,
Knowledge diagnostics, bar colors/sorts and R01 retention behavior are unchanged.
Primary512/512 top-level cases, all19 U07 workloads in4 groups, unchanged744K6/565K7,
diagnostics23/23/Python PASS; independent scoped-static PASS. Runner/caps unchanged.
Three source files changed: Dashboard, ViewModel and SelfTests. No schema/migration.
[Review/acceptance](skill-u07-review.md).

## U07 focused user check

Update your `CraftArmy` folder while WoW is closed, keeping SavedVariables intact/backed
up as usual. Using cached rows, confirm Skill has no `!` and **Skill below max** excludes
max Skill even when Knowledge is incomplete. Switching back to All should restore those
rows. No rescan/capture/IDs/fullselftest or routine redraw retest needed. This focused
native feedback is now accepted above; these steps remain reference, not a repeat request.
No agent installation or release performed.

Concentration bar and older-expansion red gear remain queued, not implemented here.

---

# U06 — Skill bar focused user check accepted; refinements requested

Historical U06 section below; current Skill marker/filter semantics are U07 above.

User says everything looks good, then requests removing Skill's `!` and suggests a
non-max-Skill filter instead of combined Progression. Focused Skill-bar feedback accepted
at the reported scope; those follow-up changes are not implemented yet. No repeat check.

**2026-11-17:** Skill now has a flat progress bar in its existing column, centered
current/max numbers, smooth red→amber→green and full green at maximum. Uses saved skill/
observed cap only, never adds equipment/skillModifier bonuses. Unknown/unusable cap keeps
a neutral unfilled `?`; known zero remains0/max. Existing warnings, tooltips, sorting,
freshness and accepted R01 retained-table behavior are preserved.

Primary508/508 dashboard +unchanged744K6/565K7, diagnostics23/23/Python PASS; independent
scoped-static PASS. Exact target/preservation proofs primary-attributed. All488 previous
cases retained verbatim plus20 new. Only Dashboard and additive SelfTests source changed;
no schema/migration/new APIs. [U06 review/acceptance](skill-u06-review.md).

## U06 user-managed update and focused visual check

Update the `CraftArmy` addon folder with this project's current copy while WoW is closed;
keep SavedVariables intact/backed up as usual. No agent installation or reset/migration.
Using existing cached snapshots, check Skill fill/color and centered readable current/max
text (including any `!` warning). Check normal/Shift hover and row selection over both
filled and unfilled bar areas. No new scan/capture/ID/fullselftest or routine redraw retest
is needed. Focused user feedback has now been received above; these instructions remain
reference, not a request to repeat the check or infer unreported procedure details.

Concentration bar and older-expansion red gear remain separate/queued. Broader native
acceptance stays partial; fullnative INCOMPLETE87/149/allrank UNVERIFIED unchanged.

---

# R01 — redraw visibility confirmed in game

**User confirmation 2026-11-17:** table no longer disappears during scans or profession
window open/close. Targeted redraw symptom resolved; no routine redraw retest needed.
This does not infer unreported hover/action recovery, error/freeze absence or measured
timing. Skill/Concentration bars and older-expansion red gear remain next, not built.

**2026-11-17:** populated rows now remain visible while an incremental replacement builds.
The retained table is explicitly **previous saved view / last observed**; fresh markers
are muted, detailed row/item hovers and row/lifecycle actions temporarily unavailable.
Only a complete current replacement is displayed; identical running requests coalesce.
Failure retains safe prior values with a retry message. Actual filter-empty/deletion or
unavailable/replaced storage is not concealed by resurrecting older rows.

Primary488/488 dashboard +unchanged744K6/565K7, diagnostics23/23 and both Python checks
PASS. Independent renewed scoped-static PASS, both findings resolved; execution and
source-preservation proofs primary-attributed. No schema/migration/collector/budget change.
Only `Dashboard.lua` and additive `SelfTests.lua` source changed. See
[R01 review/acceptance](redraw-review.md), [current tasks](../../TASKS.md).

## R01 user-managed update and focused check — reference

The visibility check was reported above. Keep these instructions for upgrade/recovery;
their presence is not a request to reinstall or repeat an already confirmed check.

1. With WoW closed, back up SavedVariables as usual and replace your `CraftArmy` addon
   folder with the updated project folder. **Keep SavedVariables intact**; R01 introduces
   no migration/reset. Diagnostics unchanged. No agent installation performed.
2. Open `/ca` with existing snapshots. Open and close your own profession a few times,
   then do one normal Refresh/scan. Confirm the populated table stays visible while
   updating, new values appear when ready, and no errors or freezes occur.
3. Retained rows/actions/hover behavior above is intentional only during replacement;
   normal row interaction should return afterward. Report persistent blanks, stuck
   updating/error status or interaction that does not return; do not reset saved data.

Focused native visibility is confirmed above, not a measured latency guarantee. No
Knowledge capture/ID discovery/fullselftest/storage-retention repeat requested. Follow-up
Skill/Concentration bars and older-expansion red gear are queued, not implemented here.
Broader native acceptance stays partial; fullnative INCOMPLETE87/149/allrank UNVERIFIED.

---

# S01 — refresh/retention confirmed; dashboard redraw issue open

Historical S01 delivery below; current redraw implementation/gate is the R01 section above.

**2026-11-17:** implementation, primary validation/comparison, independent scoped-static
review and post-review source freeze complete. Both reviewed findings resolved. Local
dashboard463/463, unchanged744K6/565K7, diagnostics23/23 and both Python checks PASS.
Independent execution/comparison was unavailable; those proofs are PRIMARY-attributed.
User now confirms scans succeed on multiple previously blocked characters and older
snapshots remain correct. That focused refresh/preservation check is accepted; exact
migration/reload procedures and measured performance were not separately reported.
The table often disappears/reappears, particularly opening/closing professions: redraw
usability remains open, with no snapshot loss reported or established cause/fix.
User requested task-file cleanup before continuing; no new update/scan/capture/selftest
round or redraw code change requested now. [Current work](../../TASKS.md) and
[review/acceptance](s01-review.md) supersede older pending gates below.

The new schema shares immutable profession definitions and stores personal allocations,
locks/states, equipment/currencies and independent snapshot times in bounded records.
Raw acquisition proofs remain temporary; live validation is unchanged. No fixed character
cap:46/100/200characters with two professions each are tested workloads, not ceilings.
The whole account no longer has the small50000-value traversal limit; individual record,
primitive and scheduled-work checks remain. Archives/Details/unknowns are preserved.

## User-managed update and focused check

Reference procedure for upgrades; the focused scan/older-snapshot check was already
reported above. Do not repeat it or reinstall merely because these instructions remain.

1. Exit WoW and **back up CraftArmy's SavedVariables** before this schema upgrade.
2. Replace the **entire `Interface/AddOns/CraftArmy` folder** with this project's
   `CraftArmy` folder, including its TOC and all11 Lua files (`Storage.lua` is new).
   Keep SavedVariables intact; do not reset or mix old/new modules. Diagnostics unchanged.
3. Relaunch. Initialization/migration runs automatically in bounded batches. Wait for
   saved storage to be ready; `/ca storage status` explains pending/failure state.
4. On one previously blocked character, open your own profession and run `/ca scan`.
   Confirm refresh succeeds, older character/profession snapshots remain, and the normal
   dashboard remains usable. Existing fields should not need rescanning to recover values.

Migration builds/validates separately and leaves the original root unchanged on failure
or cancellation. If blocked, stop and report `/ca storage status`; do not delete data.
Explicit `/ca storage cancel|retry` controls initialization only, not gameplay. Older
schema1-only addon versions cannot write schema2: downgrade requires the matching addon
and pre-upgrade SavedVariables backup, not editing the schema number.

Batching performs at most16 indivisible Steps while observed time remains below2ms
between units; one unit can overshoot. Absent clocks use explicit one-Step fallback.
No native latency guarantee is claimed. No Knowledge captures/ID discovery/fullselftest
sequence requested. Fullnative remains INCOMPLETE87/149, all-rank costs UNVERIFIED.
No agent-installed files, private SavedVariables access, Git publication or release.

---

# S01 piece9 — locally corrected; BLOCKED until renewed scoped review and acceptance

**2026-11-17: no addon update/installation advice.** Renewed scoped-static review resolved
catalogue ownership but found a stale startup failure callback overwriting a replacement
retry's pending status; no root/snapshot loss was claimed. The exact combined clock-error/
Hide-retry test failed on old source before correction. Commands now uses a private startup
epoch and post-callback job/runtime checks across cleanup, setup, errors, finish and cancel.
Only that driver and new nested tests changed in source; no schema/native/budget change.

Local checks completed463/463 (all458 prior test bytes retained+5new), unchanged744K6/565K7,
diagnostics23/23 and both Python checks PASS. Equivalent source-drift/setup/cancel/entry
callbacks retain replacement job/batch/pending dashboard state; stale callbacks cannot
advance it, original root stays until correct replacement completion. These are fixtures,
not native API/responsiveness proof. Prior failures,458 result and both review findings
remain history; renewed review and primary acceptance are still pending.

Batching remains at most16 Steps and observed2ms BETWEEN indivisible units, explicit
clockless-one-Step fallback, no synchronous drain. One unit can overshoot2ms; no native
frame-time guarantee. Backups/rollback requirements below remain; no install/reset/eviction,
private DB read, native capture/selftest request, Git or release action performed.
Current evidence/proofs: TASKS and `/tmp/opencode/craftarmy-s01-piece9-artifacts`.
Full artifact delivery is permission-blocked (directory currently has check logs only);
read-only preservation hashes and exact primary resume prerequisite are recorded in TASKS.

---

# S01 piece8 — locally corrected; BLOCKED until renewed review and acceptance

**2026-11-17: no addon update/installation advice yet.** The independent review's medium
new-character catalogue-reuse ownership finding is corrected locally, with rejecting
graph/counter/token regressions. The prior PARTIAL/CHANGES REQUIRED result remains history;
primary actual recomparison, renewed independent verification and acceptance are pending.
All446 existing scenarios remain byte-identical;12 new cases bring the completed local
suite to458/458, unchanged744K6/565K7, diagnostics23/23 and both Python checks PASS.

Only startup and dashboard drivers now batch work: at most16 individual Steps per callback,
stopping when observed elapsed time reaches2ms between units. Prefer debugprofilestop,
then precise seconds*1000; absent native clocks explicitly use `clockless-one-step` mode.
A selected invalid/throwing/backward/overflowing clock fails closed instead of switching
clocks or synchronously draining. Guards run before/between work and before publication,
including cleanup gaps; cancelled/unsafe/superseded jobs cannot publish old rows or roots.
Individual Step/native/primitive limits, selftest/capture/Details schedulers and saved
schema2 format are unchanged. One indivisible unit can overshoot2ms: this is NOT preemption
or a promise every callback stays below2ms, and fixture clocks are not native timing proof.

Actual synthetic zero-clock drivers completed46/100/200characters×2 with startup34/72/140
callbacks and dashboard36/77/154callbacks. These are observed fixture callbacks, not a
calculated division or client responsiveness claim. Full counts, failure history, frozen
diffs/hashes and ownership proofs are in TASKS/evidence. Preserve backups and use the later
whole-addon manifest below only after review/acceptance; older schema1-only code still
requires its matching pre-upgrade backup for rollback. No reset, eviction or new cap.

No private SavedVariables read, game install, native capture/selftest request, Git operation
or release action occurred. Fullnative INCOMPLETE87/149/all-rank costs UNVERIFIED unchanged.

---

# S01 — local implementation complete; review and acceptance pending

**2026-11-16: do not update the addon from this revision yet.** Primary's contract5a
amendment is implemented; the earlier blocked report below is historical. Final local
checks completed **446/446** (all409 old test bytes preserved+37 additive S01 cases),
unchanged744K6/565K7, diagnostics23/23 and both Python structural checks PASS. Writer
comparison/retention proofs are recorded in TASKS and appended dashboard evidence.
Primary actual comparison, independent verification and primary acceptance remain separate
pending gates; local fixtures do not establish native API behavior or measured timing.

Schema2 shares immutable profession definitions while independently bounding each personal
generation/catalogue. Migration preserves field history, unknown/false/zero distinctions,
equipment and independent observation/Details/archive times. Raw diagnostic graphs are not
normally persisted: Shift-hover honestly identifies compact summaries. No fixed character
ceiling or raised primitive/native limits. Full rich fixture paths covered46/100/200alts×2,
compact accounts beyond50000aggregate values,17 historical tree fields and sparse archives.

Startup/migration and handle-backed display are frame-stepped. Pending/cancelled/failed
startup retains the original root and disables writes; `/ca storage status | cancel | retry`
controls initialization only. There is no automatic retry/reset/synchronous fallback. A
complete candidate is published only under source/runtime guards. Cached dashboard/Details
reads do not query profession APIs. After reload, explicit Refresh details needs a normal
complete own-profession scan to establish its ephemeral rich source; migration itself does
not require rescanning known dashboard values. Details scope/layout and Knowledge gates stay.

**Eventual full-addon manifest, only after review/primary acceptance:**
`CraftArmy/CraftArmy.toc`, `Core.lua`, `Storage.lua`, `Data.lua`, `Knowledge.lua`,
`Collectors.lua`, `KnowledgeCheck.lua`, `Details.lua`, `ViewModel.lua`, `Dashboard.lua`,
`SelfTests.lua`, `Commands.lua` (all Lua paths inside `CraftArmy/`). Use the matching full
folder; Storage loads immediately after Core. No diagnostic-addon update is involved.
Back up the complete SavedVariables before any future upgrade while WoW is not writing
them; preserve saved data, never reset or mix versions. Older schema1-only code cannot
write schema2: rollback requires the matching older addon AND the pre-upgrade backup,
not editing a schema number. No agent installed files or performed an upgrade/rollback.

No live storage test or further Knowledge capture/ID/fullselftest round is requested here.
Full native suite remains INCOMPLETE87/149; all-rank costs UNVERIFIED. No Git, publication,
release or installation authorization follows from these results.

---

# S01 — partial storage implementation BLOCKED; do not update from this revision

**2026-11-16: not ready for installation, review acceptance or native testing.**
The provisional schema2 migration and incremental display implementation is blocked on
a demonstrated contract conflict: a valid schema1 generation can retain9 tree fields,
but the settled record-Step dependency bound is8 definitions. All retained values must
survive; the writer has not chosen a cap, dropped history or relaxed that assertion.
Primary must settle this in the [S01 contract](storage-s01-contract.md) before resumption.
Current recovery point and missing tests: top S01 task in [TASKS](../../TASKS.md).

- All409 old scenarios are byte-for-byte retained. Final local run completed423 cases:
  422PASS/1FAIL (required dependency-budget regression), NOT a passing release gate.
- New native-derived growth fixtures reached46/100/200characters×2 rows through real
  Apply/migration/reload/iterator/view paths, including compact accounts above50000
  aggregate values. These are fixture sizes, not character caps or client timing proof.
- No source installed, saved data inspected/reset, live API test, Git or release action.
  Historical fullnative remains INCOMPLETE87/149; all-rank costs remain UNVERIFIED.

**Eventual update, only after completed implementation, comparison, independent review
and primary acceptance:** back up the complete SavedVariables before upgrading; use the
whole `CraftArmy` addon folder with its TOC and all eleven Lua files (including new
`Storage.lua` immediately after `Core.lua`). Diagnostics do not change. Preserve saved
data; never reset or partially mix old/new modules. This is a future manifest, NOT an
update request. No further Knowledge capture, identifier queries or fullselftest chase.

Schema2 stores shared immutable definitions and independently bounded personal records;
the proposed normal path migrates privately and replaces the saved root only after full
candidate validation. Pending/cancelled/failed startup disables writes and retains the
original root; `/ca storage status|cancel|retry` is the provisional job control. Missing
schedulers must not synchronously drain jobs. These paths are not yet fully verified.
An older schema1-only addon cannot write schema2: downgrade requires restoring the
pre-upgrade SavedVariables backup with the matching older addon, not editing the schema
number. See the appended [schema notes](schema.md) and [partial evidence](evidence.md).

---

# U05 — dashboard polish ready for focused visual checks

**Known blocker2026-11-16:** user reports most characters update correctly, but some
scans hit “Assembled snapshot exceeds bounded saved data limits”. Primary reproduced
this with valid full snapshots as the account roster grows; current50000-value budget
applies to the whole DB. Prior snapshots are retained on this rejection. **Do not reset
or delete saved data, raise limits or repeat scans/captures/selftests to work around it.**
Native U05 is PARTIAL; a separate storage-capacity correction must be designed/reviewed.
Actual user DB size is not measured. The earlier delivery/update procedure below is
historical for this report, not a request for another update or testing round.

**2026-11-16: implementation/local validation and primary acceptance complete;
independent bounded static review PASS, no findings.** Independent execution was
unavailable; executable/comparison proofs are primary-attributed. Native U05 visual/
control check remains NOT RUN. See [review scope](u05-review.md) and [evidence](evidence.md).

- Knowledge bars use four stable colors per profession/native tree ID (blue, green,
  orange, purple); unmapped IDs are neutral. Numeric labels, geometry, native order,
  locked capacity, unknown fills and normal/Shift hovers are unchanged.
- A1/A2/Tool cells and headings are centered. Name fonts use native class colors when
  optional saved `classToken` is available; old snapshots remain white. Only a normal
  guarded own-character scan learns class metadata; no offline class lookup or guessing.
- Historical attention loses only `~`: muted `!` still means last observed; fresh `!`
  remains amber. No threshold, warning, freshness, numeric/raw Knowledge gate or time
  changes. Snapshot display never makes old data current.
- View and Attention are native radio dropdowns. All14 headings select/toggle typed
  sorting with a separate direction indicator; unknown values stay last. Initial
  ordering remains attention-first. Filters/sorts do not collect or save UI settings.
  Unavailable menus explain their noninteractive All/Active fallback.
- Dashboard has a plain dark fill/solid border and HIGH priority. Existing close,
  dragging, paging and confirmed lifecycle actions remain; only its existing owned
  Details window is raised to DIALOG when opened successfully. Details redesign stays
  parked; its accounting/capture/layout sources are unchanged.

Local fixtures: **409/409** (all359 retained with exact approved UI/helper adaptations
+50 new U05), unchanged **744K6/565K7**, diagnostics **23/23**, both Python checks PASS.
Mocks are not native API/appearance/timing evidence. Full native suite remains
**INCOMPLETE87/149**; K09 focused acceptance remains intact, all-rank costs UNVERIFIED.

**Scoped update manifest (back up saved data before replacing files):**
`CraftArmy/Core.lua`, `CraftArmy/Collectors.lua`, `CraftArmy/Data.lua`,
`CraftArmy/ViewModel.lua`, `CraftArmy/Dashboard.lua`, `CraftArmy/SelfTests.lua`.
No diagnostic update, migration or SavedVariables reset. The next focused user check
concerns appearance/controls with existing snapshots, plus a normal
own-alt scan only where class metadata is absent. No repeated Knowledge captures,
identifier queries, accepted correctness rounds or full-client selftest requested.
No agent-performed installation, gameplay, Git or release approval is implied.

---

# K09 — focused numeric Knowledge validation complete

**2026-11-16: implementation/local fixtures, independent bounded static review and
primary acceptance complete. User confirms all values match expectations and behave as
expected following the requested focused dashboard round. No further routine Knowledge
updates or checks requested.** Independent execution was unavailable; local execution and
comparison proofs are primary-attributed. See [review scope](k09-review.md). This gate
supersedes historical Inscription-only numeric/raw-persistence statements below, not
the accepted K08 evidence or its limitations. All-rank costs remain **UNVERIFIED**.

Guarded normal scans now support numeric Knowledge/raw snapshots for the eight exact
Midnight crafting identities. Core owns the private identity/trait-currency resolver:
Alchemy4030, Blacksmithing3750, Enchanting4056, Engineering3903, Inscription3902,
Jewelcrafting3989, Leatherworking4085, Tailoring3736. These are **trait spend currencies,
not Moxie IDs**; live path reads must supply the correct currency. Purchased points
still exclude automatic unlock ranks, retain locked capacity and reconcile shared
spent once across complete unstaged same-scan metadata. No assumed caps/configs/tabs,
currency fallback or all-rank cost rule. See the dated K09 clarification in
[schema](schema.md) and actual local results/failure history in [evidence](evidence.md).

Typed-valid incomplete raw can persist independently while numeric trees remain
unknown/stale. Invalid/wrong-currency raw records an unknown no-value attempt, retaining
prior coherent raw and trees without aborting valid generic fields. Raw identity and
numeric evidence currency are bound to the owning active/archive generation. Independent
successful field observation times remain independent; no migration, reset or eviction.
Unspent KP still comes from its own live API; positive auxiliary currencies are not KP.
Details stays **Inscription-only**. Both evidence commands and their safety/privacy/
no-write behavior are unchanged; native bars still carry the existing accounting caveat
on Shift-hover. Normal branch hovers retain hierarchical individual X/Y labels.

Local validation: **359/359** (all309 retained with explicitly approved historical
assertion adaptations +50 new K09), unchanged **744 K6 /565 K7**, diagnostic23/23 and
both Python structural checks PASS. Complete eight-profession raw+numeric snapshots
fit **29793/50000** expanded values. These fixtures are not target-client API proof.
K09 focused user value/normal-use validation is **COMPLETE at the reported scope**.
Individual procedure steps, reload timestamps and quantitative timing were not separately
itemized; no detailed per-step or failure-path proof is inferred. Historical full native suite remains
**INCOMPLETE87/149**, not PASS and not a blanket prerequisite for this native slice.

**Delivered update manifest (reference only; no further update requested):**
`CraftArmy/Core.lua`, `CraftArmy/Knowledge.lua`, `CraftArmy/Collectors.lua`,
`CraftArmy/SelfTests.lua`. No SavedVariables reset, migration or diagnostic update.
No agent-performed game installation or release/publication is authorized.

**Completed focused-round request (historical; do not repeat):** one batched normal dashboard
comparison for Alchemy, Blacksmithing, Enchanting, Engineering, Jewelcrafting,
Leatherworking and Tailoring: tree X/Y/native order, branch hovers and Unspent KP;
report responsiveness/errors/warnings. Then a single closed-profession/reload spot-check
of a newly numeric snapshot's values/original observation times, without scanning it
again. No repeat of accepted generic fields, K08 captures, identifier discovery,
Inscription native checks or full selftest. The user's general expected-values/behavior
confirmation closes this bounded round without inventing a detailed execution trace.
No native checks are run on the user's behalf. This is K09 completion, not completion
of all dashboard requirements, guides or release approval.

---

# K08 — focused Knowledge evidence validation complete

**Complete2026-11-16:** all six batch reports are complete/stable/untruncated and
provisionally reconciled; all native tree/Unspent0 comparisons now confirmed. User
reports no errors/warnings and responsive UI throughout. Earlier Enchanting validation
is complete too. **No further captures, updates or selftests requested.** Numeric bars
still require separately specified implementation/approval/review; current production
accounting/raw persistence remains Inscription-only. Observed batch values, not defaults:

| Profession | Trees in native order | Total / capacity | Unspent KP |
| --- | --- | --- | --- |
| Alchemy (22paths) | Potion Prowess170/170; Fluent in Flasks141/170; Alchemical Mastery90/90; Transmutation Authority0/90 | 401/520 | 0 |
| Blacksmithing (30paths) | Craftsmithing80/105; The Old Ways33/120; Armorsmithing0/345; Weaponsmithing180/205 | 293/775 | 0 |
| Jewelcrafting (35paths) | Thoughtful Throughput73/120; Glamorous Gems0/310; Alluring Accessories150/150; Proficient Processor0/194 | 223/774 | 0 |
| Engineering (21paths) | Market Mobility103/225; Combat Analytics0/165; Recycling70/90; Bits and Bots30/90 | 203/570 | 0 |
| Leatherworking (32paths) | Learned Leatherworker73/120; Lasting Leather250/250; Safeguarding Scales0/250; Flawless Fortes0/150 | 323/770 | 0 |
| Tailoring (26paths) | Sin'dorei Finery0/300; Nimble Needlework130/130; Fabric Specialist80/80; Fiber Arts86/150 | 296/660 | 0 |

Their traitspendcurrencies are4030,3750,3989,3903,4085 and3736 respectively. Auxiliary3807/4008 each have
quantity1 but are NOT additional UnspentKP. Jewelcrafting's194capacity includes four
observed1-point spendentries, not a rounded/default cap. Engineering's165CombatAnalytics
capacity includes four35-pointbranches (including110352); auxiliary3983quantity1 is
notUnspentKP. Eight LastingLeatherauxiliarycurrencies quantity1 are also NOTUnspentKP.
**Leatherworking/Tailoring values plus Unspent0 and all-six batch behavior are now
explicitly confirmed.** No more reports, updates or recaptures needed. All-rank costs,
quantitative timing and unobserved failure paths remain unverified. Numeric/rawpersist
enablement remains a separate task, not an automatic effect of this evidence.
The original six-profession request below is historical, not a new request.

**Primary actual-baseline comparison/local checks PASS; independent bounded static-delta
review COMPLETE/PASS, no blockers (2026-11-15). Complete stable Enchanting capture
received:27/27paths, no truncation, provisional443/650 matches sharedspent443. User
confirms native tree/Unspent0 agreement, no errors and responsive capture. The focused
Enchanting evidence sequence is complete.** This current
gate supersedes historical Knowledge-capture instructions below, not their evidence.
E05's affected blank-enchant check is complete; no repeat is needed.

**Historical batch procedure — completed; do not repeat.** Use the already installed
`/ca knowledgecapture` once each for **Alchemy, Blacksmithing, Engineering,
Jewelcrafting, Leatherworking and Tailoring**. For each, open your own ready Midnight
profession out of combat with no staged changes, let automatic scans settle, then keep
it open/unchanged until the copy window appears. Send the entire BEGIN→END report
labeled by profession, confirm native tree points/capacities and Unspent KP agreement
(screenshots are fine), and note any errors/warnings/responsiveness issues. If refused
or INCOMPLETE, send the message instead of repeated runs. No fullselftest, spending,
identifier discovery, generic-field checks or Inscription/Enchanting recapture.

Accepted Enchanting values: Elevating Equipment83/270; Transitories, Tonics, and
Tools120/140; Disenchanting Delegate120/120; Spellbound Shatterer120/120; Unspent0.
Enchanting's observed traitspendcurrency4056 is distinct from Inscription3902 and
Moxie3258. Numeric bars remain gated; all-rank costs unverified. Review each remaining
profession's actual report before specifying accounting implementation; do not infer
one profession's currency/graph for another. The original Enchanting procedure below
is retained for reference, not requested again.

The separate **`/ca knowledgecapture`** starts an asynchronous, ephemeral evidence job
for the eight already registered Midnight crafting identities. It returns immediately
without stepping capture/format or scanning. Repeat the bare command or use
`/ca knowledgecapture status` for brief status; `/ca knowledgecapture cancel` retires it.
Other arguments print usage. Legacy **`/ca knowledgecheck` remains synchronous and
Inscription-only**; do not use it for Enchanting or other professions. Neither command
is a numeric-policy activation. Report version1/BEGIN/END headers retain their existing
`knowledgecheck` spelling for compatibility.

New capture requires an existing idle collector, own open ready unstaged profession,
explicit out-of-combat safety, usable monotonic clock and native Frame. Missing/pending
state means wait and manually retry: it never performs Login, Scan, saved-data validation,
timers or snapshot writes. Capture and format advance at most one bounded job unit per
OnUpdate callback, with separate phase/publication frames. Context/config/source/player
and runtime object/revision/serial are checked before/after work and publication. Any
event cancels first, then normal event processing continues (and may independently scan).
Explicit scan also cancels first; selftest/legacy capture overlap is refused.

Cancellation, drift, combat/unknown safety, errors, **>100ms measured callback** (including
last unit/copy publication), or **10000 total callbacks** stops INCOMPLETE, with no automatic
resume. Timing is post-return detection, **not preemption or proof of responsiveness**.
Previous successful evidence is retained in memory on failed retries but hidden, never
presented as the new result. Nothing is persisted across reload. Scheduler COMPLETE is
distinct from report `captureComplete`: incomplete metadata can still yield a useful
formatted evidence report with unknown reconciliation. Full coverage/ownership/cost/
currency/truncation guards remain; rank candidates/current unit costs are **provisional**,
and all-rank costs **UNVERIFIED**. Non-Inscription numeric Knowledge/raw persistence and
all existing snapshot/freshness/accounting gates remain unchanged.

Local evidence: **309/309** (all277 byte-frozen +32 additive K08), unchanged **744 K6 /
565 K7**, diagnostic23/23 and both structural checks PASS. Synthetic fixtures and
structural checks are not target-client API/accounting/native timing acceptance.

## Reviewed update / one Enchanting evidence capture

1. Quit WoW and back up the installed addon/account SavedVariables. If on E05, replace
   only **`CraftArmy/Commands.lua`, `CraftArmy/KnowledgeCheck.lua`,
   `CraftArmy/SelfTests.lua`**. Preserve saved data/unrelated files; agents do not install.
   If not on E05, overlay the current full addon preserving saved data/backups and the
   historical U03 rollback caveat below; do not mix unknown source revisions.
2. Open your own ready Midnight **Enchanting** out of combat, with no staged Knowledge
   changes. Wait for ordinary automatic scans/events to settle. Do not spend points or
   request another scan for this check.
3. Run **`/ca knowledgecapture`**. Keep the profession open and unchanged until the copy
   window appears. It advances over frames, not on the slash-command stack.
4. Copy the **entire BEGIN → END** report, including END SUMMARY. The version1 header
   still says `knowledgecheck`; that is report compatibility, not the command to run.
   Supply native tree investments/capacities and Unspent KP too (screenshots are fine),
   and report whether it stayed responsive and any errors/execution warnings.

If refused or INCOMPLETE, send the exact message rather than repeatedly retrying or
running the full selftest. Use `/ca knowledgecapture status` for status or
`/ca knowledgecapture cancel` to stop. Do not close/switch professions or run `/ca scan`
during capture; events or drift conservatively cancel with no automatic resume.

Review this first profession's report/native comparison before batching others using
the existing identifiers. No spending, reload/cache tests, repeated accepted generic
fields/Moxie, new ID discovery, or full native selftest. This evidence does not enable
numeric accounting. Details improvements, guides, broader native/API acceptance and
release remain separate. Independent executable/hash/full-tree verification was
unavailable; the successful local commands and comparison/hash proofs are primary-
attributed. [Bounded review scope and limitations](k08-review.md).

---

# CraftArmy 0.2.0-mvp — snapshot dashboard

**PARTIAL, not released/accepted.** Read [evidence](evidence.md) before testing.

## E05 — empty enchant-field fix verified

**Hash-anchored source comparison and independent scoped static review PASS/no findings
(2026-11-15 continuation). User confirms the affected unenchanted tool now has a blank
Enchant cell instead of `?`. Focused E05 validation is complete; no further update or
retest is requested.** This current gate supersedes the E04 investigation
and historical empty-field-is-unknown descriptions below, retaining their evidence.
The affected diagnostic says `Enchant: unknown; invalid/missing enchant field`.
Its fresh Enchanting rod screenshot supports parser investigation, not proof of the
exact raw item-link payload; its Resourcefulness tool stat is not enchant evidence.

Documented item links omit zero-valued fields. A ready `item:95020::0` has an explicitly
empty, delimited enchant field and now means observed ID0/no enchant, just like
`item:95020:0:0`, unless a typed-positive enchant line conflicts. Missing delimiters,
nil/malformed/overflow/unready/conflicting data remain unknown (`?`), never a zero
fallback. Positive known IDs retain full categories; unmapped positives remain `?`.
Whole-tool metadata readiness/freshness gates, schema and UI are unchanged. Core's
same-instance enchant syntax guard now accepts the same explicit-empty form, so an
identical slot/item/full link retains the coherent known snapshot and its original
successful time on transient stats/quality/loading failure. Exact identity/link
equality and existence requirements remain unchanged; changed/missing/malformed
instances cannot borrow old metadata. No link normalization or subfield borrowing.
Initial273-pass parser-only delivery missed this integration path and was not accepted.

Production changes are only `Collectors.lua`'s two parser/conversion lines and
`Core.lua`'s one same-instance syntax pattern. `SelfTests.lua` adapts one obsolete
valid-empty expectation and adds13 E05 cases. Three new preservation cases first
failed against unchanged Core, then passed unchanged after the one-pattern fix.
Local **277/277 +744 K6 /565 K7** passes are synthetic correctness evidence, not a
native blank-display/API result. Full native selftest remains **INCOMPLETE87/149**.
No saved migration or API reads on cached/offline/hover views: old saved unknowns
remain `?` until a normal ready own-profession scan supplies a new observation.

### E05 delivered update / native check — historical procedure

Quit WoW and back up the installed addon/account SavedVariables. If on E04, replace
only **`CraftArmy/Core.lua`, `CraftArmy/Collectors.lua` and `CraftArmy/SelfTests.lua`**.
Otherwise overlay the complete current CraftArmy folder preserving saved data/unrelated
files and backups; retain the U03 rollback caveat linked below. Agents do not install.

Open your own ready Midnight Enchanting out of combat with the known-unenchanted rod,
run `/ca scan`, then `/ca`. Its Enchant cell should be **blank**, not `?`; report any
remaining unknown, mismatch, error, execution warning or unresponsiveness. The focused
blank-display result is now user-confirmed. No repeat accepted field/Moxie/cache/reload tests, extra enchant-
ID discovery, full native suite or Details refresh. No release approval.

Restart recovery: original temporary whole-tree snapshot/logs were lost. Exact Core,
Collectors and SelfTests preimages were reconstructed and matched durable pre-E05
hashes; current delivery hashes matched too. Whole-tree historical writer proofs were
not independently reproduced; documentation was reviewed directly. Details in evidence.

## E04 — Engineering Resourcefulness confirmed; absence-state report open

**Primary actual-baseline comparison and independent scoped static review PASS/no
blockers (2026-11-10). User confirms Engineering now shows Resourcefulness.** This section supersedes historical
one-ID/discovery-required descriptions and the E03 Resourcefulness issue below without
rewriting their evidence. Engineering's saved diagnostic reports positive enchant7977;
the user identifies Resourcefulness. Six exact supplied IDs are now mapped:

| ID | Full category | Evidence here |
| --- | --- | --- |
| 7977 | Resourcefulness | Engineering equipped diagnostic + user category, 2026-11-10 |
| 8005 | Multicraft | Original T01 native ID/typed line; provenance unchanged |
| 8035 | Ingenuity | User-supplied list, 2026-11-10; not native-verified here |
| 8033 | Deftness | User-supplied list, 2026-11-10; not native-verified here |
| 8003 | Finesse | User-supplied list, 2026-11-10; not native-verified here |
| 7975 | Perception | User-supplied list, 2026-11-10; not native-verified here |

Only production `Data.lua` changes: these entries plus approved Deftness/Finesse/Perception
category labels (D/F/P). All four verified stat API keys, eight crafting identities,
Moxie mappings, collectors, saved schema, Knowledge and Details are unchanged. D/F/P
labels do **not** enable gathering scans or establish equipped-item compatibility.
Known IDs establish category only, never amounts/ranks or other quality variants.
Full category names appear without amounts in the main table; observed tool-stat
amounts and enchant IDs/typed lines remain in diagnostic Shift-hover. Unknown positive
IDs/unready/conflicting data show `?`, not confirmed absence; only confirmed absent
enchants are blank. Coherent saved values/time survive transient reads where available.

Local fixtures: **264/264** (251 retained, only obsolete final R6 enchant allowlist/count
adapted,13 new E04); unchanged **744 K6 /565 K7**. These are synthetic correctness
checks, not native API, gathering or display acceptance. Exact validation/freeze evidence
is appended in [evidence](evidence.md). Engineering7977's **new dashboard display is
user-confirmed**; the other four supplied IDs remain unverified here.

### Current investigation — blank versus unknown enchant

Blank means confirmed no enchant (or confirmed empty/not-applicable tool); `?` means
unavailable/unready/conflicting evidence or an unmapped category. A known category
shows its full name. The current display also requires whole-tool metadata readiness:
unrelated rank/stat failures can suppress otherwise observed enchant absence. One
affected Shift-hover diagnostic/profession is needed to establish the user's case;
do not treat all unknowns as absent. No new scan/update/selftest is requested yet.

### E04 delivered update / display check — historical procedure

Quit WoW and back up the installed addon/account SavedVariables. If on E03, replace
only **`CraftArmy/Data.lua` + `CraftArmy/SelfTests.lua`**. Otherwise overlay the complete
current CraftArmy folder preserving saved data/unrelated files and backups; retain
the U03 rollback caveat linked below. Agents do not install or run the client.

Open your own ready Midnight Engineering out of combat, run `/ca scan`, then `/ca`.
Check the Enchant cell now shows **Resourcefulness** and report any errors, execution
warnings or unresponsiveness. A pre-E04 cached unknown category updates on that normal
scan; offline/cached viewing or hover does not migrate data or read APIs.
Verify the other supplied categories as encountered in ordinary onboarding, not new
ID-discovery rounds. Do not repeat accepted skill/Moxie/concentration/cache/reload
checks, full native selftest, or Details refresh. Full native selftest remains
**INCOMPLETE87/149**; gathering/Knowledge capture/Details improvements stay separate.

## E03 — six-profession skill/Moxie/concentration and reload confirmed

**Primary actual-baseline comparison and independent scoped static review PASS/no
blockers (2026-11-10). User confirms correct skill, Moxie and concentration across all
six new professions, with those values surviving reload.** This
section supersedes historical two-active-mapping/dormant-crafting claims below, not
the accepted E01/E02 observations. Those Enchanting checks need not be repeated.

Only production **`Data.lua`** changes: six user-evidenced Midnight identities
(child/parent/family, all expansion11), each dated2026-11-10, and active references to
their existing supplied Moxie catalogue entries:

| Profession | Child / parent / family | Moxie |
| --- | --- | --- |
| Alchemy | 2906 /171 /3 | 3256 |
| Blacksmithing | 2907 /164 /1 | 3257 |
| Engineering | 2910 /202 /8 | 3259 |
| Jewelcrafting | 2914 /755 /12 | 3262 |
| Leatherworking | 2915 /165 /2 | 3263 |
| Tailoring | 2918 /197 /7 | 3266 |

Inscription2913→3261 and Enchanting2909→3258 are unchanged. Gathering remains outside
scope; its three catalogue entries stay dormant. Native identity/config/tab queries
prove **identity only**, not generic fields, Moxie balances, Knowledge accounting or
responsiveness. Config/tab observations are not hardcoded. Supplied Moxie provenance
in the shipped catalogue records its initial user-supplied basis; subsequent native
Moxie agreement for all six is now recorded in evidence/Q03. Other field semantics
and complete Knowledge accounting are not established by that agreement.

All eight identities can use existing guarded skill, gear/stat/enchant, dynamic
concentration, Moxie and Unspent KP collection. **Numeric Knowledge and Details remain
Inscription-only**: other professions store a nil-valued unsupported Knowledge-raw
attempt, may show named unknown trees and have read-only unsupported Details. No
collector/Core/Knowledge/Details/schema/UI changes. Unknown is not observed0 or a
confirmed missing enchant; failures retain coherent prior values/time where available.

Local fixtures: **251/251** (238 retained, exactly two obsolete mapping-count/scope
cases adapted,13 new E03), unchanged **744 K6 /565 K7**, diagnostic23/23 and both
Python structural checks. Original220 and all other236 prior cases/helpers/runner
are byte-frozen. Fixtures are synthetic correctness evidence, not native API/UI/latency
acceptance; exact checks, hashes and inverse/freeze limits are in [evidence](evidence.md).

### Current issue — Resourcefulness enchant shown as unknown

User reports a Resourcefulness enchant showing `?`. Only enchant8005→Multicraft is
currently mapped; unknown category is a possible cause, not a confirmed diagnosis.
Shift-hover the affected Enchant cell to inspect the saved enchant ID and typed label.
Exact ID/native label/profession evidence is needed before adding a mapping; unknown
is not confirmed absence. No new update/capture/selftest or repeated accepted field/
reload checks requested. Equipment, Unspent KP and general normal-use observations
remain unreported in this six-profession batch.

### E03 delivered update / initial native batch — historical procedure

Quit WoW and back up the installed addon/account SavedVariables. If on E02, replace
only **`CraftArmy/Data.lua` + `CraftArmy/SelfTests.lua`**. Otherwise overlay the complete
current CraftArmy folder preserving saved data/unrelated files and backups, retaining
the U03 rollback caveat linked below. Agents do not install or run WoW.

For each of the six professions, log into its character, open its own ready Midnight
profession out of combat, run `/ca scan`, then `/ca`. Compare skill, A1/A2/Tool,
concentration, **current Moxie** and Unspent KP to native UI in the same round. Report
unknowns/mismatches, errors/execution warnings or unresponsiveness; a consolidated
report is fine. Numeric Knowledge stays unknown outside Inscription at this stage.
No separate currency-ID discovery or repeat of accepted Enchanting cache/Moxie checks,
Details refresh, crafting/spending or full native selftest. Subsequent user evidence
confirms skill/Moxie/concentration+reload only; other field/normal-use gates remain open.
Full native stress stays
**INCOMPLETE87/149**; guides, broader API/Knowledge acceptance and release are separate.

## E02 — Enchanting Moxie verified in dashboard

**Primary actual-baseline comparison and independent scoped static review PASS/no
blockers (2026-11-10). E02 takes precedence over historical E01 unknown-Moxie/query
instructions below.** The user reports `3258 Artisan Enchanter's Moxie 415`, matching
native Enchanting (2026-11-10), and subsequently confirms dashboard Moxie matches the
native balance. **E02's focused validation is complete; no further check/update is
requested.** 415 is an observation, never a default balance. Numeric Knowledge remains
unverified; this is not full Enchanting/dashboard/API acceptance.

Only production `Data.lua` changes: `moxieCatalog` retains the11 supplied IDs with
provenance; numeric active mappings reference only verified identities
**2913→Inscription3261** and **2909→Enchanting3258**. Other entries remain dormant:
Alchemy3256, Blacksmithing3257, Engineering3259, Herbalism3260, Jewelcrafting3262,
Leatherworking3263, Mining3264, Skinning3265, Tailoring3266. These nine are user-supplied
list data, **not native-validated here**. Gathering stays outside crafting-only scope;
no new skill-line/family mappings, collector, schema, UI or Knowledge/Details changes.
Numeric Knowledge remains Inscription-only; Enchanting Details stays unsupported.

Existing collection reads the current balance; zero is observed0, attention is strictly
**>600** (not600), failures preserve the last value/time or remain unknown on a first
failure. Stale/offline values are not fresh confirmed attention. Rendering/reload does
not collect. Future profession onboarding's **initial native dashboard comparison
includes Moxie**; a separate currency-ID discovery query is no longer the default.
Dormant IDs activate only after that profession's identity is verified.

Local fixtures: **238/238** (original220 frozen,11 E01 retained with4 authorized
mapping adaptations/local currency helper,7 new E02), **744 K6 /565 K7** PASS.
Fixtures do not prove native APIs/UI/latency. Exact final checks/hashes/freeze evidence
are recorded in [evidence](evidence.md).

### E02 delivered update / native check — historical procedure

Quit WoW and back up installed addon/account SavedVariables. If on E01, replace only
**`CraftArmy/Data.lua` and `CraftArmy/SelfTests.lua`** in the installed addon. Otherwise
overlay the complete current CraftArmy folder preserving saved data/unrelated files
and backups, retaining the U03 rollback caveat linked below. Agents do not install.

Open your own ready Midnight Enchanting out of combat, run `/ca scan`, then `/ca`.
Compare **dashboard Moxie against the then-current native balance**, not forced415;
report mismatch/errors/warnings/unresponsiveness. This display check is now user-confirmed.
Do not repeat E01 cache/reload checks, currency-ID queries, full native selftest or
Details refresh. No crafting, purchasing or spending is requested. Full native stress
remains **INCOMPLETE87/149**; broader dashboard/API coverage and publication are separate.

## E01 — focused Enchanting validation complete

**Implementation delivered locally; primary baseline comparison and independent
scoped static review PASS/no blockers (2026-11-10). User confirms skill, equipment,
concentration and Unspent KP match native UI, without noticed performance issues or
errors. Saved values survive both closing the profession and reloading without a new
scan. E01's bounded focused sequence is complete; no further cache checks needed.** This gate
takes precedence over older update instructions below. Earlier one-mapping statements
describe historical deliveries, not the current registry.

The runtime changes are limited to:
- `Data.lua`: Midnight Enchanting child skill line **2909**, parent **333**, profession
  **9**, expansion **11**, from the user's child-profession query2026-11-10. That query
  also observed skill81/max100; it did not establish other field semantics.
- `Collectors.lua`: only the Knowledge-raw persistence boundary changes. Exact
  Inscription2913/773/13/11 keeps its original raw observation/evidence-budget behavior.
  Other identities receive an **unsupported**, nil-valued raw attempt with an explicit
  unverified-profession reason. Existing bounded capture/evaluation/index behavior is
  retained; no unverified raw report is stored and no accounting/schema guard widened.

Existing guarded generic skill, gear/stat/enchant, dynamic concentration and unspent-KP
collection can now save the Enchanting row. Native agreement and normal-use behavior
are user-confirmed for the reported sequence, not an individual audit of every
gear/slot/stat/enchant/cap/API case or a measured latency result. Closed-context and
reload retention are user-confirmed for E01.
Unknown/unavailable reads must not be interpreted as observed zero or absence.

**Enchanting Moxie remains unknown**: no mapping was added and Inscription currency3261
is not queried for Enchanting. **Numeric Knowledge remains unknown**: Inscription's
native accounting policy is unchanged and rejects relabeled Enchanting data. Captured
tab identities may provide named unknown bars, never inferred numeric totals.
Existing Details is unchanged and **unavailable/read-only for Enchanting**; no perks,
recipes or new Details support are implied. Inscription behavior is retained.

Local validation: **231/231 addon cases** (original220 byte-preserved +11 additive E01),
**744 K6 /565 K7** checks, diagnostic23/23 and both Python structural checks PASS.
All non-native fixture quantities/IDs/gear are synthetic, not client API evidence.
Source hashes, exact inverse/freeze proofs and both historical partial failures are
in [evidence](evidence.md). Full native stress remains **INCOMPLETE87/149**; no full
native selftest, timing chase, agent installation, reset or release is requested.

### Next dashboard field — Enchanting Moxie evidence

E01 persistence checks are complete. The next step is a targeted read-only currency
name/balance query for candidate3258, recorded in Q03. No Moxie mapping or new addon
update is delivered by E01; numeric Knowledge remains unverified. No full selftest
or Details refresh is requested.

### E01 delivered update / first native check — historical procedure

Quit WoW and back up the installed addon and account SavedVariables before updating.
If already on the latest U04 build, replace **only `CraftArmy/Data.lua`,
`CraftArmy/Collectors.lua` and `CraftArmy/SelfTests.lua`** in the installed addon.
If not on that build, overlay the complete current `CraftArmy` folder without deleting
unrelated files. Preserve SavedVariables/diagnostics and pre-update backups; the U03
rollback caveat in [schema](schema.md#u03-optional-profession-details-report) still applies.
Agents do not install/run the client. Current instructions supersede older procedures.

Open your own Midnight Enchanting, wait until ready and stay out of combat. Run
`/ca scan`, then `/ca`. Compare skill, A1/A2/Tool, concentration and Unspent KP with
the native UI; report unknowns/mismatches, errors/execution warnings or unresponsiveness.
The earlier81/100 is an observation, not a required current balance. Moxie and numeric
Knowledge are expected to remain unknown at this stage. No Details refresh, full
selftest, crafting, purchases or Knowledge spending is requested. Closed/reload-cache
checks follow separately after a satisfactory first round.

## U04 — wider flat knowledge bars; appearance accepted

Knowledge bars now show **only X/Y or `?`**, without Blu/Cal/Per/Dar prefixes. Stat
is 140px, Enchant 110px and Knowledge 292px; all other columns and the 1454px outer window,
row height and fonts are unchanged. Four bars use 70px each (one through eight trees
share the column). The fill uses built-in solid `WHITE8X8`, with no theme/dependency.
Normal tree hover retains every captured branch and its individual X/Y, with **two
spaces per child depth**, root unindented. Duplicate/localized names, unknown branches,
stale/archive footers and the complete Shift-hover diagnostics remain available.
This is presentation only: no collection, accounting, saved points or timestamps change.

Local validation: **220/220 addon cases** (214 retained +6 new U04), **744 K6 /565 K7**
checks, diagnostic 23/23 and both Python structural checks PASS. Missing native clocks
remain unavailable, not 0 or timing PASS. Fixtures are not native visual/API evidence.
**Primary actual-baseline comparison and independent U04 static review PASS (2026-11-10).**
User follow-up (2026-11-10): “Oh yeah, that looks a lot better.” The appearance is
accepted for this iteration. No further U04 update/retest is requested. U03 Details
values match and normal-use responsiveness/no errors or execution warnings are user-
confirmed. Closed-context cached Details are user-confirmed preserved with original
observation time and saved/notcurrent presentation. Reload also retains all values
and original observation time, with only relative age increasing as expected.
**U03 focused validation is complete for the reported Inscription sequence; U04
appearance is accepted. No further check or update is requested for this round.**

### Delivered update / visual-check procedure — historical, not a new request

If already on U03, quit WoW and back up the installed addon and SavedVariables. Update
**only `CraftArmy/Dashboard.lua`, `CraftArmy/ViewModel.lua`, `CraftArmy/SelfTests.lua`**.
Preserve `Details.lua`, `Core.lua`, Collectors, all other modules, TOC, SavedVariables
and diagnostics. If **not** on U03, use the full current `CraftArmy` folder overlay
without deleting unrelated files instead; retain the pre-update backup because older
code rejects the optional Details field (see [schema](schema.md#u03-optional-profession-details-report)).
The user's “Values match correctly” is bounded U03 native value agreement, not proof
of an exact installed source hash, latency, warning absence or cached persistence.

Use existing cached data: `/ca`, inspect numeric-only labels, wider flat bars and
root/child/grandchild/sibling indentation. Hold Shift **before** entering a bar to
check the full diagnostic view; the five silent normal cells, native gear hovers and
Profession click should remain unchanged. Report visual problems or actual errors.
**No recollection, Refresh details, full native selftest, V01 restart or new capture
is needed for U04.** U03 focused cached-persistence checks are now complete; broader
T02 acceptance remains separate. No install or client run by agents.
These instructions supersede earlier update/retest instructions below for U04.

## U03 — Inscription Details; static review PASS, bounded native values agreement

Click a row's **Profession** with the left mouse button to open cached branch details.
Previous/Next branch shows each branch's own investment, the client's per-point rule
with all conditions, and confirmed earned milestones with required ranks (including0).
Text wraps and scrolls; opening or navigating the panel does **not** collect data.
Other professions are unavailable/read-only; offline/archived snapshots are cached
observations, never live alt inspection. If details are absent, known investment and
an explicit “perks not observed” instruction appear, not a fake empty earned list.

**Refresh details** is a separate explicit action on your own ready, unstaged Midnight
Inscription. It uses one metadata/perk/verification unit per frame, then a bounded
final scalar node check (at most64 paths) and atomic save in the commit frame. Ordinary
dashboard scans do not read perk descriptions. Close, Escape, hide, restart or combat
cancels capture without autoresume. Failures preserve the prior coherent report;
pending/unavailable data never counts as earned. Details have their **own observation
age** and saved/stale/archive status. Refreshing details does not advance dashboard
Last Updated. Saved perks retain their own points, not later table investment.

Recipe-like milestone wording, such as the rank0 Treatise text, remains an **earned
milestone description**, not proof that a recipe is learned. Complete recipes,
computed benefit totals, profitability and other professions are deferred.

Local validation: **214/214 addon cases** (181 retained +33 new U03), **744 K6 /565 K7**
supplement checks, diagnostic23/23 and both Python structural checks PASS. The full
local workload is retained; missing native clocks remain “timings unavailable,” not
zero or performance PASS. Injected fixtures do not establish target-client API behavior.

**Primary exact comparison and independent scoped review PASS (2026-11-09).**
Focused Inscription Details validation is complete; broader native coverage and
release remain incomplete. The initial197/1 local stop
is retained in evidence; the final same-frame point check follows the settled primary
amendment and keeps its rejecting regression. Native sample61 proves only sampled
data feasibility. User subsequently reports “Values match correctly,” responsive
refresh without errors/execution-limit warnings, closed-context preservation and
reload retention with only expected relative-age changes (2026-11-10). These are scoped
normal-use observations, not an individual audit of every native path/API/limit.

### Historical combined U02 + U03 update and focused check

These U03 delivery instructions are historical, **not a request to recollect for U04**.
The U04 review/update gate above takes precedence. The U03 static review passed. Quit WoW
and back up all SavedVariables and the installed addon. Copy the **full current
`CraftArmy` folder over the existing addon without deleting anything**, including new
`Details.lua` and the updated TOC/Core/Dashboard/SelfTests. This also includes U02's
Collectors/ViewModel changes if U02 was never installed. Preserve all SavedVariables,
diagnostics and unrelated files. New SelfTests definitions are **not a request for a
full native selftest rerun**. Older code rejects the new optional saved field: retain
the **pre-update backup** for any coordinated revert; do not strip/reset the field or
run old code on newly captured data. See [schema](schema.md#u03-optional-profession-details-report).

Out of combat, open your own ready Midnight Inscription with no staged changes:

1. Run **one normal `/ca scan`**, then `/ca`. Check U02 branch names/individual X/Y,
   five silent normal value cells and Shift-before-hover diagnostics; native gear
   tooltip behavior should remain unchanged.
2. Left-click Profession, then **Refresh details** once. Navigate to Calm Hands and
   compare the full per-point rule/conditions and earned rank0 milestone with native
   UI. Do not assume sample point totals or use recipe text as learned confirmation.
3. Report responsiveness, load/API errors, execution warnings or mismatches. Stop on
   a real problem; preserve data. No synthetic timing/performance PASS is assumed.
4. Close the profession and reopen cached Details without refreshing; then reload
   and reopen the cached panel. Confirm the report/text/investment and its own saved
   observation time survive without advancing dashboard Last Updated. Saved/stale
   rather than fresh is expected after context loss/reload.

No full `/ca selftest`, `/cad selftest`, large capture, `/ca knowledgecheck`, V01
restart, timing chase, crafting, spending, recipe learning, gameplay action or reset
is requested. These are focused user-run checks, not agent-run client validation.

## U02 — named branch-only tree hover; five silent normal value cells

Normal tree hovers show **every captured path**, including the root and locked branches,
as `Name: purchased/capacity` using that individual path's points, not the whole-tree
aggregate. No routine heading, accounting caveat, age prose or Shift hint is appended.
Actual stale/archived states get a short footer; missing observations stay unknown.
Names come from the observed active entry's definition override name or spell name during
the guarded scan, never on hover/offline. Unavailable names say `Unknown branch`.
This optional metadata is schema1 backward-compatible: old nameless snapshots remain
valid. Name failures do not change numeric eligibility or borrow labels from history.

**Moxie, Unspent KP, Last Updated, Stat and Enchant value cells have no normal tooltip.**
Their header hovers and selection still work. Hold **Shift BEFORE entering** any cell/bar/
status hover for the original full diagnostics, including exact observation times, raw
IDs/reasons, reconciliation and future-cost caveats. Leave and re-enter to change modes.
Missing/throwing/nonboolean modifier support safely selects normal behavior (silent on
those five cells). Native item/third-party tooltips remain on A1/A2/Tool only; Stat and
Enchant Shift hovers show full tool evidence without native hyperlinks. Tool normal
hover still includes observed stat amounts/enchant detail, not an inferred base/enchant
split or enchant rank/amount. Table values, attention rules and saved ages are unchanged.

U01 user feedback confirms improved tooltips and a normal/Shift difference; it does
**not** verify U02 names or silence. **U02 independent static review PASS; native checks pending.**
Local checks pass: **181/181 addon cases** (149 retained +15 adapted U01 +17 new U02),
744 K6/565 K7 checks, diagnostic23/23 and both Python structural checks. Injected fixtures
are not evidence of target-client API behavior, native timing or wrapped readability.
Primary U02 exact comparison and independent static review passed (2026-11-08).
Its earlier five-file update instructions are superseded by the **combined U03
review-gated folder update above**. U02 target-client name/API behavior, wrapped
readability and hover checks remain NOT RUN; broader T02 acceptance is incomplete.

## Current validation policy — approved 2026-11-07

**No further full `/ca selftest` timing chase is requested.** The U04 update above
is review-gated; its focused cached-data visual check follows review. The latest
client result is **INCOMPLETE:87 passed/0failed of149**, case88unit2 at134.4ms,
wall77323.9ms. It is not a full PASS and does not show an assertion failure. Keep the
100ms/10000-step safety limits and every existing test/workload unchanged.

Full correctness/stress coverage runs locally: the pre-U01 reviewed code had149/149 addon
fixture PASS,744 K6 checks,565 K7 checks and23/23 diagnostic PASS. This does not prove
WoW APIs, native numeric behavior or normal-use responsiveness. With the user's explicit
agreement, completing every synthetic client fixture under100ms is **no longer a
blanket prerequisite** for focused native validation. Historical update/retest/full-suite
gates below are superseded by this policy, not retroactively passed or deleted.

### Completed V01 context — historical first-round procedure, not a new request

All three user-run V01 rounds are complete for the reported scoped Inscription values,
normal-use responsiveness, closed-context preservation and reload persistence. Explicit
stale wording was not confirmed. Do not restart these rounds for U02; the earlier
procedure is retained below as historical context, not current testing instructions.

1. Out of combat, open your own ready **Midnight Inscription**, with no pending
   specialization changes. Do not craft, purchase, unlock or spend knowledge for testing.
2. Run `/ca scan`, then `/ca`. Report responsiveness and any errors/execution warnings.
   Stop on a freeze, warning, load error or disabled-DB message; don't reset saved data.
3. Report the four dashboard tree labels and points/capacities, plus separate
   **Unspent KP** and any unknown/stale explanation. Compare native values where they
   are directly comparable. If the native UI doesn't show a per-tree total, say so
   rather than estimate. Historical264/870 is not an expected current balance.
4. Hover a known tree once; note whether the evidence/time/provisional text is readable
   and whether it disagrees with the native view. No full report, character/realm data,
   SavedVariables upload or `/ca knowledgecheck` capture is needed for this first round.

After a satisfactory first round, primary will coordinate closed-window snapshot
preservation and reload/last-observed checks. These focused observations—not a relabeled
stress-suite PASS—gate native API, snapshot and normal-use responsiveness acceptance.
Any actual mismatch, freeze or warning still requires investigation. Other profession
mappings/required-field semantics/guides/release remain unaccepted.

## Historical selftest/update notes — superseded instructions

The following preserves earlier diagnostic and delivery context. Do not follow its
full-suite-before-bars or repeat-update requirements over the current policy above.

**Current selftest paused:** latest K6 user run stopped **INCOMPLETE,86 passed/0 failed
of149**, case87 unit2 [oversized Apply]123.4ms (wall86561.3ms).63 cases remain
uncompleted (87 started). Case81 now passes under the unchanged100ms limit, but its
new scan2 T was not provided; no new stage/speedup numbers are inferred. Warning
recurrence/interactivity remain unknown. Safe full completion is still unproven.
K7 adds a private conservative rejection proof for a reachable plain table with
at least50000 confirmed own entries, not a sparse-length assumption. Every unproven
input still runs the entire old validator, with every numeric guard/order unchanged.
**K7 awaits independent review and native validation; no latency PASS is claimed.**
**Do not rerun unchanged K6/K5/K4a/K4/K3f/K3e/K3d/K3c/K3b/K3a/K3 or the old synchronous suite**.
Historical K3f81/123 stopped at final second-Scan/assert unit122.4ms (wall67041.5ms),
with42 uncompleted; it did not measure internal Scan stages either.
Historical K3d64/123 stopped at case64 combined100.5ms (wall102289.1ms), with59
uncompleted and case80 NOT REACHED in that separate run.
Historical K3c79/123 stopped at case80 initial unit123.1ms (wall70914.9ms); that
separate run passed case66, with44 uncompleted (80 started), not new case80 validation.
Historical K3b66/123 stopped at case66 combined102.8ms
(wall65297.9ms); individual command timings were not measured.
Historical K3a62/111 stopped at case63 combined140.4ms (wall20823.1ms); historical96/96
accompanied extended lockup/execution-limit warnings. Full safe completion, warning
recurrence/interactivity and warning cause remain unverified; no performance PASS.
K2 adds narrowly scoped Midnight Inscription native-rank/shared-spent-reconciled
bars, subject to complete same-scan guards and review/user validation. This is NOT
verified future/all-rank cost proof. Registry support for eight crafting families is not runtime
support for eight professions; at that historical K2 delivery, only Midnight Inscription
expansion identity was mapped. E01 above adds only the evidenced Enchanting identity,
not complete field acceptance. Safe unknowns do not complete required fields.

## User-only installation, backup and removal

Agents do not install or run WoW. Quit WoW first. Back up the existing `WTF` folder,
especially account SavedVariables, before any manual install/update/removal. Copy
the **CraftArmy** directory (TOC and nine Lua files) to the Retail
`Interface/AddOns/` directory yourself. No dependency, guide or Auctionator required.
Enable CraftArmy on the desired characters. Interface120105 is source corroborated
and T01 user-observed, not a T02 client-load result.

Keep the separate `CraftArmy_Diagnostics` directory and its SavedVariables unchanged.
`CraftArmyDB` is new schema1 data; it does not import or alter diagnostic samples.
Update only CraftArmy addon files, never overwrite your saved data with defaults.
For removal, quit WoW and remove/disable CraftArmy. Saved snapshots remain unless
you explicitly delete the production SavedVariables files yourself after backup.
Do not remove diagnostic files or unrelated addon data. Invalid/future production
DB disables writes with an explanation; back up and report it, do not blindly reset.

## Commands and compact dashboard

- `/ca` toggles the native dashboard (deferred in combat).
- `/ca help` shows usage. `/cad` remains independent and unchanged.
- `/ca scan` reads the currently visible, ready, own-player supported profession.
  It never opens/switches professions. Closed, linked, guild, NPC, changing or
  unready contexts preserve saved snapshots with a refresh explanation.
- `/ca selftest` starts frame-stepped isolated injected fixtures out of combat,
  without Login/live collection/real DB mutations. Repeating it reports status, not
  a second run. `/ca selftest cancel` stops INCOMPLETE. See the K7 review gate below.
- `/ca knowledgecheck` captures read-only, provisional Midnight Inscription evidence
  into a local copy window, out of combat only. No scan or snapshot write is required.

Log into each alt and open its own Midnight profession normally; scan when ready.
No snapshot does not mean the character has no profession. Unknown expansion IDs
are explained as pending instead of silently attributed to Inscription. Roster
presence is collected at login/scan; automatic unlearning remains unsupported until
a complete authoritative absence contract is verified. Use confirmed retirement.

R6 uses **one 22-pixel line** per character/profession with **14 columns**: Name,
Realm, Profession, Skill, Accessory #1, Accessory #2, Tool, Stat, Enchant,
Concentration, Moxie, Knowledge trees, **Unspent KP**, **Last Updated**. Name/Realm are
separate labels; GUID and profession IDs remain the saved keys. No portraits, wrapping
or second knowledge strip. Tool contains gear only; Stat and Enchant are independent.

Stat shows full names (Crafting Speed, Ingenuity, Multicraft, Resourcefulness), joined
with commas when multiple, without amounts or an attribution asterisk. Numeric totals,
raw stat keys and base/enchant-attribution-unknown explanation remain on hover; never
add the enchant again or infer values from rank. Enchant shows the full known category,
blank for confirmed none/no tool/not applicable, and a lone `?` for unknown, unloaded
or unmapped category. 8005 establishes Multicraft only, not amount or enchant rank.
Unknown stat categories show `?` with raw evidence on hover, not guessed names.

Gear cells use item icon plus matching valid crafted-quality atlas, without redundant
`R#`. If a known rank1–5 has no usable matching atlas, the fallback is bare `1`–`5`;
unknown rank shows `?`, confirmed empty is entirely blank. A1/A2/Tool alone receive
uncommon/rare/epic rarity backgrounds at alpha0.18. Unknown rarity/empty cells reset
transparent when rows are reused; rarity is never crafted rank or item level.

Earlier C/I/M/R letters remain historical registry/tooltip naming guidance, not R6's
main-cell format. Full names are chosen by explicit stable stat keys/category maps,
not localized first letters.

Future naming guidance only: **D = Deftness, F = Finesse, P = Perception** for
gathering (Skinning/Herbalism/Mining). Gathering remains **outside this crafting-only
MVP**. This legend adds no gathering API keys, collectors, registry or runtime support.

Hover gear for native item + observation detail, tree bars for path/coverage detail,
and other cells for exact field attempt/observation timestamps and skill modifier.
Unknown bars have no numeric fill/denominator. Tooltips may be long with full raw
path evidence; native-client sizing/overflow must be checked before acceptance.
Wheel-scroll or use Previous/Next (12 reusable rows). Character text matches name,
realm, combined name-realm or GUID. The native Profession dropdown offers All plus
the eight supported families, using stable enums independently of localized row
labels. It filters existing active/archived snapshots, resets the page and never
scans or writes data. This does not add seven missing Midnight identity mappings.
If native menu capabilities are unavailable, a noninteractive All-professions
placeholder explains why; no hidden profession selection remains. Attention and
Sort buttons cycle their options.
Archived view is separate and has no active alerts/totals. Click a row to select it;
Retire, Delete generation and Delete character show explicit scope and Confirm/Cancel.
Character deletion includes all its profession generations, never other characters.
Reactivation/relearning requires a new successful guarded scan, no historical restore.

`!` means fresh confirmed attention; `~!` means last-observed historical attention
for skill/currencies. Confirmed missing enchant instead uses a subtle amber cell
background (alpha0.12), leaving the Enchant text blank. Hover distinguishes fresh
from historical missing attention; unknown enchant never gets missing highlighting.
Moxie must be **>600**; concentration must be **≥90% of a verified positive cap**.
Unknown cap/enchant/progression is not a confirmed warning. Last Updated is only the
relative age of the last scan (`scannedAt`), even for archives—not retirement time or
a promise that all fields were observed then. Hover retains scan/per-field exact
times, snapshot/fresh/stale state, failed attempts and archival reason/time. Offline
data is always last observed, with no concentration regeneration estimate. Freshness is session-
only and invalidated by login/reload, context loss and relevant change events. A
failed latest attempt marks retained data stale; age alone never establishes fresh.

R1 correctness handling: a failed metadata read for the exact same verified equipped
instance retains the whole previous successful gear unit and its original timestamp,
with a failed attempt/stale label—not empty stats or fresh unknown rank. Changed,
removed or unidentifiable instances never inherit old metadata. Invalid typed saved
payloads/labels disable writes and show an explanation instead of attempting to render
bad rows; the saved global remains untouched. Back it up and report the failure.
These corrections passed prior static/user fixture gates for their recorded scope;
they do not establish R6 presentation or broader native API acceptance.

## Approved local checks

Inspect scripts first. No installation/download/alternate runtime is permitted.

```text
python3 tools/check_diagnostics.py
python3 tools/check_dashboard.py
lua5.1 tests/run.lua          # only if already installed
lua5.1 tests/dashboard.lua    # only if already installed
```

Python checks do not parse or execute Lua. Installed Lua5.1.5 now executes both full
suites; see evidence for actual **149/149**, **744 separate K6 checks**, the separate
K7 soundness-check count, and **23/23** results. Supplements load fresh Core chunks with copied math tables
and fake predicates, never patches host math, and reports separately from149 cases.
These isolated fixtures
do not establish WoW APIs, native100ms performance, warnings or interactivity.

### R4 update and retest (user only, after independent review)

Your R3 `/ca selftest` result **35 PASS / 1 FAIL of36** remains historical. The failing
sanitization group exposed target-client NaN comparison behavior; native
`math.isfinite` rejected the same NaN. R4 centralizes that native-aware rule and adds
contextual subcase labels. It does not reset saved data, change schema1/version
0.2.0-mvp, or establish a corrected fixture pass before you run it.

1. After primary R4 static review, fully quit WoW and back up `WTF`, including both
   production and diagnostic SavedVariables. Replace **only the CraftArmy addon
   files** with the reviewed R4 set in your existing addon folder. Do not delete or
   replace `CraftArmyDB`, diagnostic samples or any SavedVariables to suppress errors.
2. Start WoW/login and use `/reload` to ensure the updated Lua files are loaded.
   Open the dashboard only as needed; do not start live profession comparisons yet.
3. Run `/ca selftest`. R4 defines **40 cases**; report the actual passed/failed counts
   and every complete failure line (now including numeric subcase context), plus any
   addon-load/DB-disabled error. This is an expected definition count, not a promised
   pass. Run separate `/cad selftest` and report its result; old23/23 is not a retest.
4. Stop on any fixture/load/disabled-data error. Preserve backups and report it through
   primary; no saved-data reset, gameplay mutation or hand-edited numeric workaround.
   Resume own ready Midnight Inscription scans/UI comparisons only after primary
   records satisfactory correction review and actual fixture results.

The correction uses native scalar classification, not live collection in selftests.
On WoW the native result takes priority; an injected absent-native fallback is not
asserted to repair WoW's non-IEEE NaN comparisons. Portable non-finite branch assertions
run on a native-absent Lua host, while actual-runtime NaN/±infinity rejection remains
mandatory on every host. No alternate runtime installation is required or authorized.

## Primary/user runtime checklist (not agent-run)

### K7 conservative budget proof (current; user only AFTER independent review)

K7 changes **only Core.lua** in the installed addon. One table plus50000 own child
values necessarily exceeds the existing50000-visit budget. A private root-only
search uses plain-table length >=50000 ONLY as a hint, then counts raw own keys.
Depth4(root0),64 distinct tables,256 discovery entries and50001 GLOBAL candidate
probes are opportunistic search caps, not new persistence bounds. A miss/cap always
runs the complete old copy/validator. Metatables (including false locks) are deferred
without invoking metamethods; search dedup never changes alias-expanded validation.
The recursive copy, public guards, typed validation, initial Apply DB validation,
alias-safe final proposal and single real commit are unchanged. Multiply-invalid
overbudget graphs may report budget before type/native/cycle errors; both old and
new paths reject, with no partial result. No formerly valid graph is rejected.

All **149 SelfTests.lua cases, full50001-element construction, real Apply and later
failed-evidence Scan, K4 timing, checkpoints and assertions remain byte-unchanged**.
Standalone-only K7 tests append after the entire unchanged K6 runner/supplement.
Local correctness tests do not establish native speed, APIs or warning resolution.

1. **Wait for primary's independent K7 review and coordination.** Fully quit WoW,
   back up `WTF` including production and diagnostic SavedVariables. Already on K6:
   replace **only `CraftArmy/Core.lua`** with the reviewed K7 file. Keep current
   **SelfTests.lua149**, ALL other modules, `CraftArmyDB`, SavedVariables and
   diagnostics unchanged. Same version0.2.0-mvp/Interface120105/schema1; no reset.
2. Login/reload and explicitly run **`/ca selftest` out of combat**. Preserve149 cases,
   order/workloads and unchanged **100ms/10000-step** limits. No skipping/filtering/
   reordering/limit raises or automatic resume; `/ca selftest cancel` remains available.
3. Share final COMPLETE/INCOMPLETE counts, wall/max-unit timing, case/unit/label,
   failures, warning recurrence and whether the game stayed interactive. If available,
   also share case81's **PASS scan2 line** to record its new T (latest86-case summary
   did not provide it). Prior Scan T102.8/unit103.0 and initial147.1/147.2ms are history,
   not current values. Case87's123.4ms is the Apply unit, not a Scan-stage measurement.
4. Report a new stop once; **no unchanged-version rerun** or raised limits. Keep native
   bars/hover/unspent comparisons paused until primary records satisfactory **safe
   full completion/performance and warning/interactivity evidence**.

No native<100ms guarantee, extra heavy Scan for latency, host clock/math patch,
profiler reset, CVar/error-handler change or agent live-game action is included.

### K6 protected numeric dispatch (historical instructions)

K6 changes **only Core.lua** in the installed addon. The existing whole-walk pcall
in boundedData and candidateMirror now protects each native finite call directly,
rather than nesting a pcall for each numeric check. Public Finite/Integer and all
typed validators remain byte-unchanged. Every key still checks the key AND literal0
before modulo/bounds; every check rereads math and raw native presence. Native strict
boolean results, absence fallback and fail-closed behavior remain. Per-walk pending
failure classes sanitize native exceptions without sharing state across reentry.
No cache, trusted bypass, check removal, schema change or async scan is introduced.

All **149 SelfTests.lua cases, runner, K4 timing, workloads and assertions are byte-
unchanged**. Standalone-only tests append after the existing149-case runner: frozen
pre-K6 walker/public-guard parity, native argument sequences, isolated pcall counts,
exceptions, dynamic math/native changes, reentry and real Apply mirror/proposal
failures/no mutation. Local Lua5.1 passes149/149 plus744 separately reported checks
and diagnostics23/23; none establishes native performance or client API behavior.

1. **Wait for primary's independent K6 review and coordination.** Fully quit WoW and
   back up `WTF`, including production and diagnostic SavedVariables. Already on K5:
   replace **only `CraftArmy/Core.lua`** with the reviewed K6 file. Keep the current
   **SelfTests.lua149**, ALL other modules, `CraftArmyDB`, all SavedVariables and
   diagnostics unchanged. Same version0.2.0-mvp/Interface120105/schema1; no reset.
2. Login/reload and explicitly run **`/ca selftest` out of combat**. STARTED reports
   actual count149. Preserve every case/order/workload and the unchanged
   **100ms/10000-step** limits. No filtering/skipping/reordering/limit raises or
   automatic resume. Cancellation remains `/ca selftest cancel`.
3. Share case81's **PASS line containing `scan2`**, or final **INCOMPLETE summary with
   the scan2-tagged case/unit identity** if slow-stopped. Before81's final step,
   Scan stages are **NOT MEASURED**, not zero. Share final COMPLETE/INCOMPLETE counts,
   wall/max-unit timing, case/unit/label, failures, warning recurrence and whether
   the game remained interactive. Compare **total T against latest102.8ms and initial
   147.1ms**, and outer **unit against103.0ms and147.2ms**, not a bucket alone.
4. Report a new stop once; **no unchanged-version rerun**, skip or raised limit.
   Keep native bars/hover/unspent comparisons paused until primary records satisfactory
   **safe full completion/performance plus warning/interactivity evidence**.

No local walltime claim, native<100ms guarantee, profiler reset, CVar/error-handler
change or live-game action is part of this correction. Unchanged K4 measurements
include probes; wrapper/assertion/runner overhead is outside T but inside the unit.

### K5 Core allocation correction (historical instructions)

K5 changes **only Core.lua and SelfTests.lua** in the installed addon. It uses one
identical bounded graph walk in copy/check-only modes: check-only removes output
allocations, not visits or guards. Apply retains full Open, the full incoming-pack
clone and whole old-character clone, then privately reuses owned fields/values.
Public Copy/ValidObservation/Merge semantics, all typed validators, alias-expanded
assembled budget and the single DB commit remain. No trusted public bypass, cache,
async scan, schema/mapping/accounting-policy change or new dependency is introduced.
All original134 cases, stress work, runner/K4 instrumentation and case81 are byte-
unchanged;15 isolated guard/ownership/oracle regressions append: **149 definitions**.
Local Lua5.1 passed all149 with0 failures/no INCOMPLETE and diagnostics23/23; this
does not prove client latency or APIs. New tests add no duplicate heavy35-path Scan.

1. **Wait for primary's independent K5 review and coordination.** Fully quit WoW and
   back up `WTF`, including production and diagnostic SavedVariables. Already on K4a:
   replace **only `CraftArmy/Core.lua` and `CraftArmy/SelfTests.lua`** with the reviewed
   K5 files. Keep ALL other modules, `CraftArmyDB`, SavedVariables and diagnostics
   unchanged. Same version0.2.0-mvp/Interface120105/schema1; no reset/profiling changes.
2. Login/reload and explicitly run **`/ca selftest` out of combat**. STARTED reports
   actual count (currently149). Preserve every case/order/workload and the unchanged
   **100ms/10000-step** limits. No filtering/skipping/reordering/limit raises or
   automatic resume. Cancellation remains `/ca selftest cancel`.
3. Share case81's **PASS line containing `scan2`**, or final **INCOMPLETE summary with
   the scan2-tagged case/unit identity** if slow-stopped. If stopped before81's final
   step, Scan stages are **NOT MEASURED**, not zero. Share final COMPLETE/INCOMPLETE
   counts, wall/max-unit timing, case/unit/label, all failures, warning recurrence and
   whether the game remained interactive. Compare **total T against147.1ms** and the
   outer **unit against147.2ms**, not C alone. Check-only work is now charged within
   O/A rather than nested C, so a falling Copy bucket alone proves no improvement.
4. Report a new stop once; **no unchanged-version rerun**, skip or raised limit.
   Keep native bars/hover/unspent comparisons paused until primary records satisfactory
   **safe full completion/performance plus warning/interactivity evidence**.

The unchanged K4 note uses probe-inclusive inner Scan T and exclusive stage totals
as explained below. Wrapper/assertion/runner overhead is outside T but inside the
outer unit. Neither standalone fixtures nor category reassignment establishes an
uninstrumented production latency claim or a hard <100ms guarantee.

### K4a case51 grouping and K4 stage measurement (historical instructions)

This changes **only SelfTests.lua**, not Core/Collectors/Knowledge/KnowledgeCheck,
Commands, snapshot policy, limits or saved data. All123 old ordered cases/assertions,
both actual case81 Scans and the full35-path native-shaped fixture remain. Eleven
small instrumentation regressions are appended: **134 definitions**, not a promised
pass. The measurement wrappers are temporary and synchronous; all real fixture
validation, copying, evaluation and the atomic write still execute. No yields, notes
or output occur while bindings are overridden; cleanup precedes annotation even on
errors. Unexpected Scan errors become `timed scan failed (payload omitted)` after
cleanup; ordinary returned success/false/reason are unchanged.

K4a adds three OUTER pause sites in case51: after fixture setup, after capture and
its original assertions, and after first explicit Format/purity assertions. Each
repeat now has three full-runtime guarded scopes; overrides restore before pauses.
Both full35-path captures, all Formats and the final invalid capture remain. No
yield occurs under pcall/override; no individual atomic-duration guarantee follows.

1. **Wait for primary's independent K4a review and coordination.** Fully quit WoW and
   back up `WTF`, including production/diagnostic SavedVariables. Already on K4:
   replace **only `CraftArmy/SelfTests.lua`** with the reviewed K4a file. Keep every
   other module, `CraftArmyDB`, all SavedVariables and diagnostics unchanged. Same
   version0.2.0-mvp/Interface120105/schema1; no reset or profiling setting changes.
2. Login/reload and explicitly run **`/ca selftest` out of combat**. STARTED reports
   the actual count (currently134). Do not filter cases, reduce work or raise the
   unchanged100ms/10000-step limits. Cancellation remains `/ca selftest cancel`;
   combat/clock/slow/error stops never automatically resume.
3. Share the case81 **PASS line containing `scan2`** on ordinary completion, or the
   final **INCOMPLETE summary containing `[case return; scan2 ...]`** on a slow stop.
   The unchanged Commands driver may suppress a slow PASS line; its terminal/max
   identity still carries the note. Also share the final COMPLETE/INCOMPLETE counts,
   wall/max-unit timing and case/unit/label, failures, warning recurrence and whether
   the game remained interactive. If stopped **before case81's final step**, no report
   means **NOT MEASURED**; do not estimate timings or rerun unchanged to force it.
4. Share a new stop once; **no unchanged-version retry**, threshold raise, skip or
   automatic resume. Keep native bars/hover/unspent comparisons paused until primary
   records satisfactory safe full completion/performance evidence.

The fixed note is `scan2 ms excl T=... O=... A=... C=... K=... E=... G=... B=... R=...`
(milliseconds, one decimal; `>99999` is a bounded overflow display). **T is the
probe-inclusive second Scan**, not the whole runner unit or uninstrumented production
latency. O=Core.Open, A=Core.Apply, C=Core.Copy, K=fixture Knowledge, E=Knowledge.Evaluate,
G=fixture Gear, B=fixture Context. These seven are **exclusive** totals: nested Open/
Copy are subtracted from Apply rather than counted twice. R is residual Scan work/
probe gaps, so stage exclusives+R partition T before display rounding. Reports also
have inclusive durations and call counts but retain no fixture/API/error payloads.
Probe overhead and client clock resolution can affect attribution (observed zero is
not evidence that a stage costs nothing); no bottleneck or production optimization
is established by delivery. Wrapper installation/cleanup and post-Scan assertions/
formatting/runner overhead are outside T but inside the measured runner unit.

Only at case81's final step, timing borrows native `debugprofilestop`, else
`GetTimePreciseSec` converted to milliseconds. There is no profiler reset, timer, CVar,
error-handler or production hook. Missing/throwing/nonfinite/backward clocks,10000
timing probes or64 active timing frames produce fixed `scan2 timings unavailable
(reason)`, **not zero or partial-success metrics**. The original fixture Scan still
runs once and its ordinary result is preserved, even if observation fails. Reports
are local, never SavedVariables/globals. Local K4a Lua5.1 fixture execution is recorded
in evidence; native K4a timing/scheduling/API/warning/interactivity checks are **NOT RUN**.
Standalone case81 correctly reports `scan2 timings unavailable (clock missing)`;
Python structure checks and stub regressions do not establish client API behavior.
Production optimization48 remains blocked on reviewed user timings and settled design.

### K3f cases81–82 scan/reload checkpoints (historical instructions)

The historical user **96 passed / 0 failed** is functional assertion evidence only:
the accompanying extended lockup and69x execution-limit warning make safe performance
**CHANGES REQUIRED**. The warning names BugGrabber but does not establish its cause.
Do not disable it, suppress error handlers, change profiling CVars or rerun the old
suite. The K2 production accounting and all saved data remain unchanged.

The subsequent K3 run passed the first42 cases but stopped **INCOMPLETE42/111,0 failed**:
case42 R5 filter/paging took109.7ms in one unit, wall5860.4ms. The100ms fail-safe correctly
stopped it; remaining69 cases did not run. Warning recurrence and actual interactivity
were not supplied. K3a adds safe fixture boundaries without removing assertions, reducing
37-row stress work or changing the runner/threshold. K3a subsequently passed62/111
with0 failures but stopped at case63's combined maximum-report unit140.4ms,
wall20823.1ms. No individual constructor/capture/format timings, explicit warning
recurrence or interactivity evidence was supplied. K3b slices the full512-path setup,
capture and both real formatting workloads; all old111 assertions/stress remain and
12 job cases are appended. K3b subsequently stopped **INCOMPLETE66/123,0 failed**,
case66 unit1/case return102.8ms, wall65297.9ms. Case63 maximum stress and64–65 passed;
57 cases remain uncompleted, and appended cases112–123 did not execute. No individual
setup/command/UI timing or explicit warning recurrence/interactivity report was supplied.
The preceding case65 boundary does not establish timing causality; neither does the
historical BugGrabber warning. K3c adds exactly four outer checkpoints in case66 between
complete combat/UI groups and its two real synchronous35-path commands. Each actual
capture+format+Show remains fully atomic, unchanged and unmeasured individually; this
does **not guarantee each command<100ms**. The next K3c user run stopped
**INCOMPLETE79/123,0 failed**, case80 unit1 [K2 scope variant]123.1ms,
wall70914.9ms.79 cases completed PASS,80 started but did not complete,44 remain
uncompleted, and appended112–123 did not execute. Case66 passed this run. No separate
setup-phase timings or explicit warning recurrence/interactivity report was supplied;
the preceding case79 start boundary does not establish timing causality.
K3d adds seven outer pause sites after complete case80 raw/evaluate, Apply, active
Open, Archive and archived Open operations, at incoming wrong-scope variants and
before legacy setup. Existing callback/scope-variant checkpoint and all123 ordered
definitions/assertions/parameters/full35-path workloads remain. Core operations stay
atomic, with no pause inside a protected operation or temporary override; individual
operation latency is unmeasured, **not guaranteed<100ms**. Runner/100ms/10000-step cap,
Commands, KnowledgeCheck and production accounting are unchanged. The next user run
then stopped **INCOMPLETE64/123,0 failed**, case64 unit1/case return100.5ms,
wall102289.1ms:64 completed PASS,59 uncompleted. Case63 completed2599 units; its starting
boundary does not establish timing causality. Case80 was NOT REACHED this run, so this
is not new case80 performance evidence; prior79/123 remains separate history. New
cases112–123 remain unexecuted. No individual command timing or explicit warning
recurrence/interactivity report was supplied.
K3e adds four outer checkpoints after case64 setup, the valid command/assertions, the
invalid command/assertions and the missing-runtime/immutable-DB/collector/chat checks.
The two real synchronous35-path commands now run in separate unchanged trappedCapture
helper calls: each has its own forbidden-call traps, protected call and full runtime
graph verification. C.Apply/K.Evaluate are restored before either outer pause; no yield
occurs under pcall or shared override. All original statements/assertions/parameters,
123 ordered cases and workloads remain; helper/runner/Commands/KnowledgeCheck/K2 and
100ms/10000-step limits are frozen. Each command remains atomic and individually
unmeasured, **not guaranteed<100ms**.

The latest user run then stopped **INCOMPLETE81/123,0 failed**, case81 unit1/case
return385.3ms, wall73206.2ms:81 completed PASS,42 uncompleted. Case80 passed this run;
cases112–123 remain unexecuted. The starting case80 boundary does not attribute the
case81 combined time to case80. No individual Scan/Core/ViewModel timing or explicit
warning recurrence/interactivity report was supplied.
K3f adds ten outer pause sites to case81 between complete fixture, first Scan and
evidence assertions, fresh ViewModel/hover, Copy, Open, historical ViewModel, Archive,
archived Open, hidden-archive ViewModel and archived ViewModel/assertion groups. Its
final time change/second full Scan/old-generation assertion remains atomic to return.
Adjacent case82 gains seven outer pause sites: per-variant fixture, first Scan/old
reference, Copy/time change, complete failure injection, second Scan/all four-tree
freshness/index assertions, final standalone fixture/currency mutation and final Scan.
Existing variant checkpoints and ViewModel/tooltip/reason assertions remain. Every
real Scan/Copy/Open/Archive/ViewModel is complete and atomic; no injected API yields,
jobs/stubs, smaller workloads or changed assertions. All123 ordered cases, production,
runner and100ms/10000-step limits stay unchanged. K3f Lua/native execution is **NOT RUN**;
individual atomic latency is unknown, **not guaranteed<100ms**. A later atomic slow-stop
returns to planning, not weakened integration/coverage.

1. **Wait for primary's independent K3f review.** Only after review/primary coordination,
    fully quit WoW and back up `WTF`, including production/diagnostic SavedVariables.
   Already on K3e: replace **only `CraftArmy/SelfTests.lua`** with the reviewed K3f file.
   Keep **`KnowledgeCheck.lua`**, **`Commands.lua`**, all K2/other addon files,
   `CraftArmyDB`, diagnostics and all SavedVariables unchanged.
   Same version0.2.0-mvp/Interface120105/schema1; no reset.
2. Login/reload, then explicitly run **`/ca selftest` out of combat**. It is asynchronous:
   STARTED reports the actual
   total (**123 definitions**, not a promised pass). It executes at most one safe unit
   per native frame; large stress operations/parameter variants have internal safe
   boundaries. The game should remain interactive, but this is **not yet measured**.
   Wait for and report explicit **COMPLETE/INCOMPLETE** counts, elapsed wall/max-unit
   timing, case/unit/label and warnings/errors, including whether the game stayed
   responsive and whether the execution-limit warning recurred.
3. While running, repeat `/ca selftest` only for status or use **`/ca selftest cancel`**
   to release work. Progress appears every10 finished cases or each second during
   multi-unit work. Entering combat stops INCOMPLETE before further units; leaving
   combat never resumes automatically. No clock/Frame capability means no start.
4. A measured atomic unit **over100ms stops INCOMPLETE**, even if the last case passed.
   It cannot interrupt an atomic operation already running; no hard latency guarantee
   is claimed. Missing/invalid/backward clocks, unsafe function drift or callback
   errors also stop. Share the case/unit/label/timing **once**; do not repeatedly rerun
   the unchanged version or wait through freezing. A new slow-stop also means stop and
   share once, not raise the limit, skip tests or rerun unchanged. Function-drift reports
   require reload, not manual repair. No automatic resume occurs.
   Report failures/cancellation as incomplete evidence; preserve data and backups.
5. Primary must record satisfactory **safe complete fixture execution and responsiveness**
   before the K2 current four-bar/hover/unspent comparison resumes. Until then it stays
   paused. Injected fixtures and fake-frame tests never establish target-client APIs,
   actual frame scheduling/performance or all-rank costs. `/cad selftest` is separate,
    unchanged and not requested again by this correction.

#### K3b read-only job contract (module callers; unchanged by K3f, not a new command)

`KnowledgeCheck.NewCaptureJob(env,runtime,options?)` and
`NewFormatJob(report,options?)` return jobs with `Step()` / `Cancel(reason?)`,
`status` (`running`, `complete`, `incomplete`), `completed`, `steps`, `phase` and a
bounded `label`. `Step` executes at most one unit: metadata, tab currency/root,
one complete path, per-tab reconciliation, up to **eight format add attempts**
(including clipped no-ops), or a bounded footer/phase transition. One bounded
record encode/final concat remains atomic, not preemptible. All collection limits,
256KiB/4096-line output and4096-byte summary reserve remain unchanged. Collection
still visits every bounded path after clipping; it never shrinks stress to pass.

Capture owns its private report. Format **borrows caller-owned immutable input until
terminal**; do not mutate it while stepping. No full-report `Core.Copy` is used.
Running jobs expose no `report`, `text` or `summary`. Only completed jobs publish
their result; `completed=true` means work finished, **not** `report.captureComplete=true`.
Missing APIs, unstable/staged boundaries and clipping still prevent complete data.
Whole-interval context/config/source/runtime tokens are not refreshed per slice;
capture time ends at collection finish, and formatting does not requery live context.

Optional plain `options` recognizes only `stepLimit`: integer1..10000, default10000;
it can only lower the cap. Invalid options, exhaustion and private failures stop
`incomplete`, with sanitized reason/no results. Cancellation also stops incomplete;
terminal jobs release their coroutine and its env/runtime/input/buffer references.
Repeated Step/Cancel are inert. Independent jobs do not share work. No yield crosses
an API pcall, native operation or temporary namespace override.

Public `Capture` and `Format` remain **synchronous compatibility drains**. Unexpected
capture failure returns fresh sanitized incomplete evidence rather than partial data;
unexpected format failure returns a bounded unmistakably incomplete version1 report,
never a passing prefix. `/ca knowledgecheck` and its copy UI remain synchronous,
read-only, ephemeral and provisional: this refactor is **not** an asynchronous command
or a real manual-capture performance guarantee. Commands/K2 accounting/DB/schema and
diagnostics are unchanged; no profiling/error-handler changes, scans or spending are
requested here. Native full completion/responsiveness/warning and bar checks stay pending.

### K2 native-rank bars (historical update; native checklist paused pending safe completion)

Version **0.2.0-mvp**, Interface **120105** and schema **1** stay unchanged. The prior
K1 user **66/66** and complete native report are baseline evidence only. K2 defines
**96 cases** (all66 byte-exact retained +30 K2 definitions, including9 review-correction
cases). User96/96 assertions now PASS, but lockup/warning blocks performance acceptance.
The historical five-file update/selftest instructions below are superseded by K3e's
SelfTests-only update/review gate for users already on K3d; **do not repeat the old suite**.
Injected fixtures are not API proof.

K2 corrected static re-review passed; this does not clear the new responsiveness gate.
The following records the previous update and deferred native comparison scope.

1. After primary's independent K2 review, fully quit WoW and back up `WTF`, including
   production and diagnostic SavedVariables. If already on K1, replace **only
   `Core.lua`, `Knowledge.lua`, `Collectors.lua`, `ViewModel.lua`, `SelfTests.lua`**
   in the existing CraftArmy folder with the reviewed files. Preserve all other
   addon files, `CraftArmyDB`, all SavedVariables and all diagnostics. No reset,
   schema edit, new dependency or gameplay action is needed.
2. Login/reload and run `/ca selftest` **first**. Report actual counts, all complete
   failure lines and any load/disabled-data error.96 is a definition count, not a
   promised pass. Stop on failures; primary must record satisfactory results before
   live comparison. `/cad selftest` remains independent; no fresh diagnostic run is
   implied or needed to establish this production correction.
3. Then open your own ready **Midnight Inscription**, out of combat, with **no pending
   specialization changes**. Manually `/ca scan`, then `/ca`. Compare all four bars,
   tree/path hover and separate unspent KP with the native UI. Report current values,
   status/tooltip text and any mismatch. Historical264/870 is NOT an expected current
   balance/capacity; never change ranks or saved data to force that match.
4. Hover must identify **native rank points/shared-spent reconciled**, compare the
   profession-wide shared spent **once**, and explicitly say **NOT verified
   future/all-rank costs**. Locked paths show their distinct unlock token, not an
   invented KP cost or lock state inferred from `isAvailable`. No purchases,
   unlocking, spending or automatic profession switching is requested.
5. Missing, malformed, staged, changing, truncated or mismatching inputs fail closed
   for **every tree**. Existing coherent numbers/times remain stale/last observed;
   the entire prior index and its time remain failed/last-observed too, so all prior
   trees stay visible with retained tree names. Without prior numbers the bar stays
   unknown, not zero. A known0/positive-cap bar
   is genuine observed zero. Retained hovers use the retained tree's own evidence/time,
   never newer raw ranks/currencies. Reload/offline/archive retains snapshot semantics,
   not permanent freshness. Report failures rather than reset data.

Production now captures all bounded currency rows (up to64/tab), costs16/node/entry,
entries32/list/map and the full8tab/64path/16child graph, including locked branches.
Only Inscription2913/773/profession13/expansion11 can use the new policy. Complete
entry/rank/state/current-cost metadata, stable unstaged boundaries and identical
shared rows across every tree are mandatory; other currencies never add to KP.
Current unit costs are guards, not proof of future rank costs; `costRule` remains
unknown, separate from this distinct policy. Other profession/field gates remain open.

`/ca knowledgecheck` itself is unchanged: read-only, ephemeral and **PROVISIONAL**.
It does not write snapshots, scan the dashboard or confer production eligibility.

### K1 knowledge evidence (historical update instructions; command unchanged)

The prior corrected R6a **50/50** user fixture result and separate diagnostic **23/23**
are historical. K1 defined **66 cases** (all50 retained +16 new); user66/66 and one
complete native report are now recorded in evidence. Injected APIs/widgets do not prove
target-client behavior. Version0.2.0-mvp, Interface120105 and schema1 are unchanged.

1. Wait for primary's independent K1 review. Fully quit WoW and back up `WTF` and
   both production/diagnostic SavedVariables. In the existing CraftArmy addon folder,
   add **`KnowledgeCheck.lua` (new)** and replace **`CraftArmy.toc`, `Commands.lua`,
   `SelfTests.lua` only** with the reviewed K1 files. Preserve every other addon file,
   `CraftArmyDB`, all SavedVariables and the entire diagnostic addon/samples. Do not
   reset data, reinstall dependencies or alter the schema to hide a failure.
2. Login and `/reload`, then run `/ca selftest`. Report actual counts, every failure
   line and any load/UI/disabled-data error.66 is a definition count, not a promised
   pass. Stop/report failures and preserve backups. `/cad selftest` is separate,
   optional reconfirmation of unchanged diagnostics; no fresh diagnostic run is claimed.
3. Once primary records satisfactory fixture results, open your own ready **Midnight
   Inscription** normally, with no pending specialization changes, out of combat.
   Run `/ca knowledgecheck`. Do not spend/unlock, switch professions automatically,
   or run `/ca scan` merely to obtain this report. The command needs the existing
   session collector token, but bypasses Login/DB initialization and snapshot scanning.
4. Use the scrollable multiline window: select all (Ctrl+A), copy manually (Ctrl+C),
   and inspect the full report before sharing through primary. Close or Escape hides
   the window; edits restore the original report. Each explicit invocation replaces
   the prior ephemeral text/window contents, not an append-only history. No clipboard,
   file, network or upload API is used. Reload discards this unsaved report. If native
   UI methods are unavailable, chat explains the limitation; it does not dump partial
   evidence into chat. Combat/unknown safety does no capture/window/focus/timer or
   deferred automatic work: issue the command again yourself when safely out of combat.
5. Check the version1 beginning/end, `captureComplete`, `outputTruncated`, stable
   unstaged boundaries, per-tab discovered/captured paths and currency-row statuses,
   plus the end summary. The earlier observation had35 paths; the command discovers
   current paths rather than promising/hardcoding35. Missing APIs/fields, sparse or
   malformed lists, cycles/shared ownership, changing context/tokens, limits or output
   clipping explicitly prevent a passing complete capture/aggregate. Empty costs or
   children are distinguished from missing data; missing entryCost is never zero.

Privacy: only sanitized game tab labels, numeric profession/trait/config/tab/path/
entry/currency identifiers, raw rank/cost data, boundary tokens and build/locale/time
metadata are exported. No character GUID/name/realm, gear, saved snapshots or raw error
payloads are included. Review even this limited local report before manually sharing.

Bounds:8tabs,64paths/tree,16children/path,32entries per node list/map,64currency rows/
tree and16costs per node/entry. Arrays are densely validated with bounded key inspection.
Text is limited to256KiB/4096lines with4096bytes reserved for the end summary; clipping
makes capture incomplete and reconciliation unknown, never a smaller successful report.

Candidate rank points/capacity and current unit-cost consistency are separate from
**verified all-rank costs**. Even a provisional match compares one common shared
currency's identical committed spent balance **once**, not once per tab. Other
currencies stay separate; repeated rows are not per-tree allocations. Mismatch/unknown
does not adjust raw ranks or write snapshots. K1 did not enable production numbers or
repair the then-first8 production currency gap. K2 separately replaces that gap with
complete bounded64 capture and the guarded native policy above; K1's report and
provisional accounting remain unchanged. Knowledgecheck does not alter the
validated diagnostic addon, enable numbers, prove all ranks or complete T02 acceptance.

### R6a fixture-only correction (historical update instructions)

The initial R6 user run reported **49 PASS / 1 FAIL of50**. The failing rarity-fill
retention subcase omitted item identity in its seed/retry. Existing storage correctly
cleared unidentified metadata; the fixture incorrectly expected retention. R6a fixes
the isolated test setup, not production code: identified same-item failure must still
retain rarity/time/alpha0.18, while unidentified or changed-item failure must clear
old metadata/colour. The original failure remains recorded in evidence.

If you already installed R6's reviewed ViewModel/Dashboard/SelfTests:

1. After focused R6a review, quit WoW and back up `WTF`/SavedVariables as usual.
   Replace **only `CraftArmy/SelfTests.lua`** with the reviewed correction. Leave all
   production Lua, TOC and other addon files unchanged. Preserve `CraftArmyDB`, both
   production/diagnostic SavedVariables and diagnostic samples; no reinstall or reset.
2. Login and `/reload`, then run `/ca selftest`. There are still **50 definitions**;
   report actual counts and complete failure/load/disabled-data errors. The corrected
   suite is **NOT RUN** until a result is supplied;49 earlier passes are not50/50.
3. Stop/report any error without resetting saved data. Resume the R6 native screenshot/
   dropdown/hover checklist below only after primary records satisfactory review and
   corrected fixture results. This correction adds no native API/render evidence.

If R6 is not yet installed, use the initial three-file R6 update below with the
reviewed corrected SelfTests. No production-file replacement is needed for users
already on R6. Separate `/cad selftest` is optional reconfirmation of unchanged
diagnostics; no fresh diagnostic result is implied by this correction.

### R6 table iteration (initial update and native checklist; user only)

R5's user-reported **46/46**, limited native one-/two-row screenshots, clean Tool
tooltip and filter shrink/grow remain historical evidence. R6 has **50 shared fixture
definitions**. The initial user result is49/50 as described above; corrected R6a
fixtures and native tests remain NOT RUN until actually supplied. Fake-menu fixtures
are not installed-client API evidence.

1. After primary independent R6 review, quit WoW/back up `WTF` and both SavedVariables.
   Replace only the reviewed `CraftArmy/ViewModel.lua`, `CraftArmy/Dashboard.lua` and
   `CraftArmy/SelfTests.lua` in the existing addon folder. Preserve all other addon
   files, `CraftArmyDB`, diagnostic samples and every SavedVariables file. Same
   version0.2.0-mvp/schema1; no reset/reinstall needed. Login and `/reload`.
2. Run `/ca selftest`; report exact counts and complete failure/load/disabled-data
   errors (50 is a definition count, not a promise). Run separate `/cad selftest` if
   reconfirming unchanged diagnostics; previous23/23 is not a fresh result. Stop on
   any error, preserve backups and report through primary; do not reset saved data.
3. Using existing snapshots, send one-/two-row screenshots. Check all14 columns on
   one line, separate Name/Realm and Tool/Stat/Enchant, full stat names without amounts,
   known enchant name vs blank confirmed none vs lone `?` unknown. A1/A2 retain full
   hover headers. Item/quality glyphs must have no redundant R#; known rarity fills
   stay readable under row selection, unknown/empty slots must not inherit colors.
   Do not equip/enchant/spend just to generate boundary cases.
4. Open Profession: All plus eight family choices, selected check/text and All reset.
   Select Inscription/another available saved family, switch active/archived view,
   combine with character name/realm filter, clear filters and verify snapshots remain.
   No fresh scan should be caused by menu selection. If capability fallback appears,
   report its explanation and confirm All rows are reachable, no hidden selection.
5. Check dropdown decoration stays below status and above headers, with no overlap.
   Unscaled content1424/outer1454; heights216 for0/1 rows,238 for2,458 for12+.
   Filter shrink/grow, wheel/paging, footer and confirmation **Cancel only** remain
   usable. No actual retirement/deletion needed. Fit is local only, positive and≤1;
   no global UI scale change. Report small-screen/clipping/large-list edge cases.
6. Hover Tool, Stat and Enchant: each retains native item/third-party rebuilt text plus
   numeric totals/raw keys, field times and attribution/unknown enchant details. Hover
   Last Updated for exact scan/per-field times, snapshot/fresh/stale/archive context;
   main value must be relative scan age only. Confirmed missing enchant stays blank
   with amber fill and explained historical/fresh attention; unknown never means missing.
   Status/raw-reason hover and safe addon-only icon cleanup remain unchanged.

This presentation pass does not unblock knowledge costs, other Midnight mappings,
cap/role/stat attribution or lifecycle/native edge gates. Theme remains deferred.

### R5 presentation update (historical instructions, superseded by R6)

The following records the prior update/check scope. Subsequent user results are in
evidence; use the R6 instructions above for the current files, count and geometry.

R4's reported40/40 fixtures and limited native field/tool/reload/two-character checks
remain historical evidence, not a pass for this UI refinement. R5 defines **46 shared
cases**; the new fake-widget cases are unexecuted until results are supplied.

- After primary R5 review, quit WoW/back up `WTF` and replace only the reviewed
  `CraftArmy/Dashboard.lua` and `CraftArmy/SelfTests.lua` addon files in the existing
  folder. Keep every SavedVariables file, Data/other addon files and diagnostics.
  Same0.2.0-mvp/schema1; no reset or reinstall required. Login and `/reload`.
- Run `/ca selftest` and report actual counts/errors (46 is the definition count,
  not a promised pass). Stop on failures. Separate `/cad selftest` can reconfirm the
  unchanged diagnostic; old40/40 does not validate these presentation changes.
- With existing snapshots only, send one-row and two-row screenshots (use the
  character/profession filters if needed). One22px line per pair remains; A1/A2/Tool
  headers have full hover labels. Unscaled frame width1276, content1246, height198
  for one/zero rows,220 for two,440 at12+. Paging/wheel still reach larger filtered
  sets using12 reusable rows. Filter/archive changes resize and clamp the page.
- Check toolbar, selection footer, paging and scope confirmation/Cancel remain
  separate and readable. Do not actually retire/delete records just to test layout.
  Full character/profession text is available on cell hover if clipped. No font
  shrinking or global UI scale change; local fit uses both screen dimensions with a
  30px margin when usable. Missing/invalid dimensions (or no positive room after that
  margin) impose no fit constraint; local scale stays positive, at most1. Truly
  unusable screen sizes cannot be promised a 30px fit and need a client report.
- Close the normal profession view and check saved-snapshot status, then hover the
  status for its original raw reason. Success still states knowledge totals pending;
  unknown/error/write-disabled reasons must remain precise, not generic success.
- Hover Tool: native item/third-party rebuilt content should remain intact, plus
  addon snapshot times, slot/rank/stat details, full enchant label/category and
  attribution-unknown explanation. Complete addon atlas/texture decorations are
  removed from appended plain text; malformed/other pipe markup remains escaped.
  No enchant rank/amount is inferred, no BIS/chat suppression is attempted. Report
  clipping/tooltip regressions; native R5 rendering remains a separate acceptance gate.

The original field/knowledge/mapping/cap/lifecycle evidence gaps remain open; this
polish changes no collected/saved values or supported professions. No live gameplay
or install/release action is performed by agents.

1. After independent static review, load the addon; record build/locale/addon version,
   errors and `/ca selftest` results, then separate `/cad selftest` results. Do not
   request crafting, purchases, equipping, enchanting, unlearning or knowledge spending.
2. Open own Midnight Inscription. Compare skill/modifier, dynamic concentration/cap,
   Moxie, all three gear rarities/ranks, tool stat totals and enchant8005 category to
   normal UI. Historical balances/items are not expected current values. Record safe
   unknowns as gaps, not passed fields. Verify roles against the actual native UI.
3. Compare complete knowledge paths, actual unlock-entry maxRanks0/1, committed ranks,
   all-rank cost semantics, no staged/increased ambiguity, native tree totals/caps and
   shared spent once. Numeric engine remains disabled in production until this proof
   supports a separately reviewed eligibility rule. Do not spend points to test it.
4. Close professions, inspect a linked/guild context only if normally available,
   observe existing delayed item loads, reopen; verify no incorrect attribution or
   zero/empty regression. Combat deferral and event bursts must not create scan loops.
5. Reload/relog, then another available character/profession: verify separation,
   timestamps, historical warnings, last-observed concentration and saved snapshots.
   Other mappings remain pending; eight-profession acceptance stays incomplete.
6. Check all columns on one line, scale/scrolling, bar and gear tooltips, filters,
   stable sorting, selection and scoped Confirm/Cancel. Use isolated fixtures for
   boundary/archive/relearn cases unavailable safely; label fixture-only evidence.

Record each outcome/limitation in [evidence](evidence.md) through the primary.
Delivery → independent review → client acceptance → separately approved release
are distinct gates. This guide is not publication or gameplay-mutation approval.
