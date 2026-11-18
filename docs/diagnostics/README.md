# CraftArmy Diagnostics (T01)

This is a **manual, read-only evidence harness**, not the dashboard or a verified
production collector. Implementation approval does not authorize publication or
automated game installation. See [evidence and outstanding gates](evidence.md).

## R1 update and fresh retest (0.1.1-diagnostic)

The user's 0.1.0 result (18/18 fixtures passed) is historical. Its large Inscription
sample was truncated and missed late path nodes. R1 changes knowledge capture only;
the revised 23-case fixture suite and client scan need fresh execution and review.

After primary independent review, the **user** should exit WoW, back up the existing
diagnostic addon folder and its own SavedVariables files, then replace only the addon
files with 0.1.1-diagnostic using the manual installation steps below. Do not delete
or reset `CraftArmyDiagnosticsDB`, the WTF directory, or other-addon data. Interface
120105 and DB schema 1 are unchanged; no migration, rewrite of previous samples or
new storage allowance is performed. Normal retention still removes the oldest
sample on a 21st successful save; keep a private backup if older evidence is needed.

1. Run `/cad selftest`; record the fresh **23-case** result and any failures.
2. Manually open your own Inscription/specializations, then run
   `/cad scan inscription-open-r1` and `/cad export`.
3. Confirm the new sample reports version `0.1.1-diagnostic`, all four tree identities,
   their root paths and `.node.<id>` path details, including the last tree. Inspect
   `knowledge.coverage`, each tab's omissions/failures/limits/budget drops, and the
   sample's `truncated` / `knowledgeCoverageFailed` flags. Do not infer zero allocation
   from missing detail. No spending, staged edits or item changes are required.
4. Compare available path ranks with the UI; do not sum repeated trait-currency
   `spent` values across trees or treat current/free ranks as purchased knowledge.
   Review/redact identifiers and links before manually sharing the result with the
   primary. Keep the old sample as historical evidence, not as a revised-code pass.

## Safe manual installation/removal (user only, after primary review)

1. Exit WoW. Back up any existing `CraftArmy_Diagnostics` folder and its own saved
   data before replacing anything. Do not overwrite an unfamiliar addon folder.
2. Manually copy **only** the repository's `CraftArmy_Diagnostics` folder into the
   Retail client's `_retail_/Interface/AddOns/`. Do not copy tests/tools/docs or any
   planning files. The folder must directly contain its `.toc` and four Lua files.
3. TOC Interface is `120105`, corroborated from current public sources (see evidence).
   This is **not** proof of your installed build. Record the actual `GetBuildInfo`
   output through a sample; stop and report mismatches/load errors to the primary
   rather than changing metadata or enabling out-of-date addons blindly.
4. Enable the diagnostic in WoW's AddOns screen. Auctionator is optional and is
   never force-loaded. Start with `/cad help`, then `/cad selftest`.
5. To remove: exit WoW and remove only the diagnostic addon folder. Its data may
   remain in the account's `WTF/.../SavedVariables/CraftArmy_Diagnostics.lua` and
   `.lua.bak`. If explicitly wanting to erase diagnostic samples, back up then
   remove only those files with WoW closed. Never delete the whole WTF directory
   or another addon's data. Removing the addon alone need not delete its data.

The implementer has not installed or run this in a game client.

## Commands

| Command | Effect |
| --- | --- |
| `/cad help` | Safety/privacy notes and usage; no sample |
| `/cad scan [label]` | One labeled current-character sample |
| `/cad inventory <itemID>` | Same metadata plus bag-only and personal/reagent-bank-inclusive counts; account bank explicitly false |
| `/cad inventory <itemID> warband` | Adds a third count including account/Warband bank; explicit opt-in only |
| `/cad currency <currencyID>` | Query one **unverified candidate** ID; does not establish a Moxie mapping |
| `/cad selftest` | Shared pure fixtures with injected fake APIs; no live collection or saved-data writes |
| `/cad export` | Selectable read-only report for this character's retained samples; manual copy, Esc/close to dismiss |

Use numeric positive item/currency IDs, not localized item names. Arguments are
case-sensitive except command verbs. No clipboard API or automatic uploads exist.
Inventory/currency commands also record the normal scan metadata; all probes run
only at command time. There is no polling, gameplay action, or automatic profession
opening. No item-data load requests are made: loading/nil is recorded as such;
manually rescan later. No event-driven retry or deferred sample reassignment exists.

## Interpretation, privacy and limits

