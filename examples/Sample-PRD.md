# ShootFlow Product Requirements Document

**Version:** 1.0

**Status:** Approved for workspace setup

**Product owner:** Solo founder
**Target release:** MVP

## 1. Product summary

ShootFlow is a lightweight web application that helps freelance photographers turn a confirmed client booking into an organised shoot plan.

The photographer enters the client, shoot type, date, location, creative direction and required deliverables. ShootFlow produces one workspace containing the brief, schedule, shot list, equipment checklist and delivery checklist.

## 2. Problem

Freelance photographers often manage shoots across messages, notes, spreadsheets and memory. This creates several recurring problems:

- Important client requirements are lost inside message threads.
- Shot lists are recreated manually for every booking.
- Equipment is forgotten because there is no consistent checklist.
- Clients and assistants do not share one clear schedule.
- Delivery requirements are sometimes discovered after the shoot.

The result is avoidable preparation time, missed shots and inconsistent client experiences.

## 3. Product promise

Turn a confirmed photography booking into a complete, reviewable shoot plan in under five minutes.

## 4. Target users

### Primary user

Independent photographers who manage their own bookings and shoot preparation.

### Secondary users

- Photography assistants who need the schedule, shot list and equipment plan.
- Clients who need a simplified brief and schedule.

### Initial market

UK-based freelance portrait, event and brand photographers.

## 5. Goals

- Give photographers one repeatable planning workflow.
- Reduce the time required to prepare a standard shoot.
- Make client requirements visible before shoot day.
- Reduce forgotten equipment and missed priority shots.
- Keep the MVP simple enough for a solo photographer to use without onboarding support.

## 6. Success metrics

- A first-time user can create a complete shoot plan in under five minutes.
- At least 80% of test users complete the planning flow without assistance.
- Every saved shoot contains a brief, schedule, shot list, equipment checklist and delivery checklist.
- No client receives access to another client's shoot.
- The primary workflow works at desktop and mobile widths.

## 7. MVP scope

### Included

- Create, view, edit and archive a shoot.
- Capture client name, email and phone number.
- Select portrait, event or brand shoot type.
- Capture shoot date, start time, expected duration and location.
- Record creative direction, mood, references and client priorities.
- Generate a suggested shot-list template based on shoot type.
- Let photographers add, edit, reorder and complete shot-list items.
- Create an equipment checklist from a reusable default list.
- Let photographers add custom equipment items.
- Create a simple shoot-day schedule.
- Capture delivery format, quantity, due date and delivery notes.
- Show preparation progress for each shoot.
- Provide loading, empty, validation, error and success states.
- Provide a read-only client summary link that hides internal notes and equipment details.

### Excluded

- Payments and invoicing.
- Contracts and electronic signatures.
- Image hosting or gallery delivery.
- Calendar synchronisation.
- Email or SMS automation.
- Multi-user teams and role management.
- Native mobile applications.
- AI image generation.
- Production deployment as part of the initial implementation ticket.

## 8. Primary user journey

1. The photographer opens ShootFlow.
2. The dashboard shows active shoots and a clear **Create shoot** action.
3. The photographer enters client and booking details.
4. The photographer selects the shoot type.
5. ShootFlow adds a relevant starter shot list and equipment checklist.
6. The photographer edits the creative brief, schedule, shot list and equipment.
7. The photographer records delivery requirements.
8. ShootFlow shows a review screen with missing required information.
9. The photographer saves the shoot plan.
10. The dashboard shows preparation progress and the next shoot date.
11. The photographer may copy a read-only client summary link.

## 9. Functional requirements

### 9.1 Dashboard

- Display active shoots ordered by nearest shoot date.
- Show client name, shoot type, date, location and preparation progress.
- Provide empty-state guidance when no shoots exist.
- Allow archived shoots to be viewed separately.

### 9.2 Shoot details

Required fields:

- Client name
- Shoot type
- Shoot date
- Start time
- Location
- Delivery due date

Optional fields:

- Client email
- Client phone
- Expected duration
- Creative direction
- Mood or visual references
- Internal notes

Validation errors must appear next to the relevant field and in an accessible summary.

### 9.3 Shot list

- Start with a template appropriate to the selected shoot type.
- Allow items to be added, edited, deleted and reordered.
- Support priority levels: required, preferred and optional.
- Allow items to be marked complete during the shoot.
- Changing shoot type must not silently delete custom items.

### 9.4 Equipment checklist

- Start with the photographer's reusable default equipment list.
- Allow project-specific items to be added or removed.
- Group items under cameras, lenses, lighting, audio, power, storage and other.
- Allow items to be marked packed.

### 9.5 Schedule

- Support ordered schedule entries with a time, title and optional notes.
- Warn when schedule entries overlap.
- Do not prevent saving solely because entries overlap.

### 9.6 Delivery checklist

- Capture delivery format, expected image quantity, due date and notes.
- Support checklist items such as backup, cull, edit, review and deliver.
- Show overdue delivery work clearly.

