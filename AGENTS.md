# AGENTS.md - AI Agent Guide for GroundControl::Api

GroundControl::Api is a Rails engine providing a headless JSON API for
managing Active Job queues, jobs, workers, and recurring tasks on top of
`mission_control-jobs`. It is the foundation for `ground_control-inertia`
(which adds an Inertia.js + React UI) but can be used standalone.

## Quick Reference

```bash
# Run the full spec suite
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/path/to/foo_spec.rb

# Lint
bundle exec rubocop

# Auto-fix lint issues
bundle exec rubocop -A

# Security checks
bundle exec brakeman --no-pager
bundle exec bundler-audit --update
```

`Gemfile.lock` is gitignored — `bundle install` regenerates it locally and
in CI.

## Project Structure

```
ground_control-api/
├── app/
│   ├── controllers/ground_control/api/
│   │   ├── application_controller.rb       # JSON API base
│   │   ├── applications_controller.rb      # Mission Control applications
│   │   ├── queues_controller.rb            # Queue listing + pause toggle
│   │   ├── queues/pauses_controller.rb     # Nested pause/resume action
│   │   ├── jobs_controller.rb              # Job index/show
│   │   ├── retries_controller.rb           # Single-job retry
│   │   ├── bulk_retries_controller.rb      # Bulk retry
│   │   ├── discards_controller.rb          # Single-job discard
│   │   ├── bulk_discards_controller.rb     # Bulk discard
│   │   ├── dispatches_controller.rb        # Force-dispatch scheduled jobs
│   │   ├── workers_controller.rb           # Worker process listing
│   │   ├── recurring_tasks_controller.rb   # Recurring task listing
│   │   ├── features_controller.rb          # Adapter capability flags
│   │   └── concerns/                       # error_handling, job_filters,
│   │                                       # adapter_features
│   └── resources/ground_control/api/
│       ├── application_resource.rb         # Alba serializers
│       ├── base_resource.rb
│       ├── job_resource.rb
│       ├── page_resource.rb                # Pagination wrapper
│       ├── queue_resource.rb
│       ├── recurring_task_resource.rb
│       ├── server_resource.rb              # Worker/server detail
│       └── worker_resource.rb
├── config/
│   └── routes.rb                           # JSON API surface
├── lib/ground_control/api/
│   ├── engine.rb                           # Wires middleware, requires
│   │                                       # mission_control-jobs engine
│   └── version.rb
└── spec/
    └── spec_helper.rb
```

## Key Patterns

### Engine boot

`GroundControl::Api::Engine` isolates the `GroundControl::Api` namespace and
requires `mission_control/jobs/engine` after initialize so all of Mission
Control's Active Record-style models are available without forcing the host
app to mount the upstream UI engine. `ActionDispatch::Flash` and
`Rack::MethodOverride` are inserted as middleware so the API can be mounted
under the same Rails stack as a host app without surprise.

### Resources (Alba)

Every JSON response goes through an Alba resource under
`app/resources/ground_control/api/`. `ApplicationResource` is the base for
gem-specific concerns; individual resources (e.g. `JobResource`,
`QueueResource`) define the public attribute set. `PageResource` wraps a
collection plus pagination metadata for index endpoints.

### Controllers

Controllers inherit from `GroundControl::Api::ApplicationController`, which
forces JSON responses and includes the `ErrorHandling`, `JobFilters`, and
`AdapterFeatures` concerns. Mutation endpoints (retries, discards,
dispatches, queue pauses) are namespaced as separate controllers per REST
resource rather than as custom actions on the parent.

### Adapter feature detection

`AdapterFeatures` exposes which capabilities the active Active Job adapter
supports (e.g. recurring tasks, bulk operations). The `FeaturesController`
returns this map so a UI client can hide controls the underlying queue
backend cannot service.

## Common Workflows

### Adding a new endpoint

1. Add the route under `config/routes.rb` inside the engine's namespace.
2. Create or extend a controller under `app/controllers/ground_control/api/`.
3. Define an Alba resource for the response shape under
   `app/resources/ground_control/api/`.
4. Add a request spec under `spec/requests/`.

### Running against a host app

The engine assumes Rails 8.0+ and `mission_control-jobs >= 0.6`. Mount it
in a host app with:

```ruby
mount GroundControl::Api::Engine, at: "/ground_control/api"
```

The host app provides the Active Job adapter, queue store, and any
authentication via Rails' standard middleware stack — this engine
intentionally has no auth opinions.

## Testing

- RSpec via `rspec-rails`. `spec/spec_helper.rb` is currently minimal —
  request specs that drive the engine through a dummy host app should be
  added under `spec/requests/`.
- Lefthook pre-push runs whitespace + signature checks, RuboCop on `*.rb`,
  and `rspec --fail-fast`.

## Security Notes

- Brakeman and bundler-audit run in CI (`extra-lint-commands` of the
  reusable `reusable-gem-ci.yml@v1` workflow) and as pre-push lefthook
  steps.
- The engine deliberately ships no authentication — host apps are
  responsible for protecting the mount point with their existing auth
  middleware.

## Key Files

| File                                                | Purpose                                         |
|-----------------------------------------------------|-------------------------------------------------|
| `lib/ground_control/api/engine.rb`                  | Engine wiring + middleware                      |
| `lib/ground_control/api/version.rb`                 | Gem version                                     |
| `app/controllers/ground_control/api/application_controller.rb` | JSON API base controller         |
| `app/controllers/concerns/ground_control/api/error_handling.rb`| Shared rescue + JSON error shape |
| `app/controllers/concerns/ground_control/api/job_filters.rb`   | Index filtering / sorting       |
| `app/controllers/concerns/ground_control/api/adapter_features.rb` | Capability detection         |
| `app/resources/ground_control/api/application_resource.rb`     | Alba base resource              |
| `app/resources/ground_control/api/page_resource.rb`            | Pagination wrapper              |
| `config/routes.rb`                                  | JSON API surface                                |
| `.github/workflows/ci.yml`                          | Reusable CI shim                                |
| `.github/workflows/release.yml`                     | Reusable release shim                           |
| `lefthook.yml`                                      | Pre-push hooks                                  |

## Dependencies

- **rails** — `>= 8.0`
- **mission_control-jobs** — `>= 0.6`
- **alba** — `>= 3.0` (JSON serialization)

Dev / test:

- **rspec-rails** — test framework
- **rubocop-rails-omakase** — linting
- **brakeman**, **bundler-audit** — security scanners
- **lefthook** — git hook manager
