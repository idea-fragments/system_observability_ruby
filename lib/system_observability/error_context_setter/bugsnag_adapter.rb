# frozen_string_literal: true

class SystemObservability::ErrorContextSetter::BugsnagAdapter
  THREAD_KEY = :__system_observability_error_context

  def self.call(metadata:)
    new(metadata:).call
  end

  def self.clear
    Thread.current[THREAD_KEY] = nil
  end

  def call
    Thread.current[THREAD_KEY] = formatted_metadata
  end

  private

  attr_accessor :metadata

  def format_value(object)
    return object if SystemObservability::ErrorContextSetter::TYPES_WITHOUT_FORMATTERS.include?(object.class.name)

    formatter = SystemObservability::ErrorContextDataFormatters.get(object.class)
    formatter.call(object)
  end

  def formatted_metadata
    metadata.transform_values { |value| format_value(value) }
  end

  def initialize(metadata:)
    self.metadata = metadata
  end
end
