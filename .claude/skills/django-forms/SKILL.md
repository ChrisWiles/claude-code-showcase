---
name: django-forms
description: Django form handling patterns including ModelForm, validation, clean methods, and HTMX form submission. Use when building forms, implementing validation, or handling form submission.
---

# Django Forms Patterns

## Form Philosophy

- Use ModelForm for model-backed forms
- Validate in `clean()` and `clean_<field>()` methods
- Always handle form errors in templates
- Keep form logic in the form, not the view

## Basic Form Patterns

### ModelForm

```python
# apps/posts/forms.py
from django import forms
from apps.posts.models import Post

class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ["title", "content", "status"]
        widgets = {
            "content": forms.Textarea(attrs={"rows": 5}),
        }

    def clean_title(self) -> str:
        title = self.cleaned_data["title"]
        if len(title) < 5:
            raise forms.ValidationError("Title must be at least 5 characters")
        return title.strip()
```

### Regular Form

```python
class ContactForm(forms.Form):
    name = forms.CharField(max_length=100)
    email = forms.EmailField()
    message = forms.CharField(widget=forms.Textarea)

    def clean_email(self) -> str:
        email = self.cleaned_data["email"]
        if email.endswith("@spam.com"):
            raise forms.ValidationError("Invalid email domain")
        return email.lower()
```

## Field-Level Validation

```python
class UserRegistrationForm(forms.ModelForm):
    password = forms.CharField(widget=forms.PasswordInput)
    password_confirm = forms.CharField(widget=forms.PasswordInput)

    class Meta:
        model = User
        fields = ["email", "username"]

    def clean_email(self) -> str:
        """Validate single field."""
        email = self.cleaned_data["email"]
        if User.objects.filter(email=email).exists():
            raise forms.ValidationError("Email already registered")
        return email.lower()

    def clean(self) -> dict:
        """Cross-field validation."""
        cleaned_data = super().clean()
        password = cleaned_data.get("password")
        password_confirm = cleaned_data.get("password_confirm")

        if password and password_confirm and password != password_confirm:
            self.add_error("password_confirm", "Passwords do not match")

        return cleaned_data
```

## Form in Views

### Function-Based View

```python
# apps/posts/views.py
from django.http import HttpRequest, HttpResponse
from django.shortcuts import render, redirect
from django.contrib import messages

from apps.posts.forms import PostForm

def post_create(request: HttpRequest) -> HttpResponse:
    if request.method == "POST":
        form = PostForm(request.POST)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.save()
            messages.success(request, "Post created successfully")
            return redirect("posts:detail", pk=post.pk)
    else:
        form = PostForm()

    return render(request, "posts/create.html", {"form": form})
```

### With HTMX

```python
def post_create(request: HttpRequest) -> HttpResponse:
    if request.method == "POST":
        form = PostForm(request.POST)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.save()

            if request.headers.get("HX-Request"):
                response = render(
                    request,
                    "posts/_post_card.html",
                    {"post": post}
                )
                response["HX-Trigger"] = "postCreated"
                return response

            messages.success(request, "Post created successfully")
            return redirect("posts:detail", pk=post.pk)

        # Return form with errors for HTMX
        if request.headers.get("HX-Request"):
            return render(request, "posts/_form.html", {"form": form})
    else:
        form = PostForm()

    return render(request, "posts/create.html", {"form": form})
```

## Template Patterns

### Basic Form Template

```html
<!-- templates/posts/create.html -->
{% extends "base.html" %}

{% block content %}
<h1>Create Post</h1>

<form method="post" novalidate>
    {% csrf_token %}

    {% if form.non_field_errors %}
    <div class="alert alert-danger">
        {{ form.non_field_errors }}
    </div>
    {% endif %}

    {% for field in form %}
    <div class="mb-3">
        <label for="{{ field.id_for_label }}" class="form-label">
            {{ field.label }}
            {% if field.field.required %}<span class="text-danger">*</span>{% endif %}
        </label>
        {{ field }}
        {% if field.errors %}
        <div class="invalid-feedback d-block">
            {{ field.errors|join:", " }}
        </div>
        {% endif %}
        {% if field.help_text %}
        <small class="form-text text-muted">{{ field.help_text }}</small>
        {% endif %}
    </div>
    {% endfor %}

    <button type="submit" class="btn btn-primary">Create</button>
</form>
{% endblock %}
```

### HTMX Form Partial

