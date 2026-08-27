# AI Software Delivery Workspace

A reusable Claude Code workflow that turns a PRD and repository context into a persistent, reviewable software-delivery system with evidence-backed intake, ticket/spec/plan traceability, TDD execution, project-truth reconciliation, safe GitHub publication, and manifest-backed workspace reset.

The current package contains eleven installable skills:

```text
/setup-workspace
/workspace-health
/sync-project
/morning-brief
/reset-workspace
/ticket
/spec
/plan
/implement-plan
/deliver-ticket
/publish-ticket
```

The installers discover every direct `skills/*/SKILL.md` directory automatically, so new skills do not require duplicated hardcoded installer registries.

## Default operating loop

```text
PRD
  ↓
/setup-workspace
  ↓
project brain + roadmap + ownership manifest
  ↓
/workspace-health      optional read-only audit when state may be stale
  ↓
/sync-project          optional approved documentation/lifecycle repair
  ↓
/morning-brief
  ↓
create or reuse one evidence-backed ticket
  ↓
tickets/NNN-feature.md
status: ready
  ↓
/deliver-ticket
  ↓
spec → TDD plan → consolidated execution review
  ↓
Approve plan
  ↓
RED → GREEN → REFACTOR → VERIFY
  ↓
final verification + review
  ↓
project truth + ticket delivery evidence
  ↓
status: delivered
  ↓
/publish-ticket        optional separate approval
  ↓
commit if needed → normal branch push → draft PR
```

The lower-level delivery commands remain available when manual control is preferable:

```text
/ticket → /spec → /plan → /implement-plan
```

`delivered`, `committed`, `pushed`, `merged`, `deployed`, and `released` are deliberately different states.

## What `/setup-workspace` creates

The standard operating workspace includes:

```text
.claude/
  workspace-manifest.json
AGENTS.md
CLAUDE.md
roadmap.md
review.md
context/
  product.md
  architecture.md
  decisions.md
  current-state.md
  lessons.md
customers/
  README.md
tickets/
  README.md
spec/
  README.md
plans/
  README.md
demos/
  core-flow.md
  browser-review-checklist.md
routines/
  README.md
```

Existing files are preserved and compatible content is merged conservatively. The manifest records whether operating paths were `created`, `updated`, or `reused`; it must never claim ownership of application/runtime code or unrelated project files.

The repository becomes the long-term memory. `context/lessons.md` keeps short repository-specific lessons learned from observed implementation, debugging, verification, or review evidence.

## Command responsibilities

### `/setup-workspace`

Builds the project brain from a selected PRD or equivalent product specification plus current repository evidence. Setup is documentation-only and maintains `.claude/workspace-manifest.json` for safe reset ownership.

### `/workspace-health`

Strictly read-only workspace audit. It compares operating documents and lifecycle metadata with repository, Git, GitHub, and verification evidence and reports:

- blockers;
- truth drift;
- lifecycle drift;
- verification debt;
- ticket/spec/plan linkage problems;
- stale approvals/plans;
- ownership-manifest issues.

It diagnoses; it never repairs state.

### `/sync-project`

Reconciles durable project truth after work happened outside the normal delivery flow, such as a separately merged PR or verification completed later.

It may update only approved operating documents and evidence-backed ticket lifecycle fields. Unless the active project grants a narrower command-scoped permission, it presents the exact reconciliation plan and requires:

```text
Approve sync
```

It does not change runtime code, dependencies/data, Git state, GitHub state, specs/plans, merge, deployment, or release state.

### `/morning-brief`

Reconciles the operating guide, roadmap, current state, verification evidence, available GitHub state, active tickets/specs/plans, and real customer signals. It identifies at most one highest-leverage next outcome.

Its only repository write is creating at most one evidence-backed ticket under `tickets/` when no equivalent active ticket exists and no material decision blocks safe scoping. Otherwise it references the existing ticket or creates none.

### `/reset-workspace`

Resets only operating state explicitly owned by `.claude/workspace-manifest.json` as `created`. It shows the exact deletion set and requires explicit approval before deletion.

It preserves application/runtime files, source product documents, Git metadata, secrets/configuration, dependency files, lockfiles, deployment configuration, unknown project files, and `.claude/skills/`. Missing or invalid ownership evidence fails closed.

### `/ticket`

Turns a roadmap outcome, bug report, idea, or request into one evidence-backed assignment defining **what should change and why**, not implementation design.

### `/spec`

Turns one approved ticket into a repository-grounded technical contract defining how the requested behaviour should fit the current system.

### `/plan`

Turns one approved specification into ordered implementation slices. Testable slices use:

```text
RED → GREEN → REFACTOR → VERIFY
```

### `/implement-plan`

Executes an approved plan against the current repository, one testable slice at a time. It runs relevant verification, reviews the result, updates project truth only from observed evidence, and synchronizes lifecycle-aware ticket acceptance/delivery evidence.

### `/deliver-ticket`

Orchestrates the full delivery lifecycle without weakening `/ticket`, `/spec`, `/plan`, or `/implement-plan`.

It resolves one queued/supplied ticket, creates or revalidates its spec and TDD plan, presents one consolidated execution contract, waits for explicit runtime approval, then coordinates implementation, verification, review, project-truth synchronization, and evidence-backed delivery.

