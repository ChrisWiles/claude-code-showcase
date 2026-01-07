---
name: django-templates
description: Django template patterns including inheritance, partials, tags, and filters. Use when working with templates, creating reusable components, or organizing template structure.
---

# Django Template Patterns

## Template Organization

```
templates/
├── base.html              # Root template
├── partials/              # Reusable fragments
│   ├── _navbar.html
│   ├── _footer.html
│   ├── _pagination.html
│   └── _form_field.html
├── components/            # UI components
│   ├── _button.html
│   ├── _card.html
│   └── _modal.html
└── posts/                 # App-specific
    ├── list.html          # Full pages
    ├── detail.html
    ├── _list.html         # HTMX partials (underscore prefix)
    ├── _post_card.html
    └── _form.html
```

## Template Inheritance

### Base Template

```html
<!-- templates/base.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}My Site{% endblock %}</title>
    {% block extra_css %}{% endblock %}
</head>
<body>
    {% include "partials/_navbar.html" %}

    <main>
        {% block content %}{% endblock %}
    </main>

    {% include "partials/_footer.html" %}

    {% block extra_js %}{% endblock %}
</body>
</html>
```

### Child Template

```html
<!-- templates/posts/list.html -->
{% extends "base.html" %}

{% block title %}Posts - {{ block.super }}{% endblock %}

{% block content %}
<h1>Posts</h1>
<div id="post-list">
    {% include "posts/_list.html" %}
</div>
{% endblock %}
```

## Include with Context

```html
<!-- Pass variables to included template -->
{% include "components/_card.html" with title=post.title body=post.excerpt %}

<!-- Only pass specified variables (isolate context) -->
{% include "components/_card.html" with title=post.title only %}
```

## Partial Templates (HTMX)

```html
<!-- templates/posts/_list.html -->
{% for post in posts %}
    {% include "posts/_post_card.html" %}
{% empty %}
    <div class="empty-state">
        <p>No posts found.</p>
    </div>
{% endfor %}

{% if is_paginated %}
    {% include "partials/_pagination.html" %}
{% endif %}
```

## Reusable Components

### Button Component

```html
<!-- templates/components/_button.html -->
<button type="{{ type|default:'button' }}"
        class="btn btn-{{ variant|default:'primary' }} {% if disabled %}disabled{% endif %}"
        {% if disabled %}disabled{% endif %}
        {% if hx_post %}hx-post="{{ hx_post }}"{% endif %}
        {% if hx_target %}hx-target="{{ hx_target }}"{% endif %}>
    {{ text }}
</button>

<!-- Usage -->
{% include "components/_button.html" with text="Submit" type="submit" %}
{% include "components/_button.html" with text="Delete" variant="danger" hx_post=delete_url %}
```

### Form Field Component

```html
<!-- templates/partials/_form_field.html -->
<div class="form-group {% if field.errors %}has-error{% endif %}">
    <label for="{{ field.id_for_label }}">
        {{ field.label }}
        {% if field.field.required %}<span class="required">*</span>{% endif %}
    </label>

    {{ field }}

    {% if field.help_text %}
        <small class="help-text">{{ field.help_text }}</small>
    {% endif %}

    {% for error in field.errors %}
        <span class="error">{{ error }}</span>
    {% endfor %}
</div>

<!-- Usage -->
{% for field in form %}
    {% include "partials/_form_field.html" %}
{% endfor %}
```

## Template Tags

### Built-in Tags

```html
<!-- Conditionals -->
{% if user.is_authenticated %}
    Welcome, {{ user.username }}
{% elif show_login %}
    <a href="{% url 'login' %}">Login</a>
{% else %}
    <a href="{% url 'signup' %}">Sign up</a>
{% endif %}

<!-- Loops -->
{% for post in posts %}
    <div class="{% cycle 'odd' 'even' %}">
        {{ forloop.counter }}. {{ post.title }}
        {% if forloop.first %}(First!){% endif %}
        {% if forloop.last %}(Last!){% endif %}
    </div>
{% empty %}
    <p>No posts.</p>
{% endfor %}

<!-- URL generation -->
<a href="{% url 'posts:detail' pk=post.pk %}">{{ post.title }}</a>
<a href="{% url 'posts:list' %}?page=2">Page 2</a>

<!-- Static files -->
{% load static %}
<link rel="stylesheet" href="{% static 'css/style.css' %}">
<img src="{% static 'images/logo.png' %}" alt="Logo">
```

