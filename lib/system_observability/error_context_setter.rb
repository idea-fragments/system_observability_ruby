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
    new(metadata:).call
  end

  def call
    adapter_class.call(metadata:)
  end

  private

  attr_accessor :metadata

  def adapter_class
    case SystemObservability.configuration.error_reporter_adapter.name
      when "SystemObservability::ErrorReporter::BugsnagAdapter"
        SystemObservability::ErrorContextSetter::BugsnagAdapter
      when "SystemObservability::ErrorReporter::SentryAdapter"
        SystemObservability::ErrorContextSetter::SentryAdapter
      else
        raise ArgumentError,
          "Unknown error reporter adapter: #{SystemObservability.configuration.error_reporter_adapter}"
    end
  end

  def initialize(metadata:)
    self.metadata = metadata
  end
end
