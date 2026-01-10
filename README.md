# claude-code-showcase (bootstrapper)

This repository is a **process + installer** you can run against an existing project to:

- **Audit** the project for Claude Code readiness (memory, hooks, commands, guardrails).
- **Implement** a minimal Claude Code “operating system” inside that project (safe, non-destructive defaults).

## Quick Start

```bash
git clone https://github.com/ChrisWiles/claude-code-showcase
cd claude-code-showcase

# Audit only (no changes)
./bin/ccs audit /path/to/your-project > audit.md

# Apply scaffold + generate project-specific CLAUDE.md
./bin/ccs apply /path/to/your-project
```

## What `apply` installs (into the target project)

Created only when missing (existing files are **never overwritten**):

- `.claude/CLAUDE.md` (generated from templates + detected tooling)
- `.claude/settings.json` (safe hooks: block edits on `main`/`master`)
- `.claude/hooks/block-main-branch.sh` (hook implementation)
- `.claude/agents/code-reviewer.md` (review checklist agent)
- `.claude/commands/code-quality.md` (typecheck→lint→test→build guidance)
- `.claude/.gitignore` (ignores local Claude settings overrides)
- `AGENTS.md` (lightweight “Act / Verify / Land” rules for agents)
- `.mcp.json` (starter MCP configuration stub)
- `.claude/ccs-audit.md` (generated audit report after applying)

## Audit Output

`./bin/ccs audit <project>` prints a Markdown report covering:

- Detected stack/tooling (Node/TS/Python/etc) and likely quality-gate commands
- Missing Claude Code surfaces (`CLAUDE.md`, `.claude/settings.json`, etc.)
- Git defaults (branch name, repo present/absent)
- Recommended next steps to tailor the config

## How to Customize (in the target project)

- Update `.claude/CLAUDE.md` with the **exact** commands your repo uses for:
  - typecheck → lint → test → build (in that order)
- Extend `.claude/settings.json` with project-specific hooks only after you confirm:
  - commands exist
  - they are fast enough to run automatically
- Add skills under `.claude/skills/*/SKILL.md` for recurring patterns.

## Non-goals / Safety

- No dependency installs.
- No schema migrations.
- No GitHub Actions added automatically (those are org-specific and may incur costs).
- Never overwrites existing files unless you explicitly remove them first.

