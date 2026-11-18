# D07 — preserved PLAN history

> Archived 2026-11-17 from original PLAN.md lines 343–675.
> Historical approval/blocker/next-step statements below are not current instructions.
> Current requirements, acceptance limits and open work remain in PLAN.md/TASKS.md.
> Wording is intact; only relative Markdown link targets were mechanically rebased.

[Current plan](../../PLAN.md) · [Current tasks](../../TASKS.md) · [History index](README.md)

<!-- BEGIN PRESERVED PLAN BLOCK -->
### D07 — Attention-first dashboard, three-slot gear, and knowledge bars 🔨

- Use an attention-first summary with every requested field visible and sorting/filtering
  for concentration, Moxie, missing enchants, and incomplete progression.
- Layout refinement from mockup feedback: **one compact single line per
  character/profession**, not a large card or a second knowledge strip. Keep the
  three gear indicators, abbreviated tool/enchant stats, currencies, inline miniature
  tree bars and unspent knowledge in that line; full labels/breakdowns use tooltips.
- Give the tool and two accessories **three separate indicators**. Show rarity using
  appropriate color and crafted quality rank using iconography capable of ranks 1–5.
  Rarity, crafted quality rank, and numeric item level are distinct fields.
- Equipment display order is **Accessory #1 → Accessory #2 → Tool**, matching the
  requested WoW UI arrangement. Group the tool indicator, abbreviated tool stat(s)
  and separate enchant status/stat within one **Tool** column, inline in the same
  compact row, rather than standalone Stats/Enchant columns. This presentation order
  does not establish the API's numeric slot-to-role mapping.
- A confirmed missing item leaves its indicator blank. Unknown/unloaded data shows
  `?`; it must not look like a confirmed empty slot. Item tooltips provide detail.
- Display the tool's profession stat(s), abbreviated when needed: for example
  Multicraft, Resourcefulness, Speed, or Ingenuity. The optional tool enchant also
  displays its own stat, not merely an enchanted checkmark. Preserve the original
  yes/no requirement for absence/presence, and do not guess stat identity.
- Compact stat labels use **C = Crafting Speed, I = Ingenuity, M = Multicraft,
  R = Resourcefulness**, for both tool and known enchant categories. Full names
  remain in tooltips. User also supplied future gathering labels **D = Deftness,
  F = Finesse, P = Perception** for Skinning/Herbalism/Mining; this is naming guidance,
  not expansion of D05's crafting-only scope or evidence of gathering API keys.
- Show progress bars per top-level specialization tree so the crafter's main branch
  is visible, with a detailed knowledge breakdown in tooltips. Retain spent/unspent
  knowledge; exact bar aggregation remains a detail in Q05.
- Attention indicators are dashboard-only initially: no sounds or popups. Flag
  concentration at 90% of a verified cap; allow later configuration. Keep Moxie >600.
  Distinguish unknown/stale data from confirmed attention conditions.
- Per-alt login/profession scans and timestamped offline snapshots are accepted.
  Clearly label concentration estimates; show last observed values if reliable
  regeneration cannot be verified.
- Source: Round 1 recommendations 2/5 accepted; Round 2 answers 1–3, 2026-11-05.
- User approved a bounded compact-UI polish pass on2026-11-06: clearer short gear
  headers with full hover labels, less unused window space, readable status messages
  and removal of raw icon markup from addon text, without changing collected data.
- Single-line density explicitly requested in subsequent visual-mockup feedback,
  2026-11-05. Reviewing a mockup does not authorize implementation.
- Accessory-first ordering and Tool-column stat/enchant grouping requested in the
  subsequent compact-mockup review, 2026-11-05.
- Single-letter stat labels specified by user during implementation follow-up,
  2026-11-05; numeric identifiers/stat keys remain separate from these English labels.
