# S01 implementation contract — normalized record storage

Status: settled technical contract under the user's “Let's do it” authorization,
2026-11-16. Execute the numbered S01 queue in TASKS.md, not historical proposals.
This document specifies implementation choices; existing native evidence is unchanged.

## 1. Architecture and compatibility boundary

Add `CraftArmy/Storage.lua` immediately after Core in TOC and the standalone runner.
Core remains the schema1/primitive implementation. Do not change its existing function
bodies, native validators, limits, copy/mirror behavior or accounting resolver. Export
the existing `mergeEquipment` as `Core.MergeEquipment` for reuse; this is the ONLY Core
source change. Knowledge, Data, KnowledgeCheck and diagnostics stay byte-for-byte frozen.

Storage is a facade: for an actual schema1 DB, its check/read/apply/lifecycle methods
delegate to the current Core behavior. For schema2 they require a module-private ready
handle, never a caller-constructed table that looks ready. New production Login uses
schema2; explicit schema1 fixture/collector users remain supported and unchanged. Do
not make Core.Open accept schema2 or change old tests into schema2 tests.

No codec, compression, executable decoding or persisted full schema1 backup. Normal
schema2 data is plain Lua tables. Sharing is by numeric catalogue reference, never by
persisted table alias. Independent **generation records**, not entire characters or
accounts, are the bounded snapshot units. Account/directory/archive counts have no
fixed character or aggregate50000-value product cap.

## 2. Saved shape

Root exact keys: `{schema=2,nextCatalog=positiveInteger,catalogs={},characters={}}`.
Catalogues are keyed by positive integer less than nextCatalog. Character keys follow
the existing nonempty GUID contract and primitive128-byte key bound. Character values
have `name`, `realm`, optional `classToken`, and `professions`. Profession keys are the
skillLineID, values contain `nextGeneration`, optional `active`, and `archives`.
`archives` is a **map keyed by generation number**, not a dense array; no length-based
archive limit or linear scan is needed for selected archive lookup. Directory wrappers
have exact registered keys; generation records have the existing generation, identity,
scannedAt, fields and optional archivedAt/archiveReason. Each archive key equals its
record generation; active/archive generation numbers are distinct, nextGeneration is
strictly higher, and counter increments must actually increase (reject overflow).

`fields` retains the current envelopes (`attempt`; optional `last` with status/value/
observedAt/build/generation). Generic keys remain exactly Core's registered payloads,
including unmapped slot fields. In schema2 tree, raw Knowledge and Details **values**
use the representations below. Failed attempts do not replace prior last values.
Unknown, false, zero and missing remain distinct. Archive metadata is independent of
field observation times. No whole-account Core.Copy/Open/mirror on schema2.

### 2a. Tree catalogue and personal tree value

Catalogue exact keys: `kind="tree"`, `identity` (four numeric profession identity fields),
`build`, optional `locale`, `definition`. Definition: `id`, optional `name`, `root`,
`paths` (ordered dense array, at most64). Each path contains `id`, optional `name`,
`capacity`, `children` (ordered dense unique IDs, at most16). Require one reachable
root, no duplicate/shared/cyclic/unreachable path, valid same-tree child ownership and
capacities. Keep labels separate from IDs; optional labels retain existing constraints.

Personal tree value: `format="tree-ref-v1"`, `catalog`, `purchased`, `capacity`,
`points` (pathID -> purchased), `locked` (pathID -> boolean when observed), `available`
(pathID -> observed node.isAvailable when present), optional `accountingPolicy` and
`accountingEvidence`. Keep the existing compact accountingEvidence currency/spent/
quantity/totalPurchased/sourcePin scalars; do not keep its duplicate path/currency graphs.
Exact point coverage, sums/capacity and bounds must match the referenced definition.
Native policy requires observed boolean lock and availability for every path, locked
implies zero, exact supported owning profession/currency/method/source pin, and the
existing scalar evidence relationships. Legacy no-policy trees preserve optional
lock/availability as observed; do not invent either from zero. Do NOT sum evidence
across tree fields from different successful times or call them a new live reconciliation.

Read adapters expand this into a **presentation-only** tree with id/name/root/paths,
individual purchased/capacity/children/locked/availability, totals, complete coverage and
the retained method/evidence scalars. Mark it `compactSnapshot=true`. No fake native
node, entry, cost or currency reports, no passing it to the rich Core tree validator.

