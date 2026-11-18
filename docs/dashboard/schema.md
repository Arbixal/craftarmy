# CraftArmy snapshot schema 1

**Current implementation:** S01 uses schema2 shared definitions/personal records (later
section below); original schema1 sections are retained reference, not a reset/migration
instruction. U09 estimates are tooltip-only, never persisted. U10 adds optional gear
decoration metadata compatible with both shapes; no schema bump or user-data reset.

## U10 optional gear decoration metadata

Ready identified gear may add `itemExpansion`; Tool may also add `toolStat`. Each is a
typed plain unit `{status, attemptedAt, source, value?, observedAt?}`. Sources are exactly
`C_Item.GetItemInfo` and `C_Item.GetItemStats:unenchant-link-v1`. Value is nonnegative
integer item expansionID, or one evidenced Tool category (Multicraft/Resourcefulness/
Ingenuity/Crafting Speed). Observed requires value/own successful server timestamp;
unknown/error/unsupported may retain a prior value and its own observedAt. No raw exception
payloads, units on empty/unmapped items, or Tool stat on accessories. No-history failed
optional attempts are omitted from successful merge; absent new metadata is legitimate.

Optional failure does not downgrade otherwise valid base gear. On a successful gear
write for the same exact link/itemID/slot, optional unit failure retains its old known
value/time with current failed status/attempt time. Changed/removed/unidentifiable gear
never inherits. This narrow independent-decoration retention is an explicit exception
to the historical base-unit no-subfield-borrowing rule; the base unit/whole failed gear
retention semantics are unchanged. Core typed validation/merge serves both schema1/2;
Storage needs no format change. Older snapshots remain valid without these units.

No new offline data reads/migration/rescan. Optional data is collected during ordinary
own ready profession scans; native expansion-ID/stat attribution still needs focused
client confirmation. Presentation uses unknown rather than guessing/forced refresh.

## Historical schema1 base contract

`CraftArmyDB` is separate from all diagnostic data. Only an absent DB initializes to
`{schema=1, characters={}}`; invalid/future data disables writes without resetting it.
No migration/import, eviction, offline API queries or concentration projection.

## Identity and generations

`characters[GUID] = {name, realm, professions}`. Labels are not keys.
`professions[expansionSkillLineID] = {nextGeneration, active?, archives={...}}`.
Each generation contains `{generation, identity, fields, scannedAt}`. Identity is a
coherent `{skillLineID, parentID, profession, expansionID, name, expansionName}` unit.
The family/expansion registry is independent of labels and display order.

Archives are copies with `archivedAt` and `archiveReason`; collector writes never
modify them. Explicit confirmed scoped deletion is the only deletion path. Retirement
removes active records. A later successful guarded scan creates a new generation with
empty fields, never promoting historical values. Automatic unlearning requires an
authoritative complete roster contract; production does not currently assert one.

## Field envelope

Each `fields[key]` contains `attempt={status,attemptedAt,source,reason?}` and optional
`last={status,value?,observedAt,build,generation}`. Statuses are `observed`, `empty`,
`unknown`, `unsupported`, `error`, `not_applicable`. Only observed/empty/not_applicable
replace `last`; zero and false are values. A failed attempt preserves an earlier
coherent success with stale presentation. Attempt and observation timestamps differ.

Equipment values are whole equipped-instance units (slot, role, existence, link,
rarity, crafted rank, icon, numeric-key stats, enchant evidence). A successful read
of a replaced/unloaded item replaces that unit, not individual old metadata. A valid
explicit false existence read represents empty; no link/cache miss means unknown.
Tree values contain complete aggregates and exact same-scan path evidence. Failed
tree accounting preserves a prior whole tree; ranks/caps are never field-merged.

The copier accepts only finite primitives and plain bounded tables: depth 20, 50,000
visited values, string values 4,096 bytes, keys 128 bytes or nonnegative integers.
Cycles, metatables, nonfinite numbers and runtime objects are rejected. IDs,
generation counters, timestamps and field envelopes are validated before writes.
There is no silent character/archive count eviction.

### R4 numeric classification

`Core.Finite(value, optionalMathLibrary)` first rejects nonnumbers, then prefers
native `math.isfinite` through `pcall`, accepting only a boolean result. Native false,
exceptions, nonboolean results or a present nonfunction all fail closed; they never
fall through to comparisons. Only an absent native predicate permits the portable
IEEE Lua5.1 self-equality/infinity-bounds fallback. The optional plain-library table
is for isolated branch fixtures; tests do not replace real math functions/globals.

