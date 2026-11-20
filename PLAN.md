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

**2026-11-18 DASHBOARD COVERAGE PRIORITY:** user says a full dashboard view is important.
Add **Herbalism, Mining, Skinning, Cooking and Fishing** dashboard tracking before guide
work. Existing eight-profession dashboard sign-off remains valid; Inscription remains the
first complete guide. This supersedes D05's original exclusion for dashboard coverage,
not a commitment to five new guides or older-expansion/Archaeology support. Verify field
applicability and own-character acquisition under Q03; unknown is not zero or N/A.
Preserve all existing snapshots and accepted controls/layout. No new Git publication
approval is implied. Feasibility/planning active; no expansion implementation writer yet.

**2026-11-18 Fishing equipment clarification:** user screenshot/report confirms one
profession slot for the rod; a fishing hat equips in the regular Head slot. Treat
Fishing as rod-only in dashboard profession gear, with both accessory cells genuinely
nonapplicable (no missing-gear attention). API-returned29/30 do not establish usable
accessories. Do not add regular Head-slot tracking or alter accepted crafting gear.
See [capability evidence](docs/dashboard/profession-expansion.md); implementation pending.

**2026-11-19 expansion display decision:** user approves `—` for genuinely nonapplicable
cells, with no attention warning or membership in that field's attention filter. Missing/
unverified data remains unknown, not N/A; failed reads preserve known observations. This
does not remove Cooking/Fishing from the Skill-below-cap filter. User has multiple Skinning
characters available for focused gathering evidence; do not request profession changes.
Next implementation proposal separates the thirteen-profession foundation/read-only
gathering capture from later evidence-gated Moxie/Knowledge/stat activation. No writer yet.

**2026-11-19 P01 execution approved:** user says “Yes, proceed” to implementing the scoped
foundation/consolidated read-only capture and local tests. Execute the P01 contract with
one synchronous implementer, then independent review and primary acceptance. No guide,
future mapping/accounting/stat activation, native acceptance, install, commit/push or
release authorization is inferred. Preserve all pre-existing planning/archive work.

**2026-11-19 P01 local delivery:** thirteen-family capability foundation and consolidated
read-only gathering evidence profile implemented. Writer reports final16additive groups/
219173assertions,512legacy/all19/744K6/565K7/23/Python/whitespace PASS; exact preservation
proofs in TASKS. Frozen for independent review; no primary/native acceptance yet. Gathering
Moxie/Knowledge/stat activation and secondary Moxie applicability remain evidence-gated.

**2026-11-19 P01 locally accepted:** independent full-scope STATIC review PASS/no confirmed
finding; independent shell/tests/hash computation denied and NOT RUN, not reattributed.
PRIMARY serial local suites/comparisons and post-review11target freeze PASS. Accept only
the foundation/read-only evidence milestone, not new native/all-field acceptance. Next is
user-run new-profession normal use and one gathering report per Herbalism/Mining/Skinning;
no repeats of accepted old checks, resets/learning/gear changes or new Git approval.
Review/provenance → [P01 review](docs/dashboard/expansion-p01-review.md).

**2026-11-19 P01 gathering evidence received:** user supplies complete/stable/untruncated
Mining, Herbalism and Skinning reports on12.1.5/build70961, Interface120105. Both completeness
flags true;36total paths, per-profession shared-spend reconciliation matches. Moxie IDs/
names/balances and Finesse/Perception intrinsic-key evidence recorded; Deftness still
unverified. Skinning's observed105cap/modifier40 stay separate, not hardcoded to100.
User subsequently confirms all reported numbers match native UI; focused value agreement
resolved, not broad/error-free/latency acceptance or activation authority. No more dumps.
[Evidence and remaining gates](docs/dashboard/gathering-native-evidence.md).

**2026-11-19 refresh concern:** user reports estimated Concentration disappears then
returns during apparently periodic refreshes; cadence/trigger unknown. PRIMARY local
widget probe reproduces retained-build estimate demotion/restoration;30second estimate
repaint alone keeps it visible at callback return. Guard predates P01. Read-only
[investigation](docs/dashboard/concentration-refresh-investigation.md); no source fix or
writer authorized. Any safe-refresh exception to retained observed-only needs its own
contract; gathering activation remains separate.