### 9.7 Client summary

- Provide a non-guessable read-only link.
- Show client-facing brief, location, date, schedule and client preparation notes.
- Hide internal notes, equipment, private contact information and delivery workflow.
- Allow the photographer to revoke the link.

## 10. Non-functional requirements

### Performance

- The initial application screen should become usable within three seconds on a typical mobile connection.
- Common UI interactions should respond within 200 milliseconds, excluding network requests.

### Accessibility

- Target WCAG 2.2 AA for the primary flow.
- All functionality must be keyboard accessible.
- Form controls require visible labels and actionable error messages.
- Status changes must be announced appropriately to assistive technologies.

### Responsive design

- Support mobile widths from 360 pixels.
- Support current desktop versions of Chrome, Edge and Safari.

### Reliability

- Failed saves must preserve the user's entered data and provide a retry action.
- Destructive actions require confirmation.
- Archiving is preferred over permanent deletion in the MVP.

## 11. Security and privacy

- Client contact details are private data.
- Secrets must be stored in environment variables and never committed.
- API input must be validated server-side.
- Client summary tokens must be random, revocable and stored securely.
- Internal notes must never appear in the client summary response.
- Application logs must not contain client phone numbers, email addresses or summary tokens.
- The MVP must include a documented data-retention decision before production deployment.

## 12. Recommended technical direction

This direction is approved for the MVP:

- React with the latest Vite and TypeScript.
- Tailwind CSS.
- Node.js and Express.
- MongoDB with Mongoose.
- TanStack Query for server state.
- React local state for form state; Redux Toolkit only if a genuine global-state need appears.
- Vitest and Testing Library for frontend tests.
- Jest or the project's established backend test runner for API tests.
- One root `package.json` unless implementation evidence justifies another structure.
- Environment variables stored in `.env` with a safe `.env.example`.

Authentication is required before any real client data is used, but the authentication provider is unresolved.

## 13. Core data entities

### Shoot

- id
- ownerId
- client
- shootType
- date
- startTime
- expectedDuration
- location
- creativeDirection
- references
- internalNotes
- status
- archivedAt
- createdAt
- updatedAt

### ShotListItem

- id
- shootId
- title
- notes
- priority
- order
- completed

### EquipmentItem

- id
- shootId
- name
- category
- packed
- source: default or custom

### ScheduleEntry

- id
- shootId
- time
- title
- notes
- order

### DeliveryRequirement

- shootId
- format
- expectedQuantity
- dueDate
- notes
- checklist

### ClientSummaryAccess

- shootId
- tokenHash
- active
- createdAt
- revokedAt

## 14. API expectations

The exact endpoint design may be refined during implementation, but the API must support:

- Creating and listing shoots.
- Reading and updating one shoot.
- Archiving and restoring a shoot.
- Managing shot-list items, equipment and schedule entries.
- Updating delivery requirements.
- Creating, reading and revoking a client summary link.

API failures must use a consistent error shape containing a stable code, human-readable message and optional field details.

## 15. Required product states

The application must provide designed and testable states for:

- Initial loading
- Empty dashboard
- Populated dashboard
- Form validation errors
- Save in progress
- Save failure with retry
- Successful save
- Archived shoot
- Revoked or invalid client link
- Unauthorised access
- Offline or unreachable API

## 16. Acceptance criteria

The MVP workspace is ready for implementation when:

- Product scope and exclusions are represented in the roadmap.
- The primary user journey is documented as a demo flow.
- Security, accessibility and privacy requirements appear in the review standard.
- Current implementation state is recorded without exaggeration.
- Unresolved authentication and retention decisions are clearly listed.
- Work is divided into small, ordered, reviewable tickets.

The product MVP is complete when:

- A photographer can create and save a shoot with all required information.
- Suggested shot-list and equipment templates are added without removing custom work.
- The photographer can manage the schedule and delivery checklist.
- Preparation progress is accurate.
- A revocable client summary exposes only approved client-facing information.
- Relevant automated checks pass.
- The complete primary flow is verified at desktop and mobile widths.
- Console and network errors are inspected.
- Security and accessibility requirements receive human review.

## 17. Risks

- The planning form could become too long for mobile users.
- Client summary links could expose private information if response filtering is incorrect.
- Starter templates may be too generic for professional photographers.
- Authentication could expand the MVP if selected too early.
- Progress calculations may become unclear if optional sections are treated as required.

## 18. Unresolved decisions

- Authentication provider and session strategy.
- Exact data-retention period.
- Whether visual references are URLs only or uploaded files.
- Whether reusable equipment defaults belong in the MVP's first implementation slice.

These decisions must remain unresolved until explicitly approved. They must not be silently inferred during workspace setup.

## 19. Human-owned decisions

- Authentication and production access policy.
- Data-retention and privacy policy.
- Production deployment.
- Use of real client data.
- Final approval of the client-summary information boundary.
