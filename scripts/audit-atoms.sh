#!/bin/bash
# Audits whether all atoms in .claude/ are exposed in plugins/
# Atoms = skills, commands, agents, hooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Atom Coverage Audit ==="
echo ""

missing=0

# Audit Skills
echo "Skills:"
for skill_dir in "$REPO_ROOT"/.claude/skills/*/; do
  [ ! -d "$skill_dir" ] && continue
  skill_name=$(basename "$skill_dir")

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
  [ ! -f "$cmd_file" ] && continue
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
  [ ! -f "$agent_file" ] && continue
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
hook_files=$(find "$REPO_ROOT"/.claude/hooks -type f \( -name "*.sh" -o -name "*.js" -o -name "*.json" \) 2>/dev/null | head -1)
if [ -n "$hook_files" ]; then
  hooks_in_plugin=$(find "$REPO_ROOT/plugins" -path "*/hooks/*" -type l 2>/dev/null | head -1)
  if [ -n "$hooks_in_plugin" ]; then
    echo "  ✓ Hook system exposed in plugins"
  else
    echo "  ✗ Hook system NOT exposed in plugins"
    missing=$((missing + 1))
  fi
else
  echo "  (no hooks found)"
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