### 2b. Raw Knowledge summary

Keep its envelope and replace only last.value with `format="raw-summary-v1"` plus the
original present policy/configID/sourceCounter/tabsComplete/nativeComplete/stagedStart/
stagedEnd/stable and four-field identity, and ordered tab identity/coverageComplete
summaries (id/name/root/coverageComplete). No paths, entries, costs or currency arrays.
This preserves refresh context/times without claiming raw evidence can be replayed.
Validate all present scalars and owner binding; incomplete summaries remain incomplete.
The facade returns the summary honestly, not manufactured knowledgeRaw. ViewModel must
say raw diagnostic payload is not retained when relevant; it may show compact context.

### 2c. Details catalogue and personal value

Catalogue `kind="details"`, four-field `identity`, `build`, optional `locale`,
`definition={trees={...}}`. Each tree holds id/name/root/capacity and ordered paths;
each path holds id/name/capacity/description and ordered perks with id/rank/isMajorPerk/
description. These are independently observed text/requirements, not borrowed from a
newer tree catalogue. Existing tree/path/perk/text/count bounds still apply.
Personal value: `format="details-ref-v1"`, `catalog`, existing version/skillLineID/
configID/sourceScanAt, `points`, `locked`, `states` (perkID -> original0 or2). Require
exact coverage, point/cap/earned constraints; expand to the existing professionDetails
payload and reuse Core.ValidPayload for that expanded payload. Never infer actual recipe
learning or earned state from rank. Keep Details timing independent of normal scans.

### 2d. Immutable revision lookup

Reuse a catalogue only when kind, four IDs, field's successful build, locale context
and complete definition are exactly equal (including optional missing labels). Locale
may be used only if observed with that field's successful timestamp; otherwise leave
it absent/unknown, never borrow a later environment locale. Conflicts create new numeric
revisions; referenced entries never mutate. No hardcoded native topology/default totals.

Build a private in-memory content index during catalogue validation. Its keys may be
canonical length-prefixed typed content strings (not persisted, never executed), with
deterministic sorted map keys and ordered arrays. Exact canonical equality avoids hash
collision assumptions and avoids scanning all catalogues during each update. Each
catalogue is independently bounded. Discard/rebuild the index on reopen; API results
must never expose its mutable definitions. Retain unreferenced catalogues for now; GC is
not needed for this fix and may not remove referenced history.

## 3. Exact migration keep/share/discard map

| Existing input | Schema2 action |
| --- | --- |
| Character name/realm/class; profession counters; generation identity/scannedAt/archive metadata | Keep unchanged, map archive array entries by their generation |
| Every field attempt and last status/time/build/generation | Keep unchanged |
| skill, slots, equipment including enchant/quality/stats/links, concentration, moxie, unspent, environment, knowledgeIndex | Copy exact value, including tolerated payload metadata |
| tree id/name/root; ordered path id/name/capacity/children | Share via immutable tree catalogue |
| tree/path purchased, locked, node.isAvailable; tree totals; accountingPolicy/accountingEvidence | Keep personal as2a, including absence of optional state |
| tree duplicate node/entry/rank/current-cost/currency/acquisition proof, coverage counters already proved by validation, cost reasons | Omit normal persistence, not the live validation |
| knowledgeRaw.last.value | Retain only explicit2b context/identity/tab summaries; omit node/entry/cost/currency graphs |
| professionDetails texts/labels/requirements/topology | Share in its independently versioned Details catalogue |
| professionDetails points/locks/perk states/config/sourceScanAt and envelope | Keep personal as2c |

Never hide a full rich input in extension data. Unknown **structural** extension keys
on root/character/profession/generation/field envelopes are not silently discarded:
fail migration with a bounded useful reason and leave the original unchanged. Generic
payload metadata remains exact; only the explicitly listed diagnostic data is omitted.
Do not narrow Core's schema1 acceptance to enforce this schema2 migration restriction.

