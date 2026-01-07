---
name: django-models
description: Django model patterns including design, QuerySet optimization, managers, signals, and migrations. Use when designing models, optimizing queries, or working with the ORM.
---

# Django Model Patterns

## Model Design

### Basic Model

```python
# apps/posts/models.py
from django.db import models
from django.urls import reverse

class Post(models.Model):
    class Status(models.TextChoices):
        DRAFT = "draft", "Draft"
        PUBLISHED = "published", "Published"

    title = models.CharField(max_length=200)
    slug = models.SlugField(max_length=200, unique=True)
    content = models.TextField()
    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.DRAFT,
    )
    author = models.ForeignKey(
        "users.User",
        on_delete=models.CASCADE,
        related_name="posts",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["status", "-created_at"]),
        ]

    def __str__(self) -> str:
        return self.title

    def get_absolute_url(self) -> str:
        return reverse("posts:detail", kwargs={"slug": self.slug})
```

### Abstract Base Model

```python
class TimestampedModel(models.Model):
    """Abstract base with created/updated timestamps."""
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

class Post(TimestampedModel):
    title = models.CharField(max_length=200)
    # Inherits created_at, updated_at
```

## Field Patterns

### Nullable Fields

```python
# Optional text field
bio = models.TextField(blank=True, default="")  # Use empty string

# Optional foreign key
category = models.ForeignKey(
    "Category",
    on_delete=models.SET_NULL,
    null=True,
    blank=True,
)

# Optional unique field (use null, not empty string)
external_id = models.CharField(max_length=100, unique=True, null=True, blank=True)
```

### JSON Field

```python
metadata = models.JSONField(default=dict, blank=True)

# Usage
post.metadata = {"views": 100, "likes": 50}
post.metadata["views"] += 1

# Querying
Post.objects.filter(metadata__views__gte=100)
```

## Custom Managers

```python
class PublishedManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(status="published")

class Post(models.Model):
    # ...
    objects = models.Manager()  # Default
    published = PublishedManager()  # Custom

# Usage
Post.objects.all()        # All posts
Post.published.all()      # Only published
```

## QuerySet Methods

```python
class PostQuerySet(models.QuerySet):
    def published(self):
        return self.filter(status="published")

    def by_author(self, user):
        return self.filter(author=user)

    def recent(self, days=7):
        cutoff = timezone.now() - timedelta(days=days)
        return self.filter(created_at__gte=cutoff)

class Post(models.Model):
    objects = PostQuerySet.as_manager()

# Chainable queries
Post.objects.published().by_author(user).recent(30)
```

## Query Optimization

### Select Related (ForeignKey)

```python
# BAD: N+1 queries
posts = Post.objects.all()
for post in posts:
    print(post.author.username)  # Query per post!

# GOOD: Single query with JOIN
posts = Post.objects.select_related("author")
for post in posts:
    print(post.author.username)  # No extra query
```

### Prefetch Related (Many-to-Many, Reverse FK)

```python
# BAD: N+1 queries
posts = Post.objects.all()
for post in posts:
    print(post.tags.all())  # Query per post!

# GOOD: Two queries total
posts = Post.objects.prefetch_related("tags")
for post in posts:
    print(post.tags.all())  # No extra query

# Custom prefetch with filtering
from django.db.models import Prefetch

posts = Post.objects.prefetch_related(
    Prefetch(
        "comments",
        queryset=Comment.objects.filter(approved=True).select_related("author"),
        to_attr="approved_comments",
    )
)
```

### Only/Defer Fields

```python
# Only load specific fields
posts = Post.objects.only("id", "title", "slug")

# Exclude heavy fields
posts = Post.objects.defer("content")
```

### Aggregation

```python
from django.db.models import Count, Avg, Sum, F

# Count related objects
posts = Post.objects.annotate(comment_count=Count("comments"))

# Filter by annotation
popular = Post.objects.annotate(
    comment_count=Count("comments")
).filter(comment_count__gte=10)

# Aggregate across all rows
stats = Post.objects.aggregate(
    total=Count("id"),
    avg_comments=Avg("comment_count"),
)

# F expressions for database-level operations
Post.objects.update(views=F("views") + 1)
```

## Signals

```python
# apps/posts/signals.py
from django.db.models.signals import post_save, pre_delete
from django.dispatch import receiver
from apps.posts.models import Post

@receiver(post_save, sender=Post)
def notify_followers(sender, instance, created, **kwargs):
    if created and instance.status == "published":
        from apps.notifications.tasks import notify_followers
        notify_followers.delay(instance.id)

@receiver(pre_delete, sender=Post)
def cleanup_post_files(sender, instance, **kwargs):
    if instance.image:
        instance.image.delete(save=False)

# apps/posts/apps.py
class PostsConfig(AppConfig):
    name = "apps.posts"

    def ready(self):
        import apps.posts.signals  # noqa
```

## Model Methods

```python
class Post(models.Model):
    def publish(self) -> None:
        """Publish the post."""
        self.status = self.Status.PUBLISHED
        self.published_at = timezone.now()
        self.save(update_fields=["status", "published_at"])

    def is_editable_by(self, user) -> bool:
        """Check if user can edit this post."""
        return user == self.author or user.is_staff

    @property
    def is_published(self) -> bool:
        return self.status == self.Status.PUBLISHED

    @property
    def reading_time(self) -> int:
        """Estimated reading time in minutes."""
        word_count = len(self.content.split())
        return max(1, word_count // 200)
```

## Migrations

```bash
# Create migrations
uv run python manage.py makemigrations

# Apply migrations
uv run python manage.py migrate

# Show migration SQL
uv run python manage.py sqlmigrate posts 0001

# Fake a migration (mark as applied)
uv run python manage.py migrate posts 0001 --fake
```

### Data Migration

```python
# Generated with: python manage.py makemigrations --empty posts
from django.db import migrations

def populate_slugs(apps, schema_editor):
    Post = apps.get_model("posts", "Post")
    for post in Post.objects.filter(slug=""):
        post.slug = slugify(post.title)
        post.save(update_fields=["slug"])

def reverse_slugs(apps, schema_editor):
    pass  # Nothing to reverse

class Migration(migrations.Migration):
    dependencies = [("posts", "0001_initial")]

    operations = [
        migrations.RunPython(populate_slugs, reverse_slugs),
    ]
```

## Anti-Patterns

```python
# BAD: Query in loop
for post in Post.objects.all():
    print(post.author.email)  # N+1 queries!

# GOOD: Prefetch
for post in Post.objects.select_related("author"):
    print(post.author.email)

# BAD: Loading all objects
if Post.objects.all():  # Loads ALL posts into memory
    ...

# GOOD: Use exists()
if Post.objects.exists():
    ...

# BAD: Count with len()
count = len(Post.objects.all())  # Loads all, counts in Python

# GOOD: Use count()
count = Post.objects.count()  # COUNT query in DB

# BAD: Overusing signals
@receiver(post_save, sender=Post)
def do_everything(sender, instance, **kwargs):
    # Too much logic, hard to test/debug

# GOOD: Explicit method calls in view/service
post.save()
notify_followers(post)
```

## Integration with Other Skills

- **pytest-django-patterns**: Testing models and querysets
- **drf-patterns**: Model serialization
- **celery-patterns**: Async model operations
- **django-forms**: ModelForm integration
