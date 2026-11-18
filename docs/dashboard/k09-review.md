# K09 primary comparison and independent review

## Frozen implementation — 2026-11-16

User approved K09 design/implementation; primary later corrected the historical-test
allowlist for already-approved typed-valid incomplete raw semantics. Sole writer stopped
after all five pieces. Review/primary acceptance remain separate from implementation.
No Git repository/revision, commits, game installation or release approval exists.

| Target file | SHA256 |
| --- | --- |
| CraftArmy/Core.lua | 168653d91ab31bb991540e57082b45d78c41e690961600537395a33bf4be0856 |
| CraftArmy/Knowledge.lua | 5c41300d521ae350ee66740c2722ca937e169bcf5f32f933a780fed96dfcc2b0 |
| CraftArmy/Collectors.lua | 4af664239054d94cb536e343dd1a7ab28aaa86493cdf3e5a67ed1f7552f2bf6f |
| CraftArmy/SelfTests.lua | 71668103b8ac762b71476056197c0958fe8bb42723e7114beb218dce59b53d3e |
| docs/dashboard/README.md (pre-acceptance gate) | 2a84ad57e4b82ff11cf60b0a7e12a62cf00092b0c8571979dac64da57d8e63f3 |
| docs/dashboard/schema.md | 80ca2be2d90025067a58435c08e40094c25822c40cd9382d42384f73f0b397f1 |

## Primary actual comparison and local validation

Actual pre-implementation baseline: `/tmp/opencode/craftarmy-k09-baseline-ao5qpous/files`,
68 files including hidden agent config. Sibling manifest SHA256
`b310e09a2b484d09bcdd0117ac02e914d7f331cc81b8e33ce7d6de034ec9f6a9`.
This is the primary's actual snapshot, not a reconstruction or writer-start substitute.
Writer could not read it and accurately attributed its separate comparison proofs.

Primary directly compared all68 paths after implementation: exactly8 approved changed
files (four Lua, README, schema, evidence, TASKS); all60 others unchanged. Path set
unchanged before this primary-owned review record was added. README old suffix,
schema/evidence old prefixes and entire K08-and-older TASKS suffix are exact originals.
PLAN/Q03 approval changes predate this baseline. No implementation files changed after
the hashes above were captured or after the following checks.

Primary independently reproduced:

- `lua5.1 tests/dashboard.lua`: completed359/359 (all309 retained+50 new), zero failures,
  no runner INCOMPLETE; unchanged744 K6/565 K7 PASS. Full log at
  `/tmp/opencode/craftarmy-k09-primary-dashboard.log`.
- `lua5.1 tests/run.lua`:23/23 PASS.
- `python3 tools/check_dashboard.py`: PASS (16 required files,24 Markdown,86 links,
  eight diagnostic hashes unchanged before this new review record).
- `python3 tools/check_diagnostics.py`: PASS.

These are primary-executed local fixture/structure results, not independent reviewer
execution or target-client API/performance proof. Complete eight-snapshot test reports
29793/50000 expanded values; no caps increased/evidence omitted. Native K09 NOT RUN;
K08 focused evidence accepted; full native suite remains INCOMPLETE87/149.

All193 new fixture path/entry/child/rank/current-cost rows independently text-compared
in exact order against Q03 by primary: PASS. Writer separately compared all auxiliary
currency projections; reviewer should inspect these and fixture synthesis limitations.
Branch labels/definitionIDs/configs/GUIDs/dynamic variants are explicitly synthetic.

Primary reviewed every changed old-test hunk against the amended allowlist. Removing
K09 and reversing ONLY the approved replacement regions restores exact original
SelfTests SHA256
`aa83f952f56d2ea0fa91d5ff0dec42b124196a85d72cc12f4bcda923d903c5fd`.
All other old bytes, case definitions/scenario loops/helpers and runner are unchanged.
Primary found10 SequenceMatcher replacement regions; grouping counts differ from
writer's11 substitution regions, not their scope or exact inverse result. The permitted
sites/current source assertions are K2 dynamic currency; E01 relabeled wrong currency;
E03 unknownKnowledge helper and cached six-character raw; E04/E05 empty-tab raw; K08
wrong-currency collector raw. Numeric-unknown/wrong-currency/owner rejections remain.

