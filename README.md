# AI Software Delivery Workspace

A reusable Claude Code software-delivery operating system for turning a PRD and repository into a persistent, evidence-backed workflow for intake, specification, TDD implementation, verification, project-truth reconciliation, and safe GitHub publication.

## Start here

For the full day-to-day operating manual, command decision table, approval boundaries, lifecycle states, recovery scenarios, and examples, read:

**[AI Dev Workspace Operating System Guide](OPERATING_SYSTEM.md)**

The package currently contains eleven installable commands:

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

The installers automatically discover every direct `skills/*/SKILL.md` directory, so new skills do not require a duplicated hardcoded registry.

## Default workflow

```text
/setup-workspace PRD.md
        ↓
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
/sync-project        when durable project truth needs repair
```

The lower-level delivery chain remains available for manual control:

```text
/ticket → /spec → /plan → /implement-plan
```

## Core model

The workspace keeps software states deliberately separate:

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

A ticket being `delivered` does not mean it was committed, pushed, merged, deployed, or released.

## Command map

### Workspace

- `/setup-workspace` — create or reconcile the persistent operating workspace from a PRD/specification.
- `/workspace-health` — strictly read-only audit of repository truth, lifecycle state, verification debt, artifact links, approvals, and manifest integrity.
- `/sync-project` — approval-gated repair of durable project docs/lifecycle metadata from current evidence.
- `/reset-workspace` — exact-preview reset of manifest-owned operating state while preserving application/runtime files and installed skills.

### Intake and delivery

- `/morning-brief` — reconcile current evidence and create/reuse at most one next ticket.
- `/ticket` — define what should change and why.
- `/spec` — define the repository-grounded technical contract.
- `/plan` — define ordered implementation slices.
- `/implement-plan` — execute an approved plan with RED → GREEN → REFACTOR → VERIFY.
- `/deliver-ticket` — orchestrate ticket → spec → plan → execution approval → implementation → verification → delivery.

### Publication

- `/publish-ticket` — after a ticket is already delivered, validate the exact branch/diff and, after separate approval, create a scoped commit when needed, push without force, and create one draft PR. It never merges or deploys.

See [skills/README.md](skills/README.md) for the skill registry and each `skills/<command>/SKILL.md` for the exact command contract.

## What setup creates

The standard project operating layer includes:

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
tickets/
spec/
plans/
demos/
routines/
```

The repository becomes long-term project memory. Repository and verification evidence outrank stale planning/lifecycle metadata.

## Install on Windows

```powershell
git clone https://github.com/kofiarhin/ai-dev-workspace.git
cd ai-dev-workspace
.\scripts\install.ps1 -ProjectPath "C:\path\to\your-project"
```

## Install on macOS/Linux

```bash
git clone https://github.com/kofiarhin/ai-dev-workspace.git
cd ai-dev-workspace
./scripts/install.sh /path/to/your-project
```

Skills are installed under:

```text
your-project/.claude/skills/
```

If target skills already exist, rerun with `-Force` on Windows or `--force` on Unix to replace only the installed skill directories. Generated operating documents and `.claude/workspace-manifest.json` are preserved.

## Initialize a project

Place a PRD or equivalent specification in the project, then run:

```text
/setup-workspace PRD.md
```

For normal work:

```text
/workspace-health
/morning-brief
/deliver-ticket
```

Use `/sync-project` when repository/Git/GitHub reality changed outside the normal delivery flow. Use `/publish-ticket` only after the source ticket is already `status: delivered` and GitHub publication is explicitly wanted.

## Approval boundaries

The fallback approval phrases are:

```text
Approve plan
Approve sync
Approve publish
```

Project-specific instructions may require stricter phrases or additional gates.

- `Approve plan` covers only the presented runtime execution contract.
- `Approve sync` covers only the presented operating-document/lifecycle reconciliation.
- `Approve publish` covers only the presented repository/branch/commit/push/draft-PR contract.

Material changes invalidate the relevant prior approval.

## Ticket lifecycle

Canonical ticket states are:

- `ready`
- `awaiting-approval`
- `in-progress`
- `verifying`
- `delivered`
- `blocked`
- `failed-verification`
- `superseded`

`delivered` and `superseded` are terminal historical states. A later regression becomes a new ticket referencing the original work.

## Verification model

Checks are reported only as:

```text
Passed
Failed
Not run
```

A check that was not executed is never claimed as passed. A ticket is delivered only when observed evidence supports acceptance criteria, required verification/review, synchronized project truth, and delivery evidence.

## Safety boundaries

- `/workspace-health` never writes.
- `/sync-project` changes only approved operating docs/lifecycle metadata.
- `/morning-brief` may create at most one evidence-backed queue ticket and never implements it.
- `/deliver-ticket` and `/implement-plan` change runtime code only after the required execution approval and revalidation.
- `/publish-ticket` requires separate publication approval and never force-pushes, rewrites history, merges, deploys, releases, deletes branches, or mutates production/data state.
- `/reset-workspace` deletes only validated manifest-owned `created` operating state after an exact preview and explicit approval.
- Project-specific `AGENTS.md` and safety rules may always be stricter.

## Full usage manual

Read **[OPERATING_SYSTEM.md](OPERATING_SYSTEM.md)** for:

- the complete daily workflow;
- command selection guidance;
- approval and permission boundaries;
- lifecycle semantics;
- TDD execution flow;
- publication flow;
- recovery after interrupted work, stale docs, missing verification, or outside merges;
- manual/expert command patterns;
- practical command recipes.

## License

[MIT](LICENSE)
