---
description: Use when creating git commits or reviewing commit messages.
alwaysApply: false
---

# Git commit message rules

Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Required types

- `feat:` – New feature
- `fix:` – Bug fix
- `docs:` – Documentation
- `refactor:` – Code restructuring without behavior change
- `test:` – Tests
- `chore:` – Maintenance (deps, config, etc.)
- `perf:` – Performance improvement
- `ci:` – CI/CD changes
- `build:` – Build system changes
- `style:` – Formatting (no logic change)

## Breaking changes

Add `!` after type or use `BREAKING CHANGE:` footer:

```
feat!: redesign authentication
fix(api)!: change response format
```

## Constraints

- Never stage or commit changes in Git yourself.
- Description: lowercase, no period, imperative mood ("add" not "added")
- Scope: optional, use package/area name (e.g., `feat(web):`, `fix(database):`)
- Keep first line under 72 chars
- Body: explain _why_, not _what_
- Reference issues with `Fixes #123` or `Refs #123` in footer

## Examples

```
feat(auth): implement OAuth2 login
fix: resolve database connection timeout
docs: update development guide with commit format
refactor(services): simplify error handling
test(web): add E2E tests for user registration
chore: update dependencies to latest versions
```
