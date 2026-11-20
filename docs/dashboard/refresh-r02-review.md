# R02 independent review — 2026-11-19

## First frozen delivery

**CHANGES REQUIRED.** Independent full-scope static review found two medium-severity
correctness gaps. Independent executable verification is **INCOMPLETE / NOT RUN** after
the verifier's first shell command was denied; no retry/bypass. Primary/writer execution
is separate evidence, never independent execution. No local/native acceptance yet.

Reviewer session: `ses_e0d090be5ffebV7zMDwmGouoeY`. Read-only report persisted by primary.
Reviewer returned PARTIAL: static scope complete, executable/preservation checks unavailable.
No reviewer edits. Platform review N/A (no CI/hosting/IAM/release change).

Base is accepted uncommitted P03, not initial HEAD. Full actual implementation diff:
`artifacts/r02-comparison/delivery.diff`, 81457 bytes, SHA256
`8af2b076a873db0ea0c476f4373200422f242d089abba772a1562b2ca0f1389b`.
Five target hashes are in `delivery-hashes.json` and TASKS first-delivery report. Reviewer
read the complete diff/new630-line runner and relevant Dashboard/Storage/ViewModel code;
hash identities supplied by primary were not independently recomputed. Both authorized
legacy adaptations match intent, retaining eight boundaries/two modes and safety assertions.

### F1 — Medium: backward integer clock does not reject cached estimate

First-delivery `CraftArmy/Dashboard.lua:1071–1073,1117–1118` checks only nonnegative integer
time for pending continuity. Fixture observation100 / initial completed paint200 followed
by time50 and Refresh would keep the frozen cyan/approximate display, whereas
`CraftArmy/ViewModel.lua:270–271` rejects `now < observedAt`. Preserve the existing invalid-
clock fallback using the single existing Render clock, without recomputation/extra reads.
Add rejecting regressions before Refresh and during pending Render. Static control-flow
finding; reviewer did not execute the reproduction.

### F2 — Medium: ownership pins end before post-preparation native callbacks

First-delivery `CraftArmy/Dashboard.lua:1317–1319,1326–1332,1350–1356` sets preparing=false
before subsequent frame:IsShown and initial paint callbacks. owns() then checks only build
version. A one-shot same-build reentrant Render + queued scroll + hover from that visibility
callback can be erased by the older outer Retain/paint. Existing eligibility-read/build-
changing tests do not cover this post-eligibility boundary. Keep ownership protection across
remaining preparation/initial-paint callbacks and reject older stacks; distinguish exact
intentional local mutations from reentrant replacement. Add rejecting visibility/status
boundary tests with newer paint/status/hover/scroll preservation. Static finding, not an
executed reviewer reproduction.

## Primary disposition and correction gate

Primary inspected both cited paths and confirms the static gaps. One synchronous writer
may correct F1/F2 within existing Dashboard/new-runner scope, with no further legacy edits.
Correction instructions are in the R02 contract/TASKS. First delivery remains frozen
evidence, not a retroactive PASS. Require meaningful new red tests, corrected green, all
final serial suites/preservation proofs, revised diff/hashes and independent reassessment.
No native check before local acceptance. Native trigger/frequency, offline estimate accuracy,
full native INCOMPLETE87/149 and all-rank UNVERIFIED remain unchanged.

## Corrected delivery reassessment

**CHANGES REQUIRED; F1/F2 statically addressed, F3 remains.** Same independent reviewer
read the full corrected96755-byte diff/new780-line runner and documentation, SHA256
`04ea25a0be7c121a927a5edb241985903a72ec659b4fff8a26952e446b7faedc`.
Dashboard hash supplied by primary:
`7f5ee85f046e40f193907ff773fcfb7cc7fdbe8058f7fee988ec21d4f86f658c`.
No independently recomputed hashes/execution/end-freeze; earlier denial still applies,
no retry/bypass. Reviewer returned PARTIAL, static full-scope complete/execution unavailable.
Writer43/857241 plus all existing suites and primary comparisons remain separately attributed.

### F3 — Medium: throwing pre-entry Retain wrapper leaves failed preparation reusable

Corrected `CraftArmy/Dashboard.lua:129–145,1383–1389` cleans failed owned Render but not
owned Retain. After prepareContinuity arms cache, a Retain wrapper throwing before forwarding
escapes without demotion/cache revocation; no job is installed and retained remains false.
Restore the wrapper and retry without a successful normal paint: failed preparation's
cache remains reusable. Existing wrapper-failure test only covers Render. Static finding,
not independently executed reproduction. Owner-checked fail-closed cleanup must handle
failed owned Retain without depending on that same throwing wrapper, preserving newer
reentrant ownership. Add immediate fallback/nonrevival/recovery and newer-owner tests.

Primary inspected ownedCall/initial paint and confirms this static gap. One writer may
correct it under the same Dashboard/new-runner ownership; no SelfTests change. Revalidate
all final suites and freeze/reassess again. No local/native acceptance granted.

## F3 delivery — final independent static reassessment

**STATIC PASS — no remaining findings.** F1/F2/F3 statically addressed. Reviewer read the
full107335-byte actual P03→F3 diff, all928 runner lines, amended contract and D1–D3 report.
Diff SHA256 `9967142bac4bab629f4ec83c62060a8d47e7000f04f96c6d9b7fafe362062806`;
five target hashes in `artifacts/r02-comparison/f3-delivery-hashes.json`. Dashboard:
`57bc8b30a2470d5ba6f2c00c197fdb717647979449256233e2a95d4ad1783d90`.
These packet identities were supplied, not independently recomputed.

Resolution: F1 shared-clock estimate-only rejection/nonrevival at Dashboard1151–1164;
F2 exact synchronous ownership/delayed installation1395–1558; F3 generalized dispatch
exception handling/private captured cleanup131–145,418–454,1370–1394. Added tests cover
pre/post-entry/simultaneous wrapper failures, retry nonrevival, newer ownership, cleanup
fault/reentry boundaries and old in-flight cancellation; previous regression groups remain.

**Review acceptance INCOMPLETE** solely for unavailable independent executable/comparison
checks; reviewer returned PARTIAL, static reassessment complete. Lua/Python/whitespace,
hash/reconstruction/protected/icon/inventory/Git and ending freeze NOT RUN independently.
Original shell denial still applies; no retry/bypass, no reviewer edits. Writer58/902323
and all existing final suites are writer-attributed; primary comparison evidence is separate.
No remaining static blocker. Primary must verify frozen hashes, persist its own acceptance
decision/evidence before focused native follow-up. No release/native acceptance granted.

## Primary scoped local acceptance

**LOCALLY ACCEPTED2026-11-19**, not independent executable/native acceptance. PRIMARY ran
all nine approved commands serially to terminal exit0 on the five reviewed F3 hashes:
R02 58/902323, P03 15/31244, P02 12/13223, P01 16/220990 (184/400/800rows), legacy512/
all19/K6=744/K7=565, diagnostics23, both Python and whitespace. Primary logs/results are
under ignored `artifacts/r02-comparison/primary-final-*`. No target drift across commands.
Primary packet/reconstruction/protected/Git comparisons are separate from reviewer evidence.
No remaining static blocker; focused ordinary-refresh native continuity feedback pending.
No installation, publication, Git mutation or guide authority implied.
