# GitHub Copilot Instructions

## Project Context
This is a Claude Code project configuration showcase demonstrating best practices for AI-assisted development.

## Code Style Guidelines
- Use TypeScript strict mode
- Prefer `interface` over `type` for object shapes
- Use `unknown` instead of `any`
- Write self-documenting code with meaningful names
- Follow the single responsibility principle

## Patterns to Follow
- Use early returns to reduce nesting
- Prefer composition over inheritance
- Handle all error cases explicitly
- Always include loading, error, and empty states in UI
- Use factory functions for test mocks

## Testing Conventions
- Write tests using Jest
- Follow TDD: write failing test first
- Use AAA pattern: Arrange, Act, Assert
- Mock factory pattern: `getMockUser(overrides)`

## React Patterns
- Use functional components with hooks
- Prefer custom hooks for reusable logic
- Always handle loading and error states
- Use proper TypeScript generics for components

## Git Conventions
- Branch naming: `{initials}/{issue-number}-{description}`
- Commit format: Conventional Commits (`feat:`, `fix:`, `docs:`)
- Reference issues in PR body: `Closes #<issue-number>`

## MCP Servers Available
- GitHub: Issue tracking and repository management
- Serena: AI agent integration
- Context7: Context retrieval
- SurrealDB: Database operations
- SearXNG: Web search
- Ollama: Local LLM inference

## Do Not
- Use `any` type
- Swallow errors silently
- Commit secrets or credentials
- Skip error handling
- Use outdated patterns
