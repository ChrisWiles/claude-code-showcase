---
description: Review a pull request using project standards / 使用專案標準審查拉取請求
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(gh:*)
---

# PR Review
# 拉取請求審查

Review the pull request: $ARGUMENTS

審查拉取請求：$ARGUMENTS

## Instructions
## 指令說明

1. **Get PR information**:
1. **獲取 PR 資訊**：
   - Run `gh pr view $ARGUMENTS` to get PR details
   - 執行 `gh pr view $ARGUMENTS` 以獲取 PR 詳情
   - Run `gh pr diff $ARGUMENTS` to see changes
   - 執行 `gh pr diff $ARGUMENTS` 以查看變更

2. **Read review standards**:
2. **閱讀審查標準**：
   - Read `.claude/agents/code-reviewer.md` for the review checklist
   - 閱讀 `.claude/agents/code-reviewer.md` 以獲取審查檢查清單

3. **Apply the checklist** to all changed files:
3. **將檢查清單應用**到所有變更的檔案：
   - TypeScript strict mode compliance
   - TypeScript 嚴格模式合規性
   - Error handling patterns
   - 錯誤處理模式
   - Loading/error/empty states
   - 載入/錯誤/空狀態
   - Test coverage
   - 測試覆蓋率
   - Documentation updates
   - 文件更新

4. **Provide structured feedback**:
4. **提供結構化回饋**：
   - **Critical**: Must fix before merge
   - **關鍵**：合併前必須修復
   - **Warning**: Should fix
   - **警告**：應該修復
   - **Suggestion**: Nice to have
   - **建議**：最好能有

5. **Post review comments** using `gh pr comment`
5. **發布審查評論**使用 `gh pr comment`
