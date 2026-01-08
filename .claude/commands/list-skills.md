---
description: List all available skills and their descriptions
allowed-tools: Read, Grep, Bash(ls, cat)
---

# List Skills Command

Show all available skills in this project with their descriptions.

## Your Task

1. **Find all SKILL.md files** in `.claude/skills/`

2. **Extract information** from each:
   - Skill name (from frontmatter)
   - Description (from frontmatter)
   - File path

3. **Display in a table format**:

```
Available Skills
================

Name                          Description
---------------------------- --------------------------------------------------
testing-patterns             Jest testing patterns and TDD workflow
react-ui-patterns           React patterns, hooks, loading states, error handling
graphql-schema              GraphQL queries, mutations, and code generation
formik-patterns             Formik form handling with validation
core-components             Core component library and design system
systematic-debugging        Four-phase debugging with root cause analysis
security-best-practices     Security best practices including input validation
performance-optimization    Performance optimization for React and Node.js

Total: 8 skills

Usage: Invoke a skill by asking Claude to use it
Example: "Use the testing-patterns skill to help me write a test"
```

4. **Optionally show details** if user specifies a skill name:
   - Full skill content
   - Related skills
   - Example usage

## Example Usage

```
/list-skills                    # Show all skills
/list-skills testing-patterns   # Show details for testing-patterns
```
