# U10 — combined gear icon redesign

## Gate — locally accepted; native appearance/API/input pending

[Contract](../../TASKS.md#u10--combined-gear-icon-redesign),
[requirements](../../PLAN.md), [decision thread](../questions/Q05.md).
User approves32px rows/28px icons, no Gear sorting, old-expansion red-border override,
narrower dashboard, intrinsic Tool-only letter/quality/enchant badges and no visible
Stat/Enchant columns. One implementer stopped, no active writer during this review.

## Initial implementation / primary scoped findings

Implementer `ses_e17858bcfffe7yI1n4qjFT22r2` reports PARTIAL: #1–#3 delivered; full runner
511PASS/1FAIL (U02 obsolete hidden-column mouse expectation), all19U07 workloads complete,
diagnostic23/23/Python PASS, K6/K7 not reached because failure exits unchanged runner.
40 inline-original adaptations +6 additions reconstruct pre-U10 SelfTests9f27ec…;
37 unassigned inputs unchanged per implementer evidence, not independent proof.

Primary inspected U02 loop; authorizes changing only EnableMouse expectation for hidden
Stat/Enchant to false, keeping all5 scenarios and remaining assertions/original bytes.
No general U02 relaxation or coverage reduction.

Primary also identified parser defects at Collectors.ToolStatLink: numeric-only tail
rejects crafted links with crafterGUID tokens; colon-only IQ prefix rejects no-colon IQ
form documented by source. Direct local Core/Data/Collectors runner reproduced both nil
outputs on synthetic crafted payload and no-colon IQ link. Accept both IQ forms and safe
alphanumeric GUID tail, retaining all other guards and exact non-enchant bytes. Added
regressions required. This also affects GetItemInfo returned-link normalization.

No independent review or local acceptance yet. Correct both issues, finish all4 full
checks/preservation and freeze exact targets for independent review. Native appearance,
expansion return/tool-only attribution and real inputs NOT RUN; historical native full
suite INCOMPLETE87/149/all-rank UNVERIFIED unchanged. Platform N/A addon-only scope.

## Corrected delivery — implementer evidence only

After primary authorization, implementer reports COMPLETE: exact U02 adaptation and
both IQ-prefix/crafterGUID corrections, added rejecting/positive exact-byte format and
collector roundtrip tests. Corrected full512/512 completed, all19U07 workloads5/10/2/2,
744K6/565K7, diagnostics23/23 and both Python checks PASS.41 inline-original adaptations
plus6 additive blocks reconstruct pre-U10 SelfTests9f27ec…;37 frozen inputs unchanged.
No new source scope or Storage/Data/runner/media changes reported. Initial PARTIAL and
its failures remain above, not relabelled PASS. No independent/native proof yet.

Stopped target supplied for review:
```text
65b5b05b82a8f9155b4abb51b5c98f825926753db9d2911babddf866e3146253 CraftArmy/Core.lua
9df7adbd57ceeaac42d94db5fadb5701028d593c1ac7f52ead1a9a927438df73 CraftArmy/Collectors.lua
ec79dae8ea00ee1d2b0603baab6aa45577126ca6d544fab33194bb86311c715c CraftArmy/ViewModel.lua
672bf0ecf82e3940ebda54356131805bcbf41d57f4b25a961513a21a1c505c1c CraftArmy/Dashboard.lua
c775da6773336392cc332de28e58f35100d3b22f8587438cc5a00ddd05848ed3 CraftArmy/SelfTests.lua
```

No Git repository/staged classification. Declared delta:5 assigned Lua files and U10
execution fields; primary documentation separate. Independent scoped-static review next,
then primary exact-target validation/preservation and bounded local acceptance. Native
tool-stat attribution/expansion/badge visibility/input/fit still NOT RUN.

## Independent scoped-static review — CHANGES REQUIRED

Verifier `ses_e1759e390ffe07V2ybq2xRkkm1` returned PARTIAL, no acceptance. Read relevant
production paths, six U10 additions,41 adaptations/U02 authorization and integration.
Medium finding at Dashboard594–600:18px stat backing shares OVERLAY with quality atlas,
created later and overlaps7×6px of12px badge; letter lacks explicit lower priority.
Geometry/visibility tests did not assert relative layers. Metadata/header/retention/guards
otherwise appear contract-consistent. No execution/hash/preimage/diff/freeze/native proof
performed; reported checks remain implementer evidence. Platform N/A.

Primary persists this before correction and settles:12px transparent child quality Frame
at the same TOPLEFT(1,-1), parent border frameLevel+1, atlas/digit in child; central stat
backing ARTWORK, letter OVERLAY on border. This guarantees foreground even where native
FontStrings draw above textures in a shared layer. Preserve geometry, hide/recycle using
guarded writes, add relative-layer regression and rejecting proof, rerun all checks and
review affected target anew. Only Dashboard/SelfTests/U10 execution fields change.

## Layer correction delivered — not yet re-reviewed

Implementer #5 COMPLETE, writer stopped. Quality atlas/digit now share a12px transparent
child at border TOPLEFT(1,-1), explicit border frameLevel+1; central backing ARTWORK,
letter remains parent OVERLAY. Guarded qualityFrame visibility resets/reuses with rows.
New assertions directly rejected pre-fix source, corrected focused tests/full512/all19U07/
744K6/565K7/23/Python PASS per implementer.41 adaptations unchanged, six additive blocks
still reconstruct exact pre-U10 test base; Core/Collectors/ViewModel and37 inputs frozen.
Only WIDGETS/DRAW additive blocks changed. Tests alone do not clear independent finding.

Primary rechecked exact stopped targets for renewed review:
```text
65b5b05b82a8f9155b4abb51b5c98f825926753db9d2911babddf866e3146253 CraftArmy/Core.lua
9df7adbd57ceeaac42d94db5fadb5701028d593c1ac7f52ead1a9a927438df73 CraftArmy/Collectors.lua
ec79dae8ea00ee1d2b0603baab6aa45577126ca6d544fab33194bb86311c715c CraftArmy/ViewModel.lua
43109c0f1001f5c44b35c43726980c44d1f19ba9ceb3030c0e646187940fdfa1 CraftArmy/Dashboard.lua
0187ece124b59de02b5521c41d85416dfb445381dbdb85e1e1eb3ce3b49fabea CraftArmy/SelfTests.lua
```
Native appearance/API/input still NOT RUN. Renewed review then primary full execution/
preservation required before bounded local acceptance.

## Renewed independent scoped-static review — PASS

Verifier `ses_e1759e390ffe07V2ybq2xRkkm1` returned COMPLETE. Prior Medium quality-layer
finding explicitly RESOLVED; Dashboard594–609 child Frame guarantees atlas and fallback
digit foreground over center backing/letter while preserving geometry. Dashboard760–772
uses guarded visibility reset; SelfTests1540–1669 and12329–12388 meaningfully cover
foreground priority/geometry/atlas-digit fallback/recycling/new visibility boundaries.
No remaining actionable static findings in overall U10 scope. Earlier read-only metadata/
retention/header inspection carries forward on unchanged three source hashes.

Independent local read/grep only; supplied target hashes not independently recomputed,
no execution/preimage/freeze/full baseline-diff/native proof performed. Full test and
preservation results above remain implementer-attributed. Platform N/A declared scope.
Primary exact-target full validation and preservation remains the next gate.

## Primary exact-target validation / bounded local acceptance — PASS

After persisting renewed PASS, PRIMARY executed the complete approved dashboard suite
with read-only Python capture/assertions: exit0, exactly512 completed PASS lines and
512passed/0failed summary, all19 U07 workloads in5/10/2/2 annotations,744K6/565K7 checks,
no FAIL/terminal INCOMPLETE. Diagnostic runner23/23 and both Python structural checks
PASS; eight diagnostic baseline hashes unchanged. This is PRIMARY local execution,
not independent execution or native client/API proof.

All5 latest target hashes above exact. Replacing41 adaptation blocks with inline originals
and removing6 additions reconstructs entire pre-U10 SelfTests9f27ec… exactly.41 complete
adaptation blocks retain pre-layer concatenation616c9778….37 unassigned scoped files match
pre-edit inventory/content fingerprint3b29daf4…; all9 image original/copy pairs retain
manifest hashes/bytes/headers, exact9/10 inventories and asset READMEcd0392…. Checked
image files/parents regular/non-symlink. No further code correction required; scoped
primary proof, not independent/full-tree/stat evidence. Original source examples/media
and all frozen Storage/Data/TOC/runner/tool inputs preserved.

U10 locally accepted. Native appearance, actual input and optional expansion/tool-stat
API semantics still NOT RUN. User whole-addon update while WoW closed, preserve
SavedVariables/restart/open /ca, inspect icon/badge/header/narrower-row fit and native
tooltips/selection. Ordinary own-character scans populate optional new metadata; existing
snapshots stay valid and retain prior values. Unknown metadata is not guessed, no forced
account-wide rescan/full-client selftest/reset. Focused native check should include one
Tool whose own stat differs from enchant and known older gear when available. No agent
installation/Git/publication performed. FullnativeINCOMPLETE87/149/all-rankUNVERIFIED unchanged.
