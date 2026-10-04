# Conventional Commit Template

Use this format to craft clear, conventional commit messages.

---

## Template

```text
<type>(<scope>): <imperative subject, max 72 chars>

[Why was this change needed? Provide context, problem statement, or motivation.
Keep sentences short and clear. Use plain language.]

[What side effects, key decisions, or trade-offs occurred?]

[Optional footer(s):
BREAKING CHANGE: <explanation of breaking change>
Closes #<issue-number>
Fixes #<issue-number>]
```

---

## Allowed Types

- `feat`: Adds a new feature or asset.
- `fix`: Fixes a bug or defect.
- `docs`: Updates documentation, docstrings, or markdown files.
- `refactor`: Refactors code without changing external behavior or contracts.
- `perf`: Improves runtime performance or resource usage.
- `test`: Adds or fixes unit, integration, or regression tests.
- `chore`: Modifies build tools, packages, scripts, or housekeeping.
- `ci`: Changes CI workflows, pipelines, or automation scripts.

> **Versioning Note:** Commit types drive automated version bumps when using Angular versioning tools (`standard-version`, `semantic-release`).
> `feat` → minor version bump. `fix` → patch bump. `BREAKING CHANGE` footer → major bump.
> Other types (`docs`, `chore`, `refactor`, etc.) do not trigger a version bump on their own.

---

## Examples

### 1. Simple Single-Line Commit
```text
docs(standards): add git and pull request standards
```

### 2. Multi-Line Commit with Motivation
```text
feat(skills): add create-pr skill for github workflows

Users need an automated way to assemble pull request descriptions
matching conventional commit standards and branch diffs.

Closes #28
```

### 3. Breaking Change Commit
```text
refactor(api)!: remove deprecated auth endpoint

BREAKING CHANGE: The v1 authentication endpoint has been removed.
Use the v2 OAuth token exchange endpoint instead.
```
