# Ticket Delivery Pipeline Implementation Plan

## Sources

- Spec: `spec/001-ticket-delivery-pipeline.md`
- Source request: approved design discussion for a unified `/morning-brief` ticket queue and `/deliver-ticket` orchestration workflow.
- No source ticket was created because this documentation-only planning step was explicitly scoped to produce the spec and plan first.

## Goal

Implement a durable software-delivery queue where `/morning-brief` creates or reuses at most one evidence-backed ticket, `/deliver-ticket` consumes the latest eligible ticket or a user-supplied task/reference, and delivery proceeds through specification, TDD planning, explicit execution approval, implementation, verification, review, project-truth synchronization, and final ticket status/evidence.

The finished repository should make this the default operator loop:

```text
/morning-brief
      ↓
create/reuse ticket in tickets/
      ↓
status: ready
      ↓
/deliver-ticket
      ↓
spec
      ↓
plan
      ↓
consolidated execution contract
      ↓
Approve plan
      ↓
RED → GREEN → REFACTOR → VERIFY
      ↓
final verification
      ↓
review
      ↓
project truth + ticket evidence
      ↓
status: delivered
```

The existing manual flow remains valid:

```text
/ticket → /spec → /plan → /implement-plan
```

## Preconditions

Before implementation:

1. Read `spec/001-ticket-delivery-pipeline.md` completely.
2. Re-read current `main`/target-branch versions of:
   - `README.md`;
   - `skills/morning-brief/SKILL.md`;
   - `skills/ticket/SKILL.md`;
   - `skills/ticket/references/ticket-format.md`;
   - `skills/spec/SKILL.md`;
   - `skills/plan/SKILL.md`;
   - `skills/implement-plan/SKILL.md`;
   - `skills/setup-workspace/SKILL.md`;
   - relevant setup templates/references;
   - `scripts/install.ps1`;
   - `scripts/install.sh`.
3. Search the repository for embedded descriptions of the old workflow, especially:
   - `morning-brief` being strictly read-only;
   - `Do not create the ticket automatically`;
   - `/ticket -> /spec -> /plan -> /implement-plan`;
   - installed skill counts/lists.
4. Inspect Git/worktree status and preserve unrelated work.
5. Confirm no material repository change has invalidated the approved spec.
6. Do not add dependencies or a new runtime service. Ticket Markdown remains the durable queue state.

If implementation reveals a need for a new database, external queue, issue-tracker dependency, migration, authentication change, deployment behaviour, or other architecture outside the spec, stop and return to specification/approval rather than absorbing it.

## Implementation Strategy

Implement the workflow in small contract-oriented vertical slices. The repository is primarily Markdown skill instructions plus installer scripts, so TDD should use the strongest available test-first evidence for each slice:

- repository text assertions for skill contracts;
- exact file-existence assertions;
- installer smoke tests in isolated temporary directories;
- searches for contradictory stale instructions;
- source/destination comparisons after installation.

Where a conventional unit-test harness does not exist, RED still requires running an assertion/check that fails because the required contract is absent, then rerunning the same check after the change.

Do not introduce a test framework solely for this change unless repository evidence during implementation demonstrates one already exists and is appropriate.

---

## Slice 1 — Establish Ticket Lifecycle and Delivery Evidence

### Outcome

Every newly created ticket has a durable lifecycle state and can later record evidence-backed delivery completion without changing the ticket's responsibility as the definition of what should change and why.

### Affected Areas

Expected:

- `skills/ticket/SKILL.md`
- `skills/ticket/references/ticket-format.md`
- `skills/setup-workspace/assets/templates/tickets-readme.md`

Potentially another existing ticket-related setup template/reference if repository search shows duplicated ticket-format instructions.

### RED

Run repository assertions proving the current contract is missing the required lifecycle behaviour. At minimum prove that:

- `ticket-format.md` has no `ticket_schema` field;
- no canonical `status: ready` frontmatter is defined;
- canonical statuses such as `delivered` and `failed-verification` are absent;
- `## Delivery Evidence` is not part of the ticket contract;
- ticket acceptance criteria are not required to be evidence-markable.

