# S01 — frozen implementation review and acceptance

Current gate2026-11-17: implementation/local validation, renewed scoped static review,
post-review source freeze and primary bounded acceptance COMPLETE. User now confirms
focused normal-scan/older-snapshot preservation; redraw/normal-use acceptance stays partial.
Earlier NOT RUN/CHANGES REQUIRED and hashes below
are historical until explicitly
superseded by a later review/acceptance entry. Native storage validation NOT RUN.

## Scope and gates — 2026-11-16

Implementation COMPLETE, primary local comparison/checks PASS. Independent review and
primary acceptance PENDING; native migration/scan/performance validation NOT RUN. No
installation or release advice until these gates complete. Platform N/A (local addon
data/UI, no CI/hosting/IAM/deployment/release changes).

Contract: `storage-s01-contract.md` including primary5a retained-field scheduling
amendment. Source comparison: actual72-file primary baseline
`/tmp/opencode/craftarmy-s01-baseline-j71j9fts/files` to current73-file workspace;
17authorized changed paths (15writer-owned plus2primary planning files),56unchanged,
only Storage.lua added, no removals. TASKS has mixed primary/writer ownership.

Primary independently recomputed target hashes against writer final artifact manifest,
full86364-byte production/checker diff SHA256
`f4ca5326bfbe7508b2678c433c4ce15ed93cfb93b69870f5790c0f67f00b05ee`, exact inverse
old409 SelfTests/Core one-export/runner insertion, old README suffix/schema+evidence
prefixes/U05-and-older TASKS suffix and primary PLAN/contract freeze: PASS. Initial
comparison script attempts omitted the S01 enclosing do/end and checker in artifact
composition; corrected complete-block/full-scope comparison passes, no source changes.
One exploratory header-prefix slicing typo also affected only the comparison script.
Primary evidence: `/tmp/opencode/s01-primary-comparison.json`.

Fresh primary execution (not independent/native evidence):
- `lua5.1 tests/dashboard.lua`: completed446/446 (409retained+37new),744K6/565K7 PASS.
- `lua5.1 tests/run.lua`:23/23 PASS.
- `python3 tools/check_dashboard.py`:PASS17required/28Markdown/97links.
- `python3 tools/check_diagnostics.py`:PASS.
Full dashboard output `/tmp/opencode/s01-primary-dashboard.log`. Initial partial422/1
and earlier INCOMPLETE results remain in TASKS/evidence; no reduced old coverage.

## Frozen source/check inputs (SHA256)

```text
aa00b24526c9fd6f9b3af85cc685120ba66eb66d15054f410a74b5288e7deb27 CraftArmy/Collectors.lua
e73a8fb9cac46b694a80e964d5e59b934e62d41387f50e5406922084bdbc289e CraftArmy/Commands.lua
de7bb9f5625d883cf1a317a62708e300fac4f31c4e4b59b7f9703b18b93b6ef9 CraftArmy/Core.lua
7d5a0a06cff301c45a445757abbd4f22065883a487b19fac1da0d73d999d431b CraftArmy/CraftArmy.toc
72733546eec21b225967fdc29a62adce3d75f56b32a99d2468deb5088f56d707 CraftArmy/Dashboard.lua
7e889a35cf485041c6c127a408792a3b1c5982bf96cd3d05c39b26f8fabc419f CraftArmy/Data.lua
fccbef396627e20ddb69e4cb67a4cf76a25ca28023b5f77e83ded2d0159484f1 CraftArmy/Details.lua
5c41300d521ae350ee66740c2722ca937e169bcf5f32f933a780fed96dfcc2b0 CraftArmy/Knowledge.lua
9d004416860fb09405cbe031847eacc9a55c7067b6eca056d3f63d27c23574b6 CraftArmy/KnowledgeCheck.lua
e3bc97f39ec212d9c14611ee63909c7d2580c8ddd1b33f7d557dac98138af8fe CraftArmy/SelfTests.lua
63cf3e1a8a1794a2a9d7d4f012767d9dbccf2e66c5c3745cc36dc331db8e61f1 CraftArmy/Storage.lua
91a9d9646716032545448c7c2a2e39cd80c092798f324509a65a047c3b86d9aa CraftArmy/ViewModel.lua
7033a1eab99d2b2adbb6a76e8bb8afb6d29e541184227564107242b094577dde tests/dashboard.lua
8d3210e44846b0fb0e45aa7e78526abbed74d6dc3207bcbb348746f448fd26bc tests/run.lua
9d19bb77f193afb0e8d4043cb176c821bf9e31d6a0838d871b5ebb1cb25f3d2e tools/check_dashboard.py
66253a0403fe29078f1b41f99ba295cbcf3c3f3e54f7a060d76b6c3df02ef6f3 tools/check_diagnostics.py
```

