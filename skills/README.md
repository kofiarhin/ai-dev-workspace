# Skill Registry

Every direct child of `skills/` that contains `SKILL.md` is an installable workspace skill. The Windows and Unix installers discover these directories automatically, so adding a new skill does not require editing a hardcoded installer list.

For the complete command-selection guide, approval boundaries, lifecycle flow, recovery scenarios, and day-to-day examples, read [`OPERATING_SYSTEM.md`](../OPERATING_SYSTEM.md).

## Workspace

- `/setup-workspace` — create the persistent AI operating workspace from a PRD/specification.
- `/workspace-health` — read-only consistency and evidence audit.
- `/sync-project` — approval-gated documentation/lifecycle reconciliation from current evidence.
- `/reset-workspace` — manifest-backed reset of workspace-owned operating state.

## Intake and delivery

- `/morning-brief` — reconcile evidence and create/reuse at most one queued ticket.
- `/ticket` — define what should change and why.
- `/spec` — define the repository-grounded technical contract.
- `/plan` — define ordered TDD implementation slices.
- `/implement-plan` — execute an approved plan and synchronize verified truth.
- `/deliver-ticket` — orchestrate ticket → spec → plan → approval → implementation → verification → delivery.

## Publication

- `/publish-ticket` — after delivery, approval-gated scoped commit + normal branch push + draft pull request; never merge or deploy.

## Quick command choice

```text
Need orientation?                    /workspace-health
Project memory is stale?             /sync-project
Need the next outcome?               /morning-brief
Know the task and want full delivery? /deliver-ticket <task>
Want manual stage-by-stage control?   /ticket → /spec → /plan → /implement-plan
Ticket is delivered and needs a PR?   /publish-ticket
Need to rebuild operating state?      /reset-workspace
```

A skill may add `references/`, `assets/`, or `agents/` when useful. `SKILL.md` remains the required entry contract.
