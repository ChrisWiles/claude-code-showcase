# Project Name

> This is an example CLAUDE.md file showing how to configure Claude Code for your project.

## Quick Facts

- **Stack**: React, TypeScript, Node.js
- **Test Command**: `npm test`
- **Lint Command**: `npm run lint`
- **Build Command**: `npm run build`

## Key Directories

- `src/components/` - React components
- `src/hooks/` - Custom React hooks
- `src/utils/` - Utility functions
- `src/api/` - API client code
- `tests/` - Test files

## Code Style

- TypeScript strict mode enabled
- Prefer `interface` over `type` (except unions/intersections)
- No `any` - use `unknown` instead
- Use early returns, avoid nested conditionals
- Prefer composition over inheritance

## Git Conventions

- **Branch naming**: `{initials}/{description}` (e.g., `jd/fix-login`)
- **Commit format**: Conventional Commits (`feat:`, `fix:`, `docs:`, etc.)
- **PR titles**: Same as commit format

## Critical Rules

### Error Handling
- NEVER swallow errors silently
- Always show user feedback for errors
- Log errors for debugging

### UI States
- Always handle: loading, error, empty, success states
- Show loading ONLY when no data exists
- Every list needs an empty state

### Mutations
- Disable buttons during async operations
- Show loading indicator on buttons
- Always have onError handler with user feedback

## Testing

- Write failing test first (TDD)
- Use factory pattern: `getMockX(overrides)`
- Test behavior, not implementation
- Run tests before committing

## Skill Activation

Before implementing ANY task, check if relevant skills apply:

- Creating tests → `testing-patterns` skill
- Building forms → `formik-patterns` skill
- GraphQL operations → `graphql-schema` skill
- Debugging issues → `systematic-debugging` skill
- UI components → `react-ui-patterns` skill
- Researching public X data → `x-research` skill

## Common Commands

```bash
# Development
npm run dev          # Start dev server
npm test             # Run tests
npm run lint         # Run linter
npm run typecheck    # Check types

# Git
npm run commit       # Interactive commit
gh pr create         # Create PR
```
