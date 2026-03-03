# frozen_string_literal: true

class SystemObservability::ErrorContextSetter::SentryAdapter
  def self.call(metadata:)
    new(metadata:).call
  end

  def call
    Sentry.configure_scope do |scope|
      scope.set_context(:custom, formatted_metadata)
    end
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
