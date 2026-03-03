# frozen_string_literal: true

class SystemObservability::ErrorReporter::SentryAdapter
  SEVERITY_MAPPING = {
    debug: :debug,
    error: :error,
    fatal: :fatal,
    info: :info,
    warn: :warning,
    warning: :warning,
  }.freeze

  def self.call(context:, error:, metadata:, severity:, user:)
    new(context:, error:, metadata:, severity:, user:).call
  end

  def call
    Sentry.capture_exception(error) do |scope|
      scope.set_context(:additional, { context: }) if context
      scope.set_context(:custom, format_metadata(metadata)) if metadata.any?
      scope.set_level(map_severity(severity)) if severity
      scope.set_user(format_user(user)) if user
    end
  end

  private

  attr_accessor :context, :error, :metadata, :severity, :user

  def format_metadata(metadata)
    metadata.each_with_object({}) do |(name, object), hash|
      formatter = SystemObservability::ErrorContextDataFormatters.get(object.class)
      hash[name] = formatter.call(object)
    end
  end

  def format_user(user)
    formatter = SystemObservability::ErrorContextDataFormatters.get(user.class)
    formatter.call(user)
  end

  def map_severity(severity)
    SEVERITY_MAPPING[severity.to_sym] || :error
  end

  def initialize(context:, error:, metadata:, severity:, user:)
    self.context = context
    self.error = error
    self.metadata = metadata
    self.severity = severity
    self.user = user
  end
end
