# CraftArmy — agent instructions

## Project state and sources of truth

This is a World of Warcraft Retail addon project with diagnostics and the dashboard
implemented. Full local Lua/stress fixtures pass; S01 storage refresh and older-snapshot
retention are user-confirmed. R01 redraw visibility during scans and profession-window
open/close is user-confirmed; broader native/required-field acceptance remains partial.
Skill bar and Skill marker/filter refinements have focused user acceptance.
U09 Concentration observed bar/no! and tooltip-only estimates have focused user acceptance;
measured offline estimate accuracy remains unverified. U10 combined gear icon redesign
has focused native quality/E acceptance. After U11, user confirms red borders and
Resourcefulness R;24px icons/28px rows/internal gaps accepted. U12 natural-size letter/
6px outer gutters locally accepted2026-11-18; user confirms M visible and gaps look great.
Focused M/outer-spacing acceptance complete; no repeat check/metadata scan needed.
Exact native font cause and broader native acceptance are not inferred.
U13 locally accepted2026-11-18: Moxie centered/no!/green>600; observed+cyan estimated Concentration
with approximate total; scrollbar replaces paging buttons; filtered current-GUID rows
first with name dot. Estimates may drive display only, never sort/attention/saved values.
User confirms current-first/dot, Moxie center/no!/green>600, distinguishable Concentration
segments, sorting/filtering and row count. U14 locally accepted2026-11-18: uniform
historical Moxie green, duplicate-paint suppression/frame-coalesced drag, opaque thumb.
User confirms Moxie color/full scrollbar bounds/good performance; focused U14 native
acceptance complete. Exact cause/measured latency not inferred. User confirms C4/window
and C6/Cancel function as expected. U15 locally accepted2026-11-18: native-only normal gear hovers,
addon detail on Shift, no routine Observed/Attention/hint or long estimate caveat normal.
Diagnostic provenance/assumptions and meaningful unavailable/stale safety cues retained.
User confirms cleaner tooltips/Shift diagnostics as before; focused C5/U15 accepted.
No repeat accepted checks/scan/full suite needed. User explicitly signed off the dashboard
2026-11-18 and approves PUBLIC GitHub Arbixal/craftarmy plus local main/initial commit/push.
Repository created/origin configured; Git status/log/remote SHA record delivery. Bootstrap
approval is scoped to initial snapshot, not future commits/push/releases/deployments.
Guide work has not started. Unreported hover
dismissal/scroll procedures and broader API coverage are not inferred.
New optional metadata fills on ordinary own scans; existing snapshots must stay intact.
Guides are not built. U13 supersedes tooltip-only estimates; predictions never drive
sorts/attention or saved data.
Read `PLAN.md` and `TASKS.md` first; load detailed design/history only as needed.

Icon pack is packaged in `CraftArmy/Media/Icons/` with a manifest README; root `media/`
originals are user-supplied and must be preserved. U08 binds the main64px TGA to a22px
dashboard title icon; locally accepted and appearance user-confirmed. Unreported input
checks are not inferred. No TOC branding.

- `PLAN.md` records confirmed requirements and decisions.
- `docs/design.md` contains proposals; it does not silently authorize implementation.
- `TASKS.md` is the implementation contract and durable recovery point.
- User work must not be overwritten or discarded. The diagnostic structural check
  is `python3 tools/check_diagnostics.py`; pure Lua fixtures use `lua5.1 tests/run.lua`
  only if already available, or `/cad selftest` in WoW. Structural success is not Lua
  execution or client evidence; never invent a successful validation result.
- Confirmed validation policy (2026-11-07): retain full local correctness/stress suites,
  use focused user-run WoW normal-use/API/snapshot checks. The full in-client suite
  remains INCOMPLETE after timing stops; completing it under the cutoff is not a blanket
  prerequisite for further native work. Never raise limits, reduce coverage or relabel
  INCOMPLETE as PASS. Follow the current PLAN/TASKS/README gates, not superseded retest
  instructions in historical delivery logs.

## Development workflow — planning vs implementation

The primary thread owns user interaction, design choices, task preparation, review,
and coordination of live testing. Use the `living-plan` skill for design interviews,
scaffolding, adoption, rebalancing, and eviction of completed task queues. A design
interview runs in the primary thread, not a subagent.

Once design is settled and the user authorizes implementation, prepare a complete
active task and use the project `implementer` agent. Use the `agent-handoff` skill
whenever crossing an agent boundary. Do not launch an implementer while the task is
BLOCKED or has no executable pieces.

Default to one synchronous implementation writer, executing a serial numbered queue.
Parallel agents are a separate explicit opt-in. The implementer must not launch
children, choose architecture, or expand scope. A blocked piece only blocks its
dependents; independent pieces may proceed. Update `TASKS.md` piece statuses and
run state at every stop so work is recoverable after interruption.

Before delegation, specify file ownership, scope, dependencies, validation, and
required report. Do not rewrite assigned files or the active contract while the
implementer works. The primary persists read-only review findings and acceptance
evidence before advancing. Implementation, verification, acceptance, and release are
distinct gates; passing tests never grants publication or Git mutation approval.

## Planning-document maintenance

Keep `PLAN.md` lean. Invoke `living-plan` when it becomes heavy (default threshold
15,000 words) or completed work dominates `TASKS.md`. Preserve cooled detail under
`docs/` and leave links. Question and parked-thread histories are append-only.
Propose and confirm file relocations and thread promotions; do not treat a proposal
as settled simply because it is written down.

PLAN is the hot requirements layer. Preserved D05/D07 histories and older sessions
are indexed in `docs/decisions/README.md` and `docs/sessions/README.md`; questions and
parked work stay under `docs/questions/` and `docs/parking-lot/`. Load history only as
needed. The approved 2026-11-17 all-nine-session archive is a one-time exception;
future maintenance still keeps the latest three sessions inline. Use `living-plan`
and a confirmed manifest for further relocations; old gates never supersede current ones.

Completed task work follows **check → collapse → evict**, using `living-plan` and a
confirmed manifest with no active writer. Keep current status, active queue/run state,
open issues and deferred work in TASKS; lift live conditions out before archiving
partially accepted history. Preserve history/link meaning and verify retention. Archive
index: `docs/tasks/README.md`; operational lessons: `docs/references/validation-and-recovery.md`.
Historical ACTIVE/BLOCKED/next labels never authorize execution or supersede current gates.

## Addon design guardrails

Follow the confirmed product decisions in PLAN.md: distinguish observed values from
unknown/stale data, verify APIs against the target Retail client, preserve known
snapshots on transient API failures, and keep identifiers separate from localized
labels. Do not promise live offline-alt inspection or automatic purchasing/crafting.
The dashboard and guide requirements are recorded in D01–D03; unresolved technical
choices belong in their question threads, not ad hoc implementation defaults.
