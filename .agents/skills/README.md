# .agents/skills/

This directory contains executable agent skills and slash commands available for AI assistants operating on this project.

## Available Skills

- `/handoff`: Synthesizes progress and updates `.agents/memory/AI_HANDOFF.md` at session end.
- `/project-ai-setup`: Initializes target repositories with project-owned AI instructions, context, and memory.
- `/project-ai-refresh`: Refreshes target repositories after shared standards or templates change.
- `/review`: Runs a 6-viewpoint technical audit panel on code, architecture, or plans.
- `/refactor-code`: Performs controlled code refactoring without altering public behavior or contracts.
- `/generate-docs`: Synchronizes READMEs, docstrings, and API documentation with code implementation.
- `/commit-cleanup`: Performs pre-commit hygiene sweep and generates a commit readiness report.
- `/create-pr`: Prepares, validates, and creates a GitHub pull request with a compliant description.