- **Latest table refinement requested 2026-11-06** supersedes the earlier grouped
  Tool/single-letter main-table presentation: separate Name and Realm; separate
  Tool, Stat and Enchant; full stat/category names without numeric amounts in the
  main table. Keep observed numeric data in tooltips, never infer it from quality.
  Enchant shows full stat name when known, blank for confirmed no enchant and a lone
  `?` for unknown/unloaded/unmapped data; no Ench:Yes/Ench:? prefixes. User selected
  this distinction explicitly rather than conflating unknown with absence.
  Remove redundant R# beside known quality icons; gear cells use translucent rarity
  background, retaining unknown/confirmed-empty distinctions. Replace Snapshot with
  Last Updated showing relative age without snapshot/read prefixes; keep exact
  observation/freshness detail on hover, as explicitly selected by user.
  Profession filter becomes a finite dropdown. Theme/knowledge investigation deferred
  while this visual iteration is settled; no new profession mappings implied.
- Refines D02. Display history and remaining lifecycle detail: [Q05](../questions/Q05.md).

#### U05 — dashboard colors, controls and flat window (2026-11-16)

- User directly requests four distinct Knowledge tree colors consistent within each
  profession; center-aligned accessory/tool columns; class-colored character names;
  removal of the visible `~` prefix; View/Attention dropdowns; column-heading sorting
  instead of the Sort button; a flat-color background/border; and higher window priority.
  This authorizes the bounded U05 implementation, not a new Knowledge/API test round.
- Use fixed blue/green/orange/purple colors keyed by profession+native tree ID, not row
  position, so alt/sort/filter/tab reorder cannot swap colors. Retain numeric labels,
  all existing bar geometry and normal/Shift hovers. Unknown IDs get a neutral fallback.
- Remove only the tilde from historical attention prefixes (keep muted `!` versus fresh
  amber `!`); do not change warnings, thresholds, stale flags, observation times or
  diagnostic freshness text. Saved data must not be relabeled current by this polish.
- Use native View (Active/Archived) and Attention dropdowns with the current options.
  Clicking column headings selects/toggles sorting with a direction indicator and
  unknowns last; keep default attention-first ordering until a heading is selected.
  No sort/filter action collects or writes snapshots. Main window uses a plain dark
  fill, subtle solid border and HIGH strata; retain close/drag/confirmation behavior.
- Class color uses an optional saved `classToken` learned only from the current player's
  normal guarded scan (UnitClassBase("player")); old snapshots stay valid/neutral until
  refreshed, absent/failed optional reads preserve a known token. Use native class
  colors with neutral fallback, not localized names/professions or live offline lookup.
  Schema1/no migration/reset; class metadata is separate from profession accounting.
- Details redesign stays parked. Only ensure its existing window can appear above the
  newly raised dashboard when opened from it; no Details capture/model/layout changes.
  Serial implementation contract: TASKS U05. Local validation and independent review
  before user update advice; no install/Git/release authorization.
- U05 delivered/locally accepted2026-11-16: all requested colors/centering/class-name
  metadata/tilde removal/dropdowns/header sorting/flat chrome/higher priority implemented.
  Primary reproduced409/409 (359 retained with approved UI/helper/RGB adaptations+50new),
  unchanged744K6/565K7, diagnostic23/23/bothPython PASS, actual69-file comparison/old359
  inverse/history/post-review eighthash freeze. Independent boundedstatic COMPLETE/PASS,
  no findings; reviewer execution unavailable, so executable/comparison proof stays
  primary-attributed. Native U05 visual/control check NOT RUN. Next user-managed six-file
  update/focused cached UI check; normal own-alt scan only to learn missing classToken.
  No reset/migration/Knowledge recapture/selftest/generic correctness repeat. K09 acceptance
  and fullnative INCOMPLETE87/149 unchanged; no agent install/Git/release approval.
- U05 follow-up2026-11-16: user reports most characters' class colors/bars/enchants
  update correctly, but some normal `/ca scan` calls fail with “Assembled snapshot
  exceeds bounded saved data limits”. Do not declare complete native U05 acceptance.
  Primary reproduced that exact failure using complete native-derived fixtures as the
  account roster grows:8rows29793values,12rows46745,attempted13th rejected without
  changing prior data. The50000-value walker budget applies to the whole saved DB,
  not per character. This is a demonstrated storage-scaling limitation; actual user
  DB counts not supplied. Preserve all data/limits/tests; no reset/eviction/limit raise.
  Next prepare a separately settled storage-capacity correction, not more captures or
  repeated scans/UI edits. No new implementation/storage-policy change authorized yet.
