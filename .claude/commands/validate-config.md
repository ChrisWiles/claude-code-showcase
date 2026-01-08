---
description: Validate Claude Code configuration files (settings.json, skill-rules.json, SKILL.md files)
allowed-tools: Bash(node:*, cat, ls), Read, Grep
---

# Configuration Validation Command

Validate your Claude Code configuration to ensure everything is properly set up.

## Your Task

Validate the Claude Code configuration in this repository:

1. **Check settings.json**
   - Verify JSON syntax
   - Check for required fields
   - Validate hook configurations

2. **Check skill-rules.json**
   - Verify JSON syntax
   - Validate against schema if present
   - Check for duplicate skill names
   - Verify all referenced skills exist

3. **Check SKILL.md files**
   - Verify frontmatter format
   - Check required fields (name, description)
   - Validate skill names match directory names
   - Check for broken references to other skills

4. **Check MCP configuration**
   - Verify .mcp.json syntax
   - Check server configurations

5. **Report findings**
   - List any errors found
   - Suggest fixes
   - Confirm if configuration is valid

## Validation Steps

```bash
# 1. Validate settings.json
if [ -f .claude/settings.json ]; then
  echo "Validating .claude/settings.json..."
  node -e "JSON.parse(require('fs').readFileSync('.claude/settings.json', 'utf-8'))" && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
fi

# 2. Validate skill-rules.json
if [ -f .claude/hooks/skill-rules.json ]; then
  echo "Validating .claude/hooks/skill-rules.json..."
  node -e "JSON.parse(require('fs').readFileSync('.claude/hooks/skill-rules.json', 'utf-8'))" && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
fi

# 3. Validate MCP config
if [ -f .mcp.json ]; then
  echo "Validating .mcp.json..."
  node -e "JSON.parse(require('fs').readFileSync('.mcp.json', 'utf-8'))" && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
fi

# 4. Check SKILL.md files
echo "Checking SKILL.md files..."
find .claude/skills -name "SKILL.md" -type f
```

## Output Format

Provide a summary like:

```
Configuration Validation Report
================================

✓ .claude/settings.json - Valid
✓ .claude/hooks/skill-rules.json - Valid
✓ .mcp.json - Valid
✓ Found 8 SKILL.md files

Skills validated:
  ✓ testing-patterns
  ✓ react-ui-patterns
  ✓ graphql-schema
  ✓ formik-patterns
  ✓ core-components
  ✓ systematic-debugging
  ✓ security-best-practices
  ✓ performance-optimization

⚠ Warnings:
  - Skill 'non-existent-skill' referenced in skill-rules.json but not found

All critical checks passed!
```
