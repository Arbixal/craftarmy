# TASKS — CraftArmy

> Current implementation handoff and recovery point. Read with [PLAN](PLAN.md).
> Historical contracts are linked below, not active instructions.
> Use `living-plan` for maintenance and `agent-handoff` before delegation.

<a id="current-status--2026-11-18"></a>
## Current status — 2026-11-20

- **Existing eight-profession dashboard SIGNED OFF.** User acceptance includes the
  focused storage/refresh, redraw, Skill/filter, gear, Moxie, Concentration, scrollbar,
  current-character, window/Cancel and normal/Shift tooltip refinements. No routine
  repeat checks, metadata scans, destructive lifecycle checks or full native timing chase.
  [Acceptance and limits](docs/dashboard/completion-checklist.md).
- **Next priority: full dashboard before guides.** Add Herbalism, Mining, Skinning,
  Cooking and Fishing tracking. P01 thirteen-family foundation is now implemented/local-tested;
  P02 gathering numbers and all four P03 refinements now have focused native acceptance.
  Broader unreported checks are not inferred; no repeat profession checks needed.
  Existing snapshots and accepted controls/layout must remain intact.
  **User confirms Nov19: professions first; Concentration flicker fix afterward.**
  **P03 four-feature native acceptance complete.** Next follow-up is combined Concentration/
    current-player-dot refresh fix: R02 native flicker persisted on user-confirmed V01 build.
    R03 native continuity failed; screenshot led to empty-FontString API mismatch.
    R04 build r04.1 now user-confirmed FIXED; focused native dot/estimate continuity accepted.
  [Contract](docs/dashboard/refresh-r02-contract.md).
- **Run state: P01 locally ACCEPTED; independent STATIC PASS + PRIMARY execution/comparison/freeze PASS.**
  Gathering IDs2912/2916/2917 observed; user confirms this character knows Herbalism/Mining.
  Secondary learning/capabilities and Fishing rod-only UI confirmed. [Audit](docs/dashboard/profession-expansion.md).
  Independent execution remains NOT RUN after shell denial; new native acceptance pending.
- **N/A policy confirmed Nov19:** use `—`, no field-specific attention/filter match;
  unknown stays unknown. User has multiple Skinning characters for the focused capture pass.
- **P01 native gathering reports RECEIVED:** all3complete/stable/untruncated on70961,
 36paths; Moxie3264/3260/3265 and Knowledge3784/3778/3889 recorded separately, Finesse/
 Perception keys evidenced. [Native evidence](docs/dashboard/gathering-native-evidence.md).
 User confirms all reported values match native UI. Error-free/responsive capture and
  broader row/N/A acceptance not inferred. No repeated dumps. P02 activation now approved.
- **Latest native feedback Nov19:** gathering dashboard values match; grey Knowledge bars
  reported and traced to unregistered gathering palette IDs. User confirms Cooking/Fishing
  have no Moxie. Screenshot evidences ITEM_MOD_DEFTNESS_SHORT110 on an older Skinning Tool,
  no enchant/ID0; no newer tool/another gathering report needed. Proposed follow-up is
  secondary Moxie N/A, gathering colours and D recognition; P03 now locally accepted.
  User now definitely confirms gathering permanent Tool enchants; gathering warning
  eligibility resolved for next task. Cooking/Fishing support is only tentative; keep
  those warnings pending. No purchases/applications needed or authorized. Proposed batch
  adds gathering missing-enchant warnings to the three fixes above; P03 locally accepted.
  User now confirms all4behaviors: dash/colours/D/gathering-only warnings. Focused native
  P03 acceptance complete, not secondary-enchant ineligibility or broader unreported checks.
- **Combined refresh investigation:** user adds current-player dot flickers too. PRIMARY
  read-only probe reproduces both dot/estimate hidden during retained build and restored on
  publish, for unchanged and invalidated context;30second repaint alone keeps both visible
  at callback return. Actual native trigger/frequency unknown; saved graph/token unchanged.
  Profession-first deferral satisfied; user now explicitly approves combined R02 fix.
  No source change at approval; one synchronous writer next. [Findings](docs/dashboard/concentration-refresh-investigation.md).
- **Latest secondary Tool evidence Nov20:** user found existing Multicraft-enchanted Cooking
  Tool; Cooking permanent-enchant applicability confirmed, Cooking-only warning now locally accepted.
  Cooking fixed multi-stat mix, crafted Fishing Perception amounts vary by rarity/quality.
  Enchant stat must not be mistaken for base stat. Fishing enchant applicability still
  unknown/not tried. No buys/applications/dumps; stat presentation and Fishing remain unchanged.
- **Latest P01 writer validation:**16additive groups/219173assertions,512/512 legacy cases,
  all19 U07 workloads5/10/2/2,744K6,565K7,diagnostics23/23,both Python/whitespace PASS.
  These are writer-attributed local results, not independent or native acceptance. Final
  hashes/preservation proofs and earlier failure chronology are in the P01 report below.
