# CraftArmy — detailed design proposal

> Recorded 2026-11-05 from the initial planning conversation. **Proposed unless
> explicitly confirmed in PLAN.md.** This is a design reference, not an executable
> task queue. API signatures, readiness conditions, identifiers, and target-build
> behavior must be checked during a separately approved feasibility spike.

## Accepted refinements from the design interview

The decision record takes precedence over the initial proposals below:

- D05: Midnight's eight crafting professions, personal-first, dashboard before guides.
- D06: knowledge activity access before affordable first crafts; preserve intended builds.
- D07: three distinct gear indicators, rarity color plus rank 1–5 iconography, blank
  confirmed missing slots, `?` for unknown slots, tool/enchant stat abbreviations,
  per-tree knowledge progress bars and detailed tooltips, passive warnings, and
  timestamped offline snapshots. Concentration warning starts at 90% of verified cap.
- D08: three route targets, adaptive curated routes, modular Lua/native UI, and
  **Inscription first**. The earlier Tailoring-first suggestion was not adopted.
- D09: bags/personal-bank inventory by default, opt-in Warband bank, remaining-target
  or next-block shopping, **one reusable `CraftArmy` Auctionator list**, resource
  safeguards, and recipe navigation with manual crafting.
- D10: whole-tree purchased-point bars and archived retired/unlearned snapshots.
- D11: actionable one-time knowledge sources and recurring-source unlock guidance;
  full weekly checklist/reset tracking deferred.
- D12: lowest-cost qualifying approved reagents; higher-output premiums opt-in;
  warn on unverified data and block known-incompatible dependent steps/calculations.

## Product shape

Two modules:

1. **Dashboard:** a compact summary of all recorded crafting alts.
2. **Guides:** knowledge-prioritized leveling routes, progress, and shopping lists.

Confirmed first scope (D05): Retail/Midnight, the eight primary crafting professions
(Alchemy, Blacksmithing, Enchanting, Engineering, Inscription, Jewelcrafting,
Leatherworking, Tailoring). Scope history: [Q01](questions/Q01.md). Gathering,
Cooking/Fishing, and older expansions are outside the first release.

## Dashboard

### Summary layout

Use one row per profession, grouped by character. Keep column headings visible in a
scrollable table rather than promising every possible alt fits without scrolling.

| Character | Profession | Skill | Gear: tool/accessories | Enchanted | Concentration | Moxie | Knowledge |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Example–Realm | Alchemy | 75/100 | Epic / Rare / Rare | Yes | ~820/1,000 | **650 ⚑** | 120 spent; 8 available |

Example values are illustrative, not verified game data.

- Character name, realm, class color, and last-seen time.
- Localized profession name and selected expansion.
- Expansion-specific base skill/current maximum; equipment and racial modifiers
  shown separately in a tooltip.
- Three independent gear indicators: tool and two accessories. Rarity color and
  crafted-rank iconography (1–5) convey separate properties; numeric item level is
  different again. Confirmed missing slots are blank, unknown/unloaded slots use `?`.
  Tooltips provide exact item/rank details; do not infer a rank from item rarity.
- Show abbreviated profession stat labels for the tool and its optional enchant
  separately, with full labels/details in tooltips. Account for multiple tool stats
  without folding enchant contributions into the tool's own stat label.
- Permanent enchant status for the equipped profession tool. Use `Unknown` when
  unobserved and `N/A` when not applicable; never infer `No` from missing item data.
- Concentration amount/cap and estimated time to full when regeneration is known.
- Profession-specific Moxie; icon plus color when `balance > 600`. Recommend an
  optional configurable threshold with 600 as the default.
- Knowledge spent/unspent and progress bars per top-level tree, with detailed point
  distribution in tooltips. Exclude preview/uncommitted changes and distinguish
  automatic/free ranks from purchased knowledge when summing allocations. Aggregate
  purchased points across the tree and all sub-branches against total spendable
  capacity. Show unspent points separately; validate the accounting against the API.
- Dashboard-only attention indicators, no sounds/popups initially. Concentration
  warning at 90% of a verified cap, later configurable; Moxie remains strictly >600.
  Do not present stale/unknown data as a confirmed threshold crossing.

