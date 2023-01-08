# frozen_string_literal: true

require "bundler/setup"
# require "action_controller"
require "faker"
require "idea_fragments_system_observability"
require "timecop"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before { Bugsnag.add_on_error(->(report) { report.ignore! }) }

  SystemObservability.configure do |c|
    c.config_bugsnag(
      api_key: "00000000000000000000000000000000",
      app_version: "1.0.0",
      enabled_envs: []
    )

    c.config_datadog(
      enabled_envs: [],
      statsd_host: "dd host",
      statsd_port: "dd port",
      track_sidekiq_job_timings: false
    )
  end
end