- Storage capacity requirement2026-11-16: user has successfully refreshed6characters
  with2professions each,3previously scanned characters currently blocked, and46possible
  tracked characters. Target at least46characters/92active profession rows while retaining
  history, not a new hard46-character cap. Recommended lossless bounded-record storage
  and all-or-nothing migration are proposed in docs/dashboard/storage-scaling-proposal.md;
  no implementation/storage-format migration approval inferred from this factual answer.
- Storage direction refined2026-11-16: user says storage changes are fine, but per-alt
  duplicate tree definitions/engineering evidence are unnecessary; nodes are shared for
  the same profession, character allocations differ. Settle shared versioned profession
  definitions plus compact character allocations/states, not opaque packing of every
  duplicated raw graph. Full live scan/accounting safety checks stay; default per-alt
  persistence need not retain raw debug payloads. Preserve meaningful user snapshots,
  archives/independent times/unknowns and required refresh context. Catalogue conflicts/
  patch/locale changes must not rewrite older snapshots. Revised S01 design in
  docs/dashboard/storage-scaling-proposal.md; exact schema/migration/integration contract
  still needed before writer. No code/cap change or engineering-doc deletion authorized.
- Storage growth clarification2026-11-16:46 is the user's CURRENT character count, with
  future additions expected, not a ceiling or merely a possible roster. User permits
  combining deduplication with the original independently bounded-record approach.
  Settle shared immutable definitions +personal snapshot records, validating all records/
  ownership/references in bounded work batches rather than applying the legacy50000-value
  budget to the entire expanded account. Preserve primitive/record safety checks, not
  the demonstrated account-wide bottleneck. No arbitrary cap raise/fixed character cap
  or unlimited-resource promise. The32095-value projection only demonstrates deduplication,
  not growth acceptance; require46×2 minimum plus larger-roster/>50000aggregate tests.
  Exact field map/schema/adapters/migration/scheduling contract remains pending; no writer.
- S01 implementation authorized2026-11-16: user “Let's do it” accepts proceeding with
  the combined redesign and safe migration. Primary settles versioned plain schema2
  directories with independently bounded generation records, immutable tree/Details
  catalogues, compact personal state/raw summaries, unchanged legacy Core/primitive
  guards, owned facade access, atomic affected-record writes and all-or-nothing root
  migration. One ephemeral fully validated rich scan source preserves Details capture
  guards without persistent diagnostic graphs. Incremental startup/directory validation,
  row generation and sorting avoid whole-account expanded walks; no fixed character cap.
  Exact executable contract docs/dashboard/storage-s01-contract.md; serial S01 queue at
  top of TASKS. Preserve all409 old scenarios; test46/100/200characters×2 as growth fixtures,
  not caps, and valid compact accounts beyond50000aggregate values. One implementer then
  independent review/primary acceptance before update advice. No game install/Git/release.
- S01 primary scheduling amendment2026-11-16: initial writer exposes Core-valid retained
  tree fields beyond an eight-tree current index. Preserve them all; native acquisition
  eight-tree limit is not a history cap. Settle one catalogue-validation unit per job Step,
  privately owned validated-registry reuse for record assembly, one-field migration
  compaction and iterator dependency preparation (contract5a). Initial423cases422PASS/
  1FAIL remains failure history, not accepted fix. No primitive cap increase/old409 edits.
- S01 review correction2026-11-16: independent static review identifies a reused-catalogue
  ownership preflight gap for new characters; block acceptance until corrected/tested.
  Primary also supersedes fixed one-Step/frame startup/dashboard scheduling with bounded
  batches (max16Steps,2ms measured between units, clockless one-Step fallback), keeping
  every individual Step/native/primitive safety bound unchanged. This addresses deliberate
  frame-count latency without claiming measured native performance. Contract8/5b and
  TASKS piece8 specify exact correction/regressions, then renewed independent review.