Controls: character/realm/profession/expansion filters, sorting, pinned alts, hidden
retired characters, `/craftarmy`, optional minimap button, and key binding.
Confirmed summary semantics and history: [Q05](questions/Q05.md), D07/D10.

### Collection and offline behavior

Recommend account-wide SavedVariables shared by characters in the same WoW
installation/account scope. Do not rely on arbitrary live inspection of offline alts.

- Onboard by logging into each alt and opening both profession UIs where required.
- Refresh relevant fields on login, skill/profession changes, equipment changes,
  currency updates, and committed specialization changes.
- Validate exact event names and readiness gates in the target client.
- Scan only the player's own profession data; linked or order-related contexts must
  not overwrite character snapshots.
- Track field-level timestamps, scan completeness, and observed/unknown/estimated
  status. Do not replace previous good values with temporary nils or loading defaults.
- Detect unlearning/relearning and expansion changes. Archive retired/unlearned
  snapshots, exclude them from active totals/warnings, and allow manual deletion.
  Relearning triggers a fresh scan, not automatic reuse of historical progression.
- Coalesce event bursts, cache item data asynchronously, and avoid per-frame scans.
- Estimate offline concentration only from verified regeneration data. Persist the
  observation timestamp, amount, cap, and regeneration basis. Clamp to cap, handle
  invalid time differences, label estimates, and rescan on login. If a reliable rate
  is unavailable, show last observed concentration rather than an invented estimate.
- No automatic cross-account/computer synchronization; see [P01](parking-lot/P01.md).

## Knowledge-prioritized guides

### Objective and targets

Knowledge progression differs from profession skill. A route can unlock access to
knowledge systems without earning all available points; maximum skill is not a
completed specialization tree. Accepted objectives: D06/D08/D09/D11/D12;
discussion history: [Q02](questions/Q02.md).

Accepted priorities:

1. Reach profession-specific thresholds for specialization and knowledge activities.
2. Collect accessible first-craft knowledge efficiently while leveling.
3. Explain recipe/build unlocks that enable future knowledge acquisition.
4. Avoid unnecessary gold, Moxie, and concentration expenditure within the chosen goal.

| Route target | Meaning |
| --- | --- |
| Knowledge-ready | Reach milestones for broad knowledge progression. |
| Budget stopping point | Finish efficient leveling before a substantial cost increase. |
| Maximum skill | Continue through expensive or constrained steps to the current cap. |

Targets can coincide. Determine them per profession and data version; do not hardcode
a universal stopping point. A curated budget breakpoint works without price data;
price-aware alternatives may refine it later. Explain the breakpoint and costs.

### Route steps and adaptation

Start with curated, independently tested routes that adapt to the recorded character.
Use recipe/skill-line/node/item/currency IDs internally and localized names at display.

Step types:

- Train or purchase a recipe, including location, skill, reputation, and currency gates.
- Acquire a prerequisite/unlock; show unavailable or externally gated actions honestly.
- Craft once for a remaining first-craft reward.
- Repeat a recipe until target skill, accounting for multiple skill points per craft.
- Produce intermediate materials before the steps that consume them.
- Collect a non-crafting knowledge source or review a specialization recommendation.
- Choose a branch, stop at a milestone, or continue toward maximum skill.

Each step shows recipe, quantity/range, skill band, required reagent quality,
prerequisites, expected skill gains, first-craft eligibility, alternatives, estimated
cost, and rationale. Show next unlocks and remaining blocked knowledge sources.

Recalculate after observed crafts, actual skill changes, recipe acquisition, and
inventory updates. Yellow/green skill-ups are uncertain: estimated counts are not
guarantees. Support existing partially leveled characters, already completed first
crafts, manual acknowledgments for unverifiable steps, and clear blocked states.

Do not assume access to particular Patron orders, cooldowns, rare recipes, or
specializations. Distinguish eligible/available/completed/unknown knowledge sources.
Any source checklist needs versioned IDs and per-source completion evidence.

Include actionable one-time knowledge sources and explain recurring-source unlocks.
Track completion where reliably observable, keeping unknown distinct from incomplete.
Show knowledge earned now separately from future access unlocked. A full recurring
weekly checklist/reset tracker is deferred to [P03](parking-lot/P03.md).

### Reagent selection