First require Core.Open(existing schema1) with unchanged whole-data rules. Copy the
validated legacy source privately (bounded original graph), then migrate one generation
at a time into a separate candidate. Validate each output record/reference and compare
its presentation/semantic projection to the original (including all independent times).
Process directory keys incrementally; do not clone a whole character to migrate it.
Validate the complete candidate through the schema2 opening job before publication.
Only a COMPLETE result may replace env.CraftArmyDB; failed/cancelled/unsupported jobs
leave every original pointer/value intact. No partial root, automatic repair/reset,
hidden backup copies or rescan requirement to recover known progress. Document backup
before upgrade and backup-based downgrade; schema1-only older addon cannot write schema2.

## 4. Facade and ownership APIs

Expose Storage.New() -> readyHandle,savedRoot for an empty store; IsHandle(db) identifies
only private live handles. Check(db) returns db or nil,reason (schema1 delegates Open;
handles require ready state/root shape). NewOpenJob(raw) -> explicit running/complete/
failed/cancelled job, Step(), Cancel(), result handle + saved root only on completion.
NewOpenJob(nil) may complete immediately with the empty store. Unknown schema/header
fails immediately. A schema1 Core.Open failure must remain immediately reportable for
existing Login invalid-data behavior. No partially ready handle.

Read(db,guid,id,generation,archived) -> owned presentation generation and owned character
metadata, or nil,reason. Active(db,guid,id) selects current active; legacy branches retain
their current internal pointer behavior. Token(handle,guid,id) -> opaque per-active-
record token, replaced on every successful write/archive/delete; no saved table returned.
The cheap token is only for an already validated source interval, not a public integrity
certificate. Every normal schema2 Read revalidates the selected saved record, relevant
wrappers and referenced catalogue content (not just pointer identity), then owns output.
No caller/input/output mutation may leak into another saved record or shared definition.

Apply(db,character,identity,observations,at,build) -> owned presentation g or nil,reason;
Archive/Delete match existing Core arguments/results through the facade. Ready handles
maintain a private revision invalidating iterators/tokens as appropriate. No direct
consumer access to saved characters/archives or pointer-based schema1 assumptions.
Source root remains saved data, handle is runtime-only and never persisted. In-process
outside code mutating the global is unsupported ownership interference, not permission
to trust mutated units: touched records/refs must reject; open/reopen validates everything.

For Apply: validate/copy the entire rich input through **real Core.Apply on an empty
temporary schema1 DB**, preserving all native attribution/payload/50000 input guards.
Validate the selected prior compact record; merge field envelopes with Core.Merge and
Core.MergeEquipment (same-instance behavior unchanged), compact newly successful rich
values only, and retain old compact values on failure. Validate candidate record/refs
and a bounded presentation roundtrip before any real write. Stage new catalogues and
counter updates privately. Commit new catalogues, character scalar metadata and the
one active record with no yield/callback/validation after the first real write; no
whole-character/archive/account copy or unrelated revalidation. All normal rejection
paths leave original data/counters/tokens untouched. No promise of recovery from process
death/OOM beyond Lua SavedVariables/backup behavior.

Archive validates/copies one active record, attaches at/reason and moves it into archives
under its generation key; no overwrite if occupied. Delete uses existing confirmation
semantics; whole-character delete can unlink one character directory without traversing
all its data. No automatic archiving by absence added; current roster presence-only
collection remains unchanged. Referenced catalogue revisions survive all normal updates.

## 5. Incremental integrity, startup and display

Each plain snapshot/catalogue unit must pass original Core.Copy50000visits/depth20/
4096-byte-string/key/finite guards plus new typed checks. Do not alter limits or make
an entire expanded account one primitive input. Enumerate root/character/profession/
archive/catalogue directories with raw next cursors, at most128 edges per directory
Step. Header/scalar wrappers have exact keys so a malicious unknown graph cannot hide
outside record validation. Reject cycles/metatables and cross-unit table aliases: use
private seen-table ownership during initial validation in addition to per-unit Copy.
All directories, every active/archive record, catalogue, owner and reference must finish
before ready; no prefix accepted as complete. A catalogue-validation Step validates at
most one catalogue. A record Step processes at most one independently bounded generation,
but does not recursively revalidate all its catalogue dependencies in that same Step.
Expose actual work counters for tests; no hard account-wide job-step cap. Each Step is
protected, nonreentrant and releases private partial results on cancellation/failure.

### 5a. Retained-field dependency scheduling amendment (primary,2026-11-16)

