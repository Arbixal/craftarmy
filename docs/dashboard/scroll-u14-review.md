# U14 — Uniform Moxie and efficient scrolling

## Gate — locally accepted; focused native brightness/endpoints/performance accepted2026-11-18

[Contract/report](../../TASKS.md#u14--uniform-moxie-brightness-and-efficient-endpoint-clear-scrolling),
[requirements](../../PLAN.md), [thread](../questions/Q05.md).
User accepts U13 current-first/dot, Moxie center/no!/green>600, observed/estimated segment
distinction, sorting/filtering, visible draggable scrollbar and range. Wants identical
Moxie green for historical/snapshot values; reports drag overhead versus wheel and thumb
not visually reaching track ends. U14 does not repeat or redesign accepted features.

Primary unchanged-source reproduction:100 ScrollTo(1) requests invoke100Render at same
offset. Proves redundant dispatch, not native timing/complete lag cause. Opaque solid
thumb removes artwork padding as a possible contributor; native endpoint cause/fix unknown.

## Reviewed targets and scoped-static review — PASS2026-11-18

```text
bfd90312faa31876b57b5811554cc837fe3c4dfad8fa749aa758ccef7a8bb1b0 CraftArmy/Dashboard.lua
1782634349a26261d414021c0ee96c0589314bf5c1b2de4c11af6f6ebf87ca2b CraftArmy/SelfTests.lua
```

Verifier `ses_e137e2f0fffeC39GSeQEJx0xhD` COMPLETE/no actionable findings. Read full
Dashboard, active contract/requirements/run state/report/latestQ05 and all marked test
additions/adaptations with relevant surrounding guards. Uniform Moxie value cue,
duplicate suppression/owned latest-target drag queue, timer/scroll shared paint, wheel
cancellation/feedback ownership and opaque full-alpha thumb match contract. Inspected
tests preserve meaningful row/identity/reachability/acquisition/retention/failure guards.

Non-Git scope: two Lua files plus U14 execution fields; primary documentation separate,
staged/unstaged N/A. Read/grep only: no independent command/execution/hash/inventory/
preimage/reversal/freeze/native evidence. Supplied targets uncomputed by verifier. Writer
reports512/all19U07/744K6/565K7/23/Python,13adaptation+13addition test preimage/wholeDashboard
reversal/40freeze PASS; not independent proof. Primary exact-target gates remain next.

Native brightness/drag smoothness/endpoints require focused user observation. Platform
N/A addonUI; no release approval. FullnativeINCOMPLETE87/149/allrankUNVERIFIED/quantified
estimate accuracy unverified remain. Changes after review invalidate affected gates.

## Primary validation / local acceptance — PASS2026-11-18

After persisting scoped-static review, PRIMARY fresh full dashboard captured/asserted
exact512completedPASS/512passed0failed/exit0/noFAIL/terminalINCOMPLETE, all19U07 annotations
5/10/2/2,744K6/565K7. Fresh diagnostics23/23/both Python structural checks PASS; diagnostic
hash baseline intact. Independent execution remains unavailable, not substituted by PRIMARY.

PRIMARY exact two reviewed hashes above match. Restore13 originals/remove13 additions =>
entire897611-byte pre-U14 SelfTests9c3b9167… exact, including all historical comments.
Reverse scoped Moxie color/local queue/lifecycle clears/scroll callback+dispatch/OnUpdate/
thumb asset+color => entire71356-byte Dashboardce3f84fb… exact.40 frozen scoped input path/
content fingerprintb45e6fc1… unchanged: ViewModel6143c027…/collectors/Core/Storage/Data/
Commands/Details/TOCs/diagnostics/runners/tools/config/media preserved. These are primary
scoped proofs, not independent/full-tree/stat/native checks. No source edits after review.

Same PRIMARY direct synthetic100ScrollTo(1) requests now dispatch1Render rather than100.
Full suite's drag burst checks latest-target/one next-frame paint, immediate wheel/no-op
cancellation, owned invalidation/fault/reentry/timer behavior. No native FPS/timing or
pixel alignment proof claimed. Known padded-art candidate removed by opaque full-quad thumb;
actual native endpoint cause/resolution still requires user observation.

Locally accepted. User update whole addon with WoW closed/preserve SavedVariables/restart;
check only uniform historical Moxie brightness, drag feel and visual top/bottom endpoints.
No scan/reset/fullsuite or repeat accepted U13 current-first/dot/Concentration/filter/sort/
row-count checks. [Checklist status](completion-checklist.md). Platform N/A; no Git/install/
publication. FullnativeINCOMPLETE87/149/allrankUNVERIFIED/accuracy limitations unchanged.

## Focused native acceptance — user-confirmed2026-11-18

User: “Moxie colour looks good, the scrollbars go to the full bounds now, and performance
is good.” Accept Moxie brightness, visible thumb endpoint reach and normal-use scrollbar
performance. U14 correction complete at that scope; no further update/retest/scan requested.
Older pending labels above record delivery chronology, not an active retest gate. No
measured latency/FPS, exact native causal proof, unreported checklist procedures or full
dashboard sign-off inferred. Documentation-only evidence update/no addon edits/new Lua run.
Remaining C4/window, C5/hover and C6/Cancel not reported. Broader evidence limits unchanged.
