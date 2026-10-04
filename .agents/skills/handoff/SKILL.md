---
name: handoff
description: Synthesizes recent progress, updates active tasks, and generates a self-contained AI handoff in .agents/memory/AI_HANDOFF.md for the next session or model. Trigger with "/handoff".
argument-hint: "[optional summary notes]"
---

# Handoff Skill

## Instructions

When the user triggers `/handoff` or ends a session:

1. **Review Session Progress:**
   - Review recent user prompts, decisions, and file modifications.
   - Follow `.agents/standards/memory-policy.md`.

2. **Update Active Session Memory:**
   - Update `.agents/memory/AI_HANDOFF.md` using the 5-section handoff template (`.agents/templates/handoff-template.md`):
     - `## Current Objective`
     - `## Current Status`
     - `## Active Tasks` (Update task status: Pending, In Progress, Complete, Blocked)
     - `## Recent Progress` (Bullet points of work completed)
     - `## Immediate Next Action` (Single highest-priority next step)

3. **Confirm Handoff:**
   - Provide a concise summary to the user confirming that `.agents/memory/AI_HANDOFF.md` has been updated and is ready for the next session or AI model.
