---
name: plugin-marketplace
description: Create a Claude Code plugin marketplace from existing skills, commands, agents, and hooks using symlinks. Use when converting a showcase repo to an installable marketplace, or when you need to share Claude Code components with others.
---

# Plugin Marketplace Pattern

Transform a showcase repository into an installable Claude Code plugin marketplace while maintaining a single source of truth using symlinks.

## When to Use

- Converting existing `.claude/` components to installable plugins
- Creating a shareable marketplace from your team's patterns
- Maintaining both showcase documentation and installable packages
- Enabling `git pull` updates to flow through to installed plugins

## Architecture

```
your-repo/
├── .claude/                      # Source of truth (showcase structure)
│   ├── skills/
│   │   └── testing-patterns/
│   │       └── SKILL.md
│   ├── commands/
│   │   └── pr-review.md
│   └── agents/
│       └── code-reviewer.md
│
├── .claude-plugin/               # Marketplace manifest
│   └── marketplace.json
│
└── plugins/                      # Plugin packages (symlinks)
    ├── testing-patterns/
    │   ├── .claude-plugin/
    │   │   └── plugin.json       # Real file
    │   └── skills/
    │       └── testing-patterns/ # Symlink → ../../../.claude/skills/testing-patterns
    └── code-review-suite/
        ├── .claude-plugin/
        │   └── plugin.json
        ├── commands/             # Symlink to specific files
        └── agents/               # Symlink to specific files
```

## Step-by-Step Implementation

### 1. Create Marketplace Manifest

Create `.claude-plugin/marketplace.json` at repo root:

```json
{
  "name": "your-marketplace-name",
  "description": "Description of your marketplace",
  "owner": {
    "name": "Your Name or Org",
    "url": "https://github.com/you/repo"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "What this plugin does",
      "version": "1.0.0",
      "keywords": ["keyword1", "keyword2"]
    }
  ]
}
```

### 2. Create Plugin Structure with Symlinks

For each plugin:

```bash
# Create plugin directory
mkdir -p plugins/testing-patterns/.claude-plugin
mkdir -p plugins/testing-patterns/skills

# Create symlink to source skill
ln -s ../../../.claude/skills/testing-patterns plugins/testing-patterns/skills/testing-patterns
```

### 3. Create Plugin Manifest

Each plugin needs `.claude-plugin/plugin.json`:

```json
{
  "name": "testing-patterns",
  "version": "1.0.0",
  "description": "Jest testing patterns, TDD workflow",
  "keywords": ["testing", "jest", "tdd"],
  "skills": "./skills/"
}
```

### 4. Bundle Related Components

For plugins with multiple components:

```bash
# Create bundle plugin
mkdir -p plugins/code-review-suite/{.claude-plugin,commands,agents}

# Symlink individual files
ln -s ../../../.claude/commands/code-quality.md plugins/code-review-suite/commands/code-quality.md
ln -s ../../../.claude/agents/code-reviewer.md plugins/code-review-suite/agents/code-reviewer.md
```

## Plugin.json Component Fields

| Field | Type | Description |
|-------|------|-------------|
| `skills` | string | Path to skills directory |
| `commands` | string/array | Path to commands or array of specific files |
| `agents` | string | Path to agents directory |
| `hooks` | string | Path to hooks JSON configuration |
| `mcpServers` | string | Path to MCP configuration |

## User Installation

Once structured, users install from your marketplace:

```bash
# Add your marketplace
/plugin marketplace add owner/repo-name

# Install specific plugins
/plugin install testing-patterns@repo-name
/plugin install code-review-suite@repo-name
```

## Why Symlinks Work

1. **Claude Code honors symlinks** when copying plugins to cache
2. **Single source of truth** - edits in `.claude/` flow to plugins
3. **Git pull updates** - pulling changes automatically updates symlinked content
4. **No build step** - no sync scripts or generated files needed

## Validation Script

Optional: Add a script to verify symlinks are intact:

```bash
#!/bin/bash
# scripts/validate-symlinks.sh

errors=0
for link in $(find plugins -type l); do
  if [ ! -e "$link" ]; then
    echo "Broken symlink: $link"
    errors=$((errors + 1))
  fi
done

if [ $errors -eq 0 ]; then
  echo "All symlinks valid"
  exit 0
else
  echo "$errors broken symlinks found"
  exit 1
fi
```

## Anti-Patterns

### Don't Duplicate Content

```bash
# Bad - copying files
cp .claude/skills/testing-patterns plugins/testing-patterns/skills/

# Good - symlinking
ln -s ../../../.claude/skills/testing-patterns plugins/testing-patterns/skills/testing-patterns
```

### Don't Use Absolute Paths

```bash
# Bad - breaks on other machines
ln -s /home/user/repo/.claude/skills/testing-patterns plugins/testing-patterns/skills/

# Good - relative paths
ln -s ../../../.claude/skills/testing-patterns plugins/testing-patterns/skills/testing-patterns
```

## Integration with Git

Symlinks are tracked by Git, so:
- Collaborators get the same structure
- CI/CD can validate the marketplace
- Pull requests can update both source and plugin structure

## Updating Versions

When updating a plugin version:
1. Update version in `.claude-plugin/marketplace.json`
2. Update version in `plugins/{name}/.claude-plugin/plugin.json`
3. Source content updates flow automatically via symlinks
