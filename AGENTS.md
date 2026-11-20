# CraftArmy — agent instructions

## Project state and sources of truth

This is a World of Warcraft Retail addon project with diagnostics and the dashboard
implemented. Full local Lua/stress fixtures pass; S01 storage refresh and older-snapshot
retention are user-confirmed. R01 redraw visibility during scans and profession-window
open/close is user-confirmed; broader native/required-field acceptance remains partial.
Skill bar and Skill marker/filter refinements have focused user acceptance.
U09 Concentration observed bar/no! and tooltip-only estimates have focused user acceptance;
measured offline estimate accuracy remains unverified. U10 combined gear icon redesign
has focused native quality/E acceptance. After U11, user confirms red borders and
Resourcefulness R;24px icons/28px rows/internal gaps accepted. U12 natural-size letter/
6px outer gutters locally accepted2026-11-18; user confirms M visible and gaps look great.
Focused M/outer-spacing acceptance complete; no repeat check/metadata scan needed.
Exact native font cause and broader native acceptance are not inferred.
U13 locally accepted2026-11-18: Moxie centered/no!/green>600; observed+cyan estimated Concentration
with approximate total; scrollbar replaces paging buttons; filtered current-GUID rows
first with name dot. Estimates may drive display only, never sort/attention/saved values.
User confirms current-first/dot, Moxie center/no!/green>600, distinguishable Concentration
segments, sorting/filtering and row count. U14 locally accepted2026-11-18: uniform
historical Moxie green, duplicate-paint suppression/frame-coalesced drag, opaque thumb.
User confirms Moxie color/full scrollbar bounds/good performance; focused U14 native
acceptance complete. Exact cause/measured latency not inferred. User confirms C4/window
and C6/Cancel function as expected. U15 locally accepted2026-11-18: native-only normal gear hovers,
addon detail on Shift, no routine Observed/Attention/hint or long estimate caveat normal.
Diagnostic provenance/assumptions and meaningful unavailable/stale safety cues retained.
User confirms cleaner tooltips/Shift diagnostics as before; focused C5/U15 accepted.
No repeat accepted checks/scan/full suite needed. User explicitly signed off the dashboard
2026-11-18 and approves PUBLIC GitHub Arbixal/craftarmy plus local main/initial commit/push.
Repository created/origin configured; Git status/log/remote SHA record delivery. Bootstrap
approval is scoped to initial snapshot, not future commits/push/releases/deployments.
Latest2026-11-18 priority: extend dashboard tracking to Herbalism, Mining, Skinning,
Cooking and Fishing BEFORE guides; existing crafting sign-off remains accepted and
Inscription remains first guide. Nov19 user confirms `—` for evidenced N/A/no field-specific
attention/filter match and has multiple Skinning characters. P01 foundation/read-only
capture contract in TASKS explicitly approved Nov19; one synchronous implementer, followed
by independent review/primary acceptance. Pending
gathering Moxie/Knowledge/stat activation is a later evidence gate, not guessed defaults.
Initial implementer external-snapshot read denied; user explicitly authorized primary
copy into ignored artifacts/p01-comparison/ and implementer/reviewer read-only access
there. Use local copy only; no writer retry of denied external path or artifact edits.
P01 primary amendment permits Core's metadataSlots additions26/27/28 ONLY, plus exact
E01/E02/E03/E04 registry expectation updates as individually listed in the contract;
all other Core rules/stat/currency maps frozen.
Copied README preimages have `.md.preimage` names to avoid treating backups as project
docs; read artifacts/p01-comparison/preimage-paths.json for10immutable preimage locations.
P01 locally ACCEPTED Nov19: writer complete; independent full-diff STATIC PASS/no findings;
PRIMARY16groups/219173additive,512legacy/all19/K6K7/23/Python/whitespace, preservation and
11target post-review freeze PASS. Reviewer shell denied; independent execution/comparison
remains NOT RUN, never reattributed from primary evidence. No writer active. Native
new-profession/candidate activation gates remain pending; hashes/review live in TASKS.
User has now supplied all3complete/stable/untruncated gathering reports on70961,36paths;
Moxie/Knowledge currency evidence and Finesse/Perception keys recorded in
docs/dashboard/gathering-native-evidence.md. User confirms all reported values match native
UI; error-free/responsive captures/broad row acceptance not separately stated. No repeated
dumps/IDs/old retests. Separate estimate flicker reported; read-only local widget probe
reproduces retained-build hide/restore, not30second repaint at callback boundary. Native
trigger unknown; docs/dashboard/concentration-refresh-investigation.md records findings.
User directs Nov19: complete other-profession dashboard coverage first, then follow up
with Concentration flicker fix. Defer further flicker work; focus remaining profession
coverage/native gates, not guides. No additional gathering evidence dumps requested.
P02 locally ACCEPTED Nov19: exact3gathering Moxie/Knowledge maps and F/P Tool stats active;
five-profession skill/cap/slot safeguards preserved independently of Moxie mode. No writer.
Independent full-scope STATIC PASS/no findings; executable verification INCOMPLETE after
shell denial (NOT RUN, no retry/bypass or PRIMARY reattribution). PRIMARY new12/13223,
P01=16/220754,512/all19/K6K7/23/Python plus exact reversals/protected/post-review freeze PASS.
Comparison/evidence local artifacts/p02-comparison/; review at
docs/dashboard/expansion-p02-review.md. Next is focused new active dashboard normal use,
not repeated dumps/ID/value interviews, old retests or native suite timing chase. Broader
native five-profession acceptance pending. No flicker/install/Git/release/guide work.
Latest Nov19 user confirms gathering dashboard values match, reports grey Knowledge bars
(missing gathering palette entries); confirms Cooking/Fishing have no Moxie. Screenshot
older Skinning Tool shows ITEM_MOD_DEFTNESS_SHORT110 matching tooltip, no enchant/ID0;
raw key evidenced, neutral result/build not shown. No newer tool/repeat capture needed.
User now definitely confirms gathering permanent Tool enchants; Cooking/Fishing support
only tentative, no enchanted Tools available. No need/authorization to buy/apply enchants
or change gear for evidence. Next proposed scope: secondary Moxie N/A, gathering colours,
D recognition and gathering missing-enchant warnings. Secondary warnings stay pending.
P03 locally ACCEPTED Nov19: all4refinements active (secondary Moxie N/A,9gathering colours,
D recognition, gathering missing-enchant warnings); secondary warnings stay pending.
Independent full STATIC PASS/no findings; executable verification INCOMPLETE after shell
denial/NOT RUN, no bypass/reattribution. PRIMARY15/31244,P02=12/13223,P01=16/220990,
512/all19/K6K7/23/Python and exact10target/reversal/protected/post-review freeze PASS.
Review docs/dashboard/expansion-p03-review.md; evidence artifacts/p03-comparison/.
User now confirms all4P03behaviors (secondary dash/gathering colours/D/gathering-only
warnings): focused native acceptance complete, no repeat checks. Secondary permanent
enchant applicability still provisional, not inferred ineligible from disabled warnings.
User adds current-player dot flickers off during refresh. PRIMARY read-only full-saved-root
widget probe reproduces BOTH dot/estimate hidden while retained build pending, restored
on publication;30second repaint alone leaves both visible. Native trigger/frequency unknown.
User now explicitly approves combined R02 implementation/local tests. Contract at
docs/dashboard/refresh-r02-contract.md, TASKS READY queue, primary snapshot under ignored
artifacts/r02-comparison/ before one synchronous implementer/review/primary acceptance.
Private last-good visible-paint cache, guarded frozen ordinary pending-build continuity;
same active-generation/GUID dot, estimate also unchanged successful concentration provenance.
Source/generation/options/GUID/failure/supersession cleanup stays; no global guard removal,
prediction sort/attention/save, model math or timer frequency change. No source edits at approval.
R02 writer paused PARTIAL after511/512legacy failure: oldU13Hide/IsShown fault cases used
safe unchanged Refresh (now intentionally no-Hide). Primary inspected and authorizes ONLY
second recoverable SelfTests dispatch block forcing changed character filter for those
two unsafe-demotion subcases, preserving all8boundaries/both modes/expectations. No runtime
guard weakening. TASKS/contract contain amendment; one writer resumes3–5 incl all missing
new fault/reentry/negative/read-bound coverage/full final suites. Two initial new groups
passed preliminarily, not final validation. No primary source/test edits at pause.
LATEST R02 locally ACCEPTED Nov19 supersedes paused/READY labels above: F1/F2/F3 corrected,
independent full STATIC PASS/no remaining findings; independent execution/comparison remains
INCOMPLETE/NOT RUN after shell denial, no retry/bypass/PRIMARY reattribution. PRIMARY serial
58/902323,P03=15/31244,P02=12/13223,P01=16/220990,512/all19/K6K7/23/Python/whitespace and
exact preservation/freeze PASS. Accepted5hashes/full107335byte actualdiff and chronology in
TASKS; review docs/dashboard/refresh-r02-review.md. No active writer/check job. Next ONLY
focused ordinary-refresh native dot/cyan-estimate continuity; no repeat profession checks,
new dumps/fullsuite timing chase/install/Git/guides. Native trigger/frequency/latency and
estimate accuracy unknown; fullnative INCOMPLETE87/149/allrankUNVERIFIED unchanged.
LATEST user still reports BOTH indicators disappear; R02 native continuity NOT accepted.
Runningclient code identity unknown, not presumedoutdated. User requests version marker;
V01 READY contract TASKS: private Dashboard literal0.2.0-mvp+r02.1 in existing Shift status
tooltip, unchangednormalheader/layout/TOC/continuity. One writer/tests/review/primaryacceptance.
No installer/copy/Git or moreflickerchange authority. Next establish displayedloadedbuild.
V01 locally ACCEPTED Nov20: exactloadedDashboard marker0.2.0-mvp+r02.1 available byholding
Shift thenhoveringstatuslinedirectlybelowtitle. Header/TOC/layout/continuityunchanged.
Independent STATICPASS/no findings,executionNOTRUNafterdenial;PRIMARY61/1333822 plusall
existingfullsuites/structural/whitespace/proofsPASS. No WoW copy/install performed. Next
ONLYaskdisplayedidentifier;nativeflickerunresolved,don'tassumeoldcopyorfixedclient.
LATEST Nov20 user CONFIRMSexpectedDashboardbuild butBOTHindicatorsstillblink. No repeat
markerchecks;V01focusednativeidentifieraccepted,R02nativecontinuityNOTaccepted. PRIMARY
read-onlyactualCommands/Collectors/Dashboardprobe reproduces eventduringpendingbuild:
dashboardframebeforequeuedScan clearsboth/cache;Scanfirst keepsdotbutclearsestimate;
newsuccessfultimestampalso clearsoldestimate;publicationrestores. Syntheticorderonly,
nativeevent/order/cadenceunknown.163projectpaths/V01hashesunchanged,UIroot/tokenchecksPASS;
evidence artifacts/r03-investigation/,findingsdocs/dashboard/concentration-refresh-investigation.md.
R03handoffcontinuityPROPOSED,notapprovedruntimequeue. Nextgetuserapproval/completecontract;
no sourcewriter/newflickerfix/install/Git/guides yet. Don'tremoveguardsorcovernewdatawitholdprediction.
LATEST user saysYes toR03 focusedhandoffcorrection. Contractdocs/dashboard/refresh-r03-contract.md,
TASKSREADY5pieces;one synchronouswriter/review/primaryacceptance. Explicitprivatecollector
DashboardHandoffsignal,<=12visibleactivevalidation,guardedreplacementConcentrationfromnew
successfulobservation;genericdriftstillfailsclosed. Zeroadditionalgainmaylegitimatelyblueonly,
neveroldcyanovernewobservation. Build0.2.0-mvp+r03.1;old61runnerONLY2versionliteralupdates,
SelfTestsfrozen. Primarysnapshotartifacts/r03-comparison/.No install/Git/native/guides.
LATEST R03 locally ACCEPTED Nov20,build0.2.0-mvp+r03.1. Explicitcollectorhandoff/scalarcell
replacement;independentfullSTATICPASS/nofindings,execution/comparisonNOTRUNafterdenial.
PRIMARY31/860393,61/1333822,P03=15/31244,P02=12/13223,P01=16/221046,512/all19/K6K7/23/
Python/whitespaceandreviewedfreezePASS. No reattribution/retrybypass. Reviewatdocs/dashboard/refresh-r03-review.md,
6hashes/full64865bytediffTASKS/artifacts/r03-comparison/. No writer/checkjob. NextONLYfocused
normalrefreshdot/coherentConcentrationfeedbackonr03.1;noR02markerrepeat/dumps/oldprofession
checks/install/copy/Git/guides. Zeroadditionalgaincantruthfullyblueonly,nooldcyanovernewdata.
Nativeoutcome/trigger/order/cadence/latencyandaccuracyunverified;fullsuite87/149INCOMPLETEunchanged.
LATEST user confirmsr03.1butBOTHdot/estimate disappearuntilrefreshcomplete. R03nativeFOLLOWUP
FAILED/notaccepted;don'trepeatversioncheckorblamecyan-onlyrenewal. Actualnativefallback
unknown. Primaryreadonlyinspectiononly,nosource/testchanges/newwriterorfurtherfixauthority.
NextONEexistingShifthoverstatustooltipcaptureWHILEmissing,pending/previous-view+Rawstatus,
notnewdump/forcedscan/professionretests. Don'tassumestaleCollectorsorwholeinstallmatchfrom
Dashboardmarker. Getactivepath evidencebeforeanotherspeculativepatch.
LATEST screenshotreceived:ordinaryBuildingincrementally,RawstatusOpenyourownprofessionto
refresh,r03.1,45rows. No repeatedcapture/versionquestion. PRIMARYcontrol/experiment finds
concreteFontStringGetTextempty-nilAPI mismatch:icon-onlygearblanklabelreadnilcurrently
treatedasfailureclearscontinuity/cache;existingmockreturns"". ONLYprivatewidgetsemantic
changedreproducesbothhiddenuntilpublicationandsamependingstatus. Fullsavedroot/tokens/
166projectpaths/sixR03hashesunchanged. Evidenceartifacts/r04-investigation/andlatestinvestigation.
Currentwikioptionalnil+historicalempty-nildocsread;notnativecalltrace.R04narrowfixPROPOSED,
awaituserapproval/completecontract,nowriter/sourceedits.Don'trelaxthrows/invalidtypes/ownership.
LATEST user APPROVESR04narrowfix/tests. TASKSR04READYcompletecontract:successfulnilGetText
normalizetoblankafterownscheck,allerrors/otherinvalidtypesfailclosed. Dashboardonlytinyfix/
buildr04.1;oldrefreshmockONEGetTextmethod+TWOversionliterals;newfontstringrunner;READMEcurrent/
prefix. Collectors/R03/Core/Storage/ViewModel/SelfTestsfrozen. Primarypacketartifacts/r04-comparison/,
one synchronouswriter/review/primaryacceptance.No install/Git/native/guides or morediagnosticasks.
LATEST R04 locally ACCEPTED Nov20,build0.2.0-mvp+r04.1. SuccessfulnilGetTextnormalizedafter
ownscheck;errors/invalidtypesstillfailclosed. Native-compatiblemock+9newgroups. Independent
fullSTATICPASS/nofindings,exec/comparisonNOTRUNafterdenial;PRIMARYall11serialchecks9/1338363,
31/860393,61/1333822,P03P02P01/512/all19/K6K7/23/Python/whitespace/freezePASS. 5accepted
hashes/full25069bytediff/reviewTASKSR04/artifacts/r04-comparison/. No newpolicy/install/Git/
guides/writer/job. NativeoutcomePENDING;priorR02R03failurespreserved. NextONLYordinaryrefresh
feedbackonloadedr04.1,nofurtherscreenshot/versioninterview/dump/forcedscan/reset/gearwork.
LATEST user says“That has fixed it,good job.” R04focusedNATIVEACCEPTANCE completeNov20:
dot/Concentration-estimate refreshcontinuityfixedasreported. No repeatchecks/screenshots/
versioninterviews,furtherwriterorfullsuitechase. HistoricalR02R03failurespreserved;measured
latency/cadence/estimateaccuracy/broadernativeacceptancenotinferred.No Git/install/guides authority.
LATEST Nov20 secondaryToolevidence:userfoundexistingCookingToolwithMulticraftpermanentenchant;
CookingapplicabilityCONFIRMED,missing-enchantwarningsstillpendingimplementation/approval.
Cookingfixedmulti-statmixnotselectablesinglestat,amountsrarity/qualitydependent;exactbasenames
notgiven,don'tderivebaseMfromenchant. CraftedFishingToolsPerception,amountsrarity/quality;
FishingenchantNOTtried/unverified,nopurchases/applications/dumpsneeded. Evidenceatgathering-native-evidence.md,
TASKSproposalonly,nowriter/sourcechanges.NextofferCooking-onlywarningactivation;statUIchanges
needsettledscope.No newGit/install/guides/refreshchecks;R04nativeacceptancecomplete.
LATEST user APPROVESCooking-onlymissing-enchantwarning,Fishingunchanged. TASKSP04READY5pieces:
Dataonlyonepolicyexpression,Fishing2911pending/Cooking2908enabled;Dashboardbuildonlyp04.1,
R04fixbytesfrozen. OldP03THREEexactstatements/P01ONEexactstatementrecoverableP04blocks;
refreshONLYTWOversionliterals,newcookingrunner,READMEcurrent/prefix. Allothercodefrozen.
Primarysnapshotartifacts/p04-comparison/sevenpreimages;one synchronouswriter/review/acceptance.
No statUI/enchantIDs/Fishingguess/purchases/gear/dumps/install/Git/guides/refreshretets.
LATEST P04 locally ACCEPTED Nov20,build0.2.0-mvp+p04.1:Cooking-onlyMissing-enchantwarning/
filterenabled,Fishingpendingunchanged. IndependentfullSTATICPASS/nofindings,exec/comparison
NOTRUNafterdenial;PRIMARYall12serialchecks12/81992+R04/R03/61/P03P02P01/512/all19/K6K7/23/
Python/whitespace/freezePASS. Eightacceptedhashes/full30680bytediff/reviewTASKSP04 and
artifacts/p04-comparison/. StatUIunchanged,R04logicbytefrozenexceptbuildliteral;nativeR04
acceptancecomplete. P04nativefeedbackpendingordinaryuse,nowriter/job/nopurchases/gear/new
dumps/versioninterview/acceptedrefreshchecks/install/Git/guidesauthority.
LATEST Nov20 user CONFIRMSP04Cookingwarning/filter:focusednativeacceptancecomplete,Fishing
pendingunchanged. Newscrollingreport:CraftArmyhaltsNPC/worldanimationunlikeWeeklyKnowledge;
wantprepared-data-onlyrender,notsynchronousstallmovedtoprepaint. PRIMARYreadonly48/96rich
profile finds60Active/41522Check/2672Copyper5wheelpaints;syntheticCPUonly,notnativecauseproof.
StablefixturecachedActivecontrolstill41522Checks;cachealoneinsufficient. Evidence/repro
artifacts/scroll-investigation/,docs/dashboard/scroll-performance-investigation.md;168paths/
savedroots/freshrows/tokensunchanged. U16DESIGNPROPOSED,noruntime/testedits/writer. Next
approvescope/settlepacketprovenance+sourcecertification/guardbounds/clockepochs/testadaptations
thencompleteTASKScontract/snapshot/onewriter/review/acceptance.No guardweakening/newdumps/
repeatacceptedchecks/installcopy/Git/guides;nativeperformancetimings/outcomeunverified.
LATEST Nov20 user APPROVESU16refactor BUTexistingworkmustbecommittedandpushedtooriginFIRST.
ExplicitcheckpointGitapprovalONLY:existingreviewedsource/tests/docs+investigation/planning,
localmain→publicArbixal/craftarmy origin/main normalfastforward;ignoredartifacts/secrets/runtime
excluded. No force/tags/releases/install/futurerefactorcommitpush. PRIMARYcheckpointqueue
TASKSU16;verifylocalHEAD==liveoriginmainbeforeanyU16sourcewriter. Thencompletesettledcontract/
snapshot/onewriter/review/acceptance. HistoricalnoGitlabelsremainexceptthisscopedcheckpoint.
No newer gear/spending/oldchecks/install/Git/guides; broad native sign-off not inferred.
No reset/training/gear change or new code outside an approved task; no new Git authority.
Preserve snapshots; do not infer N/A from missing data. No new Git
mutation authorization. Guide work has not started. Unreported hover
dismissal/scroll procedures and broader API coverage are not inferred.
New optional metadata fills on ordinary own scans; existing snapshots must stay intact.
Guides are not built. U13 supersedes tooltip-only estimates; predictions never drive
sorts/attention or saved data.
Read `PLAN.md` and `TASKS.md` first; load detailed design/history only as needed.

