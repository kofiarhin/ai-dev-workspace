# AI Software Delivery Workspace

A reusable Claude Code workflow that turns a PRD and repository context into a persistent, reviewable software-delivery loop with a read-only operator brief and a manifest-backed workspace reset.

The package installs seven skills:

```text
/setup-workspace
/morning-brief
/reset-workspace
/ticket
/spec
/plan
/implement-plan
```

The package separates orientation, delivery, and workspace lifecycle:

```text
PRD
  ↓
/setup-workspace
  ↓
project brain + roadmap + ownership manifest
  ↓
/morning-brief
  ↓
one evidence-backed recommended next outcome
  ↓
human selects or refines the outcome
  ↓
/ticket
  ↓
tickets/NNN-feature.md
  ↓
/spec
  ↓
spec/NNN-feature.md
  ↓
/plan
  ↓
plans/NNN-feature.md
  ↓
/implement-plan
  ↓
RED → GREEN → REFACTOR → VERIFY
  ↓
review + document sync + lessons
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

Produces a concise read-only operator brief from the project's own operating guide, roadmap, current state, verification evidence, available GitHub state, and real customer signals. It reconciles project truth, flags stale or conflicting status, identifies verification debt and material risks, and recommends exactly one next ticket outcome.

It does not edit files, modify GitHub state, create tickets automatically, run persistent jobs, change data, commit, push, merge, deploy, or activate routines. Pass the selected recommendation to `/ticket` after human review.

### `/reset-workspace`

Resets the AI operating workspace without uninstalling the skills or modifying the application.

It requires a valid `.claude/workspace-manifest.json`, validates every reset candidate, expands owned directories for an exact deletion preview, and requires explicit approval before removing anything. Only entries marked `created` are eligible for deletion. Entries marked `updated` or `reused`, unknown files, application/runtime code, the source PRD, Git metadata, secrets, dependency files, lockfiles, deployment/CI configuration, and `.claude/skills/` are preserved.

Legacy or untracked workspaces without a valid manifest fail closed: `/reset-workspace` may report likely operating paths, but it deletes nothing automatically.

After a complete successful reset, the manifest is removed and the installed skills remain available so the workspace can be rebuilt with `/setup-workspace`.

### `/ticket`

Turns a roadmap item, morning-brief recommendation, bug report, idea, or request into one clear assignment with a visible finish line. A ticket defines **what should change and why**, not the implementation design.

### `/spec`

Turns an approved ticket into the technical contract. It inspects the relevant architecture, decisions, code, and tests before describing how the requested behaviour should fit the existing system.

### `/plan`

Turns the spec into small implementation slices. Each testable slice is planned around **RED → GREEN → REFACTOR → VERIFY**.

### `/implement-plan`

Executes an approved plan against the current repository. It uses TDD by default, runs relevant verification, reviews the result against `review.md`, and updates project truth only from observed implementation evidence.

After verified implementation it keeps these documents aligned when relevant:

- `context/current-state.md`
- `context/architecture.md`
- `context/decisions.md`
- `roadmap.md`
- `context/lessons.md`

A morning brief, ticket, specification, or plan does not count as implementation evidence. A lesson must come from something actually observed in the repository, tests, review, or implementation.

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

The brief should end with no more than one recommended next ticket outcome. Review or refine that recommendation before handing it to `/ticket`.

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

## Delivery example

```text
/morning-brief
/ticket Add saved products
/spec tickets/004-saved-products.md
/plan spec/004-saved-products.md
/implement-plan plans/004-saved-products.md
```

Each downstream artifact should reference its source so code can be traced back through plan → spec → ticket → roadmap/PRD. A morning-brief recommendation may explain why a ticket was selected, but the ticket must independently re-read current evidence.

## Updating an installation

Pull the latest repository changes and rerun the installer with `-Force` on Windows or `--force` on macOS/Linux. A forced upgrade replaces only the installed skill directories. It also removes the legacy `.claude/skills/setup-prd-workspace` skill if present. Generated project documentation and `.claude/workspace-manifest.json` are not deleted by the installer.

## Safety boundaries

`/morning-brief` is read-only. `/reset-workspace` is destructive only to explicitly manifest-owned `created` operating state and always requires an exact preview plus explicit approval. It fails closed when ownership cannot be validated.

The planning skills do not install dependencies, commit, push, merge, deploy, or silently make high-risk product decisions. `/implement-plan` changes runtime code only when the plan is approved and higher-priority project rules permit it. Material scope, architecture, dependency, migration, authentication, payment, permission, or security changes must stop for renewed approval rather than being silently absorbed.

Production deployment, destructive application/data operations, live billing/customer-data decisions, credential sharing, and security-policy decisions remain human-owned.

## License

[MIT](LICENSE)