- Every recorded field has a status, timestamp and API source. Statuses are
  `observed`, `empty`, `unknown`, `unsupported`, `error`, `not_applicable`.
  `timeKnown=false` explicitly marks a missing clock (numeric time then is a 0
  sentinel, not an observed epoch timestamp).
  `0` and `false` are valid observations. `empty` means an explicit false result
  from item existence at an evidenced player slot, not a nil/cache miss.
- Failed/latest attempts retain the last observed field as `lastObserved` with its
  original time/source when that field occurs in prior retained samples. It is
  historical evidence, not a current value. Skipped dependent fields are not
  silently copied into the latest sample; earlier samples remain available.
- The normal professions frame must be visible, all linked/guild/NPC/changing
  guards must explicitly be false, and profession IDs must be positive. Missing
  guards fail closed. Closed/inspected/unready context does not establish zero skill.
  Verify those guards on the actual client; UI visibility alone is not ownership proof.
- Equipment rarity and crafted rank are independent. Slots retain numeric indices;
  tool/accessory ordering is **unknown**. Full whitelisted `ITEM_MOD_*` stat keys
  are retained, but base/enchant contribution is not separated. Permanent-enchant
  lines are localized evidence, not a verified enchant-stat mapping. Zero lines
  do **not** prove no enchant. Unknown rank is not rank zero.
- Tree currency uses `excludeStagedChanges=true`. Node ranks are raw evidence;
  `committedPurchased` is populated only when `ConfigHasStagedChanges` explicitly
  returns false. Current/free/increased ranks never become purchased totals. Node
  `maxRanks` is not spendable tree capacity. No derived tree denominator or total,
  Moxie mapping, concentration phase, or offline projection is invented.
- **Compact knowledge scope:** all bounded tabs' identity, committed currency
  observations, root path and `.nodeList` count summary are attempted **before** any
  detail. Path traversal/detail then proceeds breadth-first within each tab and
  round-robin across tabs, so later tree roots are prioritized too. `.node.<id>`
  details are selected by discovered specialization paths, not the first 64 entries
  of a raw perk/node list. Non-path perk-node detail is deliberately not queried.
  `.nodeList` records raw count and bounded inspection/limit/invalid flags, not the
  old full `.nodes` ID list. This is not an exhaustive trait dump or KP calculation.
- `knowledge.coverage` is a normal timestamped field whose observed value describes
  **capture bookkeeping**, not verified tree totals. `policy=paths_only` identifies
  intentional compact omissions. Each bounded tab reports `rawNodeCount`, bounded
  `pathsDiscovered`, successfully stored observed `pathsCaptured`, `nonPathOmitted`,
  `pathComplete`, `failures`, `budgetDrops`, and child/path/node-list/invalid/repeated
  flags. Unknown counts are the explicit string `unknown`, not zero. Discovered
  counts are lower bounds when traversal fails or is limited. Non-path omission
  counts are known only with a complete bounded traversal and a usable complete raw
  list (no node-list limit); otherwise they stay unknown. A node API failure can coexist with
  known intentional non-path omissions: failed path detail is a separate problem.
- Coverage also reports raw `tabCount`, tab-list status/invalid and tab-limit flags,
  config status, original traversal limits and aggregate `budgetDrops`.
  `pathCaptureComplete=true` means the selected bounded path scope had no detected
  failure/limit/write drop; it does **not** mean all perks, KP totals, free/unlock
  accounting or spendable capacities are established. Repeated path references
  conservatively prevent completeness claims (including cycles). Missing root,
  child, node or list data is unknown/error, never a complete observed empty tree.
- Only during knowledge collection, ordinary writes use a reduced 61,440-byte /
  511-field ceiling to reserve **4,096 bytes and one field** for final coverage.
  Final coverage must still fit the original total limits and at most the reserved
  bytes. Budget-rejected writes are counted, not treated as successful captures.
  Intentional non-path omission alone does not set `truncated`; budget loss does.
  `knowledgeCoverageFailed=true` means full coverage could not be stored (for
  example extreme exhaustion before knowledge). A small error fallback is attempted,
  `truncated=true` remains explicit, and the flag is exported even if no field fits.
  `false` only means full accounting was stored, not that the capture is complete.
  Historical samples without a knowledge attempt do not acquire this flag.
- Inventory flag order is `(includeBank, includeUses, includeReagentBank,
  includeAccountBank)`: bags `(false,false,false,false)`, personal
  `(true,false,true,false)`, opt-in Warband `(true,false,true,true)`.
  Bank-frame visibility is captured separately; bank type/freshness/usability are
  unknown. Counts, even observed zeros, are API outputs, **not** proof that cached
  bank/Warband materials are currently usable. No other-alt inventory is inspected.
