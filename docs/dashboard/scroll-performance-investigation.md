# U16 — Scrolling performance investigation and proposed separation

## Status — 2026-11-20

**PRIMARY read-only investigation complete; design proposal, not an executable writer queue.**
User reports that scrolling CraftArmy visibly pauses patrolling NPCs and other world
animations, unlike a comparable WeeklyKnowledge list. User asks that rendering display
prepared values rather than perform processing/calculations. This is a new performance
report; earlier U14 focused native acceptance remains historical, not evidence against it.
The same message's “Confirmed” accepts P04's Cooking-only warning/filter. Fishing remains
pending; accepted R04 refresh continuity must not regress. No repeated accepted checks.

No production/test source edits, installation, WoW copy, Git mutation, guide work, new
native diagnostic request or performance fix delivered during this investigation.

## Reproducible local evidence

Ignored primary-owned packet: `artifacts/scroll-investigation/`:

- `before-files.json`: SHA256 of all168 project paths before investigation/docs updates.
- `git-before.json`: HEAD and index identity.
- `profile.lua`, `profile.log`, `profile-result.json`: reproducible production-callback
  profile, exact script/log hashes and terminal command result.
- `control.lua`, `control.log`, `control-result.json`: stable-fixture storage-read control.

Run from repository root with the already-installed Lua5.1:

```sh
lua5.1 artifacts/scroll-investigation/profile.lua
lua5.1 artifacts/scroll-investigation/control.lua
```

These are **synthetic host CPU/operation measurements, not native WoW timings**. Native
frame layout, font/texture work, GPU costs, event ordering and other addons are not modelled.
The existing widget mocks perform assertions and retain call records. Instrumented wrappers
add overhead; nested timings overlap and must not be summed or subtracted as a partition.
One run is not a statistically stable latency distribution or an acceptable CI time limit.

### Fixture and protections

Use only the helper prefix of `tests/refresh_continuity.lua`, not its cases. Temporarily
observe `C.Apply` while executing the retained K09 combined-eight knowledge-rich fixture
once; restore that observer on either success/failure. This yields eight full observation
packs without running or modifying the full suite. Populate private schema2 handles with
48/96 records, complete the actual Dashboard incremental build, and use its12 reused rows.
Private collector acquisition methods throw if called. No real SavedVariables are loaded.

Measure real production wheel, slider/frame and estimate/frame callbacks separately.
Profile `S.Active`, `S.Check`, `S.Token`, `C.Copy`, progress/estimate/palette helpers,
Layout/Render/clock and all methods of the private widget metatable. Restore wrappers.
Compare complete saved-root/freshness/row graphs (identity, edges, metatables) and every row's
active token after each operation. All fixtures/proofs pass. All168 project paths were
unchanged after each command; instrumentation is private and does not persist into runtime.

### Results

Uninstrumented callback CPU in the saved run (ms):

| Work | 48 records | 96 records |
| --- | ---: | ---: |
| Five changed wheel events / five paints | 258.066 | 254.051 |
| 100 slider events + one frame / one paint | 49.597 | 51.589 |
| One30-second estimate callback / one paint | 44.548 | 51.328 |
| 100 unchanged ScrollTo calls / zero paints | 5.038 | 6.019 |

The same visible workload has identical operation counts with48/96 total rows. This
does not establish performance at every account size or with every native data shape.
Drag already coalesces to one paint; unchanged offsets already avoid painting.

Instrumented48-record/five-wheel run:

| Operation | Calls | Inclusive CPU ms |
| --- | ---: | ---: |
| Render | 5 | 311.569 |
| S.Active | 60 | 166.991 |
| S.Check | 41522 | 92.444 |
| S.Token | 120 | 0.183 |
| C.Copy | 2672 | 102.115 |
| ConcentrationEstimate | 60 | 0.155 |
| SkillProgress | 60 | 0.113 |
| ConcentrationProgress | 60 | 0.109 |
| TreeRGB | 240 | 0.192 |
| Layout | 5 | 0.491 |
| Private mock-widget dispatch | 10223 | 8.920 |

The Copy time substantially overlaps Active; Render includes all of them. Geometry
queries/sets=1259; SetFont=180. Native geometry/font costs cannot be inferred from cheap
mock calls. Class-color API work is not measured: this fixture has no native class-color API.

An earlier unsaved one-off probe reported309.476ms total /184.802ms Active, with the same
60Active/41522Check/120Token/2672Copy/60Estimate counts. It is historical conversation
evidence only; do not present it as a saved command log or a separate native measurement.

### Controlled storage-read experiment

Preload each private fixture record before measuring. In the experimental run only,
substitute a lookup for S.Active with source identity assertions; restore it afterward.
There are deliberately no source changes or reentrant callbacks in this control.

| Instrumented five-wheel run | CPU ms | Check calls | Copy calls |
| --- | ---: | ---: | ---: |
| Actual storage reads | 312.898 | 41522 | 2672 |
| Private cached records | 136.342 | 41522 | 10 |

This isolates a large avoidable cost **in this fixture** and shows that eliminating the
storage expansion alone leaves substantial duplicate guard/dispatch work. It is **not**
a safe production cache implementation, a source-drift test, a native speedup claim or
permission to substitute cached records for required validation.

## Concrete paths

- `Dashboard:ScrollTo` calls Render synchronously for changed offsets; wheel uses it.
- Render's candidate-cache loop (`Dashboard.lua:1406–1419` at P04) invokes S.Active
  once per visible row **after** widget painting, even when source/model data is unchanged.
