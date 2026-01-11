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

## Auditing Atoms Coverage

"Atoms" are the fundamental units in Claude Code: **skills**, **commands**, **agents**, and **hooks**. Use this audit process to ensure all atoms in your `.claude/` directory are exposed as installable plugins.

### Audit Script

Create `scripts/audit-atoms.sh` to check coverage:

```bash
#!/bin/bash
# Audits whether all atoms in .claude/ are exposed in plugins/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Atom Coverage Audit ==="
echo ""

missing=0

# Audit Skills
echo "Skills:"
for skill_dir in "$REPO_ROOT"/.claude/skills/*/; do
  skill_name=$(basename "$skill_dir")
  [ "$skill_name" = "README.md" ] && continue

  # Check if this skill is symlinked in any plugin
  found=$(find "$REPO_ROOT/plugins" -type l -name "$skill_name" 2>/dev/null | head -1)
  if [ -n "$found" ]; then
    echo "  ✓ $skill_name"
  else
    echo "  ✗ $skill_name (NOT IN ANY PLUGIN)"
    missing=$((missing + 1))
  fi
done

echo ""

# Audit Commands
echo "Commands:"
for cmd_file in "$REPO_ROOT"/.claude/commands/*.md; do
  cmd_name=$(basename "$cmd_file")

  found=$(find "$REPO_ROOT/plugins" -type l -name "$cmd_name" 2>/dev/null | head -1)
  if [ -n "$found" ]; then
    echo "  ✓ $cmd_name"
  else
    echo "  ✗ $cmd_name (NOT IN ANY PLUGIN)"
    missing=$((missing + 1))
  fi
done

echo ""

# Audit Agents
echo "Agents:"
for agent_file in "$REPO_ROOT"/.claude/agents/*.md; do
  agent_name=$(basename "$agent_file")

  found=$(find "$REPO_ROOT/plugins" -type l -name "$agent_name" 2>/dev/null | head -1)
  if [ -n "$found" ]; then
    echo "  ✓ $agent_name"
  else
    echo "  ✗ $agent_name (NOT IN ANY PLUGIN)"
    missing=$((missing + 1))
  fi
done

echo ""

# Audit Hooks (check for any hook files)
echo "Hooks:"
hook_files=$(find "$REPO_ROOT"/.claude/hooks -type f \( -name "*.sh" -o -name "*.js" -o -name "*.json" \) 2>/dev/null)
if [ -n "$hook_files" ]; then
  hooks_in_plugin=$(find "$REPO_ROOT/plugins" -path "*/hooks/*" -type l 2>/dev/null | head -1)
  if [ -n "$hooks_in_plugin" ]; then
    echo "  ✓ Hook system exposed in plugins"
  else
    echo "  ✗ Hook system NOT exposed in plugins"
    missing=$((missing + 1))
  fi
fi

echo ""
echo "=== Summary ==="
if [ $missing -eq 0 ]; then
  echo "All atoms are exposed in plugins!"
  exit 0
else
  echo "$missing atom(s) missing from plugins"
  exit 1
fi
```

### Running the Audit

```bash
chmod +x scripts/audit-atoms.sh
./scripts/audit-atoms.sh
```

Example output:
```
=== Atom Coverage Audit ===

Skills:
  ✓ testing-patterns
  ✓ react-ui-patterns
  ✗ new-skill (NOT IN ANY PLUGIN)

Commands:
  ✓ pr-review.md
  ✓ ticket.md

Agents:
  ✓ code-reviewer.md

Hooks:
  ✓ Hook system exposed in plugins

=== Summary ===
1 atom(s) missing from plugins
```

### Integrating with CI

Add to your GitHub Actions workflow:

```yaml
- name: Audit atom coverage
  run: ./scripts/audit-atoms.sh
```

### Quick Manual Check

To quickly see what's in `.claude/` vs what's symlinked:

```bash
# List all atoms in .claude/
echo "=== Skills ===" && ls .claude/skills/
echo "=== Commands ===" && ls .claude/commands/
echo "=== Agents ===" && ls .claude/agents/
echo "=== Hooks ===" && ls .claude/hooks/

# List all symlinks in plugins/
find plugins -type l | sort
```

### When Atoms Are Missing

If the audit finds missing atoms:

1. **Decide on packaging**: Should it be standalone or bundled?
2. **Create the plugin structure**:
   ```bash
   mkdir -p plugins/new-skill/{.claude-plugin,skills}
   ln -s ../../../.claude/skills/new-skill plugins/new-skill/skills/new-skill
   ```
3. **Add plugin.json manifest**
4. **Update marketplace.json**
5. **Re-run the audit** to verify

## Content Change Tracking with Git

Use git to detect which atoms have changed since the last release. This is simpler and more reliable than maintaining separate checksum files.

### Version Tagging Strategy

