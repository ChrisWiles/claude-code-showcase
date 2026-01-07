---
name: drf-patterns
description: Django REST Framework patterns including serializers, viewsets, permissions, and pagination. Use when building REST APIs, creating serializers, or handling API authentication.
---

# Django REST Framework Patterns

## API Philosophy

- Use ViewSets for CRUD, APIView for custom actions
- Keep serializer logic in serializers, not views
- Use permissions and throttling for security
- Always paginate list endpoints

## Serializer Patterns

### Basic ModelSerializer

```python
# apps/posts/serializers.py
from rest_framework import serializers
from apps.posts.models import Post

class PostSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source="author.get_full_name", read_only=True)

    class Meta:
        model = Post
        fields = ["id", "title", "content", "author", "author_name", "created_at"]
        read_only_fields = ["author", "created_at"]
```

### Nested Serializers

```python
class CommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ["id", "content", "author", "created_at"]

class PostDetailSerializer(serializers.ModelSerializer):
    comments = CommentSerializer(many=True, read_only=True)
    author = UserSerializer(read_only=True)

    class Meta:
        model = Post
        fields = ["id", "title", "content", "author", "comments", "created_at"]
```

### Write vs Read Serializers

```python
class PostCreateSerializer(serializers.ModelSerializer):
    """For creating/updating posts."""
    class Meta:
        model = Post
        fields = ["title", "content", "tags"]

    def create(self, validated_data: dict) -> Post:
        validated_data["author"] = self.context["request"].user
        return super().create(validated_data)

class PostReadSerializer(serializers.ModelSerializer):
    """For reading posts."""
    author = UserSerializer(read_only=True)
    tags = TagSerializer(many=True, read_only=True)

    class Meta:
        model = Post
        fields = ["id", "title", "content", "author", "tags", "created_at"]
```

### Validation

```python
class PostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ["title", "content", "status"]

    def validate_title(self, value: str) -> str:
        """Field-level validation."""
        if len(value) < 5:
            raise serializers.ValidationError("Title too short")
        return value.strip()

    def validate(self, data: dict) -> dict:
        """Cross-field validation."""
        if data.get("status") == "published" and not data.get("content"):
            raise serializers.ValidationError({
                "content": "Published posts must have content"
            })
        return data
```

## ViewSet Patterns

### Basic ModelViewSet

```python
# apps/posts/views.py
from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.posts.models import Post
from apps.posts.serializers import PostSerializer, PostDetailSerializer

class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.select_related("author").prefetch_related("tags")
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_serializer_class(self):
        if self.action == "retrieve":
            return PostDetailSerializer
        return PostSerializer

    def perform_create(self, serializer) -> None:
        serializer.save(author=self.request.user)

    @action(detail=True, methods=["post"])
    def publish(self, request, pk=None) -> Response:
        post = self.get_object()
        post.status = "published"
        post.save()
        return Response({"status": "published"})
```

### Filtered QuerySet

```python
class PostViewSet(viewsets.ModelViewSet):
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """Return only user's own posts."""
        return Post.objects.filter(author=self.request.user)
```

### APIView for Custom Logic

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

class PostStatsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request) -> Response:
        user = request.user
        stats = {
            "total_posts": Post.objects.filter(author=user).count(),
            "published": Post.objects.filter(author=user, status="published").count(),
            "draft": Post.objects.filter(author=user, status="draft").count(),
        }
        return Response(stats)
```

## URL Configuration

```python
# apps/posts/urls.py
from rest_framework.routers import DefaultRouter
from apps.posts.views import PostViewSet

router = DefaultRouter()
router.register("posts", PostViewSet, basename="post")

urlpatterns = router.urls

# Or with explicit URLs
from django.urls import path
from apps.posts.views import PostStatsView

urlpatterns = [
    *router.urls,
    path("posts/stats/", PostStatsView.as_view(), name="post-stats"),
]
```

## Permissions

### Custom Permission

```python
# apps/core/permissions.py
from rest_framework import permissions

