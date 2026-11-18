# S01 — shared definitions and scalable record storage (contract pending)

Update2026-11-16: user “Let's do it” authorizes implementation. The settled executable
technical contract is [storage-s01-contract.md](storage-s01-contract.md), with serial S01
queue in TASKS.md. This earlier proposal preserves rationale; later contract resolves
the pending schema/facade/migration/jobs choices below. No source delivery implied.

## Capacity requirement

User currently has **46 characters**, may add more, and wants to avoid restrictive storage
limits. Six characters with two professions each successfully refreshed (12 rows); three
previously scanned characters are now blocked. Minimum fixture target: **46 characters
×2 primary professions =92 active profession rows**, plus retained history/Details, with
larger-growth stress coverage required. Neither46 nor92 is a product ceiling or evidence
that the whole roster has been scanned. Actual SavedVariables have not been inspected;
do not invent the number/size of the three blocked characters' records.

The local reproduction already demonstrates the architectural problem: eight complete
native-derived rows29793values;12rows46745;attempted13th fails final assembled50000-value
guard without committing. The user's12 successful rows are consistent with that failure,
not a measured equality of their DB with the synthetic fixture.

## Confirmed direction — combine deduplication with independently bounded records

User approves changing storage, then explicitly refines the design: profession nodes are
shared definitions; each Inscriptionist should not retain their own duplicate tree and
implementation evidence. This supersedes the earlier recommendation to losslessly encode
every existing per-character raw evidence copy. Preserve user progress/meaning, not all
development artifacts in the normal saved format. Repository evidence/history is separate
and is NOT authorized for deletion by this request.

Latest user clarification explicitly permits combining both approaches. Shared catalogues
hold static definitions; independently bounded snapshot records hold personal observations
and compact collection context. Safety limits apply to primitive operations, individual
records and scheduled work batches, not one50000-value traversal of the expanded account.
Simply normalizing today's roster below that whole-account limit is NOT sufficient.

Prefer ordinary versioned tables where appropriate; a custom codec is neither required
nor settled. Do not merely pack all duplicate engineering evidence into opaque records.
The earlier per-record validation organization remains useful; the requirement to preserve
every raw diagnostic copy does not. Exact schema/access/migration/validation interfaces
still need a complete primary-owned executable contract before any implementation writer.

No fixed character-count cap is requested. This does not promise unlimited memory, disk
or client serialization performance: document measured growth and practical constraints
honestly. Bounded job slices are not proof of constant total startup/render/serialization
cost. Growth must not trigger silent eviction or known-value loss.

### Store once per compatible profession definition / locale

- Profession/expansion definition identity and immutable catalogue revision.
- Tree IDs/names/native order, roots, node IDs/parent-child structure, localized branch
  labels and spendable capacities. Shared metadata is validated from source/client
  observations, not inferred from one character's points.
- Shared path/perk descriptions and rank requirements, where actually observed/needed
  for the existing Details feature. No recipe learned status inferred from such text.
- Fixed provenance/accounting-method metadata needed to interpret the definition, once
  rather than repeated on every node/alt.

Version catalogues by compatible structure/build/locale and keep old referenced revisions
immutable. Equal definitions reuse one catalogue; conflicting/incomplete observations
must not silently overwrite a catalogue used by older snapshots. A character's config ID,
allocation, unlock state, earned state, staged preview and currency balances are NOT shared
definition data. Do not use localized labels as stable identity or force one revision when
actual static metadata differs.

### Keep per character / profession / successful snapshot unit

- Character identity/class, profession skill, equipment/enchant, concentration, Moxie and
  Unspent KP remain character-specific as before.
- Catalogue reference plus observed purchased points for each node. Preserve observed
  locked/unlocked state: zero invested points alone cannot distinguish a locked node from
  an unlocked zero-point node. Preserve actually observed perk/recipe states where the
  existing feature stores them; do not derive learned status from point requirements.
- Field attempts/status/reasons, independent observation times, active/archive generations
  and minimal collection context genuinely required for correct refresh/Details guards.
- Compact whole-snapshot validation result/method revision if needed. This is not a stored
  replay of every native node/entry/currency/current-cost call.

Raw node/entry/cost/currency reports and duplicated raw Knowledge graphs are temporary
scan/debug data, not normal per-character SavedVariables. Full current metadata must still
pass ALL existing acquisition/accounting/state/current-cost/coverage/reconciliation checks
BEFORE compact values can replace a known snapshot. Failed scans retain prior coherent
allocations/catalogue references/times; unknown remains unknown. Debug commands can keep
their existing ephemeral read-only reports; preserve Shift diagnostic access with honest
snapshot information rather than pretending discarded raw payloads were saved/replayed.

### Safety/integration requirements

- Keep original generic50000visit/depth20/4096-byte-string/finite/plain-data limits and
  legacy schema1 validation/atomicity behavior. Schema2 deliberately changes validation
  organization: validate every stored record/catalogue and all ownership/references in
  bounded work units, without imposing the legacy50000 aggregate-value limit on the
  account. Do not call the old whole-account copier on the assembled schema2 store or
  an expanded read adapter. No arbitrary increase to a primitive limit is the fix.
