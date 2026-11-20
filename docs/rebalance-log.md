# Rebalance log

## Config

- planning_doc: PLAN.md
- task_doc: TASKS.md
- conductor: AGENTS.md
- agent_definition: .opencode/agents/implementer.md
- threshold_words: 15000
- recency_keep_sessions: 3

## Rules

No automatic cooling rules promoted yet.

## Runs

### 2026-11-05 — scaffold

- Detected greenfield: empty workspace, no existing planning documents or code.
- User requested living-plan write-up and approved the file/directory manifest.
- Reused the existing conversation proposal; no additional grill rounds run.
- Recorded user requirements as D01–D03 and workflow approval as D04.
- Preserved recommendations in docs/design.md; opened Q01–Q06 and parked P01–P02.
- Created the conductor, task contract, and model-inheriting OpenCode implementer.
- No documents overwritten or relocated; no implementation queue promoted or run.
- No source implementation, Git initialization, commit, release, or deployment.
- Validation: read-only Python check passed for 14 Markdown files, 29 local
  links/anchors, required directories, template completion, and expected unpinned
  implementer frontmatter. No application or in-game tests run.

### 2026-11-05 — grill (in progress; Round 1 recorded)

- Resumed existing decision tree in the primary session; did not re-open D01–D04.
- Asked seven product-scope/priority questions; user accepted all recommendations.
- Two decision promotions: D05 (scope/audience/delivery) and D06 (knowledge/build policy).
- Appended dated Round 1 history to Q01, Q02, Q05, and Q06 without rewriting earlier entries.
- Q01 release coverage decided; exact client/build validation remains Q03.
- Q02/Q05/Q06 retain dependent detail. Q03/Q04 factual checks remain open; P01/P02 dormant.
- Session 2 records progress; Round 2 pending. No implementation or delegation started.

### 2026-11-05 — grill (in progress; Round 2 recorded)

- User answered six questions, refining gear/knowledge display and selecting Inscription.
- Two decision promotions: D07 (dashboard semantics) and D08 (route targets/architecture).
- Appended Q02/Q03/Q05/Q06 histories and opened Q07 for material/resource/workflow policies.
- Updated the design reference for three rarity/rank indicators, tool/enchant stats,
  knowledge bars/tooltips, passive warnings, and Inscription-first delivery.
- User accepted adaptive curated routes and three targets; no universal optimizer.
- Round 3 pending; no implementation, diagnostic addon, or agent run started.

### 2026-11-05 — grill (in progress; Round 3 recorded)

- Recorded seven answers; user refined Warband inclusion to opt-in and chose one
  reusable `CraftArmy` export list rather than per-character/profession/target lists.
- Two promotions: D09 (shopping/resource/manual execution) and D10 (bars/archiving).
- Appended Q02/Q05/Q06/Q07 histories; product policies Q02/Q05/Q07 now decided.
- Opened Q08–Q10 for remaining guide content/quality/compatibility boundaries.
- One read-only general agent researching Q03/Q04 public-source evidence under the
  living-plan fact-finding workflow; primary retains all document ownership.
- No implementation, installed dependencies, runtime tests, release, or Git operations.

### 2026-11-05 — grill factual-research handoff persisted

- General agent returned PARTIAL; primary recorded pinned Retail source evidence,
  secondary-source Auctionator API candidates, inaccessible upstream, and live gaps.
- Updated Q03/Q04, PLAN.md Session 2, and TASKS.md planning-research report/run state.
- No product promotions from source evidence; Q03/Q04 stay open. No user response
  to Round 4 inferred from the automatic research notification.
- Validation limited to public reads; no installed client/API, runtime, or release checks.

### 2026-11-05 — grill complete (Round 4; four rounds total)

- User accepted all three final recommendations; promoted D11 (knowledge-source scope)
  and D12 (reagent quality/cost and compatibility behavior).
- Appended Q08/Q09/Q10 dispositions; parked the full weekly tracker in P03.
- Four rounds, 23 numbered product questions; decisions D05–D12 added during grill.
- All product branches disposed. Q03/Q04 remain factual evidence gaps; Q06 remains
  primary-owned tooling/handoff preparation. P01/P02 stay parked.
- Updated PLAN.md, TASKS.md, and design reference; no task queue promoted or executed.
- Next proposed action: prepare an approval-gated API-feasibility task contract.
- No addon implementation, runtime tests, installation, Git operations, or publication.
- Final read-only Python documentation check: PASS for 19 Markdown files, 43 local
  links/anchors, D01–D12 uniqueness/order, required directories, template completion,
  expected implementer configuration, and absence of Lua/TOC implementation files.

