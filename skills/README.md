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
- `/ticket` — define what should change and why; before writing a ready ticket, run a bounded shared-understanding Grill when material user-owned decisions remain. The Grill asks one question at a time using `Question`, `Recommended answer`, and `Why`, stops early when clear, and asks at most three questions by default.
- `/spec` — define the repository-grounded technical contract from a shared-understanding-ready ticket; a plan-ready spec carries no blocking open technical question.
- `/plan` — define ordered TDD implementation slices from a plan-ready spec without carrying unresolved decisions into execution.
- `/implement-plan` — execute an approved plan and synchronize verified truth.
- `/deliver-ticket` — orchestrate ticket → bounded Grill when needed → spec → plan → approval → implementation → verification → delivery.

## Publication

- `/publish-ticket` — after delivery, approval-gated scoped commit + normal branch push + draft pull request; never merge or deploy.

## Quick command choice

```text
Need orientation?                    /workspace-health
Project memory is stale?             /sync-project
Need the next outcome?               /morning-brief
Need to scope a request without guessing? /ticket <request>
Know the task and want full delivery? /deliver-ticket <task>
Want manual stage-by-stage control?   /ticket → /spec → /plan → /implement-plan
Ticket is delivered and needs a PR?   /publish-ticket
Need to rebuild operating state?      /reset-workspace
```

### Ticket shared-understanding boundary

`/ticket` researches repository facts first. It only asks the user about material decisions that cannot be inferred safely and can change scope, acceptance criteria, environment/data, security/permissions, architecture constraints, dependencies/migrations, or verification requirements.

A successful `status: ready` ticket has no known material intake question left for `/spec`. If the default three-question Grill cap is exhausted while a material decision remains, the workflow must not guess or create a misleading ready ticket.

A skill may add `references/`, `assets/`, or `agents/` when useful. `SKILL.md` remains the required entry contract.
