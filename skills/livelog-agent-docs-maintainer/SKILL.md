---
name: livelog-agent-docs-maintainer
description: Maintain and refresh LiveLog AI agent documentation (`AGENTS.md`, `docs/project-map.md`, `docs/infrastructure-inventory.md`, and README links). Use when routes, dependencies, environment variables, CI checks, developer commands, or external-service integrations change and these docs must stay aligned with the repository.
---

# LiveLog Agent Docs Maintainer

## Overview

Keep LiveLog's AI-agent-facing documents synchronized with actual code and operations.

## Execute Workflow

1. Confirm target files.
- `AGENTS.md`
- `docs/project-map.md`
- `docs/infrastructure-inventory.md`
- `README.md`

2. Recollect facts from code before editing docs.
- Recheck routes, environment settings, initializers, and tasks.
- Recheck CI workflows and local developer commands.
- Recheck environment variables and external-service couplings.

3. Update docs with strict scope.
- Keep `AGENTS.md` short and action-oriented.
- Keep details in `docs/project-map.md` and `docs/infrastructure-inventory.md`.
- Keep README changes minimal and link-focused.
- Keep migration-target comparison out unless explicitly requested.

4. Enforce mandatory policies.
- Require explicit human approval for production/external-service changes.
- Mark side-effect tasks as opt-in only.

5. Run consistency checks and fix issues.
- `scripts/check_agent_docs.sh <repo-path>`

6. Report changes clearly.
- List files changed and why.
- List unresolved unknowns and follow-up actions.

## Resources

- Detailed checklist: `references/maintenance-checklist.md`
- Fast consistency checks: `scripts/check_agent_docs.sh`

