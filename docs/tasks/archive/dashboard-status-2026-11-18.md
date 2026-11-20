# Dashboard status and housekeeping — pre-cleanup snapshot

> Archived 2026-11-18 from pre-cleanup TASKS.md lines 1–124 and 4437–4521.
> Historical status only: some entries are stale even within this snapshot.
> In particular, pending dashboard sign-off/checklist instructions are superseded.
> Do not resume old work or treat this snapshot as current authorization.
> Wording is preserved; relative Markdown link targets alone are mechanically rebased.

[Current task state](../../../TASKS.md) · [History index](../README.md)

<!-- BEGIN PRESERVED STATUS HEADER -->
# TASKS — CraftArmy

> Current implementation handoff and recovery point. Read with [PLAN](../../../PLAN.md).
> Historical contracts are indexed below; they are not active instructions.
> Use `living-plan` for maintenance and `agent-handoff` before delegation.

## Current status — 2026-11-18

- **Next priority: full profession dashboard before guides.** User requests a full view;
  add Herbalism, Mining, Skinning, Cooking and Fishing tracking, keeping existing crafting
  acceptance and Inscription-first guide order. Feasibility/planning only; no executable
  expansion contract or writer. Verify identities, acquisition, field applicability,
  currencies, equipment and stats; distinguish N/A from missing evidence. Preserve saved
  observations, no caps/resets/forced recovery scans. Current code still supports eight.
  See PLAN D05 and latest Q01/Q03. No new commit/push/release authorization.
  [Capability audit / next read-only identity capture](../../dashboard/profession-expansion.md):
  static Cooking2/Fishing1 active equipment slots identified; native identities, context,
  currencies/Knowledge/applicability pending. Documentation-only structural check PASS
  (72 Markdown/390 links/eight diagnostic hashes unchanged), git diff whitespace PASS;
  no fresh Lua/native validation claimed. Await first new-family identity capture.