This matters on the tested WoW runtime: user output was exactly
`NaN: -nan(ind) self: true bounds: true finite: false`. Its comparisons are not proof
of IEEE NaN behavior. The actual/default native path must reject NaN and ±infinity;
portable injected fallback non-finite assertions apply on a native-absent IEEE host,
not as a claim that disabling WoW's native predicate is supported. All actual-runtime
rejection assertions, including the original failing copier assertion, remain
mandatory and are not gated by NaN self-equality.

Integer values and lower bounds are classified before modulo/comparison. Copier
values and numeric keys, typed numeric validators, collector projections/stat maps
and view attention predicates share that same rule. No non-finite observation may
enter saved fields, become observed zero or confirm an attention condition. Failed
required numeric metadata preserves a prior coherent unit as stale where identity
permits; malformed existing data disables writes without mutation/reset. This is a
numeric safety correction only: schema1, version and all field bounds remain intact.

### R1 same-instance failure handling

A gear metadata read returning nil/error/unsupported is a failed attempt, not a
successful empty stats map or fresh unknown rarity/rank. Only an exact match of
positive equipped item ID, valid full instance link and slot within the same active
GUID/profession generation can preserve the previous **whole** successful unit and
its `observedAt`. No successful subfield is advanced or borrowed from the failed
scan. The latest attempt carries its error/reason/time; all retained unit metadata
is displayed stale/last observed. Cache-loading and timeout attempts follow the same
rule. Freshness requires an actual successful latest unit read.

A changed/removed/unidentifiable instance never inherits old unit metadata. With
known existence, only the current scan's partial unit is retained; its metadata
failure remains the latest failed attempt. With no usable current unit, no previous
`last` is promoted. Confirmed false existence replaces the old unit with an empty
location. Missing link/item ID is not proof of either same instance or emptiness.

### R1 typed load and write gates

`Core.Open` validates registered payload types in **both** active and archived
generations, in addition to primitive bounds and envelopes. `Core.Apply` uses the
same payload validators before its single commit, so a mixed valid/malformed scan
is rejected atomically. Unknown production field keys are rejected. Generic
`Core.Merge` still accepts finite zero/false primitives, but that utility does not
bypass a production field's type (e.g. `skill=true` and `unspent=false` are invalid).

Character name/realm must be strings; optional identity name/expansionName must be
strings when present. IDs are positive integral identifiers; times/generation
counters are validated. Skill needs numeric skill/cap/modifier, currencies require
positive ID plus nonnegative integer quantity and optional nonnegative cap/recharge,
and unspent is a nonnegative integer. Gear requires a matching role or dynamic
`slot<index>`, numeric slot, explicit boolean existence/readiness, numeric rarity/
rank/stat values when present, typed quality/enchant/tooltip text and consistent
link/item ID. Ready units must identify the equipped instance. Enchant absence and
empty locations remain legitimate boolean false values.

Index/tab/path/child/tooltip lists must be dense bounded arrays; raw path maps need
positive ID keys and typed optional node/unlock/cost evidence. Unknown raw metadata
may remain absent (not zero); raw ranks remain integral evidence, not purchased KP.
Dynamic `tree:<ID>` values require a matching ID, complete coverage, bounded unique
path records, nonnegative purchased/capacity and internally consistent path sums.
These are shape/coherence checks, **not** source proof of unit-cost eligibility.

Invalid existing data is never repaired/reset in place. It disables collection and
renders no attributed rows, with the validation explanation visible in the native
dashboard. The saved global remains untouched for backup/reporting; do not discard
it to suppress an error. Schema remains1; TOC/version and runtime evidence unchanged.

### Field keys and coherent values

