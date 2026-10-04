# Memory Update Policy

This policy governs when and how AI agents must update project memory files (`PROJECT_CONTEXT.md` and `AI_HANDOFF.md`).

---

## 1. Active Session Handoff (`AI_HANDOFF.md`)

`AI_HANDOFF.md` tracks short-term, active session state.

### When to Update:
- **End of Session / Handoff:** Whenever the user triggers `/handoff`, ends a development session, or switches models.
- **Task Status Change:** Whenever an active task changes status (`Pending` ➔ `In Progress` ➔ `Complete` or `Blocked`).
- **Before Context Reset:** Prior to clearing the context window (`/clear` or session reset).

### What to Update:
- Update the **Active Tasks** table.
- Record bullet points under **Recent Progress**.
- Define the single **Immediate Next Action** for context restoration.

---

## 2. Long-Term Project Context (`PROJECT_CONTEXT.md`)

`PROJECT_CONTEXT.md` tracks persistent, long-term project facts and architectural decisions.

### When to Update:
- **Architectural Decisions:** When a structural, design, or framework decision is finalized (e.g. choosing a database, folder conventions, core abstractions).
- **Tech Stack Changes:** When new core dependencies, frameworks, or tools are added or changed.
- **Domain & Business Rules:** When core entities, data models, or non-negotiable business rules are established.
- **Milestone Completion:** When a major feature or project milestone is completed.

### What NOT to Update:
- Do **not** update long-term context for minor bug fixes, refactoring tweaks, or routine code formatting.
- Do **not** duplicate style rules that belong in `standards/coding-standards.md`.
- Do **not** record temporary session notes (those belong in `AI_HANDOFF.md`).

### Update Procedure:
1. Update the affected section(s) in `PROJECT_CONTEXT.md` (e.g., Stack, Architecture, Domain Concepts).
2. Append a dated entry under `## 6. Architecture & Milestone Log` (format: `YYYY-MM-DD: Description of change`).