Icon pack is packaged in `CraftArmy/Media/Icons/` with a manifest README; root `media/`
originals are user-supplied and must be preserved. U08 binds the main64px TGA to a22px
dashboard title icon; locally accepted and appearance user-confirmed. Unreported input
checks are not inferred. No TOC branding.

- `PLAN.md` records confirmed requirements and decisions.
- `docs/design.md` contains proposals; it does not silently authorize implementation.
- `TASKS.md` is the implementation contract and durable recovery point.
- User work must not be overwritten or discarded. The diagnostic structural check
  is `python3 tools/check_diagnostics.py`; pure Lua fixtures use `lua5.1 tests/run.lua`
  only if already available, or `/cad selftest` in WoW. Structural success is not Lua
  execution or client evidence; never invent a successful validation result.
- Confirmed validation policy (2026-11-07): retain full local correctness/stress suites,
  use focused user-run WoW normal-use/API/snapshot checks. The full in-client suite
  remains INCOMPLETE after timing stops; completing it under the cutoff is not a blanket
  prerequisite for further native work. Never raise limits, reduce coverage or relabel
  INCOMPLETE as PASS. Follow the current PLAN/TASKS/README gates, not superseded retest
  instructions in historical delivery logs.

## Development workflow — planning vs implementation

The primary thread owns user interaction, design choices, task preparation, review,
and coordination of live testing. Use the `living-plan` skill for design interviews,
scaffolding, adoption, rebalancing, and eviction of completed task queues. A design
interview runs in the primary thread, not a subagent.

