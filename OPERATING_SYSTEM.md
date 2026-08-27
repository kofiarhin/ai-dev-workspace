# AI Dev Workspace Operating System

This guide explains how to operate the AI software-delivery workspace day to day: how to choose commands, where approvals happen, how ticket state changes, and what to do when repository reality drifts from project memory.

## Mental model

The workspace separates software delivery into five concerns:

```text
WORKSPACE HEALTH      What is true right now?
INTAKE                What should we work on next?
DELIVERY              How do we safely implement it?
PUBLICATION           How do we publish delivered work to GitHub?
RECONCILIATION        How do we repair project memory after outside changes?
```

The default path is:

```text
/workspace-health
      ↓
/morning-brief
      ↓
/deliver-ticket
      ↓
Approve plan
      ↓
RED → GREEN → REFACTOR → VERIFY
      ↓
status: delivered
      ↓
/publish-ticket
      ↓
Approve publish
      ↓
commit if needed → push branch → draft PR
      ↓
human review / merge
      ↓
/sync-project          when project truth needs reconciliation
```

`/setup-workspace` initializes the operating layer. `/reset-workspace` removes only manifest-owned operating state after an exact preview and approval.

## Quick start

### 1. Install the skills

Windows:

```powershell
git clone https://github.com/kofiarhin/ai-dev-workspace.git
cd ai-dev-workspace
.\scripts\install.ps1 -ProjectPath "C:\path\to\your-project"
```

macOS/Linux:

```bash
git clone https://github.com/kofiarhin/ai-dev-workspace.git
cd ai-dev-workspace
./scripts/install.sh /path/to/your-project
```

Skills are installed under:

```text
your-project/.claude/skills/
```

### 2. Initialize the project operating layer

Place a PRD or equivalent product specification in the project, then run:

```text
/setup-workspace PRD.md
```

This creates or reconciles the persistent operating layer:

```text
AGENTS.md
CLAUDE.md
roadmap.md
review.md
context/
tickets/
spec/
plans/
customers/
demos/
routines/
.claude/workspace-manifest.json
```

The application code remains separate from the operating layer.

### 3. Start normal work

Run:

```text
/workspace-health
```

If the workspace is healthy enough to continue, run:

```text
/morning-brief
```

Then deliver the selected or queued work with:

```text
/deliver-ticket
```

## Which command should I use?

| Goal | Command | Writes? | Approval boundary |
| --- | --- | --- | --- |
| Initialize/reconcile the AI operating workspace | `/setup-workspace PRD.md` | Operating docs only | Project rules |
| Check whether project memory matches repository reality | `/workspace-health` | No | None |
| Repair stale operating docs/lifecycle metadata | `/sync-project` | Docs/lifecycle only | `Approve sync` unless stricter rules apply |
| Decide the single highest-leverage next outcome | `/morning-brief` | At most one new ticket | Narrow command permission |
| Define what should change and why | `/ticket` | Ticket only | Project rules |
| Define the technical contract | `/spec` | Spec only | Project rules |
| Define implementation order | `/plan` | Plan only | Project rules |
| Execute an approved plan | `/implement-plan` | Runtime + delivery docs | Approved execution contract |
| Run ticket → spec → plan → implementation end to end | `/deliver-ticket` | Docs first, runtime after approval | `Approve plan` unless stricter rules apply |
| Publish already-delivered work to GitHub | `/publish-ticket` | Git/GitHub only after approval | `Approve publish` unless stricter rules apply |
| Remove manifest-owned operating state | `/reset-workspace` | Destructive to owned operating state only | Exact preview + explicit approval |

## Normal daily workflow

### Step 1 — Audit current truth

```text
/workspace-health
```

Use this whenever:

- you have not worked in the repository recently;
- a PR may have been merged outside the AI workflow;
- checks may have completed later;
- ticket status looks suspicious;
- roadmap/current-state documents may be stale;
- you are about to resume interrupted work.

The command is strictly read-only. It reports:

```text
HEALTHY
DEGRADED
BLOCKED
UNKNOWN
```

Typical findings include truth drift, lifecycle drift, verification debt, broken ticket/spec/plan links, stale approvals, and manifest problems.

If the result is `DEGRADED` because documentation or lifecycle state is stale, use `/sync-project` before starting new work when the drift could affect prioritization or execution.

### Step 2 — Reconcile project memory when needed

```text
/sync-project
```

Use it when repository/Git/GitHub reality changed outside the normal delivery flow.