### 2026-11-05 — task-contract preparation

- User authorized the next planning step; drafted T01 in the existing TASKS.md contract.
- Six unstarted pieces; explicit nine-file future manifest, test commands, evidence
  gates, ownership, and no-mutation boundaries. Execution remains approval-blocked.
- Recorded missing local Lua tooling and no-install test strategy in Q06/PLAN.md.
- No new source/test files, addon install, interpreter install, task execution, Git
  mutation, or publication. Q03/Q04 remain unresolved technical evidence questions.
- Contract check PASS: 19 Markdown files, 46 local links/anchors, required sections,
  six unstarted pieces, approval gate, and no Lua/TOC implementation. No code tests run.

### 2026-11-05 — T01 implementation and static review

- User explicitly approved T01. One synchronous implementer delivered the nine-file
  scoped harness/tests/docs; task remains PARTIAL for unrun fixture/client acceptance.
- Independent verifier statically reviewed frozen files/APIs; no concrete blocking
  finding. Verifier shell checks were permission-denied, accurately recorded NOT RUN.
- Primary separately inspected/reran the Python structural checker (PASS, exit 0)
  and matched all eight recorded source/tool/README hashes. No hashed files changed.
- Persisted review attribution/results in TASKS.md, evidence.md, PLAN.md and Q03/Q04;
  updated conductor for real project state. No live claims; Q03/Q04 remain open.
- No installs, gameplay/list mutations, credentials, Git operations, publication, or
  deployment. Next: user-run WoW fixtures and labeled Inscription evidence.

### 2026-11-05 — first client evidence recorded

- User reports 18/18 fixtures PASS and an open-Inscription capture on 12.1.5/70783,
  Interface 120105, diagnostic 0.1.0, Auctionator 341.
- Recorded sanitized field observations and attribution in evidence.md, TASKS.md,
  PLAN.md and Q03/Q04. Did not persist raw identifiers or full item links.
- Live sample exposes 64-node-prefix and byte-budget knowledge coverage limitations;
  capture acceptance CHANGES REQUIRED, broader feasibility INCOMPLETE.
- Proposed a compact path-first repair plus regression tests; no repair source changed,
  task queue executed, gameplay/list mutation, installation, or release performed.

### 2026-11-05 — T01 R1 approved, implemented, and statically reviewed

- User approved the correction; primary specified R1 pieces 7–10 and one implementer
  delivered 0.1.1-diagnostic within the existing manifest. No stored samples erased.
- Path-first/all-tab capture, coverage reserve within original limits, explicit
  omissions/failures, and five new fixtures (23 definitions) delivered.
- Primary structural check PASS and new eight-file hashes match. Independent static
  review COMPLETE with no blocking finding; verifier shell checks permission-denied.
- Persisted review/check attribution, revised evidence identity and retest gate.
  Runtime acceptance remains INCOMPLETE; original 18/18 is not a revised test result.
- Next: user manual update and fresh 23-case fixture/open-Inscription capture.
  No dependency/game installation by agents, gameplay/list mutation, Git, or release.

### 2026-11-05 — R1 user validation recorded

- User reports revised 23/23 fixtures PASS and all 35 Inscription paths captured
  without truncation/failure/drops. Specific capture correction accepted PASS.
- Recorded sanitized mixed-rarity/stat/concentration evidence and original-history
  retention. Broader feasibility remains INCOMPLETE; Q03/Q04 remain open.
- Pinned Blizzard rank-display source confirms variable unlock-entry exclusion;
  conditional arithmetic reconciles raw 277 to shared spent 260, not a production rule.
- Updated evidence, task status, Q03 and PLAN. No source changes or raw character
  data persisted; no agent-run client actions, installs, mutations or release.

### 2026-11-05 — targeted currency/enchant evidence recorded

- User confirmed currency 3261 name/balance as Artisan Scribe's Moxie 240.
- User confirmed the quill was unenchanted during the prior scan, now enchanted;
  positive tooltip/stat observation remains pending. No universal absence inference.
- Updated TASKS.md, evidence.md, Q03 and PLAN; no code changes, raw character data,
  new implementation, agent client action, installation, or release.

### 2026-11-05 — positive enchant observation recorded

- User's typed permanent-enchantment filter returned Haranir Multicrafting on the
  quill. Recorded presence/localized stat-name evidence and absent rightText semantics.
- Icon/rank not copied and numeric enchant ID not observed; no inferred quality or
  universal localized parser. No source changes, raw character data, game actions,
  installation or release.

