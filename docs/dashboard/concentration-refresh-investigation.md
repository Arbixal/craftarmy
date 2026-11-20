# Concentration refresh flicker — investigation

## 2026-11-20 — Focused native fix accepted

After the R04 empty-FontString correction, user confirms: **“That has fixed it, good job.”**
Accept the reported current-player-dot/Concentration-estimate refresh continuity fix in WoW.
No repeat screenshots, version interviews or ordinary-refresh checks needed. Earlier R02/R03
failures and controlled reproductions below remain historical evidence. Exact event cadence,
measured latency and offline estimate accuracy are not established; native full-suite limits
and broader unreported acceptance remain unchanged. No new code/install/Git/guide authority.

## 2026-11-20 — Screenshot narrows path; empty-FontString contract reproduces symptom

Screenshot received: previous saved view / last observed; ordinary **Building saved
dashboard incrementally**; raw status **Open your own profession to refresh**; loaded
Dashboard0.2.0-mvp+r03.1; Active/All,45rows. No displayed scheduler/render/build error.
It supplies the requested evidence; do not repeat status/version questions.

### Concrete mismatch

Dashboard.demoteVisible reads every cell label with pcall(GetText). It considers only a
string successful. A nil result sets ok=false, and its later failure branch clears both
continuity and lastPaint. Gear cells intentionally use an empty FontString when showing
only icons; so this can discard the indicator cache during a perfectly ordinary Retain.

