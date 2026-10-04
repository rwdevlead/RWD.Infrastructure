# Workflow Standards — RWD.Infrastructure

This document defines the core software development lifecycle (SDLC) and workflow standards for developers and AI agents working on **RWD.Infrastructure**.

---

## 1. Five-Phase Development Lifecycle

All task execution and feature development MUST follow this 5-phase lifecycle:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ 1. Orient    │ ──> │ 2. Plan      │ ──> │ 3. Implement │ ──> │ 4. Verify    │ ──> │ 5. Hand Off  │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
```

### Phase 1: Orientation
Before writing or modifying code, inspect repository state:
1. Read root `AGENTS.md`.
2. Read `.agents/memory/PROJECT_CONTEXT.md` for project architecture and technology stack context.
3. Read `.agents/memory/AI_HANDOFF.md` for current session status and active tasks.
4. Review applicable files in `.agents/standards/` (e.g. `coding-standards.md`, `code-documentation-standards.md`).

### Phase 2: Planning & Alignment
1. Formulate a step-by-step implementation plan. For non-trivial tasks, use `.agents/templates/plan-template.md`.
2. Ensure task boundaries are clear (in-scope vs out-of-scope).
3. If requirements are ambiguous, clarify design decisions before writing code.
4. **Questions vs. Directives:** Answer questions and propose next actions; do not make file edits on questions alone.

### Phase 3: Implementation
1. Perform minimal invasive changes to fulfill requirements.
2. Follow existing code style, architecture, and design patterns.
3. Keep edits atomic and focused. Do not refactor code outside the scope of the instruction without asking permission.

### Phase 4: Empirical Verification
1. **Never declare success without empirical evidence** when implementing functional changes.
2. Run automated test suites, build checks, and linters. Skip running full builds and unit tests if changes are strictly limited to comments or documentation.
3. Verify that zero regressions were introduced.

### Phase 5: Handoff & Memory Sync
1. Update `.agents/memory/AI_HANDOFF.md` with progress, completed tasks, and immediate next steps.
2. If new canonical decisions or milestones were established, record them in `.agents/memory/PROJECT_CONTEXT.md`.
3. Provide a concise summary of changes and open items.

---

## 2. Git & Branching Conventions

Follow `.agents/standards/git-and-pr-standards.md` for full git and pull/merge request workflows.
- **Branch Protection:**
  - Never commit directly to `main` or `master`. Always work on a dedicated topic branch.
  - If work begins on `main`, inspect changes and switch to a new branch (`git checkout -b <branch-name>`) before staging or committing.
- **Branch Naming:**
  - Features: `feature/<short-description>`
  - Bug Fixes: `fix/<short-description>`
  - Refactoring: `refactor/<short-description>`
  - Documentation: `docs/<short-description>`
  - Maintenance: `chore/<short-description>`
- **Commit Messages & Push Choice:**
  - Follow Conventional Commits via `.agents/templates/commit-template.md`.
  - Use clear, imperative style: `feat: add user authentication handler` or `fix: resolve null dereference in parser`.
  - Choose push preference during commit: push immediately to remote branch or leave local.
- **Pull Requests & Merge Requests:**
  - Run `/commit-cleanup` before committing to ensure clean code, branch guards, and memory synchronization.
  - Run `/create-pr` to validate quality gates, push the branch, and generate the PR/MR package with direct server links. Complete and merge on the server.

---

## 3. Definition of Done (DoD)

A task or feature is considered **Done** only when:
- [ ] Code builds cleanly with no errors.
- [ ] Automated tests pass.
- [ ] Existing codebase conventions and documentation standards are followed.
- [ ] Project documentation and `.agents/memory/` files are updated.
- [ ] No temporary files or debug artifacts are left behind.
