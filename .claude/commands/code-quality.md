---
description: Run code quality checks on a directory / 對目錄執行程式碼品質檢查
allowed-tools: Read, Glob, Grep, Bash(npm:*), Bash(npx:*)
---

# Code Quality Review
# 程式碼品質審查

Review code quality in: $ARGUMENTS

審查程式碼品質於：$ARGUMENTS

## Instructions
## 指令說明

1. **Identify files to review**:
1. **識別要審查的檔案**：
   - Find all `.ts` and `.tsx` files in the directory
   - 在目錄中找到所有 `.ts` 和 `.tsx` 檔案
   - Exclude test files and generated files
   - 排除測試檔案和生成的檔案

2. **Run automated checks**:
2. **執行自動化檢查**：
   ```bash
   npm run lint -- $ARGUMENTS
   npm run typecheck
   ```

3. **Manual review checklist**:
3. **手動審查檢查清單**：
   - [ ] No TypeScript `any` types
   - [ ] 沒有 TypeScript `any` 型別
   - [ ] Proper error handling
   - [ ] 適當的錯誤處理
   - [ ] Loading states handled correctly
   - [ ] 正確處理載入狀態
   - [ ] Empty states for lists
   - [ ] 清單的空狀態
   - [ ] Mutations have onError handlers
   - [ ] 變更操作具有 onError 處理程序
   - [ ] Buttons disabled during async operations
   - [ ] 非同步操作期間禁用按鈕

4. **Report findings** organized by severity:
4. **報告發現**按嚴重程度組織：
   - Critical (must fix)
   - 關鍵（必須修復）
   - Warning (should fix)
   - 警告（應該修復）
   - Suggestion (could improve)
   - 建議（可以改進）
