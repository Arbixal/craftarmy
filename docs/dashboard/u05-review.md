# U05 primary comparison and independent review

## Frozen target — 2026-11-16

User directly requested bounded UI refinements recorded in PLAN D07 U05. One writer
completed1–6 after primary's narrow old RGB-expectation amendment. No concurrent writer,
Git revision/repository, installation or release. Native U05 appearance/controls NOT RUN.

| Reviewed file | SHA256 |
| --- | --- |
| CraftArmy/Core.lua | d9ecece7d9b2dd2b0966d3c52690d430f0f2b1e249b549c640fd6667c81d0f75 |
| CraftArmy/Collectors.lua | 8a2aec1da6c15f52babbf781ed84c5cb7dcbfbbbc99727e72310ebb0406451c1 |
| CraftArmy/Data.lua | 7e889a35cf485041c6c127a408792a3b1c5982bf96cd3d05c39b26f8fabc419f |
| CraftArmy/ViewModel.lua | 22ce00ad5de73729abd068c676957814d34a0715dcc3b1861361280b67166dd2 |
| CraftArmy/Dashboard.lua | 694a8b3da3b1e5836e85349cbe801c5187f0cda20cb5e0dde5cd8782caa6d401 |
| CraftArmy/SelfTests.lua | 86deee99123f3a4df5b6000a5c177cf8237c02922e426777a2afc1863a0e4f79 |
| docs/dashboard/README.md (pre-acceptance gate) | b1856aa405a321fad6cc615dabcde4f7ea7bd5c8f21fe7905f6f8fa01e1dfd88 |
| docs/dashboard/schema.md | 16752fb5a9c2af97bed0cf2ad959486dc1d29f010a576b2c979edcdafc0bc1ee |

## Primary actual comparison and execution

Actual69-file baseline, including hidden agent config:
`/tmp/opencode/craftarmy-u05-baseline-ox5phjc_/files`; sibling manifest SHA256
`28e0dd1b2a66d5f6aa0f7e8e3ebdb07af01ee5745a961047322820a45bd7efe7`.
Writer could access it, but its proofs remain writer-performed. Primary now separately
compared the ACTUAL files, not a reconstructed or substitute comparison base.

Same69 paths, exactly10 approved changes (six Lua, README, schema, evidence, TASKS),
all59 others unchanged. Knowledge/KnowledgeCheck/Commands/Details, TOC, runners/checkers,
diagnostics/config byte-frozen. README old suffix, schema/evidence old prefixes and
entire K09-and-older TASKS suffix exact. This primary record was added afterwards.
PLAN/Q03/Q05 U05 preparation predates base; no code/test changes during primary review.

Primary inspected all old-test hunks against amended allowlist and reproduced exact
inverse: remove U05; restore five historical marker literals, four archived invocations,
five new mock style methods/root BackdropTemplate rect clause and single approved RGB
tuple. Exact old359 SelfTests hash
`71668103b8ac762b71476056197c0958fe8bb42723e7114beb218dce59b53d3e` restored.
Every other old byte/scenario/helper/runner is unchanged.

Complete five-production-file delta375lines/21698bytes SHA256
`3bfcc716900e7e218872968e5497aaeb61e51cef13ef63a2d03341b80304c2da` recomputed
from actual baseline. Durable diff is in evidence's U05 partial report, with one
explicit CONTEXT-line transcription correction just before the final report (evidence
lines9030–9039). Primary verified exactly one context mismatch and equality after that
recorded correction; do not call the uncorrected raw transcription byte-exact. Correct:

```lua
        if w.category=="Missing enchant" then tool.summaryTooltip[#tool.summaryTooltip+1]="Attention: "..w.label end
```

Fresh PRIMARY execution on frozen target:
- `lua5.1 tests/dashboard.lua`: completed409/409 (359 retained+50 U05), unchanged
  744K6/565K7 PASS; zero failures/no runner INCOMPLETE. Full temporary log
  `/tmp/opencode/craftarmy-u05-primary-dashboard.log`.
- `lua5.1 tests/run.lua`:23/23 PASS.
- `python3 tools/check_dashboard.py`:PASS (25 Markdown/89 links before this record).
- `python3 tools/check_diagnostics.py`:PASS.

These are primary-executed local checks, not independent reviewer execution or native
API/appearance/priority/menu/color proof. Fullnative INCOMPLETE87/149 and K09 focused
acceptance/all-rank limitations unchanged. Fifty new cases cover class errors/ownership/
reload/neutral/font reset, all32 visual mappings/reorder/reuse, all14 typed sorts in both
directions/active+archive, warnings, real generated menus/fallback/stale callbacks,
geometry/flat chrome/HIGH/owned Details priority/close/drag/confirmation/combat defer.

## Primary findings and independent gate

No primary blocker. Optional typed classToken is isolated from accounting; absent read
preserves known same-GUID class, old DB remains valid, invalid colors stay neutral and
recycled fonts reset. Stable visual colors never imply accounting eligibility. Tilde-only
removal retains fresh/historical warning semantics. Typed sorting doesn't parse markup/
age or borrow raw Knowledge. Menu fallback invalidates stale callbacks. HIGH dashboard
and precise owned Details DIALOG hook don't alter unrelated frames or Details source.

Independent verifier `ses_e1df38776ffeiyC5yH3UkXYDkI`: COMPLETE, **PASS for bounded
static review only**, no findings/static blockers. Reviewed corrected375-line production
delta, integration, all50 new cases/named old359 adaptations, schema/README/evidence.
Native menu/header protocol and owned Details priority hook show no static blocker;
Knowledge/freshness/attention/ownership/validation boundaries remain preserved.

Shell access denied once, no retry/bypass. Reviewer executed no tests and independently
recomputed no hashes/fulltree/inverse/post-review freeze. All409/409+744/565+23/23/Python
PASS and comparison proofs remain primary-attributed, not reviewer execution. No reviewer
edits/artifacts or concurrent writer. Native U05 remains NOTRUN; mocks do not prove
appearance/fit/priority/responsiveness. Platform N/A; fullnative/K09 limits unchanged.
Primary persisted this read-only result before the separate post-review freeze/acceptance.

## Primary acceptance — 2026-11-16

Primary post-review check: all eight reviewed source/docs hashes unchanged; all59
unowned baseline files unchanged, no path deletion/addition except this primary record,
and entire K09/older TASKS suffix exact. No source/test change during/after review.
Accept bounded U05 using primary409/409+744/565+23/23/Python execution, actual-baseline/
inverse/history/freeze proofs and independent static PASS, with reviewer execution
unavailable. Source-pinned class/menu behavior and mocks are not native UI proof.

README's hash above records the reviewed pre-acceptance gate; primary now changes ONLY
its administrative gate/update advice and appends acceptance to task/planning/evidence.
Six Lua hashes and schema remain frozen. User-managed six-file update/focused cached UI
checks are appropriate; optional class coloring needs a normal own-alt scan where old
snapshots lack classToken. No reset/migration, live offline lookup, Knowledge recapture/
full selftest, agent installation, Git/gameplay/publication/release approval. Native U05
remains NOTRUN until user reports appearance/control behavior.
