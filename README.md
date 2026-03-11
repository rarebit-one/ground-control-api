# Ground Control API

A headless JSON API Rails engine for managing Active Job queues, jobs, workers, and recurring tasks. Built on top of [mission_control-jobs](https://github.com/rails/mission_control-jobs) for the adapter and query layer.

Use standalone for custom frontends, or as the foundation for [ground_control-inertia](https://github.com/rarebit-one/ground-control-inertia).

## Installation

```ruby
# Gemfile
gem "ground_control-api", github: "rarebit-one/ground-control-api"
```

## Setup

Mount the engine in your routes:

```ruby
# config/routes.rb
mount GroundControl::Api::Engine, at: "/ground-control/api"
```

### Authentication

By default, endpoints are unauthenticated. Configure a custom auth strategy:

```ruby
# config/initializers/ground_control.rb
GroundControl::Api.authenticate_with = ->(controller) do
  controller.head :unauthorized unless controller.current_user&.admin?
end
```

### Multi-application support

If you run multiple queue backends, register them explicitly:

```ruby
MissionControl::Jobs.applications.add("Primary", {
  "solid_queue" => ActiveJob::QueueAdapters::SolidQueueAdapter.new
})

MissionControl::Jobs.applications.add("Legacy", {
  "resque" => ActiveJob::QueueAdapters::ResqueAdapter.new(Redis.new)
})
```

Otherwise, the engine auto-registers your default `active_job.queue_adapter`.

## API

All endpoints are scoped under `/applications/:application_id`. When only one application is registered, the application ID can be inferred.

### Queues

| Method | Path | Description |
|--------|------|-------------|
| GET | `/applications/:app/queues` | List all queues |
| GET | `/applications/:app/queues/:id` | Show queue with paginated jobs |
| POST | `/applications/:app/queues/:id/pause` | Pause a queue |
| DELETE | `/applications/:app/queues/:id/pause` | Resume a queue |

### Jobs

| Method | Path | Description |
|--------|------|-------------|
| GET | `/applications/:app/:status/jobs` | List jobs by status (paginated, filterable) |
| GET | `/applications/:app/jobs/:id` | Show job details |
| POST | `/applications/:app/jobs/:id/retry` | Retry a failed job |
| POST | `/applications/:app/jobs/:id/discard` | Discard a job |
| POST | `/applications/:app/jobs/:id/dispatch` | Dispatch a blocked/scheduled job |
| POST | `/applications/:app/jobs/bulk_retries` | Retry all matching failed jobs |
| POST | `/applications/:app/jobs/bulk_discards` | Discard all matching failed jobs |

**Filtering:** Pass `filter[job_class_name]`, `filter[queue_name]`, `filter[finished_at_start]`, `filter[finished_at_end]` as query params.

**Pagination:** Pass `page` as a query param. Default page size is 10, configurable via `GroundControl::Api.page_size`.

### Workers

| Method | Path | Description |
|--------|------|-------------|
| GET | `/applications/:app/workers` | List workers (if adapter supports it) |
| GET | `/applications/:app/workers/:id` | Show worker details |

### Recurring Tasks

| Method | Path | Description |
|--------|------|-------------|
| GET | `/applications/:app/recurring_tasks` | List recurring tasks |
| GET | `/applications/:app/recurring_tasks/:id` | Show task with execution history |
| PATCH | `/applications/:app/recurring_tasks/:id` | Trigger a recurring task |

### Feature Discovery

| Method | Path | Description |
|--------|------|-------------|
| GET | `/applications/:app/features` | Adapter capabilities (supported statuses, workers, recurring tasks, queue pausing) |

## Configuration

```ruby
GroundControl::Api.authenticate_with = ->(controller) { ... }  # Auth callback
GroundControl::Api.page_size = 25                                # Default: 10
```

## Architecture

```
ground_control-api
├── app/controllers/ground_control/api/   # JSON API controllers
├── app/resources/ground_control/api/     # Alba serialization resources
├── app/controllers/concerns/             # JobFilters, AdapterFeatures, ErrorHandling
├── config/routes.rb                      # Engine routes
└── lib/ground_control/api/               # Engine, config, version
         ↓ depends on
mission_control-jobs                      # Adapter layer, query objects, models
```

## Development

```bash
bundle install
bundle exec rspec           # Run tests
bundle exec rubocop         # Lint
```

## License

MIT
