---
description: Work on a JIRA/Linear ticket end-to-end
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(gh:*), Bash(uv:*), Bash(python:*), mcp__jira__*, mcp__github__*, mcp__linear__*
---

# Ticket Workflow

Work on ticket: $ARGUMENTS

## Instructions

### 1. Read the Ticket

First, fetch and understand the ticket:

```
Use the JIRA/Linear MCP tools to:
- Get ticket details (title, description, acceptance criteria)
- Check linked tickets or epics
- Review any comments or attachments
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
git checkout -b {initials}/{ticket-id}-{brief-description}
```

### 4. Implement the Changes

- Follow project patterns (check relevant skills)
- Write tests first (TDD)
- Make incremental commits

### 5. Run Quality Checks

Before committing:
```bash
uv run ruff check .
uv run ruff format .
uv run pyright
uv run pytest
```

### 6. Update the Ticket

As you work:
- Add comments with progress updates
- Update status (In Progress → In Review)
- Log any blockers or questions

### 7. Create PR and Link

When ready:
- Create PR with `gh pr create`
- Link the PR to the ticket
- Add ticket ID to PR title: `feat(PROJ-123): description`

### 8. If You Find a Bug

If you discover an unrelated bug while working:
1. Create a new ticket with details
2. Link it to the current ticket if related
3. Note it in the PR description
4. Continue with original task

## Example Workflow

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
   Found: apps/users/views.py
   Found: templates/users/profile.html

3. Creating branch: jd/PROJ-123-avatar-upload

4. [Implements feature with TDD approach]

5. Running quality checks...
   - ruff check: passed
   - pyright: passed
   - pytest: 15 tests passed

6. Updating JIRA status to "In Review"...
   Adding comment: "Implementation complete, PR ready for review"

7. Creating PR and linking to PROJ-123...
   PR #456 created: feat(PROJ-123): add avatar upload to profile
```
