---
name: celery-patterns
description: Celery task patterns including task definition, retry strategies, periodic tasks, and best practices. Use when implementing background tasks, scheduled jobs, or async processing.
---

# Celery Patterns for Django

## Philosophy

- Tasks must be idempotent
- Pass IDs, not objects
- Always handle failures
- Use proper retry strategies

## Project Setup

```python
# config/celery.py
import os
from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

app = Celery("myproject")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()

# config/settings.py
CELERY_BROKER_URL = "redis://localhost:6379/0"
CELERY_RESULT_BACKEND = "redis://localhost:6379/0"
CELERY_TASK_ALWAYS_EAGER = False  # Set True for testing
CELERY_TASK_ACKS_LATE = True
CELERY_TASK_REJECT_ON_WORKER_LOST = True
```

## Basic Task Definition

```python
# apps/notifications/tasks.py
import logging
from celery import shared_task
from apps.users.models import User

logger = logging.getLogger(__name__)

@shared_task
def send_welcome_email(user_id: int) -> None:
    """Send welcome email to user."""
    logger.info(f"Sending welcome email to user {user_id}")

    try:
        user = User.objects.get(pk=user_id)
    except User.DoesNotExist:
        logger.warning(f"User {user_id} not found, skipping email")
        return

    # Send email logic here
    send_mail(
        subject="Welcome!",
        message="Thanks for signing up.",
        recipient_list=[user.email],
    )

    logger.info(f"Welcome email sent to {user.email}")
```

## Calling Tasks

```python
# Async execution (returns immediately)
send_welcome_email.delay(user.id)

# With options
send_welcome_email.apply_async(
    args=[user.id],
    countdown=60,  # Run after 60 seconds
    expires=3600,  # Expire after 1 hour
)

# Chain tasks
from celery import chain
chain(
    process_order.s(order_id),
    send_confirmation.s(),
    update_inventory.s(),
).apply_async()
```

## Retry Strategies

### Basic Retry

```python
@shared_task(
    bind=True,
    max_retries=3,
    default_retry_delay=60,
)
def send_notification(self, user_id: int) -> None:
    try:
        # ... send notification ...
    except ConnectionError as exc:
        logger.warning(f"Connection failed, retrying: {exc}")
        raise self.retry(exc=exc)
```

### Exponential Backoff

```python
@shared_task(
    bind=True,
    autoretry_for=(ConnectionError, TimeoutError),
    retry_backoff=True,      # Exponential backoff
    retry_backoff_max=600,   # Max 10 minutes
    retry_jitter=True,       # Add randomness
    max_retries=5,
)
def sync_external_service(self, resource_id: int) -> None:
    """Sync with external API."""
    response = external_api.sync(resource_id)
    if not response.ok:
        raise ConnectionError(f"API error: {response.status_code}")
```

### Custom Retry Logic

```python
@shared_task(bind=True, max_retries=3)
def process_payment(self, order_id: int) -> dict:
    try:
        order = Order.objects.get(pk=order_id)
        result = payment_gateway.charge(order)
        return {"status": "success", "transaction_id": result.id}

    except PaymentDeclined:
        # Don't retry declined payments
        logger.error(f"Payment declined for order {order_id}")
        return {"status": "declined"}

    except PaymentGatewayError as exc:
        # Retry with increasing delay
        retry_in = 60 * (2 ** self.request.retries)
        logger.warning(f"Payment gateway error, retrying in {retry_in}s")
        raise self.retry(exc=exc, countdown=retry_in)
```

## Idempotent Tasks

```python
@shared_task
def process_order(order_id: int) -> None:
    """Process order - idempotent implementation."""
    order = Order.objects.select_for_update().get(pk=order_id)

    # Check if already processed
    if order.status == "processed":
        logger.info(f"Order {order_id} already processed, skipping")
        return

    # Process order
    order.status = "processing"
    order.save()

    try:
        fulfill_order(order)
        order.status = "processed"
    except Exception:
        order.status = "failed"
        raise
    finally:
        order.save()
```

## Periodic Tasks (Celery Beat)