| Key | Successful value |
| --- | --- |
| `skill` | `{skillLevel, maxSkillLevel, skillModifier}` from one profession info read |
| `concentration`, `moxie` | `{id, name?, quantity, maxQuantity?, rechargingCycleDurationMS?, rechargingAmountPerCycle?}`; cap/recharge absence is unknown |
| `slots` | `{indices={...}, complete}` from profession API membership |
| `accessory1`, `accessory2`, `tool` | `{slot, role, exists, metadataReady, link?, itemID?, rarity?, rarityStatus?, rank?, rankStatus?, icon?, quality?, stats?, statsStatus?, statAttribution?, enchant?, enchantLines?, loadReason?}`; no previous-item subfield merge |
| `slot<index>` | Independent evidence with unknown role, never relabeled by position |
| `unspent` | Nonnegative integer, including actual zero |
| `knowledgeIndex` | `{ {id, name?, root?}, ... }`; incomplete tab/config read preserves prior index |
| `knowledgeRaw` | `{configID?, stagedStart?, stagedEnd?, stable, tabsComplete, tabs={...}}`; tabs contain `{id,name?,root?,paths={[pathID]={node?,children?,childrenComplete,unlockEntryID?,unlock?,costs,costRule,costReason}},coverageComplete,currencies}` |
| `tree:<tabID>` | `{id,name?,root,paths={...},complete=true,coverage,purchased,capacity}` only after whole-tree eligibility; `paths` retains node/entry/child/cost evidence plus exact per-path purchased/capacity |
| `environment` | `{version, locale?}`; each field's `build` is version + build from GetBuildInfo |
| `professionDetails` (optional) | Version1 native Midnight Inscription report with its own `sourceScanAt`, coherent tree/path points and client path/perk descriptions; see U03 below |

Current production `costRule` remains unknown. The distinct K2 native policy below
can produce guarded observed aggregates without claiming verified-unit-spend.
No persisted fresh flag, attention wallet total, rank
vector default or cross-tab shared-spent sum exists. Raw evidence may advance while
an older coherent numeric tree remains last observed; tooltips use that tree's own
path evidence/time and do not mix it with the new raw scan.

### K2 backward-compatible native evidence (no schema migration)

Legacy schema1 raw/trees remain valid without new fields or inferred eligibility.
No-policy `Knowledge.Evaluate` keeps its legacy exact-rule fixture behavior. Unknown
or non-string policies never fall through to that mode. New production evidence uses
**`native-rank-reconciled-v1`** only for identity2913/773/profession13/expansion11;
Core checks that scope on active/archive load and cloned candidate generation before
atomic write. Invalid existing data remains untouched with writes disabled.

Native `knowledgeRaw` adds:

- `policy`, numeric `identity={skillLineID,parentID,profession,expansionID}`,
  `sourceCounter?`, `nativeComplete` and existing config/staging/stability/tab flags.
  Missing invalid scalar metadata is omitted, not coerced to0/false; incomplete flags
  remain explicit booleans. `nativeComplete` describes capture, not future cost proof.
- Each tab adds `currenciesComplete`, `currencyStatus?`, `currencyCount?` (copied rows),
  all bounded64 typed currency rows in source order, and existing graph/coverage data.
  Currency rows require unique traitCurrencyID, quantity/spent and optional maxQuantity.
- Each path adds `metadataComplete`, `spendEntryID`, `spendCurrencyID`, and `spend` entry
  alongside `unlockEntryID`/`unlock`. Both entries carry type/maxRanks and explicitly
  observed `entryCost` plus `entryCostComplete`; explicit{} is empty, missing is not.
  Node costs are a separate bounded16-row array of unique `{ID,amount}` pairs.
- Nodes retain ID/type/flags/isAvailable/currentRank/activeRank/ranksPurchased/
  ranksIncreased/maxRanks/totalMaxRanks; optional activeEntry/nextEntry `{entryID,rank}`
  (nil at max for next), entryIDs/entryIDsWithCommittedRanks (32 each) and
  entryIDToRanksIncreased (32 entries). `isAvailable` is not a lock classification.

IDs1..2147483647; ranks/amounts/quantities0..2147483647; all finite integers. Native
lists are dense, plain, unique and inspected at most limit+1 keys; malformed prefixes
are sanitized with false flags. Graph bounds remain8tabs/64paths/tree/16children/path.
Cycles, duplicates, unreachable/shared paths or any omitted metadata prevent new
numeric values. Global copier depth20/50,000-value bounds are unchanged; oversized
payloads reject atomically rather than raise those limits.

Complete native `tree:<tabID>` adds `accountingPolicy`, its own complete same-scan
`currencies`, `currenciesComplete=true`, and required typed
`accountingEvidence={currencyID,spent,quantity,totalPurchased,sourcePin}`. Pin is
`297d7aaaa736f346b3e036f38ee088eaf7f8c07f`; `totalPurchased==spent` is profession-wide,
not the local tree sum. Paths also retain rank-derived purchased/capacity and `locked`.
Core validates these shapes, rank-derived values, graph sums and provenance coherence;
it is NOT independent API proof or a K1 dependency.

