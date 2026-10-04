# Project AI Refresh Checklist

Use this checklist with `.agents/skills/project-ai-refresh/SKILL.md`.

## Refresh Scope

- Identify changed or newly added `.agents` standards.
- Identify changed or newly added `.agents` templates.
- Identify changed or newly added `.agents` skills.
- Identify project files that consume the changed guidance.

## Current Project AI Files

- Read root `AGENTS.md`, if present.
- Read `.agents/memory/PROJECT_CONTEXT.md`, if present.
- Read `.agents/memory/AI_HANDOFF.md`, if present.

## Comparison

- Check for missing required standard references.
- Check for stale template wording.
- Check for broken paths.
- Check for contradictions between project instructions and framework instructions.
- Check whether memory entries are still accurate.
- Check whether handoffs need updates because continuation state changed.

## Update Rules

- Preserve verified project-specific guidance.
- Update only guidance affected by the changed framework files.
- Keep root `AGENTS.md` concise.
- Keep `.agents/memory/PROJECT_CONTEXT.md` factual and durable.
- Keep handoffs short and tied to active continuation state.
- Avoid unrelated documentation rewrites.

## Safety

- Do not invent project facts.
- Do not remove project-specific instructions unless they are stale or contradicted by repository reality.
- Do not store secrets, credentials, tokens, API keys, regulated data, personal preferences, or machine-specific private paths.

## Validation

- Verify referenced standards, templates, and skills exist.
- Verify Markdown readability.
- Report any files intentionally left unchanged.