- S01 renewed review2026-11-17: catalogue integrity finding resolved; remaining startup
  cleanup/error callback can overwrite a replacement retry's pending status (no root-loss
  finding). Block acceptance; primary settles private startup invocation epoch and all
  post-cleanup job/runtime identity checks in contract9/TASKS9, with combined failure+
  cleanup retry and equivalent-path regressions. No format/native/primitive policy change.
- S01 delivered/locally accepted2026-11-17: plain schema2 shared immutable tree/Details
  definitions +independently bounded personal generations, compact raw summaries,
  atomic migration/affected-record writes and bounded startup/render batches implemented.
  Primary463/463 (all409original bytes retained+54new), unchanged744K6/565K7, diagnostics
  23/23/Python, actual comparison/inverse/history and post-review16hash freeze PASS.
  Independent accumulated scoped-static review PASS; catalogue-reuse integrity and startup
  cleanup-status findings resolved, with old failing reproductions retained. Independent
  executable/comparison proofs unavailable, primary-attributed; extra external derivative
  bundle ungenerated after denied helper, direct read-only primary proof/review record
  accepted without retry/bypass. Real full-input46/100/200×2growth, >50000aggregate stores,
  archives/Details and9/17retained tree fields tested (sizes not caps). Next user-managed
  whole CraftArmy folder update/backup/automatic migration and one previously blocked
  normal scan plus retained older snapshots/normal-use check. Native storage NOTRUN;
  U05PARTIAL/fullnativeINCOMPLETE87/149/allrankUNVERIFIED unchanged. No new Knowledge
  capture/IDs/fullselftest chase, agent install/Git/publication/release authorization.
- S01 focused native follow-up2026-11-17: user reports scans now succeed on multiple
  previously blocked characters and older snapshots remain correct. Accept that scoped
  refresh/preservation evidence; do not infer exact migration/reload steps, roster size,
  timings or all failure paths. User also reports frequent table disappearance/reappearance,
  particularly opening/closing professions. Keep dashboard redraw/normal-use acceptance
  open; no lost snapshots reported, diagnosis/fix not settled. User prioritizes TASKS cleanup
  before continuation; no redraw implementation authorized by that documentation approval.

#### U01 — concise tooltips with opt-in diagnostics (approved 2026-11-07)

- User approves tooltip cleanup after V01: concise player-facing normal hovers,
  with existing technical evidence kept separately. Use **Shift-hover** for the
  existing detailed diagnostic view; no saved toggle or new command is needed.
- Normal hovers are field-specific, not a dump of the whole profession record.
  Retain observed stat amounts/full names, confirmed-empty versus unknown enchant,
  fresh/last-observed/stale/archived distinctions and useful attention warnings.
  Last Updated explains saved observation age; exact field timestamps remain in
  Shift-hover diagnostics. Never mark a snapshot fresh merely because it is displayed.
- Tree hover shows purchased/capacity, a short branch breakdown including known
  locks, and the native-accounting caveat that future point costs remain unverified.
  Show at most six branch lines and offer full breakdown on Shift-hover. Current
  snapshots lack branch labels: use ordinal branch labels, never invent names or
  collect new APIs solely for tooltip cleanup. Unknown totals get a short explanation,
  not raw rank/currency dumps or fabricated zeroes.
- Raw keys/IDs, currency reconciliation, source pins, generations, attempt metadata,
  raw reasons and the full path breakdown remain available on Shift-hover. Preserve
  native item hyperlinks/third-party tooltip contents for gear indicators; Stat and
  Enchant get focused summaries rather than another full native item tooltip.
- Presentation only: no accounting/collector/schema/table/threshold/theme change.
  Keep all correctness/stress assertions/workloads and the approved local-plus-focused
  validation policy; do not resume the full-client timing chase. Task: TASKS U01.
- Delivered/local164/164+744/565+diagnostic23/23 and independent static review PASS
  on2026-11-08. Original149 assertions/stress workloads retained;15 additive hover
  regressions. Native readability/Shift-hover observation pending after scoped
  ViewModel/Dashboard/SelfTests update; broader T02 acceptance remains incomplete.

#### U02 — named branch-only tree hovers; fewer default tooltips (2026-11-08)