The RED result must fail for those intended missing-contract reasons, not because paths are wrong or files are unreadable.

### GREEN

Update the ticket contract to implement the smallest complete lifecycle schema from the spec:

- required frontmatter:
  - `ticket_schema: 1`;
  - `status`;
  - `source`;
  - `created`;
- optional lifecycle fields only when relevant:
  - `spec`;
  - `plan`;
  - `delivered_at`;
  - `superseded_by`;
  - `blocked_reason`;
- canonical status definitions:
  - `ready`;
  - `awaiting-approval`;
  - `in-progress`;
  - `verifying`;
  - `delivered`;
  - `blocked`;
  - `failed-verification`;
  - `superseded`;
- allowed source values:
  - `manual`;
  - `morning-brief`;
  - `deliver-ticket`;
- acceptance criteria expressed as checkboxes when practical;
- `## Delivery Evidence` rules;
- explicit rule that `delivered` requires observed verification/review evidence and is not equivalent to committed, merged, deployed, or released.

Keep technical solution design out of the ticket format.

Update the generated `tickets/README.md` template to explain active queue states versus historical terminal tickets.

### REFACTOR

Remove duplicate lifecycle wording where one concise canonical rule can be referenced from another ticket instruction. Keep `SKILL.md` focused on behaviour and the format reference focused on artifact shape.

Do not move technical-spec responsibilities into the ticket skill.

### VERIFY

Rerun the RED assertions and confirm they now pass.

Also verify:

- existing required ticket sections remain present;
- `ticket` still says it must not generate a spec or implement code;
- no status definition implies merge/deploy;
- no secrets/log blobs are encouraged in frontmatter.

---

## Slice 2 — Turn `/morning-brief` Into a Safe Ticket-Queue Producer

### Outcome

`/morning-brief` still performs evidence-based orientation and prioritization, but its one allowed repository write becomes creating at most one real `/ticket`-quality artifact when no equivalent active ticket exists.

### Affected Areas

Expected:

- `skills/morning-brief/SKILL.md`

Potentially generated operating-guide text is handled in a later setup slice to keep this slice focused on the skill behaviour itself.

### RED

Run assertions proving the current morning-brief contract contradicts the target behaviour. Confirm the file currently contains equivalent statements to:

- read-only operation;
- `Do not edit files, create tickets`;
- recommended-ticket handoff via `/ticket` rather than ticket creation;
- `Do not create the ticket automatically`.

These checks should fail against the target contract before editing.

### GREEN

Update `/morning-brief` to:

1. retain all current evidence-reconciliation responsibilities;
2. continue recommending no more than one highest-leverage outcome;
3. inspect active `tickets/`, relevant `spec/`, and `plans/` before ticket creation;
4. evaluate potential equivalence using title/outcome, desired behaviour, acceptance criteria, and scope;
5. reuse/reference an equivalent active ticket rather than create a duplicate;
6. follow `superseded_by` when the equivalent ticket is superseded;
7. create a new regression ticket when a historical delivered outcome has demonstrably regressed rather than reopening the historical ticket;
8. create no ticket when the proposed outcome has a material unresolved decision or insufficient evidence;
9. create at most one new ticket with:
   - the next valid numeric prefix;
   - the normal `/ticket` artifact contract;
   - `status: ready`;
   - `source: morning-brief`;
10. end with exactly one of:
    - `Created ticket: ...`;
    - `Existing ticket: ...`;
    - `No ticket created: ...`;
11. point a ready ticket to `/deliver-ticket <ticket-path>`.

Keep all existing prohibitions on:

- runtime code edits;
- spec creation;
- plan creation;
- dependency changes;
- GitHub writes;
- commits/pushes/merges/deployments;
- customer-data invention;
- routine activation.

The only new write permission is the single evidence-backed ticket.

### REFACTOR

Remove stale recommendation-only wording and replace repeated negative rules with one precise permissions section.

Preserve application-route versus AI-command disambiguation behaviour added in the current morning-brief skill.

### VERIFY

Rerun RED assertions and verify the contradictory absolute no-ticket rules are gone.

