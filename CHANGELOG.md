## [Unreleased]

## [0.3.0] - 2026-04-29

### Fixed
- ErrorContextSetter::BugsnagAdapter no longer registers a new `add_on_error` callback per invocation, which caused stale metadata from previous jobs to leak onto unrelated error reports in multi-threaded Sidekiq processes
- Bugsnag error context metadata is now stored in thread-local storage, ensuring isolation between concurrent Sidekiq threads

### Added
- SidekiqErrorContextMiddleware to clear thread-local error context after each job completes
- Global `add_on_error` callback registered once at boot via `config_bugsnag`, reading context from thread-local storage

## [0.2.2] - 2026-03-03

### Added
- ErrorReporter service for unified error reporting across Bugsnag and Sentry
- BugsnagAdapter and SentryAdapter for provider-specific error reporting
- Support for error metadata, severity levels, context, and user information
- Configuration method `config_error_reporter` to switch between providers
- ErrorContextSetter now forks based on configured provider (Bugsnag or Sentry)
- WebErrorReporter now forks based on configured provider (Bugsnag or Sentry)

### Fixed
- Service class now loads before other classes to prevent initialization errors

## [0.1.0] - 2022-05-12

- Initial release