- **Repository bootstrap delivered:** public [Arbixal/craftarmy](https://github.com/Arbixal/craftarmy),
  `main`, initial commit `5f98f5e`. That approval covers the initial snapshot only;
  no future commits, pushes, tags, releases or deployments are authorized by it.
- **Guides are not built.** Inscription remains the first complete guide after the
  dashboard expansion. Details is still Inscription-only; no broader guide scope inferred.

## Active implementation queue

### U16 — Prepared rendering and scrolling performance

**REFACTOR APPROVED2026-11-20; GIT CHECKPOINT FIRST — no executable source queue yet.**
User confirms P04 Cooking warning/filter, then reports scrolling pauses world animation;
requests paint-only rendering of prepared values. Existing R04 native acceptance remains
complete; no accepted refresh/Cooking/profession checks or new dumps needed.

PRIMARY read-only actual Dashboard/Storage fixture48/96records/12widgets: five wheel paints
use60Active/41522Check/120Token/2672Copy/60Estimate;48-row uninstrumented258.066ms total,
instrumented311.811ms /166.991ms insideActive (overlapping timings, NOT native evidence).
48/96 operation counts identical. Drag100events coalesces1paint; unchanged100offsets0paint.
Stable-fixture cached-record control drops instrumented312.898→136.342ms while41522Checks
remain: caching alone insufficient, control not a production safety design.

[Detailed evidence/proposal/open contract mechanics](docs/dashboard/scroll-performance-investigation.md).
Reproduction and terminal logs/hashes under ignored `artifacts/scroll-investigation/`.
All168project-path hashes unchanged after both commands; saved-root/fresh/rows/token proofs
PASS; wrappers restored. No production/test edits or active writer/check job.

Proposed scope: detached prepared display/provenance packets from existing incremental
build; bounded cancellable dynamic prep at existing30-second cadence; no storage expansion/
deep copies/model work/account loops during paint or synchronous prepaint; consolidated
lightweight source/owner guards; fixed geometry/font setup and changed-property updates.
Preserve all source/generation/reentry/failure/continuity safety, unknown/stale/N/A, current
dot, prediction display-only and Cooking-only warnings/Fishing pending. Packet/provenance
ownership and mutable-storage drift certification, numeric work bounds, clock epochs and
exact permitted old-test changes must be settled in a complete contract before READY.

User now approves the scoped refactor but requires existing work committed/pushed to origin
FIRST. Next: complete/verify the checkpoint below, finish mechanics/ownership/serial task/
test contract, primary snapshot, one synchronous implementer then independent review/primary
acceptance. No implementation writer yet or speculative cache/guard removal. No installer/
WoW copy/release/guide scope; no future refactor commit/push authorization. Native timing/
sole cause/outcome remain unmeasured.

#### Existing-work Git checkpoint prerequisite —2026-11-20

**READY, PRIMARY-owned Git-only checkpoint.** Explicit user approval: “Yes, but make sure
existing work is committed and pushed to origin first.” Commit existing intended source,
tests, approved task archives and docs, including U16 investigation/approval but NO U16
runtime implementation. Current base `5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`, localmain;
remote `https://github.com/Arbixal/craftarmy.git`, origin/main currently same SHA by live
ls-remote. Empty index at inspection. No `.github` workflows or active hook files found.

Serial gate: inspect complete candidate inventory/diff and sensitive-file/content scan;
verify accepted eight P04 delivery hashes unchanged and latest primary suites/independent
static-review evidence (independent execution still NOT RUN); structural/whitespace checks;
stage only explicit reviewed paths, verify index tree/manifest; make one normal checkpoint
commit and push `HEAD:refs/heads/main` toorigin withoutforce; verify live remoteSHA==localHEAD
and working/index state. Stop on unexpected paths/remote drift/hooks/secret findings/errors.
Ignored artifacts/captures/backups/WoW runtime data staylocal. No branch reset/amend/rebase/
force, tags/releases/installation, or U16 implementation before remote verification.

No independent review is reattributed and no old native suite result upgraded. Local
preflight/commit/push command results and exact final SHA must be durably recorded after
completion; no automatic extra commit/push to include post-commit delivery bookkeeping.

### P04 — Cooking missing-enchant warning

**LOCALLY ACCEPTED2026-11-20 — independent STATIC PASS + PRIMARY full checks; Fishing unchanged.** User reports:
- Existing Cooking Tool has a Multicraft permanent enchant. This resolves Cooking Tool
  enchant applicability; Cooking's existing Missing enchant warning/filter is now enabled.
  Positive observation/absence/unknown/freshness safeguards remain.
- Cooking Tool has a fixed multi-stat mix, not a selectable single base stat; quantities
  vary with rarity/quality. Exact constituent stat names/amounts not supplied. Do not label
  base Tool M from its Multicraft enchant or hardcode a single Cooking-stat choice.
- Crafted Fishing Tools provide Perception, amount varies by rarity/quality. This is user
  item-family evidence, not exact API key/neutral result/quantity or every historical rod.
  Existing verified enchant-neutral stat reads stay authoritative; no new hardcoded values.
- Fishing Tool enchant not tried, so applicability remains unverified/pending, not N/A.

[Native evidence](docs/dashboard/gathering-native-evidence.md) updated. No repeated accepted
profession/refresh tests, new dumps, purchases/enchant applications/gear changes needed.
User-approved Cooking-only activation is implemented/locally accepted below. Stat presentation
changes still need their own settled scope; no Git/install/guide scope.
R04 focused native acceptance stays complete; no further refresh work inferred. Historical
proposal above is superseded by the executable approved contract below.

#### Goal
Enable existing Missing enchant warning/filter behavior for evidenced Cooking Tool eligibility.

#### Why
User confirms an existing Multicraft-enchanted Cooking Tool, then explicitly says Yes to
Cooking-only warning activation. Fishing enchant applicability unverified; no stat UI work.

#### Run state
LOCALLY ACCEPTED — all5 pieces, independent static review and PRIMARY final validation PASS.
Frozen eight delivery targets below; no active writer/children/background or check job.
Completed: baseline/red/green, exact Cooking policy/build edits, FOUR recoverable old-test
adaptations/TWO refresh literals,12new safety/UI groups, scoped docs and full final proofs.
Blockers: none locally. Independent executable verification remains NOT RUN after denial.
P04 focused native acceptance now complete: user says “Confirmed” Nov20. R04 acceptance
remains complete; no repeat checks, purchases/applications or new dumps. Next priority is
the separately reported scrolling performance issue (U16), not more Cooking evidence.
No writer resume/source edits without scoped correction; no native/installer/Git authority.
Primary freezes accepted uncommitted R04 actual tree (NOT HEAD) in ignored
`artifacts/p04-comparison/`: before-files.json, seven immutable preimages, git-before.json.
New tests/cooking_enchant.lua absent. Artifacts primary-owned/read-only to agents. No active
writer/check job or source edits at approval; no competing primary edits while writer active.

#### Design — serial pieces
1. Verify packet/accepted R04 hashes/HEAD/index; inspect scripts; fresh serial existing
   baseline. Add new tests/cooking_enchant.lua with meaningful rejecting Cooking eligibility/
   observed-absence warning and attention-filter cases using actual Data/Collectors/Storage/
   ViewModel/Dashboard and schema1/schema2, not a fabricated warning implementation.
2. Change ONLY Data.lua policy initializer's `enchantAttentionMode` expression from
   `secondary and "pending" or "enabled"` to `id==2911 and "pending" or "enabled"`.
   Exact-tuple guard remains; Cooking2908 enabled, Fishing2911 pending, all other professions
   unchanged. No new enchant IDs, stat mapping/letter, currency, collection or model logic.
   Dashboard only private loaded build literal advances to `0.2.0-mvp+p04.1`; R04 fix and
   all other runtime bytes frozen. Existing warning/fresh/last-observed/archive semantics
   are reused, not redesigned: unknown without known absence is not missing; a retained
   known absence may remain a historical warning, never reclassified fresh.
3. Adapt ONLY these FOUR exact old-test statements with recoverable P04 ORIGINAL/ADAPT blocks:
   - profession_completion.lua eligibility loop at168: enchant mode `n<=3` → `n<=4`.
   - Same file line174: ONLY enchant mode `n<=3` → `n<=4`; Moxie condition untouched.
   - Same file line355: ONLY local enabled expression `s[3]~=5 and s[3]~=10` → `s[3]~=10`.
     Keep all seven modes/both schemas/fresh/history/absence/archive/filter assertions and
     all following else/freshness checks unchanged; Cooking now exercises enabled branches.
   - profession_expansion.lua active line135: ONLY enchant mode `n<=3` → `n<=4`, Moxie untouched.
   Preserve all older nested original markers byte-exactly. No case renaming/skips/limits/
   workload/other old-test edits. Refresh runner ONLY TWO expected build literals r04.1→p04.1;
   native blank FontString mock and all61cases unchanged. Any additional old failure stops
   for primary review, not broader rewrites.
4. New runner covers confirmed zero/empty enchant ID, positive Multicraft/other/uncatalogued
   enchant (presence suppresses warning regardless category), missing/uncached/unknown or
   conflicting metadata, transient failure/same-instance retention/changed-instance safety,
   reopened last-observed history and archives, Fishing unchanged even observed absence.
   Verify Missing enchant filter membership, fresh versus historical label, native normal
   versus Shift tooltip gates using current native-compatible widgets; no false warnings
   for N/A accessory2 or absent Tool, preserved Cooking slots26/27 and Fishing rod28 only.
   Positive Cooking multi-stat fixture is synthetic, not user-provided native stat list;
   ensure enchant separate from intrinsic neutral stats without changing presentation.
   Freeze saved root/fresh/row/token graph around UI-only work; intentional collector writes
   separate. Retain all thirteen-profession/N/A/Skill safety and R04 accepted runtime behavior.
5. Root README current Cooking/Fishing eligibility/build/dev-command lines; dashboard README
   prefix beforeR04 (old history verbatim). Run all final commands serially to completion,
   reconstruct whole old tests/Dashboard/Data byte-exact by reversing ONLY scoped changes,
   protected/preimage/history/icon/inventory/Git proofs/full actual diff/final hashes; freeze.

- [x] **1. Baseline and rejecting Cooking regressions.**
- [x] **2. Cooking-only policy/build literal** — depends on1.
- [x] **3. FOUR exact old-test adaptations** — depends on2.
- [x] **4. New safety/filter/UI regressions** — depends on2+3.
- [x] **5. Full checks/docs/proofs/freeze** — depends on4.

#### Files
Writer ONLY CraftArmy/Data.lua (ONE expression), CraftArmy/Dashboard.lua (ONE build literal),
new tests/cooking_enchant.lua, tests/profession_completion.lua (THREE exact marked statements),
tests/profession_expansion.lua (ONE exact marked statement), tests/refresh_continuity.lua
(TWO build literals), README current/build/dev, docs/dashboard/README prefix beforeR04,
TASKS P04 execution/status/report. Primary owns PLAN/AGENTS/evidence/review/artifacts.
All other paths frozen, including Core/Storage/Collectors/ViewModel/Knowledge/Commands/
Details/SelfTests/collection/fontstring/gathering runners/tools/TOC/assets and all R04 fix bytes.

#### Tests
Installed runtimes only, inspect scripts first. Baseline all existing commands excluding
new runner before edits; meaningful new red on unchanged production. Final serial commands:

```sh
lua5.1 tests/cooking_enchant.lua
lua5.1 tests/fontstring_continuity.lua
lua5.1 tests/collection_continuity.lua
lua5.1 tests/refresh_continuity.lua
lua5.1 tests/profession_completion.lua
lua5.1 tests/gathering_activation.lua
lua5.1 tests/profession_expansion.lua
lua5.1 tests/dashboard.lua
lua5.1 tests/run.lua
python3 tools/check_dashboard.py
python3 tools/check_diagnostics.py
git diff --check
```

No skipped/reduced tests/limits. Whole P01/P03 reconstruction by reversing ONLY FOUR P04
blocks, older markers intact; exact two-literal refresh and single-literal Dashboard reversal;
single policy-expression Data reversal. Protected paths/preimages/README history/9icon pairs/
inventory/HEAD/index and actual seven-preimage diff + new runner/eight final hashes. Permission
denials stay NOT RUN, no retry/bypass or evidence reattribution. Platform review N/A.

#### Out of scope
No Cooking stat/letter redesign, stat/enchant IDs/amount guesses, Fishing warning activation/
ineligibility claim, purchases/enchant applications/gear changes/repeated dumps or accepted
refresh checks. No schema/math/collection/handoff/sort policy/timer changes. No install/copy/
Git/release/guide work. Full native87/149 INCOMPLETE/all-rank/estimate accuracy limits unchanged.

#### Report back
agent-handoff envelope; durable piece/run statuses at every stop, completed/blocker/remaining/
exact resume, baseline/red/green/failure chronology, commands/results and complete actual
diff/hashes/reconstruction/protected/history/icons/Git proofs. Artifacts read-only, primary
generates review packet/persists independent findings before acceptance. COMPLETE never
grants native/publication acceptance. No child agents or competing writes.

**P04 writer execution —2026-11-20:** read agent-handoff/AGENTS/complete PLAN/all8P04
sections. Read-only packet verification PASS167actualpaths/7immutablepreimages/all5accepted
R04hashes/exactinventory/HEAD/index/emptycached diff/newrunner absent. Artifacts untouched.
Installed Lua5.1/Python3, runners/tools inspected. Fresh baseline before any edits, serial
foreground timeout0 under `set -euo pipefail`: `lua5.1 tests/fontstring_continuity.lua`
9/1338363; `lua5.1 tests/collection_continuity.lua`31/860393;
`lua5.1 tests/refresh_continuity.lua`61/1333822; `lua5.1 tests/profession_completion.lua`
15/31244; `lua5.1 tests/gathering_activation.lua`12/13223;
`lua5.1 tests/profession_expansion.lua`16/221046; `lua5.1 tests/dashboard.lua`
512/all19/K6=744/K7=565; `lua5.1 tests/run.lua`23/23;
`python3 tools/check_dashboard.py`97Markdown/546links/8diagnostic hashes;
`python3 tools/check_diagnostics.py`9required; `git diff --check`: ALL exit0/PASS.
Long Lua stdout filtered with `tail -n 6` after full execution, pipefail retained; no skips.
No baseline failure. Initial `lua5.1 tests/cooking_enchant.lua` exit1,0passed/2failed/
5assertions on unchanged production: eligibility pending!=enabled and actual observed
Cooking absence does not warn. Observed enchant absence preconditions pass; genuine red,
not harness failure. Exact policy/build edits then applied; same command exit0,2groups/
74assertions. FOUR authorized statements now adapted with P04 ORIGINAL/ADAPT blocks,
including preserving older nested originals; only TWO oldrefresh expected literals changed.
Next expand new safety/filter/UI coverage, then final checks/proofs/docs.
Expanded new runner first exit1,9passed/1failed/71622assertions: new fixture's `item:123`
did not identify any valid item instance, causing typed payload rejection before row creation.
Corrected ONLY new missing-enchant-field fixture to `item:123:` (identifiable item but no
complete enchant field). Next same command exit0,10groups/78761assertions. No old failure
or production change. Added successful transition/independent-slot groups; final run next.
Root README current eligibility/R04 acceptance/build/dev lines and dashboard README prefix
updated; all older dashboard README history untouched.
First final serial attempt stopped at new runner, exit1,11passed/1failed/80055assertions;
direct rerun confirms only new independent-empty-Tool fixture incorrectly expected boolean
false rather than the model's nil absence of a positive badge. Corrected ONLY new assertion
to test `enchanted==true`. No existing final commands ran in that aborted attempt. Next
rerun all12 final commands serially, then preservation proof/freeze.

**P04 FINAL writer report — COMPLETE2026-11-20 (local implementation only):**

Only authorized files changed: Data ONE policy expression, Dashboard ONE build literal,
new280line `tests/cooking_enchant.lua`, P03 THREE/P01 ONE recoverable P04 statement blocks,
oldrefresh TWO expected version literals, root README current/build/dev lines, dashboard
README29line prefix and P04 execution/status/report here. No older case/mode/schema/growth/
assertion/limit changes; previous nested markers preserved. Exact tuple guard untouched.
Cooking2908 warning enabled, Fishing2911 pending; every other runtime byte unchanged.
Build `0.2.0-mvp+p04.1`; no stat UI/IDs/amount mapping, collection/model/schema/math/sort/
attention-semantics/handoff/timer/layout/TOC/asset changes. Accepted uncommitted R04 actual
tree is the base, NOT initial HEAD. Pre-existing user changes preserved.

New coverage: exact13capabilities and malformed tuples; both schema facades actual
Collectors/Storage/ViewModel/Dashboard paths; observed zero/empty absence/fresh warning/
filter; positive synthetic Multicraft/other/uncatalogued presence regardless category;
synthetic multi-stat neutral query separate from enchant totals, no guessed Cooking letter.
Unknown existence/loading/missing link/ID/cache API/errors/stats error/conflict/malformed or
incomplete enchant field/missing slots/absent Tool do not fabricate absence. Same-instance
failure retains successful100timestamp/absence as historical or positive metadata; changed/
unidentifiable/removed instance cannot inherit absence/badge. Reopen/archives/relearn/new
successful transitions and independent accessory/Tool presence covered. Fishing unchanged
pending even observed absence, no ineligibility claim, rod28only/noHead/29/30. Cooking26/27,
accessory2N/A, secondary Moxie/Knowledge/Concentration N/A and Skill-below-cap/cap safeguards
preserved. Native-compatible widgets reused without changing old helpers: native+thirdparty
normal item hover versus Shift diagnostics, fresh/history/no false warnings, hidden Cooking
multi-stat letter, positive-only badge, filter/sort/repaint/scroll and saved/fresh/old-row
graph identity/metatables/edges/token preservation, zero acquisition attempts or item/currency
reads during UI work. Intentional collector writes isolated before read-only snapshots.
Synthetic ID/amounts are not the user's enchant rank/ID or native Cooking constituent stats.

**Final terminal serial checks — ALL exit0/PASS**, foreground timeout0, `set -euo pipefail`.
Lua output piped through `tail -n 7` only after full execution, no skips/reductions:

| Exact command | Final result |
| --- | --- |
| `lua5.1 tests/cooking_enchant.lua` |12groups/81992assertions |
| `lua5.1 tests/fontstring_continuity.lua` |9groups/1338363assertions |
| `lua5.1 tests/collection_continuity.lua` |31groups/860393assertions |
| `lua5.1 tests/refresh_continuity.lua` |61groups/1333822assertions |
| `lua5.1 tests/profession_completion.lua` |15groups/31294assertions; Cooking now exercises existing enabled branches (+50) |
| `lua5.1 tests/gathering_activation.lua` |12groups/13223assertions |
| `lua5.1 tests/profession_expansion.lua` |16groups/221046assertions; original184/400/800row workloads retained |
| `lua5.1 tests/dashboard.lua` |512/512; ALL19U07workloads5/10/2/2; K6=744/K7=565 |
| `lua5.1 tests/run.lua` |23/23diagnostic cases |
| `python3 tools/check_dashboard.py` |17required/exactTOC/97Markdown/548links/8diagnostic hashes |
| `python3 tools/check_diagnostics.py` |9required/exactTOC/oneSavedVariables |
| `git diff --check` |PASS |

Above baseline/red/intermediate/new-fixture-failure chronology remains distinct from final
green. No baseline/unexpected old failure or permission denial in this writer execution.
No independent verification/native acceptance inferred; Python structural only.

**Final read-only Python stdlib/Git preservation proof — PASS:** all7immutable preimages
match167path baseline;159protected paths unchanged (exclude7owned+TASKS), including all
Collectors/R03/Core/Storage/ViewModel/Commands/Knowledge/Details/SelfTests/fontstring/
collection/gathering runners/tools/TOC/assets/primary docs. Whole Data reconstructs after
reversing ONLY one expression; whole Dashboard ONLY one literal (all accepted R04/R03 bytes
frozen); whole refresh ONLY two literals (native blank mock/all61cases untouched). Whole
P03 and P01 reconstruct byte-exact after reversing ONLY3+1P04blocks via ORIGINAL content;
older nested originals and all following assertions byte-exact. All old dashboard README
bytes remain exact suffix; root README actual diff inspected current/build/dev only.
9original/packaged icon pairs byte-identical. Inventory exact168=original167+newrunner,
no removals. HEAD `5f98f5e6a5d74d53c7e487d810753f3ff7b9a661` unchanged; NULstageSHA256
`77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299` unchanged; cached
diff empty. Primary-owned comparison artifacts read-only/unmodified.

Full actual seven-preimage diff + entire newrunner computed in memory (not HEAD diff):
**30680bytes**, SHA256 `ef3b34eee5df1985cabc5884e089b2e40ff60aabbf283fdf2da5f26371336a5e`.
Reproduction: sorted preimage-map paths, concatenate Python `difflib.unified_diff` on
`splitlines(True)`, fromfile=`P04-before/<path>`, tofile=`P04-after/<path>`; append newrunner
empty-before `/dev/null` to `P04-after/tests/cooking_enchant.lua`; default3context/newlines,
UTF-8, no separators. Seven-path diff printed/inspected; entire newrunner authored/inspected.
PRIMARY owns review-diff persistence; no writer evidence-artifact writes.

**Frozen final eight SHA256s:**
```text
c9feb76d44da5777ddc2ad0a0542fbfccf4278bf2bcf2679c7d838ff836caeaf  CraftArmy/Dashboard.lua
672b7e445a3ea9158adf300a7aa8a630802781f327d416b7bb570209fe86cf0b  CraftArmy/Data.lua
abdb4cc4c4492f3e682b1d62129f7b5f653246503fa4dc6d6e89c10b5e64be3f  README.md
09c4b4654e04357e3c8018128e82aca921ac852a9c77f75daff9afffcb160fca  docs/dashboard/README.md
4146c918a226f6c73760529cab6113d385c67d53f7cb538fea11318f9f4f1383  tests/cooking_enchant.lua
dfdb0577c972857b296dffca132d3809a701d7c22ec8da454a1a451a04825839  tests/profession_completion.lua
146afbdc9f0504290054856b6ac3c01b49a20989f01314fa5300e9131fc1f5c7  tests/profession_expansion.lua
b61fa02fe72d092e354ea2261a7202c220a2d8d1f89c3f53ae6efd4f96b06c20  tests/refresh_continuity.lua
```

Remaining/next: PRIMARY independent read-only full-scope review of this exact frozen target,
persist findings then primary acceptance. Platform review N/A. This implementation is not
independently verified/released; no native P04 outcome asserted. Historical R02/R03 failures
and R04 focused native acceptance preserved. Full native87/149 INCOMPLETE/all-rankUNVERIFIED/
estimate accuracy unverified remain. No spending/gear changes/dumps/accepted-check repeats,
install/copy/Git mutation/releases/deployments/guides or children performed/authorized.

**P04 post-report stop check:** both Python structural commands PASS again (97Markdown/
548links/8diagnostic hashes;9required diagnostics), `git diff --check` PASS. Read-only
Python rechecked all8reported hashes/159protected/7immutablepreimages/exact whole reversals/
oldREADME suffix/9icons/168inventory/HEAD/index/emptycached/full30680byte actualdiff freeze:
ALL PASS. No source/test/README drift or active job. Resume remains PRIMARY independent
review, not another writer/native refresh check.

**PRIMARY independent P04 review persisted2026-11-20:** verifier
`ses_e0d090be5ffebV7zMDwmGouoeY` full-scope STATIC PASS/no confirmed findings on30680-byte
actual diff SHA`ef3b34eee5df1985cabc5884e089b2e40ff60aabbf283fdf2da5f26371336a5e`, all280
new runner lines, inline contract/evidence and surrounding Data/collection/instance-retention/
model warning/filter/tooltip semantics. Cooking-only eligibility, Fishing pending, tuple
guards and existing freshness/history/archive semantics preserved. Four exact old adaptations
retain all matrices/assertions; no stat/ID/presentation redesign or R04 logic changes.
Reviewer PARTIAL/overall review acceptance INCOMPLETE solely for independent commands/hash/
reversal/protected/inventory/Git/end-freeze NOT RUN after prior denial, no retry/bypass or
reattribution. Supplied hashes not independently recomputed. Writer execution and primary
comparisons remain separate. No static blocker, platform/.NET/React N/A; primary final
execution/freeze/acceptance next. P04 native outcome pending; R04 native acceptance intact.

**PRIMARY P04 scoped local acceptance2026-11-20:** independent full STATIC PASS/no findings
plus separately attributed PRIMARY all12approved serial terminal commands on eight reviewed
hashes: Cooking12/81992, fontstring9/1338363, collection31/860393, refresh61/1333822,
P03=15/31294, P02=12/13223, P01=16/221046/all184/400/800rows, legacy512/all19U07
(5/10/2/2)/K6=744/K7=565, diagnostics23, bothPython97Markdown/548links/8diagnostic hashes
and whitespace PASS. Full stdout/results in ignored `artifacts/p04-comparison/primary-final-*`;
all eight hashes exact across commands. Reviewer execution/comparison/end-freeze remains
NOT RUN/INCOMPLETE after denial, no retry/bypass/reattribution; platform N/A.

Build `0.2.0-mvp+p04.1`: only Cooking policy activated and Dashboard build marker advanced;
Fishing pending unchanged, stat UI unchanged, accepted R04 continuity bytes preserved.
Eight hashes/full30680-byte actual diff above are locally accepted. P04 native behavior
remains pending ordinary use; no new native success, install/copy/Git/release/guide authority.
No purchases/enchant applications/gear changes/new dumps/version interview or repeated
accepted refresh checks. Full native87/149 INCOMPLETE/all-rank/estimate-accuracy limits unchanged.
PRIMARY ending freeze after acceptance docs PASS:8reviewed hashes/156protected originals,
7immutable preimages, FOUR exact old-test block reversals/Data one-expression/Dashboard
one-literal/refresh two-literal reversals, old README history,9icons,168inventory,HEAD/index/
cached diff/full30680-byte actualdiff unchanged. Only attributed primary PLAN/AGENTS/TASKS/
native-evidence updates outside writer scope. Accepted hashes in ignored P04 packet;
postdoc bothPython97Markdown/548links/8diagnostic hashes and whitespace PASS. No active job.

**P04 focused native acceptance2026-11-20:** user says “Confirmed” after the delivered
Cooking-only warning/filter. Accept reported scope; no repeat Cooking/profession/refresh
checks, spending/gear changes/new dumps. Fishing remains pending/unverified; broader native
and full-suite limitations unchanged. Subsequent scrolling report tracked separately asU16.

### R04 — Empty FontString read incorrectly invalidates continuity

**ACCEPTED2026-11-20 — local verification + user-confirmed focused native fix.** User
screenshot received; no further status/version capture requested. It shows ordinary
“Building saved dashboard incrementally”/previous-view text, raw status “Open your own
profession to refresh”, build r03.1,45rows, Active/All and blank text under gear icons.
This does not identify an event or prove the complete installed file set.

Concrete contract mismatch in Dashboard.demoteVisible: pcall(label.GetText) succeeds with
nil for a normal empty native FontString, but the type check marks it failed; later cleanup
clears continuity and lastPaint. Ordinary icon-only gear intentionally SetText(""). Existing
standalone widget mocks return "" for that read and missed this path.

PRIMARY read-only control/experiment via installed Lua5.1: actual Dashboard/schema2 fixture,
one icon-only accessory display. Existing empty-string mock keeps both indicators visible;
ONLY changing private FontString empty result to nil makes BOTH disappear during pending
build and return at publication, with same pending/raw status as screenshot. Complete saved
root/token preservation and166project-path/sixacceptedR03hash freeze PASS. Evidence under
ignored `artifacts/r04-investigation/`: fontstring-empty-probe.lua/log, probe-source-freeze.json.
First exploratory fixture failed its own empty-label precondition (generic fixture only
unknown gear); corrected private presentation to icon-only gear before the meaningful
successful control/experiment. No source/test change or new full-suite/native execution.

API evidence: current Warcraft Wiki GetText returns string-or-nil when no text set;
archived widget reference explicitly nil for an empty string. Sources/limits in investigation.
Deterministic native-contract reproduction, not a direct native call trace; R03 native still
unaccepted. Proposed fix: treat ONLY successful nil label reads as normal blank, preserve
throw/false/number/table failures and all ownership/cache safety. Update native-compatible
mock and focused regressions, advance build. No broader collection/continuity redesign,
new instrumentation/install/Git/guide scope. The approved executable contract follows.
No writer/check job active at preparation.

#### Goal
Keep ordinary blank native FontString reads from discarding verified indicator continuity.

#### Why
Latest PLAN/R04 finding and investigation: successful nil from empty native text was
misclassified as failure. Screenshot + controlled API-contract reproduction, not native
call tracing; no new screenshot/version interview or broad speculative handoff redesign.

#### Run state
LOCALLY ACCEPTED — all4 implementation pieces, independent static review and PRIMARY final
validation complete. No active writer/check job; five reviewed targets below frozen.
Completed: native-compatible red/green regression; exact nil-only normalization/comment/
buildr04.1; nine new regression groups; approved old-mock/two-version edits; scoped docs;
all11final serial commands and reconstruction/protected/history/icons/inventory/Git proofs.
Blockers: none locally. Independent executable verification remains NOT RUN after denial;
user now confirms the native refresh symptom is fixed. No remaining R04 acceptance check.
Historical R02/R03 failures remain. Fullnative87/149 INCOMPLETE/allrank UNVERIFIED unchanged.
Exact resume: PRIMARY generate read-only full actual four-preimage+new-runner review packet
from `artifacts/r04-comparison/`, delegate independent review of the final five hashes below.
No source edits, installer/copy/Git mutation or native tests authorized by this completion.
Primary freezes accepted uncommitted R03 actual tree in ignored `artifacts/r04-comparison/`,
NOT initial HEAD. Four immutable preimages; new fontstring runner absent. Comparison
artifacts primary-owned/read-only to agents. No primary writes assigned files while active.

#### Design — serial pieces
1. Verify packet/current accepted R03 hashes/HEAD/index, inspect scripts, run existing full
   serial baseline. Add new `tests/fontstring_continuity.lua` and correct the ONE existing
   native-style widget mock GetText method to return nil for FontString with stored empty
   text (other widgets/values unchanged). New meaningful rejecting tests use actual Render
   to produce icon-only blank gear labels, first show both indicators, then Refresh and
   demand both survive each pending callback. Use normal saved view/no-open-profession
   scenario matching screenshot as well as actual collector handoffs. No harness-only red.
2. In Dashboard.demoteVisible immediately AFTER existing post-GetText owns() check,
   normalize ONLY `ok and value==nil` to `value=""` before original string handling.
   Retain thrown/false/number/table/function failures, warning recolouring, source/context/
   generation/ownership/cache guards and cleanup exactly as before. No general tostring
   coercion, broad exception suppression or call skipping. Optional short API comment.
   Advance private loaded Dashboard marker to `0.2.0-mvp+r04.1`; no other runtime change.
3. New tests cover no-text and intentional-empty FontString contract, icon-only accessory/
   Tool/hidden empty labels at early/late rows/46mixed rows/two own professions. Preserve
   saved roots/fresh/old row graphs/tokens/no acquisition/GUID/clock work beyond existing
   refresh/paint. Verify no eligible marker/cyan Hide/reset, approximate label stays frozen,
   pending historical hovers/actions unchanged; normal publication recovers/updates. Test
   actual Request/Scan and closed-profession failure paths with empty text; true GetText
   faults/invalid types still clear cache/unsafe decorations, retry no revival; reentry at
   GetText returning nil must not touch newer paint/job/status/hover/scroll. No model/data
   or observed/unknown semantics changed by treating an empty UI label as normal.
4. Update expected-version TWO literals in old refresh runner and README marker to r04.1.
   Other old refresh helpers/cases unchanged except the ONE mock method; all61groups retained.
   R03 collection runner/older runners/SelfTests fully frozen. Root README current status/
   build/dev-command lines only; dashboard README prefix beforeR03, old history intact.
   Run final serial commands/proofs/hashes; freeze for independent review/primary acceptance.

- [x] **1. Baseline/native-compatible rejecting regressions.**
- [x] **2. Narrow nil normalization/build update** — green2groups/26327assertions.
- [x] **3. Blank/invalid/fault/reentry regressions** — final9groups/1338363assertions PASS.
- [x] **4. Full checks/docs/proofs/freeze** — all11final commands/proofs PASS; review pending.

#### Files
Writer ONLY CraftArmy/Dashboard.lua (normalization/comment/build literal), new
tests/fontstring_continuity.lua, tests/refresh_continuity.lua (ONE mock method and TWO
expected-version literals only), README current/status/build/dev lines,
docs/dashboard/README prefix beforeR03, TASKS R04 execution/status/report. Primary owns
PLAN/AGENTS/investigation/review/artifacts. Every other module/test/tool/asset/TOC frozen,
including Collectors and R03 handoff implementation, Storage/Core/ViewModel/Commands/Data/
Knowledge/SelfTests/collection runner. No old test adaptations beyond exact listed edits.

#### Tests
Installed runtimes only, inspect first. Existing baseline all commands excluding new
runner before edits; final commands serially to terminal completion:

```sh
lua5.1 tests/fontstring_continuity.lua
lua5.1 tests/collection_continuity.lua
lua5.1 tests/refresh_continuity.lua
lua5.1 tests/profession_completion.lua
lua5.1 tests/gathering_activation.lua
lua5.1 tests/profession_expansion.lua
lua5.1 tests/dashboard.lua
lua5.1 tests/run.lua
python3 tools/check_dashboard.py
python3 tools/check_diagnostics.py
git diff --check
```

Whole Dashboard reconstruction by reversing ONLY normalization/comment and build literal;
whole old refresh runner reconstruction by reversing ONLY mock method and TWO literals;
all other preimage/protected paths and old dashboard README suffix exact. Icon pairs,
inventory, HEAD/index unchanged. Full actual four-preimage diff + new runner/final5hashes.
Unexpected old failure/design fork stops for primary, never relax tests/workloads/limits.
Permission denial remains NOT RUN without retry/bypass or writer/primary reattribution.
Platform review N/A. No native/all-rank/estimate-accuracy success inference.

#### Out of scope
No new collection/handoff/model/clock/storage/sort/attention policy, redesign, runtime
tracing, new API lookups/frames/commands, install/copy/Git/release/guides, resets or native
retests/dumps beyond eventual focused ordinary refresh. Prior native failures stay recorded.

#### Report back
agent-handoff envelope; durable piece/run status at every stop, completed/blocker/remaining/
exact resume, baseline/red/green/failure command chronology, files/diff/hashes and exact
reconstruction/protected/history/icon/Git proofs. Artifacts read-only; primary generates
review packet/persists findings before acceptance. COMPLETE never grants native/publication
acceptance. No children or competing writer.

**Writer report —2026-11-20 (local only; independent review/primary acceptance pending):**

- Files: Dashboard only successful-nil normalization immediately after post-GetText owns,
  one API comment, one build literal. New `tests/fontstring_continuity.lua`285lines reuses
  frozen fixture helpers without running/changing old case lists. Old refresh runner only
  ONE GetText method/TWO version literals. Root README current/build/development lines;
  dashboard README28line prefix; no existing dashboard history changed. TASKS only R04 state/report.
- Coverage: no-text/intentional-empty native FontString and unchanged other widget reads;
  actual Render icon-only Accessory1/Accessory2/Tool and empty/hidden/no-text labels at rows1/12;
  mixed46 rows/two own professions; no eligible dot/cyan Hide/reset, frozen approximate labels
  at every pending frame/build callback; successful publication updates normally. Root/fresh/
  old-row graph identity/metatables/edges and46row tokens preserved. Historical hover/disabled
  actions/Details and warning recolouring remain. Actual failed closed-profession Scan produces
  screenshot Raw status/ordinary pending status and retains both; actual Request/Scan handoffs
  work in frame/build/scan-first orders, coherent new observation replaces whole cell. Bounded
  visible validation12, existing GUID/clock counts, zero prediction recalculation and zero
  attempted acquisition (protected-error counting included). Early/late GetText throw/false/
  number/table/function reads revoke unsafe paint/cache, retry cannot revive until publication.
  Successful nil GetText reentry preserves newer same-paint/completed/pending job, rows/status/
  widget calls/hover/queued scroll. Existing wrappers/R02F1F2F3/R03 tests fully retained.

Chronology (no hidden old-test failure or workload reduction):
1. Read skill/AGENTS/complete PLAN/R04 contract and scripts; installed `/usr/bin/lua5.1`,
   `/usr/bin/python3`. Packet166paths/fourpreimages/acceptedR03hashes/HEAD matched before edits.
   Initial non-NUL index-hash comparison failed; `git ls-files --stage -z` matches packet,
   so command-format mismatch only, no index drift. `rg` absent; used dedicated grep.
2. Baseline all10existing commands below before source/test edits: serial foreground timeout0,
   exit0 throughout, no baseline failure. Collection output initially tool-truncated; overall
   shell `set -e` confirms exit0. Attempted read of tool-managed external full-output file
   denied (external_directory): NOT READ, no retry/bypass; no missing check result inferred.
3. Correct ONE mock GetText, add first2new groups. Twice `lua5.1 tests/fontstring_continuity.lua`
   exit1,1passed/1failed/1291assertions against unchanged Dashboard: first forbidden dot demotion;
   second improves assertion diagnostic to `pending dot=false; estimate=false`. Actual icon-only
   Render/blank-nil precondition and initial BOTH visibility pass. Genuine product red, not
   initial investigation's empty-gear harness issue.
4. Apply exact normalization/comment/build. Same command exit0,2groups/26327assertions.
5. Expand new runner: first same command exit1,8passed/1failed/1313131assertions, solely new
   harness mistake dispatching status OnEnter on reason FontString instead of statusArea.
   Correct only new runner; next exit0,9groups/1338362assertions. Add explicit acquisition
   attempt counter, update scoped docs and only TWO old expected-version literals.
6. Final11serial foreground checks below, `set -e -o pipefail`, timeout0. Older long Lua
   outputs filtered with `tail` only after full execution (no skipped cases); all exit0.
   Read-only Python preservation/diff/hash proof then PASS. No primary artifacts written.
7. After final durable report, reran `python3 tools/check_dashboard.py`,
   `python3 tools/check_diagnostics.py`, `git diff --check`: all exit0 with same97/544
   structural counts. Read-only Python rechecked final5hashes/161protected paths/HEAD/index:
   all unchanged/PASS. No heavy suites rerun, no pending writer/check process.

| Exact command | Baseline before edits | Final frozen target |
| --- | --- | --- |
| `lua5.1 tests/fontstring_continuity.lua` | absent |9groups/1338363assertions PASS |
| `lua5.1 tests/collection_continuity.lua` | exit0 PASS |31groups/860393assertions PASS |
| `lua5.1 tests/refresh_continuity.lua` |61groups/1333822assertions PASS |61groups/1333822assertions PASS |
| `lua5.1 tests/profession_completion.lua` |15groups/31244assertions PASS |15groups/31244assertions PASS |
| `lua5.1 tests/gathering_activation.lua` |12groups/13223assertions PASS |12groups/13223assertions PASS |
| `lua5.1 tests/profession_expansion.lua` |16groups/221046assertions PASS |16groups/221046assertions PASS |
| `lua5.1 tests/dashboard.lua` |512/all19/744K6/565K7 PASS |512/all19(5/10/2/2)/744K6/565K7 PASS |
| `lua5.1 tests/run.lua` |23/23 PASS |23/23 PASS |
| `python3 tools/check_dashboard.py` |97Markdown/542links/8diagnostic hashes PASS |97Markdown/544links/8diagnostic hashes PASS |
| `python3 tools/check_diagnostics.py` |9files PASS |9files PASS |
| `git diff --check` | PASS | PASS |

Preservation proof (read-only Python stdlib/subprocess, compared actual uncommitted R03,
NOT HEAD): all4immutable preimages still match166path packet. All161protected paths exact,
including Collectors/Core/Storage/ViewModel/Data/Commands/Knowledge/SelfTests/R03 collection
runner/other old runners/tools/TOC/assets/primary docs. Whole Dashboard byte-exact reconstruction
after removing ONLY exact two-line comment/normalization and reversing one build literal.
Whole old refresh runner byte-exact after reversing ONLY one exact mock function/two version
literals; all61cases/helpers therefore preserved. Complete old dashboard README suffix exact;
root README diff inspected and limited to allowed current/build/dev lines. Inventory exact167
paths = original166 + new runner, no removals. All9original/packaged icon pairs byte-identical.
HEAD unchanged `5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`; index NULstage SHA256 unchanged
`77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299`.

Full actual four-preimage diff + entire new runner computed in memory (no artifact writes):
25069bytes, SHA256 `b09d08e2bbb7aa34abc99cda38e85c5451fc3d1963aa18d39c8b62357d1a8170`.
Format: Python difflib.unified_diff, sorted fourpreimage paths, fromfile=`a/<path>`,
tofile=`b/<path>`, then newrunner fromfile=`/dev/null`, tofile=`b/tests/fontstring_continuity.lua`,
default3context/newline, UTF-8. Primary owns review-diff persistence; not Git HEAD diff.

Frozen final five SHA256:
```text
f5ef59e57fa2104cf8d4d81883cac5f7c62e47c9f21d07760d391b577d1c0944  CraftArmy/Dashboard.lua
6f2770f687799068304a798646b0284453fc46d3b8066886103302f6dcb387ef  README.md
d5f537efe3620321689088bbdab02c9f42dd518f067f2873b2ec6b52d03be006  docs/dashboard/README.md
2e27722852ca88b5c1e8b36e75e23a640ca92df84c021a7597beeec0f5d038ce  tests/fontstring_continuity.lua
8369f436352fb1c4a9394879f527a98161614b16172f458e3cb1269910a4a992  tests/refresh_continuity.lua
```

**PRIMARY independent R04 review persisted2026-11-20:** verifier
`ses_e0d090be5ffebV7zMDwmGouoeY` full-scope STATIC PASS/no findings on25069-byte actual
diff SHA`b09d08e2bbb7aa34abc99cda38e85c5451fc3d1963aa18d39c8b62357d1a8170`, all285new
test lines, inline contract/investigation and surrounding demotion ownership. Successful
nil normalized only after ownership check; other invalid types/throws remain fail-closed.
Mock change and coverage substantively exercise native blank labels, actual icon-only
Render/production callbacks, no revival/reentry/bounds/data preservation; no policy change.
Reviewer PARTIAL/overall review acceptance INCOMPLETE solely because independent commands,
hashes/reconstructions/protection/Git/end-freeze NOT RUN after prior shell denial, no retry/
bypass/reattribution. Writer execution and primary comparisons remain separate. No reviewer
edits/static blocker, platform/.NET/React N/A. Primary fresh final validation/acceptance next;
no native resolution, new diagnostic request, install/copy or Git authority from review.

**PRIMARY R04 scoped local acceptance2026-11-20:** independent full STATIC PASS/no findings
plus separately attributed PRIMARY all11approved terminal serial commands on reviewed5hashes:
fontstring9/1338363, collection31/860393, refresh61/1333822, P03=15/31244, P02=12/13223,
P01=16/221046/all184/400/800rows, legacy512/all19U07(5/10/2/2)/K6=744/K7=565,
diagnostics23, bothPython97Markdown/544links/8diagnostic hashes and whitespace PASS.
Full stdout/results under ignored `artifacts/r04-comparison/primary-final-*`; all five
reviewed hashes exact across commands. Independent execution/comparison/end-freeze remains
NOT RUN/INCOMPLETE after denial, never reattributed. Platform N/A. No native-fix claim.

Current local build `0.2.0-mvp+r04.1` corrects ONLY successful-nil label handling; collection/
R03 policies and saved observations/sort/attention unchanged. Nine new native-compatible
groups cover the previously masked failure, including screenshot Raw status path. Prior
R02/R03 native failures preserved. Next only ordinary-refresh behavior feedback once this
delivery is loaded—no new screenshot/version interview, dump, forced scan, profession/
gear change or reset. No install/copy/Git/release/guides performed/authorized. Full native
87/149 INCOMPLETE/all-rankUNVERIFIED/estimate accuracy unverified remain. No writer/job.
PRIMARY ending freeze PASS after acceptance docs:5reviewed hashes/159protected originals,
4immutable preimages, exact whole Dashboard/old-runner reversal, old README history,9icon
pairs,167inventory(original166+newrunner), HEAD/index/cached diff/full25069-byte actualdiff
unchanged. Only attributed primary PLAN/AGENTS/TASKS updates outside writer scope. Accepted
hashes retained in ignored R04 packet. Postdoc bothPython97Markdown/544links/8diagnostic
hashes and whitespace PASS; no source/test/README drift or active job.

**R04 focused native acceptance2026-11-20:** user says “That has fixed it, good job.”
Reported dot/Concentration-estimate refresh continuity now accepted in WoW; no repeat check,
screenshot, version question or further writer work. User acceptance does not complete the
full native87/149 suite, establish measured latency/cadence/offline estimate accuracy or
infer broader profession acceptance. Independent execution remains NOT RUN after denial.
Source/test/README accepted hashes unchanged; no new install/Git/release/guide authority.

### R03 — Collection-handoff continuity follow-up

**LOCALLY ACCEPTED / NATIVE FOLLOW-UP FAILED2026-11-20 — r03.1 confirmed; both indicators still disappear.** Complete
[R03 implementation contract](docs/dashboard/refresh-r03-contract.md) is authoritative.
User
confirms `0.2.0-mvp+r02.1` and continued dot/estimate disappearance. Do not repeat marker
checks or attribute this to an old Dashboard. V01 focused native identifier accepted;
R02 native continuity NOT accepted. No writer or validation job active.

PRIMARY read-only local probe invokes actual Commands.Event → Collectors.Request/Scan →
Dashboard callback methods with synthetic own Inscription APIs/timers/widgets/schema2 root.
Three asserted sequences PASS:
1. Begin ordinary pending Refresh (both visible), send CURRENCY_DISPLAY_UPDATE, run dashboard
   OnUpdate before scheduled Scan: both disappear at callback return; queued real Scan
   cannot recover old paint cache; replacement publication restores both.
2. Run queued Scan first: dot stays, estimate clears; publication restores estimate.
3. Scan from completed view with unchanged amount/new observation timestamp: dot stays,
   estimate clears until replacement publication. This is R02's exact-provenance rule,
   not evidence that the numeric estimate is generally accurate.

Evidence-only files under ignored `artifacts/r03-investigation/`: collector-sequence-probe.lua,
collector-sequence-probe.log, probe-source-freeze.json. PRIMARY Lua5.1 exit0;163actual project
paths unchanged, accepted V01 hashes exact. Saved-root/token comparisons around UI-only
work PASS; intentional fixture scans update their private roots. No production/test edits,
native event/order/frequency/latency proof, new full-suite result, install or Git mutation.
Initial exploratory probe also reproduced callback clearing; its first publication used
time equal to new observation (legitimately no gain), corrected evidence probe advances
clock10seconds before publication to assert restoration. No product fix or hidden PASS.

Next proposal: scoped R03 independently validate same current-player active-generation
identity across expected collection handoffs, and directly replace Concentration with a
freshly verified visible display when its observation changes, instead of blanking while
the full asynchronous list builds. Do not merely ignore revisions/tokens, retain an
obsolete projection over changed data, or change estimate math/saves/sort/attention. Keep
unknown/failure/source/GUID/options/generation safety and ownership; add actual collector
sequence regressions (not just manual pre-Refresh invalidation). Advance Dashboard build
for any new source delivery. Historical proposal is superseded by approved contract below.
PRIMARY evidence-only ending check PASS:159non-document project paths and accepted V01
targets unchanged; only PLAN/TASKS/AGENTS/investigation updated. Dashboard structural check
PASS95Markdown/535links/8diagnostic hashes; whitespace PASS. No full suites/native run or writer.

**Approved R03 execution queue / run state COMPLETE2026-11-20:** one synchronous writer, no children,
primary ignored comparison snapshot verified before dispatch; no source edits/new full suite
at approval. Complete contract includes private collector DashboardHandoff signal lifecycle,
bounded replacement/ownership, actual production-sequence regressions and correct no-gain
observed-only semantics. Runtime source build `0.2.0-mvp+r03.1`. Native outcome still pending.
- [x] **1. Baseline/rejecting production-sequence tests.**
- [x] **2. Private collector handoff record/accessor** — depends on1.
- [x] **3. Guarded Dashboard handoff/replacement cell** — implemented; coverage/audit in4; depends on2.
- [x] **4. Regressions/exact version update** — depends on3.
- [x] **5. Full final suites/docs/proofs/freeze** — depends on4.
Read-only packet `artifacts/r03-comparison/before-files.json`, `preimage-paths.json`,
`git-before.json`; accepted uncommitted V01/R02 actual tree, NOT HEAD. Primary owns artifacts/
contract/planning; writer only contract-listed files/R03 execution fields. No installation/
Git/native/guide/new profession authority. Unexpected legacy failure/design fork stops for
primary; no old tests rewritten except TWO specified V01 version literals.

**R03 writer baseline2026-11-20:** agent-handoff loaded; complete AGENTS/PLAN/active task/
all8contract sections read. Installed Lua5.1/Python3 and approved runners inspected.
Read-only packet verification PASS all164actual paths/exact inventory/5immutable preimages/
HEAD/index/empty cached diff/new runner absent. Artifacts untouched. Fresh serial baseline
under `set -euo pipefail`, foreground timeout0: `lua5.1 tests/refresh_continuity.lua`
PASS61/1333822; `lua5.1 tests/profession_completion.lua` PASS15/31244;
`lua5.1 tests/gathering_activation.lua` PASS12/13223;
`lua5.1 tests/profession_expansion.lua` PASS16/220990/all184/400/800rows;
`lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'`
PASS512/all19/K6=744/K7=565; `lua5.1 tests/run.lua` PASS23;
`python3 tools/check_dashboard.py` PASS96Markdown/538links/8diagnostic hashes;
`python3 tools/check_diagnostics.py` and `git diff --check` PASS. No baseline failure.
Next: new actual-collector rejecting runner before product edits, then serial pieces2–5.
No blocker/children/background job/native execution/Git mutation.

**R03 piece1 red complete; piece2 RUNNING:** new `tests/collection_continuity.lua` reuses
frozen fixture helper declarations only, actual Commands/Collectors/Storage/Dashboard with
46mixed rows/two own professions. `lua5.1 tests/collection_continuity.lua` exit1:
1PASS/2FAIL/8391assertions on unchanged runtime: frame-before-real-queued-Scan loses dot;
successful renewed150 observation at210/shared Render220 loses valid cyan160. Reverse order
zero-gain100/1000 already truthfully passes. No product edits at red/no harness failure.
Next private collector signal lifecycle, then guarded Dashboard replacement. No blocker/job.

**R03 pieces2–3 implemented; piece4 RUNNING:** private record/accessor/lifecycle added to
actual Collectors only; Dashboard validates explicit signal and bounded visible rows, replaces
pending work through existing StartBuild ownership and prepares private scalar cell from
verified committed successful Concentration. Uses existing Render clock/unchanged estimator
once, freezes pending cell and keeps dot independent. Initial new green
`lua5.1 tests/collection_continuity.lua` PASS3/19496. Compatibility pre-version reruns:
`lua5.1 tests/refresh_continuity.lua` PASS61/1333822 and legacy filtered dashboard command
PASS512/all19/K6=744/K7=565. Further signal/provenance hardening since that preliminary green
not final-validated yet. Next comprehensive new negative/fault/reentry/bounds coverage and
exact build/two-literal updates, then final suites/docs/proofs. No unexpected old failure/job.

**R03 piece4 complete / piece5 RUNNING:** expanded production-sequence suite first
PASS15/609111, then23PASS/2FAIL795682: new wrong-scope fixture manufactured a different
record identity on every accessor read (correctly rejected); same-build fixture asserted
across Scan's second legitimate changed callback instead of the interrupted callback.
Corrected ONLY new fixtures (stable per-publication fake identity; immediate first-callback
ownership assertions). Next PASS25/802774 and PASS30/833935 after more boundary matrices.
No unexpected old failure or legacy edits. Private one-shot StartBuild handoff pins the
original signal against change-again; observed collector publication also pins token/session
serial/revision/generation. Build now r03.1; old refresh runner edited ONLY its two approved
version literals. Both approved README current/prefix edits present, old dashboard history
untouched. Final added coherent/no-preliminary-cyan-hide/two-own-profession group awaits
final execution. Next final full serial commands/proofs/diff/hash freeze. No blocker/job.

**FINAL R03 writer run state — COMPLETE2026-11-20:** all5pieces complete; no active writer,
children, background/check job, blocker or remaining local implementation work. Six delivery
targets frozen below. Only approved Dashboard handoff/private scalar/build integration,
Collectors private signal/accessor/lifecycle, new collection runner, TWO old-runner version
literals, approved README current/prefix edits and these R03 execution fields changed.
Actual accepted UNCOMMITTED V01/R02 is the base, NOT HEAD; unrelated user work preserved.
Private collector scheduling evidence distinguishes genuinely queued work from a scheduler
throw; the existing scheduler call is protected solely to revoke the signal before rethrowing
the same failure, without changing self.scheduled policy, calls, timing or changed frequency.
Scan observed publication precedes StartLoads/Expire's synchronous notifications. No new
acquisition, event/timer frequency, model/schema/math/save/sort/attention/layout/TOC changes.
Implementation completion is NOT independent verification, primary/native acceptance or release.

**Final terminal serial commands — all exit0**, `set -euo pipefail`, foreground timeout0:
- `lua5.1 tests/collection_continuity.lua` —31groups/860393assertions. Actual production
  Commands.Event → Request/queued Scan, Scan/StartLoads/synchronous Expire, item retry/timeout,
  schema2 Storage and native-style widgets/build/frame callbacks;46mixed rows/12widgets/two
  own professions. Both callback orders and build-driver-first, coalesced/repeated events,
  multiple scans, zero-gain/full/zero/future/backward/nil-clock/invalid-rate/unknown/error/N/A,
  renewed time/build/currency/quantity/cap/rate and committed-scope mismatch covered.
  Safe dot/unchanged cyan no Hide/reset; positive new cyan has no preliminary Hide; complete
  new observed ratio/cyan offset/width/label coherent by callback return and frozen thereafter.
  New/unchanged UI paths preserve saved root/fresh/old-row graphs/tokens, separating intentional
  collector commits. <=12Active reads, zero additional retained Active/estimate work, one new
  estimate despite both synchronous changed callbacks, existing GUID/shared clocks only;
  no eager iterator/whole-root/list/row copy. Missing/throwing/malformed/stale/change-again
  signals and bare/unsigned drift fail closed. Source/options/GUID/row/generation negatives;
  signal/Active/Token/source/clock/model/native paint/setup/scheduler/cancel/Step/batch/
  publication faults, unsignalled mutation and same/new-build reentry matrices; newer job/
  status/hover/scroll protected; private one-shot self-only wrappers/pre/post-entry throws,
  historical actions/hovers, explicit cancel/hide/drop/scroll/reuse cleanup included.
- `lua5.1 tests/refresh_continuity.lua` —61groups/1333822assertions, all prior groups/helpers
  byte-preserved except exactly TWO V01 version literals. F1/F2/F3 coverage unchanged.
- `lua5.1 tests/profession_completion.lua` —15groups/31244assertions.
- `lua5.1 tests/gathering_activation.lua` —12groups/13223assertions.
- `lua5.1 tests/profession_expansion.lua` —16groups/221046assertions; ALL original184/400/800row
  growth workloads complete. Baseline reported220990; no source/fixture/assertion edits.
- `lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'` —512/512,
  ALL19U07workloads5/10/2/2, K6=744/K7=565, zero failures. Output filtering only; no skips,
  workload/order/limit/assertion reductions. SelfTests and all older runners frozen.
- `lua5.1 tests/run.lua` —23/23diagnostic cases.
- `python3 tools/check_dashboard.py` —PASS17required/exactTOC/96Markdown/539links/
  8diagnostic hashes; `python3 tools/check_diagnostics.py` —PASS9required/exactTOC/oneSV.
- `git diff --check` —PASS. Python checks structural only. All callbacks/APIs/widgets are
  synthetic, not native client evidence. Fresh baseline/red/intermediate greens and final
  commands remain separately recorded above. No unexpected legacy failure or denied retry.

**Exact final preservation/full actual-diff proofs — PASS**, read-only Python stdlib/Git:
- All158protected paths of164baseline hash-identical (excluding5owned preimage paths+TASKS).
  All5immutable local preimages match the fixed original manifest; artifacts untouched.
  SelfTests SHA256`0caa9096efaaf98f1bdd79a8738bbc779489c7eced3b19189601734566e339c1` exact.
  Core/Storage/ViewModel/Data/Knowledge/Commands/Details/old fixtures/tools/TOC/assets and
  primary planning/contract/evidence documents unchanged.
- Entire old refresh runner reconstructs byte-exactly by reversing ONLY TWO r03.1 literals
  to r02.1. Dashboard README suffix beginning `# R02` is byte-identical to its entire
  immutable preimage (all prior history preserved). Root README actual diff inspected:
  current R03/version/follow-up/development lines only. Full actual runtime diff inspected;
  no collection-policy/math/scheduling-frequency or unrelated edits. New runner inspected.
- All9root/packaged icon pairs identical. Exact165Git-listed existing path inventory equals
  original164 plus SOLE new `tests/collection_continuity.lua`, no removals.
- HEAD unchanged`5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`; NUL-stage SHA256 unchanged
  `77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299`; cached diff empty.
- Deterministic complete actual diff: sorted5preimage-map paths, Python
  `difflib.unified_diff(...splitlines(True),fromfile='R03-before/'+p,tofile='R03-after/'+p)`,
  then new runner `/dev/null` to `R03-after/tests/collection_continuity.lua`, concatenated
  without separators: **64865bytes**, SHA256
  `63d7c54d514e8ff6baa12772188edca1ca103c996d2ba10f8899bfbe4cff4f24`.
  No writer evidence-artifact writes; PRIMARY generates its own review diff.

**Final SHA256s —6frozen delivery targets:**
```text
ba1e3aa4eeea521d6c8875eeab0cff6b04cf21b39bf602a7e1f2fa41c165151c CraftArmy/Collectors.lua
df8de4bcdb6a98f8612e7b44c6c922863f700d8cb76edb247bc259192403eeb6 CraftArmy/Dashboard.lua
8ac2539d26a577c9feace9294aedb0cb7a5792aa07b5317f935c89f98caaaf12 README.md
e58fe69acb84b55df12b87527b03254aa6b6175d42379477d0fc51beb0fc017e docs/dashboard/README.md
293ee4200fc810050df7ad6ed4f22c643e45b6633e908f96a36a1d03b7e5f0df tests/collection_continuity.lua
6b5ae53ab2860e1cdd8650b21c2017780f513d5b547ab256e7e6ff4ddf2fcfbd tests/refresh_continuity.lua
```

**Remaining gates / exact next action:** PRIMARY dispatches independent read-only full R03
review against these6targets and the5immutable local preimages/actual V01 base, persists
findings and owns local acceptance. No writer resume without scoped correction. Independent
execution/comparison for this delivery NOT RUN by this writer; prior reviewer denial remains
NOT RUN, never reattributed. Platform review N/A. Then only focused ordinary native dot/cell
continuity after local acceptance, not repeat profession/loaded-R02-marker checks or dumps.
R02 native continuity remains NOT accepted; no new native success/cause claim. Native trigger/
frequency/latency and measured offline estimate accuracy remain unknown; full native
INCOMPLETE87/149/all-rankUNVERIFIED unchanged. No install/copy/Git mutation/release/deployment/
guides/spending/gear/profession changes or child agents performed/authorized.

**R03 post-report stop check:** both Python structural commands again PASS96Markdown/
539links/8diagnostic hashes/exactTOC; whitespace PASS. Ending6target/158protected/5preimage/
two-literal whole-runner reversal/SelfTests/history/9icons/165inventory/HEAD/index/cached/
64865byte full actual-diff freeze PASS after final report. No source/test/README drift or
active job. Resume remains PRIMARY independent read-only review, not more writer work.

**PRIMARY independent R03 review persisted2026-11-20:** full-scope STATIC PASS/no findings
on64865-byte actual diff/six frozen targets, all657new runner lines and surrounding runtime.
[Review/provenance](docs/dashboard/refresh-r03-review.md). Verifier PARTIAL/overall acceptance
INCOMPLETE solely for independent executable/comparison/end-freeze NOT RUN after prior
denial, no retry/bypass/reattribution. Collector publication order, bounded protected handoff,
whole-cell replacement/no-gain fallback, frozen successor, cleanup/reentry/wrapper safety
and substantive coverage checked. No static blocker; primary final serial checks/freeze next.
No writer/check job active. No native/local acceptance or install/Git authority from review.

**PRIMARY scoped R03 local acceptance2026-11-20:** independent full-scope STATIC PASS/no
findings plus separately attributed PRIMARY all10approved terminal serial commands on
reviewed6hashes: collection31/860393, refresh61/1333822, P03=15/31244, P02=12/13223,
P01=16/221046/all184/400/800rows, legacy512/all19U07(5/10/2/2)/K6=744/K7=565,
diagnostics23, bothPython97Markdown/540links/8diagnostic hashes and whitespace PASS.
Logs/results in ignored `artifacts/r03-comparison/primary-final-*`; six reviewed target
hashes unchanged across all commands. Reviewer execution/comparison/end-freeze NOT RUN
after prior denial remains INCOMPLETE, no retry/bypass or reattribution. Platform N/A.

Accept only scoped local R03 implementation, not native resolution or offline estimate
accuracy. Build `0.2.0-mvp+r03.1`; current six hashes/64865-byte actual diff above, not earlier
deliveries. Next only focused normal-refresh dot/coherent Concentration display feedback
on this delivery. A renewed observation may legitimately have no extra cyan; correct
latest observed blue-only is not an unnecessary blank. No more R02 version interview,
profession checks/dumps/forced scans/full native timing chase/gear spending, install/copy,
Git/release or guides. Native trigger/order/frequency/latency unknown, full suite remains
INCOMPLETE87/149/all-rankUNVERIFIED and measured offline accuracy unverified. No writer/job.
PRIMARY ending freeze PASS after acceptance docs:6reviewed hashes/156protected originals,
5immutable preimages, exact TWO-literal reversal, old dashboard README suffix,9icon pairs,
166inventory(original164+writer runner+primary review), HEAD/index/cached diff and64865-byte
actualdiff unchanged. Only attributed primary PLAN/AGENTS/TASKS/review updates outside writer
scope. Accepted hashes retained in ignored R03 packet. Postdoc bothPython97Markdown/541links/
8diagnostic hashes and whitespace PASS. No source/test/README drift or active job.

**Latest native feedback2026-11-20:** user confirms expected current version and BOTH player
dot/Concentration estimation still disappear, returning only when refresh completes. Native
R03 NOT accepted; no repeat build question or cyan-only explanation. Prior local passes
are not revoked or promoted to native proof. Primary read-only inspection confirms there
are still explicit cache-eligibility, generic Retain/invalidated-context and failure/hide/
publication cleanup paths; which one runs in the client is unknown. No new source/test
edits, runtime instrumentation/fix authorization, writer or full-suite execution.
**Next focused evidence:** while both indicators are absent during an ordinary refresh,
hold Shift and hover existing status line under title; capture/copy that tooltip including
pending/previous-view text and Raw status. This uses existing diagnostics, not a repeated
version interview, new dump, forced scan or older acceptance procedure. Use it to narrow
the active path before another implementation proposal. Do not presume stale Collectors
or a complete matching installation merely from Dashboard marker; neither is established.

### V01 — Loaded dashboard build identification

**LOCALLY ACCEPTED2026-11-20; focused native marker user-confirmed.**
User confirms expected identifier; continuing native flicker remains unresolved, not an old-build assumption.

#### Goal
Show exactly which dashboard-code delivery the client loaded before more flicker changes.

#### Why
Latest PLAN V01 decision: R02 local acceptance does not prove updated client installation or
native success. Both dot/estimate still disappear per user; do not blame an old copy without evidence.

#### Run state
One synchronous implementer, no children; independent review then primary acceptance.
Primary read-only comparison packet `artifacts/v01-comparison/` freezes current accepted
uncommitted R02 tree, NOT HEAD. No writer/check job active at preparation.
All3pieces now complete; no writer/check job/blocker or remaining implementation work.
Source/test/README frozen at final hashes below. Independent static review and PRIMARY
local acceptance complete; independent execution unavailable. No client/install/native proof.

**PRIMARY independent review persisted2026-11-19:** verifier
`ses_e0d090be5ffebV7zMDwmGouoeY` reports full-scope STATIC PASS/no findings on6242-byte
actual V01 diff SHA256`ba2b63f72575ebc425cffc47ed0fa22012336d5886b7707f0aa27f224510178f`.
Reviewed both Dashboard additions, all3new groups, existing tooltip/Shift guards and README.
No normal header/layout/TOC/continuity/data/acquisition change. Marker identifies loaded
Dashboard code, not whole-install consistency or flicker success. Reviewer PARTIAL/overall
review acceptance INCOMPLETE solely for unavailable independent executable/comparison/
end-freeze checks: prior shell denial, NOT RUN, no retry/bypass. Supplied target hashes not
independently recomputed. Writer full suites and primary comparisons remain separately
attributed. No static blocker; platform/.NET/React N/A. Primary final validation/freeze next.

**Writer RUNNING2026-11-19, piece1:** read AGENTS/complete PLAN/all8V01sections;
agent-handoff loaded, approved Lua/Python runners inspected, installed runtimes confirmed.
Read-only Python stdlib/Git comparison PASS:163actual paths/exact inventory,3immutable
preimages, all5accepted R02 hashes, HEAD/NUL-stage/cached diff unchanged. Artifacts untouched.
Known baseline is PRIMARY R02 acceptance58/902323 plus other suites above, NOT a fresh V01
execution. Next add meaningful rejecting V01 groups before production edits; no blocker/job.

#### Design — serial pieces
1. Verify packet/current R02 target hashes; add rejecting standalone-runner groups using
   existing actual widgets. Shift status hover must expose exact loaded build, normal
   hover must not; missing/throwing Shift API stays normal. Preserve all58existing groups.
2. In Dashboard.lua only, embed private literal `0.2.0-mvp+r02.1` near module initialization
   and append `Loaded dashboard build: 0.2.0-mvp+r02.1` to diagnostic detail lines in existing
   statusArea OnEnter. Reuse focusedTooltip Shift selection, no new frame/event/command/API,
   no metadata lookup, saved field, timers or continuity changes. Header/title widths/text
   unchanged. It identifies loaded Dashboard source, not a full-install hash. Add concise
   README instruction to hold Shift then hover the status line directly beneath title.
   Future code deliveries must deliberately advance this identifier; do not reuse it for
   changed Dashboard source. No TOC/version/branding edit or metadata checker adaptation.
3. Run final serial new+existing refresh runner, P03/P02/P01, legacy512/all19/K6K7,
   diagnostics23, bothPython and whitespace. Verify exact protected paths/HEAD/index and
   complete actual diff/hashes; freeze for independent read-only review. Do not change
   old tests to accommodate this label. Unexpected failure stops for primary.

- [x] Piece1 — rejecting regressions/packet verification.
- [x] Piece2 — private code identifier/Shift status detail/README instruction; depends on1.
- [x] Piece3 — full checks/proofs/freeze; depends on2.

#### Files
Writer ONLY CraftArmy/Dashboard.lua (literal+status detail), tests/refresh_continuity.lua
(additive groups, original58 unchanged), README.md (version-check instruction), V01 task
execution/report fields. Everything else frozen, including SelfTests, TOC, Core/Storage/
ViewModel/Collectors/Commands/Data, existing fixtures/runners, assets and R02 implementation.
Primary owns PLAN/AGENTS/investigation/review/artifacts. No primary edits assigned files
while writer active; comparison artifacts read-only to agents.

#### Tests
Installed runtimes, inspect scripts; all nine R02 final commands serially as listed above.
New groups verify exact identifier only under Shift, same in retained status, safe missing/
throwing Shift query, unchanged normal status/header, saved root/token and no acquisition/
clock/GUID read added. Hash all protected actual paths; three local immutable preimages;
Git HEAD/index unchanged. No installer, native execution or permission-denial bypass.

#### Out of scope
No further flicker repair/instrumentation, continuity-policy/math/data/schema changes,
full-install verification claim, installation/copying into WoW, dependency/Git/release/guide
work, gathering retests/dumps/spending/gear changes. R02 native acceptance remains absent.

#### Report back
Persist piece/run status, red/green chronology, commands/results/diff/hashes/protected and
Git proofs at every stop. agent-handoff envelope; primary persists independent findings
and makes local acceptance decision. Then ask only for displayed identifier, not more data dumps.

**Piece1 complete / piece2 RUNNING:** added ONLY3new standalone groups after original58.
First `lua5.1 tests/refresh_continuity.lua` exit1:58PASS/3FAIL/904625assertions due solely
to new-fixture frame-width expectation1168 (actual accepted geometry1184 includes16extra).
Corrected ONLY new assertion. Meaningful pre-production red rerun, same exact command,
exit1:59PASS/2FAIL/1286226assertions: BOTH ready/retained Shift hovers lack exact appended
identifier; normal absence and missing/throwing/nontrue Shift fallback already pass.
All58original groups remain passing, Dashboard/README still exact preimages at red.
No old failure, production change or artifact write. Next tiny literal/detail/README edits.

**Piece2 complete / piece3 RUNNING:** production changed exactly2lines: private module-init
literal and appended existing status diagnostic detail, using unchanged focusedTooltip.
README adds only the concise Shift/status/expected-marker/not-TOC/full-install-limit/future
advance instruction. `lua5.1 tests/refresh_continuity.lua` green exit0:61groups/1333822assertions;
all58original groups and3V01 additions pass. Next final serial nine commands and exact
preservation/fullactualdiff/hash freeze. No blocker/background job or continuity changes.

**FINAL V01 writer run state — COMPLETE2026-11-19:** all3pieces complete, source/test/README
frozen, no active job/children/blocker. Changes ONLY Dashboard's private literal+existing
status detail append,3additive refresh-runner groups, root README instruction and V01
execution fields. No continuity-policy/logic changes, exports, metadata/API lookup, new
frame/event/command/timer, saved field, TOC/title/layout edit or acquisition. Loaded marker
identifies Dashboard code delivery, NOT whole-install consistency or a native flicker fix.
Actual accepted UNCOMMITTED R02 is the base, not initial HEAD; all unrelated changes preserved.

**Final terminal commands — all exit0, serial under `set -euo pipefail`, foreground timeout0:**
- `lua5.1 tests/refresh_continuity.lua` —61groups/1333822assertions. Original58 unchanged;
  3new V01 groups exercise existing actual status widget on same schema2/46row fixture:
  exact appended identifier once on Shift in ready+retained views, existing raw/blocked
  detail retained, normal hover absent including after Shift, missing/throwing/nonfunction/
  nil/string/number Shift queries stay normal. Full saved-root/fresh/rows/token preservation,
  unchanged title/status text/geometry/dispatch, no added frame/acquisition/GUID/clock reads.
- `lua5.1 tests/profession_completion.lua` —15groups/31244assertions.
- `lua5.1 tests/gathering_activation.lua` —12groups/13223assertions.
- `lua5.1 tests/profession_expansion.lua` —16groups/220990assertions, ALL original184/400/800rows.
- `lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'` —512/512,
  ALL19U07workloads5/10/2/2, K6=744/K7=565, zero failures. Output-only filtering; no skipped
  tests/limit/order/workload changes. SelfTests/old runners completely frozen.
- `lua5.1 tests/run.lua` —23/23diagnostic cases.
- `python3 tools/check_dashboard.py` —PASS17required/exactTOC/95Markdown/534links/8diagnostic
  hashes; `python3 tools/check_diagnostics.py` —PASS9required/exactTOC/oneSV. Structural only.
- `git diff --check` —PASS. No fresh V01 baseline suite claimed: initial PRIMARY accepted
  results, writer pre-production red (including new-fixture error) and green/final executions
  are distinct above. No unexpected old failure. Mock callbacks are NOT client API evidence.

**Exact preservation/full actual-diff proofs — PASS (read-only Python stdlib/Git queries):**
- All159protected actual paths of163baseline hash-identical; all3immutable preimages match
  manifest. Exact163Git-listed existing path inventory, no additions/removals. This includes
  frozen SelfTests, TOC, primary documents, tools/assets and every other runner/module.
- Whole Dashboard reconstructs exact accepted R02 preimage by removing ONLY the literal
  declaration and status detail append. All R02 continuity implementation bytes therefore
  unchanged. Removing ONLY the V01 addition block from refresh runner reconstructs its whole
  preimage (all58original groups/helpers/footer exact). README reconstructs by removing only
  the4line instruction+blank line. Full actual3file diff inspected, no unscoped change.
- HEAD unchanged`5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`; NUL-stage SHA256 unchanged
  `77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299`; cached diff empty.
- Complete actual V01 diff: sorted3preimage-map paths, Python
  `difflib.unified_diff(...splitlines(True),fromfile='V01-before/'+p,tofile='V01-after/'+p)`,
  concatenated without separators: **6242bytes**, SHA256
  `ba2b63f72575ebc425cffc47ed0fa22012336d5886b7707f0aa27f224510178f`.
  All comparison artifacts read-only/untouched; no writer-generated evidence artifact.

**Final SHA256s —3frozen delivery targets:**
```text
85196750d6b8d7308cc7e8154afd38445827885c054871765f8dc12eca636529 CraftArmy/Dashboard.lua
76b0a6bd7c1fad9c33ef2c14704798356933cd89e3cd18026eccbb6291ec2253 README.md
67e4cfdb93f42954ec4be79d1e29339bcf63d11010b2bb48a006e2599ddef9d9 tests/refresh_continuity.lua
```

**Remaining gates / exact next action:** PRIMARY dispatches independent read-only V01 review
against3local immutable preimages/actual R02 base, persists findings and makes scoped local
acceptance decision. No writer resume absent scoped correction. After acceptance, ask only
for displayed loaded identifier using Shift then status-line hover; running-client code
identity remains unknown and both indicators still blink per user. R02 native continuity
NOT accepted; no presumed old copy or new native claim. Full native INCOMPLETE87/149,
all-rank UNVERIFIED, estimate accuracy/trigger/frequency/latency unknown remain unchanged.
No native test/install/copy/Git mutation/release/deployment/guide work or denied-path retry.

**Post-report stop check:** both Python commands again PASS95Markdown/534links/8diagnostic
hashes/exactTOC; `git diff --check` PASS. Ending3delivery hashes/159protected paths/3immutable
preimages/exact163inventory/6242byte actualdiff/HEAD/index/cached diff freeze PASS after
final report. No source/test/README drift or active job; next remains PRIMARY independent review.

**PRIMARY V01 local acceptance2026-11-20:** full independent STATIC PASS/no findings,
plus PRIMARY all9approved serial terminal commands on reviewed3hashes PASS:61/1333822,
P03=15/31244,P02=12/13223,P01=16/220990/all184/400/800rows,512/all19/K6=744/K7=565,
diagnostics23,bothPython95Markdown/534links/8diagnostic hashes and whitespace. Logs/results
under ignored `artifacts/v01-comparison/primary-final-*`; no target drift across commands.
Independent execution/hash/preservation/end-freeze NOT RUN after prior denial; no bypass
or reattribution. Local acceptance only. No further flicker repair or WoW copy/install
performed; running-client identity unknown and both-indicator native flicker unresolved.
Next ask only for Shift status marker `Loaded dashboard build: 0.2.0-mvp+r02.1`, once this
delivery is loaded. Future changed Dashboard source must advance its private build literal.
PRIMARY ending freeze PASS after acceptance docs:3reviewed hashes/157other protected paths,
3immutable preimages, exact Dashboard2line/old58group reversal,163inventory/6242-byte actual
diff/HEAD/index unchanged. Only attributed primary PLAN/AGENTS/TASKS updates outside source
scope; postdoc bothPython/whitespace PASS. Accepted hashes in ignored V01 packet; no active job.

### R02 — Safe refresh continuity for estimate and current-player dot

**LOCALLY ACCEPTED2026-11-19 — independent STATIC PASS + PRIMARY full checks; native pending.** User explicitly approves combined fix/local tests. Complete
[R02 contract](docs/dashboard/refresh-r02-contract.md) is part of this handoff; all8sections
must be read. Baseline accepted uncommitted P03, not HEAD.10accepted P03 targets unchanged
at approval; new tests/refresh_continuity.lua absent; no new full-suite/native execution.

- [x] **1. Baseline/rejecting tests** — verify actual-tree snapshot/preimages/Git; full
  serial existing baseline; meaningful new failures for both markers.
- [x] **2. Private paint cache/eligibility** — bounded12visible cache; active-generation/
  source/options/GUID guards and unchanged Concentration provenance for estimate; depends on1.
- [x] **3. Lifecycle/preserved rendering** — implemented and new fault/reentry tests pass;
  additional U13 unsafe-demotion dispatch setup now expressly amended; validation resumes;
  ordinary pending-only frozen indicators;
  robust failure/supersession/invalid-source cleanup, no fresh/actions override; depends on2.
- [x] **4. Regression coverage** — primary conflict review complete; TWO narrowly scoped
  legacy blocks (expected preserved marker + unsafe fault dispatch) and new
  continuity runner; all old suites/workloads remain; depends on2+3.
- [x] **5. Full checks/docs/freeze** — serial new/existing suites, exact protected/preimage/
  diff/hash/Git report and focused native instructions; depends on4.

**Run state:** D1–D3 complete, independently statically reviewed and PRIMARY locally accepted.
No writer/children/check job or remaining local implementation blocker. Independent executable
verification remains INCOMPLETE/NOT RUN after denial; no bypass or evidence reattribution.
Prior C1–C3 delivery remains history; F3 final hashes/results below are the accepted targets.
Exact historical failures/provisional hashes/resume below. Historical511/512
and all red/fixture/fix chronology retained below. Final new suite PASS58groups/902323;
all final existing suites/proofs PASS, command results/frozen hashes below. Primary owns
focused native flicker follow-up; no further writer work without scoped correction.
Exact historical blocker/resume/partial hashes below. Original dispatch:
approved, primary repo-local snapshot verified before one synchronous
implementer dispatch; no children. Read-only packet `artifacts/r02-comparison/before-files.json`,
`preimage-paths.json`, `git-before.json`;4immutable preimages with `.md.preimage` backups.
Primary owns artifacts/contract/planning, writer owns ONLY listed Dashboard/SelfTests/new
runner/current README and R02execution fields. No competing edits while writer active.
P01–P03 accepted, not resumed; no install/Git/release/guide/new profession scope.

**PRIMARY dispatch snapshot verified:**161actual paths/4immutable local preimages,
10accepted P03 hashes unchanged; new runner absent. Packet ignored by existing .gitignore,
HEAD/index unchanged/cached diff empty. TASKS-only approval note finalized into manifest
before dispatch; no source edits/fresh full-suite/native run. One synchronous writer may
start piece1 after checking exact packet/base hashes; artifacts read-only to writer.

**R02 writer RUNNING2026-11-19, piece1:** read AGENTS/complete PLAN/active task/all8contract
sections; loaded agent-handoff and inspected approved runners/Python scripts. Read-only
snapshot comparison PASS161paths/4exact preimages/HEAD/NUL-stage/empty cached diff/new
runner absent. Fresh serial baseline (foreground timeout0, pipefail):
`lua5.1 tests/profession_completion.lua` PASS15/31244;
`lua5.1 tests/gathering_activation.lua` PASS12/13223;
`lua5.1 tests/profession_expansion.lua` PASS16/220990/all184/400/800rows;
`lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'` PASS512/all19
workloads5/10/2/2/K6=744/K7=565; `lua5.1 tests/run.lua` PASS23/23;
both Python commands PASS94Markdown/526links/8diagnostic hashes; `git diff --check` PASS.
No baseline failure, production edit, native run or Git mutation. Next: meaningful new red
tests for both decorations, then pieces2–5 serially; no blocker/job active.

**Piece1 red complete:** new runner first rejected fixture-only missing skillModifier and
then incorrect recharge-key spelling (not product evidence); corrected only new fixtures.
Final `lua5.1 tests/refresh_continuity.lua` on UNCHANGED Dashboard exits1:0PASS/2FAIL/
1935assertions, specifically pending dot hidden and pending estimate hidden after verified
initial completed indicators. Meaningful red for BOTH markers, no harness errors. Piece2
now executing private bounded cache/eligibility; piece3 lifecycle follows. No blocker.

**Pieces2–3 implemented / piece4 running:** private12visible cache installed only after
successful completed paint, guarded NEW preparation context/per-row Active+token eligibility,
exact successful Concentration provenance, distinct dot eligibility and frozen widget
preservation integrated with Retain/StopBuild/build/frame/Render cleanup. First new green
run PASS2groups/13067assertions. Additional fault/reentry/negative/read-bound coverage and
the single approved legacy marker adaptation remain next, then full suites/proofs/docs.
No unexpected legacy failure (not rerun yet), blocker or job active.

**R02 WRITER STOP — PARTIAL/BLOCKED2026-11-19:** piece1 complete; piece2 cache/eligibility
implemented, piece3 lifecycle implementation present but NOT fully validated; pieces3–5
blocked pending PRIMARY review of unexpected unchanged legacy failure. No additional old
test edits attempted. No independent remaining numbered piece (4depends2+3;5depends4).
Files changed: `CraftArmy/Dashboard.lua`, exactly one recoverable R02 block in
`CraftArmy/SelfTests.lua`, new `tests/refresh_continuity.lua`, R02 execution fields here.
Both READMEs remain unchanged. Comparison artifacts untouched; no install/native/Git
mutation/publication or children. Current source is provisional, NOT delivery/acceptance.

**Exact blocking command/result:**
`set -euo pipefail; lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'`
(foreground timeout0) exits1: **511passed/1failed**, failing case
`R01 lifecycle native enable state recovers and retained renders coalescence collect nothing`:
`CraftArmy/SelfTests.lua:13866: U13 failed marker must not remain current`.
All19U07workloads completed5/10/2/2. Runner exits before K6/K7 supplements on this failure;
post-change supplements therefore NOT RUN (baseline744/565 above remains baseline only).

**Conflict requiring PRIMARY review:** unchanged `U13 MARKER_NATIVE` block at13840–13872
injects faults/reentry into marker Hide/IsShown during `view:Refresh()`; it requires hidden
row/dot for faults and requires the injected boundary to execute for reentry. R02's explicit
eligible-dot no-Hide/no-reset preservation avoids those old demotion boundaries. Static
order indicates Hide/fault as first conflict, but the executable failure does not print
its boundary; no extra old-fixture instrumentation/rewrite was performed. PRIMARY must
review whether to authorize narrowly recoverable additional legacy adaptations (including
new independent fault/reentry coverage), or provide an in-scope correction satisfying BOTH
the unchanged tests and explicit no-Hide contract. Do not silently bless this failure.

**Chronology / unfinished validation:** initial two new meaningful red failures above;
after implementation, `lua5.1 tests/refresh_continuity.lua` PASS2groups/13067assertions
for ordinary unchanged dot+estimate callbacks/read-only46mixed schema2 fixture. Subsequent
small ownership/source/protected-read hardening was NOT rerun in the new suite before
the blocking legacy run; that green is preliminary, not a final-hash green. Full requested
negative/fault/reentry/read-bound/action-hover/ticker/scroll coverage remains unfinished.
No final P03/P02/P01/diagnostics/Python suites or README work performed after implementation;
all fresh baseline results above remain accurately attributed. Full native remains
INCOMPLETE87/149, all-rank UNVERIFIED, offline estimate accuracy unverified.

**Stop preservation proofs terminal PASS:** read-only Python stdlib plus Git queries:
all156protected originals of161 unchanged;4immutable preimages match manifest; whole
SelfTests reconstructs byte-exactly by reversing ONLY `R02 ADAPT U13_REFRESH` to embedded
ORIGINAL; all older markers inherently preserved. Both READMEs entirely byte-identical
(including historical suffix);9root/packaged icon pairs identical;162actual Git-listed
existing paths, sole new runner/no removals. HEAD remains
`5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`, NUL-stage SHA256 remains
`77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299`, cached diff empty.
`git diff --check` PASS. No artifact writes or external managed-log/path access.
Partial actual source/test/README diff, sorted4preimage-map paths with Python
`difflib.unified_diff(...splitlines(True),fromfile='R02-before/'+p,tofile='R02-after/'+p)`
then new runner `/dev/null` to `R02-after/tests/refresh_continuity.lua`, no separators:
31591bytes, SHA256`22cab454d6d19b00e4b4bfa2ae6eadead88de4f5f4cff4cfbe62a75c8cab0d2b`.

**Partial stop hashes (NOT final validated delivery):**
```text
3267a33763a2f6f5a76ccf77552d9a90fb74d078e3599812c5377dc0439fba90 CraftArmy/Dashboard.lua
d773e475db8eb87be199bcbe9126facfd00e662868ddfb7b0055f3b9002b0b9a CraftArmy/SelfTests.lua
0d6935d7623cf170c7a652b207cf35f936134f6e6127520e01ea46a4fdc6da33 tests/refresh_continuity.lua
318dbd74cc2c0cbe3a955548148019fdd172ab13d1657f726533103b9b9ab9dc README.md
91f11d8bcc0bf78f7ba96202ebe3062cebd4d3a75f2e8e32ba18e58b59f7ecfe docs/dashboard/README.md
```

**Exact resume point / remaining:** PRIMARY first reviews the additional legacy failure
and settles any scoped contract amendment/correction. Then one writer resumes piece3
validation and piece4: reproduce/resolve approved conflict without broader old rewrites,
rerun new green on current hashes, add ALL contract negative/fault/reentry/read-bound and
behavior regressions. Finish piece5 full terminal suites/docs/exact proofs/freeze before
independent verification/primary acceptance/focused native flicker check. No further source
work or reviewer acceptance requested on this provisional partial implementation.

**PRIMARY conflict review/amendment2026-11-19 (STATIC determination, no new test run):**
inspected exact U13 MARKER_NATIVE block and provisional continuity path. Hide/IsShown
subcases currently inject failures during unchanged Refresh, which intentionally avoids
demotion under the approved positive path. Keep original unsafe-demotion safety coverage
by forcing a changed-character filter ONLY in those two subcases before Refresh; keep
all8boundaries/two modes/fault code/assertions/frozen/newer-owner checks unchanged. Contract
now authorizes precisely one additional recoverable dispatch block, not expectation
relaxation, skipped scenario or runtime guard removal. Initial failed output did not print
the exact inner boundary, so it remains an observed511/512 plus static setup conflict,
not a retroactively passing test or an independently executed reproduction.

One synchronous writer resumes3–5: apply that exact second block, add ALL missing new
negative/fault/reentry/read-bound cases (including safe no-Hide and unsafe Hide/IsShown),
rerun current hashes/new suite and every final suite. Both previous greens and baseline
remain distinct. No wider scope/native/Git/install permission. Primary comparison resume
manifest `artifacts/r02-comparison/resume-files.json`; primary-only amended-document
attribution in `primary-amendments.json`. Original4immutable source preimages stay exact;
writer reads artifacts only. No source/test changes by primary during this pause.

**Writer resumed2026-11-19:** reread latest AGENTS/PLAN/complete amended contract/active
task, loaded agent-handoff. Exact162-path resume manifest/4original immutable preimages/
HEAD/NUL-stage/empty cached diff PASS. Applied ONLY authorized second recoverable
U13_MARKER_NATIVE_DISPATCH setup; all boundaries/modes/assertions remain. Resuming3–5;
no active blocker, children or background job. Original511/512 remains chronology.

**Resume validation / pieces3–4 RUNNING:** new runner on resumed hashes PASS2/13067;
legacy after exact second dispatch amendment PASS512/all19U07/K6=744/K7=565 (terminal,
foreground timeout0/pipefail). Expanded new suite first8PASS/3FAIL284176, then8/3/284177:
two fixture-target mistakes (first own row is Alchemy2906, not Inscription2913), plus real
explicit StopBuild leaving frozen decorations. Corrected new target fixtures; StopBuild
now revokes/demotes before Cancel callbacks. Next10/1/358301 exposed fixture-only ignored
observedAt input (Core successful times derive from attemptedAt); corrected fixture.
Added scalar row identity pins/provenance checks and pending-scroll cache revocation,
protected-read faults/reentry, native/widget/setup/step/batch/publication faults, source/
GUID/options/generation and action/hover/ticker/scroll matrices. Latest expanded run
20PASS/1FAIL577550: unknown fixture incorrectly retained prior known history (existing
normal completed behavior is intentionally unchanged); new unknown fixture now starts
without Concentration history. No old assertion changed beyond TWO approved blocks.
Next: rerun expanded suite and finish coverage/ownership audit, then piece5 full checks/docs.
No unresolved blocker or background job; previous failures remain chronology, not PASS.

**Further coverage chronology:** expanded21groups/590683 PASS, then23PASS/1FAIL606249
exposed genuine eligibility-read reentry overwriting a newer paint/status/hover/scroll
owner. Added preparation render/hover/scroll pins and newer normal-render ownership;
24groups/606237 PASS. Added preparation/coalescing visibility/safety/source-query faults
and Cancel/setup/Step/batch/publication reentry; first25PASS/1FAIL614913 exposed an
unprotected initial native visibility query. Protected coalescing/preparation visibility
and context checks; cleanup ClearScope/tooltip failures are isolated. Latest new runner
PASS26groups/625220assertions, all terminal foreground timeout0. No extra legacy edit.

**Continuation-state check after repeated resume request:** inspected actual files rather
than reapplying work. Exact156nonowned RESUME paths/4original immutable preimages/TWO-block
whole SelfTests reversal/HEAD/NUL-stage/empty cached diff PASS. Source/test work above was
already present; both READMEs still unchanged. Current new suite green is intermediate;
final serial suites/proofs/docs still pending. No usage-limit result treated as completion.

**Pieces3–4 complete / piece5 RUNNING:** added same-build native reentrant paint ownership
checks AFTER continuity validation, protected cleanup owner checks, exact active-identity/
generation negatives and completed-cache-failure tests. Latest focused new suite PASS
30groups/802890assertions; prior29/652552 also PASS. Post-hardening legacy rerun PASS512/
all19U07/K6=744/K7=565 before final small guard/refactor changes (final rerun still due).
Coverage includes every pending callback/no Hide/IsShown/reset on eligible markers,
12Active-read ceiling/coalescing/no eager iterator/whole-graph copy/acquisition/re-estimate,
46mixed rows/two own professions, full saved-root+old-row/fresh graph/token preservation,
provenance-only estimate rejection, all required unsafe/fault/reentry/action/hover/ticker/
scroll/reuse categories. Updated only approved README current status/dev and dashboard
intro beforeU15 with frozen-versus-fresh policy and focused flicker follow-up after local
acceptance; no repeated accepted profession checks. Next: final full serial suites to
terminal completion, whole-diff/static audit and exact preservation/hash/freeze report.

**FINAL R02 WRITER RUN STATE — COMPLETE2026-11-19:** all5pieces complete, no active job
or blocker. Implemented only private Dashboard paint/cache/continuity integration plus
TWO exact authorized SelfTests blocks, new standalone runner, approved README current/dev/
intro changes and R02 execution fields here. Comparison remains actual accepted UNCOMMITTED
P03, NOT HEAD. Original161-path packet/4immutable preimages remain exact/read-only; primary's
162-path resume packet protects its AGENTS/contract amendments and prior mixed TASKS
chronology. No other module/runner/fixture/tool/asset/primary document changed by writer.
Source/tests/READMEs now frozen; independent review and primary/native acceptance pending.

**Final serial terminal commands on frozen hashes below — all exit0:**
- `lua5.1 tests/refresh_continuity.lua` —30groups/802890assertions. Actual schema2 production
  driver,46mixed rows/12widgets/two own professions. Every pending callback preserves
  eligible frozen dot/estimate/label without Hide/IsShown demotion queries or geometry/
  label reset; unchanged and collector serial/revision/fresh invalidation, unrelated own/
  alt field updates and coalescing included. Eligibility reads exactly12Active maximum;
  coalescing/preserved Render add none. No eager iterator steps/whole-root/list/row graph
  copy, collector Scan/Context/Request, retained recomputation or extra own-GUID lookup;
  one pending Render clock plus existing job clock. Saved root/old rows/fresh graphs and
  both own tokens preserved. Source/GUID/options/generation/capability/status/time/build/
  currency/amount/cap/rate negatives, estimate-only provenance rejection vs identity dot,
  normal archive/unknown/N/A/observed0/full and invalid-rate semantics, retry/cache cleanup.
  Protected Active/Token/Revision/source faults, setup/Step/batch/scheduler/publication/
  render/clock/widget faults; eligibility/preserved-paint mutation and reentry, same-build
  native paint retirement, Cancel/setup/Step/batch/publication/newer hover/scroll ownership;
  unsafe Hide/IsShown boundary fault/reentry, early-label fault cleanup, pending historical
  hovers/actions/Details/confirmation/fresh-warning demotion, ready30second ticker/wheel/
  frame-coalesced drag/range/reuse all covered. All callbacks/timings remain synthetic.
- `lua5.1 tests/profession_completion.lua` —15groups/31244assertions/46mixed rows.
- `lua5.1 tests/gathering_activation.lua` —12groups/13223assertions/46active rows.
- `lua5.1 tests/profession_expansion.lua` —16groups/220990assertions; ALL unchanged original
  46/100/200character workloads complete184/400/800rows.
- `lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'` under
  `set -euo pipefail` —512/512original cases, ALL19U07workloads5/10/2/2, K6=744/K7=565,
  no runner/limit/coverage/order reduction. Earlier511/512 remains real historical failure
  resolved solely by primary-approved unsafe-demotion dispatch setup, not weaker assertions.
- `lua5.1 tests/run.lua` —23/23diagnostic cases.
- `python3 tools/check_dashboard.py` —PASS17required/exactTOC/94Markdown/529links/
  8diagnostic hashes unchanged; `python3 tools/check_diagnostics.py` —PASS9required/
  exactTOC/oneSV. Structural only, not Lua/client evidence.
- `git diff --check` —PASS. Heavy checks foreground timeout0, serial terminal completion;
  no polling, duplicate jobs, installations or external service/client execution.

**Final actual-diff/preservation proofs — PASS (read-only Python stdlib/Git queries):**
- All156nonowned RESUME paths unchanged, including both PRIMARY-only amended documents.
  Against ORIGINAL161baseline,154other protected paths unchanged plus exactly2attributed
  primary AGENTS/contract amendments. All4immutable preimage hashes match original manifest.
  Actual inventory162existing Git-listed paths = original161 + sole new refresh runner,
  no removals or post-resume additions. All9root/packaged icon pairs byte-identical.
- Whole SelfTests reconstructs by replacing ONLY `R02 ADAPT U13_REFRESH` and
  `R02 ADAPT U13_MARKER_NATIVE_DISPATCH` with embedded original payloads:
  SHA256`d16224d09a75536446f01389d621fe8272e0e98989cf26cfa6e872265752bbcf`.
  All earlier P01/P02/P03/Uxx marker bytes/helpers/assertions/matrices therefore intact.
  Original8boundaries/both fault+reentry modes/newer-owner/frozen checks retained.
- Dashboard README suffix from `# U15` onward byte-identical, preserving all old U13/R01
  history. Root README diff restricted to current-status/evidence/development lines;
  dashboard edits only current intro beforeU15. Source/README/marked-fixture actual diffs
  directly inspected; new630-line runner fully inspected through implementation/audit.
- HEAD unchanged `5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`; NUL-delimited index-stage SHA256
  unchanged `77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299`;
  cached diff empty. No commits/push/tags/Git mutations/publication performed or authorized.
- Deterministic complete actual source/test/README diff: sorted4preimage-map paths,
  Python `difflib.unified_diff(...splitlines(True),fromfile='R02-before/'+p,tofile='R02-after/'+p)`,
  then new runner `/dev/null` to `R02-after/tests/refresh_continuity.lua`, no separators:
  **81457bytes**, SHA256`8af2b076a873db0ea0c476f4373200422f242d089abba772a1562b2ca0f1389b`.
  Primary may generate its own review artifact from local immutable preimages; writer
  did not write artifacts or access/retry denied external managed logs/paths.

**Final SHA256 inventory —5frozen source/test/README targets:**
```text
52bc1d899078cf19968471f61709d707dee76b3abf07d842563e689f54973bf5 CraftArmy/Dashboard.lua
0caa9096efaaf98f1bdd79a8738bbc779489c7eced3b19189601734566e339c1 CraftArmy/SelfTests.lua
0b249b80389eca726456fd2fc2c63a547d1ba4c58a3cd5b08ac6910c3c4a5a34 README.md
8c25ebf2dfeb3955da6ca18e8a862d0abe8d6b5484b785ddaa7a8a9a9c5caf91 docs/dashboard/README.md
7d060a4044678c860781104f7068dbca790b1cfa04676212cff39bf5f78d489a tests/refresh_continuity.lua
```

**Remaining gates / exact next action:** PRIMARY dispatches independent read-only review
against ORIGINAL P03 preimages/new runner with RESUME primary-amendment attribution,
persists findings and owns acceptance. No remaining writer resume without an explicit
scoped correction. After local acceptance only focused ordinary dot/estimate flicker
follow-up per current README, not repeated profession reports/accepted checks, forced
scans, spending/training/gear changes or full native timing chase. Native trigger/frequency/
latency still unknown; full native INCOMPLETE87/149, all-rank costs UNVERIFIED and measured
offline estimate accuracy unverified. No native test, install, guides, new profession or
release/deployment scope. Implementation COMPLETE is NOT independent verification,
primary/native/global dashboard acceptance or release. Platform review N/A (no CI/hosting/
IAM/deployment changes). No writer/reviewer/check job remains active.

**Post-report stop check:** both Python structural commands again PASS94Markdown/529links/
8diagnostic hashes; whitespace PASS. Ending5delivery hashes/156protected RESUME paths/
4original preimages/TWO-block whole SelfTests reversal/README historical suffix/9icon pairs/
162inventory/HEAD/index/81457byte diff freeze all PASS after final report. New runner630lines.
No source/test/README drift or active job. Next action remains PRIMARY independent review.

**PRIMARY independent review disposition — CHANGES REQUIRED2026-11-19:** full-scope
read-only static review by verifier `ses_e0d090be5ffebV7zMDwmGouoeY` found two medium gaps:
F1 backward valid integer clock retains an estimate rejected by normal model; F2 ownership
pins stop before post-eligibility visibility/initial-paint callbacks, allowing old setup
to erase newer same-build paint/status/hover/scroll. Primary inspected cited paths and
confirms static gaps. [Full review/provenance](docs/dashboard/refresh-r02-review.md).
Reviewer shell denied on first command: independent execution/hash/preservation/end-freeze
checks NOT RUN/INCOMPLETE, no retry/bypass, no reattribution of writer/primary evidence.
First81457-byte diff/five hashes remain frozen first-delivery evidence, not accepted.

**Correction queue COMPLETE; no writer/children/check job:**
- [x] **C1. Rejecting regressions** — backward clock before Refresh/during pending Render;
  post-eligibility visibility and initial status/paint same-build reentry ownership.
- [x] **C2. Correct F1/F2** — corrected runtime/new tests and legacy matrices green; PRIMARY runtime-compatibility
  direction below resolves stop; existing shared clock, separate estimate/dot; retain exact
  preparation ownership through native callbacks/intentional mutations; depends onC1.
- [x] **C3. Full final suites/proofs/freeze** — all contract commands and reconstruction/
  protected/history/icon/inventory/Git checks, final actual diff/hashes; depends onC2.

Contract correction subsection is authoritative. Same writable files, no additional legacy
adaptation. Primary owns contract/review/comparison artifacts; original preimages immutable.
Primary correction-start manifest protects first delivery plus attributed primary doc
changes. One synchronous writer resumes C1–C3; independent reassessment/primary acceptance
remain separate. No native/install/Git/release/guide scope. Full native/accuracy limits intact.

**Correction writer C1 complete2026-11-19:** read latest instructions/active queue/full review
and complete amended contract; agent-handoff loaded. Read-only163path correction-start/
4original preimage/first81457byte delivery diff/HEAD/NUL-stage/cached diff verification PASS.
No primary source edits; SelfTests and both READMEs remain exact first delivery. Added only
new-runner regressions before runtime edits. First run31PASS/4FAIL813531: two F1 backward
clock failures and F2 status/paint failures; visibility fixture initially fired inside an
eligibility validation boundary (test harness targeting error), not after it. Corrected
standalone-only stack observation to exclude continuityCurrent as well as prepareContinuity.
Next run with `| tail -54` printed30PASS/5FAIL808610 (shell pipeline exit0 without pipefail,
NOT a PASS). Exact rejecting rerun `set -euo pipefail; lua5.1 tests/refresh_continuity.lua |
awk '/^(PASS|FAIL|R02 additive)/'` exits1:30old groups PASS,5meaningful new FAIL/808610assertions.
F1 beforeRefresh/duringRender keeps unsafe cyan; F2 post-eligibility visibility/initial
status/paint same-build reentry installs older job. No product edits or legacy edits yet.
Reproductions writer-attributed; reviewer executable work remains denied/NOT RUN. Next C2
shared-clock estimate-only rejection and exact preparation-owner accounting, then C3.

**C2 provisional implementation / required STOP2026-11-19:** F1 checks cached observation
time against the existing shared Render clock, rejects only estimate/approximate paint,
poisons only the private estimate-cache flag until normal publication, keeps identity dot.
F2 uses expected version/render/hover/scroll owner throughout synchronous preparation,
with explicit adoption ONLY at owned StopBuild/Retain/Render counter mutations; native
callbacks cannot silently rebaseline it. Job publication delayed until scheduler setup
returns under the exact owner. No source/model/math/timer-frequency changes outside
Dashboard. SelfTests and READMEs stayed byte-identical to reviewed first delivery.

First corrected new run34PASS/1FAIL830556: only the existing new-runner nil-clock subcase
still expected both decorations to disappear. Scoped that NEW-runner assertion to F1's
now-separated identity/estimate rule (no SelfTests change); no other old test relaxed.
Latest `lua5.1 tests/refresh_continuity.lua` PASS35groups/835482assertions, including ALL
five meaningful C1 red regressions now green. This is provisional writer evidence only.

**Unexpected unchanged legacy blocker — terminal command:**
`set -euo pipefail; lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'`
(foreground timeout0) exits1: **510passed/2failed**:
1. `R01 setup status Render widget and scheduler reentry retires old invocation without
   stale publication`: `CraftArmy/SelfTests.lua:5: 8 ~= 0`.
2. `R01 lifecycle native enable state recovers and retained renders coalescence collect
   nothing`: `CraftArmy/SelfTests.lua:13693: assertion failed!` (U13 timer query-ownership
   block's required `assert(fired)`).
All19U07workloads still completed5/10/2/2; runner exits before K6/K7, so correction-stage
supplements NOT RUN. No additional legacy adaptation/instrumentation attempted. Stopped
immediately per correction contract; PRIMARY must review these failures before further
runtime changes. First case's executable output does not identify its inner boundary.
Static inspection only: unchanged R01 block13103–13147 wraps Render as
`ui.Render=function(w) change(); return render(w) end`; timer block13665–13697 also wraps
Render. New optional owner arguments may not survive such wrappers. This is a review clue,
NOT a separately executed diagnosis or authority to change SelfTests. Preserve both
frozen legacy blocks and resolve runtime compatibility only after PRIMARY direction.

**Partial correction stop proofs — PASS:** read-only Python/Git verification of all158
protected correction-start paths (includes frozen SelfTests),4original immutable preimages,
both READMEs exact first delivery/old historical suffix, two-block whole SelfTests reversal,
9icon pairs,163path inventory/no additions/removals, HEAD/index/cached diff and first81457byte
delivery artifact. HEAD remains`5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`; NUL-stage SHA256
`77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299`; `git diff --check` PASS.
Only Dashboard/new refresh runner/R02 task-state edits changed during this correction.
Artifacts read-only/untouched; no denied-path retries, native/install/Git mutation/children.
Provisional complete actual diff against ORIGINAL P03 preimages plus new runner, using
same sorted4map/`R02-before/`→`R02-after/` difflib algorithm as first delivery:
**90252bytes**, SHA256`52ff860dce2e317dd22186a242f40ddcb49cf54102abec0323e8fdf76cd7ab5e`.

**Partial correction hashes — NOT final validated delivery:**
```text
9fb85eed1ab97a3cec691a4b26341e91d15adc1ea9cff11ea27c4448732ec4e7 CraftArmy/Dashboard.lua
0caa9096efaaf98f1bdd79a8738bbc779489c7eced3b19189601734566e339c1 CraftArmy/SelfTests.lua
0b249b80389eca726456fd2fc2c63a547d1ba4c58a3cd5b08ac6910c3c4a5a34 README.md
8c25ebf2dfeb3955da6ca18e8a862d0abe8d6b5484b785ddaa7a8a9a9c5caf91 docs/dashboard/README.md
8efd4526ffe6c449fdf68a58ed1e3fdf4c8583c253cc617dff69fbcff4960118 tests/refresh_continuity.lua
```

**Exact resume / remaining:** PRIMARY reviews unchanged legacy510/512 failures and provides
scoped runtime-compatibility correction direction (no broader test rewrite). Then one writer
resumes C2, adds focused regression as needed and reruns35new/legacy groups; complete C3's
ALL final serial suites/docs-if-needed/proofs/hash/freeze before independent reassessment.
No independent numbered correction piece remains executable because C3 depends on C2.
Correction-stage P03/P02/P01/diagnostics/Python/final full checks NOT RUN; previous first-
delivery passes are NOT corrected-hash validation. Reviewer executable verification remains
denied/NOT RUN, never reattributed. Independent review/primary/native acceptance still
pending; full native INCOMPLETE87/149, all-rank UNVERIFIED, measured offline accuracy unverified.

**PRIMARY legacy compatibility review2026-11-19 — STATIC, no fresh execution:** inspected
unchanged R01 setup matrix and U13 timer wrappers plus provisional owned Render path.
Both wrappers intentionally forward self only. Provisional preparation owner is passed
as a new Render argument, so a transparent wrapper drops it; Render increments its counter
without updating the intended preparation owner and setup then retires itself. This is a
runtime compatibility defect, not authorization to edit or relax old tests. Actual observed
result remains510/512; exact inner R01 boundary was not printed/executed in isolation.

Contract now directs private scoped one-shot owned dispatch, validated/consumed at method
entry, safely restored/retired around nesting. Preserve ordinary self-only public wrappers,
no universal ambient owner inheritance or post-callback rebaseline. New wrapper regressions
and all existing F1/F2 tests plus legacy matrices must pass. SelfTests remains byte-frozen.
One synchronous writer may resume C2–C3 after primary correction-resume manifest; no source
or test edits by primary during this pause. No broader authority or local/native acceptance.

**Compatibility resume2026-11-19:** loaded handoff/read latest primary direction/full contract
and task recovery; exact163path correction-resume/4original preimages/first-delivery diff/
HEAD/NUL-stage/cached diff PASS. Added self-only wrapper regressions BEFORE runtime edits:
`set -euo pipefail; lua5.1 tests/refresh_continuity.lua | awk '/^(PASS|FAIL|R02 additive)/'`
exits1:37PASS/3FAIL841321assertions. Meaningful new failures: ordinary wrapped Refresh
installs no job, wrapped timer recovery never ready, wrapped Refresh reentry replacement
never completes. Hide/source wrapper reentry safety already passes. All35existing groups
(including five F1/F2 regressions) still PASS. Next C2 one-shot private dispatch consumed/
validated at method entry, then full legacy and C3; no SelfTests edits or active blocker.

**C2 compatibility fixed / C3 RUNNING:** private one-shot dispatch tickets carry only the
intentional method owner/permit across original public signatures (Render self only,
Retain why, StopBuild self only). Production entry consumes before callbacks; nested
native Render does not inherit. Scoped restoration preserves an unconsumed outer ticket
so its stale owner is rejected, never blindly adopted; exception cleanup retires ticket/
eligible cache only while still owning preparation. Exact counter pins remain active
through all synchronous native/status/paint/setup callbacks; job installs atomically only
after scheduler setup returns owned. No SelfTests edit or parameter-forwarding requirement.
Intermediate new40groups/847711 PASS plus unchanged legacy512/all19/K6=744/K7=565 PASS
resolved previous510/512runtime regressions. Added original-signature Retain/StopBuild
wrapper, nested native same-build Render and pre-entry wrapper exception cleanup coverage:
43groups/857205 PASS before final small exception-cleanup assertion/runtime/docs changes.
All earlier35groups/five F1/F2 rejections remain. README current status/introduction now
explicitly describes backward/invalid estimate clock as estimate-only fallback; historical
suffix unchanged. Next C3 final ALL serial commands/preservation/hash/freeze on final files.

**FINAL CORRECTION RUN STATE — COMPLETE2026-11-19:** C1–C3 complete, no active job or
blocker; corrected delivery frozen for independent reassessment. F1 estimate-only backward/
invalid-clock fallback and nonrevival use the one existing Render clock, never recompute
retained predictions; valid dot remains independent. F2 pins exact synchronous ownership
through post-eligibility visibility/Retain/status/Render/setup, adopts only intentional
counter increments at their exact owned sites, then atomically installs the async job.
Private scoped one-shot dispatch preserves original public method signatures and consumes
before native callbacks; nested Render is not an inherited owner. SelfTests stayed frozen
at reviewed first delivery (only original TWO authorized adaptations). All first-delivery
and510/512/red/fixture/fix chronology above remains accurate, not retroactively PASS.

Correction changed ONLY Dashboard/new runner/approved README current-intro wording and
these R02 execution fields. Primary review/contract/AGENTS/PLAN/other paths frozen against
`artifacts/r02-comparison/correction-resume-files.json`. Original accepted UNCOMMITTED P03
161baseline/4preimages remain actual-diff base, NOT HEAD. First81457byte delivery.diff/
delivery-hashes.json preserved unchanged; writer created/overwrote NO comparison artifacts.

**Corrected final serial terminal commands — all exit0 on corrected hashes below:**
- `lua5.1 tests/refresh_continuity.lua` —**43groups/857241assertions**. All original30
  refresh groups retained; ALL5F1/F2 rejecting regressions now green, plus self-only normal
  refresh/timer recovery/Refresh-Hide-source reentry, all original public signatures,
  private one-shot nesting and exception cleanup. Original46mixed rows/12widgets/two own
  professions, exact12Active-read ceiling/no extra coalesced or preserved-render Active
  reads/no extra GUID or clocks/eager iterator/whole graph copy/acquisition/re-estimate,
  provenance/source/options/generation/action/hover/scroll/fault matrices retained.
- `lua5.1 tests/profession_completion.lua` —15groups/31244assertions/46mixed rows.
- `lua5.1 tests/gathering_activation.lua` —12groups/13223assertions/46active rows.
- `lua5.1 tests/profession_expansion.lua` —16groups/220990assertions, ALL original
  46/100/200character workloads complete184/400/800rows, unchanged fixtures.
- `lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'` with
  `set -euo pipefail` —**512/512**, ALL19U07workloads5/10/2/2, K6=744/K7=565, zero failures;
  frozen SelfTests/old runners/assertions/matrices/order/workloads/limits unchanged.
- `lua5.1 tests/run.lua` —23/23diagnostic cases.
- `python3 tools/check_dashboard.py` —PASS17required/exactTOC/**95Markdown/531links**/
  8diagnostic hashes; `python3 tools/check_diagnostics.py` —PASS9required/exactTOC/oneSV.
  Structural only, not Lua/native API evidence.
- `git diff --check` —PASS. Already-inspected installed runtimes only; heavy checks
  foreground timeout0, serial terminal completion/no polling/duplicates/installations.

**Corrected exact preservation/actual-diff proofs — PASS:**
- All**158protected correction-resume paths** hash-identical, including frozen SelfTests
  and primary review/contract amendments. All4original immutable preimages match original
  manifest. Actual163path Git-listed existing inventory exactly correction-resume, no
  additions/removals. Original161 + writer refresh runner + primary review document only.
- Whole SelfTests exact original P03 reconstruction by reversing ONLY U13_REFRESH and
  U13_MARKER_NATIVE_DISPATCH embedded R02 ORIGINAL blocks; original SHA256
  `d16224d09a75536446f01389d621fe8272e0e98989cf26cfa6e872265752bbcf`.
  Current SelfTests reviewed SHA256`0caa9096efaaf98f1bdd79a8738bbc779489c7eced3b19189601734566e339c1`
  unchanged throughout correction; all older markers/8boundaries/both modes untouched.
- README old suffix from `# U15` onward byte-identical; root README correction only
  current-status clock wording, dashboard correction only current intro clock fallback.
  All9root/packaged icon pairs byte-identical; source/new780-line runner changes inspected.
- HEAD still`5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`; NUL-stage SHA256 still
  `77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299`; cached diff empty.
  First-delivery81457byte diff SHA256`8af2b076a873db0ea0c476f4373200422f242d089abba772a1562b2ca0f1389b`
  and first five-hash artifact exact, not overwritten by corrected results.
- Corrected complete actual source/test/README diff against ORIGINAL P03, sorted4preimage
  map with `difflib.unified_diff(...splitlines(True),fromfile='R02-before/'+p,tofile='R02-after/'+p)`,
  then new runner `/dev/null`→`R02-after/tests/refresh_continuity.lua`, no separators:
  **96755bytes**, SHA256`04ea25a0be7c121a927a5edb241985903a72ec659b4fff8a26952e446b7faedc`.

**Corrected final five SHA256s — frozen for reassessment:**
```text
7f5ee85f046e40f193907ff773fcfb7cc7fdbe8058f7fee988ec21d4f86f658c CraftArmy/Dashboard.lua
0caa9096efaaf98f1bdd79a8738bbc779489c7eced3b19189601734566e339c1 CraftArmy/SelfTests.lua
19c49e2e4fedc59c8ecf9be4f1c3078cd5e053344210409f945e2fcd7baae7a9 README.md
c9eb7e0c3300e2e2cc8f876a8c1e5f0828f3f9d7f74d96e3181c478d5e4726fd docs/dashboard/README.md
8d41ba35f7221887fb328bdd5ff464c1173f61758bb5527122c6e9491e6ea4d6 tests/refresh_continuity.lua
```

**Exact next action / remaining gates:** PRIMARY generates any corrected review packet
from original preimages without overwriting first-delivery evidence, dispatches independent
read-only reassessment and persists findings before primary acceptance. No further writer
resume without explicit scoped correction. Reviewer's first shell denial remains independent
execution/hash/preservation NOT RUN; these corrected executions are WRITER evidence only.
No native/install/Git mutation/publication/release/guide/gear/spending work. Focused ordinary
dot/estimate flicker follow-up only after local acceptance; no repeated profession checks.
Full native INCOMPLETE87/149, all-rank costs UNVERIFIED, offline estimate accuracy unverified;
native refresh trigger/frequency/latency unknown. Correction COMPLETE is NOT independent
verification, primary/native acceptance or release. No writer/reviewer/check job active.

**Corrected post-report stop check:** both Python commands again PASS95Markdown/531links/
8diagnostic hashes and whitespace PASS. Ending5hash freeze/158protected correction-resume
paths/4preimages/frozen SelfTests/TWO-block reversal/README history/9icons/163inventory/
HEAD/index/first-delivery artifact/96755byte corrected diff all PASS after final report.
No source/test/README drift or active job; next remains PRIMARY independent reassessment.

**PRIMARY corrected-delivery reassessment2026-11-19 — CHANGES REQUIRED:** same verifier
reviewed full96755-byte corrected diff/new780-line runner/docs; F1/F2 statically addressed.
New medium F3: pre-entry owned Retain wrapper throws after eligibility arms continuity,
but ownedCall's exception cleanup handles only Render, leaving reusable failed-preparation
cache. Primary inspected cited paths and confirms static gap. [Review](docs/dashboard/refresh-r02-review.md).
Independent execution/comparison/end-freeze still NOT RUN after original denial, no retry/
bypass. Corrected43/857241/other suites are writer evidence, primary freeze separate.

**F3 queue COMPLETE; no writer/children/check job:**
- [x] **D1. Rejecting regression** — pre-entry Retain wrapper failure leaves no decorations/
  reusable cache, retry cannot revive before normal paint; newer-owner exception safety.
- [x] **D2. Owner-checked private cleanup** — failed owned method dispatch revokes cache and
  demotes without depending on throwing public wrapper; audit Render/StopBuild; depends onD1.
- [x] **D3. Full final checks/freeze** — all serial suites/preservation/diff/hashes, then
  independent reassessment; depends onD2.

Contract F3 direction authoritative, same ownership/no SelfTests edits. Primary F3-start
manifest before one synchronous writer. Prior delivery artifacts immutable. No primary
source/test edit, acceptance, native/install/Git/release/guide authority.

**D1 complete / D2 next2026-11-19:** read instructions/current queue/full reassessment/F3
contract; handoff loaded. Exact163F3-start paths/4immutable original preimages/HEAD/NUL-stage/
cached diff PASS. Added meaningful new tests BEFORE runtime edits. `set -euo pipefail;
lua5.1 tests/refresh_continuity.lua | awk '/^(PASS|FAIL|R02 additive)/'` exits1:
48PASS/4FAIL866302assertions. All43prior groups retained/PASS. Immediate unsafe-dot failures
for pre-entry Retain, pre-entry StopBuild and pre-entry Render whose public Retain cleanup
also throws; new same-build Render-wrapper reentry exposes old armed preparation later
clearing newer queued scroll (0vs2). Other5new throwing-reentry cases preserve newer state.
These are writer reproductions, NOT reviewer execution. No source/SelfTests/README edits
yet. Next private owner-checked production cleanup for all owned dispatch failures, exact
old-record retirement without demoting newer paint, then D3 full suites/proofs/freeze.

**D2 complete / D3 RUNNING:** all owned dispatch failures now use privately captured
production Retain cleanup, not the public throwing wrapper. Exact-current owners revoke
continuity/cache before any callback and demote through existing per-boundary guards.
Retired owners discard only their own still-armed private preparation/cache references,
never newer widget/hover/scroll/job/status state. Pre-entry StopBuild failure with previous
in-flight work also uses captured production StopBuild under exact ownership; cancellation
reentry cannot cancel newer replacement work. Public signatures/one-shot consumption,
F1 shared clock/nonrevival and F2 exact counter pins unchanged. SelfTests/READMEs untouched.
Chronology: initial new52groups/884049 PASS; added simultaneous throwing wrappers, post-entry
exceptions, cleanup native-reentry/early-widget faults:56groups/898383 PASS. In-flight
StopBuild audit then rejected with56PASS/1FAIL899375 (old job stranded). Private owned
cancellation cleanup corrected it; latest58groups/902323 PASS. Unchanged legacy512/all19/
K6=744/K7=565 PASS (terminal, pipefail/timeout0). No unexpected old failure or blocker.
Next D3 ALL final serial suites/proofs/hash/freeze; no artifact writes or background job.

**FINAL F3 RUN STATE — COMPLETE2026-11-19:** D1–D3 complete, no blocker/job. Generalized
failed owned dispatch cleanup uses private production Retain and, when previous in-flight
work remains owned, private production StopBuild. Reusable cache/continuity revoked BEFORE
cleanup callbacks; exact owner checked throughout protected/native demotion/cancellation.
Retired exception stacks discard only their own stale private preparation references,
never newer paint/cache/job/status/hover/scroll. Public wrappers may both throw without
being used for cleanup. Original signatures/one-shot dispatch/F1–F2 pins/shared clock/
bounded read semantics retained. Owned exceptions are rethrown, not swallowed into setup.
Changed during F3: ONLY Dashboard/new refresh runner/R02 execution state. SelfTests and
both READMEs byte-identical to preceding corrected delivery. No broader legacy edits.

**F3 final serial terminal commands — all exit0 on frozen hashes below:**
- `lua5.1 tests/refresh_continuity.lua` —**58groups/902323assertions**. All prior43groups
  retained; added pre-entry Retain/StopBuild/Render+throwingRetain immediate historical/
  observed-only fallback, cache nonrevival/retry/normal-paint recovery; throwing newer
  same-build/new-build ownership for all3methods; simultaneous public wrapper failures;
  post-entry exceptions; cleanup GetText/Hide/IsShown/SetText/source-check reentry and early
  label faults; old in-flight cancellation and newer replacement job/scroll preservation.
  Original46mixed rows/12widgets/two own professions and <=12Active eligibility reads,
  one-clock/no-acquisition/no-extra-GUID/no-retained-recompute guarantees remain tested.
- `lua5.1 tests/profession_completion.lua` —15groups/31244assertions/46mixed rows.
- `lua5.1 tests/gathering_activation.lua` —12groups/13223assertions/46active rows.
- `lua5.1 tests/profession_expansion.lua` —16groups/220990assertions; ALL original46/100/200
  character workloads complete184/400/800rows.
- `lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'` under
  `set -euo pipefail` —512/512, ALL19U07workloads5/10/2/2, K6=744/K7=565, zero failures.
  SelfTests/old fixtures/runners/assertions/order/matrices/workloads/limits unchanged.
- `lua5.1 tests/run.lua` —23/23diagnostic cases.
- `python3 tools/check_dashboard.py` —PASS17required/exactTOC/95Markdown/532links/
  8diagnostic hashes; `python3 tools/check_diagnostics.py` —PASS9required/exactTOC/oneSV.
  Structural only, not Lua/native API evidence.
- `git diff --check` —PASS. Inspected installed runtimes only, heavy checks foreground
  timeout0, all serial terminal completion/no polling/duplicate jobs/installations.

**F3 exact preservation/freeze proofs — PASS (read-only Python stdlib/Git):**
- All158protected F3-start paths hash-identical, including primary contract/review and
  frozen SelfTests; all4immutable ORIGINAL P03 preimages match original manifest. READMEs
  exactly preceding corrected delivery; dashboard suffix from `# U15` onward exact original
  history. All9root/packaged icon pairs identical. Actual163path Git-listed existing
  inventory exactly F3-start, no additions/removals. No comparison artifacts written.
- Whole SelfTests reconstructs original SHA256
  `d16224d09a75536446f01389d621fe8272e0e98989cf26cfa6e872265752bbcf` from ONLY original TWO
  R02 ORIGINAL/ADAPT blocks. Current reviewed SelfTests SHA256
  `0caa9096efaaf98f1bdd79a8738bbc779489c7eced3b19189601734566e339c1` unchanged.
- HEAD`5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`, NUL-stage SHA256
  `77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299` unchanged, cached
  diff empty. First81457byte delivery.diff/SHA8af2b076… and preceding96755byte corrected-
  delivery.diff/SHA04ea25a0… plus previous hash artifact unchanged, never overwritten.
- Complete actual P03-based source/test/README diff, sorted4preimage map using Python
  `difflib.unified_diff(...splitlines(True),fromfile='R02-before/'+p,tofile='R02-after/'+p)`,
  then new runner `/dev/null`→`R02-after/tests/refresh_continuity.lua`, no separators:
  **107335bytes**, SHA256`9967142bac4bab629f4ec83c62060a8d47e7000f04f96c6d9b7fafe362062806`.
  Current928-line runner/source changes inspected. Actual base remains accepted UNCOMMITTED
  P03, not HEAD; writer never accessed/retried denied external paths/managed logs.

**F3 final five target SHA256s — frozen for reassessment:**
```text
57bc8b30a2470d5ba6f2c00c197fdb717647979449256233e2a95d4ad1783d90 CraftArmy/Dashboard.lua
0caa9096efaaf98f1bdd79a8738bbc779489c7eced3b19189601734566e339c1 CraftArmy/SelfTests.lua
19c49e2e4fedc59c8ecf9be4f1c3078cd5e053344210409f945e2fcd7baae7a9 README.md
c9eb7e0c3300e2e2cc8f876a8c1e5f0828f3f9d7f74d96e3181c478d5e4726fd docs/dashboard/README.md
cad3b9cef20ebd41a4480cf537feb6de6ef29dc969e6b99c67dfe5edf0936878 tests/refresh_continuity.lua
```

**Exact next action / remaining gates:** PRIMARY prepares separate F3 review packet from
original immutable preimages, dispatches independent read-only reassessment and persists
findings before primary acceptance. No further writer resume without scoped direction.
All former red/510/512/first-delivery review chronology retained, not retroactive PASS.
Independent execution/comparison/end-freeze remains NOT RUN after reviewer's denial;
these executions/proofs are WRITER evidence only. No live WoW/install/Git mutation/
release/deployment/guide/spending/gear work. Native follow-up only after local acceptance;
full native INCOMPLETE87/149, all-rank UNVERIFIED, offline accuracy unverified and native
trigger/frequency/latency unknown. F3 implementation COMPLETE is not independent
verification, primary/native acceptance or release. No active writer/reviewer/check job.

**F3 post-report stop check:** both Python checks again PASS95Markdown/532links/8diagnostic
hashes; whitespace PASS. Ending5target hashes/158protected F3-start paths/4preimages/frozen
SelfTests+READMEs/TWO-block reversal/history/9icons/163inventory/HEAD/index/previous delivery
diffs/107335byte actual diff freeze all PASS after final report. No source/test/README drift
or active job; exact next action remains PRIMARY independent reassessment.

**PRIMARY persisted final independent reassessment2026-11-19:** verifier reports full-scope
STATIC PASS/no remaining findings on107335-byte F3 delivery; F1/F2/F3 statically addressed.
[Review and limitations](docs/dashboard/refresh-r02-review.md). Reviewer overall review
acceptance INCOMPLETE (PARTIAL handoff): all executable/comparison/end-freeze checks NOT RUN
after original shell denial; no retry/bypass or primary/writer evidence reattribution.
No static blocker. PRIMARY verified current5hashes/160unchanged F3-start paths/4immutable
preimages/TWO-block exact reconstruction/163inventory/HEAD/index/full actual diff before
dispatch. No writer or source/test/README drift reported; native acceptance still pending.

**Run state: PRIMARY final validation next, no writer active.** Inspect approved scripts,
run complete serial local suites on the reviewed hashes, retain distinct primary command
results, verify ending freeze and then make scoped local acceptance decision. No new native,
install/Git/release/guide/gear authority. Independent execution remains unavailable.

**PRIMARY local acceptance2026-11-19:** independent full-scope STATIC PASS/no remaining
findings plus separately attributed PRIMARY all9terminal serial commands on the reviewed
F3 hashes. Results: R02=58/902323; P03=15/31244; P02=12/13223; P01=16/220990 with all
184/400/800rows; legacy512/all19U07(5/10/2/2)/K6=744/K7=565; diagnostics23; bothPython
(95Markdown/533links/8diagnostic hashes) and whitespace PASS. Primary full stdout/results
retained in ignored `artifacts/r02-comparison/primary-final-01.log` through `09.log` and
`primary-final-results.json`. All5reviewed targets remained hash-identical across commands.
Primary first reconstruction checker had an indentation-regex error; corrected checker
passed exact TWO-block reversal with no source change. That checker failure is not a
product failure or hidden validation PASS.

Accept only the scoped local R02 implementation/corrections; reviewer execution/comparison
remains NOT RUN/INCOMPLETE after denial, never reattributed. Latest actualdiff107335bytes/
SHA9967142b… and five F3 hashes are accepted, not earlier deliveries. Platform review N/A.
Focused native check next: during ordinary dashboard refreshes, confirm the current-player
dot and visible cyan/approximate Concentration display no longer blink off and return.
No repeat profession checks/dumps, forced scans/reset/training/gear changes, full native
timing chase, installation or Git mutation. Native trigger/frequency/latency and measured
offline estimate accuracy remain unverified; full native INCOMPLETE87/149, all-rank UNVERIFIED.

**PRIMARY ending freeze PASS after acceptance docs:** five accepted hashes exact;
157other F3-start paths unchanged, with only attributed primary PLAN/AGENTS/review/TASKS
updates plus Dashboard/new runner changes. Four immutable preimages, TWO-block exact
SelfTests reversal, README historical suffix,9icon pairs,163inventory, HEAD/index/cached
diff, prior delivery artifacts and current107335-byte actualdiff exact. Accepted hashes
saved in ignored `artifacts/r02-comparison/accepted-target-hashes.json`. BothPython again
PASS95Markdown/534links/8diagnostic hashes; whitespace PASS. No writer/check job active.

### P03 — Profession N/A, colours, Deftness and gathering enchant warnings

**LOCALLY ACCEPTED2026-11-19 — independent STATIC PASS + PRIMARY full checks/freeze PASS.**
User explicitly approved implementing all four refinements.
Complete [P03 contract](docs/dashboard/expansion-p03-contract.md) is part of this handoff;
read all Goal/Why/Run state/Design/Files/Tests/Out of scope/Report back before executing.
At approval all9accepted P02 targets unchanged, new completion runner absent, no new Lua/
native execution/source edits. P01/P02 stay accepted, not resumed. No writer remains active.

- [x] **1. Baseline/rejecting tests** — verify primary actual-tree snapshot/preimages/Git,
  full existing serial baseline, meaningful new failures for approved behaviors.
- [x] **2. Exact data/Core changes** — secondary Moxie N/A;9tab colours; D key/category;
  gathering enchant eligibility enabled, secondary pending; depends on1.
- [x] **3. Secondary Moxie collection/model** — one collector N/A branch and existing
  ViewModel mask/cell/underlying-history integration, no Dashboard/storage edits; depends on2.
- [x] **4. Regressions** — exact marked old-fixture adaptations plus new completion runner,
  both storage facades/actual widgets/failed-read retention/mixed46coverage; depends on2+3.
- [x] **5. Full local validation/docs/freeze** — all existing/new suites serially, exact
  preservation/diff/hash report and focused user normal-use instructions; depends on4.

**Run state:** locally accepted; all5pieces complete, no writer/reviewer/validation job.
All4new-feature behaviors now user-confirmed; focused native acceptance complete. Local read-only comparison
packet: `artifacts/p03-comparison/before-files.json`,
`preimage-paths.json`, `git-before.json`; immutable9preimages (`.md.preimage` backups).
Primary owns artifacts/planning/contract; writer owns only contract-listed source/tests/
README changes and these P03 execution/report fields. No competing edits while writer
active. Remaining secondary-enchant uncertainty blocks only secondary warnings (excluded),
not this queue. No managed-log/external-path retry, native/install/Git/release scope.

**PRIMARY dispatch snapshot verified:**158actual existing paths,9immutable local preimages,
9accepted P02 target hashes exact; new runner absent. Existing .gitignore excludes packet;
HEAD/index unchanged/empty cached diff. Primary adds this approval note before finalizing
manifest (TASKS-only note delta); no source/test edit or fresh Lua/native execution.
One synchronous implementer may now start piece1 after verifying the complete packet.

**P03 implementer RUNNING2026-11-19, piece1:** loaded agent-handoff; read AGENTS/PLAN,
complete active task/contract and inspected all four existing Lua runners/both Python
scripts. Local read-only comparison PASS158actual paths/9byte-exact preimages/inventory,
HEAD/index unchanged, new runner absent. Fresh serial baseline (foreground timeout0):
`lua5.1 tests/gathering_activation.lua` PASS12groups/13223assertions;
`lua5.1 tests/profession_expansion.lua` PASS16/220754/all184/400/800rows;
`lua5.1 tests/dashboard.lua` PASS512/all19U07=5/10/2/2/K6=744/K7=565 (stdout-only awk,
pipefail); `lua5.1 tests/run.lua` PASS23/23; both approved Python checks PASS
(92Markdown/510links/8diagnostic hashes); `git diff --check` PASS. No baseline failure.
No production edits yet. Next: new rejecting fixtures for all four behaviors, then2–5.
No blocker or background job; artifacts remain untouched, no native/Git mutation.

**Piece1 red complete:** `lua5.1 tests/profession_completion.lua` against unchanged
production exits1:0PASS/4FAIL/4assertions, specifically secondary pending vs N/A,
gathering neutral vs blue palette, missing D key, gathering pending vs enabled enchant
eligibility. Meaningful expected failures, no harness errors. Now executing piece2.

**Piece2 complete:** exact Data policies/9native-tab colours/D key plus Core private
Deftness category/comment only. Piece3 executing the single collector branch and Moxie
mask/cell/underlying-history integration; all frozen modules remain untouched.

**Piece3 complete / piece4 running:** single N/A collector elseif, capability Moxie
mask/column/cell/history diagnostic integrated without storage/Dashboard changes. Applied
only listed recoverable P03 blocks: SelfTests3/P01fixture5/P02fixture2, preserving older
marker payloads; new coverage expansion next. No unexpected conflict or scope expansion.

**Piece4 interim chronology:** new completion suite13PASS/1FAIL22566assertions; both
old additive suites PASS12/13223 and16/220990/all184/400/800rows. New warning fixture
incorrectly expected unidentifiable existence failure to inherit prior equipment; existing
instance safety correctly clears that history. Changed ONLY new fixture to same-instance
loading, testing legitimate retained absence; no production guard change. Diagnostic rerun
with new-runner traceback confirmed same failure before correction. Next: green completion,
remaining coverage audit then piece5 full suites/docs/exact proofs. No job active/blocker.

**Piece4 green / piece5 running:** next new run13PASS/1FAIL22615 exposed a new-fixture
invalid raw-link seed (production correctly rejects accessory2 payload). Replaced it with
a valid ID0/typed-permanent-line conflict to exercise unknown enchant; no source change.
Then14groups/27316 PASS; added schema2 actual frame-driven widgets/reopen/archive/history
and independent timestamps/observed0/600/601 coverage: latest15groups/31244 PASS.
Both facades,9stable gathering colours/original palettes, D raw/neutral/instance/context
guards, actual reused Moxie/Tool/tree widgets, warning modes/old8 and mixed46rows covered.
Updated only approved README current/evidence/dev/introduction lines; historical suffix
unchanged. Next: full final serial checks, exact preimage/protected/Git/icon/diff/hash proofs.

**FINAL P03 IMPLEMENTER RUN STATE — COMPLETE2026-11-19:** all5pieces complete; no
blocker, remaining implementation work or running job. Actual accepted **uncommitted P02**
158-path baseline/preimages remain authoritative, NOT HEAD. Exactly9existing owned targets,
new `tests/profession_completion.lua` and this P03 execution/status/report changed. All
comparison artifacts remain read-only/untouched; no external-path/log denial retry or
writer-created evidence artifact. Earlier red/fixture failures above remain chronology,
not relabelled PASS. Production changes stayed within the exact4authorized modules;
Dashboard/Knowledge/Storage/KnowledgeCheck/Commands/Details and all unowned paths frozen.

**Final fresh terminal commands/results on delivery hashes below (serial, all exit0):**
- `lua5.1 tests/profession_completion.lua` —15groups/31244assertions; all four behaviors,
  exact capabilities/immutability/rejections/seven keys, schema1+schema2 own scans with
  nil/error/absent currency APIs skipped, successful N/A supersession vs read-only masking
  of unscanned/archived700/ID999/history/times, no Moxie sort/filter/green cue and nonmax
  secondary Skill retained. Actual reused Dashboard widgets on both facades, including
  actual bounded frame build/reopen/archive, concise normal N/A/Shift history, cleared D/
  colour/tree decorations. All9gathering colours with swapped order/identical names,
  exact old8palettes/unknown fallback and unchanged totals/ratios/graphs. D raw110 vs
  **synthetic fixture-only neutral79**, Tool-only D/source/time/older10red, D+F/P/zero/
  negative/malformed/nil/error/loading/missing API/arbitrary/changed instance/link/info/
  source/context guards. Gathering/secondary/old8 enchant observed0/empty-field/enchanted/
  unknown/loading/absent/conflicting evidence, fresh vs retained absence/archive exclusion.
  Mixed46old/new characters/46rows, current-first/dot/filter/sort/scroll and read-only DB.
- `lua5.1 tests/gathering_activation.lua` —12groups/13223assertions/46active rows; no
  helper/group/workload changes, only2authorized marked expectations.
- `lua5.1 tests/profession_expansion.lua` —16groups/220990assertions; ALL original
  46/100/200character workloads completed184/400/800rows. Only5authorized P03 blocks.
- `lua5.1 tests/dashboard.lua | awk '!/^PASS / || /U07 grouped scenarios/'` with
  `set -euo pipefail` —512/512original cases, ALL19U07workloads5/10/2/2, K6=744/K7=565,
  zero failures; no runner/limits/order/assertions/workload reductions.
- `lua5.1 tests/run.lua` —23/23diagnostic cases.
- `python3 tools/check_dashboard.py` —PASS17required/exactTOC/92Markdown/511links/
  8diagnostic hashes unchanged; `python3 tools/check_diagnostics.py` —PASS9required/
  exactTOC/oneSV. Structural only, not Lua/client evidence.
- `git diff --check` —PASS. Foreground timeout0; no polling/duplicate jobs/installations.

**Exact preservation/actual-diff proofs — PASS (read-only Python stdlib + Git queries):**
- All9immutable preimage hashes still match manifest. All148protected originals of158
  hash-identical; actual Git-listed existing inventory159, sole addition new completion
  runner, no removal. All9root/packaged icon pairs byte-identical. HEAD remains
  `5f98f5e6a5d74d53c7e487d810753f3ff7b9a661`; NUL-delimited stage SHA256 remains
  `77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299`; cached diff empty.
- Core exact whole-preimage reconstruction by removing ONLY P03 comment and
  `,Deftness=true`: SHA8d95fa3f740d0e474b941c23584994748c22c309e59ff85f7927497b0795db8a.
  Collectors exact reconstruction by removing ONLY the single N/A elseif line:
  SHAece23816e159301a79d4aa92e5f36154def23c5fe777a4dd329542d455ef9f39.
- Whole SelfTests reconstruction from3P03blocks U10_CATEGORY/E04_LABEL/E04_KEYS:
  SHAfd520e1c084139d10f6ecb29c7e0c7c6e824633193b6bfedaaad9be51b830a97.
  Whole P01 fixture reconstruction from5P03blocks CAP_MODES/STAT_KEYS/SCAN_FIELDS/
  MOXIE_HISTORY/TOOL_CATEGORIES:
  SHAe3664af689df0eeb764263fb4237dcd57474e9303e3dad14d83dc5163aa2718f.
  Whole P02 fixture reconstruction from2P03blocks DEFTNESS_KEY/UNSUPPORTED_CATEGORY:
  SHA93af470bc2df086b0afd5ead9082be3054d9ee501e5876fcece9ad61ec75841f.
  Older P01/P02/Uxx original-marker payloads remain verbatim; no old helper/workload edit.
- Dashboard README suffix from `# U15` onward byte-identical; root README diff restricted
  to approved current-status/evidence/development lines. Actual production/README diffs
  directly inspected; no other Core/collector/validator/neutral-query/accounting change.
- Deterministic complete actual diff: sorted9preimage-map paths using Python
  `difflib.unified_diff(...splitlines(True),fromfile='P03-before/'+p,tofile='P03-after/'+p)`,
  then new runner `/dev/null` to `P03-after/tests/profession_completion.lua`, concatenated
  without extra separators:57128bytes, SHA256
  `8851800df1c31e4cfe65da8bdea73c6e5d7763a5c394d598f201131efc630064`.
  Primary may generate its own local review diff/log packet from immutable local files;
  writer did not modify artifacts or depend on an external managed log.

**Final SHA256 inventory (10source/test/README targets frozen for review):**
```text
84d027fa52258ff0e4cec3d3da7b76a6a6b6251be8548af3fd77edd7dbde8dde CraftArmy/Collectors.lua
312842957fd79fc4065623ac32152735f4158413ad900f97d932496074a6a21e CraftArmy/Core.lua
86d1c054db540b5935a98c8437964e902f7d3d09df47daef86312091350cc01a CraftArmy/Data.lua
d16224d09a75536446f01389d621fe8272e0e98989cf26cfa6e872265752bbcf CraftArmy/SelfTests.lua
a866ff3b2a6859c03c5504fd8909290908f1067b5505faec73b84654f7565e97 CraftArmy/ViewModel.lua
318dbd74cc2c0cbe3a955548148019fdd172ab13d1657f726533103b9b9ab9dc README.md
91f11d8bcc0bf78f7ba96202ebe3062cebd4d3a75f2e8e32ba18e58b59f7ecfe docs/dashboard/README.md
0d118efcd06c36803df4a5146227d9e8ef84152b9c9808a82753fb309c981876 tests/gathering_activation.lua
437eccde30822846805f4560d3846e974d3ed4b68fe406a2c581a3d725a12912 tests/profession_completion.lua
0e4275dd3423952723b351401742c14be0f77929c5e2d9644b4631b93c0e1fba tests/profession_expansion.lua
```

**Remaining gates / exact next action:** PRIMARY dispatches independent read-only review
of these frozen10targets against actual P02 preimages and persists findings/attribution
before primary acceptance. No further implementation resume without explicit scoped
correction. After local acceptance, PRIMARY coordinates focused ordinary new-feature use
per README, not repeat reports/IDs/value interviews, old-profession retests or gear changes.
Cooking/Fishing enchant warnings remain pending; screenshot rawD110 is NOT separate native
neutral110/build proof. No native run, spending/training/gear swap, install, flicker/guide,
Git mutation/publication/release/deployment performed or authorized. Native suite remains
INCOMPLETE87/149, all-rank costs UNVERIFIED, measured offline estimate accuracy unverified.
Implementation COMPLETE is not independent verification, primary/native acceptance or release.

**Post-report stop check:** both Python structural checks again PASS92Markdown/511links/
8diagnostic hashes and `git diff --check` PASS. Fresh read-only byte-level Core/Collectors/
3fixture reconstruction,10delivery hashes/148protected originals/9immutable preimages/
README history/159inventory/9icon pairs/HEAD/index/57128byte diff freeze all PASS after
the final report. No source/test/README changes or active job; remaining action is primary
independent review dispatch, not further writer execution.

**PRIMARY P03 review packet frozen:** generated local `artifacts/p03-comparison/actual.diff`
from9immutable preimages/new runner:57128bytes/SHA8851800df1c31e4cfe65da8bdea73c6e5d7763a5c394d598f201131efc630064,
matches writer's actual diff. `delivery-owned-hashes.json` freezes10targets, all delivery
hashes match;148protected originals unchanged, sole new runner/no removals. No external
log/path access or retry. No writer/validation job active. Verifier may inspect full actual
diff/new runner/3+5+2adaptations/preimages and run approved serial checks; primary persists
read-only findings before acceptance. No CI/hosting/IAM/deployment scope; platform review
not applicable. No implementation/source changes while independent review runs.

**Independent P03 review persisted:** full811-line actual diff,442-line new runner,
3legacy/5P01/2P02adaptations and relevant preimages/interactions reviewed; STATIC PASS/no
confirmed findings. Overall independent verification INCOMPLETE after initial shell denial
(`permission.rejected: Permission denied: shell`); no retry/bypass. Independent executable/
hash/diff/reversal/protected/Git/end-freeze checks NOT RUN; writer/primary evidence not
reattributed. [Review](docs/dashboard/expansion-p03-review.md). No reviewer/writer active.
Primary next runs approved serial local suites and exact post-review proofs; acceptance pending.

**PRIMARY P03 LOCAL ACCEPTANCE2026-11-19:** independent full actual-diff/new-runner/static
review PASS/no findings plus separately attributed PRIMARY full serial terminal checks/
exact post-review preservation support scoped local acceptance. Independent executable
verification remains INCOMPLETE/NOT RUN after shell denial, never reattributed from primary.
No writer/reviewer active; broad native sign-off and publication not implied.

PRIMARY commands all exit0: P03=15groups/31244assertions/46mixed rows; P02=12/13223/46rows;
P01=16/220990/all184/400/800rows; legacy512/all19U07groups5/10/2/2/K6=744/K7=565;
diagnostics23/23; Python structural checks93Markdown/512links/8diagnostic hashes; whitespace.
Full stdout/results in local `primary-validation.log` and `primary-validation.json`.

PRIMARY post-review proofs PASS:10reviewed target hashes unchanged;3SelfTests+5P01+2P02
whole-file marker reconstruction; Core/Collectors/ViewModel/Data exact limited reversals;
148protected original paths, README history,9icon pairs,57128byte diff,160path inventory/
no removals and HEAD/index unchanged. Only new completion runner and primary review doc
added. `primary-preservation.json` records proofs, not independent reviewer execution.

Next user step: ordinary new-feature check (secondary Moxie dash, coloured gathering bars,
D recognition on existing Tool, appropriate gathering missing-enchant attention), not
repeated values/reports/old checks/newer gear/purchases/enchants. Cooking/Fishing warning
eligibility remains pending and disabled. Concentration flicker/guide work still deferred.
Primary-only status/evidence documentation follows;10implementation/test/README targets
remain frozen. Final structural/freeze evidence recorded at stop.

**Final PRIMARY stop checks:** both Python structural checks PASS93Markdown/518links/
8diagnostic hashes; whitespace PASS. All10reviewed targets unchanged at local acceptance;
142other original paths unchanged,7primary status docs explicitly updated;160paths/no
removals and HEAD/index unchanged. Local `accepted-owned-hashes.json`/`final-freeze.json`
retain accepted freeze. No source suites repeated for status-only docs; reviewed source
hashes remain identical. Independent executable verification remains NOT RUN.

### P02 — Verified gathering field activation

**LOCALLY ACCEPTED2026-11-19 — independent STATIC PASS + PRIMARY full checks/freeze PASS.** User answers “Yes”
to scoped P02 implementation and local tests after preparation. Complete
[P02 contract](docs/dashboard/expansion-p02-contract.md) specifies Goal/Why/Run state/
Design/Files/Tests/Out of scope/Report back; it is part of this handoff. At approval no
source/test changes or fresh Lua/native run. P01 stays locally accepted, not reopened.

**Goal:** activate verified gathering Moxie/Knowledge/unspent and F/P Tool stats; preserve
all five additions' safeguards/N/A and accepted crafting behavior. Cooking/Fishing Moxie,
Deftness and new enchant-warning eligibility remain evidence gaps, not blockers on P02.
Concentration flicker explicitly follows profession coverage, not this queue.

- [x] **1. Baseline and rejecting regressions** — primary repo-local actual-working-tree
  manifest/preimages supplied before dispatch; eight base hashes in contract, all11accepted P01
  source/test/README hashes unchanged at preparation; fresh full baseline and final results
  recorded below (the preparation-only NOT RUN state is superseded).
- [x] **2. Exact catalogue activation** — three Moxie/Knowledge tuples, F/P keys/categories;
  original-eight entries preserved; depends on1.
- [x] **3. Preserve collector safeguards** — decouple five-profession skill/cap, strict slot
  parsing and excluded-slot skip from Moxie pending-mode; four diagnostic text literals
  only to avoid obsolete inactive-field wording; depends on2.
- [x] **4. Regression adaptation/presentation checks** — exact marked legacy/P01 exceptions
  and new activation runner, both storage facades and UI/failed-read retention; depends on2+3.
- [x] **5. Full local checks and delivery docs** — serial complete existing/new suites,
  exact preservation/diff/hash report, focused native steps; depends on4.

**Original dispatch run state:** approved; primary freezes actual tree before dispatch to one synchronous
implementer for1–5, no children. Comparison manifest:
`artifacts/p02-comparison/before-files.json`; immutable8preimages mapping:
`artifacts/p02-comparison/preimage-paths.json`; Git freeze:
`artifacts/p02-comparison/git-before.json`. These are primary-owned, implementer/reviewer
read-only; do not edit or retry external P01 paths. README preimages use `.md.preimage`.
Writer must verify all hashes/manifest before edits and preserve all existing uncommitted
work. Primary does not edit assigned files/contract while writer runs.
Independent review and primary acceptance follow on frozen source. No install/Git/release
authorization. Remaining evidence questions are primary-owned subsequent work.

**PRIMARY preparation validation:** both Python structural checks PASS (90Markdown/
497links/eight diagnostic hashes); whitespace PASS; all8proposed owned-file hashes match
current files, all11accepted P01 source/test/README hashes unchanged; new runner absent.
Complete8-section contract checked. No fresh Lua/client execution; no implementation PASS.

**PRIMARY approval baseline verified:**155actual working-tree paths frozen;8immutable
repo-local preimages byte/hash verified,11accepted P01 targets unchanged; new runner absent.
Snapshot ignored by existing .gitignore; HEAD5f98f5e/index diff empty. Only primary approval
status notes in AGENTS/TASKS updated before finalizing manifest; no source/test changes.
One synchronous implementer may now start piece1 under the complete approved contract.

**P02 implementer run state — RUNNING2026-11-19, piece1:** read AGENTS/PLAN/TASKS and
complete P02 contract; loaded agent-handoff; inspected both Lua runners, P01 additive
runner and both Python scripts. Read-only local comparison verified all155 paths and8
immutable preimages exactly; new runner absent. Initial index comparison used non-NUL
`git ls-files --stage` and failed the manifest hash assertion (comparison harness error,
not tree drift). Correct `git ls-files --stage -z` matches SHA77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299;
HEAD5f98f5e6a5d74d53c7e487d810753f3ff7b9a661 and empty cached diff match. No Git mutations.
Fresh serial baseline, before production/test edits: `lua5.1 tests/profession_expansion.lua`
PASS16groups/219173assertions including184/400/800rows; `lua5.1 tests/dashboard.lua`
PASS512/512, K6=744/K7=565; `lua5.1 tests/run.lua` PASS23/23;
`python3 tools/check_dashboard.py` PASS90Markdown/498links/8diagnostic hashes;
`python3 tools/check_diagnostics.py` PASS; `git diff --check` PASS. Foreground terminal
completion, timeout disabled; dashboard stdout filtered only with `awk '!/^PASS /'`
and pipefail. No baseline product failures. Next: meaningful rejecting new fixtures,
then exact catalogue activation; remaining pieces2–5 not started. No blocker.

**Piece1 red / piece2 completed:** new `lua5.1 tests/gathering_activation.lua` before
production edits failed both groups meaningfully: pending Moxie mode vs enabled and
missing F/P key, exit1/2assertions; no harness error. Added only exact3 maps/provenance,
capability modes and2stat keys in Data, and Core's2private-map additions/comments.
Piece3 next: decouple the three preexisting safety paths; then marked fixture adaptations.
One rejected patch envelope (missing Begin header) changed no files; corrected immediately.

**Piece3 completed / piece4 running:** private exact-five-ID predicate now controls only
skill/cap, strict slot parsing and unknown-slot suppression after validated identities.
Four KnowledgeCheck literals replaced exactly; no accounting/storage/view/UI edits.
First combined collector/wording patch failed context matching atomically, changed no files;
read actual literals, reapplied successfully. Legacy5P02 marker blocks preserve original
bytes; P01 adaptation and new normalized36path projection coverage remain next.

**Piece4 interim validation chronology (terminal, no jobs active):** initial new suite
3PASS/1FAIL170assertions: fixture expected `enchantMissing=false` rather than legitimate
nil; changed to falsiness. P01 adaptation initially15PASS/1FAIL220509: fresh index is
observed even when default wrong-currency tree is nonnumeric. Corrected index expectation
and added explicit nonnumeric tree assertion, then corrected schema2's absent-last handling.
Second new run5PASS/3FAIL1325: attempted synchronous V.Build on schema2 handles; corrected
fixture helper to actual incremental NewBuildJob, no production bypass. Latest P01 runner
PASS16groups/220754assertions with all184/400/800rows unchanged. Latest expanded new runner
9PASS/2FAIL4548: timestamp seeding tried reapplying compact schema2 read-facade trees as
rich incoming payloads (Core correctly rejected tree:1107); seed now uses actual production
Knowledge acquisition/evaluation rich units. No production changes for these fixture fixes.
New coverage includes36paths/9trees, native rejecting mutations, both facades/reopen,
currency failures, exact skill/slot guards, Tool metadata/letters, actual reused widgets
and mixed46active rows. Continue piece4 to green, then piece5 full serial suites/docs/proofs.

**Piece4 green / piece5 running:** corrected rich schema2 seed via actual collector
Knowledge projection/evaluation; `lua5.1 tests/gathering_activation.lua` PASS11groups/
8239assertions, then expanded edge/context/currency/independent-unspent/F/P-widget and
original-eight preservation coverage: latest PASS12groups/12515assertions. Both terminal
foreground runs; no further failures. P01 fixture helpers/all16groups/workloads unchanged;
only11recoverable authorized P02 blocks adapted. Legacy5recoverable blocks adapted.
Updated only approved root README current-status/evidence/development lines and dashboard
README opening section before U15; no repeated gathering reports requested. Remaining:
full final serial suites, exact reversal/protected/inventory/icon/Git proofs and hashes.

**Piece5 first full run terminal PASS:** new12groups/12515, P01=16/220754,
legacy512/all19U07=5/10/2/2/K6=744/K7=565, diagnostics23, Python90Markdown/498links,
whitespace. Reversal/protected146of155/inventory156/9icon/HEAD/index proofs PASS. Actual
full diff inspection then found a *fixture coverage bug*, not product failure: Lua's
`condition and nil or bad` made unsupported mode perform a nil-returning read instead of
removing the API. Fixed explicit nil assignment and added assertions on actual unsupported
statuses, successful failed-read attempts versus discarded context drift, and nonobserved
retained-field attempts. Therefore earlier12515 count/hash is superseded, not final;
rerun all final serial checks and hashes on corrected fixture before delivery.

**FINAL P02 IMPLEMENTER RUN STATE — COMPLETE2026-11-19:** all5pieces complete;
source/test/README files frozen for independent read-only review. No remaining implementation
blocker or running job. Comparison base remains the actual accepted **uncommitted P01**
155-path tree, not HEAD; immutable8preimages and Git freeze remain in the original local
`artifacts/p02-comparison/` paths above, read-only and untouched. Exactly8existing owned
files plus new `tests/gathering_activation.lua` and these P02 task-state edits changed.
No other file was added/removed/edited. Earlier failures/coverage correction above remain
chronology, not retroactive PASS. No product defect required a change outside the contract.

**Final terminal commands/results on delivery hashes below (all exit0, serial):**
- `lua5.1 tests/gathering_activation.lua` —12/12groups,13223assertions,46active rows.
  Exact3tuples/old8preservation, all36normalized paths/9trees, shared totals69/81/61,
  both schema facades/scans/reopen/view,20failed-read/context modes per profession/facade,
  rank/coverage/currency guards, Skill/cap/slot safeguards, max0/nil/zero/600/601,
  independent Unspent, F/P optional metadata/history/letters and actual reused widgets.
  Reconstructed active/next/committed/definition metadata is explicitly fixture-only.
- `lua5.1 tests/profession_expansion.lua` —16/16groups,220754assertions; ALL original
  46/100/200character workloads completed184/400/800rows. Privacy/cancellation/reentry/
  bounded graph/clipping/read-only capture/scheduler/N/A tests retained.
- `lua5.1 tests/dashboard.lua` —512/512original cases in original order, ALL19U07workloads
  completed5/10/2/2, K6=744/K7=565, zero failures. Final command used stdout-only
  `| awk '!/^PASS / || /U07 grouped scenarios/'` with `set -euo pipefail`; no tests skipped.
- `lua5.1 tests/run.lua` —23/23diagnostic cases.
- `python3 tools/check_dashboard.py` —PASS17required/exactTOC,90Markdown/498links,
  8diagnostic hashes unchanged. `python3 tools/check_diagnostics.py` —PASS9required/
  exactTOC/oneSV. Structural checks only, not Lua/client evidence.
- `git diff --check` —PASS. Foreground execution with timeout disabled; no polling,
  duplicate background jobs, runtime/dependency installations or limit/coverage reductions.

**Final preservation and actual-diff proof — PASS:** read-only Python stdlib comparisons
against `before-files.json`/`preimage-paths.json`/`git-before.json` and actual sources:
- All146nonowned paths of155originals hash-identical; actual Git-listed existing-file
  inventory156, sole addition `tests/gathering_activation.lua`, no removals. All9original/
  packaged icon pairs byte-identical; HEAD5f98f5e6a5d74d53c7e487d810753f3ff7b9a661 and
  NUL-delimited stage SHA77498e5d3a974f6e3ec1569ccad73b7e463bb61826fefb75f8525bca5d489299
  unchanged, cached diff empty. Frozen Knowledge/Storage/ViewModel/Dashboard/Commands/
  Details/TOC/diagnostics/tools/assets/agents/archives/primary docs remain byte-identical.
- Core reconstructs byte-exactly by removing ONLY2map additions/comments:
  SHA7abc18c4b633d9df83b3877f389ad46305c4535106b4310ea433af630d11c515.
  All validators/schema/metadata slots/PIN/limits otherwise untouched. KnowledgeCheck
  reverses the4literal replacements to whole-file SHA8aaafdcb7b710214a725758d5253861ea0baa528f89ef3a649cf36c3454d3ea6.
  Additional full Collectors reversal removes helper/comments and3conditional substitutions
  to SHA453e70421a419fc730232f6debd07f9d5e1b17b325d8f49fd9dbe3a857912cd2.
- Whole SelfTests preimage reconstructs from5P02blocks: U10_CATEGORY, E02_PROVENANCE,
  E02_ACTIVE, E04_LABEL, E04_KEYS; original SHA21b0714639563d4fd543aa31262be9a95cc0f405d9e07bdc80058f58a642b263.
  P01 and all older original-marker payload bytes remain unchanged.
- Whole profession_expansion preimage reconstructs from11P02blocks: CAP_MODES, ACTIVE_MAPS,
  CRAFTING_LOOP, STAT_KEYS, SCAN_FIELDS, FAILED_READS, CAPTURE_FREEZE, CAPTURE_MAPS,
  TOOL_CATEGORIES, INDEX_FAILED_READS, INDEX_GRAPH; original
  SHA90bcad85b095aee1fac664a3df7769950054df6b4218c10bfe56b2bb0df67c66.
  Helpers,16group order and all original workloads are exact. Dashboard README historical
  bytes from `# U15` onward are exact; root README only approved status/evidence/dev lines.
- Deterministic full actual diff: sorted8preimage-map paths, Python
  `difflib.unified_diff(...splitlines(True),fromfile='P02-before/'+p,tofile='P02-after/'+p)`
  then new runner from `/dev/null` to `P02-after/tests/gathering_activation.lua`, concatenated
  without extra separators:71744bytes, SHA256
  `d05789f31bd8128f26b8f017eb2b652225eb5ef2116ad73b971fdc78144d260d`.
  Complete final diff plus proofs were printed by shell `sh_1f1d9098c001Cm5fhlllIkhYfN`;
  tool-managed output is
  `/home/arbixal/.local/share/opencode/shell/694064a96f35f065306fac92f7ed4af904f09058/sh_1f1d9098c001Cm5fhlllIkhYfN.out`.
  Dedicated read of that external managed log was denied `permission.rejected: external_directory`;
  did NOT retry/read it via another tool. Repository sources/preimages remained authorized;
  separate direct `sha256sum` and diff-hash computation confirmed the hashes/size above.
  No artifact writer/bypass or old external-snapshot retry. Primary owns any review artifacts.

**Final SHA256 inventory (9source/test/README targets):**
```text
ece23816e159301a79d4aa92e5f36154def23c5fe777a4dd329542d455ef9f39 CraftArmy/Collectors.lua
8d95fa3f740d0e474b941c23584994748c22c309e59ff85f7927497b0795db8a CraftArmy/Core.lua
92f1558492e65a769896841aa000a04d4aba672f3b7b6b4f09f22e89e5b66e15 CraftArmy/Data.lua
a292a4bf44699e5a711bc38af74fb6f1b503c2b27eadc9f2cb1385129ec1ae86 CraftArmy/KnowledgeCheck.lua
fd520e1c084139d10f6ecb29c7e0c7c6e824633193b6bfedaaad9be51b830a97 CraftArmy/SelfTests.lua
02e72c956e79ed00668826849d772e2b14d50418f0690027fe00155d1cef551e README.md
eda7e08277d52e37d811a2ca65d524d4d02b540763e97a6abe63539b6f2159ae docs/dashboard/README.md
93af470bc2df086b0afd5ead9082be3054d9ee501e5876fcece9ad61ec75841f tests/gathering_activation.lua
e3664af689df0eeb764263fb4237dcd57474e9303e3dad14d83dc5163aa2718f tests/profession_expansion.lua
```

**Remaining gates / exact next action:** PRIMARY dispatches independent read-only review
of these frozen9targets against the actual P01 preimages, persists findings and owns
acceptance/focused new-field normal-use coordination. No review/native/primary acceptance
or release is claimed by implementation COMPLETE. No install, Git mutation, live WoW,
SavedVariables/private snapshot access, spending/training/gear changes, flicker work or
guides performed. Deftness/secondary Moxie/new enchant warnings remain primary-owned
evidence gaps, not guessed activations. Full native stays INCOMPLETE87/149, all-rank costs
UNVERIFIED, measured offline estimate accuracy unverified. No new writer work remains;
resume only on a new explicitly scoped primary correction after review.

**Post-report stop check:** both Python commands again PASS90Markdown/498links/exact
packaging and `git diff --check` PASS; direct9delivery-hash/146protected-path/HEAD/index
comparison PASS after this report. No source/test/README drift or active validation job.

**PRIMARY review packet frozen:** generated local `artifacts/p02-comparison/actual.diff`
from8immutable preimages plus new runner;71744bytes/SHA d05789f31bd8128f26b8f017eb2b652225eb5ef2116ad73b971fdc78144d260d
matches writer's deterministic diff. `delivery-owned-hashes.json` freezes9target hashes;
all match delivery,146protected originals unchanged, no unexpected addition/removal. No
denied external managed-log access/retry; primary created these new local review artifacts.
Independent verifier may read these and original local comparison files, inspect full
actual diff/new fixture and run approved serial local checks after script inspection.
No active writer; no primary/source changes during review. Platform review not applicable
(no hosting/CI/IAM/deployment scope). Reviewer must return findings/attribution; primary
persists result before acceptance. No native or publication acceptance inferred.

**Independent P02 review persisted2026-11-19:** full1060-line actual diff/new runner/
5legacy+11P01adaptations and relevant production/preimages reviewed; STATIC PASS/no confirmed
findings. Overall independent verification INCOMPLETE after `permission.rejected: shell`;
independent Lua/Python/Git/hash/preservation/ending-freeze checks NOT RUN, no retry/bypass.
Primary/writer results not reattributed. [Review](docs/dashboard/expansion-p02-review.md).
No reviewer/writer active. Primary next supplies serial terminal local checks and exact
post-review preservation/freeze before acceptance; no acceptance claim yet.

**PRIMARY P02 LOCAL ACCEPTANCE2026-11-19:** independent full-scope STATIC PASS/no confirmed
findings plus separately executed PRIMARY terminal suites and post-review preservation
support local acceptance of the scoped P02 activation. Independent executable/comparison
verification remains INCOMPLETE/NOT RUN after shell denial; it is never reattributed.
No implementation writer/reviewer remains. Broad five-profession native acceptance pending.

PRIMARY serial results (all exit0, no source drift): new12groups/13223assertions;
P01=16/220754/all184/400/800rows; legacy512/all19U07workloads5/10/2/2/K6=744/K7=565;
diagnostics23/23; both Python structural checks (91Markdown/499links/8diagnostic hashes);
whitespace. Full stdout and command results are local `primary-validation.log` and
`primary-validation.json`, PRIMARY-attributed, not independent verifier evidence.

PRIMARY post-review exact proofs PASS:9delivered hashes unchanged;5legacy+11P01marked
blocks reconstruct whole preimages; Core private-map/comment, Collectors helper/3guards
and KnowledgeCheck4literal reversals exact;146protected originals, README history,
9icon pairs,71744byte actual diff and HEAD/index unchanged. Only new implementation
runner plus primary-owned review document added, no removals. Evidence local
`primary-preservation.json`. No denied external log/path retry or native execution.

Next: ordinary user-run new-field/dashboard normal use, retaining snapshots and unknowns;
no repeat reports/IDs/native number interview, old-profession retests or full native timing
chase. Deftness/Cooking-Fishing Moxie/new enchant-warning gates remain unresolved.
Primary current-status doc updates after this review freeze are documentation-only;
implementation7source/test targets remain frozen. Final doc checks/hashes recorded below.

**Final documentation addendum — independent STATIC PASS:** same verifier reviewed full
28-line acceptance-status-only README delta and current review wording; no findings,
no shell retry or independent hash/execution claim. Reviewed local `acceptance-docs.diff`;
`accepted-owned-hashes.json` freezes final9targets. Seven implementation hashes unchanged;
only2README status hashes supersede initial delivery:
README `e4047ac5a80a477c4be10a877276e4f34eb158a906023f9e097f8fc3a338a5b3`;
dashboard README `b01dae9537c813b116cd964bfe1130b28763de20675746eb4784f19a0fecb0cb`.
Primary inverse-delta proof reconstructs initial reviewed README hashes. No writer/reviewer
active; no further P02 executable piece or native/Git/release acceptance implied.

**Final PRIMARY stop checks:** both Python structural checks PASS91Markdown/504links/
8diagnostic hashes; whitespace PASS. Final9accepted hashes match,7reviewed implementation
targets unchanged;140other protected original paths unchanged,7primary status docs
explicitly updated;157paths/no removals, HEAD/index unchanged. Evidence `final-freeze.json`.
No full suite repeated for documentation-only status changes; source-suite results above
remain tied to identical reviewed implementation hashes. Independent execution stays NOT RUN.

### P01 — Capability-aware profession foundation and gathering evidence

**LOCALLY ACCEPTED2026-11-19 — independent STATIC PASS + PRIMARY checks/freeze PASS.**
Gathering reports/native value agreement received; broader native acceptance and activation
pending. No writer or further executable piece. Historical stops below
remain chronology, not current blockers or permission to resume implementation.
User approved “Use repo-local backup”: primary may copy the specific pre-writer150-path
manifest/nine preimages to ignored `artifacts/p01-comparison/`; implementer/reviewer may
read there. Original external-directory denial remains recorded, not retried by the writer.
One synchronous implementer is assigned the complete
[P01 contract](docs/dashboard/expansion-p01-contract.md), which is part of this handoff.
Read its Goal/Why/Run state/Design/Files/Tests/Out of scope/Report back before execution.
No code/test edits at approval; start with piece1 and freeze the actual working tree.
No historical queue authorizes execution; no native/Git/release authority implied.
Preparation checks: Python structural PASS86Markdown/474links and diagnostics packaging;
git diff whitespace,9writer-base hashes/frozen paths/navigation PASS. No fresh Lua/native run.
Primary pre-writer snapshot: `/tmp/opencode/craftarmy-p01-before-hmgp8x6w/`:
`before-files.json` freezes150original paths; `files/` has9exact owned-file preimages.
All9contract base hashes matched and new fixture path was absent. This is preparation,
not a fresh Lua baseline. Preserve all existing uncommitted planning/archive work.

- [x] **1. Baseline and rejecting regressions** — local comparison and fresh full legacy
  Lua baseline completed; new seven-group additive runner rejects unchanged production
  (six failing groups). Additional widget/edge coverage remains for final validation;
  retain all old correctness/stress workloads and existing selftest limits.
- [x] **2. Registry, explicit capabilities and guarded collection** — implemented with
  the exact Core26/27/28 metadataSlots exception; thirteen identities,
  secondary learned-presence checks, truthful N/A vs pending fields; depends on1.
- [x] **3. N/A dashboard behavior** — implemented; additive widget/history checks pass; depends on2;
  `—`, no field-specific attention/sort fabrication,
  unchanged accepted crafting layout/controls/normal-vs-Shift hovers; depends on2.
- [x] **4. Consolidated read-only gathering capture** — implemented; candidate/graph/clipping/
  scheduler/reentry/cancellation regressions pass;
  depends on2; extend the existing bounded
  knowledgecapture report with Moxie/skill/tool evidence for the three gatherers; depends on2.
- [x] **5. Full local checks and report** — all final commands terminal/PASS after the
  explicit E01 amendment:512/all19/744K6/565K7/23/additive/Python/whitespace;
  source-freeze/review-ready output, accurate
  README/status and focused native instructions; depends on3+4.

**P01 implementer run state — PARTIAL / stopped2026-11-19:** Read AGENTS, PLAN,
TASKS and the complete linked contract; loaded `agent-handoff`. Inspected both legacy
Lua runners, both approved Python scripts, Data and Collectors. Actual starting
`git status --short` shows the pre-existing planning/archive changes only.
`sha256sum CraftArmy/Data.lua CraftArmy/Collectors.lua CraftArmy/ViewModel.lua CraftArmy/Dashboard.lua CraftArmy/KnowledgeCheck.lua CraftArmy/Commands.lua CraftArmy/SelfTests.lua docs/dashboard/README.md README.md`
matches all9 contract hashes; `test ! -e tests/profession_expansion.lua` succeeds.
No implementation/test/doc changes other than these P01 execution-state edits.

**Initial blocker / historical stop:** The dedicated read of
`/tmp/opencode/craftarmy-p01-before-hmgp8x6w/before-files.json` was denied by the
permission boundary (`permission.rejected: external_directory`). Did not retry it
using shell/another tool or access the sibling preimages. Primary must supply an
authorized readable location for the existing150-path manifest and9 preimages,
or resolve that access permission before resuming piece1's required starting
freeze/comparison. No dependent production piece started. No independent numbered
piece remains executable under the contract's dependencies. All fresh baseline,
red/green Lua, Python, whitespace, asset-pair and final preservation checks are
**NOT RUN**; no fresh PASS/native/review/acceptance claimed. Retain INCOMPLETE87/149,
all-rank UNVERIFIED and offline estimate accuracy unverified. No Git mutations,
installation, external service or native execution performed. Remaining work is
all five pieces; resume with snapshot comparison, then fresh baseline/rejecting
regressions on unchanged production. No additional evidence artifact created.

**Primary access resolution2026-11-19:** User explicitly authorized primary copying this
specific comparison data into ignored `artifacts/p01-comparison/`, with read-only access
for implementer/reviewer. No broader permission or implementation-scope change. Primary
owns verification artifacts; writer does not modify them or access the old external path.
On verified copy, reset blocked pieces to unstarted and resume piece1's local comparison,
baseline and actual rejecting regressions. Retain the denial/stop chronology above.

**Copy verified / READY to resume:** original150-path manifest and9preimages copied
byte-for-byte into `artifacts/p01-comparison/`; owned sources still match their preimages.
`resume-files.json` freezes current150paths. Between original and resume manifests only
AGENTS, TASKS and the P01 contract changed for documented approval/access notes, all
primary-attributed. Use resume manifest for protected-file checks and immutable preimages
for source/test comparisons. Copy is ignored by existing .gitignore. No Lua baseline yet.
All five pieces reset to unstarted; one implementer resumes1, no active scope blocker.

**Previous implementer run state — PARTIAL / implementation stopped2026-11-19:**
The authorized local comparison succeeded: resume manifest150paths differs initially
only in TASKS (primary's later execution notes); all9 copied preimages matched current
owned files. No access to/retry of the denied external snapshot. Implemented initial
registry/capabilities, guarded presence-only secondary contexts, N/A/pending collection,
display masking and gathering-only candidate/stat reporting in the6 allowed production
files. No production currency/Knowledge/DFP mappings activated. New standalone regression
runner has7 groups; no old runner/cap/limit changes. No SelfTests adaptations yet; its
bytes still exactly match the copied preimage. READMEs unchanged pending safe completion.

**Exact blockers at that stop (resolved by primary amendment below):**
1. `Core.lua:284,317–319` validates optional gear metadata against a private20–25-only
   slot map. Contract requires26/27/28 in Data/helper but freezes Core. Actual Cooking
   scan now rejects `Invalid production field payload: accessory1` for slot27 optional
   expansion metadata. Primary must authorize the minimal Core named-slot allowlist
   extension or explicitly revise secondary optional-metadata collection. Writer did
   neither; do not silently omit required metadata/relax validation.
2. Legacy exact registry/exclusion expectations in SelfTests around7986–7988,8273–8283,
   8501–8503 and8776–8778 conflict with13 identities. Only dropdown/title/message
   adaptations are authorized. Primary must authorize narrowly marked registry-list/
   count/exclusion adaptations preserving original scenarios; no broad test edits made.
3. `python3 tools/check_dashboard.py` has a baseline failure: it includes the2 copied
   Markdown preimages under `artifacts/p01-comparison/files/` and reports38 broken local
   links there. Primary owns artifacts and tools are frozen: primary must resolve this
   validation-location issue explicitly. Writer has not edited/moved artifacts or tools.

**Actual validation so far (pure fixtures, never native evidence):**
- First combined baseline invocation timed out at120000ms before Lua output; NOT PASS.
  Rerun `lua5.1 tests/dashboard.lua` completed512/512, all19 U07 workloads in5/10/2/2
  groups, K6=744 and K7=565; `lua5.1 tests/run.lua` completed23/23. Both scripts were
  inspected. Baseline modules loaded before any production changes. Background baseline
  shell ID `sh_1eed77d02001xJMhxGGrAwRykF` retains full output.
- `python3 tools/check_diagnostics.py` PASS; `python3 tools/check_dashboard.py` FAIL38
  artifact-preimage links as above; `git diff --check` PASS. Both Python scripts inspected.
- Initial `lua5.1 tests/profession_expansion.lua` against unchanged production:1group
  PASS/6FAIL,22094assertions; missing capability function/unsupported family, missing N/A
  masking/gathering profile. All46/100/200 mixed workloads complete184/400/800rows.
- After initial implementation:6groups PASS/1FAIL,23705assertions (fixture incorrectly
  assumed unidentified absent-role gear inherits old instance). Removed that extra
  assertion, retaining the required unknown-not-empty/N/A assertion. Latest rerun:
  6groups PASS/1FAIL,23767assertions; real Cooking metadata/Core failure above. Mixed
  46/100/200 workloads complete. Further UI/reentrancy/clipping/preservation edge coverage
  remains; this is not a full final additive-suite PASS.
- Partial-source `lua5.1 tests/dashboard.lua` completed in background shell
  `sh_1eee00b3e001cfw9Nx3XXdLNov`:505PASS/7FAIL, exit1; all19 U07 workloads still
  complete5/10/2/2. Failures: R6 dropdown count14vs9; E01 exact8registry count/list
  (7986–7988); E02 exact8registry list/count/provenance and family exclusions; E03
  absent-gathering-family assertion; E04 exact8family list; U05 title wording in
  flat-chrome and toolbar cases. SelfTests remains unedited; dropdown/title adaptations
  are already authorized, registry adaptations need primary scope resolution above.
  The unchanged runner exits on failed top-level cases BEFORE K6/K7 supplements, so
  partial-source K6/K7 were NOT EXECUTED; baseline744/565PASS is separate, not final
  evidence. No production edits after launch; validation is now terminal, not running.
  Fresh final diagnostic/Python commands not rerun yet; baseline outcomes above remain
  separately attributed. Source is frozen as partial/blocked, not review-ready complete.
- Partial freeze comparison: all140 protected original paths byte-identical to resume
  manifest; only6owned production paths plus TASKS differ among original150. All9
  original/packaged icon pairs byte-identical. New fixture is the only writer-added path.

**Partial delivery SHA256 (not an accepted final revision):**
```text
5879e656365faf6338afdb83d11703e593e75643338557cd16f48545583a81c7 CraftArmy/Collectors.lua
4c5656421251b15553885e2e2a5a4ec78a5774e239fc7c95a01acc44d223488e CraftArmy/Commands.lua
4f6f1a1229ffa07b1bd8f361198e67a3525ed7b6859b8298c24f6fe4b227c99e CraftArmy/Dashboard.lua
58163fefaca262db4fcbd6a10695c29020b1dcfbdf03cb7fd75bb4b04f966e43 CraftArmy/Data.lua
c2822242a7dfe28968dc429ecb01a04fe9900b9187caf050d997d911d8cae68d CraftArmy/KnowledgeCheck.lua
75e42dc9e0b836d9048b84ffe73ec49a780100aedbbbde9088545ee1d4189cbd CraftArmy/ViewModel.lua
760fa8a0eabcd4a0f48f69e5957b74f42c8b39849fc7a263be4b27cdec43224b CraftArmy/SelfTests.lua
dacf53044831db59455c79bfd3c9f6d067b7549fc471bae4acd0e8823e742a58 README.md
7ec2c6ae4b112f52d71ce4c38c68e1f061532f4a8f34538cc884b7533f16d605 docs/dashboard/README.md
4e56461b27c4ad0613e8bfbd7cea939db03b54f4ec5c02fe058d1569ce18fe87 tests/profession_expansion.lua
```
Exact resume: primary resolves the3scope/validation items above, then implementer
resumes piece2's secondary metadata failure and completes3/4/additive coverage/docs
and all final checks. No commits/push/install/native/API/gameplay actions performed.
Native suite INCOMPLETE87/149, all-rank UNVERIFIED and offline estimate accuracy
unverified remain unchanged. Independent review/primary acceptance have not occurred.

**Primary scope/validation resolution2026-11-19:** complete contract now has an explicit
three-item amendment. Core may add only named metadataSlots26tool/27accessory1/28tool,
plus a P01 comment; no other Core byte/rule/category/currency/schema change. Writer must
add excluded-slot/wrong-role/malformed metadata regressions and exact Core-preimage proof.
The three original E02/E03/E04 registry-only expectation blocks may enumerate verified
13families/identities while preserving all original rejection fixtures, original eight
provenance,8active Moxie,4stat keys,512cases and all workloads. No broad test rewrite.
Primary renamed only the two copied Markdown README backups to `.md.preimage`, exact
bytes/hashes unchanged. They are not project docs; checker/tools/real-doc coverage stay
frozen. All10immutable source/docs preimages (including original Core) are mapped by
`artifacts/p01-comparison/preimage-paths.json`. No external read/retry or writer artifact
edits authorized. No production edits during this pause; primary updated AGENTS, this
contract and TASKS plus local verification artifacts, all explicitly attributed.
`artifacts/p01-comparison/amended-resume-files.json` now freezes151paths (the150original
paths plus new fixture); original10preimages remain authoritative for full code diffs.
`primary-amendments.json` attributes the changed primary documents and artifact corrections.
Before any production edits, writer must acknowledge prior partial-source suite's terminal
result from its automatic completion notification; no polling/duplicate suite. Resume2
then3/4/additive coverage/docs and all final checks. Previous failures/denials retained.

**Amended implementation2026-11-19 — PARTIAL; source edits frozen; validation terminal:**
Before writing production, implementer consumed/acknowledged the automatic terminal result
of `sh_1eee00b3e001cfw9Nx3XXdLNov` (505/7, all19workloads; K6/K7 not reached), already
recorded above. Amended151-path manifest initially differed only in TASKS (primary's later
pointer update). All10 immutable preimages were read locally; Core original hash matched.
No denied external-path retry or artifact edits. Completed the exact Core slot additions,
new-profession guarded collection, N/A UI/history masking and bounded gathering capture.
Added detailed regression groups and updated both READMEs with pending native gates and
focused own scans/three read-only captures; no training/unlearning/spending/gear swap.

**Remaining permission gap:** the original E01 exact-eight identity-map assertion at
SelfTests7986–7988 failed in the recorded partial suite, but the amendment explicitly
permits only the named E02/E03/E04 registry blocks. E01 remains untouched. Primary must
authorize that exact list/count adaptation preserving its eight originals and all unknown/
conflicting identity rejections. No workaround, suppressed scenario or weakened count.

Expanded `lua5.1 tests/profession_expansion.lua`:16groups PASS/0FAIL,218553assertions
before the final source freeze, including full8tabs×64paths capture/clipping,32stat-key
boundary, malformed/oversize/missing/error APIs, unsafe/changed contexts, direct job and
command cancellation/reentry, read-only runtime graphs, both storage facades, prior indexed
tree times, excluded slots/wrong roles/unready metadata, reused widget cleanup/native-only
normal gear and full Shift history, filters/current grouping/scroll/range and mixed
46/100/200characters. No original workload replaced. A subsequent fixture-only addition
verifies preexisting DB edges immediately before intentionally adding a history owner.

Final exact-source commands ran serially in background shell
`sh_1f0b7f79e001E9VDe0oelfp2XI`: additive suite; legacy suite (stdout filtered with awk
only to omit routine PASS lines, pipefail retains its exit); diagnostic suite; both Python
checks; whitespace. Each command exit was printed. Its automatic completion notification
was consumed before delivery; no polling/duplicate suite. No production/test/README edits
after launch. No validation job remains running. Final overall PASS is NOT claimed.

**Terminal results on the frozen hashes below:**
- `lua5.1 tests/profession_expansion.lua`:16groups PASS/0FAIL,219173assertions, exit0;
  mixed46/100/200character workloads completed184/400/800rows; no skipped groups.
- `lua5.1 tests/dashboard.lua`:511PASS/1FAIL, exit1; all512cases executed and all19 U07
  workloads completed5/10/2/2. Sole failure is E01's obsolete exact-eight identity map
  (current assertion7992; original7986–7988). The8 authorized adaptations pass. Unchanged
  runner exits before K6/K7 on a failed top-level case: final K6/K7 NOT EXECUTED. Earlier
  fresh baseline744K6/565K7PASS remains baseline evidence only, not a final PASS.
- `lua5.1 tests/run.lua`:23/23 PASS, exit0.
- `python3 tools/check_dashboard.py`:PASS, exit0;86Markdown/475local links/anchors,
 17required files/exactTOC and8diagnostic hashes. Primary's backup renames resolved the
  historical38artifact-only broken links; real checker and coverage remain unchanged.
- `python3 tools/check_diagnostics.py`:PASS, exit0;9required files/exactTOC/oneSV.
- `git diff --check`:PASS, exit0. Python checks are structural, not Lua/client proof.
  Complete concise output is retained by shell `sh_1f0b7f79e001E9VDe0oelfp2XI` at
  `/home/arbixal/.local/share/opencode/shell/694064a96f35f065306fac92f7ed4af904f09058/sh_1f0b7f79e001E9VDe0oelfp2XI.out`.
  No writer-created/modified verification artifact or source changes after this run.

**Preservation proof at freeze:** all139 protected paths in the amended151-path manifest
are hash-identical; no added/deleted paths since that manifest. Compared to original150,
the fixture is the sole writer-added path. Ten source/docs originals plus fixture and TASKS
are the full writer scope; Commands/Dashboard retain their earlier partial-source hashes.
All9 original/packaged icon pairs remain byte-identical. Core reconstructs byte-exactly
after removing the P01 comment and three metadataSlots entries; every other Core byte,
including validators/stat categories/native currency mappings, is unchanged. Commands
reconstructs exactly by reversing its capability eligibility check and two wording changes;
scheduler/clocks/limits/selftest logic are untouched.

**Legacy assertion proof:**8 P01-marked adaptations reconstruct the entire original
SelfTests preimage byte-for-byte (SHA760fa8a0eabcd4a0f48f69e5957b74f42c8b39849fc7a263be4b27cdec43224b):
`DROPDOWN` (9→14), `E02_REGISTRY` (exact13tuple/family lists/count/provenance; old8 and
activeMoxie8 intact), `E03_FAMILIES` (known new labels; unknown tuple rejection intact),
`E04_LABEL` (obsolete no-gathering wording only), `E04_REGISTRY` (13families/skill lines;
4stat keys and all rejection checks intact), `FALLBACK_TITLE`, `TITLE`, `TOOLBAR_TITLE`
(only crafting→profession text, dimensions unchanged). No original cases removed or
added; all512 and19workloads retained. Existing runner/K6/K7 files are protected unchanged.

**Frozen source hashes (terminal results above; partial delivery, not accepted):**
```text
453e70421a419fc730232f6debd07f9d5e1b17b325d8f49fd9dbe3a857912cd2 CraftArmy/Collectors.lua
4c5656421251b15553885e2e2a5a4ec78a5774e239fc7c95a01acc44d223488e CraftArmy/Commands.lua
7abc18c4b633d9df83b3877f389ad46305c4535106b4310ea433af630d11c515 CraftArmy/Core.lua
4f6f1a1229ffa07b1bd8f361198e67a3525ed7b6859b8298c24f6fe4b227c99e CraftArmy/Dashboard.lua
ffa36e82ded170e094045bed94f08ac97f821312b94319c708cb6d066b99de7d CraftArmy/Data.lua
8aaafdcb7b710214a725758d5253861ea0baa528f89ef3a649cf36c3454d3ea6 CraftArmy/KnowledgeCheck.lua
1fbd04e18e7408c575b4200320a354838c106357d9bcd4d9834a4b0bdf1ea309 CraftArmy/SelfTests.lua
366bde4db3f688c1d769370c79b1c4688123a78a3f2afc5422562a7fc881a533 CraftArmy/ViewModel.lua
19f9598cd3ab165564e08b96fcb99ebda0354e291451355a95894672e88399ca README.md
e72fa0c8494eddf8c887f1bad906a4d2137d7e726dd5981130449319d7e0d7c4 docs/dashboard/README.md
90bcad85b095aee1fac664a3df7769950054df6b4218c10bfe56b2bb0df67c66 tests/profession_expansion.lua
```
Current exact resume: primary authorizes the missing E01 original7986–7988 map/list/count
adaptation (13registered IDs, retaining all8 originals and every following unknown-identity
rejection), then writer performs that marked adaptation and reruns all full final checks
through512/all19/744K6/565K7/23/additive/Python/whitespace to completion. Feature code,
regressions and READMEs are otherwise delivered within scope; no independent review or
primary acceptance yet. NativeINCOMPLETE87/149/all-rankUNVERIFIED/offline
accuracy unverified and review/acceptance/publication gates are unchanged. No active
currency/accounting/DFP mapping, Git mutation, install or native/gameplay action added.

**Primary final-registry permission2026-11-19:** inspected original SelfTests7986–7988:
it enumerates Data.expansions, not an unrelated8-count invariant. Authorize ONLY adding
five verified IDs/13count there, P01-marked, preserving the surrounding E01 identity/Moxie
checks and following unknown/base-ID rejection loop. Contract/AGENTS updated accordingly.
No other source or test-scenario permission change. Resume this exact adaptation and
rerun all final suites to terminal results; independent review remains next, not granted.

**FINAL IMPLEMENTER RUN STATE — COMPLETE2026-11-19 (implementation/local tests only):**
All5pieces complete. Final approval snapshot
`artifacts/p01-comparison/final-registry-approval-files.json` matched all151paths before
the last edit. Applied only `E01_REGISTRY` to the original7986–7988 list/count: added
2908/2911/2912/2916/2917, count13, retaining the original8 and every surrounding identity,
Moxie, synthetic-unknown and base-ID check. No feature source/regression/README changes
at this last resume. All earlier denial/timeout/red/505and511 failure chronology above
is retained and is not relabelled PASS.

**Final terminal validation on exact delivery sources (all exit0):**
- `lua5.1 tests/profession_expansion.lua` —16/16groups,219173assertions; mixed46/100/200
  workloads completed184/400/800rows. No skipped additive group; pure fixtures only.
- `lua5.1 tests/dashboard.lua` —512/512 original cases; ALL19 U07 workloads completed
  in unchanged5/10/2/2groups; K6=744checks and K7=565checks, zero failures.
- `lua5.1 tests/run.lua` —23/23 diagnostic cases.
- `python3 tools/check_dashboard.py` —17required files/exactTOC;86Markdown files,
 475local links/anchors;8diagnostic hashes unchanged. Structural only.
- `python3 tools/check_diagnostics.py` —9required files/exactTOC/oneSV. Structural only.
- `git diff --check` —PASS. No raised limits/reduced workloads, installations or client
  execution. All commands ran serially to terminal completion in one foreground invocation
  with timeout disabled; ordinary legacy PASS lines were filtered only on stdout, with
  pipefail preserving its status. No validation/background job remains running.

**Final exact preservation proofs — PASS:**
- All139 protected files hash-identical to the final-registry approval manifest;151-path
  inventory unchanged. Compared to original150paths, only the new fixture is added.
  Primary-owned approval docs/artifacts stayed untouched by the writer. All9 root/packaged
  asset pairs remain byte-identical and their protected manifest hashes unchanged.
- Full SelfTests original bytes reconstruct exactly from9 marked adaptations:
  `DROPDOWN`, `E01_REGISTRY`, `E02_REGISTRY`, `E03_FAMILIES`, `E04_LABEL`, `E04_REGISTRY`,
  `FALLBACK_TITLE`, `TITLE`, `TOOLBAR_TITLE`. The8 earlier adaptations are enumerated above;
  E01 is the sole final addition. Reconstructed SHA is the original
  `760fa8a0eabcd4a0f48f69e5957b74f42c8b39849fc7a263be4b27cdec43224b`.
  All512cases/order/scenarios retained; old runners, K6/K7 and U07 workloads unchanged.
- Removing only the P01 comment and26tool/27accessory1/28tool entries reconstructs ALL
  original Core bytes exactly (SHA65b5b05b82a8f9155b4abb51b5c98f825926753db9d2911babddf866e3146253).
  Other validators/categories/native-currency maps/schema remain frozen. Commands exact
  reconstruction removes only capability eligibility and two wording changes; all other
  bytes, scheduler/clocks/limits/selftest behavior are original.
- Immutable original preimage locations remain in
  `artifacts/p01-comparison/preimage-paths.json`; final protected snapshot is the local
  `final-registry-approval-files.json` above. No external-path retry or artifact writes.

**Final writer inventory / SHA256:**8existing Lua files,2existing READMEs,1new fixture
and this task's execution state only. All11 source/test/doc hashes:
```text
453e70421a419fc730232f6debd07f9d5e1b17b325d8f49fd9dbe3a857912cd2 CraftArmy/Collectors.lua
4c5656421251b15553885e2e2a5a4ec78a5774e239fc7c95a01acc44d223488e CraftArmy/Commands.lua
7abc18c4b633d9df83b3877f389ad46305c4535106b4310ea433af630d11c515 CraftArmy/Core.lua
4f6f1a1229ffa07b1bd8f361198e67a3525ed7b6859b8298c24f6fe4b227c99e CraftArmy/Dashboard.lua
ffa36e82ded170e094045bed94f08ac97f821312b94319c708cb6d066b99de7d CraftArmy/Data.lua
8aaafdcb7b710214a725758d5253861ea0baa528f89ef3a649cf36c3454d3ea6 CraftArmy/KnowledgeCheck.lua
21b0714639563d4fd543aa31262be9a95cc0f405d9e07bdc80058f58a642b263 CraftArmy/SelfTests.lua
366bde4db3f688c1d769370c79b1c4688123a78a3f2afc5422562a7fc881a533 CraftArmy/ViewModel.lua
19f9598cd3ab165564e08b96fcb99ebda0354e291451355a95894672e88399ca README.md
e72fa0c8494eddf8c887f1bad906a4d2137d7e726dd5981130449319d7e0d7c4 docs/dashboard/README.md
90bcad85b095aee1fac664a3df7769950054df6b4218c10bfe56b2bb0df67c66 tests/profession_expansion.lua
```
**Blockers: none for scoped implementation. Exact next action:** primary dispatches
independent read-only verification on these frozen sources, persists findings and owns
acceptance/native coordination. No independent review, primary acceptance, native API/
UI/timing proof or publication is claimed. Gathering production Moxie/Knowledge/DFP
activation remains out of scope; Cooking/Fishing Moxie applicability is pending, not N/A.
Full native suite remains INCOMPLETE87/149; all-rank costs UNVERIFIED; offline estimate
accuracy unverified. No Git/index/commit/push, install, private-data, native or gameplay
operations performed. No source/test/doc edits remain; only final task-state reporting
occurs after the terminal validation.

**Primary pre-review freeze2026-11-19:** all11final implementation/test/README hashes
matched the writer's final list exactly. Read-only review uses local
`artifacts/p01-comparison/review-owned-hashes.json` and `review-freeze-files.json`;
immutable original10preimages are located through `preimage-paths.json`. Primary updated
only current PLAN/AGENTS/audit/TASKS status after writer stop, not delivered source/docs.
No writer or validation jobs remain active. Independent verification is dispatched next;
reviewer cannot edit files and must not retry the old external snapshot path.

**Independent verifier stop2026-11-19 — INCOMPLETE, no confirmed finding:** reviewed
contract/current source/additive fixtures statically; initial HEAD/status/diff shell was
denied (`permission.rejected: shell`), no retry or alternate execution. All independent
Lua/Python/hash/inventory/actual-diff/preimage/end-freeze checks NOT RUN. Expected manifests
were read, not recomputed. Writer validation remains writer-attributed. Primary persists
[review details](docs/dashboard/expansion-p01-review.md), will separately execute approved
local checks/comparisons and supply frozen literal diff for further STATIC review only.
Do not represent that primary evidence as independent execution; no acceptance yet.

**PRIMARY validation/comparison2026-11-19 — PASS, separate from reviewer:** all6approved
commands completed serially/exit0 on unchanged11delivery hashes:16groups/219173additive,
512actualPASS/all19workloads5/10/2/2/K6=744/K7=565,23diag,Python87Markdown477links/8diag
hashes and diagnostics packaging, whitespace PASS. No background jobs. Primary computed
full9adaptation SelfTests reconstruction, exact Core three-slot-only and Commands inverse
proofs,135unchanged non-writer/non-primary original paths,9asset pairs, no removed paths,
HEAD5f98f5e/index unchanged. Logs `artifacts/p01-comparison/primary-validation/results.json`;
comparison `primary-comparison-results.json`; complete diff `review-actual-diff.txt` and
inventory `review-status.txt` supplied for read-only STATIC review. Independent execution/
hash computation remains NOT RUN due denial, not silently upgraded. Native gates unchanged.

**FINAL PRIMARY LOCAL ACCEPTANCE2026-11-19:** same verifier completed independent static
review of the FULL supplied actual diff/new fixture/9legacy adaptations and amended scope,
PASS STATIC ONLY/no confirmed finding. Independent tests/Git/hash/preimage computations
remain NOT RUN; its reviewed hashes/results are explicitly PRIMARY-computed. Primary
post-review rehashed all11targets: exact final hashes above, HEAD/index unchanged. Sources
did not drift during review. No writer/reviewer jobs remain. [Review and attribution](docs/dashboard/expansion-p01-review.md).
Accept scoped P01 foundation/evidence milestone using PRIMARY terminal suites/preservation
proofs plus independent static review; not a new-profession native/all-field sign-off.
Next USER step: normal addon update, inspect new own-profession cells, then one read-only
knowledgecapture report each for Herbalism/Mining/Skinning in own ready unstaged config.
Report blocked/incomplete output, do not reset/train/unlearn/change gear/repeat old checks.
Next PRIMARY step: inspect returned evidence before any new mapping/accounting/stat task.
No further implementation, install, commit/push/publication authorization from acceptance.

Native Moxie mappings, gathering Knowledge accounting and intrinsic stat activation belong
to a later evidence-gated task, not guessed defaults or blockers on independent P01 work.
Use one synchronous implementer, no children, and persist each piece/run
state at every stop. Primary owns review/native coordination. No commits/push/releases.

## Open issues and acceptance gaps

- [x] **P02/P03 focused native acceptance:** gathering numbers and all four P03 features
  user-confirmed: secondary Moxie dash, gathering colours, Deftness D, gathering-only
  missing-enchant behavior. No repeat checks or broader unreported acceptance inferred.
- [ ] **Secondary enchant applicability:** Cooking/Fishing permanent support remains
  tentative/pending, warnings disabled rather than N/A. No purchases or gear changes needed.
  Fishing rod-only confirmed despite API28/29/30; accessories N/A, fishing hats use regular Head.
  Dormant gathering Moxie catalogue IDs alone do not authorize activation.
- [ ] **Remaining field semantics:** authoritative roster absence/automatic unlearning
  remains unsupported. Missing or transient nil data must not retire known snapshots.
  [Q03](docs/questions/Q03.md) retains API/readiness evidence and unresolved semantics.
- [ ] **Broader native attribution/edge coverage:** Tool intrinsic stat is implemented,
  locally reviewed and fixture-tested; focused native R/M visibility is accepted, but
  contrasting enchant-stat attribution and every API/input/hover edge are not universally
  verified. Unreported procedures are not inferred; no repeat accepted checks requested.
- [ ] **Concentration estimate accuracy:** quantified offline accuracy remains unverified.
  Observed values and approximate display predictions must remain separate.
- [ ] **Review/evidence limitations:** independent executable/comparison proofs and measured
  client timing are not supplied by static review or synthetic clocks. Full native suite
  stays **INCOMPLETE87/149**; all-rank costs **UNVERIFIED**. Missing external derivative
  evidence remains missing; no retry/bypass of denied operations. None is relabelled PASS
  or treated as a blanket prerequisite to unrelated native work.

## Accepted behavior to preserve

- No fixed character/profession storage cap, resets, silent eviction or forced rescans to
  recover known values.46/100/200-character workloads are fixtures, not ceilings. Retain
  coherent observations on failed reads; estimates never affect sorting, attention or saves.
- Filter first, then current-character rows first with green name dot; apply sorting within
  current/other groups. Keep the scrollbar, wheel/range footer and reused visible rows.
- Gear24px icons/28px rows, accepted internal gaps/6px outer gutters, red older-gear borders,
  quality/enchant badges and natural-size Tool letters. Native/third-party equipped-item
  tooltip only on normal hover; CraftArmy details/provenance on Shift.
- Centered Moxie/no `!`, uniform green strictly above600; observed blue plus cyan estimated
  Concentration and approximate total. Skill-only non-max filter/marker refinements remain.
- Concise normal tooltips retain meaningful unknown/stale/archived/pending safety cues;
  full Shift diagnostics and assumptions remain. Do not reopen accepted visual checks.
- Preserve original `media/` assets and packaged icons/manifest; title icon is accepted.

## Deferred work and priorities

1. Extend dashboard coverage to all thirteen named professions before guides; existing
   crafting sign-off is not awaiting another checklist round.
2. Follow up with the [Concentration flicker fix](docs/dashboard/concentration-refresh-investigation.md)
   after profession coverage, as explicitly ordered by user Nov19. No fix writer now.
3. **Inscription is the first complete guide.** Guide routes, shopping/inventory/material
   calculations and Auctionator integration are unbuilt; confirmed policies remain in PLAN.
4. Details redesign stays parked; preserve existing Inscription functionality. Complete
   Knowledge-gated recipe catalogue/actual learned-status mapping, computed bonuses and
   other-profession Details remain deferred/unverified, not delivered.
5. Older expansions and Archaeology were not added by the full-dashboard decision.
   Cross-account sync, general route optimization and weekly tracking remain parked;
   follow PLAN's individual [parking-lot](docs/parking-lot/P01.md) thread pointers.
6. New defects need new scoped tasks; completed U06–U15/M01/R01 contracts are history only.

## Validation and handoff rules

- Retain full local correctness/stress suites. Inspect scripts before execution; use
  installed Lua5.1 only: `lua5.1 tests/dashboard.lua`, `lua5.1 tests/run.lua`,
  `python3 tools/check_dashboard.py`, `python3 tools/check_diagnostics.py`.
- Documentation/structural success is not Lua execution, live API behavior or timing.
  Never raise safety limits, reduce coverage or relabel INCOMPLETE as PASS.
- Use focused new-profession user-run native checks, not repeated accepted crafting checks.
- One synchronous writer after a settled authorized serial contract; specify files,
  dependencies/tests and required report. Persist run state at every stop, then review.
- Implementation, independent review, acceptance and release are distinct gates. No reset,
  game/dependency installation, private-data access or new Git/release authorization.
- References: [validation/recovery](docs/references/validation-and-recovery.md),
  [current schema](docs/dashboard/schema.md), [dashboard guide](docs/dashboard/README.md).

## Done / historical queue index

Historical results are not universal native acceptance. Read the current status and newest
PLAN/thread evidence first. Compatibility anchors below retain old task/section navigation.
Dates are2026; run dates do not imply that all acceptance evidence was available that day.

| Queue | Completed work | Run date | Preserved contract/report |
| --- | --- | --- | --- |
| <a id="u15--native-only-gear-hovers-and-concise-normal-tooltips"></a><a id="goal"></a><a id="why-pointer"></a><a id="-u15-run-state"></a><a id="design--serial-numbered-pieces"></a><a id="files"></a><a id="tests--exact-old-byte-preservation"></a><a id="out-of-scope"></a><a id="report-back--u15"></a>U15 | Native normal gear hovers / concise normal tooltips / Shift diagnostics | Nov18 | [U15](docs/tasks/archive/U15.md) |
| <a id="completed-u14-record--non-executable-history"></a><a id="u14--uniform-moxie-brightness-and-efficient-endpoint-clear-scrolling"></a><a id="goal-1"></a><a id="why-pointer-1"></a><a id="-u14-run-state"></a><a id="design--serial-numbered-pieces-1"></a><a id="files-1"></a><a id="tests--old-byte-preservation"></a><a id="out-of-scope-1"></a><a id="report-back--u14"></a>U14 | Moxie brightness / coalesced scrolling / thumb bounds | Nov18 | [U14](docs/tasks/archive/U14.md) |
| <a id="completed-u13-record--non-executable-history"></a><a id="u13--dashboard-attention-estimates-scrollbar-and-current-character"></a><a id="goal-2"></a><a id="why-pointer-2"></a><a id="-u13-run-state"></a><a id="design--serial-numbered-pieces-2"></a><a id="files-2"></a><a id="tests--permitted-old-assertion-adaptations"></a><a id="out-of-scope-2"></a><a id="report-back--u13"></a>U13 | Moxie / estimated Concentration / scrollbar / current-character grouping | Nov18 | [U13](docs/tasks/archive/U13.md) |
| <a id="completed-u12-record--non-executable-history"></a><a id="u12--unclipped-tool-letter-and-outer-gear-padding"></a><a id="goal-3"></a><a id="why-pointer-3"></a><a id="-u12-run-state"></a><a id="design--serial-numbered-pieces-3"></a><a id="files-3"></a><a id="tests--preservation"></a><a id="out-of-scope-3"></a><a id="report-back--u12"></a>U12 | Unclipped Tool letter / outer Gear gutters | Nov18 | [U12](docs/tasks/archive/U12.md) |
| <a id="completed-u11-record--non-executable-history"></a><a id="u11--decorated-item-link-metadata-fix-and-compact-gear-spacing"></a><a id="goal-4"></a><a id="why-pointer-4"></a><a id="-u11-run-state"></a><a id="design--numbered-pieces"></a><a id="files-4"></a><a id="tests--exact-old-byte-preservation-1"></a><a id="out-of-scope-4"></a><a id="report-back--u11"></a>U11 | Decorated-link metadata parser / compact gear spacing | Nov17 | [U11](docs/tasks/archive/U11.md) |
| <a id="completed-u10-record--non-executable-history"></a><a id="u10--combined-gear-icon-redesign"></a><a id="goal-5"></a><a id="why-pointer-5"></a><a id="-u10-run-state"></a><a id="design--numbered-pieces-1"></a><a id="files-5"></a><a id="tests--authorized-expectation-adaptations"></a><a id="out-of-scope-5"></a><a id="report-back--u10"></a>U10 | Combined gear icons / rarity-quality-enchant / intrinsic Tool metadata | Nov17 | [U10](docs/tasks/archive/U10.md) |
| <a id="completed-u09-record--non-executable-history"></a><a id="u09--concentration-bar-and-tooltip-only-estimates"></a><a id="goal-6"></a><a id="why-pointer-6"></a><a id="-u09-run-state"></a><a id="design--numbered-pieces-2"></a><a id="files-6"></a><a id="tests"></a><a id="out-of-scope-6"></a><a id="report-back--u09"></a>U09 | Concentration bar / initial tooltip-only estimates, superseded by U13 | Nov17 | [U09](docs/tasks/archive/U09.md) |
| <a id="completed-u08-record--non-executable-history"></a><a id="u08--dashboard-title-bar-icon"></a><a id="goal-7"></a><a id="why-pointer-7"></a><a id="-u08-run-state"></a><a id="design--serial-numbered-pieces-4"></a><a id="files--tests"></a><a id="out-of-scope-7"></a><a id="report-back--u08"></a>U08 | Title icon | Nov17 | [U08](docs/tasks/archive/U08.md) |
| <a id="completed-m01-record--non-executable-history"></a><a id="m01--import-user-supplied-icon-pack"></a><a id="goal-8"></a><a id="why-pointer-8"></a><a id="-m01-run-state"></a><a id="design--serial-numbered-pieces-5"></a><a id="files--exact-source-manifest"></a><a id="tests--acceptance"></a><a id="out-of-scope-8"></a><a id="report-back--m01"></a>M01 | Preserved original / packaged icon assets and manifest | Nov17 | [M01](docs/tasks/archive/M01.md) |
| <a id="completed-u07-record--non-executable-history"></a><a id="u07--skill-only-attentionfilter-refinement"></a><a id="goal-9"></a><a id="why-pointer-9"></a><a id="-u07-run-state"></a><a id="design--serial-numbered-pieces-6"></a><a id="files--compatibility-scope"></a><a id="tests-1"></a><a id="out-of-scope-9"></a><a id="report-back--u07"></a>U07 | Skill-only attention/filter / marker refinement | Nov17 | [U07](docs/tasks/archive/U07.md) |
| <a id="completed-u06-record--non-executable-history"></a><a id="u06--skill-column-progress-bar"></a><a id="goal-10"></a><a id="why-pointer-10"></a><a id="-u06-run-state"></a><a id="design--serial-numbered-pieces-7"></a><a id="files--ownership"></a><a id="tests-2"></a><a id="out-of-scope-10"></a><a id="report-back--u06"></a>U06 | Skill progress bar | Nov17 | [U06](docs/tasks/archive/U06.md) |
| <a id="completed-r01-record--non-executable-history"></a><a id="r01--retain-completed-dashboard-during-incremental-redraw"></a><a id="goal-11"></a><a id="why-pointer-11"></a><a id="-run-state"></a><a id="design--serial-numbered-pieces-8"></a><a id="files--ownership-1"></a><a id="tests--acceptance-1"></a><a id="out-of-scope-11"></a><a id="report-back-implementer-updates-primary-persists-review-before-acceptance"></a>R01 | Completed dashboard retained during redraw / focused visibility accepted | Nov17 | [R01](docs/tasks/archive/R01.md) |
| <a id="next-active-task--s01-shared-definitions-and-independently-bounded-saved-records"></a>S01 | Storage / focused refresh and older-snapshot retention accepted; redraw resolved by R01 | Nov16–17 | [S01](docs/tasks/archive/S01.md) |
| <a id="next-active-task--u05-dashboard-colors-dropdowns-header-sorting-and-flat-window"></a>U05 | Dashboard UI / subsequent refinements and milestone accepted | Nov16 | [U05](docs/tasks/archive/U05.md) |
| <a id="next-active-task--k09-numeric-knowledge-for-the-other-seven-crafting-professions"></a>K09 | Eight-profession numeric Knowledge / focused native values accepted | Nov16 | [K09](docs/tasks/archive/K09.md) |
| <a id="next-active-task--k08-frame-stepped-read-only-crafting-knowledge-evidence"></a>K08 | Read-only Knowledge capture / focused profession reports | Nov15–16 | [K08](docs/tasks/archive/K08.md) |
| <a id="next-active-task--e05-explicit-empty-enchant-field-means-observed-absence"></a>E05 | Explicit-empty enchant correction | Nov10–15 | [E05](docs/tasks/archive/E05.md) |
| <a id="next-active-task--e04-supplied-enchant-categories--engineering-resourcefulness"></a>E04 | Supplied enchant categories / Engineering Resourcefulness | Nov10 | [E04](docs/tasks/archive/E04.md) |
| <a id="next-active-task--e03-remaining-six-crafting-identities-and-moxie-activation"></a>E03 | Remaining six crafting identities / Moxie | Nov10 | [E03](docs/tasks/archive/E03.md) |
| <a id="next-active-task--e02-enchanting-moxie-and-supplied-currency-catalogue"></a>E02 | Moxie catalogue / Enchanting mapping | Nov10 | [E02](docs/tasks/archive/E02.md) |
| <a id="next-active-task--e01-enchanting-identity-and-guarded-dashboard-scans"></a>E01 | Enchanting dashboard slice | Nov10 | [E01](docs/tasks/archive/E01.md) |
| <a id="next-active-task--t02-snapshot-dashboard-mvp"></a>T02 | Dashboard MVP/corrections; later milestone signed off, evidence limits retained | Nov5–10 | [T02 with R/K/U/V passes](docs/tasks/archive/T02.md) |
| <a id="previous-task--t01-read-only-retail-api-diagnostic"></a>T01 | Diagnostic harness/R1; broader feasibility partial | Nov5 | [T01](docs/tasks/archive/T01.md) |

## Maintenance recovery

- User approved the 2026-11-18 cleanup manifest. All twelve queue bodies survive verbatim
  except mechanical relative-link rebasing. Historical failures, denials and partial native
  evidence remain history, not renewed execution or test instructions.
- [Pre-cleanup status/housekeeping snapshot](docs/tasks/archive/dashboard-status-2026-11-18.md)
  retains old status text, including superseded pending sign-off/checklist instructions.
- [Archive extraction maps](docs/tasks/README.md) and [maintenance log](docs/rebalance-log.md)
  record ranges, backup/checksum, content retention and unchanged-source validation.
- Keep **check → collapse → evict**, confirmed manifests and no active writer. Current
  status/run state, executable queue, open issues and deferred work always stay here.