With no stronger project phrase, runtime execution requires:

```text
Approve plan
```

Material scope, architecture, dependency, migration, authentication, payment, permission, security, deployment, destructive-behaviour, acceptance, or verification changes invalidate prior approval.

### `/publish-ticket`

Separate post-delivery publication boundary. The source ticket must already be lifecycle-aware and `status: delivered` with required delivery evidence.

Before Git/GitHub writes it validates the non-protected branch, exact diff/commit set, base branch, remote state, and duplicate-PR state, then presents one publish contract. With no stronger project phrase it requires:

```text
Approve publish
```

After approval it may:

- create one scoped commit when delivered changes are still uncommitted;
- push the approved non-main branch normally, never with force;
- create exactly one draft pull request.

It never merges, deploys, releases, rewrites history, deletes branches, or mutates production/data state.

## Ticket queue and lifecycle

New tickets use frontmatter such as:

```yaml
---
ticket_schema: 1
status: ready
source: manual
created: YYYY-MM-DD
---
```

Canonical statuses:

- `ready` — scoped and waiting for delivery;
- `awaiting-approval` — valid spec/plan and current execution contract are waiting for approval;
- `in-progress` — approved runtime implementation has started;
- `verifying` — implementation is complete enough for final verification/review;
- `delivered` — acceptance criteria, required verification/review, project truth, and delivery evidence are complete;
- `blocked` — a material decision/prerequisite prevents progress;
- `failed-verification` — an observed required verification failure remains unresolved;
- `superseded` — another identified ticket intentionally replaces this one.

`delivered` and `superseded` are terminal queue states. A regression after delivery becomes a new ticket rather than silently reopening history.

A merge alone never proves delivery. A missing check is `Not run`, not automatically `Failed`.

## `/deliver-ticket` input modes

Use the latest eligible unfinished numeric ticket:

```text
/deliver-ticket
```

Use an exact ticket:

```text
/deliver-ticket tickets/004-saved-products.md
```

Resolve by unique number or basename:

```text
/deliver-ticket 004
/deliver-ticket 004-saved-products
```

Start from a freeform task:

```text
/deliver-ticket Add saved products to the catalogue
```

Freeform input applies normal ticket evidence/scope and duplicate rules before creating a new ticket.

## Approval and verification

Before runtime/application edits, `/deliver-ticket` presents one execution contract covering goal, scope, exclusions, technical approach, affected areas, TDD slices, material checkpoints, verification, risks/assumptions, human-review items, and explicitly excluded external actions.

After implementation, relevant checks are reported as `Passed`, `Failed`, or `Not run`. Final review uses `Must fix`, `Should fix`, and `Okay to ship`.

A ticket is delivered only when supported by observed acceptance, verification/review, and synchronized project truth.

Publication has a separate approval boundary and does not retroactively change delivery evidence.

## Install on Windows

```powershell
git clone https://github.com/kofiarhin/ai-dev-workspace.git
cd ai-dev-workspace
.\scripts\install.ps1 -ProjectPath "C:\path\to\your-project"
```

## Install on macOS or Linux

```bash
git clone https://github.com/kofiarhin/ai-dev-workspace.git
cd ai-dev-workspace
./scripts/install.sh /path/to/your-project
```

Skills are installed under:

```text
your-project/.claude/skills/
```

The installers discover installable skill directories automatically. If one or more corresponding target skills already exist, rerun with `-Force` on Windows or `--force` on Unix to replace the installed skill directories.

Generated project documentation and `.claude/workspace-manifest.json` are not deleted by the installer.

## Start a project

Place a PRD in the project and run:

```text
/setup-workspace PRD.md
```

Then use:

```text
/workspace-health
/morning-brief
/deliver-ticket
```

Use `/sync-project` when external/manual repository reality needs to be reconciled into durable project truth. Use `/publish-ticket` only after a ticket is delivered and Git publication is explicitly wanted.

## Manual delivery example

```text
/ticket Add saved products
/spec tickets/004-saved-products.md
/plan spec/004-saved-products.md
/implement-plan plans/004-saved-products.md
```

Each downstream artifact should reference its source so work can be traced plan → spec → ticket → roadmap/PRD.

## Reset example

```text
/reset-workspace
```

The skill first validates the manifest, shows the exact manifest-owned deletion set and what will be preserved, then waits for explicit approval. `/reset-workspace` is not an uninstall command; `.claude/skills/` remains installed.

## Safety boundaries

- `/workspace-health` is read-only.
- `/sync-project` is documentation/lifecycle-only and approval-gated unless stronger project instructions provide a narrow permission.
- `/morning-brief` may create at most one queued ticket and cannot implement it.
- `/deliver-ticket` and `/implement-plan` may change runtime code only after required execution approval and revalidation.
- `/publish-ticket` has a separate publication approval and may only create a scoped commit when needed, normal branch push, and draft PR.
- `/reset-workspace` deletes only validated manifest-owned `created` operating state after exact preview and approval.
- Planning/delivery/publication do not imply merge, deployment, release, production activation, destructive data operations, live billing/customer-data decisions, credential sharing, or security-policy decisions.

Project-specific instructions may be stricter and always remain authoritative within their permitted precedence.

## License

[MIT](LICENSE)