```html
<!-- templates/posts/_form.html -->
<form method="post"
      hx-post="{% url 'posts:create' %}"
      hx-target="#form-container"
      hx-swap="innerHTML"
      hx-indicator="#spinner">
    {% csrf_token %}

    {% include "partials/_form_errors.html" %}

    {% for field in form %}
    {% include "partials/_form_field.html" %}
    {% endfor %}

    <button type="submit" class="btn btn-primary">
        <span id="spinner" class="htmx-indicator spinner-border spinner-border-sm"></span>
        Create
    </button>
</form>
```

### Reusable Form Field Partial

```html
<!-- templates/partials/_form_field.html -->
<div class="mb-3 {% if field.errors %}has-error{% endif %}">
    <label for="{{ field.id_for_label }}" class="form-label">
        {{ field.label }}
    </label>

    {% if field.field.widget.input_type == "checkbox" %}
        <div class="form-check">
            {{ field }}
        </div>
    {% else %}
        {{ field|add_class:"form-control" }}
    {% endif %}

    {% for error in field.errors %}
    <div class="text-danger small">{{ error }}</div>
    {% endfor %}
</div>
```

## Form Widgets

```python
class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ["title", "content", "tags", "published_at"]
        widgets = {
            "title": forms.TextInput(attrs={
                "class": "form-control",
                "placeholder": "Enter title...",
                "autofocus": True,
            }),
            "content": forms.Textarea(attrs={
                "class": "form-control",
                "rows": 10,
            }),
            "tags": forms.CheckboxSelectMultiple(),
            "published_at": forms.DateTimeInput(attrs={
                "type": "datetime-local",
                "class": "form-control",
            }),
        }
```

## Dynamic Forms

### Form with Dynamic Choices

```python
class AssignTaskForm(forms.Form):
    assignee = forms.ChoiceField(choices=[])

    def __init__(self, *args, team=None, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        if team:
            self.fields["assignee"].choices = [
                (m.id, m.name) for m in team.members.all()
            ]
```

### Conditional Fields

```python
class OrderForm(forms.Form):
    delivery_type = forms.ChoiceField(
        choices=[("pickup", "Pickup"), ("delivery", "Delivery")]
    )
    address = forms.CharField(required=False)

    def clean(self) -> dict:
        cleaned_data = super().clean()
        delivery_type = cleaned_data.get("delivery_type")
        address = cleaned_data.get("address")

        if delivery_type == "delivery" and not address:
            self.add_error("address", "Address required for delivery")

        return cleaned_data
```

## Formsets

```python
from django.forms import inlineformset_factory

# Create formset for related model
PostImageFormSet = inlineformset_factory(
    Post,
    PostImage,
    fields=["image", "caption"],
    extra=3,
    max_num=10,
    can_delete=True,
)

# In view
def post_edit(request: HttpRequest, pk: int) -> HttpResponse:
    post = get_object_or_404(Post, pk=pk)

    if request.method == "POST":
        form = PostForm(request.POST, instance=post)
        formset = PostImageFormSet(request.POST, request.FILES, instance=post)

        if form.is_valid() and formset.is_valid():
            form.save()
            formset.save()
            return redirect("posts:detail", pk=post.pk)
    else:
        form = PostForm(instance=post)
        formset = PostImageFormSet(instance=post)

    return render(request, "posts/edit.html", {
        "form": form,
        "formset": formset,
    })
```

## Anti-Patterns to Avoid

```python
# BAD - Validation in view
def create_post(request):
    title = request.POST.get("title")
    if len(title) < 5:  # Don't validate here
        ...

# GOOD - Validation in form
class PostForm(forms.ModelForm):
    def clean_title(self):
        title = self.cleaned_data["title"]
        if len(title) < 5:
            raise forms.ValidationError("Too short")
        return title

# BAD - Silently ignoring errors
if form.is_valid():
    form.save()
return redirect("home")  # What if invalid?

# GOOD - Always handle errors
if form.is_valid():
    form.save()
    return redirect("home")
return render(request, "form.html", {"form": form})

# BAD - Not using commit=False when needed
form.save()  # Can't set author

# GOOD - Use commit=False
post = form.save(commit=False)
post.author = request.user
post.save()
```

## Integration with Other Skills

- **htmx-alpine-patterns**: HTMX form submission and validation feedback
- **django-templates**: Form rendering patterns
- **pytest-django-patterns**: Testing form validation
- **django-models**: ModelForm integration