- [Current Warcraft Wiki FontString:GetText](https://warcraft.wiki.gg/wiki/API:FontString_GetText)
  documents `string?`, nil if no text is set (read2026-11-20).
- [Archived widget reference](https://wowwiki-archive.fandom.com/wiki/API_FontString_GetText)
  explicitly says nil when the FontString is an empty string. Historical corroboration,
  not current-client execution proof.
- Our standalone widgets' GetText always return their stored string, including `""`.
  Existing generic refresh fixtures also begin with unknown, not icon-only, gear.

### PRIMARY controlled reproduction

`lua5.1 artifacts/r04-investigation/fontstring-empty-probe.lua` terminal exit0:

| Sole changed private widget behavior | During pending Refresh | Publication |
| --- | --- | --- |
| Existing mock returns empty string | Dot visible, cyan visible | Both visible |
| Native-compatible empty FontString returns nil | BOTH hidden, observed-only label | Both restored |

Both runs intentionally use one icon-only accessory so production Render clears its label;
all production Dashboard/collector/storage code is identical. Pending/raw status matches
the screenshot. Complete saved-root/token comparisons PASS;166actual project paths and all
sixaccepted R03 hashes unchanged. Probe/log/freeze in same ignored artifact directory.
An earlier exploratory fixture only had unknown gear and failed its empty-label precondition;
correcting fixture presentation produced the meaningful control/experiment above.

This proves a concrete API-handling defect can produce the exact symptom/status; it is
not an in-client call trace or proof there are no additional native causes. No more screenshot
or marker interview needed before proposing the narrow fix. No source/test edits/full suites.

### R04 proposal — implementation approval pending

Normalize a **successful nil** label read to normal blank before string warning demotion;
do not treat thrown GetText, false/numeric/table results or ownership/source drift as safe.
Correct the native widget mock, add icon-only/hidden blank-label continuity and genuine
failure/reentry regressions, advance loaded build. Keep source/observation/collection rules,
model maths/saved data/sort/attention/layout unchanged. No further speculative handoff
redesign, runtime tracing, install/copy/Git or guides. Complete scoped contract/approval next.

## 2026-11-20 — R03 build confirmed; native symptom persists

User confirms current expected version, but both player dot and Concentration estimate
still disappear until refresh completion. R03 native continuity is **NOT accepted**.
Do not treat this as just legitimate no-gain cyan-to-blue conversion: the dot disappears too.
No repeated version check needed. Marker identifies Dashboard source, not all installed
modules; incomplete installation is neither proved nor assumed.

Read-only primary follow-up examined cache preparation/validation, retained rendering,
remaining generic cleanup, normal publication and collector event paths. These include
deliberate fail-closed demotion and protected cache preparation errors; actual native
branch/reason has not been established. No new runtime/test edit or fresh validation PASS.
Rather than another speculative fix, next capture the **existing** Shift status tooltip
while decorations are absent, including previous-view/pending reason and Raw status.
No new native dump, repeated profession checks, forced scans or resets requested. Runtime
instrumentation or further implementation would need its own approved scope if necessary.

## 2026-11-20 — Expected Dashboard build confirmed; collection transition reproduced

User confirms `0.2.0-mvp+r02.1` while both dot and estimate still disappear during refresh.
Loaded Dashboard identity is no longer unknown; no repeat marker check. Marker does not
verify all installed modules. R02 native continuity remains NOT accepted.

PRIMARY read-only probe: `artifacts/r03-investigation/collector-sequence-probe.lua` with
installed Lua5.1. Reuses existing P01 private API/widgets, invokes actual Commands.Event,
Collectors.Request/Scan and Dashboard frame/build callbacks. No project source/tests edited.
Chosen synthetic callback ordering does not establish native order, triggering event or cadence.

| Synthetic sequence | During pending replacement | After publication |
| --- | --- | --- |
| Event during build → dashboard frame → queued Scan | Both hidden | Both visible |
| Event during build → queued Scan before dashboard frame | Dot visible, estimate hidden | Both visible |
| Completed view → successful Scan, same amount/new timestamp | Dot visible, estimate hidden | Both visible |

All three asserted **PASS**. Initial observation at100/paint200 gives `~200/1000`; Scan at210
observes100/1000 anew, then publication at220 gives `~110/1000`. These deliberately chosen
fixture times/rates are not measured native/offline accuracy evidence. Saved-root/token
identity checks around UI-only operations pass; scans intentionally update private fixture
storage. All163actual project paths/accepted V01 target hashes unchanged by probe. Logs/
source-freeze are in the same ignored directory. No full suites repeated or new native PASS.

### Mechanism in the loaded source

- Commands.Event forwards currency/trait/etc events to Collectors.Request. Request calls
  Invalidate immediately (revision changes, fresh table replaced) and schedules Scan later.
- An already armed Dashboard continuity record pins exactly that collector context.
  Dashboard OnUpdate/driver validates it; any revision/fresh/token drift leads to generic
  Retain and clears both the exception and reusable last-good cache. Subsequent successful
  Scan cannot borrow that discarded paint even when player/generation are unchanged.
- Independently, every successful Concentration rescan updates observation/attempt time.
  prepareContinuity's exact provenance comparison rejects the cached estimate—even with
  unchanged quantity/cap/rate—until full view publication. This deliberately obeys R02 but
  does not deliver continuous display through actual observation renewal.
- R02 tests covered manual invalidation before Refresh and expected fail-closed drift during
  pending callbacks; those passed but did not require continuity over this production handoff.

### Proposed R03 scope — approval required, no runtime edits yet

Revalidate visible current-player active identities independently across ordinary collection
handoffs. When Concentration is renewed, replace its visible observed/estimated display from
the verified new observation without an intervening empty projection while the full list
builds. Preserve truthful historical/pending status, source/GUID/options/generation/reentry
safety and observed-only saves/sorting/attention. Do not simply remove revision guards or
keep old projections over changed observations. Actual callback-sequence regressions and a
new loaded-build marker are required. Complete implementation contract/user approval next;
no install/copy/Git/guide/native retesting or further runtime changes authorized by this probe.

## Latest native follow-up — 2026-11-19

After R02 local acceptance, user reports both Concentration estimate and current-player
dot still disappear during refresh. Running-client code identity is unknown; neither
outdated installation nor current-build failure cause is established. R02 native continuity
is not accepted. User requests version identification, including Shift-only presentation.
V01 embeds a loaded-dashboard build in Shift status detail; no additional flicker-policy
change or install/copy is authorized. Establish the displayed build before further diagnosis.

## User report — 2026-11-19

After confirming the three gathering reports' numbers agree with native UI, user reports:
“when the dashboard is refreshing (periodically and I'm not sure how frequently) the
estimated concentration disappears and then is redrawn again.” Exact frequency, triggering
event and native cause are unconfirmed. No gathering error-free/responsiveness or broad
dashboard acceptance is inferred. No source fix or activation authorized; no writer active.

## Read-only findings

- `CraftArmy/Dashboard.lua` StartBuild always paints a retained previous view before
  scheduling the replacement build, even when the completed context is unchanged.
- Retain calls demoteVisible, which hides the cyan estimate and restores the observed
  label immediately. Render also suppresses estimates while retained/building. Completed
  publication restores the estimate. These are deliberate U13 observed-only retained-view
  safeguards, not simply an accidental texture Hide call to remove.
- The separate dashboard OnUpdate accumulates30seconds then calls Render, not Refresh.
  Hide/show within a synchronous Render does not by itself demonstrate a visible native
  frame gap. The rebuild path leaves the estimate hidden across callback boundaries.
- `CraftArmy/Commands.lua` collector changed callback calls dashboard Refresh. Collection
  and event requests can therefore rebuild it. Registered events include currency/trait/
  profession updates. No dedicated periodic rebuild timer found in this path; no particular
  event or cadence is attributed to the user's client without evidence.
- Estimate demotion/build suppression predates P01; P01 adds the N/A applicability check.
  This is not evidence that the profession expansion introduced the symptom.

## PRIMARY focused local reproduction

Temporary probe: `/tmp/opencode/craftarmy-concentration-refresh-probe.lua`, run with the
already-installed `lua5.1`. Reuses existing P01 API/widget helpers in a private namespace
without executing the full additive/legacy suites. No production/test files edited.
Uses a schema2 storage handle and one saved Inscription Concentration observation:
quantity100/max1000, observedAt10, one point/second; initial fixture time100.

Terminal outcome: **PASS**, pure fixture evidence, not native rendering/latency proof:

1. Initial completed view shows cyan estimate and `~190/1000`.
2. At time130,30-second OnUpdate repaint keeps estimate visible at callback return,
   label `~220/1000`, identical rows, no build job.
3. Unchanged-context Refresh retains the completed rows but hides estimate immediately,
   label `100/1000`, with build job pending.
4. Replacement publication restores cyan and `~220/1000`. This small fixture completes in
   one scheduler callback; no native callback duration or large-roster latency inferred.
5. Explicit collector invalidation followed by Refresh also hides then restores it.
6. Recursive identity/edge comparison proves the saved graph unchanged by the probe.

This reproduces a mechanism consistent with the report; actual periodic native trigger
remains unknown. No new full-suite/native/estimate-accuracy PASS is claimed.

Evidence-only checks: PRIMARY dashboard structural checker PASS89Markdown/487links/eight
diagnostic hashes; whitespace PASS; all11accepted P01 source/test/README hashes unchanged.
Repo-local immutable pre-P01 Dashboard confirms the same demotion/build suppression path.

## Proposed direction — not an executable task

A targeted presentation correction could avoid unnecessary demotion for safe refreshes
or preserve an eligible completed estimate while a replacement builds. Any exception to
the accepted retained=observed-only policy needs a separate approved contract, explicit
provenance/source/generation/applicability checks and rejecting regressions. Do not remove
the retained/build guards globally: failed/cancelled/detached/superseded, archived and N/A
views must retain their truthful fallback behavior. Preserve observed-only saved values,
sort/filter/attention, approximate labels and current accepted controls/layout.

**Original user direction2026-11-19:** defer until other-profession work first. User has
subsequently confirmed all four P03 refinements; that ordering prerequisite is satisfied
for the refresh follow-up. Current scope includes both estimate and current-player dot.
No source-fix implementation contract/approval or writer yet. P01/P02/P03 remain accepted,
not reopened. No installation, Git mutation, release or guide work from this ordering.

## 2026-11-19 — P03 accepted; current-player dot flicker added

User confirms secondary Moxie dash, gathering colours, Deftness D and gathering-only
missing-enchant warning behavior. Focused four-feature acceptance complete, not new
evidence that Cooking/Fishing Tools cannot be enchanted or blanket error-free/timing/
overall dashboard sign-off. No repeat profession checks needed.

New report: current-player identification dot also flickers off during refresh. Static
Dashboard inspection confirms `demoteVisible` explicitly hides `cell.currentDot`, and
Render only shows it when `not self.retained` plus row/current-GUID match. This shares
the estimate's retained-build hide-and-republish mechanism. A combined scoped correction
must retain identity/source/archived/N/A/invalidation safety, not globally remove guards.

PRIMARY temporary read-only probe:
`/tmp/opencode/craftarmy-refresh-dot-estimate-probe.lua`, installed Lua5.1, existing private
P01 API/widget helpers, schema2 handle plus full saved root. No production/test files edited.
Terminal **PASS**, synthetic callback-boundary evidence only:

1. Completed own Inscription row shows dot and `~190/1000` estimate.
2. At fixture time130,30second estimate repaint leaves both visible, same rows/no build.
3. Unchanged-context Refresh retains completed rows while replacement build is pending;
   both dot and estimate are hidden at callback return.
4. Completion publication restores both. Explicit collector invalidation followed by
   Refresh reproduces the same hide/restore sequence.
5. Full recursive identity/edge comparison of **saved root**, plus storage-token equality,
   proves no snapshot mutation during this probe. It does not replay native events.

The dot and estimate symptoms are reproduced together locally; native trigger/cadence/
measured frame duration remain unknown. No new full suite/native run or source fix claimed.
Next: approve/design one refresh-continuity task for both indicators, preserving observed-
only saved/sort/attention semantics and source/GUID/generation/render ownership guards.
