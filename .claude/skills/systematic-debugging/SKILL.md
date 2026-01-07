---
name: systematic-debugging
description: Four-phase debugging methodology with root cause analysis for Django. Use when investigating bugs, fixing test failures, or troubleshooting unexpected behavior. Emphasizes NO FIXES WITHOUT ROOT CAUSE FIRST.
---

# Systematic Debugging for Django

## Core Principle

**NO FIXES WITHOUT ROOT CAUSE FIRST**

Never apply patches that mask underlying problems. Understand WHY something fails before attempting to fix it.

## Four-Phase Framework

### Phase 1: Reproduce and Investigate

Before touching any code:

1. **Write a failing test** - Captures the bug behavior
2. **Read error messages thoroughly** - Every word matters
3. **Examine recent changes** - `git diff`, `git log`
4. **Trace data flow** - Follow the call chain to find where bad values originate

```python
# Write a failing test first
@pytest.mark.django_db
def test_bug_reproduction():
    """Reproduces issue #123."""
    user = UserFactory()
    response = Client().post("/profile/", {"bio": "New"})
    assert response.status_code == 200  # Currently failing
```

### Phase 2: Isolate

Narrow down the problem:

```python
# Add strategic logging
import logging
logger = logging.getLogger(__name__)

def problematic_view(request):
    logger.debug(f"Method: {request.method}")
    logger.debug(f"POST: {request.POST}")
    logger.debug(f"User: {request.user}")

    form = MyForm(request.POST)
    logger.debug(f"Valid: {form.is_valid()}")
    logger.debug(f"Errors: {form.errors}")
```

### Phase 3: Identify Root Cause

- Read the full stack trace
- Use debugger to inspect state
- Check what assumptions are violated

### Phase 4: Fix and Verify

1. Implement fix at the root cause
2. Run reproduction test (should pass)
3. Run full test suite
4. Verify manually if needed

## Django Debug Tools

### Django Debug Toolbar

```python
# settings/dev.py
INSTALLED_APPS += ["debug_toolbar"]
MIDDLEWARE += ["debug_toolbar.middleware.DebugToolbarMiddleware"]
INTERNAL_IPS = ["127.0.0.1"]
```

Check SQL panel for N+1 queries, slow queries > 10ms.

### Python Debugger

```python
def problematic_view(request):
    breakpoint()  # Execution stops here

    # Commands: n(ext), s(tep), c(ontinue), p var, q(uit)
```

```bash
# Drop into debugger on test failure
uv run pytest --pdb -x
```

### Query Debugging

```python
# Log all SQL queries
LOGGING = {
    "loggers": {
        "django.db.backends": {"level": "DEBUG", "handlers": ["console"]},
    },
}

# Count queries in tests
from django.test.utils import CaptureQueriesContext
from django.db import connection

def test_no_n_plus_one():
    with CaptureQueriesContext(connection) as ctx:
        list(Post.objects.select_related("author"))
    assert len(ctx) <= 2
```

## Common Django Issues

### N+1 Queries

```python
# Problem
for post in Post.objects.all():
    print(post.author.email)  # Query per post!

# Fix
for post in Post.objects.select_related("author"):
    print(post.author.email)  # Single query
```

### Form Not Saving

```python
# Check these:
# 1. form.is_valid() returns True?
# 2. form.save() called?
# 3. If commit=False, did you call .save() on instance?

def debug_form(request):
    form = MyForm(request.POST)
    print(f"Valid: {form.is_valid()}")
    print(f"Errors: {form.errors}")
```

### CSRF 403 Errors

```html
<!-- Check: csrf_token in form -->
<form method="post">
    {% csrf_token %}
</form>
```

### Migration Issues

```bash
uv run python manage.py showmigrations
uv run python manage.py migrate app_name 0001 --fake
```

## Debugging Celery

```python
# Run synchronously for debugging
my_task(arg)  # Direct call, not .delay()

# Or set in settings
CELERY_TASK_ALWAYS_EAGER = True
```

## Debugging HTMX

```html
<script>htmx.logAll();</script>
```

```python
def view(request):
    print(f"HTMX: {request.headers.get('HX-Request')}")
```

## Checklist

Before claiming fixed:

- [ ] Root cause identified
- [ ] Reproduction test passes
- [ ] Full test suite passes (`uv run pytest`)
- [ ] No type errors (`uv run pyright`)
- [ ] No lint errors (`uv run ruff check .`)

## Red Flags

Stop if you're thinking:
- "Quick fix now, investigate later"
- "One more attempt" (after 3+ failures)
- "This should work" (without understanding why)

Three consecutive failed fixes = architectural problem. Stop and discuss.

## Integration with Other Skills

- **pytest-django-patterns**: Write reproduction tests
- **django-models**: Debug QuerySet issues
- **celery-patterns**: Debug async task failures
- **htmx-alpine-patterns**: Debug HTMX requests
