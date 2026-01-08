---
description: Work on a JIRA/Linear ticket end-to-end / 端到端處理 JIRA/Linear 工單
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(gh:*), Bash(npm:*), mcp__jira__*, mcp__github__*, mcp__linear__*
---

# Ticket Workflow
# 工單工作流程

Work on ticket: $ARGUMENTS

處理工單：$ARGUMENTS

## Instructions
## 指令說明

### 1. Read the Ticket
### 1. 閱讀工單

First, fetch and understand the ticket:

首先，獲取並理解工單：

```
Use the JIRA/Linear MCP tools to:
- Get ticket details (title, description, acceptance criteria)
- Check linked tickets or epics
- Review any comments or attachments
```

```
使用 JIRA/Linear MCP 工具：
- 獲取工單詳情（標題、描述、驗收標準）
- 檢查關聯的工單或史詩
- 查看任何評論或附件
```

Summarize:

總結：

- What needs to be done
- 需要完成什麼
- Acceptance criteria
- 驗收標準
- Any blockers or dependencies
- 任何阻礙或依賴

### 2. Explore the Codebase
### 2. 探索程式碼庫

Before coding:

開始編碼前：

- Search for related code
- 搜尋相關程式碼
- Understand the current implementation
- 理解當前實作
- Identify files that need changes
- 識別需要變更的檔案

### 3. Create a Branch
### 3. 建立分支

```bash
git checkout -b {initials}/{ticket-id}-{brief-description}
```

### 4. Implement the Changes
### 4. 實作變更

- Follow project patterns (check relevant skills)
- 遵循專案模式（檢查相關技能）
- Write tests first (TDD)
- 先寫測試（TDD）
- Make incremental commits
- 進行增量提交

### 5. Update the Ticket
### 5. 更新工單

As you work:

工作時：

- Add comments with progress updates
- 添加進度更新評論
- Update status (In Progress → In Review)
- 更新狀態（進行中 → 審查中）
- Log any blockers or questions
- 記錄任何阻礙或問題

### 6. Create PR and Link
### 6. 建立並連結 PR

When ready:

準備就緒時：

- Create PR with `gh pr create`
- 使用 `gh pr create` 建立 PR
- Link the PR to the ticket
- 將 PR 連結到工單
- Add ticket ID to PR title: `feat(PROJ-123): description`
- 在 PR 標題中添加工單 ID：`feat(PROJ-123): description`

### 7. If You Find a Bug
### 7. 如果發現錯誤

If you discover an unrelated bug while working:

如果在工作時發現無關的錯誤：

1. Create a new ticket with details
1. 建立新工單並提供詳細資訊
2. Link it to the current ticket if related
2. 如果相關，將其連結到當前工單
3. Note it in the PR description
3. 在 PR 描述中註明
4. Continue with original task
4. 繼續完成原始任務

## Example Workflow
## 工作流程範例

```
Me: /ticket PROJ-123

Claude:
1. Fetching PROJ-123 from JIRA...
   Title: Add user profile avatar upload
   Description: Users should be able to upload a profile picture...
   Acceptance Criteria:
   - [ ] Upload button on profile page
   - [ ] Support JPG/PNG up to 5MB
   - [ ] Show loading state during upload

2. Searching codebase for profile-related code...
   Found: src/screens/Profile/ProfileScreen.tsx
   Found: src/components/Avatar/Avatar.tsx

3. Creating branch: cw/PROJ-123-avatar-upload

4. [Implements feature with TDD approach]

5. Updating JIRA status to "In Review"...
   Adding comment: "Implementation complete, PR ready for review"

6. Creating PR and linking to PROJ-123...
   PR #456 created: feat(PROJ-123): add avatar upload to profile
```
