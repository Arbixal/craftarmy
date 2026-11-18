# D05 — preserved PLAN history

> Archived 2026-11-17 from original PLAN.md lines 78–331.
> Historical approval/blocker/next-step statements below are not current instructions.
> Current requirements, acceptance limits and open work remain in PLAN.md/TASKS.md.
> Wording is intact; only relative Markdown link targets were mechanically rebased.

[Current plan](../../PLAN.md) · [Current tasks](../../TASKS.md) · [History index](README.md)

<!-- BEGIN PRESERVED PLAN BLOCK -->
### D05 — Initial scope, audience, and delivery order 🔨

- First release targets Midnight's eight primary crafting professions: Alchemy,
  Blacksmithing, Enchanting, Engineering, Inscription, Jewelcrafting, Leatherworking,
  and Tailoring. Older expansions, gathering, Cooking, and Fishing are outside the
  first release. Verify the exact supported client build under Q03.
- Build personal-first, structured for later publication. Defer distribution-platform
  integration and broad localization work, not correctness or data safety.
- Validate the APIs, complete the dashboard, then deliver one complete guide before
  expanding guide coverage. The guide remains part of the product commitment.
- Source: user accepted Round 1 recommendations 1, 6, and 7, 2026-11-05.
- Next dashboard coverage milestone selected2026-11-10: user says “Yes, let's
  proceed” with dashboard completion, then chooses **Enchanting** as the next
  profession available for native checks. Verify its target-client identity/fields
  before enabling mappings; do not extend Inscription-only Knowledge accounting by
  assumption. Details improvements remain parked. Other six professions follow later.
- Enchanting identity evidence2026-11-10: user reports “Midnight Enchanting skillLine
  2909 parent 333 profession 9 skill 81 100.” Enable this identity in a bounded first
  dashboard slice using existing guarded collection. This does not verify a Moxie
  mapping, equipment/stat semantics or Knowledge accounting for Enchanting; keep those
  unknown where not evidenced, and preserve the Inscription-only numeric policy.
  Task E01 is identity/scan enablement, not complete Enchanting acceptance.
- E01 local implementation exposed a saved-data boundary: native-policy raw Knowledge
  is Inscription-only in Core as well as numeric evaluation. Preserve both validators.
  For scans outside exact2913/773/13/11, emit an unsupported knowledgeRaw attempt with
  no value; existing tab discovery may still supply named unknown bars. No schema
  widening, numeric-policy reuse or stored unverified raw report. Generic fields must
  commit normally. Add this narrow collector guard and retain rejecting regressions.
- E01 delivered2026-11-10: native identity registry plus unsupportedraw boundary,
  local231/231+744K6/565K7+diagnostic23/23/bothPythonPASS; primary baseline/inverse
  proofs and independent scoped static review PASS/no blockers. Native Enchanting
  dashboard comparison/responsiveness/persistence remain pending. Moxie/numeric
  Knowledge unverified; Details unchanged. Next focused normal scan, no fullselftest.
- E01 native follow-up2026-11-10: user confirms skill, equipment, concentration and
  Unspent KP match the native UI, with no noticed performance issues or errors.
  Accept that focused normal-use/value comparison, not every stat/enchant/cap/API
  edge case or measured latency. Closed-context/reload preservation remain pending;
  Moxie/numeric Knowledge still unverified. Next read-only cached dashboard check.
- E01 closed-context follow-up2026-11-10: user confirms the same Enchanting values
  remain after closing native Enchanting and reopening the dashboard without scanning.
  Record scoped saved-data preservation; reload persistence is next and not yet proven.
- E01 reload follow-up2026-11-10: user confirms the same values survive after reload
  with Enchanting closed and no new scan. Focused validation is complete for reported
  skill/equipment/concentration/Unspent KP, normal-use behavior and closed/reload
  preservation. This completes E01's bounded slice, not full Enchanting coverage.
  Next verify Moxie mapping; numeric Knowledge remains separate/unverified.