Choose the lowest-cost approved combination meeting each step's requirements,
without concentration. Do not pay for higher-quality output unless the user selects
that alternative. Missing prices trigger a curated fallback with unknown cost, not
a cheapest-route claim. Preserve exact quality requirements and approved branches.

### Specialization safety

- Never spend knowledge automatically.
- Do not assume a build or reset availability.
- Explain required investment, opportunity cost, and alternatives before using a
  specialization-dependent branch.
- Require explicit branch selection and preserve the player's long-term goal.
- Validate committed ranks and recipe requirements, not just visible tree labels.

Dynamic pricing should initially select among approved alternatives, not attempt a
universal global optimum; see [P02](parking-lot/P02.md).

## Shopping lists and Auctionator

### Remaining-route material calculation

- Build from the remaining selected route, not a static level-one shopping list.
- Aggregate quantities by exact reagent identity and allowed quality.
- Account for intermediate output quantities, including deterministic rounding.
- Avoid counting both a purchased intermediate and its raw materials as required.
- Subtract accessible owned inventory once; clamp remaining need at zero.
- Keep quality alternatives explicit; do not silently select incompatible substitutes.
- Separate AH items, vendor items, currencies, bind-on-pickup items, and other gates.
- Offer expected quantities and an optional skill-up buffer; do not count random
  resourcefulness/multicraft savings as guaranteed materials.
- Default to current-character bags and personal bank. Offer Warband-bank inclusion
  as an opt-in option (off by default). Deduct only reliably scanned, usable stock;
  stale/unknown bank data is not confirmed absence. Do not automatically deduct
  materials held by other alts.
- Before shared-stock support, add reservations so multiple alt routes cannot each
  claim the same materials. Cached alt stock is not automatically available stock.

### Integration behavior

Auctionator is optional. Verify its supported public API and installed-version
capabilities before implementing; see [Q04](questions/Q04.md).

- User-initiated **Send to Auctionator**, plus a copyable text fallback.
- Own exactly one reusable list named `CraftArmy`. An explicit new export replaces
  that same list across character/profession/target changes; no per-alt lists.
- Preview/confirm owned-list replacement and never overwrite unrelated lists. Handle
  a pre-existing same-name list safely rather than assuming its ownership.
- Retain exact quantities/qualities in CraftArmy when the external format cannot
  represent them. Disclose any reduced fidelity rather than claiming a complete export.
- Treat absent prices as unknown, never free. Show data age and estimate coverage.
- Keep estimates scoped to their price source/market; account for commodities versus
  realm-specific items if prices are used.
- Export does not automatically buy items. Opening/searching and purchases remain
  subject to the target client's supported APIs and user interaction requirements.
- Selecting a guide step navigates to the recipe. The player crafts in the normal
  WoW UI and observed results update progress; do not auto-craft or spend knowledge.
- Default routes spend no concentration. Moxie recipe unlocks are explicit opt-in
  branches; explain targets that cannot be reached without the excluded resources.

## Technical architecture and proposed source layout

Lua/native UI, saved snapshots, and separately loadable guide packaging are accepted
in D08. Account-wide SavedVariables implements the snapshot proposal; no backend,
web API credentials, or external service is proposed. Detailed file layout and exact
test tooling remain task-preparation work under [Q06](questions/Q06.md).

```text
CraftArmy/
  CraftArmy.toc
  Core/          # Bootstrap, database, migrations, event coordination
  Collectors/    # Characters, professions, equipment, currencies, knowledge
  Services/      # Concentration, inventory
  UI/            # Dashboard, profession details, settings
CraftArmy_Guides/
  CraftArmy_Guides.toc
  Engine/        # Routes, progress, shopping lists
  Data/Midnight/ # Versioned profession data
  Integrations/  # Auctionator adapter
  UI/            # Guide and material views
```

Use a separate load-on-demand guide addon depending on the dashboard addon.
Keep client API adapters separate from pure calculations for local unit tests.
Resolve identifiers and capabilities centrally; expansion data must not leak into
generic collection/planning code. Do not guess TOC interface numbers.

### Persisted data

