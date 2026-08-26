# Ticket Delivery Pipeline Specification

## Source Request

This specification is based on the approved design discussion for a unified ticket queue and delivery workflow. No source ticket was created because this documentation-only change was explicitly scoped to produce the specification and implementation plan first.

## Objective

Turn the existing set of independent delivery skills into a durable operating loop where:

1. `/morning-brief` identifies at most one highest-leverage next outcome and either reuses an equivalent active ticket or creates one explicit ticket in `tickets/`.
2. `tickets/` becomes the persistent work queue.
3. `/deliver-ticket` can consume a specific ticket, resolve a ticket by number/basename, create a ticket from freeform task text, or select the latest eligible unfinished ticket when called with no argument.
4. `/deliver-ticket` generates or reuses the ticket's technical spec and TDD implementation plan, then presents one consolidated execution contract for human review.
5. No runtime/application implementation begins until the user explicitly approves that execution contract.
6. Approved implementation follows `RED → GREEN → REFACTOR → VERIFY` one vertical slice at a time.
7. Final verification, review, project-document synchronization, and ticket delivery evidence are required before a ticket becomes `delivered`.
8. Existing `/ticket`, `/spec`, `/plan`, and `/implement-plan` commands remain independently usable for manual/expert control.

The design must preserve the repository's current safety model: current repository evidence outranks stale planning documents, material scope/risk changes stop the workflow, unrelated work is preserved, and merge/deploy/external actions are never implied by implementation completion.

## Existing System

### Existing skills

The repository currently installs seven skills:

- `/setup-workspace`
- `/morning-brief`
- `/reset-workspace`
- `/ticket`
- `/spec`
- `/plan`
- `/implement-plan`

There is no orchestration command that takes a ticket through the full delivery lifecycle.

### Existing morning brief behaviour

`skills/morning-brief/SKILL.md` is intentionally read-only. It may recommend at most one next ticket outcome, but it explicitly forbids creating tickets. The current handoff ends with a suggested `/ticket <outcome>` command.

### Existing ticket behaviour

`/ticket` creates one evidence-backed assignment under `tickets/` and defines what should change and why. The current ticket format has no durable lifecycle metadata, no delivery state, and no structured delivery evidence.

### Existing spec and plan behaviour

`/spec` turns an approved ticket into a technical contract under `spec/`.

`/plan` turns an approved spec into ordered `RED → GREEN → REFACTOR → VERIFY` slices under `plans/`.

### Existing implementation behaviour

`/implement-plan` already:

- requires an approved plan;
- revalidates repository state before editing;
- executes one TDD slice at a time;
- runs relevant final verification;
- performs final diff review using `Must fix`, `Should fix`, and `Okay to ship`;
- synchronizes `context/current-state.md`, `context/architecture.md`, `context/decisions.md`, `roadmap.md`, and `context/lessons.md` when verified truth changes.

It does not currently synchronize the source ticket's lifecycle or delivery evidence.

### Existing setup and installers

`/setup-workspace` currently teaches:

`/morning-brief` → recommendation → human selection → `/ticket` → `/spec` → `/plan` → `/implement-plan`.

Both `scripts/install.ps1` and `scripts/install.sh` enumerate the existing seven skills explicitly. A new `/deliver-ticket` skill therefore requires installer updates.

## Required Operating Model

The target loop is:

```text
repository + roadmap + GitHub + customer evidence
                    ↓
              /morning-brief
                    ↓
          reuse or create one ticket
                    ↓
               tickets/
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
       synchronize project truth/docs
                    ↓
         ticket status: delivered
```

`tickets/` is the durable queue between the operator/prioritization loop and the implementation loop.

## Ticket Lifecycle Contract

### Required frontmatter

New tickets must use YAML frontmatter containing at least:

```yaml
---
ticket_schema: 1
status: ready
source: manual
created: YYYY-MM-DD
---
```

Allowed `source` values for this version are:

- `manual` — created directly through `/ticket`;
- `morning-brief` — created automatically by `/morning-brief`;
- `deliver-ticket` — created from freeform text passed to `/deliver-ticket`.

Optional lifecycle fields are added only when applicable:

```yaml
spec: spec/NNN-slug.md
plan: plans/NNN-slug.md
delivered_at: YYYY-MM-DD
superseded_by: tickets/NNN-other-ticket.md
blocked_reason: <concise reason>
```