The eight-tree discovery limit is per scan/index, NOT a bound on retained `tree:*` fields.
Real schema1 Apply can retain9 or more old/new fields after index changes. Keep ALL of
them and their times, even when not in the latest index. No new field/history cap and
no raising the eight-tree native acquisition limit. The original phrase “at most8tree
referenced definitions per record Step” is superseded by scheduling, not an increased cap.

On schema2 startup every catalogue is already copied/typed-validated in its own prior
unit before records. Record validation may resolve ONLY that job's privately owned,
validated catalogue registry, checking reference/kind/owner/build/node coverage and actual
personal state without rerunning the catalogue Copy/typed definition validator in the
record Step. Such reuse is allowed solely for private owned definitions, never public
mutable saved pointers or a cache justified only by pointer identity. No fabricated raw
evidence. The candidate retains complete validation provenance until publication.

Schema1 migration must split compaction of retained fields: one successful special field
(tree or Details) per Step, staging/validating at most its one new/reused catalogue; generic
fields and raw summaries can also be processed one field per Step. The final bounded
record assembly/check uses those privately owned validated staged/reused catalogues, not
another walk over all raw definitions. Candidate validation still runs after migration.
No partial fields/record/root exposed on cancellation or late failure.

Iterator/model jobs use analogous selected-record preparation when necessary: acquire
one privately owned validated dependency per Step, then finish the single presentation
record with its owned registry. Do not fall back to synchronous S.Read inside an iterator
if that revalidates an arbitrary number of definitions. S.Read/Apply/Archive remain
synchronous affected-record APIs with original record/presentation bounds; do not impose
eight retained fields on them. Their public normal reads must still freshly validate
touched saved definitions, not reuse startup acceptance against mutable live data.

