# CraftArmy — living plan

> Authoritative record of confirmed decisions, not assumed approvals. Read with
> [TASKS](TASKS.md) at the start of work. Current requirements stay here; preserved
> histories live behind links. Proposals in [docs/design.md](docs/design.md) do not
> authorize implementation. Use `living-plan` for interviews and document maintenance.

## Overview

CraftArmy is a World of Warcraft Retail addon for managing crafting alts from one
summary screen, with a separate profession-leveling guide module that prioritizes
knowledge progression and generates shopping lists exportable to Auctionator.

**2026-11-17:** diagnostics and the dashboard are implemented; guides are not built.
S01 storage refresh succeeds on multiple previously blocked characters, and older
snapshots remain correct, as reported by the user. **R01 redraw correction confirmed
in game**: user reports the table no longer disappears during scans or profession
window open/close. Accept that focused visibility result, not unreported interaction,
error/freeze or measured timing checks; no further redraw retest requested.
Broader native controls/performance/field acceptance remain open.

**2026-11-18 DASHBOARD SIGN-OFF:** user explicitly says “I am happy to sign off on the
dashboard.” Current dashboard milestone accepted; no routine retesting requested. This
does not relabel incomplete native-suite/all-rank/estimate-accuracy evidence or infer
unreported procedures. Before the next section, user requests a GitHub repository under
**Arbixal/craftarmy**. User explicitly chooses PUBLIC visibility and local initialization,
initial commit/main push of reviewed code/tests/assets/project docs after sensitive-file
review. Public [repository](https://github.com/Arbixal/craftarmy) created; local `main` and
`origin` configured, repository-local GitHub noreply identity used. Root README/.gitignore
added; caches/credentials/runtime data excluded without deleting local files. Git status/
log and remote branch SHA are the delivery source of truth. No tags/releases/deployments
authorized; future Git mutations need their own scope. No guide work begun.

**2026-11-18 next step:** user approves preparing a dashboard gap checklist. The
[focused completion checklist](docs/dashboard/completion-checklist.md) separates six
remaining normal-use checks from accepted work and explicit semantic limitations.
Final checklist follows the approved U13 refinement batch below, then explicit dashboard
sign-off. Checklist preparation alone did not authorize guide work.
No repeated accepted checks, blanket scans or full native timing chase.

**2026-11-18 checklist feedback:** user confirms C4 window behavior and C6 selection/
Cancel confirmations function as expected. Do not repeat. C5 now has an authorized tooltip
cleanup (U15): normal Tool/Accessory hovers native-item-only, addon extras on Shift; remove
routine observed-age/Attention/Shift-diagnostics-hint lines from normal dashboard hovers
and the long Concentration assumptions sentence. Keep estimates explicitly `~`/Estimated,
real unknown/stale/archived/pending safety cues and complete Shift provenance/assumptions.
No native/third-party item text stripping, observed-data or filter changes. After U15,
only focused tooltip acceptance and explicit overall dashboard sign-off remain; no guide
implementation authorized. U15 delivered/locally accepted2026-11-18 after independent
scoped-static/PRIMARY512/all19/744K6/565K7/23/Python, exact3targets/27original+7addition
test preimage/whole Dashboard+ViewModel reversal/39-input preservation PASS. User now
confirms cleaner tooltips and Shift reveals diagnostics as before: focused U15/C5
presentation/diagnostic availability accepted2026-11-18. No repeat check; dismissal/scroll
procedures not separately reported or inferred. Ready for explicit overall dashboard
sign-off decision with existing limitations, not automatic guide implementation. Contract in TASKS;
[review](docs/dashboard/tooltips-u15-review.md), [thread](docs/questions/Q05.md).

**U13 approved2026-11-18:** user agrees to all proposed Moxie/Concentration/scrolling
refinements and requests current-character priority/dot. Center Moxie, remove `!`, green
strictly above600 (U14 below supersedes historical dimming). Show observed blue Concentration plus
cyan estimated additional regeneration, `~estimated/max` when increased; only observed
full is green. Estimates remain approximate, never saved and never drive sorting/attention;
invalid/archived/retained views use observed-only. This supersedes U09's tooltip-only/bar
restriction, not its observed sorting/filter/data guarantees. Add scrollbar/wheel and
row-range text, remove Previous/Next; retain12 visible reused rows/no character cap.
Filter first, then current player's matching GUID rows (both professions when eligible)
before other characters in every sort; apply selected sort within each group. This is
list ordering, not sticky viewport rows. Small dot after each current-character name;
identity is current player GUID, never guessed from name/class or saved as freshness.
U13 delivered/locally accepted2026-11-18; independent scoped-static PASS then PRIMARY
512/all19U07/744K6/565K7/23/Python, exact3targets/40original+22addition test preimage,
whole ViewModel reversal and39-input preservation PASS. Latest user confirms current
character first/dot, centered/no-marker Moxie and green>600, visually distinct observed/
estimated Concentration, expected sorting/filtering, visible draggable scrollbar and row
count. Accept reported scope, not unreported checklist procedures or quantified accuracy.
User reports drag performance impact greater than wheel and thumb not visually reaching
track endpoints. **U14 locally accepted2026-11-18:** use same Moxie green for known>600 fresh/
snapshot/historical values (freshness stays in tooltips; no sort/filter/data changes), skip
unchanged scroll offsets and coalesce drag repaint to one per frame; use a solid opaque
thumb rather than padded knob art. Independent scoped-static/PRIMARY512/all19/744K6/565K7/
23/Python/exact2targets/13original+13addition full test preimage/wholeDashboard reversal/
40-input preservation PASS. Same direct primary synthetic100ScrollTo(1) dispatches1Render
instead of100. These counts do not prove client timing, actual lag cause or native endpoints.
User now reports “Moxie colour looks good, the scrollbars go to the full bounds now, and
performance is good.” U14 focused native brightness/endpoints/normal-use drag performance
accepted2026-11-18; no repeat check. No measured timing or exact native causal proof inferred.
[U14 review](docs/dashboard/scroll-u14-review.md).
[Review](docs/dashboard/refinements-u13-review.md). Final checklist revised for U13;
existing focused acceptance stays accepted. [Decision thread](docs/questions/Q05.md).

Current primary source validation (U15,2026-11-18): **512/512 top-level cases**, all19 U07 workloads in4
groups plus additive UI/parser checks; unchanged744K6/565K7, diagnostics23/23 and both Python
checks PASS. U15 has7 additions/27 explicitly authorized inline-original adaptations;
exact pre-U15 test bytes reconstruct. No runner/cap change. Independent U15 scoped-static PASS;
executable/comparison evidence remains primary-attributed, not independent. The external
derivative S01 bundle remains ungenerated after a denied helper write; no bypass/retry.
Full native suite stays **INCOMPLETE 87/149** and all-rank costs **UNVERIFIED**.
These are local execution/static-review results, not native client acceptance.

User confirms U07 “it all looks good” at the requested focused marker/filter scope;
no itemized procedure/timing or blanket native acceptance inferred. No repeat check.
Icon pack imported/locally accepted as M01: all nine supplied root `media/` files copied
byte-for-byte into `CraftArmy/Media/Icons/`, filenames/originals retained. No conversion
or native render claim at import. Main CraftArmy.tga is64px, with128/256px TGA
variants and32–1024px PNGs. [Asset manifest/usage](CraftArmy/Media/Icons/README.md).
U08 title icon delivered/locally accepted:22px decorative icon at dashboard top left,
packaged64px CraftArmy.tga, title only shifted/shrunk28px with unchanged wording/right
edge. Protected failure keeps plain title. Independent static PASS; fresh PRIMARY512/512,
all19 U07 workloads,744K6/565K7/23/Python and exact-target/preservation checks PASS.
User “It looks good” accepts focused title-icon appearance; no repeat check needed.
Do not infer unreported drag/close procedures or timings; no rescan/fullselftest.
No TOC metadata change. [Review](docs/dashboard/title-icon-u08-review.md).
U09 focused user feedback accepted. **U10 gear redesign locally accepted, native PARTIAL:**
rarity borders overridden red for confirmed older-expansion gear, quality top left,
positive-only enchanted badge top right, large semi-centered Tool-only stat letter.
One **Gear** header with no sorting; remove visible Stat/Enchant columns and narrow
window rather than stretch. Accessory1→Accessory2→Tool order and tooltips retained.
Source-checked optional item-expansion/tool-only metadata collection during ordinary
own-character scans. User confirms quality/E badges work, but reports no red border for
Khaz Algar gear or Tool letter even after an updated-addon scan; tooltip says Item expansion
unknown/Tool's own stat unavailable. Do not label this cache-only or native metadata PASS.
**U11 locally accepted refinement/correction:**24px icons/28px rows and4px icon gaps bothaxes;
fix locally reproduced item-link parser rejection of quality markup in display labels.
Primary full512/all19U07/744K6/565K7/23/Python/exact-target/preimage/39-input/media checks
PASS after independent static PASS. Latest focused native feedback: red borders now show,
Resourcefulness Tool shows R, and internal icon spacing is correct. Multicraft consistently
shows `...` across multiple characters; outer Gear/progress-bar spacing is cramped.
Accept those focused results, not blanket API/input acceptance or exact causal proof.
**U12 presentation correction locally accepted2026-11-18:** natural-size, single-center-anchor Tool letter
at existing14px font (remove fixed18×18 clipping box), font before text on render; preserve
intrinsic M mapping. Add6px outer padding each side of Gear, keep24px icons/28px rows and
4px internal gaps. Gear96px/content1138/window1168; no bar or other column stretching.
Independent static PASS then PRIMARY full512/all19U07/744K6/565K7/23/Python and exact-target/
25+3 preimage/whole Dashboard reversal/40-input preservation PASS. User now confirms
“M is visible and the gaps look great.” U12 focused native M visibility/outer-spacing
acceptance COMPLETE2026-11-18; no further check or scan requested. Exact font-engine cause,
unreported interactions and broader native acceptance are not inferred.
[U12 review](docs/dashboard/gear-u12-review.md).
[Review](docs/dashboard/gear-u11-review.md).
Primary exact-target512/full supplements/23/Python/preservation PASS; parser defects and
reviewed quality-layer finding corrected and renewed static PASS. No writer remains.
[Review/acceptance](docs/dashboard/gear-u10-review.md).
Concentration U09 delivered/locally accepted: observed-value bar without visible `!`, plus
tooltip estimates. U13 supersedes tooltip-only with a cyan estimated-gain segment/approximate
total; observed base, sorts, attention filtering and stored observations stay observed.
Independent static/PRIMARY full local
checks and preservation PASS. User “Everything looks good and as expected” accepts the
focused bar/tooltip result; no repeat check requested. Quantified recharge phase/rounding/
offline accuracy and unreported procedures remain unverified. No writer.
[Review](docs/dashboard/concentration-u09-review.md), [decision thread](docs/questions/Q05.md).
Local investigation reproduced table clearing
on profession close without storage changes; native timing/complete causality remain
unproven. [Investigation/proposed direction](docs/dashboard/redraw-investigation.md).
**R01 redraw-only correction delivered/locally accepted**, 2026-11-17, after user “Yes
fix redraw first”. Retain completed rows as explicitly last-observed/noninteractive
during guarded asynchronous replacement; coalesce identical running work. Both review
findings corrected and re-reviewed; no data/collector/schema/budget changes. Follow-up
bars/gear colors are not included. User confirmed the targeted redraw symptom resolved
2026-11-17; broader native acceptance remains separate. **U06 Skill-only bar delivered/
locally accepted** after user “Yes, I like this approach”. Flat centered current/max
bar uses saved skill/cap, smooth red→amber→green and neutral unknown; no bonus added.
User “Everything looks good” accepts the focused Skill-bar check at the reported scope;
individual procedure/timing details are not inferred. User now requests removing the
Skill `!` and suggests Progression filter should select non-max Skill rather than
combined Knowledge progression. User “Yes” approves removing Skill-only `!` and renaming
the Progression option **Skill below max**, matching known Skill below known positive cap,
excluding unknowns and independent of Knowledge. U07 is authorized; other indicators
and default attention ordering unchanged. Settled active queue is in TASKS.
Concentration/gear-red not included. [U06 review](docs/dashboard/skill-u06-review.md).
[R01 review](docs/dashboard/redraw-review.md), [TASKS](TASKS.md),
[S01 review](docs/dashboard/s01-review.md).

## Decisions

`🔨` marks requirements with unfinished implementation or acceptance, not a claim that
the entire decision is unbuilt. Later confirmed refinements supersede older wording;
historical gates and thread-opening statuses are not current instructions.

### D01 — Retail crafting-alt management 🔨

- Target World of Warcraft **Retail**, not Classic.
- Track the user's crafting alts and expose their profession progress together.
- The exact supported expansion/build and profession coverage remain [Q01](docs/questions/Q01.md).
- Source: original user request, 2026-11-05.

Current expansion/profession scope is settled in D05; exact target-client API/build
evidence and unresolved semantics remain in Q03, not inferred from scope alone.

### D02 — Required summary information 🔨

For each character and profession, display:

- Character name and profession name.
- Profession skill level.
- Profession equipment rarity: uncommon, rare, or epic.
- Profession enchantment status: yes/no.
- Concentration.
- Moxie, highlighted when **greater than 600**; 600 itself must not trigger it.
- Knowledge point distribution.

Per-slot gear, enchant interpretation, Knowledge layout and offline snapshots were
subsequently confirmed/refined in D07/D10 and [Q05](docs/questions/Q05.md); they are not
still pending general UI approval. Unknown data must never look like an observed zero,
confirmed missing item or confirmed absent enchant. Remaining API semantics stay open.

### D03 — Separate knowledge-prioritized leveling guide 🔨

- Provide a separate module with a guide for leveling each supported profession.
- Prioritize unlocking maximum knowledge points; the precise optimization objective
  remains [Q02](docs/questions/Q02.md).
- Include an ordered list of required crafts and a material shopping list.
- Support sending the shopping list to Auctionator.
- Break leveling into a useful lower-cost stopping point and continuation to maximum
  skill. Determine milestones per profession rather than assuming one universal level.
- Source: original user request, 2026-11-05.

### D04 — Durable planning workflow

- Use `PLAN.md`, `TASKS.md`, and `AGENTS.md`, with a project-local OpenCode
  `implementer` definition inheriting the session model.
- Keep the detailed proposal in `docs/design.md`, open threads in `docs/questions/`,
  and maintenance history in `docs/rebalance-log.md`.
- Use the existing proposal as starting material; distinguish user requirements from
  unconfirmed recommendations. Do not begin implementation as part of this write-up.
- No external task mirror was named; these project documents are the source of truth.
- Source: user approved the proposed file layout, 2026-11-05.
- Task cleanup approved2026-11-17: user confirms the11-archive layout after a manifest.
  Preserve original contracts/reports with mechanical link rebasing, keep genuine open
  conditions and deferred work in lean TASKS, and remove obsolete hot-state claims.
  Archive index [docs/tasks/README.md](docs/tasks/README.md); maintenance ledger records
  backup/retention/link/source-freeze checks. No addon changes or new implementation.
- PLAN rebalance approved 2026-11-17: retain all decision IDs/current requirements,
  archive complete D05/D07 histories and Sessions 1–9 with indexes and legacy anchors.
  One-time all-nine-session exception; future three-session retention is unchanged.

### D05 — Initial scope, audience, and delivery order 🔨

- First release targets Midnight's eight primary crafting professions: **Alchemy,
  Blacksmithing, Enchanting, Engineering, Inscription, Jewelcrafting, Leatherworking,
  Tailoring**. Older expansions, gathering, Cooking and Fishing remain outside scope.
  Verify exact supported client/build APIs under Q03.
- Build personal-first, structured for later publication. Defer distribution-platform
  integration and broad localization, not correctness or data safety.
- Validate APIs, **complete the dashboard, then one complete Inscription guide** before
  expanding guide coverage. Guide work remains committed, not cancelled.
- Eight verified crafting identities/Moxie mappings are implemented. K08 focused native
  capture/value/normal-use evidence and K09 numeric Knowledge implementation/review/
  focused dashboard validation are complete at their reported scope. Do not repeat
  Knowledge captures, identifier discovery or routine full selftests.
- Supplied enchant categories retain provenance; inclusion is not blanket native proof
  of every ID/rank/amount. Blank means confirmed absence; `?` unknown/unmapped. Never
  infer amounts, API keys or gathering support from names or similar IDs.
- Source: Round 1 accepted recommendations, 2026-11-05; subsequent confirmed E01–E05,
  K08/K09 refinements, November 10–16. Full history/evidence →
  [D05 history](docs/decisions/D05-history.md), [Q01](docs/questions/Q01.md),
  [Q03](docs/questions/Q03.md), [Q06](docs/questions/Q06.md).

### D06 — Knowledge access first, without sacrificing the intended build 🔨

- Prioritize unlocking knowledge activities, then affordable first-craft points.
- Present expensive opportunities separately; do not default to maximum knowledge
  at any price. The definition of affordable remains in Q02.
- Preserve the player's intended specialization build. Default routes avoid required
  specialization investment; optional branches explain investment and tradeoffs and
  require explicit selection.
- Source: user accepted Round 1 recommendations 3 and 4, 2026-11-05.
- Refines D03; remaining route-policy detail lives in [Q02](docs/questions/Q02.md).

### D07 — Attention-first dashboard, three-slot gear, and knowledge bars 🔨

#### Current dashboard requirements

- **Latest U13 refinement2026-11-18:** confirmed Moxie text/estimated Concentration/
  scrollbar/current-player ordering rules above supersede contradictory older presentation
  wording below. Observed numeric sorting remains within current-player/other groups;
  filter membership and saved values are unchanged. Delivered/locally accepted; new native
  presentation/interaction confirmation pending in the updated completion checklist.
- Attention-first compact **one line per character/profession**, all requested fields
  available. Separate Name/Realm; U10 merges gear heading/removes visible Stat/Enchant
  columns in favor of icons and full tooltip detail. Equipment order is
  **Accessory #1 → Accessory #2 → Tool**. This does not establish numeric API slot roles.
- Three separate gear indicators: rarity by border (supersedes translucent background), crafted quality
  ranks 1–5 by icons, no redundant R# label. Rarity, quality and item level are distinct.
  Center gear columns. Confirmed empty is blank; unloaded/unknown is `?`.
- Gear polish requested2026-11-17: accessory/tool item icons close to full row height,
  rarity color as a border, crafted-quality icon overlaid at the top left of each item
  icon. Merge the three accessory/tool headings into one **Gear** header, preserving
  separate slots in Accessory #1 → Accessory #2 → Tool order. This refines the earlier
  rarity-background presentation. Plan the older-expansion warning in the same gear
  redesign, with red border replacing red background proposed by the user below.
  U10 used32px rows/28px icons. User follow-up requests24px icons/28px rows and horizontal
  gaps matching vertical gaps; U11 adopts28px gear cells/26px borders/84px Gear heading.
  No Gear sorting/red-border/narrower-dashboard choices change. Native metadata issue open.
- Gear redesign refinement2026-11-17: slightly taller rows acceptable. A single, larger,
  semi-centered stat-letter overlay belongs **only on the Tool**, never accessories;
  it occupies more of the item icon than the quality/enchant corner badges. Remove Stat
  and Enchant columns in the redesigned view, retaining full names/details in hover.
  Show an enchanted badge only for confirmed enchanted items; absence intentionally
  covers unenchanted or unknown, with distinction retained in tooltips/data. No separate
  negative/unknown enchant badge required. Quality top left; enchant top right proposed.
  The letter specifically represents the stat provided by the Tool itself, excluding
  its enchant. An enchant with a different stat does not change/add to the letter;
  tooltip supplies that distinction. This display intent is settled; identifying the
  tool-only stat reliably is technical verification, not a request to choose among
  combined totals. Never choose arbitrarily or subtract guessed enchant amounts.
  User approves32px rows/28px icons and no Gear sorting. Tool stat uses a protected
  enchant-neutralized link query preserving bonus/crafted modifiers, requiring one clear
  supported stat; missing/ambiguous metadata leaves letter absent, never a guessed `?`.
  Optional item expansion comes from documented GetItemInfo return15. No live offline
  reads or forced rescans; old snapshots remain intact, new metadata fills on ordinary
  own-character scans. Unknown expansion is not red. Native behavior still to verify.
- Dashboard rounding-out requested 2026-11-17, **after the redraw issue**: Skill column
  becomes a progress bar with color moving towards green as skill approaches maximum;
  Concentration becomes a progress bar that turns green when full. Numeric values and
  unknown/stale distinctions remain meaningful; exact palettes/implementation are unsettled.
- **Concentration bar approach approved2026-11-17:** flat bar in existing column,
  matching Skill bar height, centered current/max; blue below capacity, green when full.
  Unknown/unusable cap stays neutral/unfilled, never fabricated zero. Remove the visible
  Concentration `!` (fresh and historical), retaining90% attention filtering/default
  attention semantics, other indicators, tooltips, freshness and existing layout.
  User approves starting with tooltip-only estimates; changing the bar to predictions is
  deferred. Show estimated now/time-to-full only from valid saved positive recharge
  metadata and successful field observation time, capped at saved capacity, with explicit
  approximate/no-spending/unchanged-rate caveat. No estimate for archived snapshots or
  missing/invalid data/time. Retain observed data and90% attention/sorting semantics.
  Calculate on normal hover, no polling/automatic scans. Native recharge phase/rounding/
  offline accuracy remains unverified pending a focused check; no universal refill rate.
- **Skill-only approach approved 2026-11-17:** flat bar in the existing column, centered
  current/max text, continuous red→amber→green with green at maximum. Use saved skill
  level/cap only, no equipment/skillModifier bonus added. Unknown skill/unusable cap:
  neutral unfilled bar with `?`. Preserve existing warnings, tooltips, numeric sorting,
  freshness and R01 retention safety. U06 implements only this; Concentration/gear-red
  design remains separate. Technical RGB/geometry/boundary contract is in TASKS.
- U06 follow-up 2026-11-17: user accepts the bar appearance and requests removing the
  Skill `!` as redundant. This supersedes preserving that marker in U06, not other
  attention indicators or freshness/unknown distinctions. User suggests reworking
  Progression filter to non-max Skill; exact refinement is proposed in Q05, not yet coded.
- U07 approved 2026-11-17: apply both refinements above. Skill has no `!`; **Skill below
  max** replaces the visible Progression option and uses only known saved skill/cap.
  Unknown/unusable caps excluded; stale known values stay honestly last-observed. Existing
  archived-attention exclusion, other warning categories/indicators and default attention
  ordering remain unchanged. Knowledge no longer affects membership in this filter.
- U07 delivered/locally accepted2026-11-17 after scoped-static review and primary full
  validation/exact-target preservation confirmation. Skill `!` removed; visible menu
  **Skill below max** uses stable internal selector with Skill-only membership. Focused
  native feedback pending; no writer/remaining implementation piece. Concentration/
  gear-red remain separate. [Review](docs/dashboard/skill-u07-review.md).
- **Previous-expansion accessories and tools use a red border instead of rarity border**,
  confirmed2026-11-17, superseding the earlier red-background proposal. Implement with
  the combined gear redesign, not separate passes. Compare observed item expansion with
  the row's supported profession expansion; no red classification for unknown metadata.
  Preserve quality indicators, rarity detail and unknown/empty distinctions. Reliable
  expansion API signature is source-checked, not yet client-verified; no rarity/item-level inference.
- Main-table stat/enchant categories use full names without numeric amounts. Preserve
  observed amounts on diagnostic hovers, never derive them from quality. Enchant is a
  full known category, blank for confirmed absence or lone `?` for unknown/unmapped.
  Earlier grouped Tool/single-letter layouts are superseded; identifiers stay separate
  from localized labels. C/I/M/R and future D/F/P abbreviations remain naming history,
  not new API mappings or gathering scope.
  U10 supersedes separate visible Stat/Enchant columns with the Tool-only letter and
  positive enchanted badge; full names/observed values/enchant distinctions stay in hover.
- Concentration attention at **90% of a verified cap**, later configurable; Moxie **>600**.
  Dashboard-only indicators initially, no sounds/popups. Distinguish fresh amber `!`
  from muted historical `!` where markers remain. Skill and Concentration visible `!`
  removals above supersede earlier marker-preservation rules, not freshness semantics.
  Concentration estimates must be labeled; otherwise show last observed values.
- Timestamped per-alt login/profession scans and offline snapshots are accepted, not
  live inspection of offline alts. Last Updated shows relative observation age without
  snapshot/read prefixes; diagnostics retain exact independent field/attempt times.
- Profession dropdown; native View (Active/Archived) and Attention dropdowns. Column
  headings select/toggle sorting with direction indicator, unknowns last; default
  attention-first until selected. Sort/filter/read actions do not collect or write data.
- Flat dark fill/subtle solid border, HIGH window strata; preserve close/drag/deletion
  confirmation. Details can appear above it. Class-colored names use optional saved
  own-player `classToken` from guarded scans, native colors/neutral fallback; failed reads
  preserve known tokens. Never infer class from names or perform live offline lookup.

#### Knowledge presentation and Details

- Inline top-level tree bars retain native tree order, purchased/capacity numbers and
  separate Unspent KP (D10). Wider flat/solid bars use their allocated space, supporting
  1–8 current trees; numeric-only labels X/Y or `?`, full names on hover. Accepted U04
  allocation: Stat 140, Enchant 110, Knowledge 292; retain total width/other geometry.
- Four fixed blue/green/orange/purple colors keyed by profession plus native tree ID,
  not row/tab position; unknown IDs neutral. Keep labels, normal and Shift hovers.
- Normal tree hover lists **every captured branch** as `Name: X/Y`, its individual path
  purchased/capacity, indented two spaces per child depth with root unindented. Optional
  saved labels come from guarded active definition overrideName, else spell name;
  missing labels say `Unknown branch`, never invented/ordinal names. Names do not gate
  numeric eligibility. No live hover/offline collection.
- No normal value hovers on Moxie, Unspent KP, Last Updated, Stat or Enchant; keep header
  hovers, native gear hyperlinks/third-party tooltip contents and Shift diagnostics.
  Routine tree accounting prose/six-line cap are superseded. Brief real unknown/stale/
  archived cues remain; raw IDs, reconciliation, generations, caveats and times stay
  on Shift-hover. Displaying a snapshot never refreshes it.
- Existing **Inscription-only Details**: click Profession, explicit Refresh details,
  bounded frame-stepped capture, independent timestamps, preserve coherent prior data
  on failure/cancellation. Cached/offline/archived views do not collect. Branch investment
  and client descriptions/earned milestone states are supported; focused correctness,
  responsiveness and closed/reload retention were confirmed, not universal API coverage.
- Details usability redesign remains **parked**: discoverability, immovability, verbosity
  and desired concise summary are unresolved. Preserve existing functionality. Product
  direction remains earned conditional branch bonuses and **all Knowledge-gated recipes**
  with learned/not learned/unknown states and rank context. Requirement satisfaction or
  recipe-like perk text is not actual recipe learned/usable evidence. Complete catalogue,
  learned-status mapping, computed totals, profitability and other professions are deferred.

#### Storage and account growth — S01

- Support the user's **current 46 characters and future additions without a fixed cap**.
  46/100/200 characters × two professions and >50,000 aggregate-value fixtures are growth
  tests, not ceilings or unlimited-resource guarantees.
- Implemented plain schema2: compatible **immutable shared tree/Details definitions**,
  independently bounded personal generation records, compact allocations/state/raw
  summaries. Retain meaningful equipment/currencies/progress, archives, ownership,
  independent timestamps and unknown/stale distinctions; do not permanently duplicate
  unnecessary rich diagnostic graphs per alt.
- Keep full live acquisition/accounting/primitive safety checks and temporary rich scan
  context for Details safety. Validate catalogue compatibility/ownership/references,
  including reuse for new characters; conflicts/patch/locale changes cannot rewrite
  older snapshots. Preserve retained fields beyond current eight-tree discovery bounds.
- Atomic affected-record writes and all-or-nothing migration preserve known/original
  data on failure/cancellation. No reset, silent eviction, arbitrary limit increase or
  forced rescan to recover known values. Back up before migration; older-addon rollback
  requires its matching pre-upgrade data backup.
- Incremental startup/directory validation, row generation and sorting avoid expanded
  whole-account walks. Startup/dashboard drivers batch **at most 16 Steps** while observed
  elapsed time remains **below 2ms between units**; clockless fallback is one Step.
  Indivisible units may overshoot; no measured native latency claim. Preserve invocation/
  runtime ownership so stale cleanup/callbacks cannot overwrite replacement work.
- Local acceptance and scoped-static review are complete, including catalogue-reuse and
  startup-cleanup corrections. User confirms successful formerly blocked scans and older
  snapshots; exact migration/reload procedures, timings/roster counts and all failure paths
  were not reported. **Redraw/normal-use acceptance remains partial**, not storage loss.
- Exact implemented contract → [S01](docs/dashboard/storage-s01-contract.md),
  [schema](docs/dashboard/schema.md), [review](docs/dashboard/s01-review.md).
  Earlier [storage-scaling proposal](docs/dashboard/storage-scaling-proposal.md) is
  historical rationale, not the executable contract or a new approval.

Sources: confirmed mockup/table/hover/Details/U04/U05 and storage refinements,
November 5–17. Complete chronological record → [D07 history](docs/decisions/D07-history.md),
[Q05](docs/questions/Q05.md); current update/recovery → [dashboard guide](docs/dashboard/README.md).

### D08 — Adaptive curated routes, modular architecture, and Inscription first 🔨

- Offer knowledge-ready, budget-stop, and maximum-skill targets. Use researched,
  profession-specific stopping points with an explanation. Show available price
  estimates; missing prices must not imply a cheap route. A hard gold budget is deferred.
- Use curated, tested routes adapting to actual skill, completed first crafts, known
  recipes, and user-selected branches. Prices may select approved alternatives, not
  invent untested routes. A universal optimizer remains parked in P02.
- Use Lua/native UI, saved snapshots, and a separately loadable guide module.
- **Inscription is the first complete guide**, chosen for the user's available test
  alts. This replaces the assistant's unaccepted Tailoring-first recommendation.
- Source: Round 2 recommendations 4/5 accepted and explicit answer 6, 2026-11-05.
- Refines D03/D05/D06; remaining resource policies: [Q02](docs/questions/Q02.md).
  Implementation-level architecture/testing preparation: [Q06](docs/questions/Q06.md).

### D09 — Shopping inventory, single export list, and manual guide execution 🔨

- Default shopping calculations use bags and personal bank. Offer an **opt-in
  Warband-bank inclusion** option; exclude it by default. Do not automatically deduct
  materials held by other alts. Deduct only reliably observed, usable stock and
  distinguish stale/unknown inventory from verified absence.
- Generate remaining materials for the selected route target, optionally just the
  next crafting block. Separate expected quantities from a contingency allowance for
  uncertain skill-ups, and update after observed progress.
- Maintain exactly **one CraftArmy-owned Auctionator list named `CraftArmy`**.
  An explicit new export replaces that same list even when character, profession,
  or target changes; do not create one list per character/profession/target.
- Retain the export preview/confirmation safeguard and never replace unrelated user
  lists. Keep exact quantities/qualities in CraftArmy if the external format cannot
  preserve them. Auctionator is optional; offer a copyable fallback.
- Default routes do not spend concentration. Show Moxie-priced recipe unlocks
  explicitly; require opting into their branches before including the costs. Explain
  when avoiding a resource prevents reaching a target.
- Selecting a guide step opens the recipe; crafting uses WoW's normal interface.
  Observe results and update progress. No automatic crafting, buying, or knowledge
  spending.
- Source: Round 3 answers 2–6, 2026-11-05. Replaces the earlier proposed per-route
  export-list naming scheme. Details/history: [Q07](docs/questions/Q07.md).

### D10 — Knowledge-bar accounting and archived snapshots 🔨

- Each top-level knowledge bar includes purchased points across that tree and all
  its sub-branches, against its total spendable knowledge capacity. Show unspent
  knowledge separately and break down branches/nodes in tooltips. Automatic/free
  unlock ranks must not inflate purchased-point totals.
- Retain unlearned-profession or retired-alt snapshots as archived. Exclude archived
  records from active totals and attention indicators; allow manual deletion.
- Relearning requires a fresh scan instead of assuming old progression is valid.
- Source: Round 3 recommendations 1/7 accepted, 2026-11-05. Refines D07.
- Display/retention history: [Q05](docs/questions/Q05.md). API accounting evidence
  remains [Q03](docs/questions/Q03.md).
- **2026-11-06 scoped refinement approved:** Midnight Inscription may display observed
  native-rank totals only after complete unstaged same-scan metadata and profession-wide
  shared-spent reconciliation. Use a distinct native-rank-reconciled policy, not a
  claim of universal all-rank cost proof. Locked-path unlock costs are separate from
  spend currency; missing/ambiguous/mismatching data retains coherent stale totals
  or unknown. User explicitly approves K2 correction; other professions remain gated.
- **Current refinement, K09 approved/delivered November 16:** the former Inscription-only
  numeric/raw gate is superseded by an exact eight-crafting-identity/trait-currency resolver,
  observed currency pinning (Inscription 3902, not a universal currency), coordinated raw/
  generation attribution and failed-attempt preservation. Complete unstaged same-scan
  reconciliation/safety remain required; zero rank alone does not prove locked state,
  positive auxiliary balances are not Unspent KP. Details remains separately Inscription-only.
  Focused values/behavior accepted at reported scope; all-rank costs remain UNVERIFIED.
  Authoritative roster absence/automatic unlearning and base-versus-enchant stat attribution
  remain unverified; do not infer them or erase known snapshots.

### D11 — Bounded knowledge-source coverage 🔨

- Include actionable one-time knowledge sources alongside crafting steps and explain
  how recurring sources are unlocked.
- Track completion where reliably observable. Unknown completion is not incomplete.
- Distinguish knowledge earned now from future knowledge access unlocked.
- Defer a full weekly checklist/reset tracker; see [P03](docs/parking-lot/P03.md).
- Source: user accepted Round 4 recommendation 1, 2026-11-05.
- Refines D03/D06/D08; history: [Q08](docs/questions/Q08.md).

### D12 — Cost-conscious reagent selection and safe guide degradation 🔨

- Select the lowest-cost approved reagent combination meeting the step's requirements,
  without concentration. Do not pay for improved output quality unless the player
  explicitly selects that alternative.
- Without prices, use the curated recommendation and mark cost unknown; do not call
  it the cheapest. This selects within tested alternatives, not a universal optimizer.
- Warn and show the validation date for unverified guide data. A newer build alone
  is not proof of incompatibility.
- Block demonstrably incompatible steps and their dependent shopping calculations;
  explain the issue and offer a validated alternative where available. Keep the
  dashboard and unaffected guide sections usable.
- Source: user accepted Round 4 recommendations 2/3, 2026-11-05.
- Refines D08/D09; histories: [Q09](docs/questions/Q09.md), [Q10](docs/questions/Q10.md).

## Open questions

- **Q03 — Target-client API feasibility** → [thread](docs/questions/Q03.md)
- **Q04 — Auctionator capabilities and export safeguards** → [thread](docs/questions/Q04.md)
- **Q06 — Implementation tooling and handoff preparation (product architecture settled)** → [thread](docs/questions/Q06.md)

## Parking lot

- **P01 — Cross-account or cross-computer synchronization** → [thread](docs/parking-lot/P01.md)
- **P02 — General-purpose optimal-route solver** → [thread](docs/parking-lot/P02.md)
- **P03 — Full weekly knowledge checklist/reset tracker** → [thread](docs/parking-lot/P03.md)

## Session log

Sessions **1–9 archived** → [session index](docs/sessions/README.md). All nine older
logs moved under the approved one-time exception; future policy still retains the latest
three inline. Current status is above/in TASKS; next session number is 10.

<!-- LEGACY PLAN NAVIGATION -->

Legacy section anchors below lead to preserved histories, not active instructions.

<a id="u05--dashboard-colors-controls-and-flat-window-2026-11-16"></a>
<a id="u01--concise-tooltips-with-opt-in-diagnostics-approved-2026-11-07"></a>
<a id="u02--named-branch-only-tree-hovers-fewer-default-tooltips-2026-11-08"></a>
<a id="knowledge-benefits-and-recipe-unlocks--product-direction-accepted-2026-11-09"></a>
<a id="u04--wider-flat-knowledge-bars-and-hierarchical-hovers-2026-11-09"></a>
[D07 historical sections](docs/decisions/D07-history.md).

<a id="session-1--2026-11-05"></a>
[Session 1 historical sections](docs/sessions/session-01.md).

<a id="session-2--2026-11-05--design-grill-complete-four-rounds"></a>
<a id="round-2-recorded"></a>
<a id="round-3-recorded"></a>
<a id="read-only-research-returned"></a>
<a id="round-4-recorded--product-design-pass-complete"></a>
[Session 2 historical sections](docs/sessions/session-02.md).

<a id="session-3--2026-11-05--api-feasibility-task-preparation"></a>
[Session 3 historical sections](docs/sessions/session-03.md).

<a id="session-4--2026-11-05--t01-implementation-authorized"></a>
<a id="t01-delivery-and-review"></a>
<a id="first-user-run-client-evidence"></a>
[Session 4 historical sections](docs/sessions/session-04.md).

<a id="session-5--2026-11-05--t01-capture-correction-approved"></a>
<a id="r1-delivery-and-review"></a>
<a id="r1-user-validation-received"></a>
<a id="targeted-moxieenchant-clarification"></a>
<a id="positive-enchant-observation"></a>
<a id="numeric-enchant-mapping-confirmed"></a>
[Session 5 historical sections](docs/sessions/session-05.md).

<a id="session-6--2026-11-05--dashboard-mvp-contract-preparation"></a>
[Session 6 historical sections](docs/sessions/session-06.md).

<a id="session-7--2026-11-05--t02-implementation-authorized"></a>
<a id="t02-initial-delivery-and-correctness-review"></a>
<a id="t02-corrections-reviewed-controlled-client-testing-next"></a>
<a id="single-letter-stat-refinement-delivered"></a>
<a id="first-user-run-t02-fixture-result"></a>
<a id="numeric-rejection-cause-reproduced-in-client"></a>
<a id="native-aware-numeric-correction-delivered"></a>
<a id="r4-user-fixtures-pass-live-dashboard-comparison-next"></a>
<a id="first-live-inscription-row-observed"></a>
<a id="inscription-native-ui-comparison-confirmed--2026-11-06"></a>
<a id="tool-item-text-corroborated--2026-11-06"></a>
<a id="craftarmy-tool-tooltip-confirmed--2026-11-06"></a>
<a id="reload-snapshot-retention-confirmed--2026-11-06"></a>
<a id="two-character-rows-retained--2026-11-06"></a>
[Session 7 historical sections](docs/sessions/session-07.md).

<a id="session-8--2026-11-06--compact-ui-polish-approved"></a>
<a id="r5-compact-polish-delivered-and-statically-reviewed"></a>
<a id="r5-user-fixtures-pass"></a>
<a id="r5-native-screenshots-validate-two-row-presentation"></a>
<a id="r5-native-filter-sizing-confirmed"></a>
[Session 8 historical sections](docs/sessions/session-08.md).

<a id="session-9--2026-11-06--further-table-iteration-requested"></a>
<a id="table-iteration-display-choices-settled"></a>
<a id="r6-table-revision-delivered-and-reviewed"></a>
<a id="r6-user-fixture-failure-test-identity-setup"></a>
<a id="r6a-fixture-correction-reviewed"></a>
<a id="r6a-user-fixture-gate-clears"></a>
<a id="revised-native-table-and-dropdown-observed"></a>
<a id="table-pass-accepted-inscription-knowledge-investigation-resumed"></a>
<a id="inscription-first-root-evidence-unlock-and-spend-entries-distinguished"></a>
<a id="blueprints-native030-confirmed"></a>
<a id="inscription-costcurrency-sample-received"></a>
<a id="read-only-full-tree-knowledgecheck-approved"></a>
<a id="k1-evidence-command-delivered-and-static-reviewed"></a>
<a id="k1-user-fixtures-pass"></a>
<a id="full-inscription-evidence-capture-received"></a>
<a id="k2-guarded-inscription-bars-authorized"></a>
<a id="k2-correction-delivered-and-static-reviewed"></a>
<a id="k2-assertions-pass-client-selftest-responsiveness-correction"></a>
<a id="k3-responsive-test-runner-deliveredstatic-pass"></a>
<a id="k3-native-diagnostic-stop-isolates-case42"></a>
<a id="k3a-r5-checkpoints-static-reviewed"></a>
<a id="k3a-reaches62-cases-maximum-report-unit-needs-deeper-slicing"></a>
<a id="resumable-read-only-report-refactor-approved"></a>
<a id="k3b-resumable-report-jobs-deliveredstatic-reviewed"></a>
<a id="k3b-client-progresses66123-grouped-command-fixture-refinement"></a>
<a id="k3c-command-fixture-checkpoint-refinement-static-reviewed"></a>
<a id="k3c-client-reaches79123-case80-setup-checkpoint-correction"></a>
<a id="k3d-case80-setup-correction-static-reviewed"></a>
<a id="latest-client-stop64123-protected-command-fixture-refinement"></a>
<a id="k3e-protected-command-scopes-static-reviewed"></a>
<a id="client-reaches81123-scanreload-fixture-grouping-correction"></a>
<a id="k3f-scanreload-fixtures-static-reviewed"></a>
<a id="k3f-isolates-final-synchronous-scan-broader-scope-decision-pending"></a>
<a id="broader-scan-performance-investigationfix-approved-measure-first"></a>
<a id="k4-stage-measurement-deliveredstatic-reviewed"></a>
<a id="local-lua51-now-available-complete-fixture-execution-pass"></a>
<a id="native-measurement-run-stopsbeforescan-atcase51"></a>
<a id="k4a-guarded-report-groups-reviewed-and-locally-executed"></a>
<a id="native-stages-measured-core-allocationowned-merge-correction-settled"></a>
<a id="k5-core-correction-deliveredreviewed-native-performance-pending"></a>
<a id="k5-native-improves30-residualprotected-call-optimization-settled"></a>
<a id="k6-protected-numeric-walks-deliveredreviewed"></a>
<a id="k6-native-advances86149-conservative-overbudget-rejection-next"></a>
<a id="k7-conservative-rejection-deliveredreviewed"></a>
<a id="approved-validation-policy-local-stress-suites--focused-wow-checks--2026-11-07"></a>
<a id="v01-first-focused-observation--2026-11-07"></a>
[Session 9 historical sections](docs/sessions/session-09.md).

## Relocated / detailed material

- Detailed design and roadmap → [docs/design.md](docs/design.md)
- Decision histories → [docs/decisions/README.md](docs/decisions/README.md)
- Questions → [docs/questions/](docs/questions/)
- Parking lot → [docs/parking-lot/](docs/parking-lot/)
- Session histories → [docs/sessions/README.md](docs/sessions/README.md)
- Task histories → [docs/tasks/README.md](docs/tasks/README.md)
- Validation/recovery lessons → [reference](docs/references/validation-and-recovery.md)
- Maintenance configuration, backups and integrity evidence → [ledger](docs/rebalance-log.md)

Retain full local correctness/stress suites and focused user-run normal-use/API/snapshot
checks. An INCOMPLETE full-client run is not PASS or a blanket prerequisite to further
native work; no raised limits, reduced coverage or repeated timing chase. Implementation,
review, acceptance and release are distinct. No installation/private data/Git/publication
authorization follows from these documents or passing checks.

Default maintenance threshold: **15,000 words**; keep the latest **three sessions** inline.
No automatic cooling rule or new product decision was introduced by this rebalance.