### Custom Template Tags

```python
# apps/core/templatetags/core_tags.py
from django import template

register = template.Library()

@register.simple_tag
def active_link(request, url_name):
    """Return 'active' if current URL matches."""
    from django.urls import reverse
    if request.path == reverse(url_name):
        return "active"
    return ""

@register.inclusion_tag("partials/_pagination.html")
def pagination(page_obj):
    """Render pagination component."""
    return {"page_obj": page_obj}

# Usage
{% load core_tags %}
<a href="{% url 'home' %}" class="{% active_link request 'home' %}">Home</a>
{% pagination page_obj %}
```

## Template Filters

### Built-in Filters

```html
<!-- Text manipulation -->
{{ post.title|title }}           <!-- Title Case -->
{{ post.title|lower }}           <!-- lowercase -->
{{ post.title|truncatewords:10 }}<!-- First 10 words... -->
{{ post.content|linebreaks }}    <!-- Convert \n to <br>/<p> -->
{{ post.content|striptags }}     <!-- Remove HTML -->

<!-- Dates -->
{{ post.created_at|date:"F j, Y" }}     <!-- January 1, 2024 -->
{{ post.created_at|timesince }}          <!-- 2 hours ago -->

<!-- Numbers -->
{{ price|floatformat:2 }}        <!-- 19.99 -->
{{ count|intcomma }}             <!-- 1,234,567 -->

<!-- Lists -->
{{ tags|join:", " }}             <!-- tag1, tag2, tag3 -->
{{ items|length }}               <!-- 5 -->
{{ items|first }}                <!-- First item -->

<!-- Default values -->
{{ user.bio|default:"No bio" }}
{{ value|default_if_none:"N/A" }}

<!-- Safe HTML (use carefully!) -->
{{ post.html_content|safe }}
```

### Custom Filters

```python
# apps/core/templatetags/core_filters.py
from django import template

register = template.Library()

@register.filter
def initials(name):
    """Get initials from name."""
    return "".join(word[0].upper() for word in name.split()[:2])

@register.filter
def percentage(value, total):
    """Calculate percentage."""
    if total == 0:
        return 0
    return int((value / total) * 100)

# Usage
{% load core_filters %}
{{ user.get_full_name|initials }}    <!-- JD -->
{{ completed|percentage:total }}%     <!-- 75% -->
```

## Form Templates

### Complete Form

```html
<form method="post" novalidate>
    {% csrf_token %}

    {% if form.non_field_errors %}
    <div class="alert alert-danger">
        {% for error in form.non_field_errors %}
            <p>{{ error }}</p>
        {% endfor %}
    </div>
    {% endif %}

    {% for field in form %}
        {% include "partials/_form_field.html" %}
    {% endfor %}

    <button type="submit">Submit</button>
</form>
```

### HTMX Form

```html
<form method="post"
      hx-post="{{ request.path }}"
      hx-target="#form-container"
      hx-swap="innerHTML">
    {% csrf_token %}
    <!-- form fields -->
    <button type="submit" hx-indicator="#spinner">
        Submit
        <span id="spinner" class="htmx-indicator">...</span>
    </button>
</form>
```

## Anti-Patterns

```html
<!-- BAD: Logic in templates -->
{% if user.role == "admin" or user.role == "moderator" or user.is_superuser %}
    <!-- Complex logic belongs in view or model -->
{% endif %}

<!-- GOOD: Move logic to model/view -->
{% if user.can_moderate %}

<!-- BAD: Hardcoded URLs -->
<a href="/posts/{{ post.id }}/">

<!-- GOOD: Use url tag -->
<a href="{% url 'posts:detail' pk=post.pk %}">

<!-- BAD: Inline styles -->
<div style="color: red; font-size: 14px;">

<!-- GOOD: Use CSS classes -->
<div class="error-message">
```

## Integration with Other Skills

- **htmx-alpine-patterns**: HTMX partial templates
- **django-forms**: Form rendering patterns
- **pytest-django-patterns**: Testing template rendering