Do not store test logs, secrets, large command output, or volatile environment details in frontmatter.

### Status values

The canonical statuses are:

- `ready` — scoped, unblocked, and waiting for delivery;
- `awaiting-approval` — spec and plan are ready and the consolidated execution contract is waiting for explicit approval;
- `in-progress` — runtime/application implementation has started under an approved execution contract;
- `verifying` — planned implementation slices are complete and final verification/review is in progress;
- `delivered` — acceptance criteria are satisfied by observed evidence, required verification is complete or explicitly reported as unavailable where allowed, no in-scope `Must fix` remains, and project truth has been synchronized;
- `blocked` — a material unresolved decision or external prerequisite prevents safe progress;
- `failed-verification` — implementation was attempted but required verification failed and the failure was not resolved in-scope;
- `superseded` — the ticket is intentionally replaced by another ticket.

`delivered` and `superseded` are terminal queue states. A regression discovered later creates a new ticket rather than reopening historical delivery evidence silently.

### Required transitions

Normal path:

```text
ready
  ↓
awaiting-approval
  ↓
in-progress
  ↓
verifying
  ↓
delivered
```

Exceptional transitions:

- any pre-delivery state → `blocked` when a material unresolved decision prevents safe continuation;
- `in-progress` or `verifying` → `failed-verification` when required checks fail and cannot be resolved within approved scope;
- any non-terminal state → `superseded` only when the replacement ticket is explicitly identified;
- `blocked` → `ready` only after the blocking decision/prerequisite is resolved and current repository evidence is revalidated;
- `failed-verification` → `awaiting-approval` or `in-progress` only after revalidation determines whether the existing approval remains valid.

A material scope, architecture, dependency, migration, authentication, payment, permission, security, deployment, or destructive change invalidates prior execution approval and requires a revised execution contract.

## Ticket Acceptance and Delivery Evidence

### Acceptance criteria

New ticket templates should express acceptance criteria as observable checkbox items when practical:

```md
## Acceptance Criteria

- [ ] Observable condition one.
- [ ] Observable condition two.
```

A checkbox may be marked complete only when supported by observed implementation/verification evidence.

### Delivery evidence section

When a ticket reaches successful completion, `/implement-plan` or `/deliver-ticket` must append or update a concise `## Delivery Evidence` section containing:

- implementation result;
- acceptance-criteria result;
- relevant automated checks with `Passed`, `Failed`, or `Not run`;
- browser/manual verification when relevant;
- final review result and remaining `Should fix` items;
- spec path;
- plan path;
- human-review items still outside automation;
- explicit statement of actions not performed when relevant, such as merge or deployment.

The ticket must not be marked `delivered` merely because a spec, plan, code diff, commit, or successful subset of tests exists.

## Repository Truth and Delivery State

Ticket metadata is the durable queue index, but current repository behaviour and verification evidence remain authoritative when delivery state is evaluated.

Rules:

1. A no-argument queue scan may use ticket metadata to avoid deeply re-verifying every historical delivered ticket on every invocation.
2. A selected ticket must be reconciled against current repository/context evidence before implementation begins.
3. An explicitly referenced `delivered` ticket must not be implemented again automatically. The command should inspect enough current evidence to determine whether the delivered behaviour still appears present.
4. If a delivered outcome has regressed, create a new regression ticket referencing the prior ticket rather than silently changing the historical ticket back to `ready`.
5. If ticket metadata conflicts materially with repository evidence and the correct state is not clear, stop and surface the conflict instead of guessing.
6. Planning artifacts are never implementation evidence.

## Legacy Ticket Compatibility

Existing tickets may have no frontmatter or status.

For a selected legacy ticket:

1. Read the full ticket and current project evidence.
2. If completion is clearly evidenced, report that it appears already delivered and normalize metadata only when the invocation/project permission model authorizes that documentation write.
3. If it is clearly incomplete and otherwise valid, normalize it to `ticket_schema: 1`, `status: ready`, and `source: manual` before continuing.
4. If state is ambiguous, stop with one material question.

No-argument selection should consider numerically named legacy tickets, but must classify the selected legacy ticket before any implementation.

## `/morning-brief` Queue Handoff

### New responsibility

