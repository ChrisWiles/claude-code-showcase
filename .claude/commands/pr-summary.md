---
name: pr-summary
description: Generate a summary for the current branch changes
allowed-tools: Bash(git:*)
---

# PR Summary

Generate a pull request summary for the current branch.

## Instructions

1. **Analyze changes**:
   ```bash
   git log main..HEAD --oneline
   git diff main...HEAD --stat
   ```

2. **Generate summary** with:
   - Brief description of what changed
   - List of files modified
   - Breaking changes (if any)
   - Testing notes

3. **Format as PR body**:
   ```markdown
   ## Summary
   [1-3 bullet points describing the changes]

   ## Changes
   - [List of significant changes]

   ## Test Plan
   - [ ] [Testing checklist items]
   ```
