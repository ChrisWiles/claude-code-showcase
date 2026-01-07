---
name: pytest-django-patterns
description: pytest-django testing patterns, Factory Boy, fixtures, and TDD workflow. Use when writing tests, creating test factories, or following TDD red-green-refactor cycle.
---

# pytest-django Testing Patterns

## Testing Philosophy

**Test-Driven Development (TDD):**
- Write failing test FIRST
- Implement minimal code to pass
- Refactor after green
- Never write production code without a failing test

## Common Decorators

### @pytest.mark.django_db

Required for any test that accesses the database:

```python
import pytest

@pytest.mark.django_db
def test_user_creation():
    user = User.objects.create(email="test@example.com")
    assert user.pk is not None

# Apply to all tests in a module with pytestmark
pytestmark = pytest.mark.django_db
```

### @pytest.mark.parametrize

Run the same test with different inputs:

```python
@pytest.mark.parametrize("status,expected", [
    ("draft", 404),
    ("published", 200),
])
@pytest.mark.django_db
def test_post_visibility(client, status, expected):
    post = PostFactory(status=status)
    response = client.get(f"/posts/{post.pk}/")
    assert response.status_code == expected
```

### @pytest.fixture

Create reusable test data:

```python
@pytest.fixture
def user(db):
    return UserFactory()

@pytest.fixture
def auth_client(client, user):
    client.force_login(user)
    return client
```

## Project Setup

```python
# pyproject.toml
[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "config.settings.test"
python_files = ["test_*.py"]
addopts = ["--reuse-db", "-ra"]

# conftest.py
import pytest

@pytest.fixture
def user(db):
    return UserFactory()

@pytest.fixture
def auth_client(client, user):
    client.force_login(user)
    return client
```

## Factory Boy Patterns

### Basic Factory

```python
# tests/factories.py
import factory
from factory.django import DjangoModelFactory

class UserFactory(DjangoModelFactory):
    class Meta:
        model = User

    email = factory.Sequence(lambda n: f"user{n}@example.com")
    first_name = factory.Faker("first_name")
    is_active = True

# Usage
user = UserFactory()  # Saved to DB
user = UserFactory.build()  # Not saved
user = UserFactory(is_staff=True)  # Override
```

### Related Factories

```python
class PostFactory(DjangoModelFactory):
    class Meta:
        model = Post

    title = factory.Faker("sentence")
    author = factory.SubFactory(UserFactory)

    @factory.post_generation
    def tags(self, create, extracted, **kwargs):
        if create and extracted:
            self.tags.add(*extracted)
```

## Test Structure

```python
# tests/apps/posts/test_views.py
import pytest
from http import HTTPStatus

pytestmark = pytest.mark.django_db


class TestPostListView:
    def test_returns_200_for_authenticated_user(self, auth_client):
        response = auth_client.get("/posts/")
        assert response.status_code == HTTPStatus.OK

    def test_redirects_anonymous_user(self, client):
        response = client.get("/posts/")
        assert response.status_code == HTTPStatus.FOUND

    def test_displays_user_posts_only(self, auth_client, user):
        my_post = PostFactory(author=user)
        other_post = PostFactory()

        response = auth_client.get("/posts/")

        assert my_post in response.context["posts"]
        assert other_post not in response.context["posts"]
```

## Testing Views

```python
pytestmark = pytest.mark.django_db

def test_create_post(auth_client, user):
    data = {"title": "New Post", "content": "Content"}

    response = auth_client.post("/posts/create/", data)

    assert response.status_code == HTTPStatus.FOUND
    assert Post.objects.filter(title="New Post", author=user).exists()

def test_htmx_returns_partial(auth_client):
    response = auth_client.get("/posts/", HTTP_HX_REQUEST="true")

    assert response.status_code == HTTPStatus.OK
    templates = [t.name for t in response.templates]
    assert "posts/_list.html" in templates
```

## Testing Forms

```python
class TestPostForm:
    def test_valid_data(self):
        form = PostForm(data={"title": "Test", "content": "Content"})
        assert form.is_valid()

    def test_blank_title_invalid(self):
        form = PostForm(data={"title": "", "content": "Content"})
        assert not form.is_valid()
        assert "title" in form.errors
```

## Testing Models

```python
pytestmark = pytest.mark.django_db

def test_str_returns_title():
    post = PostFactory(title="Hello World")
    assert str(post) == "Hello World"

def test_published_manager_excludes_drafts():
    published = PostFactory(status="published")
    draft = PostFactory(status="draft")

    assert published in Post.published.all()
    assert draft not in Post.published.all()
```

## Mocking

```python
def test_sends_email(mocker, user):
    mock_send = mocker.patch("apps.users.services.send_mail")

    send_welcome_email(user.id)

    mock_send.assert_called_once()
    assert user.email in mock_send.call_args.kwargs["recipient_list"]
```

## Running Tests

```bash
uv run pytest                    # All tests
uv run pytest -x --lf            # Stop first, last failed
uv run pytest --cov=apps         # With coverage
uv run pytest tests/apps/posts/  # Specific directory
```

## Integration with Other Skills

- **django-models**: Test model methods and querysets
- **django-forms**: Test form validation
- **celery-patterns**: Test tasks with mocking
- **systematic-debugging**: Write test that reproduces bug first
