# Create Pull Request

## Overview

Create a GitHub Pull Request with a comprehensive description based on the current branch changes.

## Prerequisites

- Must be on a feature branch (not `main` or `prod`)
- Must have `gh` CLI installed and authenticated

## Steps

1. **Validate branch**

   - Run `git branch --show-current` to get current branch name
   - If on `main` or `prod`, stop and ask user to switch to a feature branch

2. **Check for uncommitted changes**

   - Run `git status` to check for staged/unstaged changes
   - If there are uncommitted changes:
     - Stage all relevant changes with `git add .`
     - Create a commit with a meaningful message based on the changes
     - Use `GIT_EDITOR=true` prefix to avoid editor blocking

3. **Ensure branch is pushed**

   - Run `git push -u origin HEAD` to push the branch to remote
   - Use `GIT_EDITOR=true` prefix for all git commands

4. **Analyze changes for PR description**

   - Run `git log main..HEAD --oneline` to see commits on this branch
   - Run `git diff main...HEAD --stat` to see changed files summary
   - Run `git diff main...HEAD` to see actual code changes

5. **Generate PR title and description**
   Based on the code analysis, generate:

   **Title:** `<feature_area>: <Title>` (80 characters or less)

   **Body:**

   ```
   ## Summary
   <1-2 sentence TLDR of what this PR does>

   ## Description
   - Bullet point explaining what's changing
   - Another bullet point if needed
   - Why this change was made (motivation/context)

   ## Test Plan
   - Step-by-step instructions to test this change
   - Cover the main functionality
   - Include edge cases if relevant

   ## Checklist
   - [ ] My code follows the style guidelines of this project
   - [ ] I have performed a self-review of my code
   - [ ] I have walked through my test plan
   ```

6. **🔍 VERIFICATION STEP - Ask for user approval**

   - Display the generated PR title and full description clearly
   - Format the output so it's easy to review
   - Ask the user: **"Does this PR title and description look good? (yes/no/suggest changes)"**
   - Wait for user response:
     - If **"yes"** or similar affirmative → Proceed to step 7
     - If **"no"** or user provides feedback → Modify the title/description based on their feedback, then ask for approval again
     - Repeat until user approves

7. **Create the PR**

   - Only proceed after user approval from step 6
   - Use `gh pr create` with the approved title and body
   - Target `main` as the base branch
   - Example command:
     ```bash
     gh pr create --title "feature: Add new component" --body "$(cat <<'EOF'
     ## Summary
     ...PR body here...
     EOF
     )"
     ```

8. **Return the PR link**
   - After PR creation, display the PR URL prominently so user can click it
   - Format: "✅ PR created: <URL>"

## Important

- Always use `GIT_EDITOR=true` prefix for git commands to avoid blocking
- Base the description on actual code changes, not assumptions
- Keep the title concise (80 chars max)
- Mark checklist items with [x] if they appear done based on the diff
- If PR creation fails, show the error and suggest fixes
- **NEVER create the PR without explicit user approval of the title and description**