## Independent review assignment

Read-only verifier examines full delta/source/tests and migration/data integrity,
affected-only writes, owned immutable definitions, raw-summary honesty, Details rich
source/final-frame checks, cancellation/reentry/publication and actual scheduled bounds.
Review retained9/17fields and46/100/200×2 fixtures, sparse archives and >50000aggregate
accounts, not just counts. Run approved local checks if permitted; report denied checks
once, no retry/bypass, and separate static review from unperformed independent execution.

Also assess practical scheduled latency: final fixture counts include46×2open544 and
build564Steps;200×2open2240/build2453Steps. These are work counts, NOT measured native
frame rates/latency, but one-Step/frame deliberately amortizes substantial total work.
Do not claim instant/constant-time rendering or native responsiveness from fixture PASS.

Primary persists read-only findings and exact review scope here/TASKS before acceptance.

## Independent read-only review returned — changes required

Verifier `ses_e1ce60a25ffejRj7qb5yU9KUKk`: Status PARTIAL, Acceptance CHANGES REQUIRED.
Reviewed current Storage/collector/Details/startup/model/render code and all37 S01 cases
against the contract including5a. External artifact read denied once and shell execution
denied once; neither retried/bypassed. No independent execution, hashes, full comparison,
inverse or final freeze. These proofs remain primary-attributed. Reviewer wrote no files.

**Medium, blocking touched-reference integrity finding:** Storage.lua stageCatalog367–378
and Apply488–506 can reuse an identical-content but unregistered replacement saved
catalogue for a NEW character, then commit references subsequent reads reject as catalogue
ownership drift. Existing-active-record tests mask this because selected() validates its
old dependencies. Equal-content cross-catalogue subtree aliases have the same missing
write-preflight ownership check. Contract4 requires touched interference to reject BEFORE
write even though external multiwriters are unsupported. Repro: real Apply seed, replace
referenced catalogue with Core.Copy(same content), real Apply same rich input to new GUID.
Correction: apply current saved-catalogue registered-owner, nested alias and immutable
content validation to every reused dependency before commit, including a new owner;
regress graph/counter/revision/token-identical rejection.

**Latency risk:** reported564model Steps at46×2 means564scheduled frames per full rebuild.
Illustrative9.4seconds at60callbacks/second is arithmetic, NOT native timing. Empty-until-
complete sorting/filter/event rebuilds may be prolonged by restarts. This follows the
initial settled scheduler, not an implementation deviation. Primary will explicitly
reconsider bounded frame batching; no claim of responsive native use from fixture PASS.

No acceptance/update advice. Further correction and renewed review required. Historical
nativeINCOMPLETE87/149 and all-rank UNVERIFIED unchanged. Platform N/A.

## Piece8 primary comparison and renewed review freeze — 2026-11-17

Writer reproduced both catalogue-reuse rejection tests against old source (446PASS/2FAIL),
then corrected precommit registered/nested ownership checks for reused tree/Details
dependencies. Added12cases with all446 previous cases byte-identical. NewFrameBatch is
bounded16Steps/observed2ms-between-unit scheduling ONLY for startup/dashboard, preserving
individual Step/native/primitive bounds and existing capture/selftest/Details schedulers.
No clock means explicit one-Step fallback; selected invalid clocks fail, no hidden drain.

Primary independently recomputed actual72baseline->74current paths:18authorized changed,
56unchanged, only Storage and primary review doc added, no removals. All final target hashes
match writer piece8 artifact manifest. Exact old446/old409/Core/runner inverse, historical
suffix/prefix and primary PLAN/contract/review freeze proofs PASS. Full93670-byte production/
checker diff SHA256 `50c18d198aff3041fcf1be1abf543891d1b4d86c15c3926d839c62ddd8e3167e`.
Comparison proof `/tmp/opencode/s01-piece8-primary-comparison.json`; artifacts
`/tmp/opencode/craftarmy-s01-piece8-artifacts`. Subsequent primary review/TASKS appends
are intentional; source stays frozen.

Fresh primary approved checks:458/458+744K6/565K7, diagnostics23/23, bothPython PASS
(17required/29Markdown/97links). `/tmp/opencode/s01-piece8-primary-dashboard.log` stores
full output. These are PRIMARY executable/comparison proofs, not independent/native ones.
Actual deterministic zero-clock driver callbacks at46×2:open34/544Steps,model36/564Steps;
100×2:72/1138,77/1226;200×2:140/2240,154/2454. These are fake-clock fixture counts,
not measured wall time or assurance each real callback fits2ms (one unit can overshoot).