- **Dashboard explicitly SIGNED OFF2026-11-18:** user happy to sign off on current scope.
  No repeat checks; evidence limits unchanged, not relabelled PASS. User requests GitHub
  **Arbixal/craftarmy** before guide work. User explicitly approves PUBLIC repository plus
  local `main` initialization/initial commit/push of code/tests/assets/project docs. Public
  [repository created](https://github.com/Arbixal/craftarmy), local main/origin configured;
  root README/ignore prepared, repository-local noreply identity. Initial snapshot/push
  authorized only; Git status/log/remote branch SHA are delivery truth. No tags/releases/
  deployments/future mutation approval inferred; no guide work or implementation writer.
- **Focused dashboard checklist results received; user sign-off recorded:**
  [remaining normal-use checks and limitations](../../dashboard/completion-checklist.md).
  U12 and prior focused acceptance remain accepted;
  dashboard sign-off is now explicit; guide implementation is not authorized by it.
- **C4/C6 user-confirmed2026-11-18:** window behavior and selection/Cancel prompts function
  as expected. User now confirms cleaner tooltips and Shift diagnostics as before:
  focused U15/C5 accepted. No repeat/destructive lifecycle checks or guide authorization.
- **U15 locally ACCEPTED2026-11-18:** native-only normal equipped gear/full Shift detail,
  concise statuses/no normal Observed/Attention/hint/long estimate caveat. Independent static
  PASS; PRIMARY512/all19/744K6/565K7/23/Python/exact3targets/27+7preimage/whole Dashboard+
  ViewModel reversals/39freeze PASS. Focused native clean-tooltip/Shift availability
  confirmed2026-11-18. No writer/retest/scan/reset/fullsuite; overall sign-off remains explicit.
- **U13 locally ACCEPTED2026-11-18:** centered Moxie/no `!`/green>600, observed+estimated cyan
  Concentration/approximate total, scrollbar replacing Previous/Next, filtered current-GUID
  rows first with name dot. Predictions never change sort/attention/saved values. Independent
  scoped-static PASS; PRIMARY full512/all19/744K6/565K7/23/Python/exact3targets/40+22test
  preimage/whole ViewModel reverse/39input preservation PASS. No writer. Checklist C2/C3
  revised/new C7 user confirms current-first/dot, Moxie alignment/no!/green>600, distinguishable
  estimated/observed portions, sorting/filtering, visible draggable scrollbar and row range.
  Focused acceptance only; reported drag performance/endpoints resolved in U14 below.
- **U14 locally ACCEPTED2026-11-18:** uniform green Moxie>600 across fresh/saved/history; duplicate-offset scroll
  suppression/frame-coalesced drag paint and solid opaque thumb. No marker/data/filter/
  sorting/Concentration redesign. Independent static PASS; PRIMARY512/all19/744K6/565K7/23/
  Python/exact2targets/13+13preimage/wholeDashboardreverse/40freeze PASS. User confirms Moxie
  color, full scrollbar bounds and good performance2026-11-18. Focused native acceptance
  COMPLETE; no repeat check. C4/C6 now user-confirmed; C5 cleanup U15 below.
- S01 storage implementation is locally accepted. User confirms scans succeed on
  **multiple previously blocked characters** and older snapshots remain correct.
  Accept those focused refresh/preservation observations, not unreported procedures.
- **Dashboard redraw symptom resolved, user-confirmed:** table no longer disappears
  during scans or profession-window open/close. Accept that focused visibility result,
  not unreported hover/action/error/freeze checks or measured native timing. R01 locally
  accepted and focused native visibility confirmed; no further redraw retest requested.
  [Review/acceptance](../../dashboard/redraw-review.md).
- **U06 Skill bar focused user check accepted:** user says everything looks good, then
  requests removing Skill's `!` and suggests Skill-only non-max filtering instead of
  combined Progression. **U07 now locally accepted** with both refinements implemented;
  focused user marker/filter feedback now accepted (“it all looks good”), no writer active.
  Concentration/gear-red remain separate. [Review](../../dashboard/skill-u06-review.md).
- Latest PRIMARY source validation: **512/512 top-level cases**, all19 U07 workloads
  in4 groups and additive UI/parser checks; unchanged744K6/565K7, diagnostics23/23/Python PASS.
  U15 has7 additions/27 authorized inline-original adaptations; exact pre-U15 test
  bytes reconstruct. Runner/caps unchanged; exact reviewed target hashes frozen.
- Independent scoped-static review PASS; executable/hash/full-tree proofs were
  primary-attributed. Extra external derivative bundle remains ungenerated after a
  denied helper write; no retry/bypass. See [S01 review](../../dashboard/s01-review.md).
- No fixed character cap.46/100/200characters×2professions are stress fixtures,
  not ceilings. Shared definitions and bounded personal records remain the design.
- **M01 icon import COMPLETE / locally accepted:**9 exact copies plus README in
  `CraftArmy/Media/Icons/`, original root media assets unchanged. Independent static
  review/primary9-pair hash/header checks and21 protected source checks PASS; structural
  checks PASS. Assets packaged only, not bound to UI/TOC; no new Lua/native execution.
- **U08 title icon locally accepted:**22px icon at top left, title only shifted/shrunk.
  Independent scoped-static PASS; PRIMARY exact reviewed hashes, original-byte
  reconstruction,19 protected source references and9 image pairs/README preservation
  PASS. Fresh512/512 +all19 U07 workloads5/10/2/2,744K6/565K7,23/23 and Python PASS.
  User “It looks good” confirms focused icon appearance; no repeat check needed. Actual
  drag/close procedures/timings not reported. No writer active.
- **U10 gear redesign locally ACCEPTED:**32px rows/28px icons, no Gear
  sorting, red border overriding rarity for older gear and narrower dashboard. Remove
  visible Stat/Enchant columns; large Tool-only stat letter, quality/enchant corner badges.
  Renewed independent static PASS, quality-layer finding resolved; PRIMARY full512/all19/
  744K6/565K7/23/Python,5 reviewed hashes,41+6 test preimage/37input/media preservation PASS.
  Native PARTIAL: user confirms quality/E badges work, but red border/Tool letter absent
  after updated-addon scan; tooltips expansion unknown/own-stat unavailable. Not cache-only.
  No writer/remaining implementation. Dashboard before guides; guides not authorized.
- **U11 locally ACCEPTED:** corrected parser rejection of item-link display-label quality
  markup;24px icons/28px rows with4px icon gaps both axes. Independent static PASS; PRIMARY
  full512/all19/744K6/565K7/23/Python,3 exact targets/38+6 preimage/39-input/media preservation
  PASS. Core/model/storage/metadata semantics unchanged. Latest user: red borders now show,
  Resourcefulness R works, internal icon gaps accepted; Multicraft consistently `...` across
  multiple characters and Gear cramped against adjacent bars. Focused PARTIAL native result,
  not blanket API/input PASS. U12 below; no repeat metadata scan requested.
- **U12 locally ACCEPTED2026-11-18:** presentation-only Tool-letter natural sizing and6px
  outer Gear gutters. Independent scoped-static PASS, PRIMARY full512/all19/744K6/565K7/
  23/Python and exact2targets/25+3 preimage/whole Dashboard reversal/40input preservation
  PASS. Intrinsic mapping,24px icons/28px rows/4px internal gaps/metadata/snapshots retained.
  User confirms “M is visible and the gaps look great”: focused native M visibility/
  outer-spacing ACCEPTED2026-11-18. No repeat check/scan needed. No writer.
- **U09 Concentration locally ACCEPTED:** existing-column
  flat bar/Skill height, centered current/max, blue below cap/green full, neutral unknown;
  remove Concentration's visible `!` only. Keep90% filter/default attention semantics,
  other indicators, freshness/tooltips/layout. User approves tooltip-only approximate
  current amount/time-to-full; observed bar/sorts/filters stay unchanged by predictions.
  Independent scoped-static PASS; PRIMARY512/512/all19 U07/744K6/565K7/23/Python and exact
  target/old-byte/39-input/media preservation PASS. User “Everything looks good and as
  expected” accepts focused bar/tooltip result; no repeat check. No quantified recharge
  accuracy or unreported procedures inferred. No writer/remaining implementation.

## Active implementation queue

**Current execution gate:** no active writer or executable expansion queue. U15 below is
completed history, not authority to resume it. Prepare a separate capability-checked
contract for the five new professions; unresolved native facts block only their dependent
pieces. No guide implementation, reset or repeat accepted crafting checks requested.

<!-- END PRESERVED STATUS HEADER -->

<!-- BEGIN PRESERVED HOUSEKEEPING -->
## Open issues and acceptance gaps

- [x] **Dashboard redraw visibility:** user confirms table stays visible during scans
  and profession-window open/close. Focused symptom closed; broader UI/API/timing and
  unreported interactions are not blanket accepted by that observation.
- [ ] **Dashboard completion:** broader native controls/appearance/API edge coverage
  remains partial. User-approved checklist preparation COMPLETE; C1–C6 results await
  user feedback in [completion checklist](../../dashboard/completion-checklist.md).
  Already confirmed Knowledge/gear/bar/storage/redraw results need no repeat capture/
  identifier/selftest sequence. Checklist preparation is not dashboard sign-off.
- [ ] **Remaining field semantics:** authoritative roster absence/automatic unlearning
  remains unsupported; intrinsic Tool stat is implemented/local-reviewed/fixture-tested,
  with native R/M visibility accepted but contrasting enchant-stat confirmation not
  explicitly reported. Keep that native attribution coverage partial, not wholly unbuilt
  or universally verified. Retain known values/unknowns. See [Q03](../../questions/Q03.md)
  and the checklist's separate semantics table; no unlearning/gear-change test requested.
- [ ] **Review/evidence limitations:** independent executable/comparison proofs and
  measured client timing are not supplied by static review or synthetic clocks.
  Full native suite remains **INCOMPLETE87/149**; all-rank costs **UNVERIFIED**.
  Neither becomes PASS through archiving or is a blanket prerequisite to further work.

The two blocked boxes in historical T02 are preserved in its archive. Their old
missing-identity/blanket numeric-Knowledge blockers were superseded by E01–E03/K09;
genuine remaining conditions are carried above, not silently marked complete.

## Deferred work and priorities

1. Complete the dashboard before guides: obtain remaining C1–C6 feedback and explicit
   sign-off with limitations recorded. No full native-suite completion prerequisite.
2. **Dashboard rounding-out delivered:** Skill/Concentration bars and marker/filter
   refinements, red older-gear borders (superseding the proposed background), quality/E,
   R/M letters and spacing have focused acceptance. No remaining implementation in those
   requests and no routine repeat check. New defects require a new scoped task.
3. **Inscription is the first complete guide.** Guides, shopping/inventory/material
   calculations and Auctionator integration are not built; decisions remain in PLAN.
4. Details redesign stays parked; preserve the existing Inscription functionality.
   Complete Knowledge-gated recipe catalogue/actual learned-status mapping, computed
   bonuses and other-profession Details remain deferred/unverified, not delivered.
5. Cross-account sync, general route optimization and weekly tracking remain in the
   [parking lot](../../parking-lot/P01.md); follow PLAN's individual thread pointers.

## Validation and handoff rules

- Retain full local correctness/stress workloads. Inspect scripts before executing:
  `lua5.1 tests/dashboard.lua`, `lua5.1 tests/run.lua` (installed runtime only),
  `python3 tools/check_dashboard.py`, `python3 tools/check_diagnostics.py`.
- Documentation structural success is not Lua execution, live API or timing evidence.
  No repeated full-client timing chase, raised safety limits or reduced coverage.
- One synchronous implementation writer after a settled, authorized serial contract;
  specify files/dependencies/tests, update statuses/run state at every stop, then review.
- Implementation, independent review, acceptance and release remain distinct gates.
  No reset/eviction, game installation, private data access or Git/release authorization.
- Operational pointers: [validation/recovery](../../references/validation-and-recovery.md),
  [current schema](../../dashboard/schema.md), [dashboard guide](../../dashboard/README.md).

## Done / historical queue index

Dates describe archived work, not blanket feature/client acceptance. T01/T02 contain
unfinished acceptance history; live obligations are retained above. Read the newest
PLAN/thread/evidence entry before acting on any historical ACTIVE/BLOCKED/next label.

| Queue | Work and disposition | Dates | Historical contract/reports |
| --- | --- | --- | --- |
| <a id="next-active-task--s01-shared-definitions-and-independently-bounded-saved-records"></a>S01 | Storage locally accepted; focused refresh/retention confirmed; redraw open | Nov16–17 | [S01](S01.md) |
| <a id="next-active-task--u05-dashboard-colors-dropdowns-header-sorting-and-flat-window"></a>U05 | UI implementation/local review complete; native acceptance partial | Nov16 | [U05](U05.md) |
| <a id="next-active-task--k09-numeric-knowledge-for-the-other-seven-crafting-professions"></a>K09 | Numeric Knowledge implemented; focused native values accepted | Nov16 | [K09](K09.md) |
| <a id="next-active-task--k08-frame-stepped-read-only-crafting-knowledge-evidence"></a>K08 | Read-only capture delivered; focused profession reports accepted | Nov15–16 | [K08](K08.md) |
| <a id="next-active-task--e05-explicit-empty-enchant-field-means-observed-absence"></a>E05 | Explicit-empty enchant correction delivered/confirmed | Nov10–15 | [E05](E05.md) |
| <a id="next-active-task--e04-supplied-enchant-categories--engineering-resourcefulness"></a>E04 | Supplied categories delivered; Engineering Resourcefulness confirmed | Nov10 | [E04](E04.md) |
| <a id="next-active-task--e03-remaining-six-crafting-identities-and-moxie-activation"></a>E03 | Remaining six identities/Moxie delivered; focused checks recorded | Nov10 | [E03](E03.md) |
| <a id="next-active-task--e02-enchanting-moxie-and-supplied-currency-catalogue"></a>E02 | Moxie catalogue/Enchanting mapping delivered and checked | Nov10 | [E02](E02.md) |
| <a id="next-active-task--e01-enchanting-identity-and-guarded-dashboard-scans"></a>E01 | Enchanting scan slice delivered and focused checks accepted | Nov10 | [E01](E01.md) |
| <a id="next-active-task--t02-snapshot-dashboard-mvp"></a>T02 | Dashboard implementation/corrections delivered; overall acceptance partial | Nov5–10 | [T02, including nested R/K/U/V passes](T02.md) |
| <a id="previous-task--t01-read-only-retail-api-diagnostic"></a>T01 | Diagnostics/R1 delivered; broader feasibility partial | Nov5 | [T01](T01.md) |

## Maintenance recovery

- [Archive index and extraction map](../README.md) records original line ranges;
  each block's wording is intact except mechanical relative-link rebasing.
- Original11557-line file backed up before changes; checksum and verification details
  are in [the maintenance log](../../rebalance-log.md). No addon/source/test changes.
- Obsolete Done-index claim that the production dashboard is unimplemented was removed;
  guide work remains unbuilt. Other old status narratives remain historical in archives.
- Use **check → collapse → evict**, with a confirmed manifest and no active writer.
  Keep current status/run state, executable queue, open issues and deferred work here.
<!-- END PRESERVED HOUSEKEEPING -->
