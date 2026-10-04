---
name: generate-docs
description: Update and synchronize project documentation, docstrings, and READMEs to reflect the current codebase implementation. Trigger with "/generate-docs".
argument-hint: "[documentation scope or component]"
---

# Purpose

The `/generate-docs` skill synchronizes project documentation, README files, API specs, and inline code comments for **RWD.Infrastructure** with the current codebase implementation.

---

## Step 1 — Implementation as Source of Truth

1. **Inspect Target Implementation**:
   - Read the source code, API signatures, export definitions, and configuration schemas.
   - Ground Rule: **The implementation is the single source of truth.** Never invent non-existent behavior or document features that are not implemented.

2. **Check Documentation Standards**:
   - Review `.agents/standards/documentation-standards.md` for Markdown formatting and structure rules.
   - Review `.agents/standards/code-documentation-standards.md` for docstring and inline comment standards.

---

## Step 2 — Update Documentation Assets

- **README Files:** Update feature lists, quickstart commands, and directory layouts to reflect current repository state.
- **Code Comments & Docstrings:** Add or update JSDoc, PyDoc, or docstrings for public classes, interfaces, and exported functions.
- **API Specs & Schemas:** Ensure parameter names, return types, and example usages are accurate.

---

## Step 3 — Verification & Links

- **Validate Markdown Syntax:** Ensure clean heading hierarchy and proper code fence language tags.
- **Check File Links:** Verify all internal file links use standard markdown syntax and valid relative paths.
- **Token Efficiency:** Keep documentation concise, scannable, and free of redundant fluff.