class IsOwnerOrReadOnly(permissions.BasePermission):
    """Allow owners to edit, others to read."""

    def has_object_permission(self, request, view, obj) -> bool:
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.author == request.user

# Usage
class PostViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]
```

### Per-Action Permissions

```python
class PostViewSet(viewsets.ModelViewSet):
    def get_permissions(self):
        if self.action in ["create", "update", "destroy"]:
            return [permissions.IsAuthenticated()]
        return [permissions.AllowAny()]
```

## Pagination

```python
# config/settings.py
REST_FRAMEWORK = {
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 20,
}

# Custom pagination
from rest_framework.pagination import PageNumberPagination

class LargeResultsSetPagination(PageNumberPagination):
    page_size = 100
    page_size_query_param = "page_size"
    max_page_size = 1000

class PostViewSet(viewsets.ModelViewSet):
    pagination_class = LargeResultsSetPagination
```

## Filtering

```python
# Using django-filter
from django_filters import rest_framework as filters

class PostFilter(filters.FilterSet):
    created_after = filters.DateFilter(field_name="created_at", lookup_expr="gte")
    created_before = filters.DateFilter(field_name="created_at", lookup_expr="lte")
    status = filters.ChoiceFilter(choices=Post.STATUS_CHOICES)

    class Meta:
        model = Post
        fields = ["status", "author", "tags"]

class PostViewSet(viewsets.ModelViewSet):
    filterset_class = PostFilter
```

## Authentication

```python
# config/settings.py
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework.authentication.SessionAuthentication",
        "rest_framework.authentication.TokenAuthentication",
    ],
}

# Token auth setup
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    path("api/token/", obtain_auth_token, name="api-token"),
]
```

## Error Handling

```python
# apps/core/exceptions.py
from rest_framework.views import exception_handler
from rest_framework.response import Response

def custom_exception_handler(exc, context) -> Response | None:
    response = exception_handler(exc, context)

    if response is not None:
        response.data["status_code"] = response.status_code

        # Log the error
        if response.status_code >= 500:
            logger.error(f"API Error: {exc}", exc_info=True)

    return response

# config/settings.py
REST_FRAMEWORK = {
    "EXCEPTION_HANDLER": "apps.core.exceptions.custom_exception_handler",
}
```

## Testing APIs

```python
import pytest
from rest_framework.test import APIClient
from rest_framework import status

@pytest.fixture
def api_client() -> APIClient:
    return APIClient()

@pytest.fixture
def auth_api_client(api_client: APIClient, user: User) -> APIClient:
    api_client.force_authenticate(user=user)
    return api_client

class TestPostAPI:
    def test_list_posts(self, auth_api_client: APIClient) -> None:
        response = auth_api_client.get("/api/posts/")
        assert response.status_code == status.HTTP_200_OK

    def test_create_post(self, auth_api_client: APIClient) -> None:
        data = {"title": "Test Post", "content": "Content"}
        response = auth_api_client.post("/api/posts/", data)
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["title"] == "Test Post"
```

## Anti-Patterns to Avoid

```python
# BAD - Logic in view instead of serializer
class PostViewSet(viewsets.ModelViewSet):
    def create(self, request):
        title = request.data.get("title", "").strip()  # Do this in serializer
        ...

# GOOD - Logic in serializer
class PostSerializer(serializers.ModelSerializer):
    def validate_title(self, value):
        return value.strip()

# BAD - N+1 queries
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()  # Will N+1 on author

# GOOD - Prefetch related
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.select_related("author")

# BAD - No pagination
class PostViewSet(viewsets.ModelViewSet):
    pagination_class = None  # Returns all records

# GOOD - Always paginate
class PostViewSet(viewsets.ModelViewSet):
    pagination_class = PageNumberPagination
```

## Integration with Other Skills

- **django-models**: Model design for API resources
- **pytest-django-patterns**: API testing patterns
- **celery-patterns**: Async API operations
- **systematic-debugging**: API debugging with DRF browsable API