- User observes U01 hovers improved and normal/Shift differ, then explicitly requests
  actual branch names and only `Name: X/Y` lines (e.g.`Calm Hands: 10/10`), without
  `Purchased/capacity`, `Future point costs are unverified` or routine last-observed
  prose. This supersedes U01's ordinal labels/six-branch cap/default tree prose.
  Show every captured branch, not just the first six; X/Y remains individual purchased
  path points/capacity, never the top-level aggregate repeated as the root path.
- Remove normal value-cell hovers on Moxie, Unspent KP, Last Updated, Stat and Enchant.
  Preserve Shift-hover diagnostic access on those cells. Native gear tooltips and
  other existing hovers remain. Header label hovers are unchanged.
- Labels are optional persisted path metadata, separate from identifiers/accounting:
  during the existing guarded scan, use active path entry's definition overrideName,
  else C_Spell.GetSpellName(definition.spellID), following pinned Blizzard talent-name
  usage. No guessed name table, new frame scraping, or live API calls on hover/offline.
  Unavailable labels say `Unknown branch`, not ordinal/invented names. A normal scan
  populates names on older snapshots; absence never invalidates numeric eligibility.
- Keep technical accounting caveats/timestamps/reconciliation on Shift-hover. Routine
  saved-snapshot prose is omitted from normal tree hovers; actual stale/archived or
  unknown states remain briefly distinguished. No freshness/quantity/time mutation.
- This authorizes bounded optional name reads/persistence/validation plus presentation
  changes, not any new accounting method, rank/currency API or scope expansion.
  See TASKS U02 and API evidence Q03; fullclient timing policy unchanged.
- U02 delivered/local181/181+744/565+diagnostic23/23 and independent static review
  PASS/no blockers on2026-11-08. Native name/individual-point comparison and five-cell
  normal/Shift behavior pending after scoped five-file update and one ordinary scan.

#### Knowledge benefits and recipe unlocks — product direction accepted (2026-11-09)

- User wants to pursue earned Knowledge bonuses per branch, preserving conditional
  applicability, and notable recipes unlocked through Knowledge investment. This is
  product scope, not an executable implementation queue until API/data design is ready.
- In a clickable profession Details panel, user requests **all Knowledge-
  gated recipes**, with a checkmark or similar indicator only when the character has
  actually unlocked the recipe (2026-11-09). This replaces a curated notable-only list
  in that view. User “That sounds good” (2026-11-09) accepts the Details panel, earned
  branch bonuses alongside recipes, branch/rank requirement context and three statuses:
  confirmed learned, confirmed not learned, unknown. Implementation/API coverage is
  still unsettled. Discussion: [Q05](../questions/Q05.md).
- Keep Knowledge requirement satisfaction distinct from actual recipe learned/usable
  state; numerical profession-wide totals aren't verified. Unknown or stale learning
  status must not be promoted to a confirmed unlock.
- U02 remains delivered/static-reviewed with native validation pending; the new
  discussion does not establish an installation, API result or completed native check.
- User “Okay, lets do that” (2026-11-09) approves a staged Inscription-first slice:
  prove the native perk reads, then implement the Details panel with branch investment
  and confirmed earned perks using client descriptions/conditions. Do not build empty
  UI before data is demonstrated. Complete recipe catalogue, computed bonus totals,
  profitability and other-profession expansion are deferred, not cancelled.
- First focused read-only check samples a branch description and one milestone's
  required rank/earned state/description. No addon update/fullselftest is necessary
  for this probe; no panel implementation writer until that evidence is recorded.
- Native probe received2026-11-09: Calm Hands/path106280 describes +1 Multicraft,
  Ingenuity and Resourcefulness per point for all Inscription crafts. Perk106276,
  requiredrank0/state2(Earned), describes a Thalassian Treatise on Inscription unlock
  and sub-specialization choice; user confirms it matches the first Calm Hands node.
  This proves sampled data feasibility, not complete perks/recipe learned status.
