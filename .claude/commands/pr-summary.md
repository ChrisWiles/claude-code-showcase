---
description: Generate a summary for the current branch changes / 為當前分支變更生成摘要
allowed-tools: Bash(git:*)
---

# PR Summary
# 拉取請求摘要

Generate a pull request summary for the current branch.

為當前分支生成拉取請求摘要。

## Instructions
## 指令說明

1. **Analyze changes**:
1. **分析變更**：
   ```bash
   git log main..HEAD --oneline
   git diff main...HEAD --stat
   ```

2. **Generate summary** with:
2. **生成摘要**包括：
   - Brief description of what changed
   - 變更內容的簡要描述
   - List of files modified
   - 修改的檔案清單
   - Breaking changes (if any)
   - 破壞性變更（如果有）
   - Testing notes
   - 測試說明

3. **Format as PR body**:
3. **格式化為 PR 正文**：
   ```markdown
   ## Summary
   [1-3 bullet points describing the changes]

   ## Changes
   - [List of significant changes]

   ## Test Plan
   - [ ] [Testing checklist items]
   ```