Once design is settled and the user authorizes implementation, prepare a complete
active task and use the project `implementer` agent. Use the `agent-handoff` skill
whenever crossing an agent boundary. Do not launch an implementer while the task is
BLOCKED or has no executable pieces.

Default to one synchronous implementation writer, executing a serial numbered queue.
Parallel agents are a separate explicit opt-in. The implementer must not launch
children, choose architecture, or expand scope. A blocked piece only blocks its
dependents; independent pieces may proceed. Update `TASKS.md` piece statuses and
run state at every stop so work is recoverable after interruption.

Before delegation, specify file ownership, scope, dependencies, validation, and
required report. Do not rewrite assigned files or the active contract while the
implementer works. The primary persists read-only review findings and acceptance
evidence before advancing. Implementation, verification, acceptance, and release are
distinct gates; passing tests never grants publication or Git mutation approval.

## Planning-document maintenance

Keep `PLAN.md` lean. Invoke `living-plan` when it becomes heavy (default threshold
15,000 words) or completed work dominates `TASKS.md`. Preserve cooled detail under
`docs/` and leave links. Question and parked-thread histories are append-only.
Propose and confirm file relocations and thread promotions; do not treat a proposal
as settled simply because it is written down.

PLAN is the hot requirements layer. Preserved D05/D07 histories and older sessions
are indexed in `docs/decisions/README.md` and `docs/sessions/README.md`; questions and
parked work stay under `docs/questions/` and `docs/parking-lot/`. Load history only as
needed. The approved 2026-11-17 all-nine-session archive is a one-time exception;
future maintenance still keeps the latest three sessions inline. Use `living-plan`
and a confirmed manifest for further relocations; old gates never supersede current ones.

Completed task work follows **check → collapse → evict**, using `living-plan` and a
confirmed manifest with no active writer. Keep current status, active queue/run state,
open issues and deferred work in TASKS; lift live conditions out before archiving
partially accepted history. Preserve history/link meaning and verify retention. Archive
index: `docs/tasks/README.md`; operational lessons: `docs/references/validation-and-recovery.md`.
Historical ACTIVE/BLOCKED/next labels never authorize execution or supersede current gates.

## Addon design guardrails

Follow the confirmed product decisions in PLAN.md: distinguish observed values from
unknown/stale data, verify APIs against the target Retail client, preserve known
snapshots on transient API failures, and keep identifiers separate from localized
labels. Do not promise live offline-alt inspection or automatic purchasing/crafting.
The dashboard and guide requirements are recorded in D01–D03; unresolved technical
choices belong in their question threads, not ad hoc implementation defaults.
