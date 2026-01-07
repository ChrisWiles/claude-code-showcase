---
name: htmx-alpine-patterns
description: HTMX patterns for Django including partial templates, hx-* attributes, and dynamic UI without JavaScript. Use when building interactive UI, handling AJAX requests, or creating dynamic components.
---

# HTMX Patterns for Django

## Philosophy

- Server renders HTML, not JSON
- Partial templates for dynamic updates
- Progressive enhancement
- Minimal JavaScript

## Basic HTMX Attributes

### hx-get / hx-post

```html
<!-- Load content into element -->
<button hx-get="/posts/" hx-target="#post-list">
    Load Posts
</button>

<!-- Submit form via AJAX -->
<form hx-post="/posts/create/" hx-target="#post-list" hx-swap="beforeend">
    {% csrf_token %}
    <input name="title" required>
    <button type="submit">Create</button>
</form>
```

### hx-target and hx-swap

```html
<!-- Target options -->
<div hx-get="/content/" hx-target="this">Replace self</div>
<div hx-get="/content/" hx-target="#other">Target by ID</div>
<div hx-get="/content/" hx-target="closest .container">Find parent</div>

<!-- Swap options -->
<div hx-get="/content/" hx-swap="innerHTML">Replace inner (default)</div>
<div hx-get="/content/" hx-swap="outerHTML">Replace entire element</div>
<div hx-get="/content/" hx-swap="beforeend">Append to end</div>
<div hx-get="/content/" hx-swap="afterbegin">Prepend to start</div>
<div hx-get="/content/" hx-swap="delete">Delete target</div>
```

### hx-trigger

```html
<!-- Trigger events -->
<input hx-get="/search/" hx-trigger="keyup changed delay:300ms" name="q">
<div hx-get="/updates/" hx-trigger="every 5s">Polling</div>
<form hx-post="/save/" hx-trigger="submit, keyup changed delay:1s from:input">
```

## Django View Patterns

### Detecting HTMX Requests

```python
def post_list(request):
    posts = Post.objects.all()

    if request.headers.get("HX-Request"):
        return render(request, "posts/_list.html", {"posts": posts})

    return render(request, "posts/list.html", {"posts": posts})
```

### Using django-htmx

```python
# settings.py
MIDDLEWARE = [
    ...
    "django_htmx.middleware.HtmxMiddleware",
]

# views.py
def post_list(request):
    posts = Post.objects.all()

    if request.htmx:
        return render(request, "posts/_list.html", {"posts": posts})

    return render(request, "posts/list.html", {"posts": posts})
```

### Form Handling

```python
def post_create(request):
    if request.method == "POST":
        form = PostForm(request.POST)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.save()

            if request.htmx:
                return render(request, "posts/_post_card.html", {"post": post})

            return redirect("posts:list")

        # Return form with errors
        if request.htmx:
            return render(request, "posts/_form.html", {"form": form})
    else:
        form = PostForm()

    return render(request, "posts/create.html", {"form": form})
```

## Template Patterns

### Base Template with HTMX

```html
<!-- templates/base.html -->
<!DOCTYPE html>
<html>
<head>
    <script src="https://unpkg.com/htmx.org@2.0.0"></script>
</head>
<body hx-headers='{"X-CSRFToken": "{{ csrf_token }}"}'>
    {% block content %}{% endblock %}
</body>
</html>
```

### Full Page with Partial

```html
<!-- templates/posts/list.html -->
{% extends "base.html" %}

{% block content %}
<h1>Posts</h1>
<div id="post-list">
    {% include "posts/_list.html" %}
</div>
{% endblock %}

<!-- templates/posts/_list.html -->
{% for post in posts %}
    {% include "posts/_post_card.html" %}
{% empty %}
    <p>No posts yet.</p>
{% endfor %}
```

### Loading Indicator

```html
<button hx-get="/slow-action/" hx-indicator="#spinner">
    Load Data
    <span id="spinner" class="htmx-indicator">Loading...</span>
</button>

<style>
.htmx-indicator { display: none; }
.htmx-request .htmx-indicator { display: inline; }
.htmx-request.htmx-indicator { display: inline; }
</style>
```

