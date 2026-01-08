# Claude Code Skills
# Claude Code 技能

This directory contains project-specific skills that provide Claude with domain knowledge and best practices for this codebase.

此目錄包含專案特定的技能，為 Claude 提供此程式碼庫的領域知識和最佳實踐。

## Skills by Category
## 依類別分類的技能

### Code Quality & Patterns
### 程式碼品質與模式
| Skill | Description |
|-------|-------------|
| [testing-patterns](./testing-patterns/SKILL.md) | Jest testing, factory functions, mocking strategies, TDD workflow |
| [testing-patterns](./testing-patterns/SKILL.md) | Jest 測試、工廠函數、模擬策略、TDD 工作流程 |
| [systematic-debugging](./systematic-debugging/SKILL.md) | Four-phase debugging methodology, root cause analysis |
| [systematic-debugging](./systematic-debugging/SKILL.md) | 四階段除錯方法論、根本原因分析 |

### React & UI
### React 與使用者介面
| Skill | Description |
|-------|-------------|
| [react-ui-patterns](./react-ui-patterns/SKILL.md) | React patterns, loading states, error handling, GraphQL hooks |
| [react-ui-patterns](./react-ui-patterns/SKILL.md) | React 模式、載入狀態、錯誤處理、GraphQL hooks |
| [core-components](./core-components/SKILL.md) | Design system components, tokens, component library |
| [core-components](./core-components/SKILL.md) | 設計系統元件、設計標記、元件庫 |
| [formik-patterns](./formik-patterns/SKILL.md) | Form handling, validation, submission patterns |
| [formik-patterns](./formik-patterns/SKILL.md) | 表單處理、驗證、提交模式 |

### Data & API
### 資料與 API
| Skill | Description |
|-------|-------------|
| [graphql-schema](./graphql-schema/SKILL.md) | GraphQL queries, mutations, code generation |
| [graphql-schema](./graphql-schema/SKILL.md) | GraphQL 查詢、變更、程式碼生成 |

## Skill Combinations for Common Tasks
## 常見任務的技能組合

### Building a New Feature
### 建構新功能
1. **react-ui-patterns** - Loading/error/empty states
1. **react-ui-patterns** - 載入/錯誤/空白狀態
2. **graphql-schema** - Create queries/mutations
2. **graphql-schema** - 建立查詢/變更
3. **core-components** - UI implementation
3. **core-components** - UI 實作
4. **testing-patterns** - Write tests (TDD)
4. **testing-patterns** - 編寫測試 (TDD)

### Building a Form
### 建構表單
1. **formik-patterns** - Form structure and validation
1. **formik-patterns** - 表單結構和驗證
2. **graphql-schema** - Mutation for submission
2. **graphql-schema** - 提交的變更操作
3. **react-ui-patterns** - Loading/error handling
3. **react-ui-patterns** - 載入/錯誤處理

### Debugging an Issue
### 除錯問題
1. **systematic-debugging** - Root cause analysis
1. **systematic-debugging** - 根本原因分析
2. **testing-patterns** - Write failing test first
2. **testing-patterns** - 先編寫失敗的測試

## How Skills Work
## 技能如何運作

Skills are automatically invoked when Claude recognizes relevant context. Each skill provides:

當 Claude 識別到相關情境時，技能會自動被調用。每個技能提供：

- **When to Use** - Trigger conditions
- **何時使用** - 觸發條件
- **Core Patterns** - Best practices and examples
- **核心模式** - 最佳實踐和範例
- **Anti-Patterns** - What to avoid
- **反模式** - 應避免的做法
- **Integration** - How skills connect
- **整合** - 技能如何連接

## Adding New Skills
## 新增技能

1. Create directory: `.claude/skills/skill-name/`
1. 建立目錄：`.claude/skills/skill-name/`
2. Add `SKILL.md` (case-sensitive) with YAML frontmatter:
2. 新增 `SKILL.md`（區分大小寫）並包含 YAML 前置資料：
   ```yaml
   ---
   # Required fields
   # 必填欄位
   name: skill-name              # Lowercase, hyphens, max 64 chars
                                 # 小寫、連字號、最多 64 字元
   description: What it does and when to use it. Include trigger keywords.  # Max 1024 chars
                                                                              # 功能說明和使用時機。包含觸發關鍵字。最多 1024 字元

   # Optional fields
   # 選填欄位
   allowed-tools: Read, Grep, Glob    # Restrict available tools
                                       # 限制可用工具
   model: claude-sonnet-4-20250514    # Specific model to use
                                       # 使用特定模型
   ---
   ```
3. Include standard sections: When to Use, Core Patterns, Anti-Patterns, Integration
3. 包含標準章節：何時使用、核心模式、反模式、整合
4. Add to this README
4. 新增至此 README
5. Add triggers to `.claude/hooks/skill-rules.json`
5. 將觸發條件新增至 `.claude/hooks/skill-rules.json`

**Important:** The `description` field is critical—Claude uses semantic matching on it to decide when to apply the skill. Include keywords users would naturally mention.

**重要：** `description` 欄位非常關鍵——Claude 使用語意配對來決定何時應用該技能。請包含使用者自然會提到的關鍵字。

## Maintenance
## 維護

- Update skills when patterns change
- 當模式改變時更新技能
- Remove outdated information
- 移除過時的資訊
- Add new patterns as they emerge
- 隨著新模式出現而新增
- Keep examples current with codebase
- 保持範例與程式碼庫同步