`/morning-brief` changes from strictly read-only recommendation mode to a narrowly scoped operator-write mode.

It may create **at most one** new ticket under `tickets/` per invocation, and only when all of the following are true:

- current evidence supports one clear highest-leverage outcome;
- the outcome can be scoped safely without a material unresolved product decision;
- no equivalent active ticket already covers the same outcome;
- the ticket can satisfy the normal `/ticket` quality and scope contract.

The morning brief must continue to avoid runtime code edits, specs, plans, dependencies, GitHub writes, commits, pushes, merges, deployments, data mutation, and routine activation.

### Duplicate prevention

Before creating a ticket, `/morning-brief` must inspect active tickets and relevant specs/plans.

An existing ticket is considered potentially equivalent when its title, user outcome, desired behaviour, acceptance criteria, and scope materially overlap the proposed outcome.

If an equivalent ticket has one of these states:

- `ready`;
- `awaiting-approval`;
- `in-progress`;
- `verifying`;
- `blocked`;
- `failed-verification`;

then `/morning-brief` must reuse/reference that ticket instead of creating a duplicate.

If the equivalent historical ticket is `delivered` but current evidence shows a regression or newly distinct problem, create a new ticket and reference the historical ticket in repository evidence/context.

If the equivalent ticket is `superseded`, follow the replacement ticket rather than reviving it.

### No useful ticket

If no evidence-backed next outcome exists, or a material decision must be made first, `/morning-brief` creates no ticket and reports the evidence/decision needed.

### Morning brief output

The brief should end with one of:

- `Created ticket: tickets/NNN-slug.md` with `status: ready`;
- `Existing ticket: tickets/NNN-slug.md` with its current status;
- `No ticket created` and the supported reason.

When a ticket is ready, the suggested next command should be `/deliver-ticket <ticket-path>`.

## `/deliver-ticket` Command

### Responsibility

`/deliver-ticket` is an orchestration skill. It coordinates the existing ticket, spec, plan, and implementation contracts; it does not redefine them independently.

The lower-level commands remain valid and independently usable.

### Supported invocation forms

#### No argument

```text
/deliver-ticket
```

Select the highest-numbered eligible unfinished ticket from `tickets/`.

#### Explicit path

```text
/deliver-ticket tickets/004-saved-products.md
```

Use that exact ticket.

#### Ticket number or unique basename

```text
/deliver-ticket 004
/deliver-ticket 004-saved-products
```

Resolve a unique matching ticket.

#### Freeform task

```text
/deliver-ticket Add saved products to the catalogue
```

If the argument does not resolve to an existing ticket, treat it as a new task. Apply the normal `/ticket` scoping/evidence rules, prevent duplicates, create the next numbered ticket with `source: deliver-ticket`, then continue through the same pipeline.

Ambiguous references must stop for one concrete question instead of guessing.

## No-Argument Ticket Selection

### Ordering

Only tickets using the repository's numeric naming convention are automatically ordered. Sort by numeric prefix descending, not filesystem modification time.

Example:

```text
tickets/005-search-regression.md
tickets/004-saved-products.md
tickets/003-mobile-nav.md
```

`005` is evaluated before `004`.

### Eligibility

Skip terminal tickets:

- `delivered`;
- `superseded`.

Skip `blocked` tickets during automatic selection, but report the newest blocked ticket when it materially explains why higher-priority work is unavailable.

The first descending ticket in one of these states is actionable:

- `ready`;
- `awaiting-approval`;
- `in-progress`;
- `verifying`;
- `failed-verification`;
- legacy/no-status, subject to classification.

Interrupted `in-progress` or `verifying` work must never auto-resume blindly. Revalidate repository/Git state and the prior execution contract; require renewed approval when validity cannot be proven or when higher-priority project rules require it.

Non-numeric legacy filenames are supported only by explicit reference unless the repository already defines another deterministic ordering convention.

## Delivery Orchestration Phases

### Phase 1 — Resolve and inspect

1. Resolve/create the source ticket.
2. Read the complete ticket.
3. Read `AGENTS.md`, `CLAUDE.md`, `roadmap.md`, `review.md`, relevant `context/*.md`, and repository evidence.
4. Inspect Git/worktree state and preserve unrelated changes.
5. Reconcile ticket state with current repository truth.
6. Stop if a material unresolved product decision blocks safe specification.

