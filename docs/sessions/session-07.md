# Session 7 — preserved PLAN history

> Archived 2026-11-17 from original PLAN.md lines 999–1131.
> Historical approval/blocker/next-step statements below are not current instructions.
> Current requirements, acceptance limits and open work remain in PLAN.md/TASKS.md.
> Wording is intact; only relative Markdown link targets were mechanically rebased.

[Current plan](../../PLAN.md) · [Current tasks](../../TASKS.md) · [History index](README.md)

<!-- BEGIN PRESERVED PLAN BLOCK -->
### Session 7 — 2026-11-05 — T02 implementation authorized

- User explicitly requested “Lets start the implementation.” Approved T02's 14-file
  manifest and serial eight-piece queue, incorporating one compact line per pair,
  Accessory #1 → Accessory #2 → Tool, and tool stats/enchant grouped under Tool.
- T02 is READY for one synchronous implementer; primary will independently review
  the frozen result and persist findings before coordinating user client validation.
- No dependency/game installation, gameplay actions, Auctionator work, Git mutation,
  publication or release approved. Remaining field semantics keep their explicit
  unknown/acceptance gates; implementation approval is not a runtime success claim.

#### T02 initial delivery and correctness review

- Implementer delivered all 14 files and 27 fixture definitions; primary Python
  packaging/docs checks PASS and reviewed diagnostic hashes unchanged. Lua/client
  execution NOT RUN (lua5.1 absent); numeric KP and other field semantics remain open.
- Independent static review found two medium contract defects: transient same-item
  metadata loss and insufficient typed saved-payload validation. Findings persisted
  in TASKS/dashboard evidence; review CHANGES REQUIRED, runtime acceptance INCOMPLETE.
- Scoped correction pieces 9–11 are READY under the existing implementation approval.
  One implementer will fix/add regressions, then primary obtains re-review. No client
  install recommendation yet, no release or other permissions expanded.

#### T02 corrections reviewed; controlled client testing next

- R1 corrected metadata preservation/typed data validation; R2 corrected async retry
  freshness. Independent static re-review PASS, no blocking static defect identified.
  Verifier execution was denied; primary separately matched frozen hashes and reran
  Python checks PASS (23 docs/70 links/eight diagnostic hashes unchanged).
- 34 shared fixture definitions NOT RUN; no lua5.1 installed. Runtime/feature
  acceptance INCOMPLETE; numeric KP, other seven Midnight IDs, unlearning and stat
  attribution retain explicit gaps. No release or full dashboard acceptance claimed.
- Next: user backup/manual install per dashboard README, `/ca selftest` and separate
  `/cad selftest`; report exact outputs before live comparisons. All review evidence
  persisted in TASKS and dashboard evidence. No gameplay mutation/agent installation.

#### Single-letter stat refinement delivered

- User requested C/I/M/R crafting labels; R3 implements them consistently for tool
  and known enchant summaries with full-name tooltips. Gathering D/F/P remains future
  naming only. No new profession/API/enchant-ID support or collector changes.
- Focused static review PASS; primary Python checks/hash preservation PASS. 36 fixture
  definitions NOT RUN; user selftests/client checks and field-semantic gates pending.

#### First user-run T02 fixture result

- User supplied **35 passed / 1 failed** across all36 cases. Failure is the grouped
  invalid-schema/primitive-sanitization rejection case; generic assertion reports a
  table where nil expected, without subcase context. Acceptance CHANGES REQUIRED.
- Other35 fixture outcomes pass as supplied; pure fixtures do not validate live APIs.
  Pause client comparisons, preserve data and diagnose. Native NaN comparison check
  is next read-only evidence; numeric compatibility is a hypothesis, not confirmed
  cause. No source/test change or reset performed; exact report in TASKS/evidence.

#### Numeric rejection cause reproduced in client

- User output `NaN: -nan(ind) self: true bounds: true finite: false` confirms the
  old comparison guard accepts NaN while native math.isfinite rejects it. No current
  build/time/source hash or actual saved-data loss inferred.
