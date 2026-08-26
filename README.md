# AI Software Delivery Workspace

A reusable Claude Code workflow that turns a PRD and repository context into a persistent, reviewable software-delivery loop with an evidence-backed ticket queue, end-to-end ticket delivery, and a manifest-backed workspace reset.

The package installs eight skills:

```text
/setup-workspace
/morning-brief
/reset-workspace
/ticket
/spec
/plan
/implement-plan
/deliver-ticket
```

The default operating loop is:

```text
PRD
  ↓
/setup-workspace
  ↓
project brain + roadmap + ownership manifest
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
```

The lower-level commands remain available when you want manual control:

```text
/ticket → /spec → /plan → /implement-plan
```

When the AI operating workspace needs to be rebuilt, `/reset-workspace` uses the ownership manifest to preview and remove only workspace-owned operating state after explicit approval. It preserves the application and installed skills so `/setup-workspace` can be run again.

The repository becomes the long-term memory. `context/lessons.md` keeps short, repository-specific lessons learned from verified work so future briefs, tickets, specs, plans, and implementations can avoid repeating mistakes without introducing a separate memory service.

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

## Responsibilities

### `/setup-workspace`

Builds the project brain from a selected PRD or equivalent product specification plus current repository evidence. It is documentation-only.

It also maintains `.claude/workspace-manifest.json`, which records operating-workspace ownership for safe reset behavior. Newly created operating containers or files may be reset-owned; pre-existing files that are updated or reused remain protected from automatic deletion.

### `/morning-brief`

Reconciles the project's operating guide, roadmap, current state, verification evidence, available GitHub state, active tickets/specs/plans, and real customer signals. It identifies at most one highest-leverage next outcome.

Its only write permission is creating at most one evidence-backed ticket under `tickets/` when no equivalent active ticket exists and no material decision blocks safe scoping. A new ticket starts with `status: ready` and `source: morning-brief`.

If an equivalent active ticket already covers the outcome, the brief references it instead of creating a duplicate. If a material decision is unresolved or evidence is insufficient, it creates no ticket.

The morning brief does not implement code, create specs/plans, modify GitHub state, change dependencies/data, commit, push, merge, deploy, or activate routines.

### `/reset-workspace`

Resets the AI operating workspace without uninstalling the skills or modifying the application.

It requires a valid `.claude/workspace-manifest.json`, validates every reset candidate, expands owned directories for an exact deletion preview, and requires explicit approval before removing anything. Only entries marked `created` are eligible for deletion. Entries marked `updated` or `reused`, unknown files, application/runtime code, the source PRD, Git metadata, secrets, dependency files, lockfiles, deployment/CI configuration, and `.claude/skills/` are preserved.

Legacy or untracked workspaces without a valid manifest fail closed: `/reset-workspace` may report likely operating paths, but it deletes nothing automatically.

After a complete successful reset, the manifest is removed and the installed skills remain available so the workspace can be rebuilt with `/setup-workspace`.

### `/ticket`

Turns a roadmap item, morning-brief outcome, bug report, idea, or request into one clear assignment with a visible finish line and lifecycle metadata. A ticket defines **what should change and why**, not the implementation design.

### `/spec`

Turns an approved ticket into the technical contract. It inspects the relevant architecture, decisions, code, and tests before describing how the requested behaviour should fit the existing system.

### `/plan`

Turns the spec into small implementation slices. Each testable slice is planned around **RED → GREEN → REFACTOR → VERIFY**.

### `/implement-plan`

Executes an approved plan against the current repository. It uses TDD by default, runs relevant verification, reviews the result against `review.md`, and updates project truth only from observed implementation evidence.

For lifecycle-aware tickets it also synchronizes acceptance criteria, `## Delivery Evidence`, and final ticket status from observed evidence. Failed required verification cannot produce `status: delivered`.

### `/deliver-ticket`

Coordinates the full delivery lifecycle without replacing the lower-level skill contracts.

It resolves one ticket, generates or revalidates its spec and TDD plan, presents one consolidated execution contract, waits for explicit approval before runtime changes, then coordinates implementation, verification, review, project-truth synchronization, and evidence-backed ticket delivery.

## Ticket queue and lifecycle

New tickets use lifecycle frontmatter such as:

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
- `awaiting-approval` — spec/plan are ready and execution approval is pending;
- `in-progress` — approved runtime implementation has started;
- `verifying` — implementation slices are complete and final verification/review is running;
- `delivered` — acceptance criteria, required verification, review, and project-truth synchronization are complete from observed evidence;
- `blocked` — a material decision/prerequisite prevents progress;
- `failed-verification` — required verification remains failed;
- `superseded` — another ticket intentionally replaces this one.

