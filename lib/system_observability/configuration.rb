# frozen_string_literal: true

class SystemObservability::Configuration
  attr_accessor :env, :error_reporter_adapter

  def initialize
    @error_reporter_adapter = SystemObservability::ErrorReporter::BugsnagAdapter
  end

  def config_bugsnag(api_key:, app_version:, enabled_envs: [])
    Bugsnag.configure do |config|
      config.api_key = api_key
      config.app_version = app_version
      config.enabled_release_stages = enabled_envs
    end

    Bugsnag.add_on_error(method(:add_error_context_from_thread))

    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add SystemObservability::SidekiqErrorContextMiddleware
      end
    end
  end

  def config_datadog(
    enabled_envs: [],
    statsd_host: ENV.fetch("DATADOG_HOST"),
    statsd_port: ENV.fetch("DATADOG_PORT"),
    track_sidekiq_job_timings: false
  )
    SystemObservability::Stats.instance =
      enabled_envs.include?(env) ?
        SystemObservability::Stats.new(Datadog::Statsd.new(statsd_host, statsd_port)) :
        SystemObservability::Stats::NullInstance.new

    config_sidekiq_stats_middleware if track_sidekiq_job_timings
  end

  def config_error_reporter(provider:)
    self.error_reporter_adapter = case provider
      when :bugsnag
        SystemObservability::ErrorReporter::BugsnagAdapter
      when :sentry
        SystemObservability::ErrorReporter::SentryAdapter
      else
        raise ArgumentError, "Unknown error reporter provider: #{provider}"
    end
  end

  def enable_query_log_tags(app_module)
    app_module::Application.configure do |app|
      app.config.active_record.query_log_tags = [:application, :controller, :action, :job]
      app.config.active_record.query_log_tags_enabled = true
    end
  end

  private

  def add_error_context_from_thread(report)
    metadata = Thread.current[SystemObservability::ErrorContextSetter::BugsnagAdapter::THREAD_KEY]
    return unless metadata

    report.add_metadata(:context, metadata)
  end

  def config_sidekiq_stats_middleware
    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add SystemObservability::SidekiqStatsMiddleware
      end
    end
  end
end
