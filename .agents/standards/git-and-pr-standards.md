# Git and Pull Request Standards — RWD.Infrastructure

This document establishes the git branching, commit messaging, and pull request (PR) standards for developers and AI agents working on RWD.Infrastructure.

---

## 1. Branch Naming Conventions

All branches should use short, descriptive names prefixed by the change type. Use lowercase letters, numbers, and hyphens. Avoid underscores and spaces.

| Prefix | Purpose | Example |
| :--- | :--- | :--- |
| `feature/` | New features, capabilities, or major assets | `feature/add-pr-skill` |
| `fix/` | Bug fixes, edge case corrections, or patch updates | `fix/broken-link-linter` |
| `docs/` | Documentation, comments, or guide updates | `docs/update-readme` |
| `refactor/` | Code refactoring without behavior changes | `refactor/split-helpers` |
| `chore/` | Tooling, build scripts, or dependency updates | `chore/update-linter` |
| `test/` | Adding, updating, or fixing tests | `test/add-template-tests` |

If tracking an issue or ticket number, include it after the prefix: `feature/42-pr-template`.

### Branch Protection: Never Commit Directly to Main
The `main` (or `master`) branch is the protected base branch. 
- **Direct Commits Prohibited:** AI agents and developers must never commit directly to `main`.
- **Automatic Branch Creation:** If work begins on `main`, the agent must inspect changes, suggest an appropriate branch name (e.g. `feature/<topic>` or `fix/<topic>`), and switch branches (`git checkout -b <branch-name>`) before staging or committing.

---

## 2. Commit Message Standards

Commits must follow the **Conventional Commits** specification. This keeps git history readable and automated tooling reliable.

### Format
```text
<type>(<optional scope>): <short description>

[optional body explaining motivation, context, and rationale]

[optional footer(s) for breaking changes or ticket links]
```

### Commit Types
- `feat`: A new feature or capability.
- `fix`: A bug fix.
- `docs`: Documentation-only changes.
- `refactor`: Code change that neither fixes a bug nor adds a feature.
- `perf`: Performance improvement.
- `test`: Adding or correcting tests.
- `chore`: Tooling, configs, or maintenance tasks.
- `build`: Build system or external dependency changes.
- `ci`: CI configuration files or script changes.

### Subject Line Rules
- Use imperative mood: write `add feature`, not `added feature` or `adds feature`.
- Start with lowercase letter after the colon.
- Do not put a period at the end.
- Keep the subject line under 72 characters.

### Body & Footer Rules
- Separate the subject from the body with one blank line.
- Focus the body on *why* the change was made, not just *what* changed.
- Write in plain words. Keep sentences short and clear.
- Note breaking changes with `BREAKING CHANGE: <explanation>` in the footer.
- Reference issues in the footer: `Closes #123` or `Fixes #456`.

### Atomic Commits
- Keep commits focused on a single logical change.
- Do not mix refactoring with new feature code in one commit.
- Keep code clean before committing: no leftover debug logging or dead code.

### Push Preferences: Remote Push vs. Leave Local
When executing a commit, the agent must ask the user their push preference:
- **Option 1: Commit and Push:** Run `git commit` and immediately push upstream (`git push -u origin <branch>`).
- **Option 2: Commit Local Only:** Run `git commit` and leave the commit local on the current branch. This allows batching multiple commits before sharing.

---

## 3. Pull Request (PR) & Merge Request (MR) Standards

Pull requests (GitHub) and Merge requests (GitLab / Bitbucket / Azure DevOps) are the primary gate for merging changes into the base branch (`main`).

### Scope Control
- Keep pull requests small and focused.
- Target fewer than 400 lines of changed code where practical. Smaller PRs are reviewed faster and with fewer mistakes.
- Break large features into sequential, reviewable pull requests.

### PR / MR Title
- Follow the Conventional Commits format, matching the primary commit type:
  `feat(skills): add create-pr skill and pr template`

### PR / MR Description
- Use `.agents/templates/pull-request-template.md` for all pull requests and merge requests.
- Provide clear context: what is new, what changed, why it changed, and how it was tested.
- Include links to related issues or requirements.

### Squash-Merge Commit Log Requirement
When PRs are squash-merged, the branch is collapsed into a single commit and the PR body becomes the permanent git history. To preserve individual commit context and support Angular versioning tools:
- The PR description **must** include a `## Commits` section listing every commit on the branch.
- Format each line as: `- \`<short-hash>\` <type>(<scope>): <subject>`
- This ensures `standard-version` and `semantic-release` can parse `feat:`, `fix:`, and `BREAKING CHANGE:` tokens from the squashed commit body to determine version bumps.

### Pre-PR Quality Gates
Before opening or requesting review on a pull request, ensure:
1. **Tests Pass:** All unit and integration tests pass cleanly.
2. **Lint & Build:** Zero linter errors and zero build warnings.
3. **Clean Code:** All temporary print statements, debug logging, and commented-out code are removed.
4. **Memory & Docs:** `.agents/memory/AI_HANDOFF.md` is up-to-date, and relevant READMEs or documentation files are synchronized.
5. **Up-to-Date Branch:** Branch is rebased or updated against latest base branch (`main`).

### Pure Git & Server-Side Completion Requirement
- **Pure Git Execution:** Use standard `git` commands (`git push -u origin <branch>`) rather than platform-specific CLI tools (`gh`, `glab`).
- **Direct Creation Links:** The agent provides the direct web comparison/creation link for GitHub or GitLab based on the remote URL.
- **Human Server Completion:** The agent must **never** auto-merge or complete the PR/MR. The PR/MR remains open for the developer or reviewer to inspect, review, and complete on the remote server UI.

### Final Link Placement Standard
- **Execution Scoping:** Direct links to commits and PRs/MRs must **only** be output at the conclusion of actual commit/push or PR preparation execution events (`/commit-cleanup` and `/create-pr`).
- **Do Not Output During Inquiries/Planning:** Never output commit or PR links during planning phases, reviews, question answers, or general conversation.
- **Clean Markdown Anchors:** Always format links as clean Markdown hyperlinks with clear labels (e.g. `🔗 [View Commit 8ade219 on GitHub](url)` or `👉 [Create Pull Request on GitHub](url)`). Never output raw unformatted URLs or percent-encoded URL walls.
- **Placement:** When an execution step concludes, place these formatted links as the **very last lines** of the output response.



