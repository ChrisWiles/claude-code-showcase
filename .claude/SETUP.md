# Claudia Setup Guide

Complete setup guide for the Claudia development environment with Claude Code integration.

## Prerequisites

- Docker & Docker Compose
- Node.js 20+
- Git
- GitHub CLI (`gh`)
- Python 3.11+ (for Serena)

## Quick Start

### 1. Clone and Install

```bash
git clone <repository-url>
cd Claudia
cp .env.example .env
# Edit .env with your tokens
npm install
```

### 2. Start All Services (Single Container)

The easiest way using Make:

```bash
# Build and start all services in one container
make up

# Or manually with docker compose
docker compose -f docker-compose.dev.yml up -d
```

This starts **ONE container** with all services:
- **Ollama** (port 11434): Local LLM inference
- **SearXNG** (port 8080): Privacy-respecting search
- **SurrealDB** (port 8081): Multi-model database
- **Serena** (port 8384): Code analysis service

### 3. Verify Services

```bash
# Quick health check
make health

# Or manually
docker compose -f docker-compose.dev.yml exec claudia-dev /usr/local/bin/healthcheck.sh

# View logs
make logs

# Open shell in container
make shell
```

### 4. Useful Make Commands

```bash
make help      # Show all available commands
make up        # Start services
make down      # Stop services
make restart   # Restart services
make logs      # View logs
make shell     # Open bash shell
make health    # Check service health
make models    # Pull recommended Ollama models
make clean     # Remove containers (keep data)
make prune     # Remove everything (DESTRUCTIVE)
```

## Environment Variables

### Required

**GITHUB_TOKEN**
- Required for: GitHub MCP, PR reviews, workflow automation
- Get from: https://github.com/settings/tokens
- Scopes needed: `repo`, `workflow`, `read:org`

**ANTHROPIC_API_KEY** (for CI/CD only)
- Required for: GitHub Actions workflows with Claude Code
- Get from: https://console.anthropic.com/
- Set as repository secret

### Optional MCP Services

**SERENA_API_KEY**
- Required for: Code review insights, pattern detection
- Get from: Your Serena instance or service provider
- Default host: http://localhost:8384

**CONTEXT7_API_KEY**
- Required for: Up-to-date framework/library documentation
- Get from: https://context7.io/ or Upstash
- Enables documentation lookups during reviews

**PLAYWRIGHT_HEADLESS**
- Default: `true`
- Set to `false` for debugging browser automation
- Used by Playwright MCP server

**PLAYWRIGHT_BROWSER**
- Default: `chromium`
- Options: `chromium`, `firefox`, `webkit`

### Optional Monitoring

**SENTRY_AUTH_TOKEN** & **SENTRY_ORG**
- For error tracking integration
- Get from: https://sentry.io/settings/account/api/auth-tokens/

**SLACK_BOT_TOKEN** & **SLACK_TEAM_ID**
- For workflow notifications
- Get from: https://api.slack.com/apps

**CODECOV_TOKEN**
- For coverage reporting in CI
- Get from: https://codecov.io/

## MCP Servers

Claudia uses 9 MCP servers for enhanced functionality:

| Server | Purpose | Configuration |
|--------|---------|---------------|
| **github** | GitHub API access | GITHUB_TOKEN |
| **serena** | Code analysis & insights | SERENA_API_KEY, SERENA_HOST |
| **context7** | Documentation lookup | CONTEXT7_API_KEY |
| **playwright** | Browser automation | PLAYWRIGHT_HEADLESS, PLAYWRIGHT_BROWSER |
| **surrealdb** | Database queries | Auto-configured via Docker |
| **searxng** | Web search | Auto-configured via Docker |
| **ollama** | Local LLM | Auto-configured via Docker |
| **sentry** | Error tracking | SENTRY_AUTH_TOKEN, SENTRY_ORG |
| **slack** | Team notifications | SLACK_BOT_TOKEN, SLACK_TEAM_ID |

## Custom Commands

Available slash commands for Claude Code:

- `/audit [directory]` - Comprehensive code quality audit
- `/test [files/flags]` - Run tests with optional arguments
- `/code-quality [directory]` - Code quality review
- `/docs-sync` - Check documentation sync
- `/pr-review [number]` - Review a pull request
- `/pr-summary` - Generate PR summary
- `/ticket [issue-number]` - Work on GitHub issue
- `/list-skills` - List available skills
- `/onboard` - Onboarding guide
- `/validate-config` - Validate configuration files

## Hooks

Claudia includes automated quality hooks:

### Pre-Tool Hooks
- **Main branch protection**: Prevents editing on main branch

### Post-Tool Hooks (after Edit/Write)
1. **Prettier formatting**: Auto-format JS/TS files
2. **Dependency installation**: Auto `npm install` when package.json changes
3. **Test runner**: Auto-run tests for changed test files
4. **Type checker**: TypeScript type checking (non-blocking)
5. **Duplicate detector**: Warns about potential code duplication

### User Prompt Hooks
- **Skill evaluation**: Suggests relevant skills based on task

## GitHub Actions Workflows

