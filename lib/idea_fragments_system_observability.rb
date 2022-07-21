# frozen_string_literal: true

require "bundler/setup"
require "active_support"
require "bugsnag"
require "datadog/statsd"
require "newrelic_rpm"
require "sidekiq"

module SystemObservability
  def self.configuration
    @configuration ||= SystemObservability::Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset
    @configuration = Configuration.new
  end
end

require_relative "./service"
Dir["#{File.dirname(__FILE__)}/**/*.rb"].sort.each { |f| require f }