Examples:

- a pull request was merged manually;
- verification finished after the implementation session;
- someone changed code outside `/deliver-ticket`;
- deployment or release state changed elsewhere;
- a legacy ticket needs evidence-backed classification;
- roadmap/current-state docs no longer match reality.

Before writing, `/sync-project` presents the exact files and truth changes it intends to make. When no stronger project rule exists, approve with:

```text
Approve sync
```

It may update only durable operating truth such as current state, architecture when actually changed, confirmed decisions, roadmap, concise lessons, and evidence-backed ticket lifecycle fields.

It does not edit runtime code, rewrite specs/plans, mutate Git/GitHub state, merge, deploy, or release.

### Step 3 — Pick the next outcome

```text
/morning-brief
```

The brief reconciles current evidence and chooses at most one highest-leverage next outcome.

It may:

- reference an equivalent active ticket;
- create at most one new evidence-backed ticket;
- create no ticket when evidence is insufficient or a material decision is unresolved.

It never implements the ticket.

A new queue ticket begins with lifecycle metadata similar to:

```yaml
---
ticket_schema: 1
status: ready
source: morning-brief
created: YYYY-MM-DD
---
```

### Step 4 — Deliver the ticket

The default command is:

```text
/deliver-ticket
```

Other supported forms:

```text
/deliver-ticket 004
/deliver-ticket 004-saved-products
/deliver-ticket tickets/004-saved-products.md
/deliver-ticket Add saved products to the catalogue
```

The command resolves or creates one ticket, then coordinates:

```text
ticket
  ↓
spec
  ↓
TDD plan
  ↓
consolidated execution contract
```

At this point runtime/application changes have not started.

The execution contract should show:

- goal;
- scope;
- exclusions;
- technical approach;
- affected areas;
- TDD slices;
- dependency/migration/auth/security checkpoints;
- verification plan;
- risks and assumptions;
- human-review items;
- external actions that are explicitly not included.

When no stricter project phrase exists, runtime execution begins only after:

```text
Approve plan
```

Any material change to scope, architecture, dependencies, migrations, authentication, payments, permissions, security, destructive behaviour, deployment, acceptance, or verification invalidates that approval and requires a revised contract.

### Step 5 — Execute with TDD

For testable work the default implementation loop is:

```text
RED
write the smallest meaningful failing test
      ↓
run it and confirm the intended failure
      ↓
GREEN
make the minimum implementation change
      ↓
run the focused test and confirm it passes
      ↓
REFACTOR
clean the implementation without expanding behaviour
      ↓
VERIFY
run relevant regression, type, build, browser, or project checks
```

Checks are reported only as:

```text
Passed
Failed
Not run
```

A check that was never executed is not a pass and is not automatically a failure.

### Step 6 — Reach `delivered`

A ticket becomes `delivered` only when the workspace has evidence for:

- implemented acceptance criteria;
- required verification;
- final review;
- synchronized project truth;
- lifecycle delivery evidence.

`delivered` is a software-delivery state, not a GitHub or production state.

Keep these states distinct:

```text
proposed
specified
planned
awaiting-approval
in-progress
implemented
verifying
verified
delivered
committed
pushed
merged
deployed
released
```

For example, code may be delivered locally while still not committed or pushed.

### Step 7 — Publish delivered work

Only after the ticket is already `status: delivered`, run:

```text
/publish-ticket tickets/004-saved-products.md
```

`/publish-ticket` validates:

- current branch and intended base branch;
- exact diff/commit range;
- delivered ticket evidence;
- unrelated/uncommitted work;
- secret-bearing or unexpected files;
- remote branch state;
- existing pull requests.

It then presents a publication contract covering:

```text
repository
current branch
base branch
files/commits to publish
commit required? + commit message
push remote/branch
force: no
draft PR title/body
explicit exclusions
```

When no stricter project phrase exists, approve with:

```text
Approve publish
```

After approval it may:

1. create one scoped commit when needed;
2. push the approved non-protected branch normally, never with force;
3. create exactly one draft pull request.

It does not merge, deploy, release, delete branches, force-push, rebase/amend history, or mutate production/data state.

### Step 8 — Human review and merge

The draft PR is the handoff point.

Review should classify findings as:

```text
Must fix
Should fix
Okay to ship
```

Merging is separate from delivery and publication. Merge only after the required project review and explicit human authorization.

After merge, use `/workspace-health` or `/sync-project` if project memory does not yet reflect the new GitHub/repository state.