### 2026-11-05 — numeric enchant mapping recorded

- User reported equipped-instance enchant ID 8005 after the positive Haranir
  Multicrafting line, supporting this ID's Multicraft category on the tested client.
- Persisted scoped mapping/provenance in evidence.md, Q03, TASKS/PLAN. No rank,
  bonus amount, other enchant IDs/locales, or new code inferred. No source changes,
  game action by agents, installations, Git operations, or release.

### 2026-11-17 — task-history eviction (11557 → 109 lines)

- User requested TASKS cleanup before addressing the reported table redraw. Primary
  showed the11-archive manifest, destinations, live-item carve-outs, supporting docs,
  stale-state removal and projected100–150line hot file; user confirmed “Yes”.
- Detected full existing workflow. PLAN13149words was below the15000word threshold;
  no PLAN structural rebalance or unrelated history cleanup performed.
- TASKS before:11557lines/82540words,121checked and2historical blocked implementation
  boxes.11537lines (99.83% of the old file) were accumulated task-block material.
  T02's remaining live conditions were extracted before archiving its partial history;
  archiving does not imply those conditions or broader T01/T02 acceptance are complete.
- Created `docs/tasks/archive/{S01,U05,K09,K08,E05,E04,E03,E02,E01,T02,T01}.md`.
  Original line ranges/dates are indexed in `docs/tasks/README.md`. All11blocks copied
  mechanically, wording intact except17relative Markdown link-target rebases. Wrappers
  mark historical ACTIVE/BLOCKED/next-step labels non-executable. No archive overwritten.
- Original backup taken BEFORE changes:
  `/tmp/opencode/craftarmy-task-eviction-ogqkfnou/TASKS.md.bak`.
  Original TASKS SHA256:
  `691e93b6236e895016a89137eedd42c284697f71bc0ec0b7c26bc1bd8be6c797`.
  Same directory holds before-files.json and archive-manifest.json (source ranges,
  source/rebased hashes, link-token transformations and per-block retention results).
- All11inverse comparisons restore exact original block bytes. Reconstructed original
  header +11restored blocks +removed trailing8-line obsolete Done index equals the full
  backup byte-for-byte. Original two blocked boxes remain intact in archived T02.
- Removed the obsolete hot Done paragraph saying the production dashboard was unbuilt;
  its T01-R1 result is duplicated in retained T01 history. New TASKS retains current
  status/run state, no active implementation queue, redraw/open acceptance gaps, deferred
  priorities, validation rules and a Done/history index. It is109lines/902words, a99.06%
  line reduction. No pending implementation/future work discarded or relabeled PASS.
- Retained all11legacy top-level task anchors; existing PLAN/Q03/Q06 T02 links still
  resolve. Added task/docs index and `docs/references/validation-and-recovery.md` for
  reusable lessons, scripts/artifact pointers and recovery/evidence policy. Current
  addon manifests remain in dashboard/diagnostic READMEs, not buried solely in archives.
- AGENTS now states check→collapse→evict and the what-never-leaves list. No automatic
  cooling rule promoted: further relocations still require a confirmed manifest.
- Recorded latest user evidence in PLAN/Q03/Q05/dashboard README/evidence/S01 review:
  multiple previously blocked scans succeed, older snapshots correct; frequent table
  disappearance/reappearance on profession open/close remains unresolved. No inferred
  timings/migration steps/full UI acceptance, diagnosis or redraw fix. No new test round.
- Validation performed: all original question/evidence bytes retained as prefixes;
  only9approved existing documentation files changed,13new documentation files added,
  no paths removed. All other65original file hashes unchanged, including addons,
  diagnostics, tests, tools and agent configuration. Historical fixture463/463+744K6/
  565K7/23 results retained, NOT rerun or presented as new Lua execution.
- `python3 tools/check_dashboard.py`:PASS17required/42Markdown/170links, all eight
  diagnostic hashes unchanged. `python3 tools/check_diagnostics.py`:PASS. These are
  structural/docs checks only. FullnativeINCOMPLETE87/149/allrankUNVERIFIED unchanged.
- No source edits, new writer/delegation, dependency/game installation, private saved
  data reads, native probe/selftest chase, Git mutations, publication or release.

### 2026-11-17 — PLAN rebalance (13266 → 3058 words)