**2026-11-19 priority confirmed:** user directs finishing Herbalism, Mining, Skinning,
Cooking and Fishing dashboard work first, then following up with the Concentration
flicker fix. Defer further flicker work until profession coverage is complete; retain
the investigation for that follow-up. Next is the evidence-gated profession activation
scope, not a flicker writer or guide work. Separate implementation contracts still apply.

**2026-11-19 P02 preparation approved:** user says “Then lets proceed” to preparing the
next scoped activation task for approval. [P02 proposal](docs/dashboard/expansion-p02-contract.md)
activates the three verified gathering Moxie/Knowledge mappings and F/P Tool keys, using
existing guarded accounting/storage/display. Preserve five-profession skill/cap/slot
safety independently of Moxie mode. No Deftness/secondary Moxie/enchant-warning guesses;
no flicker or guide work. Implementation approval remains pending; no writer/source edits.

**2026-11-19 P02 implementation approved:** user answers “Yes” to P02 implementation
and local tests. Execute the complete [P02 contract](docs/dashboard/expansion-p02-contract.md)
with one synchronous implementer, then independent review/primary acceptance. Preserve
actual accepted uncommitted P01 baseline and unrelated work using repo-local comparison
artifacts. No flicker, unverified capability activation, install or Git/release authority.

**2026-11-19 P02 locally accepted:** three gathering Moxie/Knowledge mappings and F/P
Tool stats activated, preserving exact-five skill/cap/slot safeguards. Independent full-diff
STATIC PASS/no findings; independent executable verification INCOMPLETE after shell denial.
PRIMARY serial new12/13223,P01=16/220754,legacy512/all19/K6K7,diagnostics23/Python and
exact preservation/post-review freeze PASS. [Review/attribution](docs/dashboard/expansion-p02-review.md).
No native five-profession sign-off inferred; next is new active dashboard normal use,
not repeated reports/old checks. Deftness, secondary Moxie and new enchant-warning evidence
remain open. No writer, installation, Git mutation or flicker/guide work.

**2026-11-19 P02 native feedback:** user confirms Herbalism/Mining/Skinning values match
on the dashboard; focused numeric acceptance, not unreported full normal-use/timing proof.
Knowledge bars are grey: Data lacks gathering tab palette entries and uses neutral fallback
(P02 explicitly retained it). User confirms Cooking/Fishing have **no Moxie**; their Moxie
cells should follow accepted `—`/no field-attention policy, not remain pending forever.
User's older-expansion Skinning Tool screenshot shows native raw
`ITEM_MOD_DEFTNESS_SHORT:110` matching +110Deftness and explicit no enchant/ID0; key evidence
received without needing a newer tool. Separate neutral-query result/build not shown.
Proposed next scoped update: secondary Moxie N/A, verified gathering tab colours, Deftness
key/category recognition with existing guards. No implementation authorized yet; permanent
tool-enchant eligibility remains unresolved and independent. [Evidence](docs/dashboard/gathering-native-evidence.md).

**2026-11-19 permanent-enchant applicability:** user definitely confirms Herbalism,
Mining and Skinning support permanent Tool enchants. Gathering warning eligibility is
resolved for the next scoped task; existing observed-absence/freshness/instance safeguards
remain required. User only believes Cooking/Fishing support them and currently has no
enchanted Tools for those professions; keep their warning eligibility pending, not N/A
or enabled. User's offer to enchant them is not authorization to spend/apply/change gear.
No such action is needed to proceed with independently verified gathering work. Proposed
follow-up now covers secondary Moxie N/A, gathering colours, D recognition and gathering
missing-enchant warnings. No new implementation approval/writer; flicker remains deferred.

