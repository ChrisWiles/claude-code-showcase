#!/usr/bin/env bash
set -euo pipefail

branch="$(git branch --show-current 2>/dev/null || true)"

if [[ "${branch}" == "main" || "${branch}" == "master" ]]; then
  printf '%s\n' '{"block": true, "message": "Cannot edit on main/master branch. Create a feature branch first."}'
  exit 2
fi

exit 0