- User requested PLAN rebalance below the default threshold, then confirmed “Yes” to
  the proposed D05/D07 histories, nine session archives, two indexes, current summaries,
  legacy anchors, conductor/ledger changes and approximately 2500–3500-word hot plan.
  This is an approved history split, not wholesale cooling of still-active requirements.
  All twelve decisions remain hot; no new product decision or implementation authorization.
- Explicit **one-time exception**: archive all nine November 5–7 session logs, rather
  than keeping the last three. Current status stays inline/in TASKS. Future policy and
  `recency_keep_sessions: 3` are unchanged; next session number is 10. No automatic
  cooling rule promoted and no recurring-reason promotion candidate established.

| Material | Destination | Original PLAN lines | Reason |
| --- | --- | --- | --- |
| D05 full history | [D05](decisions/D05-history.md) | 78–331 | Accumulated profession/evidence/delivery narrative; current scope retained |
| D07 full history | [D07](decisions/D07-history.md) | 343–675 | Superseded UI iterations and storage chronology; latest requirements retained |
| Session 1 | [01](sessions/session-01.md) | 773–786 | Older scaffold history; approved exception |
| Session 2 | [02](sessions/session-02.md) | 787–854 | Older design interview; approved exception |
| Session 3 | [03](sessions/session-03.md) | 855–873 | Older task preparation; approved exception |
| Session 4 | [04](sessions/session-04.md) | 874–911 | Older diagnostic delivery/evidence; approved exception |
| Session 5 | [05](sessions/session-05.md) | 912–977 | Older diagnostic correction/evidence; approved exception |
| Session 6 | [06](sessions/session-06.md) | 978–998 | Older dashboard preparation; approved exception |
| Session 7 | [07](sessions/session-07.md) | 999–1131 | Older dashboard delivery/evidence; approved exception |
| Session 8 | [08](sessions/session-08.md) | 1132–1181 | Older UI polish; approved exception |
| Session 9 | [09](sessions/session-09.md) | 1182–1618 | Older table/Knowledge/performance history; approved exception |

- Original backup captured before any edits:
  `/tmp/opencode/craftarmy-plan-rebalance-d_i4j_z1/PLAN.md.bak`.
  Original SHA256:
  `50980851c75dc9b7cd863037a1be9820eda5cc79b95c043cadb41bb6085a3c5a`.
  Same directory contains `before-files.json` (87 original files) and
  `archive-manifest.json` (exact offsets/ranges, source/rebased hashes and transformations).
- Eleven archives preserve **1433 original lines / 11829 words**. Wording is unchanged
  except six mechanical relative-link rebases (D05 two, D07 three, Session 6 one).
  All eleven inverse comparisons recover original source blocks exactly. Wrappers mark
  old approval/blocker/next instructions historical. Existing archives were checked after
  continuation, not recreated or overwritten blindly.
- Created [decision index](decisions/README.md) and [session index](sessions/README.md).
  PLAN is now **463 lines / 3058 words**, down from 1630 / 13266 (76.95% fewer words).
  Current scope, 46-character/future-growth requirement, shared/independently bounded
  storage safeguards, scheduling, successful refresh/retention evidence, redraw issue,
  guide priorities and deferred Details/recipe semantics remain visible.
- Nine other decision bodies survive as exact prefixes; D02 keeps its original field
  list and replaces superseded pending-UI wording with explicit D07/D10 pointers.
  D01/D04/D10 receive clarifications; D10 explicitly supersedes the historical
  Inscription-only numeric/raw gate with approved eight-profession K09 semantics,
  without widening Details or claiming all-rank proof. No requirements cancelled.
- All **106** original PLAN heading anchors retained (including 87 historical navigation
  aliases), all twelve decision IDs preserved. Existing D05/D07 task-archive backlinks
  still resolve. All thirteen new archives/indexes are reachable from PLAN/TASKS.
  Link scan flagged the older storage proposal as unreferenced; PLAN now links it as
  historical rationale, explicitly not the implemented contract. No document relocated
  beyond the approved manifest. AGENTS explains hot/history navigation and the exception.
- Validation: `python3 tools/check_dashboard.py` PASS (17 required files, 55 Markdown
  documents, 263 local links/anchors, eight diagnostic hashes unchanged);
  `python3 tools/check_diagnostics.py` PASS. Structural/documentation evidence only,
  not new Lua execution, native APIs or performance validation.
- Final scope: only PLAN, AGENTS and this append-only ledger changed among 87 original
  files; thirteen new documentation files, no deletions. Other 84 original files,
  including TASKS, question/evidence histories, addon/diagnostics/tests/tools and agent
  configuration, remain hash-identical. All sixteen reviewed source/check hashes retained.