Verify by inspection/search that:

- the file says **at most one** ticket;
- duplicate prevention is mandatory;
- unresolved material decisions cause no ticket creation;
- `/morning-brief` still cannot implement code or create specs/plans;
- the output references `/deliver-ticket` for a ready ticket;
- customer evidence rules remain intact.

---

## Slice 3 — Add `/deliver-ticket` Input Resolution and Queue Selection

### Outcome

The new skill can deterministically resolve the work item before any spec, plan, or runtime implementation begins.

### Affected Areas

Create:

- `skills/deliver-ticket/SKILL.md`
- `skills/deliver-ticket/references/workflow.md`
- `skills/deliver-ticket/references/execution-review.md`
- `skills/deliver-ticket/references/completion-report.md`

### RED

Run assertions proving:

- `skills/deliver-ticket/SKILL.md` does not exist;
- no installed-skill source currently defines `/deliver-ticket`;
- there is no documented algorithm for no-argument latest-ticket selection.

RED should fail because the new skill is absent.

### GREEN

Create the new skill with input resolution in this exact precedence:

1. existing explicit ticket path;
2. unique ticket number or basename;
3. no argument → automatic queue selection;
4. otherwise freeform task → create/reuse a ticket using `/ticket` rules.

Implement/document automatic queue selection:

- sort numeric ticket prefixes descending;
- skip `delivered` and `superseded`;
- skip `blocked` for automatic selection while surfacing it when materially relevant;
- first actionable state wins among:
  - `ready`;
  - `awaiting-approval`;
  - `in-progress`;
  - `verifying`;
  - `failed-verification`;
  - selected legacy/no-status after classification;
- non-numeric legacy names require explicit reference unless a repository-specific deterministic convention exists;
- ambiguous explicit references stop for one question;
- freeform input performs duplicate detection before creating a new ticket;
- freeform-created tickets use `source: deliver-ticket`.

Add legacy-ticket classification and explicit-delivered-ticket safeguards from the spec.

Do not yet implement detailed spec/plan/approval sequencing beyond enough structure to hand off to the next slice.

### REFACTOR

Keep argument resolution and queue-selection details in `references/workflow.md`; keep `SKILL.md` concise enough to explain responsibilities, required context, phase order, and stop conditions.

Avoid copying the full ticket format into `/deliver-ticket`; direct the orchestrator to the `/ticket` contract.

### VERIFY

Run static contract assertions for all supported forms:

```text
/deliver-ticket
/deliver-ticket tickets/004-saved-products.md
/deliver-ticket 004
/deliver-ticket 004-saved-products
/deliver-ticket Add saved products to the catalogue
```

Verify the workflow reference clearly defines terminal, blocked, actionable, interrupted, and legacy cases.

Verify there is no rule that blindly chooses the newest filesystem timestamp or blindly reruns `delivered` tickets.

---

## Slice 4 — Add Spec/Plan Orchestration and the Single Approval Gate

### Outcome

A resolved ticket is carried through repository-grounded spec and TDD plan generation/revalidation, then the workflow stops at one consolidated human execution review before runtime edits.

### Affected Areas

Expected updates inside:

- `skills/deliver-ticket/SKILL.md`
- `skills/deliver-ticket/references/workflow.md`
- `skills/deliver-ticket/references/execution-review.md`

No changes to runtime application code.

### RED

Run assertions against the newly created skill proving it does not yet completely require all of the following:

- existing `/spec` contract delegation;
- default same-basename `spec/` path;
- existing `/plan` contract delegation;
- default same-basename `plans/` path;
- stale spec/plan revalidation;
- one consolidated execution contract;
- explicit `Approve plan` fallback gate;
- no runtime edit before that gate;
- approval invalidation on material scope/risk change.

At least one assertion must fail for the intended missing behaviour before implementation.

### GREEN

Implement the orchestration phases:

