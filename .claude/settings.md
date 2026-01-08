# Claude Code Settings Documentation
# Claude Code 設定文檔

## Environment Variables
## 環境變數

- `INSIDE_CLAUDE_CODE`: "1" - Indicates code is running inside Claude Code
- `INSIDE_CLAUDE_CODE`: "1" - 表示程式碼正在 Claude Code 中執行

- `BASH_DEFAULT_TIMEOUT_MS`: Default timeout for bash commands (7 minutes)
- `BASH_DEFAULT_TIMEOUT_MS`: bash 命令的預設超時時間（7 分鐘）

- `BASH_MAX_TIMEOUT_MS`: Maximum timeout for bash commands
- `BASH_MAX_TIMEOUT_MS`: bash 命令的最大超時時間

## Hooks
## 鉤子

### UserPromptSubmit
### 使用者提示提交

- **Skill Evaluation**: Analyzes prompts and suggests relevant skills
- **技能評估**: 分析提示並建議相關技能
  - **Script**: `.claude/hooks/skill-eval.sh`
  - **腳本**: `.claude/hooks/skill-eval.sh`
  - **Behavior**: Matches keywords, file paths, and patterns to suggest skills
  - **行為**: 匹配關鍵字、檔案路徑和模式以建議技能

### PreToolUse
### 工具使用前

- **Main Branch Protection**: Prevents edits on main branch (5s timeout)
- **主分支保護**: 防止在主分支上進行編輯（5 秒超時）
  - **Triggers**: Before editing files with Edit, MultiEdit, or Write tools
  - **觸發時機**: 在使用 Edit、MultiEdit 或 Write 工具編輯檔案之前
  - **Behavior**: Blocks file edits when on main branch, suggests creating feature branch
  - **行為**: 當在主分支時阻止檔案編輯，建議建立功能分支

### PostToolUse
### 工具使用後

1. **Code Formatting**: Auto-format JS/TS files (30s timeout)
1. **程式碼格式化**: 自動格式化 JS/TS 檔案（30 秒超時）
   - **Triggers**: After editing `.js`, `.jsx`, `.ts`, `.tsx` files
   - **觸發時機**: 編輯 `.js`、`.jsx`、`.ts`、`.tsx` 檔案後
   - **Command**: `npx prettier --write` (or Biome)
   - **命令**: `npx prettier --write`（或 Biome）
   - **Behavior**: Formats code, shows feedback if errors found
   - **行為**: 格式化程式碼，如果發現錯誤則顯示回饋

2. **NPM Install**: Auto-install after package.json changes (60s timeout)
2. **NPM 安裝**: 在 package.json 變更後自動安裝（60 秒超時）
   - **Triggers**: After editing `package.json` files
   - **觸發時機**: 編輯 `package.json` 檔案後
   - **Command**: `npm install`
   - **命令**: `npm install`
   - **Behavior**: Installs dependencies, fails edit if installation fails
   - **行為**: 安裝依賴項，如果安裝失敗則編輯失敗

3. **Test Runner**: Run tests after test file changes (90s timeout)
3. **測試執行器**: 在測試檔案變更後執行測試（90 秒超時）
   - **Triggers**: After editing `.test.js`, `.test.jsx`, `.test.ts`, `.test.tsx` files
   - **觸發時機**: 編輯 `.test.js`、`.test.jsx`、`.test.ts`、`.test.tsx` 檔案後
   - **Command**: `npm test -- --findRelatedTests <file> --passWithNoTests`
   - **命令**: `npm test -- --findRelatedTests <file> --passWithNoTests`
   - **Behavior**: Runs related tests, shows results, non-blocking
   - **行為**: 執行相關測試，顯示結果，非阻塞式

4. **TypeScript Check**: Type-check TS/TSX files (30s timeout)
4. **TypeScript 檢查**: 對 TS/TSX 檔案進行類型檢查（30 秒超時）
   - **Triggers**: After editing `.ts`, `.tsx` files
   - **觸發時機**: 編輯 `.ts`、`.tsx` 檔案後
   - **Command**: `npx tsc --noEmit`
   - **命令**: `npx tsc --noEmit`
   - **Behavior**: Shows first errors only, non-blocking
   - **行為**: 僅顯示第一個錯誤，非阻塞式

## Hook Response Format
## 鉤子回應格式

```json
{
  "feedback": "Message to show",
  "suppressOutput": true,
  "block": true,
  "continue": false
}
```

## Environment Variables in Hooks
## 鉤子中的環境變數

- `$CLAUDE_TOOL_INPUT_FILE_PATH`: File being edited
- `$CLAUDE_TOOL_INPUT_FILE_PATH`: 正在編輯的檔案

- `$CLAUDE_TOOL_NAME`: Tool being used
- `$CLAUDE_TOOL_NAME`: 正在使用的工具

- `$CLAUDE_PROJECT_DIR`: Project root directory
- `$CLAUDE_PROJECT_DIR`: 專案根目錄

## Exit Codes
## 退出代碼

- `0`: Success
- `0`: 成功

- `1`: Non-blocking error (shows feedback)
- `1`: 非阻塞式錯誤（顯示回饋）

- `2`: Blocking error (PreToolUse only - blocks the action)
- `2`: 阻塞式錯誤（僅限 PreToolUse - 阻止操作）
