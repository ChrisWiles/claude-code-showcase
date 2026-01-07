# Claude Code Settings Documentation

## Environment Variables

- `INSIDE_CLAUDE_CODE`: "1" - Indicates code is running inside Claude Code
- `BASH_DEFAULT_TIMEOUT_MS`: "420000" - Default timeout for bash commands (7 minutes)
- `BASH_MAX_TIMEOUT_MS`: "420000" - Maximum timeout for bash commands (7 minutes)

## Hooks

### UserPromptSubmit

- **Skill Evaluation**: Analyzes prompts and suggests relevant skills
  - **Script**: `.claude/hooks/skill-eval.sh`
  - **Behavior**: Matches keywords, file paths, and patterns to suggest skills
  - **Timeout**: 5s

### PreToolUse

- **Main Branch Protection**: Prevents edits on main branch (5s timeout)
  - **Triggers**: Before editing files with Edit, MultiEdit, or Write tools
  - **Behavior**: Blocks file edits when on main branch, suggests creating feature branch

### PostToolUse

1. **Ruff Formatting**: Auto-format Python files (30s timeout)
   - **Triggers**: After editing `.py` files
   - **Command**: `uv run ruff format`
   - **Behavior**: Formats code, suppresses output on success, shows feedback on failure

2. **Dependency Installation**: Auto-install after dependency changes (60s timeout)
   - **Triggers**: After editing `pyproject.toml` or `requirements*.txt` files
   - **Command**: `uv sync`
   - **Behavior**: Installs dependencies, suppresses output on success, shows feedback on failure

3. **Test Runner**: Run tests after test file changes (90s timeout)
   - **Triggers**: After editing `test_*.py`, `*_test.py`, or `*/tests/*.py` files
   - **Command**: `uv run pytest <file> -x -q`
   - **Behavior**: Runs tests in modified file, shows last 30 lines of output, non-blocking

4. **Pyright Type Check**: Type-check Python files (30s timeout)
   - **Triggers**: After editing `.py` files
   - **Command**: `uv run pyright`
   - **Behavior**: Shows first 20 lines of errors only, non-blocking, exit 0

5. **Ruff Linting**: Lint Python files (30s timeout)
   - **Triggers**: After editing `.py` files
   - **Command**: `uv run ruff check`
   - **Behavior**: Shows first 20 lines of issues only, non-blocking, exit 0

## Hook Response Format

```json
{
  "feedback": "Message to show",
  "suppressOutput": true,
  "block": true,
  "continue": false
}
```

## Environment Variables in Hooks

- `$CLAUDE_TOOL_INPUT_FILE_PATH`: File being edited
- `$CLAUDE_TOOL_NAME`: Tool being used
- `$CLAUDE_PROJECT_DIR`: Project root directory

## Exit Codes

- `0`: Success
- `1`: Non-blocking error (shows feedback)
- `2`: Blocking error (PreToolUse only - blocks the action)