`delivered` and `superseded` are terminal queue states. A delivered historical ticket is not silently reopened. A later regression becomes a new ticket referencing the prior ticket.

`delivered` does **not** mean committed, pushed, merged, deployed, or released.

## `/deliver-ticket` input modes

Use the latest eligible unfinished ticket:

```text
/deliver-ticket
```

Automatic selection sorts numeric ticket prefixes descending and chooses the first eligible unfinished ticket. It skips `delivered` and `superseded`, skips `blocked` for automatic selection, and revalidates interrupted or failed work before continuation. It does not use filesystem modification time.

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

If freeform input does not resolve to an existing ticket, `/deliver-ticket` applies the normal ticket scoping/evidence rules, prevents duplicates, creates the next numbered ticket with `source: deliver-ticket`, then continues through the same pipeline.

Ambiguous ticket references stop for one concrete question rather than guessing.

## Approval and verification

`/deliver-ticket` may create or update the ticket/spec/plan artifacts needed to reach execution review when the active project's rules permit those documentation writes.

Before runtime/application edits it presents one consolidated execution contract covering:

- goal and scope;
- exclusions;
- technical approach;
- affected areas;
- TDD slices;
- material dependency/migration/auth/security checkpoints;
- verification;
- risks/assumptions;
- human-review items;
- external actions not included.

Runtime implementation requires the project's explicit approval phrase; when no stronger phrase is configured, the fallback is:

```text
Approve plan
```

Material scope, architecture, dependency, migration, authentication, payment, permission, security, deployment, or destructive changes invalidate that approval and require a revised contract.

After approved implementation, relevant checks are reported as `Passed`, `Failed`, or `Not run`. Final review uses `Must fix`, `Should fix`, and `Okay to ship`. A ticket is delivered only after in-scope `Must fix` findings are resolved and evidence/project truth are synchronized.

## Install on Windows

```powershell
git clone https://github.com/kofiarhin/setup-prd-workspace.git
cd setup-prd-workspace
.\scripts\install.ps1 -ProjectPath "C:\path\to\your-project"
```

## Install on macOS or Linux

```bash
git clone https://github.com/kofiarhin/setup-prd-workspace.git
cd setup-prd-workspace
./scripts/install.sh /path/to/your-project
```

The skills are installed under:

```text
your-project/.claude/skills/
```

## Start a project

Place a PRD in the project and run:

```text
/setup-workspace PRD.md
```

Use an exact relative or absolute path when needed:

```text
/setup-workspace docs/product-requirements.md
```

An example input is available at [`examples/Sample-PRD.md`](examples/Sample-PRD.md).

## Operator example

Start a working session with:

```text
/morning-brief
```

The brief ends by creating one ticket, referencing an equivalent existing ticket, or explaining why no ticket was created.

When a ticket is ready:

```text
/deliver-ticket
```

or pass the ticket explicitly.

## Manual delivery example

Use the lower-level commands when you want step-by-step control:

```text
/ticket Add saved products
/spec tickets/004-saved-products.md
/plan spec/004-saved-products.md
/implement-plan plans/004-saved-products.md
```

Each downstream artifact should reference its source so work can be traced plan → spec → ticket → roadmap/PRD.

## Reset example

Run:

```text
/reset-workspace
```

The skill first shows the exact manifest-owned deletion set and what will be preserved. Nothing is removed until the preview receives explicit approval.

A typical lifecycle is:

```text
/setup-workspace PRD.md
# work with the operating workspace
/reset-workspace
# review preview and approve
/setup-workspace PRD.md
```

`/reset-workspace` is not an uninstall command. `.claude/skills/` remains installed.

## Updating an installation

Pull the latest repository changes and rerun the installer with `-Force` on Windows or `--force` on macOS/Linux. A forced upgrade replaces only the installed skill directories. It also removes the legacy `.claude/skills/setup-prd-workspace` skill if present. Generated project documentation and `.claude/workspace-manifest.json` are not deleted by the installer.

## Safety boundaries

`/morning-brief` has one narrow repository write permission: create at most one queued ticket. It cannot implement that ticket or modify external systems.

`/reset-workspace` is destructive only to explicitly manifest-owned `created` operating state and always requires an exact preview plus explicit approval. It fails closed when ownership cannot be validated.

The planning skills do not install dependencies, push, merge, deploy, or silently make high-risk product decisions. `/deliver-ticket` and `/implement-plan` change runtime code only after the required execution approval and revalidation. Material changes reopen approval rather than being silently absorbed.

Production deployment, destructive application/data operations, live billing/customer-data decisions, credential sharing, and security-policy decisions remain human-owned unless separately authorized under the active project's rules.

## License

[MIT](LICENSE)