### Inline Editing

```html
<!-- Display mode -->
<div id="post-{{ post.pk }}">
    <span>{{ post.title }}</span>
    <button hx-get="/posts/{{ post.pk }}/edit/" hx-target="#post-{{ post.pk }}">
        Edit
    </button>
</div>

<!-- Edit mode (returned by /edit/) -->
<form hx-post="/posts/{{ post.pk }}/update/"
      hx-target="#post-{{ post.pk }}"
      hx-swap="outerHTML">
    {% csrf_token %}
    <input name="title" value="{{ post.title }}">
    <button type="submit">Save</button>
    <button hx-get="/posts/{{ post.pk }}/" hx-target="#post-{{ post.pk }}">Cancel</button>
</form>
```

### Delete with Confirmation

```html
<button hx-delete="/posts/{{ post.pk }}/"
        hx-target="closest .post-card"
        hx-swap="outerHTML"
        hx-confirm="Delete this post?">
    Delete
</button>
```

## Response Headers

### HX-Trigger

```python
def post_create(request):
    # ... create post ...

    response = render(request, "posts/_post_card.html", {"post": post})
    response["HX-Trigger"] = "postCreated"
    return response

# In template, listen for event
# <div hx-get="/posts/count/" hx-trigger="postCreated from:body">
```

### HX-Redirect

```python
def post_create(request):
    # ... create post ...

    response = HttpResponse()
    response["HX-Redirect"] = reverse("posts:detail", args=[post.pk])
    return response
```

### HX-Reswap / HX-Retarget

```python
def form_view(request):
    form = MyForm(request.POST)
    if form.is_valid():
        # Success - replace the whole container
        response = render(request, "success.html")
        response["HX-Retarget"] = "#main-container"
        response["HX-Reswap"] = "innerHTML"
        return response

    # Error - just replace the form
    return render(request, "_form.html", {"form": form})
```

## Common Patterns

### Infinite Scroll

```html
<div id="posts">
    {% for post in posts %}
        {% include "posts/_post_card.html" %}
    {% endfor %}

    {% if has_next %}
    <div hx-get="?page={{ next_page }}"
         hx-trigger="revealed"
         hx-swap="outerHTML">
        Loading more...
    </div>
    {% endif %}
</div>
```

### Search with Debounce

```html
<input type="search"
       name="q"
       hx-get="/search/"
       hx-trigger="keyup changed delay:300ms"
       hx-target="#results">

<div id="results">
    {% include "search/_results.html" %}
</div>
```

### Modal Dialog

```html
<!-- Trigger -->
<button hx-get="/posts/{{ post.pk }}/delete-confirm/"
        hx-target="#modal-container">
    Delete
</button>

<!-- Modal container in base.html -->
<div id="modal-container"></div>

<!-- Modal partial -->
<div class="modal">
    <p>Are you sure?</p>
    <button hx-delete="/posts/{{ post.pk }}/"
            hx-target="#post-{{ post.pk }}"
            hx-on::after-request="this.closest('.modal').remove()">
        Confirm
    </button>
    <button onclick="this.closest('.modal').remove()">Cancel</button>
</div>
```

## Anti-Patterns

```html
<!-- BAD: No loading indicator -->
<button hx-get="/slow/">Load</button>

<!-- GOOD: Show loading state -->
<button hx-get="/slow/" hx-indicator="#spinner">
    Load <span id="spinner" class="htmx-indicator">...</span>
</button>

<!-- BAD: Full page in partial response -->
<!-- View returns base.html for HTMX request -->

<!-- GOOD: Check for HTMX and return partial -->
if request.htmx:
    return render(request, "_partial.html", context)
```

## Integration with Other Skills

- **django-templates**: Partial template organization
- **django-forms**: HTMX form submission
- **pytest-django-patterns**: Testing HTMX endpoints