- U03 production slice uses explicit **Refresh details**, separate from ordinary
  dashboard scans. Capture one bounded unit/frame; preserve prior coherent detail
  snapshots on failures/cancellation. Separate schema1 field stores branch investment,
  client path descriptions and milestone descriptions/states; no computed stat totals.
  Click Profession to view; per-branch navigation keeps long text readable. Opening
  cached/offline/archived details does not collect or inspect offline alts live.
  Details timestamps are independent; dashboard Last Updated/scan age isn't refreshed
  by this details-only action. Recipe-like perk text is not a recipe learning check.
- U03 initial local regression catches a verification→commit frame gap. Correct it
  with a bounded final <=64node scalar check in the commit frame, no perk rereads;
  keep the failing assertion and all limits. Cheap scope guards between frames,
  fullDB validation atstartup/atomicApply only. Native timing remains unmeasured.
- U03 delivered/local214/214+744/565+diagnostic23/23 and independent scoped static
  review PASS/no blockers on2026-11-09. Original181 fixtures/stress and rejecting
  final-gap regression retained. New panel/native acquisition coverage, final-batch
  responsiveness and cached persistence pending focused user checks, not a fullsuite
  rerun. Complete recipe mapping/catalogue and computed totals remain deferred.
- Native follow-up2026-11-10: user confirms prior Details refresh stayed responsive
  with no errors/execution-limit warnings (“Yes it was fine”). This supplements prior
  value agreement; subsequent closed-context/reload observations are recorded below.
  No quantitative latency or blanket all-path/API acceptance inferred.
- Closed-context Details follow-up2026-11-10: user “Yes, all looks good” confirms
  branch investment/perk text/original observation time remain when reopening Details
  with the profession closed and no refresh, shown as saved/notcurrent.
- Reload follow-up2026-11-10: user confirms all values remain and only relative age
  increases as expected. Focused U03 Inscription Details validation is complete for
  reported values, normal-use responsiveness/no errors, closed-context preservation
  and reload persistence. U04 appearance also accepted; no further retest requested.
  Broader profession/API coverage, required-field semantics, recipes and release
  remain separate; full native stress suite stays INCOMPLETE87/149.
- Usability follow-up2026-11-10: user reports Details appears behind other UI, cannot
  be moved, is hard to discover and too verbose. Intended outcome is a concise detailed
  summary without repeated branch navigation to see the desired information. Earlier
  focused correctness/persistence evidence does not establish usability acceptance.
  Park Details improvements for now in favor of filling out the dashboard, which the
  user identifies as highest impact. Preserve existing functionality; no redesign or
  removal authorized. Specific future layout/interaction choices remain unsettled.
  Feedback: [Q05](../questions/Q05.md).

#### U04 — wider flat knowledge bars and hierarchical hovers (2026-11-09)

- User reports U03 values match correctly; no specific values, responsiveness/error/
  warning or cachedpersistence result repeated. Record bounded native agreement, not
  complete U03/fullT02 acceptance. Remaining checks stay pending.
- User requests numeric-only bar labels (remove Blu/Cal/Per/Dar prefixes), more space
  for knowledge bars by reducing Stat/Enchant columns, flat/solid fill, and tooltip
  names indented to show hierarchy. Implementation authorized by direct request.
- Reallocate Stat180→140, Enchant130→110, Knowledge232→292; preserve totalwindowwidth/
  othercolumns/fonts/rowheight. Remove old53px bar cap so bars use their allocated
  column (4bars70px each, responsive to1..8trees). Labels only X/Y or?, names onhover.
  Built-in WHITE8X8 solid texture; no SharedMedia dependency/theme settings.
- Normal tree hovers indent two spaces per child depth using existing saved child
  relationships (rootunindented); full branch names/X/Y and traversalorder retained.
  No new collection or node accounting; diagnostic Shift view and actual stale/
  unknown/archived cues preserved. Scope TASKS U0466→67.
- U04 delivered/local220/220+744/565+diagnostic23/23 and independent scoped static
  review PASS/no blockers2026-11-10. Native width/flatfill/fontindent readability
  follow-up: user says “Oh yeah, that looks a lot better.” U04 appearance accepted
  for this iteration; retain layout. This isn't U03 responsiveness/errorabsence/cache
  persistence evidence or broad T02 acceptance. No scan/selftest/Detailsrefresh requested.

<!-- END PRESERVED PLAN BLOCK -->