- Schema version and explicit migrations.
- Characters keyed by GUID, with identity/realm/last-seen metadata.
- Profession records keyed by expansion skill-line ID, associated with base profession.
- Base skill/cap, equipment/item links/rarities/enchant evidence, and freshness.
- Concentration observation/regeneration basis and profession-specific Moxie.
- Committed specialization node allocations, unspent knowledge, and scan completeness.
- Known recipes and remaining first-craft observations needed by active guides.
- Route/data version, user-selected branches, progress, and inventory timestamps.

Store only necessary observations; avoid large unbounded event histories. Migrations
must preserve user data, and route upgrades must not silently invalidate choices.

## Delivery phases

Delivery order is accepted; these are **milestones, not executable task pieces**.
Prepare and approve the corresponding `TASKS.md` contract before implementation begins.

| Phase | Deliverable | Acceptance evidence |
| --- | --- | --- |
| 1. API feasibility | Diagnostic collector for one character | Verify every requested field, item loading, spec accounting, currencies, and concentration regeneration on the target build; document UI-open/readiness requirements. |
| 2. Dashboard MVP | Persistent collector and summary | Two alts with two professions each survive reload/logout; incomplete scans remain clear; Moxie at 600 is not highlighted and at 601 is. |
| 3. Dashboard completion | Filters, details, robust snapshots, estimates | Requested fields validated across supported professions; mixed equipment, absent enchants, and stale data handled correctly. |
| 4. One guide | Complete vertical slice | All three route targets, prerequisites, progress, shopping arithmetic, and optional Auctionator export work on a tested profession. |
| 5. Profession coverage | Remaining primary crafting guides | Validate each route's milestones, dependencies, first crafts, material counts, and expensive continuation independently. |
| 6. Release hardening | Packaging and maintenance workflow | Clean install, migrations, localization, optional dependencies, compatibility checks, and documented patch validation. |

Accepted order: dashboard first, **Inscription guide next**, then expand coverage.
Engineering or Alchemy may later provide a complex-dependency test, but that later
order is not committed. No duration estimate is committed.

## Validation strategy

Choose tooling and commands in the first authorized implementation contract.

Automated tests should cover:

- Database migrations, snapshot merging, missing/loading data, and unlearning.
- Concentration regeneration math, caps, invalid elapsed time, and stale observations.
- Moxie below/at/above 600, plus missing values and configured thresholds.
- Committed knowledge allocations without double-counting automatic/free ranks.
- Route prerequisite ordering, unreachable steps, completed first crafts, variable
  skill-ups, and selected specialization branches.
- Shopping quantities, intermediate production rounding, quality alternatives,
  shared-stock reservations, and inventory freshness.
- Optional Auctionator availability, unsupported API, owned-list name collisions,
  export fidelity, and missing prices.

In-game tests must verify real API readiness and event behavior, mixed/missing gear,
enchants and unloaded items, multiple alts/realms/locales, profession changes,
reload/logout persistence, and interaction with other profession addons. Check that
no secure/protected UI behavior is tainted. User-driven live testing remains with
the primary; mocked tests do not replace it.

## Content and patch maintenance

- Version guide content separately from addon code.
- Record sources, target build, validation date, prerequisites, and known limitations
  per profession route. Do not claim an untested route is optimal or patch-current.
- Use original instructions; reference external guides rather than copying their text.
- Validate currency/skill-line/recipe/node IDs, source completion flags, knowledge
  rewards, recipe requirements, equipment changes, and skill-up bands after patches.
- Unverified guide data displays a warning and validation date. A newer client build
  alone does not prove incompatibility. Block known-incompatible steps and dependent
  shopping calculations, explain the issue, and offer a validated alternative when
  available. Keep the dashboard and unaffected guide sections usable.
- Packaging, distribution platforms, license, and automated release tooling remain
  future release decisions, not authorization to publish.

## Reference starting points

These informed the proposal, not an in-game certification of all API behavior:

- [Retail TradeSkillUI API documentation mirror](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/TradeSkillUIDocumentation.lua)
- [Auctionator features and shopping lists](https://addons.wago.io/addons/auctionator)
- [Midnight Inscription mechanics/equipment example](https://www.wow-professions.com/midnight/inscription-guide)

Use the target client's shipped UI/API documentation and the installed Auctionator
version as implementation references. External guides can conflict or lag patches;
validate all route-specific facts rather than propagating unverified numbers.