### On Every PR
- **CI**: Lint, type-check, test, build
- **Claude Code Review**: Automated code review with Serena/Context7
- **Semgrep**: Security scanning
- **CodeQL**: Semantic code analysis

### Scheduled (Monthly)
- **Code Quality Review**: Random directory reviews with auto-fixes
- **Documentation Sync**: Ensure docs match code
- **Dependency Audit**: Security updates and dependency checks
- **Actions Usage Monitoring**: Track GitHub Actions usage

### Scheduled (Weekly)
- **Auto-Improvement**: Autonomous codebase improvements
  - Focus areas: docs, tests, performance, security, types, quality
  - Uses Serena for insights, Context7 for best practices
  - Creates PRs with improvements

## Development Workflow

### 1. Feature Development

```bash
# Create feature branch
git checkout -b feature/my-feature

# Develop (hooks auto-run on file changes)
# - Prettier formats on save
# - Tests run automatically
# - Type checking happens in background

# Commit
git add .
git commit -m "feat: add new feature"

# Push
git push -u origin feature/my-feature

# Create PR
gh pr create
```

### 2. Code Review

PRs automatically get Claude Code review with:
- TypeScript quality checks
- React patterns validation
- Security scanning
- Performance analysis
- Serena insights
- Context7 best practices

### 3. Auto-Improvements

Every Monday at 9 AM UTC:
- Claude analyzes recent changes
- Identifies improvement opportunities
- Makes fixes (docs, tests, performance, etc.)
- Creates PR with improvements

## Docker Architecture

Claudia uses an **all-in-one multi-service container** for development:

### Why Single Container?

- ✅ **Simpler**: One command to start everything
- ✅ **Faster**: Less overhead than multiple containers
- ✅ **Easier networking**: All services on same network
- ✅ **Resource efficient**: Shared base image and dependencies

### Service Management

All services are managed by **Supervisor** inside the container:
- Automatic restarts on failure
- Centralized logging
- Health checks for all services
- Graceful shutdown

### Data Persistence

Data is stored in Docker volumes:
- `ollama-data`: Models and cache
- `surrealdb-data`: Database files
- `searxng-data`: Search engine config
- `serena-data`: Code analysis cache

### Accessing Services

From your host machine:
```bash
# Ollama API
curl http://localhost:11434/api/tags

# SurrealDB HTTP
curl http://localhost:8081/health

# SearXNG web interface
open http://localhost:8080

# Serena API
curl http://localhost:8384/health
```

From inside the container:
```bash
# All services use localhost
make shell
# Inside container:
curl http://localhost:11434/api/version
```

## Troubleshooting

### Hooks Failing

If hooks fail with "command not found":
```bash
# Make hooks executable
chmod +x .claude/hooks/*.sh

# Test hook manually
bash .claude/hooks/format-check.sh
```

### Docker Services Not Starting

```bash
# Check container status
docker compose -f docker-compose.dev.yml ps

# View logs
make logs
# Or: docker compose -f docker-compose.dev.yml logs

# Check health
make health

# Restart services
make restart

# Rebuild if needed
make down
make build
make up
```

### Individual Service Issues

```bash
# Open shell in container
make shell

# Inside container, check supervisor status
supervisorctl status

# Restart specific service
supervisorctl restart ollama
supervisorctl restart surrealdb

# View service logs
tail -f /var/log/supervisor/ollama.out.log
tail -f /var/log/supervisor/surrealdb.out.log
```

### MCP Servers Not Working

```bash
# Check if container is running
docker ps | grep claudia-dev

# Verify ports are exposed
docker port claudia-dev-env

# Test connections
curl http://localhost:11434/api/version  # Ollama
curl http://localhost:8081/health        # SurrealDB
curl http://localhost:8080/              # SearXNG
curl http://localhost:8384/health        # Serena
```

### TypeScript Errors in Hooks

Ensure `tsconfig.json` exists in project root:
```bash
npx tsc --init
```

### Playwright Installation

If Playwright MCP fails:
```bash
# Install browsers
npx playwright install chromium

# Or in DevContainer
npx playwright install-deps
```

## DevContainer

For consistent development environment:

```bash
# Open in VS Code
code .

# Reopen in container
# Command Palette → "Reopen in Container"
```

Includes:
- Node.js 20
- Docker-in-Docker
- Git & GitHub CLI
- Playwright with chromium
- All VS Code extensions
- Pre-configured settings

## Best Practices

### 1. Always Work on Feature Branches
Never commit directly to `main` - hooks will block you.

### 2. Let Hooks Do Their Job
Don't bypass hooks unless absolutely necessary. They catch issues early.

### 3. Use Custom Commands
Leverage `/audit`, `/test` for consistent quality checks.

### 4. Review Auto-Improvement PRs
Weekly auto-improvements are autonomous but should be reviewed before merging.

### 5. Keep Dependencies Updated
Monthly dependency audit workflow handles this automatically.

## Support

- Documentation: `CLAUDE.md`
- Commands: `/list-skills`
- Configuration: `.claude/settings.json`
- Hooks: `.claude/hooks/`
- Workflows: `.github/workflows/`
