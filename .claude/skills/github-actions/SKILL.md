# GitHub Actions for Claude Code

Reusable GitHub Actions workflows that integrate Claude Code into your CI/CD pipeline.

## How It Works

These are **reusable workflows** (using GitHub's `workflow_call` trigger). You don't copy them—you **call them** from your own repository using a simple caller workflow:

```yaml
# In YOUR repository: .github/workflows/claude-pr-review.yml
jobs:
  review:
    uses: aviadr1/claude-code-showcase/.github/workflows/showcase-pr-review.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

**Quick setup:** Run `/setup-github-actions` in Claude Code to interactively create caller workflows.

---

## Workflow Compatibility

| Workflow | Stack | Notes |
|----------|-------|-------|
| [PR Review](#1-pr-review) | **Any** | Language-agnostic, uses git only |
| [Docs Sync](#2-documentation-sync) | **Any** | Language-agnostic, uses git only |
| [Code Quality](#3-code-quality-review) | **Node.js** | Requires npm, configurable lint command |
| [Dependency Audit](#4-dependency-audit) | **Node.js** | Requires npm for dependency management |

---

## Generic Workflows (Any Stack)

### 1. PR Review (`showcase-pr-review.yml`)

**Stack: Any** - Uses only git commands, works with any language.

Automatically reviews pull requests using Claude Code.

**Triggers on:**
- Pull request opened/synchronized
- Issue comments mentioning `@claude`

**Usage:**
```yaml
name: Claude PR Review

on:
  pull_request:
  issue_comment:
    types: [created]

jobs:
  review:
    uses: aviadr1/claude-code-showcase/.github/workflows/showcase-pr-review.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    with:
      model: 'opus'           # Optional, auto-updates to latest Opus
      timeout_minutes: 30     # Optional
```

**Inputs:**
| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `model` | string | `opus` | Claude model alias (`opus`, `sonnet`, `haiku`) |
| `timeout_minutes` | number | `30` | Timeout in minutes |
| `review_prompt` | string | (built-in) | Custom review prompt |

---

### 2. Documentation Sync (`showcase-docs-sync.yml`)

**Stack: Any** - Uses only git commands, works with any language.

Periodically checks if documentation is out of sync with code changes.

**Usage:**
```yaml
name: Monthly Docs Sync

on:
  schedule:
    - cron: '0 9 1 * *'  # 1st of each month
  workflow_dispatch:

jobs:
  sync:
    uses: aviadr1/claude-code-showcase/.github/workflows/showcase-docs-sync.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    with:
      days_back: 30
      code_patterns: '*.py *.go *.rs'  # Customize for your stack
      docs_paths: 'docs/ README.md'
```

**Inputs:**
| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `model` | string | `opus` | Claude model alias |
| `timeout_minutes` | number | `60` | Timeout |
| `days_back` | number | `30` | Days to look back for changes |
| `base_branch` | string | `main` | Base branch for PRs |
| `code_patterns` | string | `*.ts *.tsx *.js *.jsx` | File patterns to check (customize for your stack) |
| `docs_paths` | string | `docs/ README.md` | Documentation paths |
| `custom_prompt` | string | (built-in) | Custom prompt |

**Stack-specific `code_patterns` examples:**
- **Python**: `*.py`
- **Go**: `*.go`
- **Rust**: `*.rs`
- **Java**: `*.java`
- **Ruby**: `*.rb`

---

## Node.js Workflows

### 3. Code Quality Review (`showcase-nodejs-code-quality.yml`)

**Stack: Node.js** - Requires `npm` and a `package.json` with lint scripts.

Periodically reviews random directories for code quality issues and creates fix PRs.

**Requirements:**
- Node.js project with `package.json`
- Lint script defined (e.g., `npm run lint`)

**Usage:**
```yaml
name: Weekly Code Quality

on:
  schedule:
    - cron: '0 8 * * 0'  # Every Sunday
  workflow_dispatch:

jobs:
  quality:
    uses: aviadr1/claude-code-showcase/.github/workflows/showcase-nodejs-code-quality.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    with:
      num_dirs: 3
      source_dir: 'src'
      file_extensions: '.ts .tsx'
      lint_command: 'npm run lint'
```

**Inputs:**
| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `model` | string | `opus` | Claude model alias |
| `timeout_minutes` | number | `45` | Timeout per directory |
| `num_dirs` | number | `3` | Directories to review |
| `source_dir` | string | `src` | Source directory |
| `base_branch` | string | `main` | Base branch for PRs |
| `file_extensions` | string | `.ts .tsx` | Extensions to review |
| `lint_command` | string | `npm run lint` | Lint command |
| `review_checklist_path` | string | `.claude/agents/code-reviewer.md` | Checklist path |
| `custom_prompt` | string | (built-in) | Custom prompt |

---

### 4. Dependency Audit (`showcase-nodejs-dependency-audit.yml`)

**Stack: Node.js** - Requires `npm` for dependency management.

Periodically audits dependencies for updates and security vulnerabilities.

**Requirements:**
- Node.js project with `package.json` and `package-lock.json`
- Test script defined (e.g., `npm test`)

**Usage:**
```yaml
name: Bi-weekly Dependency Audit

on:
  schedule:
    - cron: '0 10 1,15 * *'  # 1st and 15th
  workflow_dispatch:

jobs:
  audit:
    uses: aviadr1/claude-code-showcase/.github/workflows/showcase-nodejs-dependency-audit.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    with:
      node_version: '20'
      lint_command: 'npm run lint'
      test_command: 'npm test'
```

**Inputs:**
| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `model` | string | `opus` | Claude model alias |
| `timeout_minutes` | number | `45` | Timeout |
| `base_branch` | string | `main` | Base branch for PRs |
| `node_version` | string | `20` | Node.js version |
| `lint_command` | string | `npm run lint` | Lint command |
| `test_command` | string | `npm test` | Test command |
| `custom_prompt` | string | (built-in) | Custom prompt |

---

## Adapting for Other Stacks

### Python Projects

The Node.js workflows can be adapted for Python. Here's a guide:

**Code Quality (Python adaptation):**
```yaml
# Create your own workflow based on showcase-nodejs-code-quality.yml
# Replace npm steps with:
- name: Setup Python
  uses: actions/setup-python@v5
  with:
    python-version: '3.11'

- name: Install dependencies
  run: pip install -r requirements.txt

# Change lint_command to: 'ruff check .' or 'flake8'
```

**Dependency Audit (Python adaptation):**
```yaml
# Use pip-audit instead of npm audit
- name: Check dependencies
  run: |
    pip install pip-audit
    pip-audit --json > /tmp/audit.json
```

### Go Projects

**Code Quality (Go adaptation):**
```yaml
- name: Setup Go
  uses: actions/setup-go@v5
  with:
    go-version: '1.21'

# Change lint_command to: 'golangci-lint run'
# Change file_extensions to: '.go'
```

### Rust Projects

**Code Quality (Rust adaptation):**
```yaml
- name: Setup Rust
  uses: actions-rust-lang/setup-rust-toolchain@v1

# Change lint_command to: 'cargo clippy -- -D warnings'
# Change file_extensions to: '.rs'
```

---

## Setup Requirements

### 1. Add Anthropic API Key

Add `ANTHROPIC_API_KEY` to your repository secrets:
1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `ANTHROPIC_API_KEY`
4. Value: Your Anthropic API key

### 2. Configure Permissions

Ensure your workflow has appropriate permissions:
```yaml
permissions:
  contents: write       # For creating branches
  pull-requests: write  # For creating PRs
  issues: read          # For reading issue comments (PR review)
```

### 3. Allow Workflow Calls (for reusable workflows)

If your repository is private, you may need to allow workflow calls from other repositories in Settings → Actions → General.

---

## Model Aliases

All workflows use auto-updating model aliases:

| Alias | Description |
|-------|-------------|
| `opus` | Latest Claude Opus (best for complex analysis) |
| `sonnet` | Latest Claude Sonnet (balanced speed/quality) |
| `haiku` | Latest Claude Haiku (fastest, most economical) |

---

## Quick Start

Run `/setup-github-actions` to interactively set up these workflows in your repository.

---

## Best Practices

1. **Start with PR Review** - Works with any stack, immediate value
2. **Use generic workflows first** - PR Review and Docs Sync work everywhere
3. **Customize `code_patterns`** - Match your project's file extensions
4. **Fork for other stacks** - Use Node.js workflows as templates for Python/Go/Rust
5. **Set appropriate timeouts** - Complex codebases may need longer timeouts