- Moxie follow-up2026-11-10: user query returns `3258 Artisan Enchanter's Moxie 415`
  and the balance matches native Enchanting. Enable3258 for verified skill line2909;
  415 is an observation, never a default. User supplies all11 profession currency IDs
  and authorizes pre-inclusion, with Moxie checked in each profession's initial native
  dashboard round instead of a separate ID-discovery step. Store the full supplied
  catalogue with provenance; activate mappings only for verified profession identities.
  Alchemy3256, Blacksmithing3257, Enchanting3258, Engineering3259, Herbalism3260,
  Inscription3261, Jewelcrafting3262, Leatherworking3263, Mining3264, Skinning3265,
  Tailoring3266. Only Enchanting/Inscription have recorded direct native currency/UI
  evidence; the others are user-supplied, not yet client-validated here. Gathering IDs
  are retained as future reference without widening crafting-only D05 scope.
- E02 delivered2026-11-10: complete supplied Moxie catalogue with provenance and
  active Enchanting3258/Inscription3261 mappings only. Local238/238+744K6/565K7+
  diagnostic23/23/bothPythonPASS; primary exact-baseline proofs and independent scoped
  static review PASS/no blockers. Native Enchanting dashboard Moxie comparison next;
  do not repeat E01 cache checks or future profession currency-ID discovery rounds.
- E02 native follow-up2026-11-10: user confirms dashboard Moxie matches the native
  balance. Bounded E02 mapping/display validation is complete; no further update,
  currency query or cache/selftest repeat is needed. This is balance agreement, not
  native threshold/failure-path proof. Enchanting numeric Knowledge remains unverified.
- User requests next steps2026-11-10: proceed with Enchanting Knowledge feasibility.
  First confirm current config/tab identifiers via targeted read-only native queries,
  then settle safe complete metadata capture before any numeric-policy implementation.
  Existing `/ca knowledgecheck` is Inscription-only and its command drains jobs
  synchronously; bounded job units do not prove frame-stepped native execution.
  Do not request it for Enchanting or promise responsive full capture without resolving
  that execution boundary. Details and all production accounting remain unchanged.
- Native Enchanting identifiers2026-11-10: config37471400; ordered tabs1155,1154,
  1153,1152. Config ID is a current character observation, not a global constant.
  User offers batching other professions' identifier queries; collect child identity
  plus config/tabs together for the six remaining crafting professions. This can
  reduce lookup rounds but does not establish complete Knowledge accounting support.
- Batch native identities received2026-11-10 for Alchemy2906/171/3, Blacksmithing
  2907/164/1, Engineering2910/202/8, Jewelcrafting2914/755/12, Leatherworking2915/165/2,
  Tailoring2918/197/7 (child/parent/family). Current configs/ordered tabs preserved in
  Q03, never hardcoded. Enable these six identities and supplied Moxie mappings in one
  bounded dashboard slice E03, then batch initial field/Moxie comparisons. This fills
  existing eight-crafting-profession scope, not gathering or proven Knowledge support.
  Keep non-Inscription numeric Knowledge/raw-persistence and Details gates unchanged;
  safe full Knowledge evidence capture remains the following separate step.
- E03 delivered2026-11-10: eight crafting identity/Moxie mappings enabled through
  registry-only changes. Local251/251+744K6/565K7+diagnostic23/23/bothPythonPASS;
  primary actual-baseline/inverse proofs and independent scoped static review PASS.
  Initial native six-profession field/Moxie/normal-use comparison is next; no complete
  eight-profession/API/Knowledge acceptance implied by identity evidence or fixtures.
- E03 native batch follow-up2026-11-10: user confirms skill/Moxie/concentration match
  for all six new professions and survive reload. Accept those reported values and
  persistence, not unreported equipment/Unspent KP/performance or full API coverage.
  Resourcefulness enchant displays `?`; investigate its exact equipped enchant ID/
  native label before adding a category mapping. Current registry contains only8005
  Multicraft. Unknown remains distinct from confirmed no enchant; no new code yet.