```python
# config/celery.py
from celery.schedules import crontab

app.conf.beat_schedule = {
    "cleanup-expired-sessions": {
        "task": "apps.users.tasks.cleanup_expired_sessions",
        "schedule": crontab(hour=3, minute=0),  # Daily at 3 AM
    },
    "send-daily-digest": {
        "task": "apps.notifications.tasks.send_daily_digest",
        "schedule": crontab(hour=8, minute=0),  # Daily at 8 AM
    },
    "sync-inventory": {
        "task": "apps.inventory.tasks.sync_inventory",
        "schedule": 300.0,  # Every 5 minutes
    },
}

# apps/users/tasks.py
@shared_task
def cleanup_expired_sessions() -> int:
    """Clean up expired sessions."""
    from django.contrib.sessions.models import Session
    from django.utils import timezone

    count, _ = Session.objects.filter(
        expire_date__lt=timezone.now()
    ).delete()

    logger.info(f"Cleaned up {count} expired sessions")
    return count
```

## Task with Progress

```python
@shared_task(bind=True)
def export_data(self, query_params: dict) -> str:
    """Export data with progress updates."""
    items = Item.objects.filter(**query_params)
    total = items.count()

    results = []
    for i, item in enumerate(items):
        results.append(process_item(item))

        # Update progress
        self.update_state(
            state="PROGRESS",
            meta={"current": i + 1, "total": total}
        )

    # Save results
    filename = f"export_{self.request.id}.csv"
    save_to_file(results, filename)

    return filename
```

## Error Handling

```python
@shared_task(bind=True)
def critical_task(self, data: dict) -> None:
    """Task with comprehensive error handling."""
    task_id = self.request.id
    logger.info(f"Starting critical_task {task_id}")

    try:
        result = process_data(data)
        logger.info(f"Task {task_id} completed successfully")
        return result

    except ValidationError as e:
        # Don't retry validation errors
        logger.error(f"Validation error in task {task_id}: {e}")
        notify_admin(f"Task failed: {e}")
        raise

    except ExternalServiceError as e:
        logger.warning(f"External service error in task {task_id}: {e}")
        raise self.retry(exc=e)

    except Exception as e:
        logger.exception(f"Unexpected error in task {task_id}")
        notify_admin(f"Critical task failed unexpectedly: {e}")
        raise
```

## Testing Tasks

```python
import pytest
from unittest.mock import patch

@pytest.mark.django_db
class TestSendWelcomeEmail:
    @patch("apps.notifications.tasks.send_mail")
    def test_sends_email(self, mock_send_mail, user):
        send_welcome_email(user.id)

        mock_send_mail.assert_called_once()
        assert user.email in mock_send_mail.call_args.kwargs["recipient_list"]

    def test_handles_missing_user(self, db):
        # Should not raise
        send_welcome_email(99999)

    @patch("apps.notifications.tasks.send_mail")
    def test_retry_on_connection_error(self, mock_send_mail, user):
        mock_send_mail.side_effect = ConnectionError()

        with pytest.raises(ConnectionError):
            send_notification(user.id)
```

## Running Celery

```bash
# Worker
uv run celery -A config worker -l info

# Beat scheduler
uv run celery -A config beat -l info

# Combined (development only)
uv run celery -A config worker -B -l info

# Flower monitoring
uv run celery -A config flower
```

## Anti-Patterns

```python
# BAD: Passing model instances
@shared_task
def process_user(user):  # Don't pass objects!
    ...

# GOOD: Pass IDs
@shared_task
def process_user(user_id: int):
    user = User.objects.get(pk=user_id)

# BAD: Not idempotent
@shared_task
def increment_counter(counter_id):
    counter = Counter.objects.get(pk=counter_id)
    counter.value += 1  # Running twice = wrong value!
    counter.save()

# GOOD: Idempotent
@shared_task
def set_counter(counter_id, new_value):
    Counter.objects.filter(pk=counter_id).update(value=new_value)

# BAD: Silent failures
@shared_task
def risky_task():
    try:
        do_something()
    except Exception:
        pass  # Silently swallowed!

# GOOD: Log and handle failures
@shared_task
def risky_task():
    try:
        do_something()
    except Exception as e:
        logger.exception("risky_task failed")
        raise
```

## Integration with Other Skills

- **pytest-django-patterns**: Testing tasks
- **systematic-debugging**: Debugging failed tasks
- **django-models**: Task-triggered model updates
