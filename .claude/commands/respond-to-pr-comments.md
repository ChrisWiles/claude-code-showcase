Task is to resolve all active comments on PR in GitHub.

First enumerate them, and then let's discuss each one. Wait for direction from me before moving forward on a fix.

Use `gh` CLI to perform operations

# Get PR number from current branch
gh pr view --json number --jq .number

# Get all comments
gh pr view --json comments --jq '.comments[] | {id: .id, body: .body, author: .author.login}'

# Mark comment as resolved
gh pr comment resolve <comment-id>