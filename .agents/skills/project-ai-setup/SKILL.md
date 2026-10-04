---
name: project-ai-setup
description: Initialize a target repository for project-owned AI instructions, memory, decisions, and handoffs using the shared .agents framework. Use this when a repository needs a root AGENTS.md, .agents/memory/PROJECT_CONTEXT.md, or .agents/memory/AI_HANDOFF.md.
argument-hint: "[target repository setup scope or notes]"
---

# Project AI Setup Skill

Use this skill when the user asks to set up a repository so AI agents can read and use project-owned `.agents` guidance, memory, decisions, and handoffs.

This skill creates the initial project AI operating surface. It must inspect the repository before writing project-specific facts.

## Required References

Before making changes, read:

- `AGENTS.md` (root, if present)
- `.agents/standards/memory-policy.md`
- `.agents/standards/documentation-standards.md`
- `.agents/standards/code-documentation-standards.md`
- `.agents/standards/coding-standards.md`
- `.agents/standards/workflow-standards.md`
- `.agents/templates/context-template.md`
- `.agents/templates/handoff-template.md`
- `.agents/skills/project-ai-setup/checklist.md`

## Required Workflow

Follow these phases in order.

### Phase 1: Discover Repository

Inspect repository files before writing:

- Existing root `AGENTS.md`
- Existing `.agents/` directory structure
- `README.md`
- Solution, project, package, or manifest files
- Source and test folders
- CI and build/test configuration

Do not infer durable facts from naming alone when repository files can verify them.

### Phase 2: Determine Needed Files

Decide which files are missing or stale:

- Root `AGENTS.md`
- `.agents/memory/PROJECT_CONTEXT.md`
- `.agents/memory/AI_HANDOFF.md` (only if active session continuation state exists)

Create only the files needed for the requested setup.

### Phase 3: Create Or Update Root Instructions

Create or update root `AGENTS.md` using standard RWD.Ai.Stack agent guidance principles.

Replace placeholders with verified project facts.

Keep root `AGENTS.md` concise and project-specific. It should tell future AI agents:

- What the repository is
- Where source, tests, and entry points live
- Which commands and conventions are verified
- Which `.agents/standards/` are mandatory
- How to use project memory (`.agents/memory/`)

If an existing root `AGENTS.md` is present, preserve valid project-specific guidance and merge in missing shared-framework requirements.

### Phase 4: Create Or Update Project Context Memory

Use `.agents/templates/context-template.md` for `.agents/memory/PROJECT_CONTEXT.md`.

Record only durable verified facts:

- Project Overview & Purpose
- Technical Stack & Dependencies
- Architecture & Core Patterns
- Domain & Data Concepts
- Constraints & Non-Goals
- Architecture & Milestone Log

Put unverified items under `Assumptions To Verify`.

Do not store secrets, credentials, tokens, personal preferences, chat transcript content, or temporary task state.

### Phase 5: Create Active Handoff (If Applicable)

Use `.agents/templates/handoff-template.md` for `.agents/memory/AI_HANDOFF.md` only if active continuation state remains after setup.

Do not create a handoff for completed, self-contained setup tasks.

### Phase 6: Validate

Validate:

- File references are accurate.
- Markdown formatting is clean and readable.
- Root `AGENTS.md` and `.agents/` rules do not contradict each other.
- Context entries distinguish verified facts from assumptions.
- No secrets or machine-specific private paths were added.

### Phase 7: Report

End with a concise report:

- Files created or updated
- Durable facts recorded
- Assumptions requiring verification
- Validation performed
- Recommended next step

## Stop Conditions

Stop and ask the user before proceeding when:

- Existing project instructions conflict with the shared framework and the correct behavior is unclear.
- A durable fact cannot be verified but would materially affect setup.
- A requested memory entry would include sensitive information.

When stopping, provide the smallest useful set of options.

## Success Criteria

The task is complete only when:

- The repository was inspected.
- Required project AI files were created or updated.
- Root `AGENTS.md` is project-specific and references `.agents/` standards.
- Project memory contains only durable verified facts or clearly marked assumptions.
- Validation was performed and reported.
