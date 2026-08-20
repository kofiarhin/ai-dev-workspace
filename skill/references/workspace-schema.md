# Workspace Schema

Create the smallest applicable form of this structure. Reuse equivalent existing files or directories.

| Path | Responsibility |
| --- | --- |
| `AGENTS.md` | Canonical operating guide: working style, permissions, ticket discipline, verification, and reporting |
| `CLAUDE.md` | Thin compatibility entry point that directs Claude-compatible tools to the canonical operating guide |
| `roadmap.md` | Current goal, priorities, exclusions, ordered outcomes, and definition of done |
| `review.md` | Product, UX, code, security, accessibility, and evidence review standard |
| `context/product.md` | Product, customer, problem, promise, scope, journeys, and success criteria |
| `context/architecture.md` | Intended architecture plus clearly separated implemented state |
| `context/decisions.md` | Confirmed decisions and unresolved questions; never fabricated decisions |
| `context/current-state.md` | Intended, implemented, verified, and unresolved status |
| `customers/README.md` | Format and rules for future real customer evidence; no invented notes |
| `spec/README.md` | How active specs, tickets, and historical material are organized |
| `demos/core-flow.md` | PRD-derived buyer/user walkthrough and expected outcome |
| `demos/browser-review-checklist.md` | Desktop/mobile states, console/network, accessibility, and human review checks |
| `routines/README.md` | Safe routine format and activation boundary; define no active schedule |

Use the templates in `assets/templates/` as content guides, not text to copy blindly. Replace every placeholder with supported project facts or `Unresolved`.

Do not create empty `interviews/`, `feedback/`, `evidence/`, or similar directories. Create them later when real content exists.
