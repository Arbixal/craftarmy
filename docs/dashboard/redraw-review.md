# R01 redraw correction — review and acceptance

## Current gate — locally accepted; focused native visibility confirmed

**User follow-up 2026-11-17:** “Table no longer disappears during a scan (or opening
and closing the profression windows)”. Accept the targeted redraw-visibility symptom
as resolved. No further redraw retest requested. Hover/action recovery, error/freeze
absence and measured timing were not separately reported; broader native acceptance
remains partial. Local source/hashes unchanged; no new Lua execution implied.

**2026-11-17:** R01 implementation plus 25 additive cases complete. Primary reproduced
488/488 dashboard, unchanged744K6/565K7, diagnostics23/23 and both Python checks PASS
after independent renewed scoped-static PASS. Both findings resolved. Exact reviewed
source hashes and original-case preservation confirmed by primary; source unchanged
after validation. **Local acceptance PASS**, not native/API/performance or release PASS.
No writer/remaining implementation piece. Focused visibility follow-up now received above.
Earlier pending/rejected statuses below are preserved chronology, not active gates.

Independent executable/comparison evidence remains unavailable. Primary proofs stay
primary-attributed. No denied operation/artifact or missing old bundle retried.

## Initial delivery gate — preserved chronology

User authorized redraw-only implementation 2026-11-17. [Task](../../TASKS.md),
[settled contract](redraw-r01-contract.md), [initial investigation](redraw-investigation.md).
No native/update/release acceptance yet. Follow-up Skill/Concentration bars and
previous-expansion red gear are not implemented by R01.

Implementer `ses_e1972d0c5ffeve4pvRGFPBrWTd` delivered Dashboard changes and 17 new cases.
Reported baseline 463/463 → final 480/480, unchanged 744 K6/565 K7, diagnostics 23/23
and both Python structural checks PASS. These are implementer-attributed until independently
reproduced; exact outputs and retained failure chronology are in TASKS Report back.

## Primary pre-verification review

- Read Dashboard diff against the immutable pre-R01 snapshot. Scope is retained completed
  presentation, generic historical hovers/action gating, matching-job coalescence and
  guarded atomic replacement/cleanup. No storage/collector/model/event/accounting changes.
- Process exception: first pre-fix test attempt had a fixture helper-scope defect and
  is not valid behavioral rejection. Corrected new-case/frozen-old-Dashboard overlay
  later fails the direct retention assertion; chronology must not be called test-first.
  Primary accepts that differential evidence in place of chronological compliance,
  subject to independent examination. No original scenario/assertion adaptation authorized.
- Denied read of first rejection artifact was not bypassed; not needed for acceptance.
  Corrected rejection output was directly returned by a separate approved execution.
  Do not access the denied artifact to retry that operation.
- Generated `tools/__pycache__/check_dashboard.cpython-312.pyc` was left untouched.
  Baseline snapshot/manifest deliberately excluded __pycache__, so comparison cannot
  establish it was newly created by the implementation. Primary imported the checker
  earlier for anchor inspection, consistent with this expected Python cache. Preserve
  that limitation rather than attribute unknown provenance or discard user files.
- Platform review N/A: local addon UI/test-only, no infrastructure/CI/release behavior.
  No implementation writer remains active. Independent review may now inspect frozen files.

## Comparison base and frozen target

Pre-R01 snapshot:
`/tmp/opencode/craftarmy-redraw-r01-elw6wfx3/baseline/`, manifest alongside.
No Git repository. Expected changes from that snapshot: primary PLAN/TASKS/Q05/
redraw-investigation documentation; new R01 contract/review; implementer Dashboard and
additive SelfTests only. Generated cache excluded from baseline as described above.
No other source, runner, tools, diagnostic, storage, agent or archived history change.

```text
5e9b3607a96cd449872d87bde5b0c620d9b84ca3a4343c282fb68f03ac9f9e23 CraftArmy/Dashboard.lua
4fb71c0dbb9c9363aa3ad7ad7a35d36b685845f18d07ff5bbd73edf254cf94f1 CraftArmy/SelfTests.lua
```

All other source/check hashes are the accepted S01 ones in its review record.
Required independent gate: inspect source/test delta and contract, attempt only authorized
local validation, report exact evidence/provenance, findings and acceptance separately.
Primary must persist that read-only report before advancing. Native still NOT RUN;
historical fullnative INCOMPLETE87/149/allrank UNVERIFIED remain unchanged.

## Independent review round 1 — CHANGES REQUIRED

Verifier `ses_e195b9a78ffef65wBz1PheQ078`: PARTIAL review; Acceptance CHANGES REQUIRED.
Read-only source/contract/additive-test/runner inspection completed; no edits. Two
medium static findings block acceptance on the frozen hashes above:

1. **Hover ownership captured too late** (`Dashboard.lua:453–466,176–179,499–501`).
   Cell captures its row before overridable Shift lookup; if that call replaces the
   source and completes its new build before returning, focusedTooltip/tooltip capture
   the new ready context but still receive the old row's text/link. Tree has equivalent
   ordering. Existing Shift test leaves replacement pending and misses completed reentry.
2. **Retained-mode render failure can leave fresh amber text** (`Dashboard.lua:558–560,
   590–594,637–643`). If an early widget SetText throws before pending render reaches
   a later Skill cell, its old fresh marker stays visible. Error handler labels retained
   mode but does not complete safe presentation. Existing fault injection occurs after
   the first historical render and misses failure entering that mode.

These were static findings, probes not executed. Primary must reproduce and settle a
bounded correction before implementer follow-up; no source acceptance at this stage.

