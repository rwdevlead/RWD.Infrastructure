---
name: create-pr
description: Prepare a Pull Request or Merge Request with a structured description, push the branch, and create the PR via gh (when available) or provide a pre-filled server link for review. Trigger with "/create-pr" or "/pr".
argument-hint: "[optional base branch, defaults to main]"
---

# Purpose

Assemble a complete Pull Request (GitHub) or Merge Request (GitLab / Bitbucket / Azure DevOps) using standard git commands and the GitHub CLI (`gh`) when available. The skill inspects diffs, validates quality gates, builds a per-commit changelog for squash-merge preservation, pushes the branch, opens the PR via `gh pr create` (or generates a pre-filled comparison link if `gh` is unavailable), and hands off to the developer on the server UI for final review and merge.

---

## Step 1 — Inspect Git State & Diff

1. **Verify Branch:**
   - Confirm current working branch is not the base branch (`main` or specified argument). If on `main`, stop: PRs/MRs must originate from a dedicated feature or topic branch.
   - Check `git status` for uncommitted changes. If unstaged changes exist, advise running `/commit-cleanup` before proceeding.
2. **Inspect Commit History & Diff:**
   - Identify base branch (defaults to `main` or `origin/main`).
   - Fetch latest base branch state:
     ```bash
     git fetch origin main --quiet
     ```
   - Run `git log <base>..HEAD --oneline` to review all branch commits.
   - Run `git diff --stat <base>..HEAD` to review modified files and impact scope.

---

## Step 2 — Pre-PR Quality Gates

Check compliance with `.agents/standards/git-and-pr-standards.md`:
- **Tests & Linter:** Verify tests pass and code lints with zero errors.
- **Hygiene:** Confirm temporary debug code and commented-out code were removed.
- **Memory & Docs:** Ensure `.agents/memory/AI_HANDOFF.md` is updated and documentation reflects code changes.
- **Branch Up to Date:** Check if branch is rebased or updated against latest base branch.

---

## Step 3 — Draft Pull / Merge Request Content

Using `.agents/templates/pull-request-template.md`:
- **PR / MR Title:** Formulate a Conventional Commit title matching the primary change (e.g., `feat(skills): add create-pr skill`).
- **Summary:** Write 1-3 direct sentences summarizing what this change introduces and why.
- **Related Issues:** Note issue numbers if applicable.
- **What's New:** List new files, features, or capabilities introduced in this PR.
- **What Changed:** List modifications to existing files, logic, or behavior.
- **Commits (Squash-Merge Changelog):** List every commit on the branch in chronological order. This section is **required** because squash merges collapse the branch into a single commit, and the PR body becomes the permanent record. Angular versioning tools (`standard-version`, `semantic-release`) parse the squashed body for `feat:`, `fix:`, and `BREAKING CHANGE:` tokens to determine version bumps.
  Format each line as:
  ```markdown
  - `<short-hash>` <type>(<scope>): <subject>
  ```
  Example:
  ```markdown
  ## Commits
  - `ec1277e` feat(skills): add branch guard, push choice, and server completion gates
  - `72245ee` feat(templates): add github pr template and gfm list formatting
  - `8ade219` docs(skills): require commit and pr links as last lines of output
  ```
- **Verification & Testing:** Include test commands executed and verification results.
- **Checklist:** Check off completed items.

---

## Step 4 — Summary & Push Confirmation Gate

Before running any push commands, present a clean summary plan:

```markdown
### 🚀 Pull Request Plan
- **Source Branch:** `<feature-branch>`
- **Target Branch:** `<base-branch>`
- **Commits:** <count> commits to merge
- **Diff Scope:** <count> files modified

#### Proposed PR Title
<type>(<scope>): <concise subject>

#### Proposed Description Preview
<Markdown body following pull-request-template.md>
```

> **MANDATORY GATE:** Stop and ask the user for confirmation. Do NOT execute `git push` or `gh pr create` until the user explicitly confirms (e.g. "yes" or "proceed").

---

## Step 5 — Git Push, PR Creation (`gh` or Fallback Link), & Server Completion

Only after user confirmation:
1. **Push Branch via Git:** If upstream is unlinked or branch has unpushed commits:
   ```bash
   git push -u origin <current-branch>
   ```
2. **Create Pull Request via `gh` (Preferred on GitHub) or Generate Pre-Populated Link (Fallback):**
   - **Step 2a — Check If `gh` Is Installed (`command -v gh`):**
     First check whether `gh` is installed on the host. If `gh` is **not installed** (or the remote is a non-GitHub host), skip `gh` authentication checks and proceed directly to **Option B (Fallback Pre-Populated Server Link)**.
   - **Step 2b — Check `gh` Authentication (`gh auth status`):**
     Only when `gh` **is installed** and the repository remote is GitHub, verify authentication status via `gh auth status` before calling any `gh pr` subcommand. If `gh` is not logged in or the token has expired, stop and prompt the user so they have the opportunity to authenticate first (e.g., `gh auth login`) before continuing, or ask if they prefer the fallback comparison link.
   - **Option A — GitHub CLI (`gh`) Installed & Authenticated:**
     Once `command -v gh` and `gh auth status` both succeed, create or update the Pull Request directly using `gh`:
     ```bash
     gh pr create --base <base> --head <branch> --title "<title>" --body-file <temp_body_file>
     ```
     *(If a PR already exists for the branch, update it with `gh pr edit --title "<title>" --body-file <temp_body_file>` and retrieve its URL via `gh pr view --json url -q .url`).*
   - **Option B — Fallback Pre-Populated Server Link:**
     If `gh` is not installed, the user chooses not to log in to `gh`, or the remote is a non-GitHub host (GitLab, Bitbucket, Azure DevOps), URL-encode `title` and `body` parameters into the comparison URL:
     `https://github.com/<owner>/<repo>/compare/<base>...<branch>?expand=1&title=<encoded_title>&body=<encoded_body>`
     *(This guarantees GitHub pre-populates the exact Conventional Commit title and full Markdown body for multi-commit branches and before templates are merged to default branch).*
   - **Link Styling:** Always mask URLs behind clean Markdown anchor text. Never output raw percent-encoded strings.
3. **Require Server-Side Completion:**
   - Explicitly instruct the user to complete the review and merge on the server:
     > *"Branch pushed and PR/MR ready. Please open the link below to review diffs and complete the merge on the server."*
   - The AI agent must **never** auto-merge the branch locally or run `gh pr merge`.
4. **Memory Update:** Update `AI_HANDOFF.md` recording that the PR/MR was created/prepared and branch pushed.
5. **Execution Link Rule:** ONLY at the conclusion of this PR/MR execution step (and never during planning, reviews, or general conversation), output clean Markdown links as the very last lines:
   - **Single-commit branches:** Show both the commit link and the PR link.
   - **Multi-commit branches:** Show only the PR link (the PR itself lists all commits).
   - When created via `gh`:
     ```markdown
     👉 **[View Pull Request #<number> on GitHub](https://github.com/<owner>/<repo>/pull/<number>)**
     ```
   - When using the fallback comparison URL:
     ```markdown
     👉 **[Create Pull Request on GitHub](https://github.com/<owner>/<repo>/compare/<base>...<branch>?expand=1&title=...&body=...)**
     ```