**2026-11-19 P03 approved:** user explicitly answers “Yes” to the four-part follow-up:
secondary Moxie N/A, gathering Knowledge colours, guarded Deftness recognition and gathering
missing-enchant warnings. [P03 contract](docs/dashboard/expansion-p03-contract.md) settles
scope/tests/ownership; one synchronous implementer, independent review then primary
acceptance. Cooking/Fishing warnings stay pending; no purchases/gear changes, flicker,
guides, installation or Git/release authority. Preserve accepted uncommitted P02 baseline.

**2026-11-19 P03 locally accepted:** all four refinements implemented. Secondary Moxie
N/A, stable9gathering tab colours, guarded D key/category and gathering observed-absence
warnings; secondary warnings remain pending. Independent full STATIC PASS/no findings;
independent executable verification INCOMPLETE after shell denial. PRIMARY serial
P03=15/31244,P02=12/13223,P01=16/220990,512/all19/K6K7/23/Python/whitespace and exact
reversals/protected/post-review freeze PASS. [Review](docs/dashboard/expansion-p03-review.md).
No new native acceptance inferred: next ordinary four-feature check, no repeat gathering
number interview, dumps, gear changes or purchases. No writer/install/Git/flicker/guides.

**2026-11-19 P03 focused native acceptance:** user confirms secondary Moxie dash,
gathering Knowledge colours, Deftness D and gathering-only missing-enchant behavior. All
four refinements accepted; no repeat checks. This does not establish Cooking/Fishing
permanent-enchant ineligibility (still provisional), global timing/error-free use or a
new overall dashboard sign-off. Profession-first follow-up can now return to flicker.
User adds current-player dot also disappears during refresh. PRIMARY read-only widget
probe reproduces BOTH dot and estimate hidden while replacement builds, restored at
publication;30second repaint alone keeps both visible at callback return. Saved graph/
token unchanged. Combined refresh-fix scope next, not separate profession work; no source
fix/writer authorized yet. [Combined investigation](docs/dashboard/concentration-refresh-investigation.md).

**2026-11-19 R02 approved:** user answers “Yes” to the combined refresh fix. The
[R02 contract](docs/dashboard/refresh-r02-contract.md) specifies a private last-good visible
paint cache and guarded, frozen pending-build continuity. Same active-generation current
identity dot may persist; estimate additionally needs unchanged successful Concentration
observation provenance. Invalid/detached/removed/retired/superseded/failed or changed-GUID/
options paths retain safe cleanup. No prediction-driven saves/sort/attention, new scans or
timer frequency changes. One synchronous implementer, independent review then acceptance;
no install/Git/guide authority. This narrowly supersedes unconditional retained suppression.

**2026-11-19 R02 locally accepted:** guarded frozen estimate/dot continuity implemented;
review findings for backward clocks, preparation ownership and exception cleanup resolved.
Independent full-scope STATIC PASS/no remaining findings; independent executable/comparison
verification INCOMPLETE/NOT RUN after denial, no bypass or reattribution. PRIMARY serial
58groups/902323 plus P01–P03/512/all19/K6K7/23/Python/whitespace and exact frozen-target/
preservation proofs PASS. [Review and attribution](docs/dashboard/refresh-r02-review.md),
full acceptance/hashes in TASKS. Focused native continuity check next during ordinary refreshes,
not repeat profession checks or a full native suite. Actual trigger/frequency/latency remain
unknown; no native acceptance, estimate-accuracy proof, installation, Git or guide authority.

**2026-11-19 R02 native follow-up / V01:** user reports both indicators still disappear
during refresh; R02 native continuity is NOT accepted. Running-client code identity is
unknown, not presumed old or current. User requests an identifiable tested version. V01
adds loaded-dashboard identifier `0.2.0-mvp+r02.1` to the existing status tooltip on Shift,
leaving header/normal tooltips/layout unchanged. Identifier is embedded in Dashboard.lua,
not inferred from unchanged TOC `0.2.0-mvp` or initial Git HEAD. It labels this source delivery,
not proof every installed file matches or a fix for the continuing native symptom. No
install/copy/Git authority; establish loaded build before further flicker changes.

