# Session 4 — preserved PLAN history

> Archived 2026-11-17 from original PLAN.md lines 874–911.
> Historical approval/blocker/next-step statements below are not current instructions.
> Current requirements, acceptance limits and open work remain in PLAN.md/TASKS.md.
> Wording is intact; only relative Markdown link targets were mechanically rebased.

[Current plan](../../PLAN.md) · [Current tasks](../../TASKS.md) · [History index](README.md)

<!-- BEGIN PRESERVED PLAN BLOCK -->
### Session 4 — 2026-11-05 — T01 implementation authorized

- User explicitly approved “Yes implement T01.” Recorded scoped execution approval
  in TASKS.md and made its six-piece queue READY.
- Approval does not include dependency/game installation, live-client testing,
  Auctionator mutations, Git operations, or release/publication.
- Primary will dispatch one implementer, then independently verify the frozen result.
  Runtime/client evidence remains a separate gate; no success is assumed in advance.

#### T01 delivery and review

- Implementer delivered the scoped nine files: diagnostic addon, 18 shared fixtures,
  structural checker, safe manual guide, and evidence matrix. Execution is PARTIAL
  because fixture/client validation is unrun, not because a production addon exists.
- Interface 120105 is source-corroborated, not installed-client verified. Probes are
  manual/read-only; Auctionator methods are not invoked. No installation or release.
- Independent verifier found no concrete blocking defect in the frozen static review.
  Its shell checks were permission-denied; primary separately ran the structural
  command (PASS) and confirmed all eight delivered code/tool/README hashes match.
- Persisted review/check attribution and INCOMPLETE runtime acceptance in TASKS.md
  and docs/diagnostics/evidence.md. Q03/Q04 remain open; no client capability inferred.
- Next: user manually loads the diagnostic and runs `/cad selftest`, then labeled
  Inscription scans per docs/diagnostics/README.md. Runtime results must be recorded.

#### First user-run client evidence

- User reports 18/18 fixtures PASS and supplies a diagnostic 0.1.0 open-Inscription
  sample from Retail 12.1.5 (70783), Interface 120105, with Auctionator 341 loaded.
- Captured base expansion skill/cap/modifier, concentration, three rare/rank-5 item
  instances and their stats/icons, top-level knowledge identities/unspent evidence.
  Persisted a sanitized summary, not raw names/realm/GUIDs or full item links.
- Capture is truncated: the 64-node prefix omits late path nodes, and the byte budget
  drops later tree detail. Current capture acceptance CHANGES REQUIRED; no zero-tree
  allocations or correct knowledge totals inferred. First fixtures do not cover this.
- Proposed next action: compact path-first/all-tab-priority capture and regressions,
  then a fresh user retest. No correction implemented; Q03/Q04 remain open and no
  dashboard, source installation, gameplay mutation, or release authorized.

<!-- END PRESERVED PLAN BLOCK -->