The pure engine independently requires tested tiered node type1/flags0, zero increases,
active/current/purchased coherence, exact unlock(type9,max0or1)/spend(type7) pair and
node cap==unlock+spend cap. The increased map covers both entries with0; committed IDs
are a unique subset containing active when purchased>0 (spend-only at max is valid).
Active/next ranks are entry data, not additional purchases; next rank is not assumed
to equal purchased points+1 or constrained to the spend entry's purchased-point cap.
Below max, next rank must be a positive finite integer<=2147483647 and reference the
state-appropriate known entry; active rank coherence/caps remain unchanged. At max,
next must still be nil. Both entry-cost lists must be complete and empty.

Purchased points are `RP>0 and RP-unlockMax or0`; capacity is `nodeMax-unlockMax`.
RP0/unlock1 is locked, with active unlock0, next unlock and exactly one current unit
cost in a **different**, uniquely observed tab currency. Opened paths and unlock0/RP0
paths target spend currency instead; below max next is spend, at max next is nil.
All paths must identify one common spend currency dynamically; every tab must supply
one identical committed quantity/spent row. Grand purchased points reconcile to that
spent **ONCE**. All trees succeed together or none do. Unspent remains independent.
Current costs are state guards, not verified future/all-rank costs; no observed totals,
IDs, capacities or path counts are production defaults.

On any native failure, all discovered and prior indexed trees get failed attempts,
retaining whole prior values/times nonfresh. Incomplete tab reads preserve the prior
index; any failed native evaluation with an existing coherent index now preserves
that entire index/time with a failed attempt, even if the new tab list claims complete.
Retained stale numeric hovers/bars prefer their own stored tree names. No node/tree
cross-scan merge or newer raw evidence borrowing is permitted.
K1 Capture/command/report remains read-only and provisional with no snapshot changes.

### K2 correction data-safety gate — delivered, re-review pending

After existing data pass Core.Open and the cloned candidate generation passes typed/
scope validation, Core.Apply creates a private temporary mirror of the current DB.
It preserves every primitive key/value and shared table reference using memoization,
with protected failure and unchanged depth20/50000-value/string/key bounds. Ordinary
Core.Copy is not used to create the mirror because it duplicates shared references.

Only `mirror.characters[guid]` is replaced by the cloned candidate, then unchanged
Core.Copy checks that assembled graph before the single real `db.characters[guid]=c`
commit. Root/nested aliases to the characters map therefore see the candidate in the
preflight exactly as they do after the real commit. Aliases to the old character object
remain old; they are not redirected to the candidate. The mirror is discarded, never
installed into the real DB. Valid preexisting aliases are not rejected by policy.

Mirror/preflight failure returns a bounded reason before any real mutation, retaining
original root/map/character/reference identities, keys, generations and times. No
limits raised, reset/eviction, unknown-key omission or DB/container replacement. Only
Core.Apply's preflight changes; archive/delete/other alias behavior is not modified.

Fixtures derive individually valid old/input and assembled50001 reject/50000 fit
boundaries, including root/nested/multiple map aliases and old-character aliases.
They assert retained failure graph identities, successful same-map aliases, immediate
reopen and old-character alias retention. All96 definitions remain NOT RUN here;
independent re-review and user fixture/client validation are separate pending gates.

## U03 optional profession Details report

This remains **schema1**, with no DB reset, migration, version bump or implied
eligibility for other professions. Old records without `professionDetails` remain
valid. The field is permitted only in generation identity2913/773/profession13/
expansion11, including archived generations. Core's registered validator applies on
load and the unchanged atomic Apply path; no trusted payload bypass exists.

```text
{version=1, skillLineID=2913, configID, sourceScanAt, trees={
  {id, name?, root, purchased, capacity, paths={
    {id, name?, purchased, capacity, locked, description, perks={
      {id, rank, state, isMajorPerk, description}, ...
    }}, ...
  }}, ...
}}
```

- Dense arrays:1–8 trees, **64 paths total**,32 perks/path,512 perks total. Tree,
  path and perk identities are unique within their respective kind across the report;
  each tree root is one of its own paths. Preserve source traversal order.
