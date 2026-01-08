# Project Name
# 專案名稱

> This is an example CLAUDE.md file showing how to configure Claude Code for your project.
> 這是一個示範 CLAUDE.md 檔案，展示如何為您的專案設定 Claude Code。

## Quick Facts
## 快速概覽

- **Stack**: React, TypeScript, Node.js
- **技術棧**：React, TypeScript, Node.js
- **Test Command**: `npm test`
- **測試命令**：`npm test`
- **Lint Command**: `npm run lint`
- **程式碼檢查命令**：`npm run lint`
- **Build Command**: `npm run build`
- **建置命令**：`npm run build`

## Key Directories
## 主要目錄

- `src/components/` - React components
- `src/components/` - React 元件
- `src/hooks/` - Custom React hooks
- `src/hooks/` - 自訂 React hooks
- `src/utils/` - Utility functions
- `src/utils/` - 工具函數
- `src/api/` - API client code
- `src/api/` - API 客戶端程式碼
- `tests/` - Test files
- `tests/` - 測試檔案

## Code Style
## 程式碼風格

- TypeScript strict mode enabled
- 啟用 TypeScript 嚴格模式
- Prefer `interface` over `type` (except unions/intersections)
- 優先使用 `interface` 而非 `type`（聯集/交集除外）
- No `any` - use `unknown` instead
- 不使用 `any` - 改用 `unknown`
- Use early returns, avoid nested conditionals
- 使用提前返回，避免巢狀條件判斷
- Prefer composition over inheritance
- 優先使用組合而非繼承

## Git Conventions
## Git 慣例

- **Branch naming**: `{initials}/{description}` (e.g., `jd/fix-login`)
- **分支命名**：`{縮寫}/{描述}` (例如：`jd/fix-login`)
- **Commit format**: Conventional Commits (`feat:`, `fix:`, `docs:`, etc.)
- **提交格式**：Conventional Commits（`feat:`、`fix:`、`docs:` 等）
- **PR titles**: Same as commit format
- **PR 標題**：與提交格式相同

## Critical Rules
## 重要規則

### Error Handling
### 錯誤處理

- NEVER swallow errors silently
- 絕不靜默吞沒錯誤
- Always show user feedback for errors
- 總是向使用者顯示錯誤訊息
- Log errors for debugging
- 記錄錯誤以便除錯

### UI States
### UI 狀態

- Always handle: loading, error, empty, success states
- 總是處理：載入中、錯誤、空狀態、成功狀態
- Show loading ONLY when no data exists
- 只在沒有資料時顯示載入中
- Every list needs an empty state
- 每個列表都需要空狀態

### Mutations
### 資料變更

- Disable buttons during async operations
- 在非同步操作期間停用按鈕
- Show loading indicator on buttons
- 在按鈕上顯示載入指示器
- Always have onError handler with user feedback
- 總是提供帶有使用者回饋的 onError 處理器

## Testing
## 測試

- Write failing test first (TDD)
- 先寫失敗的測試（TDD）
- Use factory pattern: `getMockX(overrides)`
- 使用工廠模式：`getMockX(overrides)`
- Test behavior, not implementation
- 測試行為，而非實作
- Run tests before committing
- 提交前執行測試

## Skill Activation
## 技能啟用

Before implementing ANY task, check if relevant skills apply:
在實作任何任務之前，請檢查是否適用相關技能：

- Creating tests → `testing-patterns` skill
- 建立測試 → `testing-patterns` 技能
- Building forms → `formik-patterns` skill
- 建立表單 → `formik-patterns` 技能
- GraphQL operations → `graphql-schema` skill
- GraphQL 操作 → `graphql-schema` 技能
- Debugging issues → `systematic-debugging` skill
- 除錯問題 → `systematic-debugging` 技能
- UI components → `react-ui-patterns` skill
- UI 元件 → `react-ui-patterns` 技能

## Common Commands
## 常用命令

```bash
# Development
# 開發
npm run dev          # Start dev server (啟動開發伺服器)
npm test             # Run tests (執行測試)
npm run lint         # Run linter (執行程式碼檢查)
npm run typecheck    # Check types (檢查型別)

# Git
npm run commit       # Interactive commit (互動式提交)
gh pr create         # Create PR (建立 PR)
```