1. resolve and inspect ticket/context/repository;
2. generate or revalidate the matching spec using `/spec` responsibilities;
3. record `spec` metadata in the ticket;
4. generate or revalidate the matching plan using `/plan` responsibilities;
5. record `plan` metadata in the ticket;
6. stop when spec/plan reveals a material ticket/scope conflict;
7. generate one execution contract with:
   - goal;
   - scope;
   - exclusions;
   - technical approach;
   - affected areas;
   - TDD slice summary;
   - material checkpoints;
   - verification;
   - risks/assumptions;
   - human-review items;
   - explicitly excluded external actions;
8. transition ticket to `awaiting-approval` when project rules permit the documentation write;
9. require the project's explicit approval phrase, falling back to `Approve plan`;
10. revalidate Git/repository/spec/plan immediately after approval and before runtime edits;
11. invalidate approval and stop if a material difference appears;
12. only then transition to `in-progress`.

Document that invoking `/deliver-ticket` requests its planning/documentation artifacts, but higher-priority project gates still win.

### REFACTOR

Keep the execution-contract presentation format in `execution-review.md` and avoid duplicating the detailed spec/plan format files.

Ensure `/deliver-ticket` remains orchestration, not a replacement implementation of `/spec` or `/plan`.

### VERIFY

Verify the skill has exactly one runtime execution approval boundary.

Search for any wording that could imply:

- ticket existence = approval;
- spec existence = approval;
- plan existence = approval;
- `awaiting-approval` = approved;
- planning may edit runtime code.

All such implications must be absent.

---

## Slice 5 — Synchronize Source Ticket During `/implement-plan`

### Outcome

Implementation completion updates the source ticket from observed evidence, making ticket status a reliable durable queue record without weakening repository truth rules.

### Affected Areas

Expected:

- `skills/implement-plan/SKILL.md`
- potentially `skills/implement-plan/references/tdd-cycle.md` only if lifecycle integration requires a narrowly relevant clarification; avoid unrelated edits.

### RED

Run assertions proving the current `/implement-plan` completion synchronization mentions project context/roadmap/lessons but not:

- source ticket status;
- acceptance-criteria evidence;
- `## Delivery Evidence`;
- `delivered_at`;
- `failed-verification`.

### GREEN

Extend `/implement-plan` so it:

1. reads the source ticket as it already does;
2. preserves original request/problem/scope/history;
3. when lifecycle metadata is present or the command is invoked through `/deliver-ticket`:
   - maintain `in-progress`/`verifying` phase state as appropriate;
   - update acceptance-criteria checkboxes only when proven;
   - write concise delivery evidence;
   - record spec and plan paths;
   - record final checks as `Passed`, `Failed`, or `Not run`;
   - record remaining `Should fix`/human-review items;
   - set `delivered_at` and `status: delivered` only after final verification, in-scope Must-fix resolution, review, and project-document synchronization succeed;
   - set `failed-verification` when required verification remains failed;
4. never use a code edit, commit, push, PR, or plan artifact alone as delivery evidence;
5. preserve standalone `/implement-plan` support for manually invoked plans.

### REFACTOR

Integrate ticket synchronization into the existing "Keep project memory aligned"/completion flow without duplicating the entire `/deliver-ticket` state machine.

Keep one authoritative definition of review categories and TDD cycle.

### VERIFY

Assert that successful completion now includes source-ticket synchronization and that failure paths cannot result in `delivered`.

Verify `delivered` remains distinct from:

- committed;
- pushed;
- merged;
- deployed;
- released.

---

## Slice 6 — Teach `/setup-workspace` the New Queue and Delivery Loop

### Outcome

Newly initialized workspaces explain the same workflow that installed skills actually implement.

### Affected Areas

Expected:

- `skills/setup-workspace/SKILL.md`
- `skills/setup-workspace/assets/templates/operating-guide.md`
- `skills/setup-workspace/assets/templates/tickets-readme.md`

Inspect and update only if repository search finds old workflow wording in:

- `skills/setup-workspace/references/workspace-schema.md`
- other templates that describe delivery responsibilities.

### RED

Run assertions proving setup currently states:

- `/morning-brief` recommends work but does not create tickets;
- `/morning-brief` is read-only;
- default delivery is `/ticket → /spec → /plan → /implement-plan`;
- generated operating-guide text has no `/deliver-ticket` queue model.