### Phase 2 — Generate or revalidate the spec

Use the existing `/spec` contract.

- Default path: `spec/<same-basename>.md`.
- If no spec exists, generate it.
- If one exists, re-read current code and determine whether it remains valid.
- If stale but safely repairable within the ticket scope, update it.
- If repository evidence requires material ticket/scope changes, stop and block rather than silently redesigning the ticket.

Record the spec path in ticket metadata.

### Phase 3 — Generate or revalidate the plan

Use the existing `/plan` contract.

- Default path: `plans/<same-basename>.md`.
- Build the smallest ordered vertical slices.
- Every normally testable slice uses `RED → GREEN → REFACTOR → VERIFY`.
- If planning reveals a material flaw in the spec, return to the spec phase rather than hiding the change inside the plan.

Record the plan path in ticket metadata.

### Phase 4 — Consolidated execution contract

After the spec and plan are valid, present one concise execution contract containing:

- ticket and goal;
- included scope;
- explicit exclusions;
- technical approach;
- expected affected areas/files;
- TDD slice summary;
- dependencies/migrations/auth/security or other material checkpoints;
- verification plan;
- risks and assumptions;
- human-review items;
- actions explicitly not included, such as push, merge, or deployment unless separately authorized.

Set the ticket to `awaiting-approval` when permitted by the active project's documentation-write rules.

Then stop and require the explicit approval phrase required by project instructions; when no stronger phrase is defined, use `Approve plan`.

The existence of a ticket, spec, or plan does not imply execution approval.

### Phase 5 — Revalidate approval before implementation

After approval and immediately before runtime edits:

1. Re-read Git/worktree state.
2. Re-read relevant current files/tests.
3. Confirm ticket, spec, plan, and approved execution contract still match reality.
4. Stop for renewed approval when a material difference appears.
5. Preserve unrelated/uncommitted work according to project rules.

Only after this revalidation may status move to `in-progress`.

### Phase 6 — Implement one slice at a time

Delegate execution semantics to `/implement-plan`.

For each slice:

```text
RED → GREEN → REFACTOR → VERIFY
```

Required behaviour:

- run RED and confirm failure for the intended reason;
- implement only enough to reach GREEN;
- refactor without adding unrequested behaviour;
- run targeted verification before starting the next slice;
- never batch the entire feature implementation before verifying slices.

### Phase 7 — Final verification

After all planned slices are green, move the ticket to `verifying` and run the relevant checks actually available in the project, including as applicable:

- targeted tests;
- broader regression tests;
- lint;
- type-check;
- production build;
- desktop/mobile browser flow;
- loading, empty, error, and success states;
- console/network errors;
- accessibility checks.

Every check must be reported as `Passed`, `Failed`, or `Not run` with a reason. Unavailable checks are never reported as passed.

### Phase 8 — Review

Review the final diff against:

- ticket;
- spec;
- plan;
- `roadmap.md`;
- `review.md`.

Classify findings as:

- `Must fix`;
- `Should fix`;
- `Okay to ship`.

Resolve in-scope `Must fix` findings before delivery. A fix that materially changes approved scope stops for renewed approval.

### Phase 9 — Synchronize truth and deliver

After successful verification/review:

1. Update applicable project truth documents using observed evidence only.
2. Update acceptance-criteria checkboxes only where proven.
3. Write concise delivery evidence to the source ticket.
4. Set `delivered_at`.
5. Set ticket status to `delivered` only after the previous steps succeed.

Project truth documents remain limited to those whose truth actually changed, including:

- `context/current-state.md`;
- `context/architecture.md` when architecture actually changed;
- `context/decisions.md` for explicitly confirmed decisions;
- `roadmap.md` when completion evidence is satisfied;
- `context/lessons.md` for repository-specific observed lessons.

If required verification remains failed, use `failed-verification` rather than `delivered`.

## Approval and Permission Boundaries

### Planning/documentation phase

Invoking `/deliver-ticket` explicitly requests the planning workflow and may create or update the ticket/spec/plan artifacts needed to reach the execution contract when the active project's higher-priority rules permit those documentation writes.

If project instructions require an additional approval before documentation writes, those rules win.

### Runtime implementation phase

Runtime/application code changes require the consolidated execution approval. Material changes invalidate that approval.

### Outside the default delivery contract

