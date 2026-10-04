# Coding Standards — RWD.Infrastructure

This document defines the core code quality, architecture, and implementation standards for developers and AI assistants working on **RWD.Infrastructure**.

---

## 1. Code Quality & Clean Architecture

- **Separation of Concerns:** Keep business logic, data persistence, and presentation layers clearly decoupled.
- **Single Responsibility Principle:** Functions, classes, and modules should focus on a single responsibility.
- **Minimal Complexity:** Prefer simple, readable implementations over clever or deeply nested abstractions.
- **Consistent Naming:** Use clear, descriptive variable and function names. Follow project language conventions (e.g. `camelCase`, `PascalCase`, or `snake_case`).

---

## 2. Defensive Coding & Error Handling

- **Explicit Parameter Validation:** Validate inputs at function and API boundaries.
- **No Silent Error Swallowing:** Do not wrap code in empty `try/catch` blocks or return generic fallbacks without logging or re-throwing appropriate errors.
- **Null & Boundary Safety:** Check object state and array bounds before dereferencing properties or accessing elements.

---

## 3. Targeted Edits & Preservation

- **No Collateral Damage:** Edits MUST be scoped strictly to the requested feature, bug fix, or refactor.
- **Preserve Existing Patterns:** Adopt established code style, import patterns, and file structure already present in the codebase.
- **No Unrequested Dependencies:** Do not add third-party libraries or heavy external dependencies without explicit user confirmation.

---

## 4. Testability & Empirical Verification

- **Write Testable Code:** Pure functions, dependency injection, and decoupled interfaces should be favored to ensure unit testability.
- **Verification Mandatory:** Never declare code changes complete without executing available build scripts, unit tests, and linters.
- **Regression Prevention:** Ensure existing unit test suites pass cleanly after code modifications.

---

## 5. Pre-Commit Code Hygiene

- **Remove Debug Logs:** Remove temporary `console.log`, `print()`, breakpoints, or temporary testing hooks before completing work.
- **Remove Dead Code:** Delete commented-out code blocks and unused imports/variables.
- **Documentation Alignment:** Ensure code docstrings and module documentation match implementation changes.
