---
description: Work on a GitHub Issue end-to-end
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(gh:*), Bash(npm:*), mcp__github__*
---

# GitHub Issue Workflow

Work on issue: $ARGUMENTS

## Instructions

### 1. Read the Issue

First, fetch and understand the GitHub Issue:

```
Use the GitHub MCP tools or CLI to:
- Get issue details (title, description, labels)
- Check linked issues or milestones
- Review any comments
- Check acceptance criteria in the issue body
```

Summarize:
- What needs to be done
- Acceptance criteria
- Any blockers or dependencies

### 2. Explore the Codebase

Before coding:
- Search for related code
- Understand the current implementation
- Identify files that need changes

### 3. Create a Branch

```bash
git checkout -b {initials}/{issue-number}-{brief-description}
# Example: git checkout -b jd/42-add-user-auth
```

### 4. Implement the Changes

- Follow project patterns (check relevant skills)
- Write tests first (TDD)
- Make incremental commits

### 5. Update the Issue

As you work:
- Add comments with progress updates
- Update labels if needed (in-progress, needs-review)
- Log any blockers or questions

### 6. Create PR and Link

When ready:
- Create PR with `gh pr create`
- Reference the issue in the PR body: `Closes #<issue-number>`
- PR title format: `feat(#42): description` or `fix(#42): description`

### 7. If You Find a Bug

If you discover an unrelated bug while working:
1. Create a new issue with details
2. Link it to the current issue if related
3. Note it in the PR description
4. Continue with original task

## Example Workflow

```
Me: /ticket 42

Claude:
1. Fetching Issue #42 from GitHub...
   Title: Add user profile avatar upload
   Description: Users should be able to upload a profile picture...
   Labels: enhancement, frontend
   
   Acceptance Criteria:
   - [ ] Upload button on profile page
   - [ ] Support JPG/PNG up to 5MB
   - [ ] Show loading state during upload

2. Searching codebase for profile-related code...
   Found: src/screens/Profile/ProfileScreen.tsx
   Found: src/components/Avatar/Avatar.tsx

3. Creating branch: cw/42-avatar-upload

4. [Implements feature with TDD approach]

5. Adding comment to Issue #42: "Implementation complete, PR ready for review"

6. Creating PR and linking to Issue #42...
   PR #56 created: feat(#42): add avatar upload to profile
   Body includes: Closes #42
```

## GitHub Issue Commands Reference

```bash
# View issue details
gh issue view 42

# List issues assigned to you
gh issue list --assignee @me

# Add comment to issue
gh issue comment 42 --body "Progress update: ..."

# Add label to issue
gh issue edit 42 --add-label "in-progress"

# Create linked PR
gh pr create --title "feat(#42): description" --body "Closes #42"
```
