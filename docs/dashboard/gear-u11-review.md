# U11 — decorated links and compact gear spacing

## Latest focused native feedback — 2026-11-17

User confirms red borders now show and Resourcefulness Tool displays R.24px/28px internal
icon spacing is accepted. Multicraft consistently displays `...` across characters;
Gear cramped against Skill/Concentration. Focused PARTIAL native acceptance, not blanket
API/input proof. U12 presentation-only letter sizing/outer gutters in TASKS; no repeat
metadata scan requested. Previous pending labels below describe the earlier delivery.

## Gate — locally accepted; native metadata correction/layout pending

[Contract/report](../../TASKS.md#u11--decorated-item-link-metadata-fix-and-compact-gear-spacing),
[requirements](../../PLAN.md), [thread](../questions/Q05.md).
User reports Khaz Algar gear lacks red border and Tool letter after updated scan, while
quality/E badges work. Supplied normal tooltip lines: Item expansion unknown, Tool's own
stat unavailable. No raw link/freshness supplied; do not infer cache-only/native cause.
User requests24px icons/28px rows and matching tighter horizontal/vertical gaps.

## Primary investigation / implementation scope

Primary locally reproduced identical crafted payload succeeding with plain label and
returning nil when label contains quality-atlas markup. ToolStatLink's old `[^|]*` label
pattern rejected markup in both equipped Tool and GetItemInfo returned links, a plausible
cause of both missing fields. This proves a parser defect, not user-client causality.
Fix treats label as opaque ignored text, never query/display/stat identity; still one
anchored wrapper/payload, nested hyperlinks/delimiters rejected and payload guards kept.

Geometry24px icon/26px border/28px cell+row gives4px icon gaps/2px border gaps both axes;
84px static Gear header,1126content/1156outer. Quality10px retains foreground child Frame;
Tool14px central glyph and E9×11 semantics unchanged. No Core/ViewModel/storage/schema/
optional metadata semantics/API changes. Three Lua files plus U11 execution fields;
primary docs separate. Non-Git working tree, no staged/unstaged comparison.

## Implementer evidence — not independent validation

Implementer `ses_e16bbde68ffezOoN1yp8UsmAx4` COMPLETE, writer stopped. Two unchanged-source
regressions rejected before correction; corrected focused2/2/full512 completedPASS,
all19U07 workloads5/10/2/2,744K6/565K7, diagnostics23/23 and both Python checks PASS.
38 geometry-only inline-original adaptations+6 additions reconstruct entire pre-U11
SelfTests0187ece1… exactly,39 unassigned input fingerprint unchanged. Whole production
reverse proofs reported. All checks here are implementer-attributed, not independent.

Frozen targets supplied for review:
```text
b716d27c799aa30e12c281ff09b35aa6395705273d306cc229ee06bd56742023 CraftArmy/Collectors.lua
37bb1bb8915f591efd4499cfb7295dfd10fefdde97eaa5c3e38790842b70a3a7 CraftArmy/Dashboard.lua
868a32aac2d877e5ef0239883b2feda7c4c0fac1d3b94ab1f3493515e9c235c2 CraftArmy/SelfTests.lua
```

Native24px appearance/input and metadata correction NOT VERIFIED; quality/E accepted only
as user reported for U10, not blanket native PASS. Historical fullnativeINCOMPLETE87/149/
allrankUNVERIFIED unchanged. Platform N/A addon parser/layout. Independent review then
primary exact-target validation/preservation needed before local acceptance/update advice.

## Independent scoped-static review — PASS

Verifier `ses_e16ad1a81ffeozW8nOfANmmGou` returned COMPLETE, no actionable findings.
Read relevant production paths, six additions and38 inline-original geometry adaptations
with contract/requirements/evidence. Parser preserves anchored/bounded single-link guards
and exact non-enchant payload, label ignored and never queried. Geometry/foreground/
fallback-font/recycle/reset/guard paths match contract. Tests meaningfully cover decorated
label defect, equipped/returned variation, exact queries, collector/Core/Storage/model
flow and actual gap/interaction/reentry behavior. Adaptations are geometry-only, original
surrounding assertions retained;512 cap/all19U07 grouping preserved.

Read/grep only, no execution/hash/preimage/reversal/inventory/freeze/native proof. Supplied
hashes not independently recomputed. All execution/preservation above remains implementer
evidence. No static blocker, platform N/A. Native causality/correction/24px appearance
pending; not established by this PASS. Primary exact-target validation remains next gate.

## Primary exact-target validation / local acceptance — PASS

After persisting independent static PASS, PRIMARY executed all four approved commands.
Full dashboard capture/assertions verify exit0/exact512 completedPASS/512passed0failed,
all19U07 completion annotations5/10/2/2,744K6/565K7 and no FAIL/terminal INCOMPLETE.
Diagnostic23/23 and both Python structural checks PASS; eight diagnostic baseline hashes
unchanged. These are PRIMARY executable results, not independent or native proof.

All3 exact reviewed hashes above match. Restore38 inline-original adaptations/remove6
additions reconstructs entire pre-U11 SelfTests0187ece1… exactly, including prior U10
original/adapted bytes. Adaptation concat79a332a1… matches.39 frozen scoped inventory/
content fingerprinte8898e28… unchanged; Core/ViewModel/Storage/Data/TOCs/runners/tools/
config/allmedia preserved. All9 original/copy images match manifest bytes/hashes, exact
9/10 inventory and asset READMEcd0392…; checked image files regular/non-symlink. No
further correction required. Scoped primary proofs, not independent/full-tree/stat.

Locally accepted. User already reported scan on updated U10 and unknown/unavailable
metadata: do not dismiss as cache-only. Corrected known label parser defect plausibly
explains both fields, but no raw user link/freshness or native fixed result supplied.
Update whole addon with WoW closed/preserve SavedVariables/restart, one ordinary affected
profession scan then inspect red Khaz Algar border, Tool intrinsic letter vs enchant and
24px/28px/equal gap layout. No reset/account-wide rescan/fullselftest needed. Native
causality/correction/appearance/input remains pending. Historical fullnativeINCOMPLETE87/149/
allrankUNVERIFIED unchanged. No Git/install/publication performed.
