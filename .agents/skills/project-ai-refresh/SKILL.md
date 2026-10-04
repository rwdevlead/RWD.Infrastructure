---
name: project-ai-refresh
description: Refresh a target repository's project-owned AI instructions, memory, decisions, and handoffs after shared .agents standards, templates, or skills change. Use this when the user says the AI library changed or asks the project AI to reread and adjust.
argument-hint: "[changed standards, templates, skills, or refresh scope]"
---

# Project AI Refresh Skill

Use this skill when the user says shared `.agents` guidance was modified or new `.agents` files were added and the target repository should reread them and adjust its project AI files.

This skill synchronizes project AI guidance with the current framework while preserving verified project-specific facts.

## Required References

Before making changes, read:

- Root `AGENTS.md`, if present
- `.agents/standards/memory-policy.md`
- `.agents/standards/documentation-standards.md`
- `.agents/standards/code-documentation-standards.md`
- `.agents/standards/coding-standards.md`
- `.agents/standards/workflow-standards.md`
- `.agents/templates/context-template.md`
- `.agents/templates/handoff-template.md`
- `.agents/skills/project-ai-refresh/checklist.md`

Read changed or newly added `.agents/standards/*`, `.agents/templates/*`, and `.agents/skills/*` files relevant to the refresh request.

## Required Workflow

Follow these phases in order.

### Phase 1: Identify Refresh Scope

Determine why refresh is needed:

- New standard added
- Existing standard changed
- Template changed
- Skill changed
- Root project instructions are missing or stale
- Context or handoff files need alignment

If the user names changed files, start there. Otherwise, inspect the current `.agents` framework and project AI files.

### Phase 2: Read Current Project AI State

Inspect:

- Root `AGENTS.md`
- `.agents/memory/PROJECT_CONTEXT.md`
- `.agents/memory/AI_HANDOFF.md`, when active handoff exists
- Related repository docs if referenced by the project AI files

Treat repository source, tests, configuration, and current standards as more authoritative than old memory or handoff files.

### Phase 3: Compare Against Current Framework

Identify:

- Missing mandatory standard references
- Stale template language
- Contradictions between root `AGENTS.md` and `.agents/` standards
- Memory entries that are stale, duplicated, or no longer sourced
- Handoffs that should be updated or marked stale

Do not rewrite valid project-specific facts simply because wording differs from the template.

### Phase 4: Apply Targeted Updates

Make the smallest useful updates:

- Add missing references to new standards.
- Update stale guidance caused by changed standards or templates.
- Preserve verified project-specific instructions.
- Add durable facts to `.agents/memory/PROJECT_CONTEXT.md` when discovered during refresh.
- Update `.agents/memory/AI_HANDOFF.md` only when active continuation state changes.

Do not recreate files wholesale unless the existing file is only a placeholder or clearly obsolete.

### Phase 5: Validate

Validate:

- Updated project AI files point to existing standards, templates, and skills.
- Project-specific facts remain grounded in repository files.
- Stale or uncertain information is marked clearly.
- No secrets or machine-specific private paths were added.
- Markdown remains readable.

### Phase 6: Report

End with a concise report:

- Changed or added files
- Shared guidance that triggered the refresh
- Project AI instructions updated
- Memory entries updated
- Handoffs updated or left unchanged
- Validation performed
- Remaining user decisions, if any

## Stop Conditions

Stop and ask the user before proceeding when:

- Current project guidance intentionally conflicts with the updated shared framework.
- The refresh would require deleting or replacing substantial project-specific instructions.
- A memory update cannot be verified and would materially affect future AI behavior.
- Sensitive information appears in existing memory or handoffs and removal policy is unclear.

When stopping, provide options and identify the files involved.

## Success Criteria

The task is complete only when:

- Current `.agents` framework files were read.
- Current project AI files were inspected.
- Needed project AI files were updated narrowly.
- Durable memory was handled according to standard.
- Stale handoff content was updated or called out.
- Validation was performed and reported.