The following are not implied by `/deliver-ticket` completion and require separate authorization when applicable:

- dependency additions/removals not already approved;
- migrations not already approved;
- authentication/payment/security policy changes not already approved;
- commits when project rules do not include them automatically;
- pushes;
- pull requests;
- merges;
- deployments;
- destructive data/application operations;
- live billing/customer-data decisions.

## `/implement-plan` Integration

`/implement-plan` must be extended so successful plan execution also synchronizes the source ticket.

Required ticket synchronization:

- read the source ticket before execution;
- preserve its request/scope/history;
- update status according to execution phase when invoked through `/deliver-ticket` or when the project's workflow explicitly uses lifecycle metadata;
- mark acceptance criteria only from actual evidence;
- write/update `## Delivery Evidence`;
- set `delivered` only after final verification/review/document sync succeeds;
- use `failed-verification` when required checks fail and remain unresolved;
- never mark delivered because code was merely edited or committed.

Standalone `/implement-plan` remains supported; when it receives a plan tied to a lifecycle-aware ticket, it should keep that ticket aligned with verified reality.

## `/setup-workspace` Integration

The generated operating workspace must teach the new queue and delivery model.

Update setup guidance so generated projects understand:

```text
/morning-brief
      ↓
create/reuse one ready ticket
      ↓
/deliver-ticket
      ↓
spec → plan → approval → implementation → verification → review → delivery evidence
```

The generated `tickets/README.md` must document lifecycle metadata, queue semantics, and the difference between historical delivered tickets and active queue tickets.

The generated operating guide must state that `/morning-brief` has one narrow write permission: create at most one evidence-backed ticket, with duplicate prevention. It must still prohibit runtime code and external writes.

The existing manual flow remains documented as an advanced/manual alternative:

```text
/ticket → /spec → /plan → /implement-plan
```

## Installer Integration

Add `deliver-ticket` to both installer skill lists:

- `scripts/install.ps1`;
- `scripts/install.sh`.

Installer completion text should make `/deliver-ticket` the default full-delivery command while preserving the lower-level command sequence as manual control.

No new external dependency is required.

## README Integration

The repository README must be updated during implementation to:

- include `/deliver-ticket` in the installed skill list;
- show the new morning-brief → queue → delivery loop;
- document all `/deliver-ticket` invocation forms;
- explain ticket lifecycle/status and latest-ticket selection;
- explain duplicate prevention in `/morning-brief`;
- retain the manual `/ticket` → `/spec` → `/plan` → `/implement-plan` example;
- clearly state that delivered does not mean merged or deployed.

## Expected New Skill Structure

```text
skills/
  deliver-ticket/
    SKILL.md
    references/
      workflow.md
      execution-review.md
      completion-report.md
```

`SKILL.md` owns command resolution, phase ordering, permission gates, and delegation to existing skill contracts.

`references/workflow.md` owns the detailed state machine, ticket-selection algorithm, resume/revalidation rules, and lifecycle transitions.

`references/execution-review.md` defines the consolidated approval contract format.

`references/completion-report.md` defines the final delivery report and ticket delivery-evidence requirements.

Avoid copying the entire `/ticket`, `/spec`, `/plan`, and `/implement-plan` instructions into the new skill. Reference and respect their responsibilities so there remains one conceptual contract per stage.

## Affected Areas

Expected implementation areas, based on the current repository:

- `skills/morning-brief/SKILL.md`;
- `skills/ticket/SKILL.md`;
- `skills/ticket/references/ticket-format.md`;
- `skills/implement-plan/SKILL.md`;
- new `skills/deliver-ticket/**`;
- `skills/setup-workspace/SKILL.md`;
- `skills/setup-workspace/assets/templates/operating-guide.md`;
- `skills/setup-workspace/assets/templates/tickets-readme.md`;
- potentially related setup templates/references where the old delivery sequence is embedded;
- `scripts/install.ps1`;
- `scripts/install.sh`;
- `README.md`.

Implementation must search the repository for old statements such as "morning brief must not create tickets" and the old delivery sequence so contradictory documentation is not left behind.

## Backward Compatibility

The change must preserve these behaviours:

- `/ticket <request>` still creates one ticket without generating a spec/plan or implementing code;
- `/spec <ticket>` still creates/revalidates only the technical specification;
- `/plan <spec>` still creates/revalidates only the TDD implementation plan;
- `/implement-plan <plan>` still performs approved implementation and verification;
- `/morning-brief` still creates no more than one next outcome and never implements it;
- existing project workspaces remain usable after skill upgrade;
- legacy tickets remain readable and can be normalized when selected;
- `/reset-workspace` ownership and safety semantics remain unchanged except for any documentation wording required to recognize the new skill.

## Error and Stop Conditions

`/deliver-ticket` must stop rather than guess when:

- an explicit ticket reference matches multiple tickets;
- a selected ticket contains a material unresolved product decision;
- the spec reveals a material ticket/scope conflict;
- the plan reveals a material spec conflict;
- Git/worktree state violates project safety rules;
- implementation approval is absent or invalidated;
- an unexpected dependency/migration/auth/payment/permission/security/destructive change appears;
- required verification fails outside the approved in-scope fix boundary;
- ticket metadata conflicts with repository evidence and the correct state cannot be established.

The stop response must name the blocked stage, evidence, and one concrete decision needed when applicable.

## Testing Requirements

Because this repository primarily contains Markdown skill contracts and installer scripts rather than application runtime code, implementation verification should focus on behavioural contract checks and installer smoke tests without introducing unnecessary dependencies.

Required checks:

1. Verify ticket format contains lifecycle frontmatter, canonical statuses, and delivery evidence rules.
2. Verify `/morning-brief` no longer contains contradictory absolute "no ticket creation" rules and instead enforces the one-ticket/duplicate-prevention boundary.
3. Verify `/deliver-ticket` exists and documents all four input modes.
4. Verify `/deliver-ticket` contains one consolidated execution approval boundary before runtime edits.
5. Verify `/implement-plan` synchronizes source-ticket delivery state/evidence.
6. Verify setup templates teach the new operating loop without removing manual commands.
7. Verify both installers include `deliver-ticket` and can copy the complete skill into an isolated temporary project.
8. Search for stale documentation that still describes `/morning-brief` as recommendation-only or omits the new default delivery flow.
9. Verify no existing `/reset-workspace` safety boundary is weakened.

Where practical, each implementation slice should begin with a failing repository-text or installer assertion that proves the required contract is absent before the change, then rerun it after the change.

## Verification Requirements

Before implementation is considered complete:

- inspect the final diff for only approved workflow/documentation/installer changes;
- run platform-appropriate installer smoke tests in temporary directories for Windows and shell paths when available;
- verify installed `.claude/skills/deliver-ticket/SKILL.md` and its references exist;
- verify existing skills are still installed;
- verify forced upgrade behaviour still replaces installed skill directories as designed;
- verify README examples and generated setup templates agree on queue/status semantics;
- verify no command is documented as merged/deployed merely because delivery completed;
- classify final findings as `Must fix`, `Should fix`, or `Okay to ship`.

## Technical Risks

### Conflicting sources of truth

Adding ticket status can create false confidence if status is treated as stronger than repository evidence. Mitigation: status is the durable queue index, while observed repository/verification evidence remains authoritative when evaluating completion.

### Duplicate morning tickets

A scheduled or frequently run morning brief could create repeated versions of the same task. Mitigation: mandatory active-ticket equivalence check before creation.

### Accidental redelivery

A no-argument command could repeatedly select completed work. Mitigation: terminal status filtering plus repository reconciliation on selected/explicit tickets.

### Interrupted delivery sessions

A ticket may remain `in-progress` or `verifying` after interruption. Mitigation: never blindly resume; revalidate repository/Git/approval state first.

### Instruction duplication

Copying full stage rules into `/deliver-ticket` could drift from `/ticket`, `/spec`, `/plan`, or `/implement-plan`. Mitigation: orchestrator delegates to existing contracts and owns only sequencing/resolution/state transitions.

### Legacy ticket ambiguity

Older tickets have no lifecycle metadata. Mitigation: normalize selected legacy tickets only after evidence-based classification; stop when ambiguous.

### Cross-platform installer drift

The PowerShell and shell installers can diverge. Mitigation: update and smoke-test both within the same ticket.

## Open Technical Questions

None currently block implementation. The specification intentionally keeps lifecycle state in ticket Markdown rather than introducing a database, service, external issue tracker, or new dependency.