- Scoped R4 pieces16–17 READY: shared native-aware guard across production numeric
  paths, original rejection assertions retained/labeled, added regressions. Same
  approved manifest/safety scope; independent review and user retest pending.

#### Native-aware numeric correction delivered

- R4 centralizes native finite classification across production copy/integer/typed/
  collector/view paths. Independent static review PASS; primary Python/hash checks
  PASS. Original NaN rejection assertion retained/labeled;40 definitions NOT RUN.
- Next user backup/addon-files-only update, reload and repeat both selftests. Original
  35/36 remains historical failure evidence, no corrected client pass assumed and no
  saved-data reset needed. Other field-semantic/client gates remain incomplete.

#### R4 user fixtures pass; live dashboard comparison next

- User supplied corrected dashboard **40 passed / 0 failed**, including the original
  NaN rejection and all R4 cases, plus fresh diagnostic **23/23 PASS**. Both fixture
  gates pass for these user runs; original failure/reproduction history retained.
- This is pure fixture execution in WoW, not agent/local Lua or live API evidence.
  Next controlled check: own Midnight Inscription, `/ca scan`, `/ca`, screenshot/
  status/error and native-UI comparison. Other field semantics and live acceptance
  remain incomplete; no new implementation, gameplay actions or release authorized.

#### First live Inscription row observed

- User supplied successful guarded-scan status and dashboard screenshot. Single row
  renders with accessory-first/grouped Tool, skill100/100, M152*/enchantYesM,
  concentration507/1000, Moxie260, unspent4, four unknown knowledge bars and snapshot7s.
  Sanitized evidence only; no character identifiers/raw screenshot persisted.
- Field/native-UI agreement remains to verify. Raw TRADE_SKILL_CLOSE status is
  compatible with snapshot invalidation, not scan failure. Crowded headers/excess
  blank space/raw event text recorded as proposed polish, not implemented changes.
- Next user compares skill/currencies/unspent with native UI; broader runtime,
  gear/tooltips, persistence/multi-alt and knowledge semantics remain incomplete.

#### Inscription native-UI comparison confirmed — 2026-11-06

- User confirms screenshot skill100/100, Moxie260 and unspent4 match native UI.
  This is acceptance of those fields for that case only, not concentration/cap,
  gear, knowledge totals or whole-dashboard acceptance. Next Tool-cell tooltip
  review; remaining client/field gates and proposed UI polish stay incomplete.

#### Tool item text corroborated — 2026-11-06

- User tooltip shows epic Gilded quill, +152 Multicraft and Haranir Multicrafting,
  agreeing with displayed tool/enchant labels. No exact rank/enchant amount inferred.
- CraftArmy's appended observation/slot/attribution lines are not visible amid native/
  third-party tooltip content. Clarify hover origin before accepting integration;
  no hook-conflict diagnosis or code changes. Sanitized item evidence only.

#### CraftArmy Tool tooltip confirmed — 2026-11-06

- User distinguishes native hover from new CraftArmy Tool-cell capture: native item
  and addon observation/slot/rarity/rank/stat/enchant details display together.
  Tool tooltip integration observed for this item; no enchant amount/quality inferred.
- Raw atlas text at bottom recorded as presentation polish. Next safe persistence
  check: profession closed, reload, `/ca` without rescan; no source/data changes.

#### Reload snapshot retention confirmed — 2026-11-06

- User confirms same row returns labeled snapshot after profession-close/reload and
  `/ca` without rescan: limited reload persistence/labeling PASS. No multi-alt/logout/
  numerical regeneration acceptance inferred. Next second existing Midnight Inscription
  character if available; otherwise leave multi-alt test pending. No source changes.

#### Two character rows retained — 2026-11-06

- User confirms two separate character rows, both snapshots with different ages.
  Limited two-character Inscription retention/separation PASS; context closure explains
  snapshot presentation, not proof of live-open freshness or numeric age accuracy.
- Next proposed bounded compact-UI polish remains confirmation-gated. Knowledge
  accounting, other mappings and remaining client/field acceptance stay incomplete.
  No implementation or new permission inferred from this validation response.

<!-- END PRESERVED PLAN BLOCK -->