Four changed source hashes supersede only their old entries in the16-input frozen list:
```text
a097e334240a57156c0b48bfcb6f9712d8a84ba81ca15fd1ad811546378f9e10 CraftArmy/Commands.lua
f00ca5756654b1909e49538a7c0ac5f28f221e7de8ed76b7996d047e0afaa3ac CraftArmy/Dashboard.lua
620f20129f7e415f7af93c9f197ee25c630d5a2091d2b464c9193a14135acc2e CraftArmy/Storage.lua
2b115ef37e838051f601f2c08914e1f8d84ad26e4134ca644ec5b48bb059f0db CraftArmy/SelfTests.lua
```
All other12 frozen source/check inputs remain unchanged. Renewed read-only verification
must resolve the reviewed integrity finding and inspect batch safety/new regressions,
without retrying prior denied artifact/shell operations or reattributing primary evidence.
Primary persists returned scope/findings before acceptance and post-review source freeze.

## Piece8 renewed static review — changes required,2026-11-17

Verifier ses_e1ce60a25ffejRj7qb5yU9KUKk COMPLETE for scoped static review; Acceptance
CHANGES REQUIRED. Original catalogue-reuse finding RESOLVED by registered/nested owner,
alias/type/content preflight. Read corrected helper/drivers and all12regressions. Prior
denied artifact/shell operations not retried/bypassed; no independent executable/hash/
fulltree/inverse/freeze proof, all such evidence remains PRIMARY. Reviewer edited nothing.

**Medium, blocking contract5b regression:** Commands.lua368–372 failure branch calls
retireDriver(), then unconditionally storageMessage(). If selected clock throws after
old opening completes and frame.Hide cleanup starts explicit `/ca storage retry`, the
new job/batch/pending status is created correctly, but the retired callback subsequently
overwrites the new job's blockReason/dashboard with the old failure. No root replacement
or snapshot loss is claimed; the initialization status is wrong. Static reproduction,
not independently executed. Existing tests cover successful cleanup supersession, not
combined failure-cleanup retry. Correct post-cleanup identity/epoch guarding; audit source-
drift, setup-failure, explicit cancellation and initialization-entry cleanup equivalents.
Regression must preserve replacement job/batch/pending status, then complete normally.

Native usability/performance remains NOT RUN: zero-clock34/36callbacks at46×2 is not
native latency,2ms units can overshoot and event restarts/fallback remain focused normal-
use observations after acceptance. No new capture/ID/fullselftest sequence. Platform N/A.

## Piece9 primary comparison, permitted evidence delivery and freeze — 2026-11-17

Writer reproduced old-source combined failure (458PASS/1FAIL), then added private startup
epoch and post-callback identity checks through entry/finish/error/setup/source-drift/
explicit-cancel paths. Five additive matrix cases, all458 previous bytes preserved.
Intermediate461PASS/2FAIL was new-fixture widget setup and remains documented; final
writer463/463+744K6/565K7/23/bothPython PASS. No Storage/dashboard/native/budget changes.

An external helper Add File at `/tmp/opencode/s01-piece9-freeze.py` was denied once;
no retry, alternate tool write or permission change. Writer correctly returned PARTIAL
for its missing derivative artifact bundle. Primary does NOT grant or bypass that tool
permission. Instead primary performs the already-authorized read-only comparisons and
approved checks and records the evidence here, an owned project review document. Extra
external copies/helper/manifests remain ungenerated; they are NOT claimed complete.
The authoritative current source, existing snapshots and these recomputed hashes permit
review without that optional derivative bundle. This changes evidence delivery location,
not safety coverage, source semantics, test requirements or independent-proof attribution.

Primary independently recomputed actual72original->74current paths,18authorized changed/
56unchanged/no deletions. Since piece9 start exactly6owned paths changed: Commands,
SelfTests,TASKS,README,schema,evidence. PLAN/contract/review were unchanged since that
start (this later primary review/TASKS append is intentional). Exact old458/old409/Core
one-export/runner insertion/history prefix+suffix proofs PASS. All source except Commands
and additive SelfTests is unchanged since piece8. Full96708-byte production/checker diff
against original baseline SHA256:
`5892a772eb96004281c11530aa228ccfcbc793860de59798e4647e9ce618567a`.
Complete13235-byte Commands correction diff against piece9-start SHA256:
`cfebde5e4296ae7140a4f67a8090882125f3ab748363e232ee9a3069db715fdc`.
Actual read-only command output includes the entire narrow production diff. These exact
results also independently match writer's earlier read-only hashes, not a bundled proof.

Fresh PRIMARY checks, all exit0:
- `lua5.1 tests/dashboard.lua`: completed463/463+744K6/565K7.
- `lua5.1 tests/run.lua`:23/23.
- `python3 tools/check_dashboard.py`:PASS17required/29Markdown/97links.
- `python3 tools/check_diagnostics.py`:PASS.
No external log/artifact write on these primary runs. Full command execution results are
recorded here; previous helper/artifact bundle limitation remains explicit.

