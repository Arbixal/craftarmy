# Dashboard completion — focused gap checklist

## Dashboard milestone — user signed off2026-11-18

User explicitly states “I am happy to sign off on the dashboard.” Accept current dashboard
scope; no routine repeat of this checklist requested. Historical procedures/results below
do not demand further testing. INCOMPLETE native-suite/all-rank/estimate-accuracy limits
and unreported procedures remain documented, not silently upgraded. User requests GitHub
Arbixal/craftarmy setup before guide work; user subsequently approves PUBLIC visibility
and initial main commit/push. [Repository](https://github.com/Arbixal/craftarmy) created;
Git history/remote state record snapshot delivery. Guide work has not started.

**Revised2026-11-18: focused results received, including C4/C6 and C5 appearance/Shift;
ready for explicit overall dashboard sign-off decision.**
Checklist only, not implementation/release or guide authorization. Uses locally accepted U15 and existing
snapshots. [Current status](../../TASKS.md),
[requirements](../../PLAN.md#d07--attention-first-dashboard-three-slot-gear-and-knowledge-bars-).

**U13 delivered2026-11-18:** C2/C3 revised for current-character groups/scrollbar; C7 adds
new display checks. U13 has independent scoped-static/PRIMARY full local PASS, not native
acceptance. Prior focused acceptance stands. U13's separate approval authorized the changes.

**Latest user feedback2026-11-18:** current-first/dot, Moxie center/no!/green>600,
observed-versus-estimated distinction, sorting/filtering and row count accepted at reported
scope (C1/C2/C7 behavior); do not repeat those accepted checks. After U14, user confirms
“Moxie colour looks good, the scrollbars go to the full bounds now, and performance is
good.” Brightness/endpoint reach/normal-use drag performance now accepted; C3 correction
closed at reported scope, no repeat C1/C2/C3/C7 checks or row count requested. Exact
procedures for unreported edge cases are not inferred. Latest user confirms **C4 and C6
all function as expected**; no repeat window/Cancel checks. U15 native-only gear/concise
normal tooltips locally accepted. User now reports **“Tooltips look a lot cleaner now and
Shift reveals the diagnostic tooltip as before.”** C5 presentation/diagnostic availability
accepted at reported scope; no repeat. Dismissal/scroll procedures and every item/field
edge not separately reported or inferred. No known new issue; explicit overall sign-off
with documented limits is next, not another blanket retest. Estimate accuracy stays unverified.

## Already accepted — do not repeat

- Storage refresh on formerly blocked characters and retention of older snapshots.
- Table visibility during scans and profession-window open/close.
- Skill bar, removal of its marker and Skill-only attention filtering.
- Concentration observed bar/no marker/approximate tooltip and U13's visual distinction
  between observed and estimated portions (not quantified prediction accuracy).
- Current-character priority/dot, sorting/filtering, row count and U14 Moxie color/
  full scrollbar bounds/normal-use drag performance at the user's reported scope.
- Knowledge values/branch presentation at the reported scope; existing Inscription Details
  correctness, refresh responsiveness and cached/reload retention at their reported scope.
- Title icon, quality/E badges, red older-gear borders, R/M Tool letters,24px icons/28px
  rows and internal/outer Gear spacing.
- C4 window behavior and C6 selection/Cancel-only confirmations at requested scope.
  No actual retirement/deletion acceptance inferred.
- C5 normal-tooltip cleanliness and Shift diagnostic availability, as reported. No repeat.

These are focused acceptances, not claims about every client/API edge case. Existing
local evidence remains512/512 cases, all19 U07 workloads,744K6/565K7,23/23 diagnostics and
structural checks; none is a new test result from preparing this checklist.

## Checklist reference — not a new retest request

The procedures below record the intended checks. Accepted reported behavior above needs
no repeat, reinstall, update or scan. For a newly reported issue, use existing saved rows.
No new profession scans, gear changes, further reinstalls, whole-account verification or
`/ca selftest`/`/cad selftest` required. Stop
and report an error rather than trying to repair saved data. Checks already performed
can be reported as such; no repeat solely to follow the sequence.

| ID | Check | Expected result / boundary |
| --- | --- | --- |
| C1 | **Filters and menus:** enter part of a saved character name; choose one Profession, then All. Try an unmatched character name and clear it. Switch Active/Archived and back; choose an available Attention option and return to All. | Menus open/select correctly; labels and visible rows agree; no-match and empty Archived views are understandable and recover when cleared. Only existing snapshots are viewed. No need to create an archive or repeat accepted Skill-below-max semantics. |
| C2 | **Grouped sorting:** click Name twice and one numeric header, such as Skill or Concentration, twice. Apply a Profession/Attention filter that excludes a current-character row if existing data permits. | Current character's eligible professions stay first; selected sort reverses within current/other groups. Filters still exclude nonmatching current rows; unknowns last within each group. Concentration sorting uses observed, not `~estimated`, amounts. Gear remains non-sortable. No need to create extra data. |
| C3 | **Navigation:** with more than12 matching saved rows, drag scrollbar top/middle/bottom and use the wheel; then apply/clear a restrictive filter. | Thumb/range text track visible rows; all rows reachable, wheel/drag agree, shrink leaves no stuck page. Scrollbar hides when all rows fit; Previous/Next gone. Current rows are top-of-list, not frozen while scrolling. Each row/name/hover agrees. No fixed46-character cap or full-roster recount. |
| C4 | **Window behavior:** close/reopen with `/ca`, drag using the window, and inspect at the UI scale/resolution you normally use. If convenient, open existing Inscription Details without Refresh details. | Main controls, footer and close button remain reachable; drag and close work. Details can appear above the dashboard. No resolution-change matrix, Details recapture or persistence-of-window-position promise. |
| C5 | **Reported-scope accepted:** cleaner normal tooltips and Shift diagnostics as before. Reference procedure was normal/Shift hover and update/dismissal after scroll/filter. | Normal presentation/Shift availability confirmed. Exact dismissal/scroll procedure, all item/field/invalid-data edges not separately reported; do not infer blanket proof or request a routine repeat. No new issue reported. |
| C6 | **Selection and Cancel only:** select an existing row; open the Retire selected, Delete generation and Delete character prompts one at a time, reading the scope and choosing Cancel each time. | Row selection and prompts identify the intended character/profession/generation; character deletion explicitly warns about all professions/archived generations. Cancel leaves the row/data unchanged. **Never choose Confirm** for this checklist; actual retirement/deletion is not requested. |
| C7 | **U13/U14 display — reported-scope accepted; reference only.** | Moxie brightness accepted along with alignment/no marker, current-first/dot and observed/estimated visual distinction. No repeat. Not every invalid-data/full-bar edge or long-name procedure is user-confirmed; no extra scan/spending/waiting requested. |

**Applies across C1–C7:** no Lua errors, normal-use freezes, unintended snapshot loss or
stuck controls. Report observed symptoms, not stopwatch measurements. This does not
repeat the already accepted scan-redraw check or establish measured latency guarantees.

Record each ID as **Confirmed**, **Issue** (short description), or **Not checked** (reason).
An empty Archived view can satisfy that part of C1; no suitable saved rows for another
check means Not checked, not an invented pass. No screenshots/log dumps needed for clean
results. For an issue, include the ID, action, expected/actual result and any visible error.

## Remaining semantics and evidence limits — separate from the checks

| Item | Current disposition / focused next evidence if needed |
| --- | --- |
| Tool stat versus enchant | Intrinsic-only query is implemented/source-reviewed and fixture-tested; native R/M visibility is accepted. A Tool with a **different enchant stat** has not been explicitly reported. If one already exists, compare its native Tool stat and enchant against the letter; report the two categories. No buying, enchanting, swapping or scan requested just to create the case. Without it, attribution coverage stays partial, not a regression or a blanket API PASS. |
| Unknown/unready item metadata | Preservation/unknown/reset behavior has local coverage. Observe naturally occurring cases if they arise; do not force uncached items, clear caches or manufacture failures. Never reinterpret unknown as confirmed empty/unenchanted. |
| Automatic unlearning / roster absence | Not supported as authoritative absence detection. Retain snapshots; manual retirement is the supported route. Do not unlearn a profession for testing. Further automatic behavior needs separate design/API verification. |
| Offline Concentration estimate accuracy | Approximate tooltip appearance accepted; quantified phase/rounding/offline accuracy unverified. Optional later natural before/after comparison, not a new bar/sort/filter or sign-off test. |
| Broad native proof | Full native suite remains **INCOMPLETE87/149** and all-rank costs **UNVERIFIED**. Independent executable/comparison and measured timing evidence remain unavailable. Do not relabel them PASS or make finishing the timed full suite a blanket prerequisite. |

## Proposed completion boundary

After C1–C7 results, the primary records confirmed checks and any actual defects. A
data-loss/wrong-character/incorrect-value defect or unusable core control needs a scoped
fix; no such new defect is established by this document. Unavailable checks/semantic
coverage remain explicitly Not checked/partial until evidenced or the user accepts the
specific limitation. Preparing the checklist does **not** approve those dispositions or
declare dashboard completion.

Dashboard sign-off is a separate explicit user decision, with remaining limitations
listed rather than silently closed. Then prepare the first Inscription-guide task;
implementation requires its own settled contract and approval. Details redesign,
all-profession Details, recipe catalogue/learned mapping, guide/material/inventory/
Auctionator work, weekly tracking and general optimization remain outside this checklist.

No destructive lifecycle tests, resets, blanket rescans, repeated accepted checks,
forced native stress runs, raised safety limits, Git/publication or agent installation.
