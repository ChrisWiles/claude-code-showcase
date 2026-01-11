#!/bin/bash
# Validates that all symlinks in the plugins directory point to valid targets
# Run after git pull to ensure marketplace integrity

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PLUGINS_DIR="$REPO_ROOT/plugins"

if [ ! -d "$PLUGINS_DIR" ]; then
  echo "No plugins directory found at $PLUGINS_DIR"
  exit 0
fi

errors=0
checked=0

echo "Validating symlinks in plugins/..."

while IFS= read -r -d '' link; do
  checked=$((checked + 1))
  if [ ! -e "$link" ]; then
    echo "  BROKEN: $link -> $(readlink "$link")"
    errors=$((errors + 1))
  fi
done < <(find "$PLUGINS_DIR" -type l -print0)

echo ""
echo "Checked $checked symlinks"

if [ $errors -eq 0 ]; then
  echo "All symlinks are valid"
  exit 0
else
  echo "$errors broken symlink(s) found"
  exit 1
fi
