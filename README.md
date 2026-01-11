# Claude Code Project Configuration Showcase

> **Install any of these skills, agents, commands, and hooks directly into your projects:**
> ```
> /plugin marketplace add aviadr1/claude-code-showcase
> /plugin install testing-patterns@claude-code-showcase
> ```
> See [Plugin Marketplace](#plugin-marketplace) for all available plugins.

---

> Most software engineers are seriously sleeping on how good LLM agents are right now, especially something like Claude Code.

Once you've got Claude Code set up, you can point it at your codebase, have it learn your conventions, pull in best practices, and refine everything until it's basically operating like a super-powered teammate. **The real unlock is building a solid set of reusable "[skills](#skills---domain-knowledge)" plus a few "[agents](#agents---specialized-assistants)" for the stuff you do all the time.**

### What This Looks Like in Practice

**Custom UI Library?** We have a [skill that explains exactly how to use it](.claude/skills/core-components/SKILL.md). Same for [how we write tests](.claude/skills/testing-patterns/SKILL.md), [how we structure GraphQL](.claude/skills/graphql-schema/SKILL.md), and basically how we want everything done in our repo. So when Claude generates code, it already matches our patterns and standards out of the box.

**Automated Quality Gates?** We use [hooks](.claude/settings.json) to auto-format code, run tests when test files change, type-check TypeScript, and even [block edits on the main branch](.claude/settings.md). Claude Code also created a bunch of ESLint automation, including custom rules and lint checks that catch issues before they hit review.

**Deep Code Review?** We have a [code review agent](.claude/agents/code-reviewer.md) that Claude runs after changes are made. It follows a detailed checklist covering TypeScript strict mode, error handling, loading states, mutation patterns, and more. When a PR goes up, we have a [GitHub Action](.github/workflows/pr-claude-code-review.yml) that does a full PR review automatically.

**Scheduled Maintenance?** We've got GitHub workflow agents that run on a schedule:
- [Monthly docs sync](.github/workflows/scheduled-claude-code-docs-sync.yml) - Reads commits from the last month and makes sure docs are still aligned
- [Weekly code quality](.github/workflows/scheduled-claude-code-quality.yml) - Reviews random directories and auto-fixes issues
- [Biweekly dependency audit](.github/workflows/scheduled-claude-code-dependency-audit.yml) - Safe dependency updates with test verification

**Intelligent Skill Suggestions?** We built a [skill evaluation system](#skill-evaluation-hooks) that analyzes every prompt and automatically suggests which skills Claude should activate based on keywords, file paths, and intent patterns.

A ton of maintenance and quality work is just... automated. It runs ridiculously smoothly.

**JIRA/Linear Integration?** We connect Claude Code to our ticket system via [MCP servers](.mcp.json). Now Claude can read the ticket, understand the requirements, implement the feature, update the ticket status, and even create new tickets if it finds bugs along the way. The [`/ticket` command](.claude/commands/ticket.md) handles the entire workflow—from reading acceptance criteria to linking the PR back to the ticket.

We even use Claude Code for ticket triage. It reads the ticket, digs into the codebase, and leaves a comment with what it thinks should be done. So when an engineer picks it up, they're basically starting halfway through already.

**There is so much low-hanging fruit here that it honestly blows my mind people aren't all over it.**

---

## Table of Contents

- [Directory Structure](#directory-structure)
- [Quick Start](#quick-start)
- [Configuration Reference](#configuration-reference)
  - [CLAUDE.md - Project Memory](#claudemd---project-memory)
  - [settings.json - Hooks & Environment](#settingsjson---hooks--environment)
  - [MCP Servers - External Integrations](#mcp-servers---external-integrations)
  - [LSP Servers - Real-Time Code Intelligence](#lsp-servers---real-time-code-intelligence)
  - [Skill Evaluation Hooks](#skill-evaluation-hooks)
  - [Skills - Domain Knowledge](#skills---domain-knowledge)
  - [Agents - Specialized Assistants](#agents---specialized-assistants)
  - [Commands - Slash Commands](#commands---slash-commands)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Best Practices](#best-practices)
- [Examples in This Repository](#examples-in-this-repository)
- [Plugin Marketplace](#plugin-marketplace)

---

## Plugin Marketplace

This repository is also a **Claude Code plugin marketplace**. You can install individual components directly into your projects.

### Quick Install

```bash
# Add this marketplace to Claude Code
/plugin marketplace add aviadr1/claude-code-showcase

# Browse available plugins
/plugin

# Install specific plugins
/plugin install testing-patterns@claude-code-showcase
/plugin install code-review-suite@claude-code-showcase
/plugin install pr-toolkit@claude-code-showcase
```

### Available Plugins

| Plugin | Type | Description |
|--------|------|-------------|
| `testing-patterns` | Skill | Jest testing, factory functions, TDD workflow |
| `systematic-debugging` | Skill | Four-phase debugging methodology |
| `react-ui-patterns` | Skill | Loading states, error handling, data fetching |
| `formik-patterns` | Skill | Form handling and validation |
| `graphql-schema` | Skill | GraphQL queries, mutations, codegen |
| `core-components` | Skill | Design system and component library |
| `pr-toolkit` | Bundle | `/pr-review`, `/pr-summary` + github-workflow agent |
| `code-review-suite` | Bundle | code-reviewer agent + `/code-quality` command |
| `ticket-workflow` | Bundle | `/ticket` + `/onboard` commands |
| `docs-sync` | Command | Documentation synchronization |
| `skill-activation` | Hook | Intelligent skill suggestions |
| `plugin-marketplace` | Skill | Create marketplaces using symlinks |

### Architecture

This marketplace uses **symlinks** to maintain a single source of truth:

```
.claude/                    # Source of truth (showcase)
├── skills/testing-patterns/
└── commands/pr-review.md

plugins/                    # Plugin packages (symlinks)
└── testing-patterns/
    └── skills/testing-patterns/  → symlink to .claude/skills/testing-patterns
```

Updates to `.claude/` automatically flow to the plugins. See the [plugin-marketplace skill](.claude/skills/plugin-marketplace/SKILL.md) for details on this pattern.

---

## Directory Structure

```
your-project/
├── CLAUDE.md                      # Project memory (alternative location)
├── .mcp.json                      # MCP server configuration (JIRA, GitHub, etc.)
├── .claude/
│   ├── settings.json              # Hooks, environment, permissions
│   ├── settings.local.json        # Personal overrides (gitignored)
│   ├── settings.md                # Human-readable hook documentation
│   ├── .gitignore                 # Ignore local/personal files
│   │
│   ├── agents/                    # Custom AI agents
│   │   └── code-reviewer.md       # Proactive code review agent
│   │
│   ├── commands/                  # Slash commands (/command-name)
│   │   ├── onboard.md             # Deep task exploration
│   │   ├── pr-review.md           # PR review workflow
│   │   └── ...
│   │
│   ├── hooks/                     # Hook scripts
│   │   ├── skill-eval.sh          # Skill matching on prompt submit
│   │   ├── skill-eval.js          # Node.js skill matching engine
│   │   └── skill-rules.json       # Pattern matching configuration
│   │
│   ├── skills/                    # Domain knowledge documents
│   │   ├── README.md              # Skills overview
│   │   ├── testing-patterns/
│   │   │   └── SKILL.md
│   │   ├── graphql-schema/
│   │   │   └── SKILL.md
│   │   └── ...
│   │
│   └── rules/                     # Modular instructions (optional)
│       ├── code-style.md
│       └── security.md
│
└── .github/
    └── workflows/
        ├── pr-claude-code-review.yml           # Auto PR review
        ├── scheduled-claude-code-docs-sync.yml # Monthly docs sync
        ├── scheduled-claude-code-quality.yml   # Weekly quality review
        └── scheduled-claude-code-dependency-audit.yml
```

---

## Quick Start

### 1. Create the `.claude` directory

```bash
mkdir -p .claude/{agents,commands,hooks,skills}
```

### 2. Add a CLAUDE.md file

Create `CLAUDE.md` in your project root with your project's key information. See [CLAUDE.md](CLAUDE.md) for a complete example.

```markdown
# Project Name

## Quick Facts
- **Stack**: React, TypeScript, Node.js
- **Test Command**: `npm run test`
- **Lint Command**: `npm run lint`

## Key Directories
- `src/components/` - React components
- `src/api/` - API layer
- `tests/` - Test files

## Code Style
- TypeScript strict mode
- Prefer interfaces over types
- No `any` - use `unknown`
```

### 3. Add settings.json with hooks

Create `.claude/settings.json`. See [settings.json](.claude/settings.json) for a full example with auto-formatting, testing, and more.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "[ \"$(git branch --show-current)\" != \"main\" ] || { echo '{\"block\": true, \"message\": \"Cannot edit on main branch\"}' >&2; exit 2; }",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### 4. Add your first skill

Create `.claude/skills/testing-patterns/SKILL.md`. See [testing-patterns/SKILL.md](.claude/skills/testing-patterns/SKILL.md) for a comprehensive example.

```markdown
---
name: testing-patterns
description: Jest testing patterns for this project. Use when writing tests, creating mocks, or following TDD workflow.
---

# Testing Patterns

## Test Structure
- Use `describe` blocks for grouping
- Use `it` for individual tests
- Follow AAA pattern: Arrange, Act, Assert

## Mocking
- Use factory functions: `getMockUser(overrides)`
- Mock external dependencies, not internal modules
```

> **Tip:** The `description` field is critical—Claude uses it to decide when to apply the skill. Include keywords users would naturally mention.

---

## Configuration Reference

### CLAUDE.md - Project Memory

CLAUDE.md is Claude's persistent memory that loads automatically at session start.

**Locations (in order of precedence):**
1. `.claude/CLAUDE.md` (project, in .claude folder)
2. `./CLAUDE.md` (project root)
3. `~/.claude/CLAUDE.md` (user-level, all projects)

**What to include:**
- Project stack and architecture overview
- Key commands (test, build, lint, deploy)
- Code style guidelines
- Important directories and their purposes
- Critical rules and constraints

**📄 Example:** [CLAUDE.md](CLAUDE.md)

---

### settings.json - Hooks & Environment

The main configuration file for hooks, environment variables, and permissions.

**Location:** `.claude/settings.json`

**📄 Example:** [settings.json](.claude/settings.json) | [Human-readable docs](.claude/settings.md)

#### Hook Events

| Event | When It Fires | Use Case |
|-------|---------------|----------|
| `PreToolUse` | Before tool execution | Block edits on main, validate commands |
| `PostToolUse` | After tool completes | Auto-format, run tests, lint |
| `UserPromptSubmit` | User submits prompt | Add context, suggest skills |
| `Stop` | Agent finishes | Decide if Claude should continue |

#### Hook Response Format

```json
{
  "block": true,           // Block the action (PreToolUse only)
  "message": "Reason",     // Message to show user
  "feedback": "Info",      // Non-blocking feedback
  "suppressOutput": true,  // Hide command output
  "continue": false        // Whether to continue
}
```

#### Exit Codes
- `0` - Success
- `2` - Blocking error (PreToolUse only, blocks the tool)
- Other - Non-blocking error

---

### MCP Servers - External Integrations

MCP (Model Context Protocol) servers let Claude Code connect to external tools like JIRA, GitHub, Slack, databases, and more. This is how you enable workflows like "read a ticket, implement it, and update the ticket status."

**Location:** `.mcp.json` (project root, committed to git for team sharing)

**📄 Example:** [.mcp.json](.mcp.json)

#### How MCP Works

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Claude Code   │────▶│   MCP Server    │────▶│  External API   │
│                 │◀────│  (local bridge) │◀────│  (JIRA, GitHub) │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

MCP servers run locally and provide Claude with tools to interact with external services. When you configure a JIRA MCP server, Claude gets tools like `jira_get_issue`, `jira_update_issue`, `jira_create_issue`, etc.

#### .mcp.json Format

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-name"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

**Fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `type` | Yes | Server type: `stdio` (local process) or `http` (remote) |
| `command` | For stdio | Executable to run (e.g., `npx`, `python`) |
| `args` | No | Command-line arguments |
| `env` | No | Environment variables (supports `${VAR}` expansion) |
| `url` | For http | Remote server URL |
| `headers` | For http | HTTP headers for authentication |

#### Example: JIRA Integration

```json
{
  "mcpServers": {
    "jira": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-jira"],
      "env": {
        "JIRA_HOST": "${JIRA_HOST}",
        "JIRA_EMAIL": "${JIRA_EMAIL}",
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
      }
    }
  }
}
```

**What this enables:**
- Read ticket details, acceptance criteria, and comments
- Update ticket status (To Do → In Progress → In Review)
- Add comments with progress updates
- Create new tickets for bugs found during development
- Link PRs to tickets

**Example workflow with [`/ticket` command](.claude/commands/ticket.md):**
```
You: /ticket PROJ-123

Claude:
1. Fetching PROJ-123 from JIRA...
   "Add user profile avatar upload"

2. Reading acceptance criteria...
   - Upload button on profile page
   - Support JPG/PNG up to 5MB
   - Show loading state

3. Searching codebase for related files...
   Found: src/screens/Profile/ProfileScreen.tsx

4. Creating branch: cw/PROJ-123-avatar-upload

5. [Implements feature...]

6. Updating JIRA status to "In Review"
   Adding comment: "PR #456 ready for review"

7. Creating PR linked to PROJ-123...
```

#### Common MCP Server Configurations

**Issue Tracking:**
```json
{
  "jira": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-jira"],
    "env": {
      "JIRA_HOST": "${JIRA_HOST}",
      "JIRA_EMAIL": "${JIRA_EMAIL}",
      "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
    }
  },
  "linear": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-linear"],
    "env": { "LINEAR_API_KEY": "${LINEAR_API_KEY}" }
  }
}
```

**Code & DevOps:**
```json
{
  "github": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-github"],
    "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
  },
  "sentry": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-sentry"],
    "env": {
      "SENTRY_AUTH_TOKEN": "${SENTRY_AUTH_TOKEN}",
      "SENTRY_ORG": "${SENTRY_ORG}"
    }
  }
}
```

**Communication:**
```json
{
  "slack": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-slack"],
    "env": {
      "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
      "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
    }
  }
}
```

**Databases:**
```json
{
  "postgres": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-postgres"],
    "env": { "DATABASE_URL": "${DATABASE_URL}" }
  }
}
```

#### Environment Variables

MCP configs support variable expansion:
- `${VAR}` - Expands to environment variable (fails if not set)
- `${VAR:-default}` - Uses default if VAR is not set

Set these in your shell profile or `.env` file (don't commit secrets!):
```bash
export JIRA_HOST="https://yourcompany.atlassian.net"
export JIRA_EMAIL="you@company.com"
export JIRA_API_TOKEN="your-api-token"
```

#### Settings for MCP

In `settings.json`, you can auto-approve MCP servers:

```json
{
  "enableAllProjectMcpServers": true
}
```

Or approve specific servers:
```json
{
  "enabledMcpjsonServers": ["jira", "github", "slack"]
}
```

---

### LSP Servers - Real-Time Code Intelligence

LSP (Language Server Protocol) gives Claude real-time understanding of your code—type information, errors, completions, and navigation. Instead of just reading text, Claude can "see" your code the way your IDE does.

**Why this matters:** When you edit TypeScript, Claude immediately knows if you introduced a type error. When you reference a function, Claude can jump to its definition. This dramatically improves code generation quality.

#### Enabling LSP

LSP support is enabled through plugins in `settings.json`:

```json
{
  "enabledPlugins": {
    "typescript-lsp@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true
  }
}
```

#### What Claude Gets from LSP

| Feature | Description |
|---------|-------------|
| **Diagnostics** | Real-time errors and warnings after every edit |
| **Type Information** | Hover info, function signatures, type definitions |
| **Code Navigation** | Go to definition, find references |
| **Completions** | Context-aware symbol suggestions |

#### Available LSP Plugins

| Plugin | Language | Install Binary First |
|--------|----------|---------------------|
| `typescript-lsp` | TypeScript/JavaScript | `npm install -g typescript-language-server typescript` |
| `pyright-lsp` | Python | `pip install pyright` |
| `rust-lsp` | Rust | `rustup component add rust-analyzer` |

#### Custom LSP Configuration

For advanced setups, create `.lsp.json`:

```json
{
  "typescript": {
    "command": "typescript-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".ts": "typescript",
      ".tsx": "typescriptreact"
    },
    "initializationOptions": {
      "preferences": {
        "quotePreference": "single"
      }
    }
  }
}
```

#### Troubleshooting

If LSP isn't working:

1. **Check binary is installed:**
   ```bash
   which typescript-language-server  # Should return a path
   ```

2. **Enable debug logging:**
   ```bash
   claude --enable-lsp-logging
   ```

3. **Check plugin status:**
   ```bash
   claude /plugin  # View Errors tab
   ```

---

### Skill Evaluation Hooks

One of our most powerful automations is the **skill evaluation system**. It runs on every prompt submission and intelligently suggests which skills Claude should activate.

**📄 Files:** [skill-eval.sh](.claude/hooks/skill-eval.sh) | [skill-eval.js](.claude/hooks/skill-eval.js) | [skill-rules.json](.claude/hooks/skill-rules.json)

#### How It Works

When you submit a prompt, the `UserPromptSubmit` hook triggers our skill evaluation engine:

1. **Prompt Analysis** - The engine analyzes your prompt for:
   - **Keywords**: Simple word matching (`test`, `form`, `graphql`, `bug`)
   - **Patterns**: Regex matching (`\btest(?:s|ing)?\b`, `\.stories\.`)
   - **File Paths**: Extracts mentioned files (`src/components/Button.tsx`)
   - **Intent**: Detects what you're trying to do (`create.*test`, `fix.*bug`)

2. **Directory Mapping** - File paths are mapped to relevant skills:
   ```json
   {
     "src/components/core": "core-components",
     "src/graphql": "graphql-schema",
     ".github/workflows": "github-actions",
     "src/hooks": "react-ui-patterns"
   }
   ```

3. **Confidence Scoring** - Each trigger type has a point value:
   ```json
   {
     "keyword": 2,
     "keywordPattern": 3,
     "pathPattern": 4,
     "directoryMatch": 5,
     "intentPattern": 4
   }
   ```

4. **Skill Suggestion** - Skills exceeding the confidence threshold are suggested with reasons:
   ```
   SKILL ACTIVATION REQUIRED

   Detected file paths: src/components/UserForm.tsx

   Matched skills (ranked by relevance):
   1. formik-patterns (HIGH confidence)
      Matched: keyword "form", path "src/components/UserForm.tsx"
   2. react-ui-patterns (MEDIUM confidence)
      Matched: directory mapping, keyword "component"
   ```

#### Configuration

Skills are defined in [skill-rules.json](.claude/hooks/skill-rules.json):

```json
{
  "testing-patterns": {
    "description": "Jest testing patterns and TDD workflow",
    "priority": 9,
    "triggers": {
      "keywords": ["test", "jest", "spec", "tdd", "mock"],
      "keywordPatterns": ["\\btest(?:s|ing)?\\b", "\\bspec\\b"],
      "pathPatterns": ["**/*.test.ts", "**/*.test.tsx"],
      "intentPatterns": [
        "(?:write|add|create|fix).*(?:test|spec)",
        "(?:test|spec).*(?:for|of|the)"
      ]
    },
    "excludePatterns": ["e2e", "maestro", "end-to-end"]
  }
}
```

#### Adding to Your Project

1. Copy the hooks to your project:
   ```bash
   cp -r .claude/hooks/ your-project/.claude/hooks/
   ```

2. Add the hook to your `settings.json`:
   ```json
   {
     "hooks": {
       "UserPromptSubmit": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/skill-eval.sh",
               "timeout": 5
             }
           ]
         }
       ]
     }
   }
   ```

3. Customize [skill-rules.json](.claude/hooks/skill-rules.json) with your project's skills and triggers.

---

### Skills - Domain Knowledge

Skills are markdown documents that teach Claude project-specific patterns and conventions.

**Location:** `.claude/skills/{skill-name}/SKILL.md`

**📄 Examples:**
- [testing-patterns](.claude/skills/testing-patterns/SKILL.md) - TDD, factory functions, mocking
- [systematic-debugging](.claude/skills/systematic-debugging/SKILL.md) - Four-phase debugging methodology
- [react-ui-patterns](.claude/skills/react-ui-patterns/SKILL.md) - Loading states, error handling
- [graphql-schema](.claude/skills/graphql-schema/SKILL.md) - Queries, mutations, codegen
- [core-components](.claude/skills/core-components/SKILL.md) - Design system, tokens
- [formik-patterns](.claude/skills/formik-patterns/SKILL.md) - Form handling, validation

#### SKILL.md Frontmatter Fields

| Field | Required | Max Length | Description |
|-------|----------|------------|-------------|
| `name` | **Yes** | 64 chars | Lowercase letters, numbers, and hyphens only. Should match directory name. |
| `description` | **Yes** | 1024 chars | What the skill does and when to use it. Claude uses this to decide when to apply the skill. |
| `allowed-tools` | No | - | Comma-separated list of tools Claude can use (e.g., `Read, Grep, Bash(npm:*)`). |
| `model` | No | - | Specific model to use (e.g., `claude-sonnet-4-20250514`). |

#### SKILL.md Format

```markdown
---
name: skill-name
description: What this skill does and when to use it. Include keywords users would mention.
allowed-tools: Read, Grep, Glob
model: claude-sonnet-4-20250514
---

# Skill Title

## When to Use
- Trigger condition 1
- Trigger condition 2

## Core Patterns

### Pattern Name
```typescript
// Example code
```

## Anti-Patterns

### What NOT to Do
```typescript
// Bad example
```

## Integration
- Related skill: `other-skill`
```

#### Best Practices for Skills

1. **Keep SKILL.md focused** - Under 500 lines; put detailed docs in separate referenced files
2. **Write trigger-rich descriptions** - Claude uses semantic matching on descriptions to decide when to apply skills
3. **Include examples** - Show both good and bad patterns with code
4. **Reference other skills** - Show how skills work together
5. **Use exact filename** - Must be `SKILL.md` (case-sensitive)

---

### Agents - Specialized Assistants

Agents are AI assistants with focused purposes and their own prompts.

**Location:** `.claude/agents/{agent-name}.md`

**📄 Examples:**
- [code-reviewer.md](.claude/agents/code-reviewer.md) - Comprehensive code review with checklist
- [github-workflow.md](.claude/agents/github-workflow.md) - Git commits, branches, PRs

#### Agent Format

```markdown
---
name: code-reviewer
description: Reviews code for quality, security, and conventions. Use after writing or modifying code.
model: opus
---

# Agent System Prompt

You are a senior code reviewer...

## Your Process
1. Run `git diff` to see changes
2. Apply review checklist
3. Provide feedback

## Checklist
- [ ] No TypeScript `any`
- [ ] Error handling present
- [ ] Tests included
```

#### Agent Configuration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Lowercase with hyphens |
| `description` | Yes | When/why to use (max 1024 chars) |
| `model` | No | `sonnet`, `opus`, or `haiku` |
| `tools` | No | Comma-separated tool list |

---

### Commands - Slash Commands

Custom commands invoked with `/command-name`.

**Location:** `.claude/commands/{command-name}.md`

**📄 Examples:**
- [onboard.md](.claude/commands/onboard.md) - Deep task exploration
- [pr-review.md](.claude/commands/pr-review.md) - PR review workflow
- [pr-summary.md](.claude/commands/pr-summary.md) - Generate PR description
- [code-quality.md](.claude/commands/code-quality.md) - Quality checks
- [docs-sync.md](.claude/commands/docs-sync.md) - Documentation alignment

#### Command Format

```markdown
---
description: Brief description shown in command list
allowed-tools: Bash(git:*), Read, Grep
---

# Command Instructions

Your task is to: $ARGUMENTS

## Steps
1. Do this first
2. Then do this
```

#### Variables

- `$ARGUMENTS` - All arguments as single string
- `$1`, `$2`, `$3` - Individual positional arguments

#### Inline Bash

```markdown
Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
```

---

## GitHub Actions Workflows

Automate code review, quality checks, and maintenance with Claude Code.

**📄 Examples:**
- [pr-claude-code-review.yml](.github/workflows/pr-claude-code-review.yml) - Auto PR review
- [scheduled-claude-code-docs-sync.yml](.github/workflows/scheduled-claude-code-docs-sync.yml) - Monthly docs sync
- [scheduled-claude-code-quality.yml](.github/workflows/scheduled-claude-code-quality.yml) - Weekly quality review
- [scheduled-claude-code-dependency-audit.yml](.github/workflows/scheduled-claude-code-dependency-audit.yml) - Biweekly dependency updates

### PR Code Review

Automatically reviews PRs and responds to `@claude` mentions.

```yaml
name: PR - Claude Code Review
on:
  pull_request:
    types: [opened, synchronize, reopened]
  issue_comment:
    types: [created]

jobs:
  review:
    if: |
      github.event_name == 'pull_request' ||
      (github.event_name == 'issue_comment' &&
       github.event.issue.pull_request &&
       contains(github.event.comment.body, '@claude'))
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: anthropics/claude-code-action@beta
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          model: claude-opus-4-5-20251101
          prompt: |
            Review this PR using .claude/agents/code-reviewer.md standards.
            Run `git diff origin/main...HEAD` to see changes.
```

### Scheduled Workflows

| Workflow | Schedule | Purpose |
|----------|----------|---------|
| [Code Quality](.github/workflows/scheduled-claude-code-quality.yml) | Weekly (Sunday) | Reviews random directories, auto-fixes issues |
| [Docs Sync](.github/workflows/scheduled-claude-code-docs-sync.yml) | Monthly (1st) | Ensures docs align with code changes |
| [Dependency Audit](.github/workflows/scheduled-claude-code-dependency-audit.yml) | Biweekly (1st & 15th) | Safe dependency updates with testing |

### Setup Required

Add `ANTHROPIC_API_KEY` to your repository secrets:
- Settings → Secrets and variables → Actions → New repository secret

### Cost Estimate

| Workflow | Frequency | Est. Cost |
|----------|-----------|-----------|
| PR Review | Per PR | ~$0.05 - $0.50 |
| Docs Sync | Monthly | ~$0.50 - $2.00 |
| Dependency Audit | Biweekly | ~$0.20 - $1.00 |
| Code Quality | Weekly | ~$1.00 - $5.00 |

**Estimated monthly total:** ~$10 - $50 (depending on PR volume)

---

## Best Practices

### 1. Start with CLAUDE.md

Your `CLAUDE.md` is the foundation. Include:
- Stack overview
- Key commands
- Critical rules
- Directory structure

### 2. Build Skills Incrementally

Don't try to document everything at once:
1. Start with your most common patterns
2. Add skills as pain points emerge
3. Keep each skill focused on one domain

### 3. Use Hooks for Automation

Let hooks handle repetitive tasks:
- Auto-format on save
- Run tests when test files change
- Regenerate types when schemas change
- Block edits on protected branches

### 4. Create Agents for Complex Workflows

Agents are great for:
- Code review (with your team's checklist)
- PR creation and management
- Debugging workflows
- Onboarding to tasks

### 5. Leverage GitHub Actions

Automate maintenance:
- PR reviews on every PR
- Weekly quality sweeps
- Monthly docs alignment
- Dependency updates

### 6. Version Control Your Config

Commit everything except:
- `settings.local.json` (personal preferences)
- `CLAUDE.local.md` (personal notes)
- User-specific credentials

---

## Examples in This Repository

| File | Description |
|------|-------------|
| [CLAUDE.md](CLAUDE.md) | Example project memory file |
| [.claude/settings.json](.claude/settings.json) | Full hooks configuration |
| [.claude/settings.md](.claude/settings.md) | Human-readable hooks documentation |
| [.mcp.json](.mcp.json) | MCP server configuration (JIRA, GitHub, Slack, etc.) |
| **Agents** | |
| [.claude/agents/code-reviewer.md](.claude/agents/code-reviewer.md) | Comprehensive code review agent |
| [.claude/agents/github-workflow.md](.claude/agents/github-workflow.md) | Git workflow agent |
| **Commands** | |
| [.claude/commands/onboard.md](.claude/commands/onboard.md) | Deep task exploration |
| [.claude/commands/ticket.md](.claude/commands/ticket.md) | **JIRA/Linear ticket workflow (read → implement → update)** |
| [.claude/commands/pr-review.md](.claude/commands/pr-review.md) | PR review workflow |
| [.claude/commands/pr-summary.md](.claude/commands/pr-summary.md) | Generate PR summary |
| [.claude/commands/code-quality.md](.claude/commands/code-quality.md) | Quality checks |
| [.claude/commands/docs-sync.md](.claude/commands/docs-sync.md) | Documentation sync |
| **Hooks** | |
| [.claude/hooks/skill-eval.sh](.claude/hooks/skill-eval.sh) | Skill evaluation wrapper |
| [.claude/hooks/skill-eval.js](.claude/hooks/skill-eval.js) | Node.js skill matching engine |
| [.claude/hooks/skill-rules.json](.claude/hooks/skill-rules.json) | Pattern matching rules |
| **Skills** | |
| [.claude/skills/testing-patterns/SKILL.md](.claude/skills/testing-patterns/SKILL.md) | TDD, factory functions, mocking |
| [.claude/skills/systematic-debugging/SKILL.md](.claude/skills/systematic-debugging/SKILL.md) | Four-phase debugging |
| [.claude/skills/react-ui-patterns/SKILL.md](.claude/skills/react-ui-patterns/SKILL.md) | Loading/error/empty states |
| [.claude/skills/graphql-schema/SKILL.md](.claude/skills/graphql-schema/SKILL.md) | Queries, mutations, codegen |
| [.claude/skills/core-components/SKILL.md](.claude/skills/core-components/SKILL.md) | Design system, tokens |
| [.claude/skills/formik-patterns/SKILL.md](.claude/skills/formik-patterns/SKILL.md) | Form handling, validation |
| **GitHub Workflows** | |
| [.github/workflows/pr-claude-code-review.yml](.github/workflows/pr-claude-code-review.yml) | Auto PR review |
| [.github/workflows/scheduled-claude-code-docs-sync.yml](.github/workflows/scheduled-claude-code-docs-sync.yml) | Monthly docs sync |
| [.github/workflows/scheduled-claude-code-quality.yml](.github/workflows/scheduled-claude-code-quality.yml) | Weekly quality review |
| [.github/workflows/scheduled-claude-code-dependency-audit.yml](.github/workflows/scheduled-claude-code-dependency-audit.yml) | Biweekly dependency audit |

---

## Learn More

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code Action](https://github.com/anthropics/claude-code-action) - GitHub Action
- [Anthropic API](https://docs.anthropic.com/en/api)

---

## License

MIT - Use this as a template for your own projects.