- `Storage.selected` audits/copies the selected record and relevant catalogues, validates
  catalogue content and reconstructs/copies an expanded generation. S.Active is not a
  scalar active-generation lookup; knowledge-rich data makes this significant.
- Render `draw()` calls `guard()` before/after every native method. The guard independently
  calls validSource and matches; matches calls validSource again. This repeatedly executes
  S.Check. In ready schema2, S.Check validates root/header/directory ownership, not the full
  account graph, but tens of thousands of duplicate calls still have measurable cost.
- Layout, font setup, labels, progress values/colours, knowledge geometry/palette and
  Concentration estimates are recalculated/reapplied on otherwise data-unchanged paints.
- `V.NewBuildJob` already gets a validated expanded `item.g` and detached row during
  frame-stepped preparation. Re-reading it in every paint is unnecessary duplication in
  principle; exact safe metadata handoff must be specified before changing the runtime.

This identifies actual synchronous cost, **not proof of the sole native stall cause**.

## Proposed U16 design for approval

1. **Prepare once, paint many.** Extend frame-stepped preparation to produce detached
   display packets: final labels, ratios, colours, icon/quality/enchant states, Knowledge
   geometry and compact active-generation/Concentration provenance. Carry provenance from
   the already-validated iterator result rather than expanding storage during painting.
   Do not keep whole generation/catalogue copies merely for display, save packets, or
   modify the existing row/sort/attention/observation data with predictions.
2. **Incremental dynamic preparation.** Concentration packets use the same mathematical
   model and a shared validated clock. Prepare on a new view/observation and at the existing
   30-second cadence in bounded, cancellable frame work; reuse prepared values on scrolling.
   No full-account loop, synchronous job drain or catch-up burst in the wheel callback,
   Render, the function immediately preceding it, or publication. A changed epoch may be
   published only coherently under its source/options/ownership context; unchanged ordinary
   pending refresh keeps the accepted frozen decorations. A new observation must never
   acquire old cyan gain. Invalid clock/rates still suppress predictions independently of dot.
3. **Keep safety, remove duplicated work.** Use an explicit private paint owner/ticket,
   consolidate identical context checks, and retain lightweight boundary checks around
   callback-capable/native calls. Reentry, source detach/swap, collector/freshness/revision/
   token changes, options/GUID changes, failures, combat/hide and supersession must revoke
   the appropriate cache/paint. No blanket guard removal, trusting a handle alone, or
   moving full validation to a synchronous pre-Render loop. Bound continuity work by the
   visible12, never the full account. Full storage/model validation stays in preparation.
4. **Avoid redundant native work.** Fixed fonts/anchors belong in initialization. Layout
   changes on actual geometry/row-count changes, not each offset. Apply changed display
   properties only where safe; never use a global cross-owner “same value” shortcut that
   can suppress restoration after failed/retained/reentrant paint. Native text-width
   measurement needed for the current-player dot remains bounded and ownership-checked;
   use native-compatible blank FontStrings (R04 successful nil means blank).
5. **Reject regressions, then test ordinary scrolling.** Add operation-count tests covering
   actual wheel/drag callbacks, prepared publication, timer coincidence and pending views.
   Reject storage expansion/audits, deep copies, model builds/estimation or account scans
   in paint; bound preparation per frame and native calls/source checks independently of
   account size. Compare prepared visuals/labels and safety against current behavior,
   including Cooking/Fishing, normal/Shift hovers, selection/filter/sort, continuity,
   invalid data and native API nil/error semantics. Retain all existing suites/workloads;
   old harness assumptions about clock/helper call locations need explicit, recoverable
   review, not wholesale replacements. Synthetic timings are supporting evidence, not
   flaky pass/fail limits. Independent static review and separately attributed primary
   execution precede only focused ordinary-scroll native feedback.

### Contract details still to settle before a writer

- Exact ownership/location of prepared packets and provenance handoff; avoid runtime
  metadata leaking into SavedVariables or prediction changes to model rows.
- Source/active-token certificate validation, including rejection of malformed/unregistered
  storage and direct source drift. A raw mutable saved-root record is **not** certified
  merely because its token is unchanged. Document the supported invariants and retain
  explicit corruption/reentry rejection tests rather than silently weakening a guard.
- Numerical per-frame preparation and per-paint guard/native-call bounds, packet invalidation,
  and shared clock epoch/publishing rules. Scroll reuse means it no longer recomputes an
  estimate on every wheel notch; this display-cadence consequence must be explicit.
- Exact permitted old-test adaptations, file ownership, fresh snapshot, full serial queue,
  build marker and validation commands. No writer is READY until this is complete.

The requested product direction is clear. The proposed refactor is broader than a one-line
cache patch; obtain focused approval, complete these mechanics and then use one synchronous
implementer, independent review and primary acceptance. No installation/Git/release authority.

## 2026-11-20 — Refactor approved, existing-work checkpoint required first

User approves this refactor and explicitly requires existing work committed and pushed
to origin first. The checkpoint covers existing reviewed source/tests/docs and this
investigation/approval, not performance implementation. TASKS U16 records the scoped normal
main→origin/main authorization and prerequisite verification. No source writer until that
checkpoint is remotely verified and remaining implementation mechanics are fully specified.
No force push, release, install or subsequent refactor publication authorization inferred.
