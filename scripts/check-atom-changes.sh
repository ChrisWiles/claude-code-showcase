#!/bin/bash
# Detects which atoms have changed since the last release tag
# Usage: ./scripts/check-atom-changes.sh [base-ref]
#   base-ref: git ref to compare against (default: latest tag)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Get base reference (default to latest tag, or HEAD~10 if no tags)
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