- Enchant evidence/policy2026-11-10: Engineering diagnostic reports `Enchant: yes;
  ID 7977; stat: ?; amount/rank unknown`; user identifies it as Resourcefulness.
  User supplies Resourcefulness7977, Multicrafting8005, Ingenuity8035, Deftness8033,
  Finesse8003, Perception7975 and requests pre-inclusion followed by display verification,
  rather than separate discovery for each ID. Add exact ID/category entries with
  provenance; keep canonical existing display `Multicraft` for8005. Add only established
  D/F/P category labels needed to render those supplied enchants, not gathering families
  or guessed stat API keys. Gathering scanning remains out of scope. Only7977 and8005
  have recorded equipped/native category evidence here; other four are user-supplied.
  Never infer amounts/ranks/absence or map additional IDs by similarity. Task E04.
- E04 delivered2026-11-10: exact six enchant mappings and D/F/P display labels only;
  local264/264+744K6/565K7+diagnostic23/23/bothPythonPASS, primary actual-baseline/inverse
  proofs and independent scoped static review PASS/no blockers. Next normal Engineering
  scan verifies7977 full Resourcefulness display; no repeat of accepted field/cache
  checks. Remaining supplied categories are pre-included, not native-accepted by fixtures.
- E04 native follow-up2026-11-10: user confirms Engineering shows Resourcefulness.
  Bounded7977 display validation complete. New report: known-unenchanted tools show?.
  Expected policy remains blank=confirmed absence, ?=unknown/unmapped, full name=known
  category. Static inspection finds enchant display also gated by whole-tool
  metadataReady (including unrelated rank/stat reads); this can suppress observedID0.
  Obtain one affected Shift-hover diagnostic before choosing a fix; do not turn all?
  into absence or claim the native cause established from source inspection alone.
- Absence follow-up2026-11-10: affected diagnostic says `Enchant: unknown;
  invalid/missing enchant field`. Screenshot shows a fresh observed Enchanting tool
  (Runed Brilliant Silver Rod, item244176, slot20, rare/rank5) and that parser error;
  its Resourcefulness stat line alone is not enchant evidence. This sample points to
  parsing, not suppressed ID0 display. Documented item links omit zero-valued fields;
  an explicitly empty enchant field is valid zero/absence when instance data is ready
  and no typed-positive conflict exists. Current digits-only parser rejects that form.
  E05 accepts only the explicit empty delimited field, preserving genuine missing/
  malformed/unready/conflicting unknowns and all metadata/freshness gates. Raw native
  payload not supplied; normal-scan blank-display verification remains required.
- E05 primary review amendment2026-11-10: Core.sameInstance also requires a nonempty
  enchant field, so valid-empty links cannot retain coherent history on transient
  metadata failures. Align ONLY that syntax guard to allow an explicit empty field;
  same slot/item/exact-link and readiness/freshness/schema rules remain unchanged.
  Add a rejecting valid-empty failure-preservation regression before this one-pattern
  correction. This supersedes E05's initial Core-file freeze, not its safety policy.
- E05 review completed2026-11-15 continuation: two parser lines plus one same-instance
  syntax guard, local277/277+744K6/565K7+diagnostic23/23/bothPythonPASS. Primary verified
  source preimages against durable hashes after restart and reproduced old-Core failures;
  independent scoped static review PASS/no findings. One native unenchanted-tool blank
  display check remains; no repeat of accepted field/cache checks or fullselftest.
- E05 native follow-up2026-11-15: user confirms the affected Enchant cell correctly
  displays blank instead of?. Focused absence-display validation is complete; no
  further update/retest needed for this fix. Blank=confirmed absence, ?=unknown/unmapped
  remains policy. Knowledge accounting outside Inscription is still unresolved.
- Knowledge continuation2026-11-15: user “Okay, lets do it” authorizes K08, a separate
  `/ca knowledgecapture` command using existing bounded capture/format jobs, one unit
  per frame, for the eight already verified crafting identities. Existing synchronous
  Inscription-only `/ca knowledgecheck` and its regression semantics remain unchanged.
  New capture is ephemeral/read-only: no Login/scan, saved-data writes, numeric-policy
  enablement, tab/config hardcoding, Details or guide changes. Require current own ready
  unstaged context and existing idle collector; stop on context/runtime changes, events,
  combat/unknown safety, cancellation, >100ms measured callback or10000 callbacks, with
  no automatic resume. Timing stops are post-return detection, not preemption or proof
  of native responsiveness. Full data/cost/currency guards and output limits stay intact;
  candidates remain provisional/all-rank costs unverified. Review before user update,
  then one focused Enchanting capture/native comparison before batching other professions.