Independent limitations: manifest external-directory read and initial shell hash
inventory denied; no alternate access/retry. Lua/Python execution, probes, differential/
byte/hash/full-tree comparisons and post-review freeze not independently performed.
Original-case preservation and execution remain implementer/primary-attributed. Do not
use another role to relabel those denied checks independent. The direct retention test
is meaningful and corrected old-source rejection is valid in principle, not chronological
test-first compliance. Native NOT RUN; platform N/A remains scoped to declared changes.

## Primary round1 reproductions and correction direction

Executed isolated installed-Lua probes using the existing R01 fixture/pump helpers;
no source/test edits. These are PRIMARY evidence, not a retry of denied independent
execution/comparison operations. The denied artifact was not accessed.

```text
REPRODUCED cell: new completed source has 0 rows, old-source tooltip text still shown.
REPRODUCED tree: new completed source has 0 rows, old-source tooltip text still shown.
REPRODUCED render entry fault: retained=true, row visible, Skill still carries fresh amber marker.
PRIMARY focused probes only; no source edits or native/independent execution claim.
```

Cell/tree probes install an old-source tooltip sentinel; IsShiftKeyDown replaces the
collector handle with a new empty schema2 source, Refreshes and drains the replacement
before returning true. The old hover incorrectly publishes that sentinel despite a
completed zero-row replacement. Render probe sets a fresh amber Skill sentinel, renders
it, then injects an early Name-label SetText fault before Refresh; Skill remains amber.

Both findings confirmed. Primary settles the narrowly scoped contract amendment below
and task piece5, not a feature expansion. Renew independent scoped-static review after
correction; independent executable/comparison evidence remains unavailable. Primary
validation/comparison may support bounded acceptance without being reattributed; no
denied checker/bundle/artifact operation may be retried under another role.

## Piece5 correction delivered — renewed scoped-static review pending

Implementer delivered original hover provenance plus independently protected visible-cell
historical demotion/fault isolation. Added eight more cases; original 480 cases preserved
verbatim per implementer removal/hash proof. Seven cases ran against reviewed source
before correction: 1 PASS / 6 behavioral failures, with exact outputs in TASKS. Final
delivery reports 488/488 dashboard, unchanged744K6/565K7, diagnostic23/23 and both Python
checks PASS. These are implementer-attributed; independent executable evidence unavailable.
No writer remains active. The next reviewer should assess sections1–9 against this exact
target and resolve both round1 findings, without retrying denied operations.

```text
b8157d436a61c0d8a6559e4a9f98ec41546c54a3b9f254af197a009fcb467dee CraftArmy/Dashboard.lua
3eb05897c908410c6916915f9c354ca07d87fd02b256679a78d34ad874c746d3 CraftArmy/SelfTests.lua
```

Native NOT RUN, no user update advice before renewed review/primary acceptance.

## Independent review round 2 — PASS (scoped-static only)

Verifier `ses_e195b9a78ffef65wBz1PheQ078`, COMPLETE scoped-static review; Acceptance PASS
for that scope. Both round1 findings RESOLVED, no new blocking correctness/bounded-work
findings. Original hover provenance is captured before overridable work and carried
through rendering/cleanup; independent per-label demotion/fault isolation prevents
early ordinary-render failure from stranding fresh markers. Eight new cases meaningfully
cover completed replacement, old item links/newer hover protection, early/persistent
render faults, partial publication, graph immutability and sweep reentry.

Read-only local source/test/contract inspection only. Reviewer did not run commands,
recompute hashes, compare baseline/manifest/files or verify post-review stability; no
denied operation retried. Supplied b8157d…/3eb058… target identities and implementer
488/488+744K6/565K7/23/Python/preservation proofs are not independent execution evidence.
No writer active. Primary must confirm exact-target validation/preservation and freeze
before bounded acceptance. Native NOT RUN; fullnative INCOMPLETE87/149/allrank UNVERIFIED
remain unchanged. No installation/release approval; platform N/A for declared UI-only scope.

## Primary exact-target confirmation and local acceptance

After renewed scoped-static review, primary directly executed:

| Command | Actual result |
| --- | --- |
| `lua5.1 tests/dashboard.lua` | 488 passed / 0 failed; K6 744 / K7 565, unchanged |
| `lua5.1 tests/run.lua` | 23/23 pure fixtures PASS |
| `python3 tools/check_dashboard.py` | PASS, diagnostic baseline unchanged; structural only |
| `python3 tools/check_diagnostics.py` | PASS; structural only |

Local recorded-digest checks (no external manifest or denied artifact reads) verify all
16 S01 source/check inputs with only the two approved replacements. Removing the eight
round1 cases' block reconstructs the full reviewed480-case SelfTests digest; removing
the original17 R01 cases' block then reconstructs full original463-case digest. Thus all
original assertions/helpers and runners/supplements remain byte-for-byte, not merely
equivalent counts. Other14 recorded inputs unchanged. Exact final hashes:

```text
b8157d436a61c0d8a6559e4a9f98ec41546c54a3b9f254af197a009fcb467dee CraftArmy/Dashboard.lua
3eb05897c908410c6916915f9c354ca07d87fd02b256679a78d34ad874c746d3 CraftArmy/SelfTests.lua
```

This is **PRIMARY** execution/preservation/post-review source-freeze proof, not independent
execution or full-tree comparison. Independent scoped-static PASS + primary full checks/
target confirmation support bounded local acceptance under the existing evidence policy.
Full native INCOMPLETE87/149/all-rank UNVERIFIED and broader field/UI limitations unchanged.
No code edits after final checks, no private data/game installation/Git/publication action.
User update guidance is now permitted; native redraw confirmation remains pending.