Extend the existing required-dependency regression (don't remove its reproducer) to prove
all9 historical fields survive migration/open/iterator and repeated index changes retain
even more fields, while each job Step validates at most ONE distinct catalogue. Inspect
actual catalogue validations, not a counter incremented independently of work. Original
failure422PASS/1FAIL remains history. No old409 test or primitive/native limit change.

Publication guards require unchanged original env.CraftArmyDB reference and job/runtime
ownership; addon writes are disabled throughout startup/migration. Copying input units
prevents later caller mutation from altering candidate data. If source units mutate
before their processing, validate the actual values; do not trust previously cached
acceptance. Directory drift/errors fail safely, no retry/bypass. Model/render revisions
guard normal own-addon concurrent changes. This is not adversarial multiwriter support.

Commands owns one hidden OnUpdate startup driver: one Step/frame, no synchronous drain.
Nil store initialization is immediate; valid existing store is pending with explanatory
collector.blockReason and no scans/lifecycle/Details writes until complete. Invalid v1
data retains existing immediate no-reset behavior. No automatic native scan is performed
to reconstruct migration data. On successful publication bind handle to collector, clear
pending reason, invalidate freshness, refresh cached UI and allow the existing normal
event/manual scan flow. Preserve events' invalidation; don't queue unbounded requests.
Combat/unknown safety pauses startup without stepping; selftest/capture pauses it too.
Missing/throwing Frame/scheduler -> explained blocked state, never synchronous fallback.
Add `/ca storage status|cancel|retry` for this job only; cancel retains old saved root,
retry is explicit (no automatic retry after failure), no collect/gameplay side effects.
An open cancelled/failing startup still exposes a dashboard/status, not an empty reset.

Storage.NewIterator(handle,archived) is a revision-pinned bounded directory iterator:
Step() returns at most one owned {guid,c,id,g,archived} item or pending/complete/failure.
No whole-account copy/expanded cache. Read only the requested active/archive view, but
all store integrity was checked at startup. ViewModel.NewBuildJob pins handle revision,
options (owned copy), session freshness and now; processes one item/Row per Step, then
incremental bottom-up mergesort with at most128 compare/move operations per Step using
the existing exact comparator. Rows are public only at completion. Failed/cancelled/
superseded builds cannot publish partial/old-filter rows. V.Build stays unchanged for
schema1; for handles it returns pending explanation, NOT a synchronous job drain.

Dashboard uses NewBuildJob only for handles and a single owned hidden OnUpdate driver.
Refresh cancels prior builds, clears selection/confirmation and shows explicit pending
status; pending rows are empty (not a claim the saved account is empty). One Step/frame,
publish complete rows only if still current and revision/options/context match. Retain
existing12 row widgets, paging, filters/sorts/colors/flatchrome/hover policy. Hidden UI
cancels its job; showing/refreshing restarts only read-only work. Missing driver or job
error explains failure with no full synchronous fallback or saved-data reset. Existing
schema1 display/tests remain synchronous. Lifecycle actions use facade selection/checks.

## 6. Collector and Details integration

Route collector validation, prior-index reads, Apply and item retry/timeout/TokenValid
through facade branches. Keep all live reads, K.Evaluate, combined raw/result input
budget and failed-index/tree preservation unchanged. On schema2 only, retain one private
ephemeral rich `knowledgeSource` after a successful complete normal scan: owned raw+
evaluated source generation, scan serial/revision/config/sourceCounter/at and active token.
Clear it on Invalidate, next scan start, lifecycle/context drift; never persist it. No
new native API or accounting reads. Generic success must not fabricate a rich source.

Details schema1 capture path remains semantically unchanged. Schema2 capture reads a
validated presentation source once and requires the ephemeral complete rich source,
same active token/serial/revision/context/scan time. Build descriptors from that actual
rich source, not reconstructed compact nodes. Cheap inter-frame guards compare opaque
token/runtime/context; retain all live node matching, verification and final <=64-node
commit-frame fingerprint checks, no per-frame whole-account reads. Use facade Apply
for independent Details commit. Cached/offline/archive Details only uses owned expanded
personal Details snapshots; after reload new Refresh details correctly needs a normal
complete scan, as before, not fabricated native evidence. No Details redesign/recipes.

## 7. Validation and test scope

Keep all409 old SelfTests scenario/assertion workloads byte-for-byte, add a marked S01
block before Tests.Run. No old-test adaptation is preauthorized. If a genuine conflict
arises, STOP the dependent piece and report the exact assertion/needed primary amendment.
Use existing full native-derived fixtures; helper reuse must not yield across temporary
Core overrides. Do not expose fixture hooks in production. New standalone runner module
list adds Storage only; entire K6/K7 supplement suffix stays byte-for-byte frozen.

Require new tests for all schema/enum/type/key/depth/visit/string/nonfinite/alias/cycle/
reference/owner/coverage/point/earned/counter guards; read/output/definition ownership;
same definitions/different allocations/locked-zero; label/build/locale/topology conflicts;
independent newer raw/older trees/Details times; corrupt touched units and late startup
failures; migration semantic comparisons/cancel/no partial roots/unsupported unknown
extensions; same/changed equipment retry behavior; no whole-account copier in hot paths.

Full native input -> real migration/Apply -> reopen/iterator/rows must exercise all8
identities, the old12->13 failure boundary,46characters×2professions, **100 and200
characters×2professions** (fixture sizes, NOT caps), plus retained archives and an actual
Inscription Details report. At least one valid compact account must exceed50000aggregate
values. Large accounts cannot be made as a schema1 fixture that bypasses its limits:
migrate a valid legacy seed, then grow through real schema2 Apply using full rich inputs.
Record actual row/catalogue/value/work counts; assert primitive records still reject
overlimit data. Roundtrip reload via new opening job, compare values/times, update one
alt, retire/relearn/delete scoped records, and verify unaffected accounts/history. Include
deterministic bounded Step counts/directory and sort budgets, cancellation/reentry/drift,
startup/render missing scheduler/error/combat, stale callbacks, exact14column sorts and
no API/render writes. Each new stress loop must use existing safe fixture checkpoints;
group only NEW work if needed, never reduce old cases/limits or label INCOMPLETE PASS.

Local results are not native performance/serialization evidence. Keep full native suite
INCOMPLETE87/149 and all-rank-costs UNVERIFIED. After review, request only a previously
blocked character's normal scan plus existing-data retention check, not captures/IDs/
full-selftest chase. No installs, Git mutations, publication or release authorization.

## 8. Primary review corrections (5b scheduling amendment),2026-11-16

Independent review found a real touched-reference integrity gap: reuse of an existing
catalogue by a NEW character must validate that saved catalogue's registered owner,
all nested alias ownership, complete types/definition and immutable content before
commit. Do not rely on selected(old active) to cover new owners. Apply this to every
reused saved dependency via stageCatalog; job-private staged/validated catalogues use
their already-owned path. Tests replace a saved catalogue with identical-content Copy
and introduce equal-content cross-catalogue aliases, then require new-character Apply
to reject with root graph, nextCatalog, revision, generations and existing tokens intact.
No weakening public read or external-interference rejection semantics.

### 5b. Bounded work batches per frame, not one Step per frame

Reviewer work-count analysis reveals a practical latency risk in blank-until-complete
model rebuilds. Supersede ONLY the fixed one-Step/frame startup/dashboard driver rule:
individual job Step budgets remain exactly unchanged (one catalogue, one record,128
directory edges or128sortoperations as applicable). Selftest, Knowledgecapture, existing
Details capture and live collection schedulers are unchanged.

Add Storage.NewFrameBatch(env) returning a runtime helper with Step(job,guard). It may
execute at most **16 job Steps per frame** while observed elapsed time is **below2ms**.
Choose protected env.debugprofilestop milliseconds, else GetTimePreciseSec*1000; no
native clock -> conservative **one-Step/frame** fallback (explicit mode/status), not a
synchronous drain. Do not add a whole-job step limit or weaken any work unit's bounds.
No promise every frame is under2ms: time is checked between units, cannot preempt one
Step; document potential one-unit overshoot, no measured-native responsiveness claim.

Step(job,guard) returns success,steps or false,reason. It checks guard before work and
between units, samples a finite monotonic clock before/after units, stops that frame at
elapsed>=2ms or16Steps or terminal job. Zero-resolution clocks still cap at16. Missing
clock fallback uses one Step; a selected clock that throws/becomes invalid/backward/
overflows reports failure, never silently changes clock or drains work. Reentry fails
closed. Keep actual per-frame work counters for tests. A false guard stops the frame
without advancing additional work; caller retains normal pause/supersession handling.

Commands startup driver uses the helper with guard for current job/runtime/original
saved root/safe combat/no selftest/no capture. Dashboard driver uses current build/db/
options/freshness/runtime/show/safe combat guard. Recheck all existing publication
guards after the batch, including cleanup gaps. A reentrant clock/Step/guard cannot
publish a cancelled/superseded/unsafe job or overwrite newer job/UI state. Missing Frame
still blocks with no synchronous fallback. No partial rows/root published. Preserve
existing no-clock tests/fallback, add deterministic fake-clock batches proving max16,
2ms boundary, one-unit overshoot, terminal/error/guard cancellation, per-Step catalogue
bound and stale callback/publication safety. Report frame counts separately from job
steps and native timing; verify growth fixtures use actual batched drivers/helper, not
an expected count divided by16. Failed prior revision/review remains in history.

This is an explicit primary technical scheduling amendment within the authorized storage
fix, not permission for new UI/accounting scope, raised primitive limits, lost history,
test skips or installation/release. Resume piece8 then renew frozen independent review.

## 9. Startup cleanup supersession correction,2026-11-17

Renewed static review resolves catalogue ownership but finds an old failure-status write
after native frame cleanup starts a replacement startup. Add a private monotonic startup
invocation epoch (same role as Dashboard's buildVersion). Each StartStorage captures it;
entry cleanup must return if a reentrant StartStorage advances it. Once job/runtime exist,
all current/owns checks include captured epoch and job/runtime identity. Source drift can
still be explained for the current invocation without requiring unchanged source pointer.

After every native cleanup/setup/error/cancel callback, recheck identity/epoch BEFORE
setting failure/cancel/pending status or clearing driver/runtime state. Never cancel or
hide the replacement job/frame. Use captured old frame/job for cleanup, not whatever
self.storageFrame has become after reentry. In particular batch-error and source-drift
retireDriver branches, setup-failure branch, finish, explicit `/ca storage cancel`, and
StartStorage's initial old-driver cleanup must protect newer invocations. No new automatic
retry/scan or scheduler/data-format/budget change.

First reproduce reviewer combination: selected clock throws after old job complete;
captured frame.Hide starts explicit retry; old callback must not replace the new job,
batch, blockReason/pending dashboard state. Add cases for equivalent source-drift/setup/
explicit-cancel/entry cleanup reentry as applicable. Verify stale callback cannot advance
or overwrite new job, original root remains until correct completion, replacement retry
can complete, all458 prior scenarios byte-exact. Preserve failure history; renew review
after approved local checks/comparison/freeze. This is within the existing authorized fix.
