---
name: refactor-code
description: Perform controlled code refactoring to improve maintainability, readability, and separation of concerns without altering public behavior or introducing new features. Trigger with "/refactor-code".
argument-hint: "[file, module, or function to refactor]"
---

# Purpose

The `/refactor-code` skill performs safe, controlled code refactoring for **RWD.Infrastructure**. It focuses on improving maintainability, reducing cognitive complexity, and eliminating technical debt without altering public API contracts or introducing unrequested features.

---

## Step 1 — Scope & Contract Verification

1. **Identify Refactoring Target**:
   - Inspect the file, module, or function specified in the command argument.
   - If un-argumented, inspect modified files in git status or ask the user to specify the target.

2. **Verify Public Contracts & Tests**:
   - Locate existing unit tests and test suites covering the target code.
   - Identify public function signatures, exported APIs, and interface contracts.
   - Rule: **Do not alter public API signatures or behavior unless explicitly requested.**

---

## Step 2 — Refactoring Execution

Apply targeted, high-leverage refactoring patterns:

- **Reduce Complexity:** Extract deeply nested logic into private helper functions.
- **Eliminate Duplication:** Consolidate redundant logic and repetitive conditionals.
- **Improve Naming:** Rename cryptic variables, parameters, and functions to be self-documenting.
- **Decouple Dependencies:** Align implementation with clean architecture standards in `.agents/standards/coding-standards.md`.
- **Preserve Behavior:** Ensure error handling and edge case behavior remain identical to the original implementation.

---

## Step 3 — Verification & Memory Update

1. **Run Test Suites**:
   - Execute unit tests and build checks to verify zero regressions.
2. **Document Architectural Changes**:
   - If the refactor introduces structural changes, record them in `.agents/memory/PROJECT_CONTEXT.md`.
3. **Summary**:
   - Provide a concise summary of files refactored, improvements made, and test results.
