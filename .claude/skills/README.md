# Claude Code Skills

This directory contains project-specific skills that provide Claude with domain knowledge and best practices for this Django codebase.

## Skills by Category

### Testing & Debugging
| Skill | Description |
|-------|-------------|
| [pytest-django-patterns](./pytest-django-patterns/SKILL.md) | pytest-django, Factory Boy, fixtures, TDD workflow |
| [systematic-debugging](./systematic-debugging/SKILL.md) | Four-phase debugging methodology, root cause analysis |

### Django Core
| Skill | Description |
|-------|-------------|
| [django-models](./django-models/SKILL.md) | Model design, QuerySet optimization, signals, migrations |
| [django-forms](./django-forms/SKILL.md) | Form handling, validation, ModelForm patterns |
| [django-templates](./django-templates/SKILL.md) | Template inheritance, tags, filters, partials |

### Frontend & UI
| Skill | Description |
|-------|-------------|
| [htmx-alpine-patterns](./htmx-alpine-patterns/SKILL.md) | HTMX attributes, partial templates, dynamic UI |

### APIs & Background Tasks
| Skill | Description |
|-------|-------------|
| [drf-patterns](./drf-patterns/SKILL.md) | Django REST Framework serializers, viewsets, permissions |
| [celery-patterns](./celery-patterns/SKILL.md) | Celery tasks, retry strategies, periodic tasks |
| [django-channels](./django-channels/SKILL.md) | WebSocket consumers, real-time features |

## Skill Combinations for Common Tasks

### Building a New Feature
1. **django-models** - Design models
2. **django-forms** - Create forms for user input
3. **htmx-alpine-patterns** - Dynamic UI
4. **django-templates** - Page templates
5. **pytest-django-patterns** - Write tests (TDD)

### Building an API Endpoint
1. **drf-patterns** - Serializers and viewsets
2. **django-models** - QuerySet optimization
3. **pytest-django-patterns** - API tests

### Building a Background Task
1. **celery-patterns** - Task definition
2. **django-models** - Database operations
3. **pytest-django-patterns** - Task tests

### Debugging an Issue
1. **systematic-debugging** - Root cause analysis
2. **pytest-django-patterns** - Write failing test first

## How Skills Work

Skills are automatically invoked when Claude recognizes relevant context. Each skill provides:

- **When to Use** - Trigger conditions
- **Core Patterns** - Best practices and examples
- **Anti-Patterns** - What to avoid
- **Integration** - How skills connect

## Adding New Skills

1. Create directory: `.claude/skills/skill-name/`
2. Add `SKILL.md` (case-sensitive) with YAML frontmatter:
   ```yaml
   ---
   # Required fields
   name: skill-name              # Lowercase, hyphens, max 64 chars
   description: What it does and when to use it. Include trigger keywords.  # Max 1024 chars

   # Optional fields
   allowed-tools: Read, Grep, Glob    # Restrict available tools
   model: claude-sonnet-4-20250514    # Specific model to use
   ---
   ```
3. Include standard sections: When to Use, Core Patterns, Anti-Patterns, Integration
4. Add to this README
5. Add triggers to `.claude/hooks/skill-rules.json`

**Important:** The `description` field is critical—Claude uses semantic matching on it to decide when to apply the skill. Include keywords users would naturally mention.

## Maintenance

- Update skills when patterns change
- Remove outdated information
- Add new patterns as they emerge
- Keep examples current with codebase
