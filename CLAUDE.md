# CLAUDE.md

## Worktree-First Workflow (Mandatory)

**All code changes MUST happen in an isolated worktree.** Do not modify files in the main checkout. Before writing any code, create a worktree:

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@')
DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}
git fetch origin "$DEFAULT_BRANCH"
git worktree add .worktrees/<name> -b <branch-name> "origin/$DEFAULT_BRANCH"
```

Then work inside `.worktrees/<name>/` for the rest of the session.

**Naming:** Use the Linear issue identifier if available (e.g., `.worktrees/<identifier>`), a task slug (e.g., `.worktrees/fix-auth-timeout`), or today's date (e.g., `.worktrees/2026-04-01`) as fallback.

**The only exceptions** — you may skip worktree creation when:
1. The user explicitly says to skip it (e.g., "no worktree", "just edit here", `--stay`)
2. The task is read-only (research, investigation, code review with no edits)
3. You are already inside a worktree (check: `git rev-parse --git-dir` returns a path under `.git/worktrees/`)
4. You are running in a CI/automated context (GitHub Actions, etc.) where the checkout is already isolated

**Why this matters:** Working directly on the main checkout causes cross-contamination between sessions — uncommitted changes, wrong branches, and dirty state leak into unrelated work. Worktrees eliminate this entirely.

See the `/worktree` and `/start` skills for full conventions and flags.

Guidance for Claude Code working with the ground_control-api gem.

## Overview

Ground Control API is a headless JSON API Rails engine for managing Active Job queues, jobs, workers, and recurring tasks. It builds on top of `mission_control-jobs` for the adapter/query layer and provides Alba-serialized JSON responses.

## Quick Reference

```bash
# Testing
bundle exec rspec                           # Run all tests
bundle exec rspec spec/path/to/file:42      # Run specific test

# Linting
bundle exec rubocop                         # Ruby linting
bundle exec rubocop -a                      # Auto-fix
```

## Architecture

**Type:** Rails engine gem (JSON API only, no views)

**Dependencies:**
- `mission_control-jobs` — adapter layer, query objects, job proxy models
- `alba` — JSON serialization
- `rails` — engine framework

**Key directories:**
- `app/controllers/ground_control/api/` — JSON API controllers
- `app/resources/ground_control/api/` — Alba serialization resources
- `app/controllers/concerns/ground_control/api/` — Shared controller concerns
- `lib/ground_control/api/` — Engine, configuration, version
- `config/routes.rb` — API route definitions

**Namespace:** `GroundControl::Api`

## Key Patterns

1. **Controllers** render JSON via Alba resources — never build hashes inline
2. **Mutating actions** (retry, discard, dispatch, pause) return `{ message: "..." }` with status 200
3. **Read actions** return `{ data: ..., meta: ... }` structure
4. **Pagination** uses `MissionControl::Jobs::Page` wrapped in `PageResource`
5. **Error handling** via `ErrorHandling` concern — rescues job/resource not found as 404
6. **Auth** is delegated to host apps via `GroundControl::Api.authenticate_with` proc

## Conventions

- All Ruby files use `frozen_string_literal: true`
- Alba resources inherit from `BaseResource` (lower_camel key transform)
- Rubocop follows `rubocop-rails-omakase` style
- Commits must be signed (GPG or SSH)