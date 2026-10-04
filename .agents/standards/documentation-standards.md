# Documentation Standards & README Policy — RWD.Infrastructure

Documentation is a required deliverable. Code or feature changes are incomplete until related documentation is updated.

---

## 1. Core Principles

- **Documentation Evolves with Code:** Update documentation in the same change set as code modifications.
- **Explain Why & How:** Focus on intent, architecture decisions, and business context, not just restating obvious code.
- **High Signal-to-Noise:** Keep documentation concise, actionable, and token-efficient.
- **Zero Stale Documentation:** Remove or archive obsolete guides immediately.

---

## 2. README Ownership & Maintenance

**Every repository must maintain a current root `README.md`.**

### Update Triggers
Update the root `README.md` whenever changes affect:
- Setup, installation, or configuration
- Environment variables or dependencies
- Architecture, public APIs, or database schemas
- Development, testing, or deployment procedures

---

## 3. Documentation Workflow

Before considering any task complete:
1. Identify all affected documentation (root `README.md`, API docs, user guides).
2. Update affected documentation in the same change set.
3. Record significant updates in `.agents/memory/PROJECT_CONTEXT.md` and active session state in `.agents/memory/AI_HANDOFF.md`.
