# frozen_string_literal: true

class SystemObservability::ErrorContextSetter::BugsnagAdapter
  def self.call(metadata:)
    new(metadata:).call
  end

  def call
    Bugsnag.add_on_error(method(:add_report_context))
  end

  private

  attr_accessor :metadata

  def add_report_context(report)
    report.add_metadata(:context, formatted_metadata)
  end

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