- K08 delivered/reviewed2026-11-15: new separate evidence factory/command, local309/309
  (277 retained+32additive),744K6/565K7,diagnostic23/23,bothPythonPASS. Primary actual
  baseline/inverse/freeze checks PASS; independent boundedstaticdelta review COMPLETE/
  PASS/no blockers. Independent executable/hash/fulltree proofs unavailable and clearly
  primary-attributed; earlier comparison-access INCOMPLETE retained. No numeric/rawpersist
  policy change. Focused user Enchanting report/native comparison is next; nativeAPI/
  responsiveness remain unmeasured. No fullselftest, acceptedfield repeats or release.
- K08 native Enchanting report received2026-11-15: complete/untruncated/stable unstaged
  capture of27/27 paths, four ordered trees. Provisional totals83/270,120/140,120/120,
  120/120 sum443/650 and reconcile once to shared spend443, unspent0. Enchanting's
  observed trait spend currency is4056, NOT Inscription3902; never assume one shared
  ID across professions. Two zero-rank unlock nodes report alternate current currencies;
  this is not all-rank spend proof. Full native breakdown in Q03. User native-UI agreement
  and responsiveness/errors/warnings are still unreported; no rerun/update or numeric
  activation yet. Confirm displayed totals and normal behavior before batching others.
- K08 Enchanting native follow-up2026-11-15: user confirms four tree values and Unspent0
  match native UI, no errors and capture remained responsive. Focused Enchanting evidence
  sequence complete for this case; no quantitative latency/all-rank-cost/failure-path
  proof inferred. Next batch same read-only capture for Alchemy, Blacksmithing, Engineering,
  Jewelcrafting, Leatherworking and Tailoring using already verified identities. No more
  Enchanting/Inscription capture, addon update or fullselftest needed. Numeric accounting
  enablement remains a separately specified/reviewed implementation, not this confirmation.
- K08 Alchemy report received2026-11-16: complete stable/untruncated22/22path capture;
  native-order tree candidates170/170,141/170,90/90,0/90 sum401/520, reconciling once to
  traitcurrency4030spent401/quantity0. Distinct from Enchanting4056/Inscription3902.
  Four zero-rank unlock nodes have alternate currentcosts; preserve lockedcapacity and
  unlock/spend distinction. NativeUIagreement and capturebehavior not yet reported for
  Alchemy; may confirm alongside remaining five reports without recapture or update.
  Other five captures stillpending; numeric/rawpersist gates unchanged.
- K08 batch follow-up2026-11-16: user confirms Alchemy numbers match native UI;
  Alchemy capture responsiveness/errors remain unreported. Complete stable/untruncated
  Blacksmithing30/30 and Jewelcrafting35/35 reports received. Blacksmithing candidates
  80/105,33/120,0/345,180/205 sum293/775, spendcurrency3750/unspent0; Jewelcrafting
  73/120,0/310,150/150,0/194 sum223/774, spendcurrency3989/unspent0. Both reconcile;
  native comparisons/behavior stillpending. Jewelcrafting includes four observed1-point
  spend capacities; do not replace with assumed caps. Positive auxiliary currencies are
  not UnspentKP. Engineering/Leatherworking/Tailoring reports remain; no recaptures,
  new source changes or numeric-policy enablement authorized by these reports alone.
- K08 Engineering follow-up2026-11-16: user confirms Blacksmithing/Jewelcrafting numbers
  match native UI; their capturebehavior remains unreported. Engineering complete stable/
  untruncated21/21path report received, ordered candidates103/225,0/165,70/90,30/90
  sum203/570 reconcile to traitcurrency3903spent203/unspent0. Combat Analytics includes
  path110352 and four35-point spend capacities; preserve live topology, not old guessed
  caps. Auxiliary3983quantity1 is not UnspentKP. Engineering nativecomparison/behavior
  pending; Leatherworking/Tailoring are the only outstanding batch reports. No recaptures,
  source edits or numeric-policy activation; batch behavior confirmation can follow together.
