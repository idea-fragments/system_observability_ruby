# frozen_string_literal: true

class SystemObservability::Stats
  class << self
    def instance=(instance)
      raise "Instance already defined" if defined? self.instance
      @instance = instance
    end

    def instance_class
      instance.class.name
    end

    def method_missing(*args, &block)
      instance.public_send(*args, &block)
    end

    def respond_to_missing?(*args)
      instance.respond_to_missing?(*args)
    end

    private

    attr_reader :instance
  end

  def count(stat, count, tags: {})
    datadog.count(stat, count, tags: formatted_tags(tags))
  end

  def increment(stat, tags: {})
    datadog.increment(stat, tags: formatted_tags(tags))
  end

  def gauge(stat, value, sample_rate: 1.0, tags: {})
    datadog.gauge(stat, value, sample_rate: sample_rate, tags: formatted_tags(tags))
  end

  def histogram(stat, value, tags: {})
    datadog.histogram(stat, value, tags: formatted_tags(tags))
  end

  def distribution(stat, value, tags: {})
    datadog.distribution("dist.#{stat}", value, tags: formatted_tags(tags))
  end

  def time(stat, tags: {}, &block)
    datadog.time(stat, tags: formatted_tags(tags), &block)
  end

  def timing(stat, ms, tags: {})
    datadog.timing(stat, ms, tags: formatted_tags(tags))
  end

  private

  def formatted_tags(tags)
    tags.map { |name, value| "#{name}:#{value}" }
  end

  attr_accessor :datadog

  def initialize(datadog)
    self.datadog = datadog
  end

  class NullInstance
    def method_missing(_name, *_args)
      yield if block_given?
    end

    def respond_to_missing?(_name, *_args); end
  end
end
