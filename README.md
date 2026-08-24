# AI Software Delivery Workspace

A reusable Claude Code workflow that turns a PRD and repository context into a persistent, reviewable software-delivery loop.

The package installs five skills:

```text
/setup-workspace
/ticket
/spec
/plan
/implement-plan
```

The workflow follows one simple chain:

```text
PRD
  ↓
/setup-workspace
  ↓
project brain + roadmap
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

The repository becomes the long-term memory. `context/lessons.md` keeps short, repository-specific lessons learned from verified work so future tickets, specs, plans, and implementations can avoid repeating mistakes without introducing a separate memory service.

## What `/setup-workspace` creates

```text
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

Existing files are preserved and compatible content is merged conservatively.

## Responsibilities

### `/setup-workspace`

Builds the project brain from a selected PRD or equivalent product specification plus current repository evidence. It is documentation-only.

### `/ticket`

Turns a roadmap item, bug report, idea, or request into one clear assignment with a visible finish line. A ticket defines **what should change and why**, not the implementation design.

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

A plan does not count as implementation evidence. A lesson must come from something actually observed in the repository, tests, review, or implementation.

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

## Delivery example

```text
/ticket Add saved products
/spec tickets/004-saved-products.md
/plan spec/004-saved-products.md
/implement-plan plans/004-saved-products.md
```

Each downstream artifact should reference its source so code can be traced back through plan → spec → ticket → roadmap/PRD.

## Updating an installation

Pull the latest repository changes and rerun the installer with `-Force` on Windows or `--force` on macOS/Linux. A forced upgrade replaces only the installed skill directories. It also removes the legacy `.claude/skills/setup-prd-workspace` skill if present. Generated project documentation is not deleted.

## Safety boundaries

The planning skills do not install dependencies, commit, push, merge, deploy, or silently make high-risk product decisions. `/implement-plan` changes runtime code only when the plan is approved and higher-priority project rules permit it. Material scope, architecture, dependency, migration, authentication, payment, permission, or security changes must stop for renewed approval rather than being silently absorbed.

Production deployment, destructive data operations, live billing/customer-data decisions, credential sharing, and security-policy decisions remain human-owned.

## License

[MIT](LICENSE)
