---
name: code-quality
description: Run code quality checks on a directory
allowed-tools: Read, Glob, Grep, Bash(npm:*), Bash(npx:*)
---

# Code Quality Review

Review code quality in: $ARGUMENTS

## Instructions

1. **Identify files to review**:
   - Find all `.ts` and `.tsx` files in the directory
   - Exclude test files and generated files

2. **Run automated checks**:
   ```bash
   npm run lint -- $ARGUMENTS
   npm run typecheck
   ```

3. **Manual review checklist**:
   - [ ] No TypeScript `any` types
   - [ ] Proper error handling
   - [ ] Loading states handled correctly
   - [ ] Empty states for lists
   - [ ] Mutations have onError handlers
   - [ ] Buttons disabled during async operations

4. **Report findings** organized by severity:
   - Critical (must fix)
   - Warning (should fix)
   - Suggestion (could improve)
