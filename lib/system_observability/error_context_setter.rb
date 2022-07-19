# frozen_string_literal: true

class SystemObservability::ErrorContextSetter
  TYPES_WITHOUT_FORMATTERS = Set.new([
    Array.name,
    Float.name,
    Hash.name,
    Integer.name,
    NilClass.name,
    String.name,
    Symbol.name,
    TrueClass.name,
  ])

  def self.call(**metadata)
    new(metadata).call
  end

  def call
    Bugsnag.add_on_error(method(:add_report_context))
  end

  private

  def add_report_context(report)
    report.add_metadata(
      :context,
      metadata.each_with_object({}, &method(:format))
    )
  end

  def format((name, object), context)
    return context[name] = object if TYPES_WITHOUT_FORMATTERS.include?(object.class.name)

    formatter = SystemObservability::ErrorContextDataFormatters.get(object.class)
    context[name] = formatter.call(object)
  end

  attr_accessor :metadata

  def initialize(metadata)
    self.metadata = metadata
  end
end