- Native IDs1..2147483647; purchased/ranks0..2147483647; capacity positive and within
  that bound. Purchased<=capacity; each tree purchased/capacity equals the sum of its
  individual paths. Locked paths have0 purchased. Perk rank<=path capacity; state is
  **only0 Unearned or2 Earned**. Earned additionally requires unlocked and rank<=
  purchased, including legitimate rank0. Pending1, absent or unrecognized state rejects
  the whole capture; it never becomes an earned milestone or an empty earned list.
- Optional names are nonblank1–256 bytes, no control characters/pipes. Descriptions
  are unmodified client strings, at most4096 bytes each and **32768 description bytes
  summed across the report**. Empty path description explicitly means no supplied
  per-point rule; perk description must be nonblank. No clipping, prefix-as-complete,
  parsed stat totals, inferred recipe IDs or recipe-learned checkmarks.
- Existing generic depth20/50000 occurrence-expanded value/string/key/alias guards
  still apply. A typed report can still fail assembled-DB budget preflight atomically.

Explicit Refresh details alone starts capture, from complete same-scan native-rank-
reconciled saved trees/index/config matching the selected own ready unstaged context.
It privately projects only selected source descriptors, not the entire DB. Startup
validates the DB once; ordinary guarded metadata/perk/verify steps do not Open or Copy
the DB. They check source object/scope/serial/revision and finite time/context. At most
one path metadata, one perk, or one path verification unit runs per frame. The amended
terminal commit frame brackets **at most64 scalar GetNodeInfo checks** with full
Context checks, using only cheap source/token guards between node calls, then calls
unchanged Core.Apply without yielding. No descriptions/perks/entries/costs are reread
in that batch. Step cap10000; no synchronous native drain or automatic resume.

The sole observation is `professionDetails`. Its `attemptedAt`/successful `observedAt`
is actual last-validated detail time, nondecreasing within the job and not earlier
than the prior good report. **Apply.at stays sourceScanAt**, preserving generation
`scannedAt` and dashboard Last Updated. Unrelated fields and session fresh flags are
retained; only details freshness advances or clears on a coherent unknown attempt.
Context/source/generation replacement, cancellation, invalid time or failed final
point check writes nothing. A coherent API/data failure may record an unknown attempt
after the same final point check, retaining the previous whole report/observation
time. Unavailable final checks and Core.Apply budget/invalid-DB rejection do not write
a replacement or partial snapshot. No unknown values are substituted with zero.

The cached panel uses its report's own points, not newer tree points. It shows own
relative observation age (unknown if clock unavailable), freshness, saved/not-current
or archive status; a different current scan timestamp is explicitly not current.
Reload/session invalidation never promotes saved details to fresh. Display-only markup
cleaning leaves persisted wording, conditions, paragraph breaks and rank0 recipe-like
milestone text unchanged. Recipe learning is not checked in this slice.

**Downgrade caution:** previous addon code does not recognize this new optional field
and fails closed on saved data containing it. Reverting code is not backward-compatible
with newly captured data. Preserve the **pre-update SavedVariables backup** for a
coordinated revert; do not strip the field, reset data, or put old code on new data as
a workaround. Keep diagnostics and unrelated saved data intact.

## Session freshness

Freshness is **not saved**. A guarded scan issues an in-memory token tied to current
GUID/profession/generation and context revision. Login/reload, context loss and
relevant change events invalidate tokens. Offline or invalidated values are always
timestamped snapshots. Failed attempts cannot become fresh retained observations.

See [evidence](evidence.md) for source contracts and [manual guide](README.md) for
validation and safe data handling.

## K09 clarification — 2026-11-16: exact eight-profession native scope

This dated clarification supersedes historical Inscription-only numeric/raw scope and
synthetic arbitrary spend-currency acceptance above. Schema remains **1**, accounting
policy remains `native-rank-reconciled-v1`, source pin remains
`297d7aaaa736f346b3e036f38ee088eaf7f8c07f`. No accounting formula, all-rank cost proof,
field envelope, archive structure, observation-time rule or safety limit changes.

Core loads before Data and privately owns the sole production numeric eligibility/
currency catalogue. `Core.NativeKnowledgeCurrency(identity)` returns only a scalar
currency or nil; all four numeric fields must match exactly and metatable/malformed
identities reject. It neither exposes a mutable registry entry nor depends on Data,
tree names/IDs, Moxie, caller overrides or future entries in Data.expansions. Q03's
focused Retail12.1.5/build70783 observations support these exact mappings:

