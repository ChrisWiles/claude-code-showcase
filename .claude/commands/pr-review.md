---
name: pr-review
description: Review a pull request using project standards
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(gh:*)
---

# PR Review

Review the pull request: $ARGUMENTS

## Instructions

1. **Get PR information**:
   - Run `gh pr view $ARGUMENTS` to get PR details
   - Run `gh pr diff $ARGUMENTS` to see changes

2. **Read review standards**:
   - Read `.claude/agents/code-reviewer.md` for the review checklist

3. **Apply the checklist** to all changed files:
   - TypeScript strict mode compliance
   - Error handling patterns
   - Loading/error/empty states
   - Test coverage
   - Documentation updates

4. **Provide structured feedback**:
   - **Critical**: Must fix before merge
   - **Warning**: Should fix
   - **Suggestion**: Nice to have

5. **Post review comments** using `gh pr comment`
