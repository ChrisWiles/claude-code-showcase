---
description: Run code quality checks on a directory
allowed-tools: Read, Glob, Grep, Bash(uv:*)
---

# Code Quality Review

Review code quality in: $ARGUMENTS

## Instructions

1. **Identify files to review**:
   - Find all `.py` files in the directory
   - Exclude migrations, `__pycache__`, and generated files

2. **Run automated checks**:
   ```bash
   uv run ruff check $ARGUMENTS
   uv run ruff format --check $ARGUMENTS
   uv run pyright $ARGUMENTS
   uv run pytest $ARGUMENTS -v
   ```

3. **Manual review checklist**:
   - [ ] No `Any` types without justification
   - [ ] Proper error handling (no silent exceptions)
   - [ ] N+1 queries avoided (select_related/prefetch_related)
   - [ ] Forms have proper validation
   - [ ] Views return correct HTTP status codes
   - [ ] HTMX partials handle HX-Request header
   - [ ] Celery tasks are idempotent
   - [ ] Tests use factories, not raw object creation

4. **Report findings** organized by severity:
   - Critical (must fix)
   - Warning (should fix)
   - Suggestion (could improve)