Tag releases to mark version boundaries:

```bash
# Tag a marketplace release
git tag -a v1.0.0 -m "Initial marketplace release"

# Tag individual plugin releases (optional, for granular tracking)
git tag -a testing-patterns/v1.0.0 -m "testing-patterns v1.0.0"
```

### Check Changes Since Last Release

Create `scripts/check-atom-changes.sh`:

```bash
#!/bin/bash
# Detects which atoms have changed since the last release tag
# Usage: ./scripts/check-atom-changes.sh [base-ref]
#   base-ref: git ref to compare against (default: latest tag)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Get base reference (default to latest tag)
BASE_REF="${1:-$(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~10")}"

echo "=== Atom Changes Since $BASE_REF ==="
echo ""

changes=0

check_changes() {
  local atom_type="$1"
  local atom_path="$2"
  local atom_name="$3"

  # Check if path has changes since base ref
  if git diff --quiet "$BASE_REF" -- "$atom_path" 2>/dev/null; then
    echo "  ✓ $atom_name (unchanged)"
  else
    echo "  CHANGED: $atom_name"
    # Show brief summary of changes
    local lines_changed=$(git diff --stat "$BASE_REF" -- "$atom_path" 2>/dev/null | tail -1)
    [ -n "$lines_changed" ] && echo "    $lines_changed"
    changes=$((changes + 1))
  fi
}

# Check skills
echo "Skills:"
for skill_dir in "$REPO_ROOT"/.claude/skills/*/; do
  [ ! -d "$skill_dir" ] && continue
  skill_name=$(basename "$skill_dir")
  check_changes "skill" "$skill_dir" "$skill_name"
done

echo ""

# Check commands
echo "Commands:"
for cmd_file in "$REPO_ROOT"/.claude/commands/*.md; do
  [ ! -f "$cmd_file" ] && continue
  cmd_name=$(basename "$cmd_file" .md)
  check_changes "command" "$cmd_file" "$cmd_name"
done

echo ""

# Check agents
echo "Agents:"
for agent_file in "$REPO_ROOT"/.claude/agents/*.md; do
  [ ! -f "$agent_file" ] && continue
  agent_name=$(basename "$agent_file" .md)
  check_changes "agent" "$agent_file" "$agent_name"
done

echo ""

# Check hooks
echo "Hooks:"
hooks_dir="$REPO_ROOT/.claude/hooks"
if [ -d "$hooks_dir" ]; then
  if git diff --quiet "$BASE_REF" -- "$hooks_dir" 2>/dev/null; then
    echo "  ✓ hooks (unchanged)"
  else
    echo "  CHANGED: hooks"
    changes=$((changes + 1))
  fi
fi

echo ""
echo "=== Summary ==="
echo "Comparing against: $BASE_REF"
if [ $changes -eq 0 ]; then
  echo "No atoms have changed"
  exit 0
else
  echo "$changes atom(s) changed - consider version bump for affected plugins"
  echo ""
  echo "To see full diff for a specific atom:"
  echo "  git diff $BASE_REF -- .claude/skills/SKILL_NAME/"
  exit 1
fi
```

### View Detailed Changes

```bash
# See what changed in a specific skill since last release
git diff v1.0.0 -- .claude/skills/testing-patterns/

# See commit history for a skill
git log --oneline v1.0.0..HEAD -- .claude/skills/testing-patterns/

# See which files changed in an atom
git diff --name-only v1.0.0 -- .claude/skills/testing-patterns/
```

### Workflow

1. **Before releasing**, check what changed:
   ```bash
   ./scripts/check-atom-changes.sh
   # Or compare against a specific version:
   ./scripts/check-atom-changes.sh v1.0.0
   ```

2. **For changed atoms**, bump version in:
   - `plugins/{name}/.claude-plugin/plugin.json`
   - `.claude-plugin/marketplace.json`

3. **Tag the release**:
   ```bash
   git tag -a v1.1.0 -m "Release v1.1.0"
   git push --tags
   ```

### CI Integration

```yaml
- name: Check for unreleased changes
  run: |
    # Fail if atoms changed since last tag but versions weren't bumped
    ./scripts/check-atom-changes.sh
```

### Why Git-Based Tracking is Better

| Aspect | Checksum File | Git-Based |
|--------|---------------|-----------|
| Extra files to maintain | Yes | No |
| Shows what changed | Hash only | Full diff |
| History | None | Complete |
| Can get out of sync | Yes | No |
| Works offline | Yes | Yes |
| Native to workflow | No | Yes |

### Quick Commands

```bash
# What changed since last tag?
git diff $(git describe --tags --abbrev=0) -- .claude/

# List commits touching a specific skill
git log --oneline -- .claude/skills/testing-patterns/

# Find which release introduced a change
git log --tags --oneline -- .claude/skills/testing-patterns/SKILL.md
```