- Auctionator namespace/candidate read-method presence is recorded, but **no
  Auctionator method is called at all**: installed public signatures are unverified.
  Existing `CraftArmy` list readback is unsupported, not an empty list. No list
  creation, replacement, deletion, search, purchase or internal write is attempted.
- Only `CraftArmyDiagnosticsDB` (schema 1) is written. At most 20 manual samples per
  character; the oldest is removed on the 21st successful save. Maximum 20 characters;
  new characters beyond that limit are refused rather than evicting another alt.
  Reload does not reset data; unknown/invalid schemas are refused and left untouched.
- Per sample: maximum 512 fields and 65,536 serialized field/key bytes. Fields past
  limits are omitted and `truncated=true` is explicit. Primitive/table sanitization
  caps strings at 1,024 bytes, tables at 128 entries and nesting at 8 levels; labels
  at 80 bytes. Probe-specific caps: 8 slots/tabs/currencies, 64 unique paths/path-node
  details per tab, 16 children per path, 128 raw node-list entries inspected per tab,
  64 tooltip lines, 8 permanent-enchant lines and 32 stat keys. This is a
  diagnostic sample, not an exhaustive specialization database.
- Export is deterministic JSON text (numeric table indices are object keys), limited
  to this character's latest 20 samples. Quotes/control characters/backslashes and
  WoW pipes are escaped. Functions/userdata/cycles are omitted; arbitrary globals,
  error payloads, bags contents and other-addon internals are not captured.
  Reports **can contain GUID, character name/realm, locale, item links, IDs and
  user labels**. Review/redact before manually sharing. Nothing is transmitted.

## User-run checklist (primary coordinates)

Record dated rows in [evidence.md](evidence.md), with a redacted sample/label and
actual UI comparison. Do not spend resources to manufacture examples. Unavailable
cases remain **NOT RUN**; fixture passes cannot establish API behavior.

1. **Load/fixtures/context:** record client version/build/Interface and Auctionator
   version. On an Inscription alt run `/cad selftest`; retain the complete summary
   and any failures. Before opening professions run `/cad scan before-open`, then
   manually open your own Inscription/specializations and run `/cad scan after-open`.
   Compare identity, skill/cap/modifier, concentration and knowledge with the UI.
   Verify closed/linked/inspected/unready scans do not attribute another crafter's data.
2. **Equipment:** observe already available equipped/empty/unloaded slots, mixed
   rarities and ranks (including ranks 4/5 if available), multiple tool stats and a
   permanent enchant. Compare the exact links/indices/icons/tooltip lines. No
   buying, crafting, equipping, enchanting, filter changes or knowledge spending.
   Keep unverified roles and enchant-stat attribution unknown.
3. **Knowledge:** compare committed purchased ranks vs free/unlocked/increased
   ranks and unspent knowledge. No staged edits are required by this task; if
   already present, capture them without committing/refunding. Confirm nullable
   currency capacity stays unknown and staged nodes are never labeled committed.
4. **Persistence/concentration:** label scans before reload/logout and after relog.
   Avoid intervening concentration spending if comparing regeneration. Check original
   timestamps/last observed data survive reload. Record elapsed time and observed
   change for later analysis; predicted change is **NOT IMPLEMENTED**, not zero.
5. **Inventory:** choose a known item ID. Probe before and after manually opening the
   personal bank; optionally repeat with `warband` before/after manually opening
   Warband bank. Record bank type/open state yourself next to reported frame visibility.
   Compare flags and UI counts; do not move/consume items. Default scan must not make
   an account-bank-inclusive query. Cached zeros must not be labeled verified absence.
6. **Auctionator:** in separate user-managed disabled/enabled sessions, record version
   and namespace/method presence. Confirm no lists are created/replaced and no search
   or purchase occurs. Readback remains unsupported until a later verified public
   signature is approved; mutating integration tests require separate approval.
7. **Another alt/profession:** repeat when available. Check retained reports belong
   to the correct GUID, survive reload, and do not query other-alt stock. Export is
   current-character-only. Do not unlearn a profession merely for this diagnostic.

## Local checks (from repository root)

Inspect the scripts before running. No package installation is needed or authorized.

```sh
python3 tools/check_diagnostics.py
# Only if already available; do not install a runtime for T01:
lua5.1 tests/run.lua
```

The Python check is read-only, stdlib-only packaging/structure inspection; it does
not parse Lua or verify client APIs. The optional Lua runner and `/cad selftest`
load the same `Core.lua`, `Probes.lua`, and `SelfTests.lua`, not separate test logic.
It never loads `Commands.lua` locally. Revised Lua syntax/fixture execution and live
checks are pending; the original 0.1.0 user result does not validate R1. Independent
review, client feasibility acceptance and release are separate gates; Q03/Q04 remain open.
