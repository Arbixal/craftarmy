# K08 — frozen review scope (2026-11-15)

## Comparison and primary validation

No Git repository; complete local files, no staged/unstaged distinction. Primary actual
pre-K08 baseline: `/tmp/opencode/craftarmy-k08-baseline`, 66 paths, manifest SHA256
`97932866cb69eeb76dbe7f2c12211dcb880682508bee157355142b14788c6441`.
Primary independently compared all paths: exactly six authorized writer files changed,
plus intentional primary PLAN/Q03 additions. All other58 baseline files unchanged.
No files added/deleted by writer. Historical E05-and-older TASKS suffix byte-identical;
README is a prepend, evidence is append-only. Remove only K08 test block+its separating
blank -> exact baseline277 SelfTests hash. An initial primary proof script had a Python
non-ASCII bytes-literal SyntaxError; corrected harness then all comparisons PASS.

Primary generated complete four-file diff (Commands, KnowledgeCheck, SelfTests, README):
`/tmp/opencode/craftarmy-k08-primary-review.diff`, 908 lines/57742 bytes, SHA256
`e80af9066176ab111a9a34b749ac7355cebaefa736fd58022773d49ad7d3c6e8`.
This primary-owned review record is the only postwriter new repository file.

Primary actual checks on frozen runtime/tests: `lua5.1 tests/dashboard.lua`309/309,
unchanged744K6/565K7; `lua5.1 tests/run.lua`23/23; both Python structural checks PASS.
No FAIL or terminal INCOMPLETE in final dashboard output. Log:
`/tmp/opencode/craftarmy-k08-primary-dashboard.log`. These are local fixtures/structure,
not target-client API or responsiveness evidence. Earlier writer fixture/checkpoint
failures are retained in TASKS/evidence; they are not baseline failures or a native PASS.

## Frozen hashes

```text
f92a2abe64d8b9ec0f23e639cdd35c53a0feaf189db2d80dde4b7f462fb14b83  CraftArmy/Commands.lua
9d004416860fb09405cbe031847eacc9a55c7067b6eca056d3f63d27c23574b6  CraftArmy/KnowledgeCheck.lua
aa83f952f56d2ea0fa91d5ff0dec42b124196a85d72cc12f4bcda923d903c5fd  CraftArmy/SelfTests.lua
b3392d77423e7c9ed1beeb5b6919a26a2c72d899fd228b1a613780c76dfb71bd  docs/dashboard/README.md
```

Baseline Commands b858f4d7..., KnowledgeCheck214550de..., SelfTests0e9605e4... are
recorded in K08 TASKS Tests with full hashes; all old277 cases/helpers/runner frozen.
Core, Data, Collectors, Knowledge, Details, ViewModel, Dashboard, schema, TOC, test
runners/checkers and diagnostics are untouched. Platform review N/A: no CI/hosting/
deployment/release changes. No install, gameplay, dependency or Git/release permission.

## Review requested

Independent read-only review of the complete source delta/current integration and32
additive regressions against top K08 TASKS. Check strict identity/live attribution,
one-Step/frame/no slash-drain, context/runtime/staging guards across all phase/final UI
gaps, events preserved after cancellation, clocks/slow-last/totalcap, old success
retention versus reused-window UI mutation on failed publication, terminal cleanup,
privacy/no writes, legacy compatibility and test strength. Report concrete blockers,
not unsupported claims of universal API support. If external temp files or execution
are denied, do not retry/bypass; attribute executable/hash evidence to primary and
state the limits of direct static inspection. Primary persists the returned review.

Native capture is NOT RUN. No update advice until independent review and primary
acceptance. Then one Enchanting report/native comparison before batching professions;
numeric Knowledge/raw persistence and full-native INCOMPLETE87/149 remain unchanged.

## First independent result — comparison scope incomplete

Verifier `ses_e2137426effe5OCxn7fNNopr1x`: PARTIAL / Acceptance INCOMPLETE. Complete
current modules/new tests/integration inspected; no blocking source finding. External
temporary diff and four approved executions denied before access/execution, no retry
or bypass. Exact baseline/freeze/executable proofs remain primary-attributed. Reused
UI widgets can hold provisional text on failed publication, but prior successful
report/text are retained and failed window hidden; no existing command reopens it.
No demonstrated user-visible defect; do not claim widget-content rollback. Native
update remains blocked on reviewable exact-delta evidence; no source changes requested.

## Repository source delta for bounded static review

Primary added [k08-review.diff](k08-review.diff), the **complete two-production-file
delta** (Commands/KnowledgeCheck), 302 lines/19871 bytes, SHA256
`4c898bcd72d73dd487687386641c78f47c0860a3479ecd913b95b562d09a251c`.
Primary verified byte equality with the production section of the actual four-file
baseline diff. All four frozen review hashes remain unchanged. The artifact is an
ordinary primary-owned durable project review record; the reviewer must not retry
external access or denied executions. No change in its read-only role or permissions.

SelfTests delta is exactly the directly inspected new K08 block at7173–7706 plus blank;
old277 whole-file inverse remains primary-attributed. README delta is exactly its
directly inspected55-line prepend; prior README unchanged. Evidence/TASKS/PLAN/Q03 are
reviewed documentation, not production changes. Independent executable/hash proof is
still unavailable; request **bounded static-delta review**, not full independent
execution/native acceptance. Earlier INCOMPLETE result remains historical evidence.

## Bounded static-delta result

Verifier `ses_e2137426effe5OCxn7fNNopr1x` continuation: **COMPLETE / PASS for bounded
static-delta scope**, no blocking findings. Directly inspected the complete repository
production diff against current integration, contract, all32 new cases and README.
No external-access retries, execution or writes. Earlier INCOMPLETE result retained;
this does not claim independent hashing/execution/full-tree verification. Those proofs
remain primary-attributed. Widget-content rollback remains unestablished, with no
demonstrated user-visible blocker. Platform N/A. Native APIs/capture/responsiveness
remain NOT RUN. Primary postreview rehash: all four files and source artifact unchanged.

## Primary bounded acceptance

Primary persisted the final review, then accepted local/static K08 for one focused
user-run Enchanting evidence capture. Source/tests/production artifact unchanged after
review; README subsequently changes current-gate instructions only (reviewed README
hash above is historical). Independent execution/hash/full-tree and native gates are
not claimed complete. See current README for update/capture procedure. No numeric
policy activation or release approval.