| Profession | skillLineID / parentID / profession / expansionID | Trait spend currency |
| --- | --- | --- |
| Alchemy | 2906 / 171 / 3 / 11 | 4030 |
| Blacksmithing | 2907 / 164 / 1 / 11 | 3750 |
| Enchanting | 2909 / 333 / 9 / 11 | 4056 |
| Engineering | 2910 / 202 / 8 / 11 | 3903 |
| Inscription | 2913 / 773 / 13 / 11 | 3902 |
| Jewelcrafting | 2914 / 755 / 12 / 11 | 3989 |
| Leatherworking | 2915 / 165 / 2 / 11 | 4085 |
| Tailoring | 2918 / 197 / 7 / 11 | 3736 |

These IDs are not Moxie and never populate missing API results. The evaluator still
discovers each path's actual spend currency independently and requires it to equal
the supported identity's expected currency. Dynamic common-currency consistency,
per-tab identical shared quantity/spent pairs and purchased-point reconciliation ONCE
remain mandatory. Even an internally coherent arbitrary3902/70002 rewrite under the
wrong profession fails all trees. Configs, tab/child order, topology, ranks, capacities,
labels and live balances remain dynamic; no native observed totals become defaults.
Automatic unlock exclusion, full locked capacity, type/entry/rank/current-unit-cost/
coverage/ownership/staging/source bounds and future-cost caveat are unchanged.

For native-policy `knowledgeRaw`, identity must be resolver-supported; **every present
path spendCurrencyID** must equal its expected currency, even when incomplete. Existing
incomplete flags may accompany absent spend/node/entry metadata. Typed-valid partial
raw is not numeric eligibility: empty tabs or absent spend metadata never imply zero
numeric totals, known currency, full capacity or complete coverage. Legacy no-policy
payload acceptance remains unchanged.

Generation validation binds native raw's four identity fields exactly to the owning
generation and each native tree's accountingEvidence.currencyID to that owner's expected
currency. This applies equally on Apply candidate validation and active/archive Open,
including tree-only generations with no raw field. Standalone tree ValidPayload has
no owner and does not infer identity from names/tree IDs; its existing internal path/
evidence currency guards remain. Do not require equal timestamps or balances across
separately retained successful tree fields or borrow newer raw metadata for old trees.

Scan retains supported typed-valid raw within the existing combined raw/result budget
even when numeric evaluation fails. Invalid raw (including wrong observed currency)
records an unknown no-value raw attempt with bounded reason, preserving prior coherent
raw; unrelated valid generic observations can still commit. Unsupported identities
record unsupported no-value raw. Failed numeric evaluation retains the whole prior
tree index and whole coherent trees with original observation times/nonfresh state;
first failures remain unknown, never fabricated zeroes. All clone/preflight/single-
commit, invalid-existing-data no-reset, aliases, depth20 and50000-value budgets remain.
Assembled snapshot overflow still rejects atomically; no hidden omission or eviction.

Unspent KP remains the independent GetCurrencyInfoForSkillLine observation, never
shared spent or a sum of auxiliary quantities; positive unspent does not disable bars.
`professionDetails` and its generation predicate remain exact2913/773/13/11 only.
Details capture/UI, legacy knowledgecheck and eight-profession evidence knowledgecapture
are unchanged. No new API calls, migration, resets or expansion/gathering support.
Older code's Inscription-only validator cannot read newly saved other-profession native
fields; preserve an appropriate pre-update backup for any coordinated revert rather
than stripping fields or resetting data. Local fixtures are not native K09 acceptance.

## 2026-11-16 — U05 optional character class identity (schema1, no migration)

`characters[GUID] = {name, realm, classToken?, professions}`. Optional `classToken`
is a string of1..32 uppercase ASCII letters (`^[A-Z]+$`), validated by the shared
boolean `Core.ValidClassToken`. Existing Open and incoming Apply reject invalid
explicit tokens atomically, without reset or graph mutation. Missing incoming token
preserves a known token on the same GUID; it never copies another character's class.
Old schema1 snapshots without it remain valid/neutral. No bump, migration or eviction.