- K08 final reports received2026-11-16: user confirms Engineering numbers match nativeUI.
  Leatherworking32/32 and Tailoring26/26 captures complete/stable/untruncated, ordered
  totals73/120,250/250,0/250,0/150=323/770 (currency4085) and0/300,130/130,80/80,
  86/150=296/660 (currency3736), both unspent0/provisionalmatch. All six requested batch
  reports now received; no more capture/update needed. LW/Tailoring nativeagreement and
  six-profession responsive/error/warning observations stillpending, may confirm together.
  Positive LW auxiliary balances are not UnspentKP. Numeric/rawpersist eligibility still
  requires separate settled implementation/review; no sourcechange or allrankproof inferred.
- K08 final native confirmation2026-11-16: user confirms Leatherworking/Tailoring values
  match nativeUI and no errors/warnings with responsive UI throughout the batch. This
  completes focused capture/value/normal-use validation for all seven non-Inscription
  professions (Enchanting earlier; remaining six now). No more captures, updates or
  selftest rounds requested. All-rank costs, quantitative timing/failure paths and numeric
  production enablement remain distinct; next prepare a separate accounting design/task
  with approval/review before implementation. Inscription-only production gate unchanged.
- K09 preparation2026-11-16: user “Please proceed” follows the offer to prepare the
  separate numeric implementation. Primary explicitly scopes this turn to preparation
  only. Proposed K09 contract is at the top of TASKS.md, with technical rationale in
  Q03's latest entry; it is BLOCKED pending design/implementation approval. No writer,
  source/test change or production gate widening yet. Proposed currency pinning is an
  additional fail-closed safeguard, not established all-rank cost proof or a settled
  decision by being written here. No completed task history relocation is authorized.
- K09 approved2026-11-16: user “Approved” accepts the proposed design and implementation
  contract. Settle the Core-local exact eight-identity/trait-currency resolver, separate
  Inscription-only Details scope, observed currency pinning (including3902 for Inscription),
  raw/generation attribution, collector failed-attempt preservation and specified native-
  derived fixtures/old-test adaptations as written in K09. Authorize one synchronous
  implementer, full local validation and independent review before update advice. No new
  native evidence round, safety-limit change, task-history relocation or release approval.
- K09 delivered/locally accepted2026-11-16: exact eight-profession currency/identity
  resolver and coordinated numeric/raw persistence implemented; Details stays Inscription-
  only and evidence commands unchanged. Primary reproduced359/359 (309 retained with
  approved assertion adaptations+50new), unchanged744K6/565K7, diagnostic23/23/bothPython
  PASS, actual68-file baseline/inverse/193path/freeze proofs. Combined eight full native-
  derived snapshots29793/50000 values. Independent boundedstatic review COMPLETE/PASS,
  no findings; reviewer execution denied, so execution/hash/fulltree proofs remain
  primary-attributed. Acceptance after post-review source freeze, not native or release
  acceptance. Next user-managed four-file update then batched normal seven-profession
  numeric/order/hover/Unspent/behavior checks and one newnumeric closed/reload spot-check.
  No K08 recapture, new IDs, generic-field/Inscription/fullselftest repeats. K09 native
  NOT RUN; all-rank costs UNVERIFIED and historical fullnative INCOMPLETE87/149 unchanged.
- K09 native follow-up2026-11-16: user confirms “All the values match what was expected
  and are behaving as expected.” Accept the requested seven-profession focused dashboard
  value/normal-use round as complete at that reported scope. Individual procedure steps,
  reload timestamps and quantitative timing were not separately itemized; do not invent
  that detail or failure-path/all-rank proof. No further routine Knowledge updates,
  captures, identifier queries or selftest rounds requested. K09 is complete for its
  bounded implementation/review/focused validation slice, not the entire dashboard,
  guide work or release; existing all-rank/full-native limitations remain unchanged.
- Refines D01; scope history remains in [Q01](../questions/Q01.md). Architecture and
  selection of the first guide remain in [Q06](../questions/Q06.md).

<!-- END PRESERVED PLAN BLOCK -->