- Historical full native **INCOMPLETE 87/149**, all-rank **UNVERIFIED**, independent
  execution/comparison limitations and missing external bundle remain unchanged.
  No writer, redraw/source/test change, repeated capture/IDs/full-selftest chase,
  dependency/game installation, private data reads, Git operation, publication or release.

### 2026-11-18 — TASKS completed-queue eviction (4521 → 156 lines)

- User requested “Cleanup TASKS.md”, then explicitly confirmed “Yes” to the proposed
  twelve-queue archive manifest, prior status/housekeeping snapshot, current-state rewrite,
  history index, reusable lessons and this ledger. No active implementation writer.
- Full planning workflow present; PLAN696lines/5345words is below15000word threshold.
  No PLAN rebalance, agent/source edits or unrelated history relocation performed.
- Before: TASKS4521lines/34884words,50checked and3unchecked boxes. Completed queue bodies
  occupied4312lines/95.4%. No unchecked implementation pieces inside the twelve queues.
- Created `docs/tasks/archive/{U15,U14,U13,U12,U11,U10,U09,U08,M01,U07,U06,R01}.md` and
  `docs/tasks/archive/dashboard-status-2026-11-18.md`; no existing archive overwritten.
  Source ranges and run dates are indexed in `docs/tasks/README.md`. Queue wording is
  preserved, with33relative Markdown targets rebased mechanically. Snapshot retains the
  other209lines, including stale status/open/deferred/index/maintenance wording.
- Backup taken BEFORE changes at
  `/tmp/opencode/craftarmy-task-cleanup-20261118-6g8r1e45/TASKS.md.bak`.
  Original SHA256:
  `23075cbc91c5c36eba57f216bb860ecadf95201d17eafcf8f414445a069563ff`.
  Same directory holds `before-files.json` (136original files), `archive-manifest.json`
  (ranges, hashes and exact link-token transformations) and `original-anchors.json`.
- Current TASKS156lines/1567words retains accepted crafting-dashboard sign-off, the
  five-profession expansion priority/API-capture gate, no executable queue/writer, open
  semantics/attribution/estimate/evidence limits, deferred guides/Details/parked work,
  validation rules and all23queue-history links. No fixed cap/reset/forced-recovery scan.
- Removed stale pending dashboard sign-off/C1–C6 instructions from the LIVE view and
  updated resolved redraw/old milestone summaries. Exact old wording survives in the
  historical snapshot. No unresolved field or native evidence condition marked PASS.
- All137pre-cleanup TASKS heading/explicit anchors retained. Old generic section anchors
  now sit beside their matching queue index rows, leading readers to the archive.
- Reusable hyperlink/instance-metadata, normal-vs-Shift tooltip, observed-vs-estimated,
  filtering/grouping and redraw/coalescing lessons added to the existing operational
  reference. Existing addon/script/asset inventories remain in their READMEs/manifest;
  the task index links current capability research and the icon manifest.
- AGENTS already states check→collapse→evict, confirmed manifests, no active writer and
  the what-never-leaves rule; no conductor edit needed. No automatic cooling rule promoted.
- Final retention verification PASS: all14source segments in13archives, with33link rebases
  reversed, reconstruct the entire original4521-line file byte-for-byte. No gaps or lost
  lines. All137original heading/explicit anchors retained; no duplicate explicit aliases.
- Final scope verification PASS: exactly4approved existing docs changed (TASKS, task
  index, operational reference and this log),13new docs, no original paths removed.
  Other132original files hash-identical, including addon/diagnostics/tests/tools/media/
  agent configuration and all pre-existing uncommitted planning/question/audit work.
  Results recorded in `verification.json` alongside the backup/manifest.
- `python3 tools/check_dashboard.py`:PASS17required/85Markdown/468local links and anchors,
  eight diagnostic hashes unchanged. `python3 tools/check_diagnostics.py`:PASS9required/
  exact packaging/order/metadata. `git diff --check`:PASS. Structural/documentation and
  retention evidence only, not Lua/native validation. TASKS line reduction96.55%; word
  reduction95.51%. All current-state limits and deferred work remain visible.
- No Lua/native suite execution claimed; existing512/all19/744K6/565K7/23 results are
  retained history only. Full native **INCOMPLETE87/149**, all-rank **UNVERIFIED**, quantified
  offline estimate accuracy and independent-execution limits remain unchanged.
- No addon/tests/tools/media edits, new writer/delegation, dependency/game installation,
  private SavedVariables access, gameplay/reset actions, commit/push/publication or release.
