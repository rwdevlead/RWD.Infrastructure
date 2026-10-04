# Project AI Setup Checklist

Use this checklist with `.agents/skills/project-ai-setup/SKILL.md`.

## Repository Discovery

- Read root `AGENTS.md`, if present.
- Read `.agents/AGENTS.md` or `.agents/README.md`.
- Read root `README.md`, if present.
- Identify source folders.
- Identify test folders.
- Identify solution, project, package, or manifest files.
- Identify build, test, package, deploy, or local service command surfaces.
- Identify existing project memory or handoff files.

## Root AGENTS.md

- Replace placeholders with verified repository facts.
- Preserve existing valid project-specific guidance.
- Include required `.agents/standards/*` references.
- Include project memory expectations (`.agents/memory/`).
- Avoid duplicating full standards content.

## Project Context Memory

- Create `.agents/memory/PROJECT_CONTEXT.md` from `.agents/templates/context-template.md` when missing.
- Record verified durable facts only.
- Include file paths and line numbers when available.
- Put uncertain items under `Assumptions To Verify`.
- Remove or update stale memory when found.

## Active Handoff

- Create `.agents/memory/AI_HANDOFF.md` using `.agents/templates/handoff-template.md` only when active continuation state is needed.
- Do not create handoffs for small completed setup work.

## Safety

- Do not add secrets, credentials, tokens, API keys, regulated data, personal preferences, or machine-specific private paths.
- Do not invent project facts.
- Do not rewrite unrelated documentation.

## Validation

- Check changed Markdown for readable formatting.
- Check file references.
- Report anything that could not be validated.
