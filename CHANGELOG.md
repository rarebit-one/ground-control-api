# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- CI and release workflows migrated to the shared `rarebit-one/.github` reusable workflows (`reusable-gem-ci.yml@v1`, `reusable-gem-release.yml@v1`); `.github/workflows/ci.yml` and `release.yml` are now thin shims.

### Removed

- **BREAKING:** Dropped support for Rails < 8.0. The `rails` constraint is now `>= 8.0` (was `>= 7.1`). Hosts on Rails 7.x must upgrade to Rails 8.0+ before bundling this version. Aligns with the org-wide policy of supporting Rails 8 and up.

## [0.1.0] - 2026-04-21

### Added

- Initial release of Ground Control API
- JSON API endpoints for managing Active Job queues, jobs, workers, and recurring tasks
- Built on top of mission_control-jobs
