# CraftArmy

A World of Warcraft **Retail** addon for managing crafting alts and their profession
progress in one dashboard.

Source repository: [Arbixal/craftarmy](https://github.com/Arbixal/craftarmy).

## Current status

The dashboard is implemented and user-signed-off. It supports the eight primary crafting
professions: Alchemy, Blacksmithing, Enchanting, Engineering, Inscription, Jewelcrafting,
Leatherworking and Tailoring. Profession guides, shopping calculations and Auctionator
export are planned but **not implemented**; Inscription will be the first complete guide.

The dashboard includes:

- Saved character/profession snapshots, with no fixed character cap.
- Skill, profession gear, Moxie, Knowledge and Concentration.
- Filters, sorting, current-character priority and scrollbar navigation.
- Distinct observed and estimated Concentration portions. Estimates are approximate;
  sorting and attention filters use observed values.
- Native item tooltips, with additional diagnostics available on Shift-hover.

Offline characters show saved observations, not live inspection. Unknown data is not
treated as zero or confirmed absence. Existing snapshots are retained on failed reads.

## Installation and use

1. With WoW closed, back up existing CraftArmy SavedVariables before updating.
2. Copy `CraftArmy/` into `World of Warcraft/_retail_/Interface/AddOns/`.
3. Optionally install `CraftArmy_Diagnostics/` alongside it for the separate diagnostic
   harness. It is not a dependency of the main addon.
4. Open the dashboard with `/ca`; `/ca help` lists commands. Open your own supported
   profession normally to collect its data; `/ca scan` requests a guarded refresh.

See the [dashboard documentation](docs/dashboard/README.md) for behavior, current
validation evidence and update/recovery notes. Do not reset SavedVariables to refresh data.

## Development

Run from the project root, using an **already-installed Lua 5.1** runtime:

```sh
lua5.1 tests/dashboard.lua
lua5.1 tests/run.lua
python3 tools/check_dashboard.py
python3 tools/check_diagnostics.py
```

Latest dashboard validation completed 512 top-level cases, all 19 grouped U07 workloads,
744 K6 and 565 K7 supplemental checks; diagnostics completed 23/23 cases. Python checks
are structural only. Local tests do not establish native client behavior or measured
performance; known evidence limitations remain documented.

## Project layout

| Path | Purpose |
| --- | --- |
| `CraftArmy/` | Main addon |
| `CraftArmy_Diagnostics/` | Independent diagnostic addon |
| `tests/`, `tools/` | Local fixtures and structural checks |
| `media/` | Preserved original branding assets |
| `docs/` | Design, decisions, validation evidence and history |
| `PLAN.md`, `TASKS.md`, `AGENTS.md` | Requirements and development workflow |

The original and packaged icon assets are documented in the
[asset manifest](CraftArmy/Media/Icons/README.md).