### GREEN

Update setup behaviour/templates to establish:

```text
/morning-brief
      ↓
create/reuse at most one ready ticket
      ↓
/deliver-ticket
      ↓
spec → plan → approval → implementation → verification → review → delivered
```

Required documentation distinctions:

- morning brief has one narrow repository write permission: one evidence-backed ticket;
- duplicate tickets are prohibited;
- material unresolved decisions create no ticket;
- `/deliver-ticket` is the default end-to-end delivery path;
- manual `/ticket → /spec → /plan → /implement-plan` remains supported;
- `tickets/` is the work queue;
- delivered tickets are historical evidence, not automatic candidates for redelivery;
- delivered does not imply merge/deploy.

Keep setup itself documentation-only; do not make `/setup-workspace` run `/morning-brief` or activate a delivery automatically.

### REFACTOR

Remove contradictory old operator-flow text instead of layering new text beside it.

Keep workspace ownership/reset rules untouched unless a wording reference must mention the new skill.

### VERIFY

Search setup skill/templates for old contradiction phrases.

Verify generated operating guidance and `tickets/README.md` agree with the canonical ticket statuses and `/deliver-ticket` behaviour.

Verify workspace-schema responsibilities remain accurate and reset ownership boundaries are unchanged.

---

## Slice 7 — Install `/deliver-ticket` on Windows and macOS/Linux

### Outcome

Both supported installers copy the new skill and all references into `.claude/skills/deliver-ticket` while preserving existing upgrade semantics.

### Affected Areas

- `scripts/install.ps1`
- `scripts/install.sh`

### RED

Run platform-appropriate assertions showing `deliver-ticket` is absent from both current installer skill lists.

When safe in a temporary directory, run an installer smoke test before the change and confirm `.claude/skills/deliver-ticket/SKILL.md` is absent. This is the intended RED failure.

Do not modify a real consumer project to create the RED condition.

### GREEN

Update both installers to include `deliver-ticket` in the enumerated skill set.

Update completion guidance so the default operating path points to:

- `/morning-brief` for queue intake/orientation;
- `/deliver-ticket` for end-to-end delivery;
- manual low-level commands as an explicit alternative.

Do not change force-upgrade semantics beyond what is required to install the new directory.

### REFACTOR

Keep Windows and shell skill lists semantically identical. Do not add new dependencies or platform-specific workflow differences.

### VERIFY

Using isolated temporary project directories where the platform is available:

1. run the installer;
2. confirm all existing skill directories still exist;
3. confirm `.claude/skills/deliver-ticket/SKILL.md` exists;
4. confirm all three reference files exist;
5. run force upgrade (`-Force` or `--force`) where safe;
6. confirm the new skill remains correctly installed;
7. confirm no application/runtime files are created by the installer.

Report unavailable platform smoke tests as `Not run`, never passed.

---

## Slice 8 — Update Repository README and User-Facing Workflow Documentation

### Outcome

The public repository documentation accurately explains the new default queue/delivery workflow and all command entry modes without removing expert/manual control.

### Affected Areas

Expected:

- `README.md`

Potentially another root documentation file only if repository search shows an existing canonical workflow description there. Do not create unrelated docs.

### RED

Run assertions proving the README currently:

- lists seven skills rather than including `/deliver-ticket`;
- describes morning brief as recommendation-only;
- shows manual `/ticket → /spec → /plan → /implement-plan` as the primary delivery example;
- does not document no-argument latest-ticket behaviour;
- does not document ticket lifecycle statuses.

### GREEN

Update README to include:

- `/deliver-ticket` in the installed skill list;
- new primary loop diagram;
- `tickets/` as durable queue;
- morning-brief ticket creation/reuse rules;
- duplicate prevention;
- lifecycle summary;
- `/deliver-ticket` invocation examples:
  - no argument;
  - explicit ticket path;
  - number/basename;
  - freeform task;
- highest-numbered eligible unfinished ticket semantics;
- approval before runtime implementation;
- TDD/verification/review/doc-sync completion flow;
- manual lower-level command sequence as an advanced/manual option;
- explicit distinction between delivered, merged, deployed, and released.