The existing guarded own-player Character read optionally calls
`UnitClassBase("player")`, using only its first `classFilename` return. Failed,
unavailable or invalid optional reads are omitted; generic scanning still works and
prior class identity survives. This does not permit live offline-alt/GUID inspection,
localized-name/profession inference, new events or render/hover-time class collection.
Q03 records source evidence at297d7aaaa736f346b3e036f38ee088eaf7f8c07f; no new native
execution is claimed. No RGB, classID or runtime ColorMixin is persisted.

ViewModel carries the saved token separately from plain identity/cell strings.
Dashboard protected-reads static `C_ClassColor.GetClassColor(token)` and its GetRGB
or r/g/b scalars, requiring finite components in0..1, otherwise white. Every reused
cell font resets to white before applying Name-only color. Native color lookup is
presentation, not a live query of the offline character. Private profession/tree-ID
palette and typed heading-sort keys are also presentation only, never accounting
eligibility, topology, raw evidence, saved settings or new field observations.
All profession envelopes, freshness/timestamps, archives, alias/commit/traversal
budgets, Knowledge numeric/raw gates and attention thresholds remain unchanged.

## S01 provisional schema2 — implementation blocked, not an accepted upgrade

2026-11-16. Exact settled shape and keep/share/discard rules are in
[the S01 contract](storage-s01-contract.md). This appendix describes the partial source,
not a claim of a complete migration or installation-ready revision.

The new plain root is `{schema=2,nextCatalog=1,catalogs={},characters={}}` (counter value
shown for an empty store only). Characters retain name/realm/optional classToken and a
profession directory. Professions retain nextGeneration, optional active generation and
an archive **map keyed by generation**, not a dense array. Generations retain independent
field attempts and successful status/time/build/generation envelopes, scan identity/time
and archive metadata. Catalogue keys are immutable numeric revisions; definitions include
kind, four-field identity, successful build and only independently attributable locale.

Trees persist `tree-ref-v1` catalogue references, purchased/capacity totals, points, locks,
availability and compact accounting evidence. Raw Knowledge retains `raw-summary-v1`
context and tab-coverage summaries, not native nodes/entries/costs/currencies. Presentation
expansion is marked compactSnapshot and cannot be replayed through the rich tree validator.
Details independently retain `details-ref-v1` definition references, points/locks/perk
states/config/sourceScanAt; expansion uses the unchanged typed Details validator. Generic
payload metadata remains owned/exact. Runtime handles/indexes/tokens and the one rich scan
source used for guarded Details acquisition are ephemeral and never saved as rich backups.

Primitive per-unit guards remain Core.Copy50000visits/depth20/4096-byte strings and original
key/finite checks. There is no new fixed character or aggregate account-value ceiling.
Provisional startup processes raw directory edges in batches and snapshot/catalogue units
separately; display uses an iterator, per-row work and bounded mergesort. No native timing,
serialization durability or complete interference/scheduler coverage has been established.

**Blocked boundary:** unmodified schema1 Core legitimately retains more than8 historical
tree fields after a successful index change. S01 keeps all of them, yet contract5 bounds
record-Step dependencies to8 tree definitions. Actual local9-tree migration currently
validates9 distinct definitions in one Step, so the required regression FAILS. Primary must
settle the preservation/work-bound conflict before dependent implementation continues.

Before any eventual upgrade, back up SavedVariables while WoW is not writing them. The
intended migration validates the full legacy source, privately builds schema2 and fully
validates the candidate before replacing the root. Failure/cancellation keeps the original
root; no automatic repair, reset, eviction or persisted full rich backup is authorized.
To downgrade after a future accepted migration, restore that complete pre-upgrade backup
and its matching old addon together. Never relabel schema2 as schema1 or ask an old addon
to write it. No upgrade/downgrade/install operation was performed by the writer.

## S01 completed local format and scheduling amendment

2026-11-16. The earlier provisional block is historical. Settled contract5a now implements
complete retained-field preservation with one catalogue-validation unit per job Step,
not an eight-field history cap. The eight-tree native acquisition/current-index limit
does not constrain older successful `tree:*` fields retained in a generation. Independent
per-unit Core.Copy50000visits/depth20/string/key/finite guards remain unchanged.

