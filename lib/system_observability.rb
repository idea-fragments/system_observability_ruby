# frozen_string_literal: true

require "bundler/setup"
require "bugsnag"
require "datadog/statsd"
require "newrelic_rpm"

module SystemObservability
  class << self
    attr_accessor :configuration
  end

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