**2026-11-20 V01 locally accepted:** loaded Dashboard build `0.2.0-mvp+r02.1` appears in
existing Shift status tooltip. Normal header/layout/TOC and all R02 continuity bytes
unchanged. Independent full STATIC PASS/no findings; independent execution unavailable,
NOT RUN after denial. PRIMARY all9serial commands61/1333822 plus P01–P03/512/all19/K6K7/
23/Python/whitespace PASS; hashes/proofs in TASKS. No WoW copy/install performed or assumed;
running-client identity and continuing native flicker remain unresolved. Ask for marker only.

**2026-11-20 V01 marker confirmed / R02 native failure persists:** user confirms expected
Dashboard build and reports both indicators still disappear during refresh. Loaded Dashboard
marker accepted; do not ask for it again or assume an outdated Dashboard. This does not hash
the entire installation. R02 native continuity remains NOT accepted; local historical passes
remain valid but insufficient for real collection transitions.

PRIMARY read-only production-callback probe reproduces three sequences: (A) event during
pending build, dashboard frame before queued Scan clears BOTH; successful replacement
restores both; (B) queued Scan first keeps dot but clears estimate; (C) successful Scan from
completed view with unchanged amount/new timestamp keeps dot but clears estimate. No source/
test changes; actual Commands/Collectors/Dashboard methods, synthetic APIs/order only.
[Evidence/proposed follow-up](docs/dashboard/concentration-refresh-investigation.md).
Propose separately scoped R03 collection-handoff continuity: independently revalidate dot
identity across ordinary collection churn and atomically replace verified Concentration
display rather than blank old projection while full view builds. New observation safety,
unknown/failure cleanup, no prediction saves/sort/attention and reentry ownership remain.
No new runtime task/implementation authorized yet; user approval and complete contract next.

**2026-11-20 R03 approved:** user answers “Yes” to focused collection-handoff correction.
[R03 contract](docs/dashboard/refresh-r03-contract.md) specifies explicit private collector
handoff signal, bounded guarded dashboard revalidation and coherent replacement Concentration
from a renewed successful observation. No generic drift bypass or obsolete cyan over new
observed data; zero-gain renewal may correctly become blue-only. Build advances to
`0.2.0-mvp+r03.1`. One synchronous writer then independent review/primary acceptance;
no install/Git/guide authority. Prior native R02 remains unaccepted; no new native claim.

**2026-11-20 R03 locally accepted:** explicit collector handoff and guarded coherent
Concentration replacement implemented, loaded build `0.2.0-mvp+r03.1`. Independent full
STATIC PASS/no findings; independent execution/comparison NOT RUN after denial, no bypass/
reattribution. PRIMARY31/860393 newgroups,61/1333822 refresh, P01–P03/512/all19/K6K7/23/
bothPython/whitespace plus exact reviewed target/preservation proofs PASS. [Review](docs/dashboard/refresh-r03-review.md),
hashes/evidence in TASKS. Focused ordinary-refresh native outcome pending; zero-gain renewal
correctly becomes observed-only rather than keeping obsolete cyan. No installer/copy/Git/
guide/native success authority; previous R02 native failure remains documented.

**2026-11-20 R03 native follow-up FAILED:** user confirms expected r03.1 Dashboard build
and reports both current-player dot and Concentration estimate disappear until refresh
completion. Do not repeat version verification, explain this away as legitimate cyan-to-
blue conversion, or claim native resolution from local passes. Local review/test evidence
remains historical local evidence; actual native fallback/trigger still unidentified.
Primary inspected remaining cache/validation/retention/publication paths read-only; no new
runtime edits or diagnosis established. Next one focused existing Shift/status tooltip
capture while indicators are missing, before further speculative changes. No forced scan,
profession retest, reset, install/copy/Git or new fix/instrumentation authority inferred.