Schema2 startup copies and validates every catalogue separately before record validation;
record assembly resolves only that job's owned validated registry and checks reference,
kind, owning identity/build, exact path coverage, personal state and totals. Migration
compacts one field per Step (at most one special-field catalogue), compares retained
generation/envelope/value semantics and all independent times, then runs complete candidate
opening before exposing a ready handle/root. Every directory/archive/catalogue/record and
alias/ownership check must finish. No partial root or rich backup is saved on interruption.

Iterators prepare each requested record's dependencies one per Step and expand one owned
presentation unit; model jobs pin options/revision/time/freshness, build one row at a time
and mergesort with at most128 compare/move operations per Step. Jobs publish only complete
results; cancellation/reentry/drift/errors retire private partial state. Direct synchronous
Read/Apply/Archive freshly validate touched mutable saved units and catalogue content,
not startup pointer identity. Private immutable-content/owner/counter checks guard in-process
interference. This is not adversarial multiwriter or process-crash durability support.

Generic values/metadata, failed attempts and same-instance equipment merging retain their
legacy semantics. Tree presentation is compactSnapshot=true with honest observed personal
locks/availability and scalar accounting evidence, never invented native reports. Raw summaries
cannot be replayed. Details definitions/state remain independently versioned/timed and their
expanded personal values use the unchanged Core Details validator. Shared definition reuse
requires complete exact content, owning four IDs, successful build and attributable locale;
later raw/environment/Details observations cannot supply missing older field context.

Final local446/446+744K6/565K7+23/23/bothPythonPASS and growth/history work counts are in
TASKS/evidence. Implementation complete is not independent verification, acceptance, native
serialization/timing/API proof or installation permission. The backup-based downgrade policy
above remains required for any future accepted upgrade; no reset/repair/eviction is added.

## S01 piece8 reviewed dependency preflight and bounded frame batches

2026-11-17. No saved format/version change. Every reused SAVED catalogue now requires fresh
registered root and nested table ownership, no cross-unit/internal alias, original primitive/
typed definition validation and immutable content before any write, even for a NEW character
without a prior active generation. Identical-content root/nested replacements are not an
ownership certificate. A reused job-private staged/validated definition remains private and
does not adopt mutable public saved tables. Normal compatible catalogue sharing still works;
rejection preserves root graph, counters, revisions and active tokens without partial owners.

Contract5b supersedes only startup/dashboard's fixed one-Step/frame policy. Runtime-only
Storage.NewFrameBatch(env):Step(job,guard) performs at most16 bounded job units per callback,
checking finite monotonic observed elapsed time before/after units and stopping at>=2ms.
It selects profile milliseconds, else precise seconds*1000, else explicit clockless-one-step
fallback. Once selected, throwing/invalid/backward/overflowing clocks fail closed without
switching or draining. Guard pauses, exceptions and reentry cannot advance extra units or
publish unsafe/superseded output. Drivers check ownership/context/revision/options/safety
again after the batch and after publication cleanup. Runtime mode/status and work counters
are not SavedVariables. A single unit may exceed the observed budget; no preemption or
quantitative native frame-time guarantee is claimed. All individual job/primitive/native
bounds, saved field semantics and other collector/selftest/capture/Details schedulers remain.

Original446 source/test history and independent CHANGES REQUIRED remain; corrected458/458
local fixtures do not replace renewed independent verification/primary acceptance or prove
native serialization/timing/API behavior. No upgrade/rollback/install operation was performed.

## S01 piece9 startup invocation ownership — 2026-11-17

No saved format/version or native/primitive/job budget change. Startup invocation ownership
is now a private monotonic epoch plus captured job/runtime identity, separate from original
saved-root equality. Entry cleanup captures old job/frame and stops after any callback that
starts a newer invocation. Setup/error/source-drift/finish/cancel paths recheck ownership
after callbacks before state/status writes; cleanup never targets a replacement frame/job.
Explicit cancellation advances the epoch to retire saved callbacks. A current invocation
can explain source drift without requiring the original root pointer; a stale one cannot
overwrite a newer pending reason/dashboard status. Replacement opening still preserves
the original root graph until its guarded complete publication; no automatic retry added.

The combined terminal-clock-error/Hide-retry regression failed before correction; current
463-case local suite preserves all458 previous test bytes and adds5 cases with equivalent
setup/cancel/entry/error/source-drift matrices. Runtime-only epoch/status semantics are not
SavedVariables. Prior458 and CHANGES REQUIRED history remain; renewed review/primary
acceptance pending, not native API/performance proof or installation permission.
