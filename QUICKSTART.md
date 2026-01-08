# Claude Code Quick Start Guide

Get up and running with Claude Code configuration in 5 minutes.

## Prerequisites

- Claude Code installed
- A Git repository (project)
- Node.js installed (for hooks)

## Step 1: Create Basic Structure (1 minute)

```bash
# Create the .claude directory structure
mkdir -p .claude/{agents,commands,hooks,skills}

# Create gitignore for local settings
echo "settings.local.json" > .claude/.gitignore
```

## Step 2: Add Project Memory (2 minutes)

Create `CLAUDE.md` in your project root:

```markdown
# Your Project Name

## Quick Facts
- **Stack**: [Your tech stack, e.g., React, TypeScript, Node.js]
- **Test Command**: `npm test`
- **Build Command**: `npm run build`
- **Lint Command**: `npm run lint`

## Key Directories
- `src/` - Source code
- `tests/` - Test files

## Code Style
- [Your coding standards]

## Critical Rules
- [Important constraints or requirements]
```

## Step 3: Add Essential Hooks (1 minute)

Create `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "[ \"$(git branch --show-current)\" != \"main\" ] || { echo '{\"block\": true, \"message\": \"Cannot edit on main branch\"}' >&2; exit 2; }",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

This prevents editing on the main branch.

## Step 4: Add Your First Skill (1 minute)

Create `.claude/skills/testing-patterns/SKILL.md`:

```markdown
---
name: testing-patterns
description: Testing patterns for this project. Use when writing or modifying tests.
---

# Testing Patterns

## Test Structure
- Use `describe` for grouping
- Use `it` or `test` for individual tests
- Follow AAA: Arrange, Act, Assert

## Example
\`\`\`typescript
describe('MyComponent', () => {
  it('renders correctly', () => {
    // Arrange
    const props = { title: 'Test' };
    
    // Act
    const { getByText } = render(<MyComponent {...props} />);
    
    // Assert
    expect(getByText('Test')).toBeInTheDocument();
  });
});
\`\`\`
```

## Step 5: Test It Out

1. **Open Claude Code** in your project
2. **Test the skill**: Ask Claude "Write a test for my login component"
3. **Test the hook**: Try editing a file on main branch (should be blocked)

## Next Steps

### Add More Skills

Copy skills from this repository:
- `testing-patterns` - Test writing patterns
- `react-ui-patterns` - React component patterns
- `security-best-practices` - Security guidelines
- `performance-optimization` - Performance tips

### Add Automation

Install the skill evaluation hook for automatic skill suggestions:

```bash
# Copy hook files
cp -r [this-repo]/.claude/hooks/ .claude/hooks/

# Update settings.json to include the hook
```

### Add GitHub Workflows

Set up automated code reviews:

```bash
# Copy workflow files
cp [this-repo]/.github/workflows/pr-claude-code-review.yml .github/workflows/
```

### Configure MCP Servers

Connect to external tools (JIRA, GitHub, etc.):

1. Create `.mcp.json` in project root
2. Add server configurations
3. Set environment variables

## Common Issues

### Hook not running
- Check Node.js is installed: `node --version`
- Verify hook file has execute permissions
- Check for syntax errors in settings.json

### Skill not activating
- Ensure SKILL.md has proper frontmatter
- Check skill name matches directory name
- Verify description includes relevant keywords

### MCP server not connecting
- Verify environment variables are set
- Check server is installed: `npx -y @anthropic/mcp-[server-name] --version`
- Review server logs for errors

## Getting Help

- Review the [full README](README.md) for detailed documentation
- Check `.claude/settings.md` for hook documentation
- Explore example skills in `.claude/skills/`
- Run `/validate-config` command to check your setup

## Summary

You now have:
- ✅ Project memory (CLAUDE.md)
- ✅ Branch protection hook
- ✅ Your first skill
- ✅ Basic configuration

Keep iterating! Add more skills and hooks as you discover patterns in your workflow.
