---
description: Check if documentation is in sync with code / 檢查文件是否與程式碼同步
allowed-tools: Read, Glob, Grep, Bash(git:*)
---

# Documentation Sync
# 文件同步檢查

Check if documentation matches the current code state.

檢查文件是否與當前程式碼狀態匹配。

## Instructions
## 指令說明

1. **Find recent code changes**:
1. **查找最近的程式碼變更**：
   ```bash
   git log --since="30 days ago" --name-only --pretty=format: -- "*.ts" "*.tsx" | sort -u
   ```

2. **Find related documentation**:
2. **查找相關文件**：
   - Search `/docs/` for files mentioning changed code
   - 搜尋 `/docs/` 目錄中提及已變更程式碼的檔案
   - Check README files near changed code
   - 檢查已變更程式碼附近的 README 檔案
   - Look for TSDoc comments in changed files
   - 在已變更的檔案中查找 TSDoc 註釋

3. **Verify documentation accuracy**:
3. **驗證文件準確性**：
   - Do code examples still work?
   - 程式碼範例是否仍然有效？
   - Are API signatures correct?
   - API 簽名是否正確？
   - Are prop types up to date?
   - prop 型別是否為最新？

4. **Report only actual problems**:
4. **僅報告實際問題**：
   - Documentation is a living document
   - 文件是活的文檔
   - Only flag things that are WRONG, not missing
   - 只標記錯誤的內容，而非缺失的內容
   - Don't suggest documentation for documentation's sake
   - 不要為了文件而建議文件

5. **Output a checklist** of documentation that needs updating
5. **輸出檢查清單**列出需要更新的文件
