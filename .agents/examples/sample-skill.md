---
name: sample-custom-skill
description: Example template demonstrating how to define custom project skills in .agents/skills/. Trigger with "/sample-custom-skill".
argument-hint: "[optional target component]"
---

# Sample Custom Skill

This reference example demonstrates how to author custom agent skills for your project in `.agents/skills/<skill-name>/SKILL.md`.

---

## Step 1 — Verify Requirements

1. Read `.agents/memory/PROJECT_CONTEXT.md` for technology stack and architectural guidelines.
2. Inspect the specified file or argument passed to the skill.

---

## Step 2 — Execution Workflow

Execute task steps in strict sequence:
1. Apply changes following project standards in `.agents/standards/`.
2. Run automated test suites to ensure zero regressions.

---

## Step 3 — Summary & Handoff

Provide a clean summary of completed actions and run `/handoff` to update `.agents/memory/AI_HANDOFF.md`.