### REFACTOR

Keep the README concise by linking conceptual sections rather than repeating full skill contracts.

Remove stale recommendation-only examples that would conflict with the new queue model.

### VERIFY

Search README for all supported entry forms and lifecycle terms.

Verify it does not imply:

- `/morning-brief` implements tickets;
- `/deliver-ticket` bypasses approval;
- delivered means merged or deployed.

---

## Slice 9 — End-to-End Contract, Contradiction, and Safety Verification

### Outcome

All changed skills, setup templates, installers, and README describe one coherent system with no stale contradictory workflow and no weakened safety boundaries.

### Affected Areas

No new feature scope. Fix only issues discovered in the files already touched by Slices 1–8 unless a directly duplicated contradiction is found elsewhere.

### RED

Before final cleanup, run a repository-wide contract scan designed to fail if any stale contradiction remains. Search for patterns/concepts such as:

- morning brief is completely read-only;
- morning brief cannot create tickets;
- "Do not create the ticket automatically";
- recommendation-only handoff to `/ticket` as the sole/default path;
- installer skill lists that omit `deliver-ticket`;
- documentation saying the delivery workflow ends at `/implement-plan` without ticket delivery status;
- language equating delivered with merged/deployed.

Any stale contradictory hit is a RED failure for this integration slice.

### GREEN

Resolve only confirmed contradictions relevant to the approved workflow.

Do not rewrite unrelated historical/examples content unless it would actively misrepresent the installed behaviour.

Ensure all lifecycle/status terms and paths use the canonical spellings from the spec.

### REFACTOR

Review duplicated workflow diagrams and wording for unnecessary drift. Prefer one concise canonical explanation per file based on that file's responsibility.

Do not introduce shared infrastructure or abstractions merely to reduce Markdown duplication.

### VERIFY

Run the complete verification matrix below.

---

## Final Verification

### Repository contract checks

Verify by exact file inspection and repository-wide search:

- `skills/deliver-ticket/SKILL.md` exists;
- `skills/deliver-ticket/references/workflow.md` exists;
- `skills/deliver-ticket/references/execution-review.md` exists;
- `skills/deliver-ticket/references/completion-report.md` exists;
- ticket lifecycle schema/statuses are canonical;
- morning brief can create at most one ticket and prevents duplicates;
- morning brief creates no spec/plan/runtime implementation;
- deliver-ticket supports no-arg/path/number-or-basename/freeform inputs;
- no-arg ordering uses numeric prefix descending;
- terminal delivered/superseded tickets are skipped;
- interrupted work requires revalidation;
- spec and plan are generated/revalidated before execution approval;
- runtime implementation requires explicit approval;
- material changes invalidate approval;
- implement-plan updates source-ticket evidence/status;
- final delivery requires verification + review + project truth sync;
- delivered is distinct from merged/deployed/released;
- manual lower-level skills remain documented and usable.

### Installer checks

For each available platform:

- run installer into a new temporary project directory;
- confirm all expected skill directories;
- confirm deliver-ticket reference files;
- run force-upgrade path;
- confirm installed files match source content where practical;
- confirm no unrelated project files are changed.

Status each platform check as `Passed`, `Failed`, or `Not run`.

### Setup-workspace consistency

Inspect:

- `skills/setup-workspace/SKILL.md`;
- `assets/templates/operating-guide.md`;
- `assets/templates/tickets-readme.md`;
- any workflow-related setup references touched by implementation.

Confirm setup creates documentation that matches the installed skills.

### Existing safety regression checks

Re-read `/reset-workspace` and relevant setup ownership rules after the diff. Confirm no implementation change expanded reset deletion ownership, modified application/runtime ownership rules, or made `/deliver-ticket`/tickets reset-owned incorrectly beyond existing operating-workspace semantics.

### Diff review

Review the complete diff against:

- `spec/001-ticket-delivery-pipeline.md`;
- this plan;
- repository README conventions;
- existing skill responsibility boundaries.

Classify findings:

- `Must fix` — contradictory workflow, broken installer, missing approval gate, unsafe status transition, duplicate-ticket behaviour, accidental redelivery, or weakened safety boundary;
- `Should fix` — clarity/maintainability issue that does not invalidate the workflow;
- `Okay to ship` — verified, coherent, and within approved scope.

Resolve all in-scope `Must fix` items before describing implementation as complete.

## Risks and Checkpoints

### Checkpoint — Lifecycle schema grows beyond Markdown

If deterministic operation is found to require a database, external service, custom parser dependency, or daemon, stop. That is an architecture change outside this spec.

### Checkpoint — Morning brief duplicate detection is underspecified

Use evidence-based semantic comparison defined in the spec. Do not add embeddings, vector search, external AI services, or a new index.

### Checkpoint — Existing ticket filenames conflict with numeric ordering

Preserve explicit-reference support. Do not silently rename historical tickets. Non-numeric automatic ordering requires a separately established repository convention.

### Checkpoint — Delivery status conflicts with repository evidence

Repository/verification evidence wins when state is evaluated. Stop when correct state is ambiguous; do not silently overwrite history.

### Checkpoint — Interrupted in-progress ticket

Never auto-resume runtime edits solely because status says `in-progress` or `verifying`. Revalidate repository, Git state, plan, and approval validity.

### Checkpoint — Installer differences

If one platform cannot be executed in the implementation environment, do not infer parity from code inspection alone. Mark its smoke test `Not run` and still review the script statically.

### Checkpoint — Scope expansion during review

Fix in-scope `Must fix` issues. Any fix requiring a new dependency, broader architecture, destructive action, external integration, or other material scope change must return for approval.

## Completion Criteria

Implementation is complete only when all of the following are true:

- [ ] Ticket lifecycle/status and delivery-evidence contract is implemented.
- [ ] New tickets receive lifecycle frontmatter.
- [ ] `/morning-brief` creates or reuses at most one evidence-backed ticket.
- [ ] Morning-brief duplicate prevention is explicit.
- [ ] Morning brief creates no ticket when a material decision is unresolved.
- [ ] `/deliver-ticket` skill exists with the four approved input modes.
- [ ] No-argument selection uses highest numeric eligible unfinished ticket semantics.
- [ ] Delivered/superseded tickets are not auto-redelivered.
- [ ] Legacy and interrupted tickets are revalidated safely.
- [ ] Spec generation/revalidation occurs before plan generation/revalidation.
- [ ] One consolidated execution contract is shown before runtime implementation.
- [ ] Runtime edits require explicit approval.
- [ ] Material changes invalidate approval.
- [ ] Implementation follows `RED → GREEN → REFACTOR → VERIFY` for testable slices.
- [ ] Final verification and layered review are required before delivery.
- [ ] `/implement-plan` synchronizes source-ticket acceptance criteria, evidence, and status.
- [ ] Failed required verification cannot produce `status: delivered`.
- [ ] `/setup-workspace` teaches the new queue and delivery workflow.
- [ ] Both installers include `/deliver-ticket`.
- [ ] README documents the new default flow and preserves manual commands.
- [ ] No stale contradictory morning-brief recommendation-only instruction remains in active workflow documentation.
- [ ] Reset-workspace and ownership safety semantics remain intact.
- [ ] Relevant installer smoke checks are run where available and reported truthfully.
- [ ] Final diff contains no unrelated changes.
- [ ] Final review has zero unresolved in-scope `Must fix` findings.

## Human Review Items

Before implementation is considered ready to ship, a human should confirm:

1. The ticket status names and meanings are understandable enough for day-to-day use.
2. `/morning-brief` creating one ticket automatically is the desired level of autonomy.
3. The no-argument rule (highest-numbered eligible unfinished ticket) matches the intended queue behaviour.
4. The single consolidated approval boundary provides enough control before implementation.
5. `delivered` is understood as implemented + verified + reviewed + synchronized, not merged/deployed/released.
6. The manual `/ticket`, `/spec`, `/plan`, `/implement-plan` workflow remains discoverable for cases where step-by-step control is preferred.