**2026-11-20 screenshot / R04 concrete API mismatch:** screenshot shows normal retained
incremental build, raw status “Open your own profession to refresh”, r03.1, Active/All and
45rows. No visible build-failure status. PRIMARY reproduced the same hide-until-completion
and pending/raw status by changing ONLY private fixture FontString empty GetText return
from empty string to nil, with icon-only gear rendering a deliberately blank label.
Current API documents optional nil text; historical widget reference explicitly documents
nil for empty string. demoteVisible treats successful nil as error and discards continuity/
cache. Existing mocks always return empty string, masking this contract mismatch.
Full saved-root/token/project-source preservation PASS. This is a deterministic local
native-contract reproduction, not tracing the exact native call in the user's client.
[Evidence and proposal](docs/dashboard/concentration-refresh-investigation.md).
Propose narrow R04 normalization of successful nil label reads to blank, retain thrown/
other non-string failure behavior, native-compatible mock/regressions and advanced build
marker. No further screenshot/version check needed; implementation approval pending.

**2026-11-20 R04 approved:** user answers “Yes” to narrow empty-FontString correction and
native-compatible regressions. TASKS R04 contract: successful nil read normalized to blank
after ownership check, genuine errors/non-string types remain fail-closed; native mock
corrected, build `0.2.0-mvp+r04.1`. No collection/model/continuity-policy redesign. One
synchronous writer, review/primary acceptance; native result remains pending, no install/Git.

**2026-11-20 R04 locally accepted:** narrow successful-nil normalization after ownership
check, native-compatible mock and nine regression groups, build `0.2.0-mvp+r04.1`.
Independent full STATIC PASS/no findings; executable/comparison verification NOT RUN after
denial, no bypass/reattribution. PRIMARY all11serial commands: new9/1338363, collection31/
860393, refresh61/1333822 plus P01–P03/512/all19/K6K7/23/Python/whitespace and exact frozen
source/protection proofs PASS; review and hashes in TASKS R04. No collection/model policy
change or native resolution inferred. Next only ordinary-refresh behavior feedback, not
more screenshots/marker interviews. No installer/copy/Git/guide authority.

**2026-11-20 R04 focused native acceptance:** user says “That has fixed it, good job”
after testing the correction. Accept the reported Concentration-estimate/current-player-dot
refresh continuity fix in WoW. No repeat refresh check, screenshot or marker interview.
This does not infer measured latency, exact event cadence, offline estimate accuracy,
broader new-profession acceptance or completed native full suite. No further source work,
installation, Git/release or guide authority; local historical evidence/limits preserved.

**2026-11-20 secondary Tool evidence update:** user finds an existing Cooking Tool with
a **Multicraft permanent enchant**, confirming Cooking enchant applicability. Cooking's
missing-enchant warning gate is now evidence-resolved for a scoped follow-up; current
disabled/pending implementation is not ineligibility. User reports Cooking Tools have a
fixed multi-stat mix rather than a selectable single intrinsic stat, with amounts varying
by rarity/quality. Exact base stat names/numbers and enchant ID/rank not supplied; do not
derive a base Multicraft category from the enchant. User reports crafted Fishing Tools
intrinsically provide **Perception**, amount varying with rarity/quality; this does not
establish all historical/dropped rods or fixed amounts. Fishing enchants remain unverified:
user has not tried one. No further purchases/applications/gear changes/dumps needed.
[Recorded evidence](docs/dashboard/gathering-native-evidence.md). No new source task or
implementation authorization from this report; propose Cooking-only warning eligibility,
with safe observed/enchant-neutral stat handling preserved and no guessed single Cooking
letter or Fishing enchant rule. R04 focused native acceptance remains complete.

**2026-11-20 P04 approved:** user answers Yes to enabling **Cooking-only Missing enchant**
warning, leaving Fishing unchanged. TASKS P04 contract changes only exact Cooking policy
eligibility, reusing existing confirmed-absence/unknown/last-observed/fresh/archive/filter
semantics. No intrinsic stat UI/letter change, guessed base stat or new enchant ID. Build
marker advances to `0.2.0-mvp+p04.1`; R04 fix bytes otherwise unchanged. One synchronous
writer/review/primary acceptance; no buys/gear changes/dumps/install/Git/guide authority.

