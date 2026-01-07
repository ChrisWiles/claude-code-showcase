# Django Project

> Claude Code configuration for Django projects with HTMX and modern Python tooling.

## Quick Facts

- **Stack**: Django, PostgreSQL, HTMX
- **Package Manager**: uv
- **Test Command**: `uv run pytest`
- **Lint Command**: `uv run ruff check .`
- **Format Command**: `uv run ruff format .`
- **Type Check**: `uv run pyright`

## Key Directories

- `apps/` - Django applications
- `config/` - Django settings and root URLconf
- `templates/` - Django/Jinja2 templates
- `static/` - CSS, JavaScript, images
- `tests/` - Test files
- `tasks/` - Celery tasks

## Code Style

- Python 3.12+ with type hints required
- Ruff for linting and formatting (replaces black, isort, flake8)
- pyright strict mode enabled
- No `Any` types - use proper type hints or `object`
- Use early returns, avoid nested conditionals
- Prefer composition over inheritance

## Git Conventions

- **Branch naming**: `{initials}/{description}` (e.g., `jd/fix-login`)
- **Commit format**: Conventional Commits (`feat:`, `fix:`, `docs:`, etc.)
- **PR titles**: Same as commit format

## Critical Rules

### Error Handling
- NEVER swallow errors silently
- Always show user feedback for errors (Django messages, HTMX response headers)
- Log errors with proper context for debugging

### Views
- Prefer Function-Based Views
- Always validate request.method explicitly
- Return proper HTTP status codes
- Use `select_related()` / `prefetch_related()` to avoid N+1 queries

### Templates & HTMX
- Use template inheritance (`{% extends %}`, `{% block %}`)
- Create partial templates for HTMX responses (`_partial.html` naming)
- Always include `hx-indicator` for loading states
- Handle `HX-Request` header for partial vs full page responses

### Forms
- Use ModelForm for model-backed forms
- Validate in `clean()` and `clean_<field>()` methods
- Always handle form errors in templates
- Disable submit buttons during HTMX requests

### Celery Tasks
- Tasks must be idempotent
- Use proper retry strategies with exponential backoff
- Always log task start/completion/failure
- Pass serializable arguments only (no model instances)

## Testing

- Write failing test first (TDD)
- Use Factory Boy: `UserFactory.create(is_admin=True)`
- Use pytest fixtures in `conftest.py`
- Test behavior, not implementation
- Run tests before committing

## Skill Activation

Before implementing ANY task, check if relevant skills apply:

- Creating tests → `pytest-django-patterns` skill
- Building forms → `django-forms` skill
- REST API work → `drf-patterns` skill
- HTMX/Alpine UI → `htmx-alpine-patterns` skill
- Template work → `django-templates` skill
- Background tasks → `celery-patterns` skill
- WebSocket/realtime → `django-channels` skill
- Model design → `django-models` skill
- Debugging issues → `systematic-debugging` skill

## Common Commands

```bash
# Development
uv run python manage.py runserver     # Start dev server
uv run pytest                         # Run tests
uv run pytest -x --lf                 # Run last failed, stop on first failure
uv run ruff check .                   # Lint code
uv run ruff format .                  # Format code
uv run pyright                        # Type check

# Django
uv run python manage.py makemigrations
uv run python manage.py migrate
uv run python manage.py shell_plus    # Enhanced shell (django-extensions)
uv run python manage.py createsuperuser

# Celery
uv run celery -A config worker -l info
uv run celery -A config beat -l info

# Dependencies
uv sync                               # Install from pyproject.toml
uv add <package>                      # Add new dependency
uv add --dev <package>                # Add dev dependency

# Git
gh pr create                          # Create PR
```