- Account directories/indexes and catalogue registries also need bounded incremental
  inspection and explicit incomplete/cancel/failure states. Validating only an index or
  a subset is not whole-store acceptance. Specify safe enumeration, structural/key/type
  checks, per-unit limits, completion bookkeeping and corruption policy before coding;
  neither an unbounded synchronous walk nor a new small aggregate metadata cap qualifies.
- Validate reference existence, compatible identity/revision, exact node coverage, point
  bounds, lock/state consistency and scalar types. Do not manufacture raw native node
  evidence to pass old validators. New persisted integrity checks and complete live-scan
  promotion checks are distinct and must be explicitly specified/tested.
- Preserve atomicity, context/generation/async-token safety and bidirectional ownership.
  No silent user-record eviction, automatic clearing, timestamp rewriting or cross-alt
  currency/progress borrowing. Sort/filter/render stay read-only; no offline-alt queries.
- Commit a changed personal record and any new catalogue/reference dependencies as one
  coherent validated update. Do not copy/revalidate unrelated expanded snapshots on each
  scan or let cancelled work expose dangling references or partial migration results.
- Bound startup/migration and scan/render work. Cache only safely owned/validated data;
  references must not introduce alias undercounting, mutable definition leakage or unsafe
  cycles. Missing/corrupt/unsupported data explains blocked writes rather than resetting.
- Preserve existing UI/class/tree colors/sorting/hover semantics and Inscription-only
  Details function. Storage adapters may need integration changes, not a Details redesign.

## Migration and recovery

Require a SavedVariables backup before the reviewed upgrade. Fully validate existing
schema1 data, construct normalized schema2 separately and compare all meaningful progress,
equipment, states, labels/definition references, field times, archives and Details before
replacing the root. Deduplicate shared definitions and intentionally omit only the
specifically approved per-character diagnostic copies; do not retain a hidden full v1
backup inside every record. Define an explicit keep/share/discard field map before coding.
Failure/cancellation/unsafe change/missing capacity leaves the original DB intact. No
partial migration, clearing user history, "start fresh" or forced rescan to recover known
values. Unknown/partial old evidence must remain unknown, not become invented allocations.
Explicitly document older-addon incompatibility with schema2 and backup-based rollback;
do not suggest blindly downgrading and overwriting the migrated data.

## Mandatory implementation acceptance evidence

- Retain all409 current addon cases and unchanged744K6/565K7/23diagnostic coverage;
  preserve original50000/50001, depth, aliases, native numeric, corruption and atomicity
  scenarios for legacy primitives. Any genuinely obsolete integration expectations need
  an explicit contract allowlist, not silent skip/relabel/coverage reduction.
- Exercise all46 synthetic characters/two professions each using FULL native-derived
  live/migration input graphs across all8 identities, then validate the intentionally
  normalized persisted output. Real migration/scan/repeated updates/reload/read-only
  display/sort/filter/class colors/archive+Details retention, including12→13 boundary.
  Rich inputs/guards must not be reduced just because persisted output is smaller.
- Exercise larger rosters beyond46 and a valid schema2 account exceeding50000 aggregate
  values: successful startup/reload, scan of one record, archived/Details preservation and
  read-only rendering must not fail solely on account-wide value count. Record actual
  roster/record/value/work counts; larger fixture sizes are stress cases, not new caps.
  Prove each invalid/oversized record still rejects, scheduled batches stay bounded and
  cancellation/late failure preserves original data. Do not substitute sizing projections.
- Verify one shared definition for equal Inscription layouts, independent allocations/
  locked-zero states across alts, mismatch/new-revision isolation, missing/corrupt refs,
  migration late failure/cancel/reentry, alias/cache ownership, per-record/work bounds and
  no cross-character loss/time changes. No hidden retained duplicate diagnostics.
- Independently review the frozen implementation and migration before recommending the
  update. Native follow-up should be one previously blocked character's normal scan and
  existing-data preservation, not another Knowledge-capture/full-selftest sequence.

## Read-only sizing evidence (not implemented or validated schema)

Primary projected the existing full eight-profession native-derived fixtures into a
normalized conceptual shape: shared tree names/IDs/children/capacities once per profession;
per-character per-node points/lock flags; all other existing field envelopes/non-Knowledge
data retained. Compact records were not used as an accounting-input substitute: each
source graph was fully collected/evaluated by the existing fixture first.
The projection uses46synthetic characters/92profession rows/eight catalogues and counts
**32095values** versus the current50000visit ceiling. This sizes one normal-data example;
it is NOT a new schema/migration implementation, Core.Open acceptance, file-byte measurement,
archives/Details headroom proof, performance result or promise of final capacity.
In particular, fitting this example under50000 is not the scalability acceptance criterion;
the combined design must support account growth across independently validated records.

## Next action

Combined storage-change/shared-definition direction is approved/refined by the user; no
storage source edits or writer launched. PRIMARY completes exact record/catalogue schema,
field mapping, immutable revisioning, read/write/Details adapters, atomic migration and
incremental validation/access scheduling contract before delegation. No arbitrary cap
raise, user-data deletion, game installation, Git/publication or release authorized.
Per-record validation and deduplication are complementary, not competing alternatives;
opaque packing of all duplicated raw evidence remains superseded.
