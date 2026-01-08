# Claude Code Project Configuration Showcase
# Claude Code 專案配置範例展示

> Most software engineers are seriously sleeping on how good LLM agents are right now, especially something like Claude Code.

> 大多數軟體工程師嚴重低估了當前 LLM 代理的強大能力，尤其是像 Claude Code 這樣的工具。

Once you've got Claude Code set up, you can point it at your codebase, have it learn your conventions, pull in best practices, and refine everything until it's basically operating like a super-powered teammate. **The real unlock is building a solid set of reusable "[skills](#skills---domain-knowledge)" plus a few "[agents](#agents---specialized-assistants)" for the stuff you do all the time.**

當您設定好 Claude Code 後，您可以將它指向您的程式碼庫，讓它學習您的慣例，引入最佳實踐，並不斷優化，直到它基本上像一個超級強大的隊友一樣運作。**真正的關鍵是建立一套堅實的可重用「[技能](#skills---domain-knowledge)」，再加上一些「[代理](#agents---specialized-assistants)」來處理您經常做的事情。**

### What This Looks Like in Practice
### 實際應用範例

**Custom UI Library?** We have a [skill that explains exactly how to use it](.claude/skills/core-components/SKILL.md). Same for [how we write tests](.claude/skills/testing-patterns/SKILL.md), [how we structure GraphQL](.claude/skills/graphql-schema/SKILL.md), and basically how we want everything done in our repo. So when Claude generates code, it already matches our patterns and standards out of the box.

**自訂 UI 函式庫？** 我們有一個[技能詳細說明如何使用它](.claude/skills/core-components/SKILL.md)。[如何撰寫測試](.claude/skills/testing-patterns/SKILL.md)、[如何組織 GraphQL](.claude/skills/graphql-schema/SKILL.md)，以及基本上我們希望在程式碼庫中如何完成所有事情，都有相應的技能。因此，當 Claude 生成程式碼時，它已經符合我們的模式和標準。

**Automated Quality Gates?** We use [hooks](.claude/settings.json) to auto-format code, run tests when test files change, type-check TypeScript, and even [block edits on the main branch](.claude/settings.md). Claude Code also created a bunch of ESLint automation, including custom rules and lint checks that catch issues before they hit review.

**自動化品質閘門？** 我們使用[鉤子](.claude/settings.json)來自動格式化程式碼，在測試檔案變更時執行測試，檢查 TypeScript 類型，甚至[阻止在主分支上進行編輯](.claude/settings.md)。Claude Code 還創建了大量 ESLint 自動化，包括自訂規則和 lint 檢查，在程式碼審查之前就能捕獲問題。

**Deep Code Review?** We have a [code review agent](.claude/agents/code-reviewer.md) that Claude runs after changes are made. It follows a detailed checklist covering TypeScript strict mode, error handling, loading states, mutation patterns, and more. When a PR goes up, we have a [GitHub Action](.github/workflows/pr-claude-code-review.yml) that does a full PR review automatically.

**深度程式碼審查？** 我們有一個[程式碼審查代理](.claude/agents/code-reviewer.md)，Claude 在進行變更後會執行它。它遵循詳細的檢查清單，涵蓋 TypeScript 嚴格模式、錯誤處理、載入狀態、mutation 模式等等。當 PR 提交時，我們有一個 [GitHub Action](.github/workflows/pr-claude-code-review.yml) 會自動進行完整的 PR 審查。

**Scheduled Maintenance?** We've got GitHub workflow agents that run on a schedule:
- [Monthly docs sync](.github/workflows/scheduled-claude-code-docs-sync.yml) - Reads commits from the last month and makes sure docs are still aligned
- [Weekly code quality](.github/workflows/scheduled-claude-code-quality.yml) - Reviews random directories and auto-fixes issues
- [Biweekly dependency audit](.github/workflows/scheduled-claude-code-dependency-audit.yml) - Safe dependency updates with test verification

**定期維護？** 我們有按計劃執行的 GitHub 工作流程代理：
- [每月文件同步](.github/workflows/scheduled-claude-code-docs-sync.yml) - 讀取上個月的提交並確保文件仍然一致
- [每週程式碼品質檢查](.github/workflows/scheduled-claude-code-quality.yml) - 審查隨機目錄並自動修復問題
- [雙週依賴審計](.github/workflows/scheduled-claude-code-dependency-audit.yml) - 透過測試驗證進行安全的依賴更新

**Intelligent Skill Suggestions?** We built a [skill evaluation system](#skill-evaluation-hooks) that analyzes every prompt and automatically suggests which skills Claude should activate based on keywords, file paths, and intent patterns.

**智慧技能建議？** 我們建立了一個[技能評估系統](#skill-evaluation-hooks)，它會分析每個提示，並根據關鍵字、檔案路徑和意圖模式自動建議 Claude 應該啟用哪些技能。

A ton of maintenance and quality work is just... automated. It runs ridiculously smoothly.

大量的維護和品質工作就這樣...自動化了。運行得非常順暢。

**JIRA/Linear Integration?** We connect Claude Code to our ticket system via [MCP servers](.mcp.json). Now Claude can read the ticket, understand the requirements, implement the feature, update the ticket status, and even create new tickets if it finds bugs along the way. The [`/ticket` command](.claude/commands/ticket.md) handles the entire workflow—from reading acceptance criteria to linking the PR back to the ticket.

**JIRA/Linear 整合？** 我們透過 [MCP 伺服器](.mcp.json)將 Claude Code 連接到我們的工單系統。現在 Claude 可以讀取工單、理解需求、實作功能、更新工單狀態，甚至在過程中發現錯誤時建立新工單。[`/ticket` 指令](.claude/commands/ticket.md)處理整個工作流程——從讀取驗收標準到將 PR 連結回工單。

We even use Claude Code for ticket triage. It reads the ticket, digs into the codebase, and leaves a comment with what it thinks should be done. So when an engineer picks it up, they're basically starting halfway through already.

我們甚至使用 Claude Code 進行工單分類。它讀取工單，深入程式碼庫，並留下註解說明它認為應該做什麼。所以當工程師接手時，他們基本上已經完成一半了。

**There is so much low-hanging fruit here that it honestly blows my mind people aren't all over it.**

**這裡有太多唾手可得的成果，說實話，人們沒有全力投入讓我感到震驚。**

---

## Table of Contents
## 目錄

- [Directory Structure](#directory-structure) / [目錄結構](#directory-structure)
- [Quick Start](#quick-start) / [快速開始](#quick-start)
- [Configuration Reference](#configuration-reference) / [配置參考](#configuration-reference)
  - [CLAUDE.md - Project Memory](#claudemd---project-memory) / [CLAUDE.md - 專案記憶](#claudemd---project-memory)
  - [settings.json - Hooks & Environment](#settingsjson---hooks--environment) / [settings.json - 鉤子與環境](#settingsjson---hooks--environment)
  - [MCP Servers - External Integrations](#mcp-servers---external-integrations) / [MCP 伺服器 - 外部整合](#mcp-servers---external-integrations)
  - [LSP Servers - Real-Time Code Intelligence](#lsp-servers---real-time-code-intelligence) / [LSP 伺服器 - 即時程式碼智能](#lsp-servers---real-time-code-intelligence)
  - [Skill Evaluation Hooks](#skill-evaluation-hooks) / [技能評估鉤子](#skill-evaluation-hooks)
  - [Skills - Domain Knowledge](#skills---domain-knowledge) / [技能 - 領域知識](#skills---domain-knowledge)
  - [Agents - Specialized Assistants](#agents---specialized-assistants) / [代理 - 專業助手](#agents---specialized-assistants)
  - [Commands - Slash Commands](#commands---slash-commands) / [指令 - 斜線指令](#commands---slash-commands)
- [GitHub Actions Workflows](#github-actions-workflows) / [GitHub Actions 工作流程](#github-actions-workflows)
- [Best Practices](#best-practices) / [最佳實踐](#best-practices)
- [Examples in This Repository](#examples-in-this-repository) / [本程式碼庫中的範例](#examples-in-this-repository)

---

## Directory Structure
## 目錄結構

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
## 快速開始

### 1. Create the `.claude` directory
### 1. 建立 `.claude` 目錄

```bash
mkdir -p .claude/{agents,commands,hooks,skills}
```

### 2. Add a CLAUDE.md file
### 2. 新增 CLAUDE.md 檔案

Create `CLAUDE.md` in your project root with your project's key information. See [CLAUDE.md](CLAUDE.md) for a complete example.

在專案根目錄建立 `CLAUDE.md`，包含專案的關鍵資訊。完整範例請參閱 [CLAUDE.md](CLAUDE.md)。

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
### 3. 新增帶有鉤子的 settings.json

Create `.claude/settings.json`. See [settings.json](.claude/settings.json) for a full example with auto-formatting, testing, and more.

建立 `.claude/settings.json`。完整範例包含自動格式化、測試等功能，請參閱 [settings.json](.claude/settings.json)。

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
### 4. 新增您的第一個技能

Create `.claude/skills/testing-patterns/SKILL.md`. See [testing-patterns/SKILL.md](.claude/skills/testing-patterns/SKILL.md) for a comprehensive example.

建立 `.claude/skills/testing-patterns/SKILL.md`。完整範例請參閱 [testing-patterns/SKILL.md](.claude/skills/testing-patterns/SKILL.md)。

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

> **提示：** `description` 欄位至關重要——Claude 使用它來決定何時應用該技能。包含使用者自然會提及的關鍵字。

---

## Configuration Reference
## 配置參考

### CLAUDE.md - Project Memory
### CLAUDE.md - 專案記憶

CLAUDE.md is Claude's persistent memory that loads automatically at session start.

CLAUDE.md 是 Claude 的持久記憶，會在會話開始時自動載入。

**Locations (in order of precedence):**
1. `.claude/CLAUDE.md` (project, in .claude folder)
2. `./CLAUDE.md` (project root)
3. `~/.claude/CLAUDE.md` (user-level, all projects)

**位置（依優先順序）：**
1. `.claude/CLAUDE.md`（專案，在 .claude 資料夾中）
2. `./CLAUDE.md`（專案根目錄）
3. `~/.claude/CLAUDE.md`（使用者層級，所有專案）

**What to include:**
- Project stack and architecture overview
- Key commands (test, build, lint, deploy)
- Code style guidelines
- Important directories and their purposes
- Critical rules and constraints

**應包含的內容：**
- 專案技術堆疊和架構概述
- 關鍵指令（測試、建置、lint、部署）
- 程式碼風格指南
- 重要目錄及其用途
- 關鍵規則和約束

**📄 Example:** [CLAUDE.md](CLAUDE.md)

**📄 範例：** [CLAUDE.md](CLAUDE.md)

---

### settings.json - Hooks & Environment
### settings.json - 鉤子與環境

The main configuration file for hooks, environment variables, and permissions.

hooks、環境變數和權限的主要配置檔案。

**Location:** `.claude/settings.json`

**位置：** `.claude/settings.json`

**📄 Example:** [settings.json](.claude/settings.json) | [Human-readable docs](.claude/settings.md)

**📄 範例：** [settings.json](.claude/settings.json) | [易讀文件](.claude/settings.md)

#### Hook Events
#### 鉤子事件

| Event | When It Fires | Use Case |
|-------|---------------|----------|
| `PreToolUse` | Before tool execution | Block edits on main, validate commands |
| `PostToolUse` | After tool completes | Auto-format, run tests, lint |
| `UserPromptSubmit` | User submits prompt | Add context, suggest skills |
| `Stop` | Agent finishes | Decide if Claude should continue |

| 事件 | 觸發時機 | 使用案例 |
|-------|---------------|----------|
| `PreToolUse` | 工具執行前 | 阻止在主分支上編輯、驗證指令 |
| `PostToolUse` | 工具完成後 | 自動格式化、執行測試、lint |
| `UserPromptSubmit` | 使用者提交提示時 | 新增上下文、建議技能 |
| `Stop` | 代理完成時 | 決定 Claude 是否應該繼續 |

#### Hook Response Format
#### 鉤子回應格式

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
#### 退出代碼

- `0` - Success
- `2` - Blocking error (PreToolUse only, blocks the tool)
- Other - Non-blocking error

- `0` - 成功
- `2` - 阻塞錯誤（僅 PreToolUse，阻止工具執行）
- 其他 - 非阻塞錯誤

---

### MCP Servers - External Integrations
### MCP 伺服器 - 外部整合

MCP (Model Context Protocol) servers let Claude Code connect to external tools like JIRA, GitHub, Slack, databases, and more. This is how you enable workflows like "read a ticket, implement it, and update the ticket status."

MCP（模型上下文協議）伺服器讓 Claude Code 能夠連接到外部工具，如 JIRA、GitHub、Slack、資料庫等。這就是您如何啟用「讀取工單、實作它並更新工單狀態」等工作流程。

**Location:** `.mcp.json` (project root, committed to git for team sharing)

**位置：** `.mcp.json`（專案根目錄，提交到 git 供團隊共享）

**📄 Example:** [.mcp.json](.mcp.json)

**📄 範例：** [.mcp.json](.mcp.json)

#### How MCP Works
#### MCP 如何運作

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Claude Code   │────▶│   MCP Server    │────▶│  External API   │
│                 │◀────│  (local bridge) │◀────│  (JIRA, GitHub) │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

MCP servers run locally and provide Claude with tools to interact with external services. When you configure a JIRA MCP server, Claude gets tools like `jira_get_issue`, `jira_update_issue`, `jira_create_issue`, etc.

MCP 伺服器在本地運行，並為 Claude 提供與外部服務互動的工具。當您配置 JIRA MCP 伺服器時，Claude 會獲得 `jira_get_issue`、`jira_update_issue`、`jira_create_issue` 等工具。

#### .mcp.json Format
#### .mcp.json 格式

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

**欄位：**

| Field | Required | Description |
|-------|----------|-------------|
| `type` | Yes | Server type: `stdio` (local process) or `http` (remote) |
| `command` | For stdio | Executable to run (e.g., `npx`, `python`) |
| `args` | No | Command-line arguments |
| `env` | No | Environment variables (supports `${VAR}` expansion) |
| `url` | For http | Remote server URL |
| `headers` | For http | HTTP headers for authentication |

| 欄位 | 必需 | 描述 |
|-------|----------|-------------|
| `type` | 是 | 伺服器類型：`stdio`（本地進程）或 `http`（遠端） |
| `command` | stdio 需要 | 要執行的可執行檔（例如 `npx`、`python`） |
| `args` | 否 | 命令列參數 |
| `env` | 否 | 環境變數（支援 `${VAR}` 擴展） |
| `url` | http 需要 | 遠端伺服器 URL |
| `headers` | http 需要 | 用於身份驗證的 HTTP 標頭 |

#### Example: JIRA Integration
#### 範例：JIRA 整合

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

**這能實現什麼：**
- 讀取工單詳情、驗收標準和註解
- 更新工單狀態（待辦 → 進行中 → 審查中）
- 新增進度更新註解
- 為開發過程中發現的錯誤建立新工單
- 將 PR 連結到工單

**Example workflow with [`/ticket` command](.claude/commands/ticket.md):**

**使用 [`/ticket` 指令](.claude/commands/ticket.md)的範例工作流程：**
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
#### 常見 MCP 伺服器配置

**Issue Tracking:**

**問題追蹤：**
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

**程式碼與 DevOps：**
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

**通訊：**
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

**資料庫：**
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
#### 環境變數

MCP configs support variable expansion:
- `${VAR}` - Expands to environment variable (fails if not set)
- `${VAR:-default}` - Uses default if VAR is not set

MCP 配置支援變數擴展：
- `${VAR}` - 擴展為環境變數（如果未設定則失敗）
- `${VAR:-default}` - 如果 VAR 未設定則使用預設值

Set these in your shell profile or `.env` file (don't commit secrets!):

在您的 shell 設定檔或 `.env` 檔案中設定這些變數（不要提交機密資訊！）：
```bash
export JIRA_HOST="https://yourcompany.atlassian.net"
export JIRA_EMAIL="you@company.com"
export JIRA_API_TOKEN="your-api-token"
```

#### Settings for MCP
#### MCP 設定

In `settings.json`, you can auto-approve MCP servers:

在 `settings.json` 中，您可以自動批准 MCP 伺服器：

```json
{
  "enableAllProjectMcpServers": true
}
```

Or approve specific servers:

或批准特定伺服器：
```json
{
  "enabledMcpjsonServers": ["jira", "github", "slack"]
}
```

---

### LSP Servers - Real-Time Code Intelligence
### LSP 伺服器 - 即時程式碼智能

LSP (Language Server Protocol) gives Claude real-time understanding of your code—type information, errors, completions, and navigation. Instead of just reading text, Claude can "see" your code the way your IDE does.

LSP（語言伺服器協議）讓 Claude 能即時理解您的程式碼——類型資訊、錯誤、自動完成和導航。Claude 不僅僅是讀取文字，而是能像您的 IDE 一樣「看到」您的程式碼。

**Why this matters:** When you edit TypeScript, Claude immediately knows if you introduced a type error. When you reference a function, Claude can jump to its definition. This dramatically improves code generation quality.

**為什麼這很重要：** 當您編輯 TypeScript 時，Claude 會立即知道您是否引入了類型錯誤。當您引用一個函式時，Claude 可以跳轉到它的定義。這大幅提升了程式碼生成的品質。

#### Enabling LSP
#### 啟用 LSP

LSP support is enabled through plugins in `settings.json`:

LSP 支援透過 `settings.json` 中的外掛程式啟用：

```json
{
  "enabledPlugins": {
    "typescript-lsp@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true
  }
}
```

#### What Claude Gets from LSP
#### Claude 從 LSP 獲得什麼

| Feature | Description |
|---------|-------------|
| **Diagnostics** | Real-time errors and warnings after every edit |
| **Type Information** | Hover info, function signatures, type definitions |
| **Code Navigation** | Go to definition, find references |
| **Completions** | Context-aware symbol suggestions |

| 功能 | 描述 |
|---------|-------------|
| **診斷** | 每次編輯後的即時錯誤和警告 |
| **類型資訊** | 懸停資訊、函式簽名、類型定義 |
| **程式碼導航** | 跳轉到定義、查找引用 |
| **自動完成** | 上下文感知的符號建議 |

#### Available LSP Plugins
#### 可用的 LSP 外掛程式

| Plugin | Language | Install Binary First |
|--------|----------|---------------------|
| `typescript-lsp` | TypeScript/JavaScript | `npm install -g typescript-language-server typescript` |
| `pyright-lsp` | Python | `pip install pyright` |
| `rust-lsp` | Rust | `rustup component add rust-analyzer` |

| 外掛程式 | 語言 | 先安裝執行檔 |
|--------|----------|---------------------|
| `typescript-lsp` | TypeScript/JavaScript | `npm install -g typescript-language-server typescript` |
| `pyright-lsp` | Python | `pip install pyright` |
| `rust-lsp` | Rust | `rustup component add rust-analyzer` |

#### Custom LSP Configuration
#### 自訂 LSP 配置

For advanced setups, create `.lsp.json`:

對於進階設定，建立 `.lsp.json`：

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
#### 疑難排解

If LSP isn't working:

如果 LSP 無法運作：

1. **Check binary is installed:**

   **檢查執行檔是否已安裝：**
   ```bash
   which typescript-language-server  # Should return a path
   ```

2. **Enable debug logging:**

   **啟用除錯日誌：**
   ```bash
   claude --enable-lsp-logging
   ```

3. **Check plugin status:**

   **檢查外掛程式狀態：**
   ```bash
   claude /plugin  # View Errors tab
   ```

---

### Skill Evaluation Hooks
### 技能評估鉤子

One of our most powerful automations is the **skill evaluation system**. It runs on every prompt submission and intelligently suggests which skills Claude should activate.

我們最強大的自動化之一是**技能評估系統**。它在每次提示提交時運行，並智慧地建議 Claude 應該啟用哪些技能。

**📄 Files:** [skill-eval.sh](.claude/hooks/skill-eval.sh) | [skill-eval.js](.claude/hooks/skill-eval.js) | [skill-rules.json](.claude/hooks/skill-rules.json)

**📄 檔案：** [skill-eval.sh](.claude/hooks/skill-eval.sh) | [skill-eval.js](.claude/hooks/skill-eval.js) | [skill-rules.json](.claude/hooks/skill-rules.json)

#### How It Works
#### 運作方式

When you submit a prompt, the `UserPromptSubmit` hook triggers our skill evaluation engine:

當您提交提示時，`UserPromptSubmit` 鉤子會觸發我們的技能評估引擎：

1. **Prompt Analysis** - The engine analyzes your prompt for:
   - **Keywords**: Simple word matching (`test`, `form`, `graphql`, `bug`)
   - **Patterns**: Regex matching (`\btest(?:s|ing)?\b`, `\.stories\.`)
   - **File Paths**: Extracts mentioned files (`src/components/Button.tsx`)
   - **Intent**: Detects what you're trying to do (`create.*test`, `fix.*bug`)

1. **提示分析** - 引擎分析您的提示以尋找：
   - **關鍵字**：簡單的字詞匹配（`test`、`form`、`graphql`、`bug`）
   - **模式**：正則表達式匹配（`\btest(?:s|ing)?\b`、`\.stories\.`）
   - **檔案路徑**：提取提及的檔案（`src/components/Button.tsx`）
   - **意圖**：檢測您試圖做什麼（`create.*test`、`fix.*bug`）

2. **Directory Mapping** - File paths are mapped to relevant skills:
   ```json
   {
     "src/components/core": "core-components",
     "src/graphql": "graphql-schema",
     ".github/workflows": "github-actions",
     "src/hooks": "react-ui-patterns"
   }
   ```

2. **目錄映射** - 檔案路徑被映射到相關技能：
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

3. **信心評分** - 每種觸發類型都有一個分數值：
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

4. **技能建議** - 超過信心閾值的技能會附帶原因被建議：
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
#### 配置

Skills are defined in [skill-rules.json](.claude/hooks/skill-rules.json):

技能定義在 [skill-rules.json](.claude/hooks/skill-rules.json) 中：

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
#### 新增到您的專案

1. Copy the hooks to your project:

   **將鉤子複製到您的專案：**
   ```bash
   cp -r .claude/hooks/ your-project/.claude/hooks/
   ```

2. Add the hook to your `settings.json`:

   **將鉤子新增到您的 `settings.json`：**
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

   **使用您專案的技能和觸發器自訂 [skill-rules.json](.claude/hooks/skill-rules.json)。**

---

### Skills - Domain Knowledge
### 技能 - 領域知識

Skills are markdown documents that teach Claude project-specific patterns and conventions.

技能是 markdown 文件，教導 Claude 專案特定的模式和慣例。

**Location:** `.claude/skills/{skill-name}/SKILL.md`

**位置：** `.claude/skills/{skill-name}/SKILL.md`

**📄 Examples:**
- [testing-patterns](.claude/skills/testing-patterns/SKILL.md) - TDD, factory functions, mocking
- [systematic-debugging](.claude/skills/systematic-debugging/SKILL.md) - Four-phase debugging methodology
- [react-ui-patterns](.claude/skills/react-ui-patterns/SKILL.md) - Loading states, error handling
- [graphql-schema](.claude/skills/graphql-schema/SKILL.md) - Queries, mutations, codegen
- [core-components](.claude/skills/core-components/SKILL.md) - Design system, tokens
- [formik-patterns](.claude/skills/formik-patterns/SKILL.md) - Form handling, validation

**📄 範例：**
- [testing-patterns](.claude/skills/testing-patterns/SKILL.md) - TDD、工廠函式、模擬
- [systematic-debugging](.claude/skills/systematic-debugging/SKILL.md) - 四階段除錯方法
- [react-ui-patterns](.claude/skills/react-ui-patterns/SKILL.md) - 載入狀態、錯誤處理
- [graphql-schema](.claude/skills/graphql-schema/SKILL.md) - 查詢、mutation、程式碼生成
- [core-components](.claude/skills/core-components/SKILL.md) - 設計系統、設計令牌
- [formik-patterns](.claude/skills/formik-patterns/SKILL.md) - 表單處理、驗證

#### SKILL.md Frontmatter Fields
#### SKILL.md 前置資料欄位

| Field | Required | Max Length | Description |
|-------|----------|------------|-------------|
| `name` | **Yes** | 64 chars | Lowercase letters, numbers, and hyphens only. Should match directory name. |
| `description` | **Yes** | 1024 chars | What the skill does and when to use it. Claude uses this to decide when to apply the skill. |
| `allowed-tools` | No | - | Comma-separated list of tools Claude can use (e.g., `Read, Grep, Bash(npm:*)`). |
| `model` | No | - | Specific model to use (e.g., `claude-sonnet-4-20250514`). |

| 欄位 | 必需 | 最大長度 | 描述 |
|-------|----------|------------|-------------|
| `name` | **是** | 64 字元 | 僅限小寫字母、數字和連字符。應與目錄名稱匹配。 |
| `description` | **是** | 1024 字元 | 技能的功能和使用時機。Claude 使用此欄位決定何時應用該技能。 |
| `allowed-tools` | 否 | - | Claude 可以使用的工具清單，以逗號分隔（例如 `Read, Grep, Bash(npm:*)`）。 |
| `model` | 否 | - | 要使用的特定模型（例如 `claude-sonnet-4-20250514`）。 |

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
#### 技能最佳實踐

1. **Keep SKILL.md focused** - Under 500 lines; put detailed docs in separate referenced files
2. **Write trigger-rich descriptions** - Claude uses semantic matching on descriptions to decide when to apply skills
3. **Include examples** - Show both good and bad patterns with code
4. **Reference other skills** - Show how skills work together
5. **Use exact filename** - Must be `SKILL.md` (case-sensitive)

1. **保持 SKILL.md 專注** - 少於 500 行；將詳細文件放在單獨引用的檔案中
2. **撰寫豐富的觸發描述** - Claude 使用語意匹配描述來決定何時應用技能
3. **包含範例** - 展示好的和壞的模式與程式碼
4. **引用其他技能** - 展示技能如何協同工作
5. **使用精確的檔案名稱** - 必須是 `SKILL.md`（區分大小寫）

---

### Agents - Specialized Assistants
### 代理 - 專業助手

Agents are AI assistants with focused purposes and their own prompts.

代理是具有特定目的和自己提示的 AI 助手。

**Location:** `.claude/agents/{agent-name}.md`

**位置：** `.claude/agents/{agent-name}.md`

**📄 Examples:**
- [code-reviewer.md](.claude/agents/code-reviewer.md) - Comprehensive code review with checklist
- [github-workflow.md](.claude/agents/github-workflow.md) - Git commits, branches, PRs

**📄 範例：**
- [code-reviewer.md](.claude/agents/code-reviewer.md) - 包含檢查清單的全面程式碼審查
- [github-workflow.md](.claude/agents/github-workflow.md) - Git 提交、分支、PR

#### Agent Format
#### 代理格式

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
#### 代理配置欄位

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Lowercase with hyphens |
| `description` | Yes | When/why to use (max 1024 chars) |
| `model` | No | `sonnet`, `opus`, or `haiku` |
| `tools` | No | Comma-separated tool list |

| 欄位 | 必需 | 描述 |
|-------|----------|-------------|
| `name` | 是 | 小寫加連字符 |
| `description` | 是 | 何時/為何使用（最多 1024 字元） |
| `model` | 否 | `sonnet`、`opus` 或 `haiku` |
| `tools` | 否 | 以逗號分隔的工具清單 |

---

### Commands - Slash Commands
### 指令 - 斜線指令

Custom commands invoked with `/command-name`.

使用 `/command-name` 呼叫的自訂指令。

**Location:** `.claude/commands/{command-name}.md`

**位置：** `.claude/commands/{command-name}.md`

**📄 Examples:**
- [onboard.md](.claude/commands/onboard.md) - Deep task exploration
- [pr-review.md](.claude/commands/pr-review.md) - PR review workflow
- [pr-summary.md](.claude/commands/pr-summary.md) - Generate PR description
- [code-quality.md](.claude/commands/code-quality.md) - Quality checks
- [docs-sync.md](.claude/commands/docs-sync.md) - Documentation alignment

**📄 範例：**
- [onboard.md](.claude/commands/onboard.md) - 深度任務探索
- [pr-review.md](.claude/commands/pr-review.md) - PR 審查工作流程
- [pr-summary.md](.claude/commands/pr-summary.md) - 生成 PR 描述
- [code-quality.md](.claude/commands/code-quality.md) - 品質檢查
- [docs-sync.md](.claude/commands/docs-sync.md) - 文件對齊

#### Command Format
#### 指令格式

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
#### 變數

- `$ARGUMENTS` - All arguments as single string
- `$1`, `$2`, `$3` - Individual positional arguments

- `$ARGUMENTS` - 所有參數作為單一字串
- `$1`、`$2`、`$3` - 個別位置參數

#### Inline Bash
#### 內嵌 Bash

```markdown
Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
```

---

## GitHub Actions Workflows
## GitHub Actions 工作流程

Automate code review, quality checks, and maintenance with Claude Code.

使用 Claude Code 自動化程式碼審查、品質檢查和維護。

**📄 Examples:**
- [pr-claude-code-review.yml](.github/workflows/pr-claude-code-review.yml) - Auto PR review
- [scheduled-claude-code-docs-sync.yml](.github/workflows/scheduled-claude-code-docs-sync.yml) - Monthly docs sync
- [scheduled-claude-code-quality.yml](.github/workflows/scheduled-claude-code-quality.yml) - Weekly quality review
- [scheduled-claude-code-dependency-audit.yml](.github/workflows/scheduled-claude-code-dependency-audit.yml) - Biweekly dependency updates

**📄 範例：**
- [pr-claude-code-review.yml](.github/workflows/pr-claude-code-review.yml) - 自動 PR 審查
- [scheduled-claude-code-docs-sync.yml](.github/workflows/scheduled-claude-code-docs-sync.yml) - 每月文件同步
- [scheduled-claude-code-quality.yml](.github/workflows/scheduled-claude-code-quality.yml) - 每週品質審查
- [scheduled-claude-code-dependency-audit.yml](.github/workflows/scheduled-claude-code-dependency-audit.yml) - 雙週依賴更新

### PR Code Review
### PR 程式碼審查

Automatically reviews PRs and responds to `@claude` mentions.

自動審查 PR 並回應 `@claude` 提及。

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
### 定期工作流程

| Workflow | Schedule | Purpose |
|----------|----------|---------|
| [Code Quality](.github/workflows/scheduled-claude-code-quality.yml) | Weekly (Sunday) | Reviews random directories, auto-fixes issues |
| [Docs Sync](.github/workflows/scheduled-claude-code-docs-sync.yml) | Monthly (1st) | Ensures docs align with code changes |
| [Dependency Audit](.github/workflows/scheduled-claude-code-dependency-audit.yml) | Biweekly (1st & 15th) | Safe dependency updates with testing |

| 工作流程 | 排程 | 目的 |
|----------|----------|---------|
| [程式碼品質](.github/workflows/scheduled-claude-code-quality.yml) | 每週（週日） | 審查隨機目錄，自動修復問題 |
| [文件同步](.github/workflows/scheduled-claude-code-docs-sync.yml) | 每月（1 日） | 確保文件與程式碼變更一致 |
| [依賴審計](.github/workflows/scheduled-claude-code-dependency-audit.yml) | 雙週（1 日和 15 日） | 透過測試進行安全的依賴更新 |

### Setup Required
### 所需設定

Add `ANTHROPIC_API_KEY` to your repository secrets:
- Settings → Secrets and variables → Actions → New repository secret

將 `ANTHROPIC_API_KEY` 新增到您的程式碼庫機密：
- Settings → Secrets and variables → Actions → New repository secret

### Cost Estimate
### 成本估算

| Workflow | Frequency | Est. Cost |
|----------|-----------|-----------|
| PR Review | Per PR | ~$0.05 - $0.50 |
| Docs Sync | Monthly | ~$0.50 - $2.00 |
| Dependency Audit | Biweekly | ~$0.20 - $1.00 |
| Code Quality | Weekly | ~$1.00 - $5.00 |

| 工作流程 | 頻率 | 預估成本 |
|----------|-----------|-----------|
| PR 審查 | 每個 PR | ~$0.05 - $0.50 |
| 文件同步 | 每月 | ~$0.50 - $2.00 |
| 依賴審計 | 雙週 | ~$0.20 - $1.00 |
| 程式碼品質 | 每週 | ~$1.00 - $5.00 |

**Estimated monthly total:** ~$10 - $50 (depending on PR volume)

**預估每月總計：** ~$10 - $50（取決於 PR 數量）

---

## Best Practices
## 最佳實踐

### 1. Start with CLAUDE.md
### 1. 從 CLAUDE.md 開始

Your `CLAUDE.md` is the foundation. Include:
- Stack overview
- Key commands
- Critical rules
- Directory structure

您的 `CLAUDE.md` 是基礎。應包含：
- 技術堆疊概述
- 關鍵指令
- 關鍵規則
- 目錄結構

### 2. Build Skills Incrementally
### 2. 逐步建立技能

Don't try to document everything at once:
1. Start with your most common patterns
2. Add skills as pain points emerge
3. Keep each skill focused on one domain

不要試圖一次記錄所有內容：
1. 從最常見的模式開始
2. 隨著痛點出現而新增技能
3. 保持每個技能專注於一個領域

### 3. Use Hooks for Automation
### 3. 使用鉤子進行自動化

Let hooks handle repetitive tasks:
- Auto-format on save
- Run tests when test files change
- Regenerate types when schemas change
- Block edits on protected branches

讓鉤子處理重複性任務：
- 儲存時自動格式化
- 測試檔案變更時執行測試
- schema 變更時重新生成類型
- 阻止在受保護分支上進行編輯

### 4. Create Agents for Complex Workflows
### 4. 為複雜工作流程建立代理

Agents are great for:
- Code review (with your team's checklist)
- PR creation and management
- Debugging workflows
- Onboarding to tasks

代理非常適合：
- 程式碼審查（使用團隊的檢查清單）
- PR 建立和管理
- 除錯工作流程
- 任務導入

### 5. Leverage GitHub Actions
### 5. 利用 GitHub Actions

Automate maintenance:
- PR reviews on every PR
- Weekly quality sweeps
- Monthly docs alignment
- Dependency updates

自動化維護：
- 每個 PR 的審查
- 每週品質檢查
- 每月文件對齊
- 依賴更新

### 6. Version Control Your Config
### 6. 版本控制您的配置

Commit everything except:
- `settings.local.json` (personal preferences)
- `CLAUDE.local.md` (personal notes)
- User-specific credentials

提交所有內容，除了：
- `settings.local.json`（個人偏好）
- `CLAUDE.local.md`（個人筆記）
- 使用者特定的憑證

---

## Examples in This Repository
## 本程式碼庫中的範例

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

| 檔案 | 描述 |
|------|-------------|
| [CLAUDE.md](CLAUDE.md) | 範例專案記憶檔案 |
| [.claude/settings.json](.claude/settings.json) | 完整 hooks 配置 |
| [.claude/settings.md](.claude/settings.md) | 易讀的 hooks 文件 |
| [.mcp.json](.mcp.json) | MCP 伺服器配置（JIRA、GitHub、Slack 等） |
| **代理** | |
| [.claude/agents/code-reviewer.md](.claude/agents/code-reviewer.md) | 全面的程式碼審查代理 |
| [.claude/agents/github-workflow.md](.claude/agents/github-workflow.md) | Git 工作流程代理 |
| **指令** | |
| [.claude/commands/onboard.md](.claude/commands/onboard.md) | 深度任務探索 |
| [.claude/commands/ticket.md](.claude/commands/ticket.md) | **JIRA/Linear 工單工作流程（讀取 → 實作 → 更新）** |
| [.claude/commands/pr-review.md](.claude/commands/pr-review.md) | PR 審查工作流程 |
| [.claude/commands/pr-summary.md](.claude/commands/pr-summary.md) | 生成 PR 摘要 |
| [.claude/commands/code-quality.md](.claude/commands/code-quality.md) | 品質檢查 |
| [.claude/commands/docs-sync.md](.claude/commands/docs-sync.md) | 文件同步 |
| **鉤子** | |
| [.claude/hooks/skill-eval.sh](.claude/hooks/skill-eval.sh) | 技能評估包裝器 |
| [.claude/hooks/skill-eval.js](.claude/hooks/skill-eval.js) | Node.js 技能匹配引擎 |
| [.claude/hooks/skill-rules.json](.claude/hooks/skill-rules.json) | 模式匹配規則 |
| **技能** | |
| [.claude/skills/testing-patterns/SKILL.md](.claude/skills/testing-patterns/SKILL.md) | TDD、工廠函式、模擬 |
| [.claude/skills/systematic-debugging/SKILL.md](.claude/skills/systematic-debugging/SKILL.md) | 四階段除錯 |
| [.claude/skills/react-ui-patterns/SKILL.md](.claude/skills/react-ui-patterns/SKILL.md) | 載入/錯誤/空白狀態 |
| [.claude/skills/graphql-schema/SKILL.md](.claude/skills/graphql-schema/SKILL.md) | 查詢、mutation、程式碼生成 |
| [.claude/skills/core-components/SKILL.md](.claude/skills/core-components/SKILL.md) | 設計系統、設計令牌 |
| [.claude/skills/formik-patterns/SKILL.md](.claude/skills/formik-patterns/SKILL.md) | 表單處理、驗證 |
| **GitHub 工作流程** | |
| [.github/workflows/pr-claude-code-review.yml](.github/workflows/pr-claude-code-review.yml) | 自動 PR 審查 |
| [.github/workflows/scheduled-claude-code-docs-sync.yml](.github/workflows/scheduled-claude-code-docs-sync.yml) | 每月文件同步 |
| [.github/workflows/scheduled-claude-code-quality.yml](.github/workflows/scheduled-claude-code-quality.yml) | 每週品質審查 |
| [.github/workflows/scheduled-claude-code-dependency-audit.yml](.github/workflows/scheduled-claude-code-dependency-audit.yml) | 雙週依賴審計 |

---

## Learn More
## 了解更多

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code Action](https://github.com/anthropics/claude-code-action) - GitHub Action
- [Anthropic API](https://docs.anthropic.com/en/api)

- [Claude Code 文件](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code Action](https://github.com/anthropics/claude-code-action) - GitHub Action
- [Anthropic API](https://docs.anthropic.com/en/api)

---

## License
## 授權

MIT - Use this as a template for your own projects.

MIT - 使用此作為您自己專案的範本。
