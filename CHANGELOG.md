## [Unreleased]

## [0.2.1] - 2026-03-03

### Added
- ErrorReporter service for unified error reporting across Bugsnag and Sentry
- BugsnagAdapter and SentryAdapter for provider-specific error reporting
- Support for error metadata, severity levels, context, and user information
- Configuration method `config_error_reporter` to switch between providers
- ErrorContextSetter now forks based on configured provider (Bugsnag or Sentry)
- WebErrorReporter now forks based on configured provider (Bugsnag or Sentry)

## [0.1.0] - 2022-05-12

- Initial release