**2026-11-20 P04 locally accepted:** Cooking Missing enchant warning/filter enabled;
Fishing remains pending. One exact Data policy change and Dashboard build literal
`0.2.0-mvp+p04.1`, all stat presentation and R04 continuity logic unchanged. Independent
full STATIC PASS/no findings; independent execution/comparison NOT RUN after denial, no
reattribution. PRIMARY all12serial commands Cooking12/81992 plus R04/R03/61/P01–P03/512/
all19/K6K7/23/Python/whitespace and exact protected/frozen-target proofs PASS; review/hashes
in TASKS P04. P04 native behavior pending normal use, no purchases/applications/gear changes,
repeat accepted checks or new dumps needed. R04 focused native acceptance remains complete.

**2026-11-20 P04 focused native acceptance:** user says “Confirmed” to Cooking's missing-
enchant warning/filter. Accept that scope; Fishing remains pending/unverified, not ineligible.
No repeat Cooking/refresh checks, purchases, applications, gear changes or reports needed.

**2026-11-20 scrolling-performance requirement (U16 investigation):** user reports CraftArmy
scrolling pauses patrolling NPCs/world animations, unlike the comparable WeeklyKnowledge
list, and asks render to display known data rather than process/calculate it. Prepare
expensive data incrementally outside painting; merely moving the same stall into a
synchronous pre-render helper is not a solution. Preserve accepted data/filter/sort/tooltip/
dot/Concentration and Cooking/Fishing behavior. PRIMARY read-only48/96-row profile confirms
per-paint storage expansion plus extensive duplicate safety/native dispatch; timings are
synthetic host CPU, not WoW latency or sole native cause. [Evidence and proposed separation](docs/dashboard/scroll-performance-investigation.md).
Runtime unchanged; complete scoped design/contract before one writer/review/acceptance.
No install/copy/Git/release/guide authority or repeated native diagnostics/accepted checks.

**2026-11-20 U16 approval with Git prerequisite:** user approves the proposed scrolling
refactor **but requires existing work committed and pushed to origin first**. Scoped Git
authorization: checkpoint existing reviewed addon/tests/docs and current investigation/
planning on local `main`, then normal fast-forward push to `origin/main` at public
`Arbixal/craftarmy`. Exclude ignored artifacts/captures/runtime files/secrets. No force push,
tag, release, installation or future refactor commit/push authorization inferred. U16 source
work waits for verified matching local/remote checkpoint; then finish the implementation
contract before one synchronous writer/review/acceptance. Historical no-Git labels are
superseded only for this explicit checkpoint operation.

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

- Dashboard targets Midnight's eight primary crafting professions: **Alchemy,
  Blacksmithing, Enchanting, Engineering, Inscription, Jewelcrafting, Leatherworking,
  Tailoring**, plus **Herbalism, Mining, Skinning, Cooking and Fishing** per the user's
  2026-11-18 full-overview priority. The eight crafting professions are implemented and
  signed off; the five additions need capability/API validation and implementation.
  Older expansions and Archaeology are not included. Verify client/build APIs under Q03.
- Build personal-first, structured for later publication. Defer distribution-platform
  integration and broad localization, not correctness or data safety.
- Validate APIs, **extend dashboard coverage to all thirteen named professions, then one
  complete Inscription guide** before
  expanding guide coverage. Guide work remains committed, not cancelled.
- Eight verified crafting identities/Moxie mappings are implemented. K08 focused native
  capture/value/normal-use evidence and K09 numeric Knowledge implementation/review/
  focused dashboard validation are complete at their reported scope. Do not repeat
  Knowledge captures, identifier discovery or routine full selftests.
- Supplied enchant categories retain provenance; inclusion is not blanket native proof
  of every ID/rank/amount. Blank means confirmed absence; `?` unknown/unmapped. Never
  infer amounts, API keys or gathering support from names or similar IDs.
- Source: full-dashboard priority2026-11-18 supersedes original dashboard exclusion;
  Round 1 accepted recommendations, 2026-11-05; subsequent confirmed E01–E05,
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