The complete three-production-file diff is durably embedded in
[evidence](evidence.md), under “K09 final local implementation after primary allowlist
amendment” / writer freeze. Primary recomputed it against the ACTUAL baseline with
the same labels and proved byte equality:117lines/7340bytes SHA256
`d7f0d1a2036309dfee192d777165620b5d059f048d7ef6dc7a56ddd5859b6b23`.
Do not rely on temporary-directory access to review this bounded delta.

## Primary read-only findings

No blocking implementation finding in the bounded production delta. Resolver handles
plain exact finite identity tuples and returns scalars; expected currencies do not fill
missing live reads. Existing formula/current-cost/topology/staging/reconciliation
guards are retained. Native raw owner and numeric tree currency are enforced on Apply
and active/archive Open. Details predicate remains exact Inscription-only. Collector
typed preflight avoids invalid raw aborting valid generic fields while preserving old
raw/trees/index as failed attempts. No-policy handling, budgets and atomic commit are
unchanged. Final Core generic-extension-marker correction is included in the frozen
delta and its additional regression; it needs independent review too.

This is primary review, not independent acceptance. Platform review N/A: no CI, hosting,
infrastructure, IAM, release or deployment changes.

## Independent review gate

COMPLETE / **PASS — bounded static scope only**. Verifier session
`ses_e1e8ba2d1ffe74UyITuMqTOx1C` reports no findings or static blockers after reviewing
the entire117-line production delta (including final generic-marker correction),
current integration, all50 additive cases/all193 native-derived paths and auxiliary
rows, named historical adaptations and README/schema truthfulness. Currency/identity,
raw/tree attribution, Details scope, partial-raw/numeric distinction, snapshot/index/
freshness preservation, reconciliation, budgets and hierarchical localized hovers
match settled K09. No reviewer edits/artifacts or observed moving target.

Reviewer inspected both runners/checkers, then attempted `lua5.1 tests/dashboard.lua`:
permission denied before execution. No retry/workaround; remaining three commands not
independently run. All execution, hashes/fulltree/inverse proof and combined29793/50000
result remain primary/writer-attributed as stated, NOT independent executable proof.
No independent post-review hash comparison occurred. No native validation implied.
Platform N/A. Primary persisted this report before the separate acceptance/freeze gate.

## Primary acceptance — 2026-11-16

After persisting the independent report, primary recomputed all six frozen hashes above:
unchanged. All60 unowned actual-baseline files/path set unchanged, with only this added
primary review record beyond the approved eight changed paths. No implementation moved
during/after review. Primary accepts the bounded implementation based on its own full
359/359+744/565+23/23/Python execution, actual-baseline/inverse/projection/freeze proofs
and independent static PASS/no findings, with independent execution unavailable.

README's pre-acceptance hash above now names a historical reviewed gate: primary changes
ONLY its administrative gate/update advice after acceptance, and appends acceptance to
PLAN/Q03/TASKS/evidence. Four Lua source hashes and schema remain frozen. This is not a
new source delta or a claim of independently executed checks. K09 native UI/persistence
still NOT RUN; all-rank costs and historical full-native INCOMPLETE remain unchanged.
Next user-managed four-file update and focused normal-dashboard checks are appropriate;
no Git/game installation/publication/release approval is implied.

## Subsequent focused user confirmation — 2026-11-16

User confirms all values match expectations and behave as expected following the
requested K09 dashboard round. Primary accepts focused value/normal-use validation
as complete at that reported scope. Individual procedure/reload/timestamp/timing detail
was not separately supplied; no detailed execution or failure-path proof is inferred.
No further routine Knowledge checks requested. This later native/user evidence does
not change the independent review's static-only limits or prior local proof attribution.
All-rank costs/full-native INCOMPLETE and separate dashboard/guide/release gates remain.