Current Commands/SelfTests hashes supersede their old entries; other14 frozen source/check
inputs (using piece8's Storage/Dashboard replacements) remain unchanged:
```text
43a3dca252696d5f596727133028ddc96804bac82b8331d03fad6b84aba4d707 CraftArmy/Commands.lua
d907ef6bce9459109072e2474a89e63dd1b870dd2bc3f187ce711bba2ce6b83a CraftArmy/SelfTests.lua
```
Renewed reviewer must resolve startup-cleanup finding against this exact local source
and all5new matrix cases, with prior denied operations NOT retried. Independent execution,
hash/fulltree comparison and freeze remain unperformed unless separately available under
permissions; do not reattribute PRIMARY proofs. Native storage validation NOT RUN.

## Piece9 independent scoped static review — PASS,2026-11-17

Verifier ses_e1ce60a25ffejRj7qb5yU9KUKk COMPLETE scoped static review, Acceptance PASS
for that scope only. Startup cleanup/status finding RESOLVED; captured epoch/job/runtime
checks prevent retired entry/setup/cancel/source-drift/batch-error/thrown-error/finish
paths from cancelling/hiding/overwriting a replacement. All5added regression matrices
reviewed: job/frame/batch identity, pending reason and visible label, stale callback
inertness, original root/counters and actual replacement completion. No remaining static
findings in the reviewed correction. Original catalogue-ownership finding remains resolved.

Reviewed current local Commands and additive SelfTests against previous piece8 review
and contract9; exact two source hashes above are PRIMARY-supplied identifiers, not reviewer-
computed. No files edited, prior denied shell/artifact operations not retried/bypassed.
Independent execution/hashes/fulltree/inverse/post-review-freeze INCOMPLETE;463/463+
744K6/565K7/23/bothPython and actual comparisons remain PRIMARY-attributed. Extra external
derivative bundle still ungenerated, not claimed complete. Platform N/A.

Native storage/normal-use performance NOT RUN; zero-clock callback counts are not native
latency, indivisible work may exceed2ms, restart behavior unmeasured. Fullnative remains
INCOMPLETE87/149 and all-rank UNVERIFIED. No new capture/IDs/fullselftest requested.
Primary persists this finding disposition BEFORE post-review hash freeze/acceptance.

## Post-review freeze and primary bounded acceptance — 2026-11-17

After persisting the scoped-static PASS and finding dispositions, PRIMARY recomputed
all16current source/check hashes: unchanged. Full96708-byte production/checker delta
still5892a772...; exact old409 inverse and actual72->74path comparison still18authorized
changed/56unchanged/no removals. No source/test edits during or after renewed review.

PRIMARY accepts this bounded storage implementation based on primary463/463+744K6/565K7/
23/Python execution, complete actual comparison/inverse/history/freeze proofs and the
independent accumulated scoped-static reviews with both findings resolved. Independent
executable/hash/fulltree/inverse evidence remains INCOMPLETE, not reattributed or relabeled.
The extra derivative external bundle remains ungenerated; permission denial was not
retried/bypassed. Direct primary read-only proof and this owned review record deliver
the acceptance evidence. No claim all independent or native validation gates passed.

Only administrative acceptance/README/PLAN/thread/TASKS evidence changes follow. Next:
user-managed whole CraftArmy addon update with SavedVariables backup, automatic safe
migration, one previously blocked character's normal own-profession scan and retained
older snapshot/normal-use check. Native migration, serialization durability and client
performance remain NOT RUN until reported; batching counts are synthetic, not timing.
No reset/eviction/cap raise/capture/identifier/fullselftest sequence/install/Git/release.
Platform N/A; historical fullnativeINCOMPLETE87/149/all-rankUNVERIFIED remain unchanged.

## User-reported normal-use follow-up — 2026-11-17

User confirms scans succeed on multiple previously blocked characters and older snapshots
remain correct. Accept the requested focused storage refresh/preservation evidence at the
reported scope; exact upgrade/migration/reload steps, timing and roster count were not
itemized. Previous NOT RUN statements describe their historical review gates, not today's
reported normal scans. No new source, native probe, fixture run or broad API proof.

User also reports frequent table disappearance/reappearance particularly on profession
open/close. Dashboard redraw/normal-use acceptance remains partial; no lost snapshots
reported and cause/fix not established. User prioritizes approved TASKS cleanup before
continuation. No code fix, repeated capture/IDs/fullselftest or release implied. Local
source/check hashes and review attribution remain unchanged; fullnative87/149INCOMPLETE
and all-rankUNVERIFIED retained. Current live obligations are in TASKS, not archived queues.