## Manual/expert delivery workflow

Use the lower-level commands when you want to stop between stages or inspect/edit each artifact independently:

```text
/ticket Add saved products
/spec tickets/004-saved-products.md
/plan spec/004-saved-products.md
/implement-plan plans/004-saved-products.md
```

Use this route when:

- product scope needs explicit review before technical design;
- architecture needs review before implementation planning;
- the plan needs external approval;
- another person/agent owns one stage;
- you need a deliberate pause between stages.

`/deliver-ticket` remains the recommended default when those pauses are unnecessary.

## Ticket lifecycle

Canonical ticket states:

| Status | Meaning |
| --- | --- |
| `ready` | Scoped and waiting for delivery |
| `awaiting-approval` | Spec/plan and execution contract are ready; runtime approval is pending |
| `in-progress` | Approved runtime implementation has started |
| `verifying` | Implementation is complete enough for final verification/review |
| `delivered` | Acceptance, verification/review, project truth, and delivery evidence are complete |
| `blocked` | A material decision or prerequisite prevents progress |
| `failed-verification` | An observed required verification failure remains unresolved |
| `superseded` | Another identified ticket intentionally replaces this ticket |

`delivered` and `superseded` are terminal historical states. A later regression becomes a new ticket referencing the original work.

## Recovery scenarios

### The docs say one thing but GitHub says another

Run:

```text
/workspace-health
```

Then, if the difference is supported by evidence:

```text
/sync-project
```

Do not manually promote ticket state merely because a PR exists or merged.

### A ticket says `in-progress` after an interrupted session

Do not resume blindly. `/deliver-ticket` must revalidate:

- current repository/worktree state;
- ticket/spec/plan contents;
- current code/tests;
- prior approval;
- whether the scope is still materially unchanged.

### Verification failed

Keep the ticket out of `delivered`. Resolve the failure or explicitly document why a required check cannot be completed under project rules.

### Verification was never run

Record it as `Not run` / verification debt. Do not convert it to `Failed` or `Passed` without evidence.

### Work is already committed or pushed

`/publish-ticket` should reuse the observed safe publication state instead of creating duplicate commits or force-pushing.

### A draft/open PR already exists

`/publish-ticket` must report/reuse it rather than creating a duplicate PR for the same branch/base pair.

### Project operating state needs to be rebuilt

Run:

```text
/reset-workspace
```

The command validates `.claude/workspace-manifest.json`, shows the exact deletion set, preserves application/runtime files and installed skills, and waits for explicit deletion approval.

## Safety rules to remember

1. Repository and verification evidence outrank stale planning metadata.
2. A ticket/spec/plan is never proof that implementation exists.
3. `delivered` does not mean committed, pushed, merged, deployed, or released.
4. Runtime execution and GitHub publication have separate approval boundaries.
5. Material scope changes invalidate prior execution approval.
6. Never force-push, rewrite history, merge, deploy, release, mutate production data, or make other external consequential changes unless the active project explicitly authorizes them.
7. Project-specific `AGENTS.md` / instructions may always impose stricter rules.

## Recommended command patterns

New project:

```text
/setup-workspace PRD.md
/workspace-health
/morning-brief
/deliver-ticket
```

Normal new feature:

```text
/morning-brief
/deliver-ticket
Approve plan
/publish-ticket
Approve publish
```

Known task without a pre-existing ticket:

```text
/deliver-ticket Add export to CSV
Approve plan
/publish-ticket
Approve publish
```

Resume after time away:

```text
/workspace-health
/sync-project      # only when drift needs repair
/deliver-ticket
```

Manual architecture-heavy work:

```text
/ticket <outcome>
/spec tickets/NNN-outcome.md
/plan spec/NNN-outcome.md
/implement-plan plans/NNN-outcome.md
```

After an outside/manual merge:

```text
/workspace-health
/sync-project
```

## Command boundary summary

```text
/setup-workspace     establish project operating memory
/workspace-health    inspect truth without writing
/sync-project        repair durable project truth
/morning-brief       select/queue one next outcome
/ticket              define WHAT and WHY
/spec                define HOW
/plan                define execution order
/implement-plan      execute an approved plan
/deliver-ticket      orchestrate delivery end to end
/publish-ticket      publish already-delivered work to a draft PR
/reset-workspace     reset manifest-owned operating state
```

For the exact contract of any command, read its `skills/<name>/SKILL.md` file. Project-local instructions remain authoritative when they are stricter than this general operating guide.
