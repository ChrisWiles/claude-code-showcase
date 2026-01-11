---
description: Set up Claude Code GitHub Actions workflows in your repository
allowed-tools: Read, Write, Bash(mkdir:*), Bash(ls:*), AskUserQuestion
---

# Setup GitHub Actions for Claude Code

Help the user set up showcase Claude Code GitHub Actions workflows in their repository.

## Available Workflows

| Workflow | Stack | Description |
|----------|-------|-------------|
| **PR Review** | Any | Automatically review pull requests with Claude |
| **Documentation Sync** | Any | Keep docs in sync with code changes |
| **Node.js Code Quality** | Node.js | Periodic code quality audits (requires npm) |
| **Node.js Dependency Audit** | Node.js | Check for outdated/vulnerable dependencies (requires npm) |

## Your Tasks

1. **Ask which workflows to set up:**
   Use AskUserQuestion to ask which workflows they want:
   - PR Review (recommended for all projects, works with any language)
   - Documentation Sync (works with any language)
   - Node.js Code Quality (Node.js projects only)
   - Node.js Dependency Audit (Node.js projects only)

2. **Check prerequisites:**
   - Verify `.github/workflows/` directory exists (create if needed)
   - Check if ANTHROPIC_API_KEY secret reminder is needed

3. **For each selected workflow, create the caller workflow:**

### PR Review Workflow
```yaml
name: Claude PR Review

on:
  pull_request:
  issue_comment:
    types: [created]

permissions:
  contents: read
  pull-requests: write
  issues: read

jobs:
  review:
    uses: aviadr1/claude-code-showcase/.github/workflows/showcase-pr-review.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Documentation Sync Workflow
```yaml
name: Monthly Documentation Sync

on:
  schedule:
    - cron: '0 9 1 * *'
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  sync:
    uses: aviadr1/claude-code-showcase/.github/workflows/showcase-docs-sync.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Code Quality Workflow
```yaml
name: Weekly Code Quality Review

on:
  schedule:
    - cron: '0 8 * * 0'
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  quality:
    uses: aviadr1/claude-code-showcase/.github/workflows/showcase-nodejs-code-quality.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Dependency Audit Workflow
```yaml
name: Bi-weekly Dependency Audit

on:
  schedule:
    - cron: '0 10 1,15 * *'
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  audit:
    uses: aviadr1/claude-code-showcase/.github/workflows/showcase-nodejs-dependency-audit.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

4. **Remind about secrets:**
   Tell the user to add `ANTHROPIC_API_KEY` to their repository secrets:
   - Go to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `ANTHROPIC_API_KEY`
   - Value: Their Anthropic API key

5. **Offer customization:**
   Ask if they want to customize any inputs (model, timeout, schedule, etc.)

## Guidelines

- Create workflows in `.github/workflows/` directory
- Use descriptive filenames like `claude-pr-review.yml`
- Don't overwrite existing workflows without asking
- Remind about the API key secret requirement
