# frozen_string_literal: true

class SystemObservability::Configuration
  attr_accessor :env

  def config_bugsnag(api_key:, app_version:, enabled_envs: [])
    Bugsnag.configure do |config|
      config.api_key = api_key
      config.app_version = app_version
      config.enabled_release_stages = enabled_envs
    end
  end

  def config_datadog(
    enabled_envs: [],
    statsd_host: ENV.fetch("DATADOG_HOST"),
    statsd_port: ENV.fetch("DATADOG_PORT")
  )
    return SystemObservability::Stats::NullInstance.new if enabled_envs.exclude?(env)

    SystemObservability::Stats.new(Datadog::Statsd.new(statsd_host, statsd_port))
  end
end
