# frozen_string_literal: true

class SystemObservability::ErrorReporter::BugsnagAdapter
  SEVERITY_MAPPING = {
    debug: "info",
    error: "error",
    fatal: "error",
    info: "info",
    warn: "warning",
    warning: "warning",
  }.freeze

  def self.call(context:, error:, metadata:, severity:, user:)
    new(context:, error:, metadata:, severity:, user:).call
  end

  def call
    Bugsnag.notify(error) do |report|
      apply_context(report, context) if context
      apply_metadata(report, metadata) if metadata.any?
      apply_severity(report, severity) if severity
      apply_user(report, user) if user
    end
  end

  private

  attr_accessor :context, :error, :metadata, :severity, :user

  def apply_context(report, context)
    report.context = context
  end

  def apply_metadata(report, metadata)
    formatted_metadata = metadata.each_with_object({}, &method(:format_metadata_value))
    report.add_metadata(:custom, formatted_metadata)
  end

  def apply_severity(report, severity)
    bugsnag_severity = SEVERITY_MAPPING[severity.to_sym] || "error"
    report.severity = bugsnag_severity
  end

  def apply_user(report, user)
    report.user = format_user_value(user)
  end

  def format_metadata_value((name, object), context)
    formatter = SystemObservability::ErrorContextDataFormatters.get(object.class)
    context[name] = formatter.call(object)
  end

  def format_user_value(user)
    formatter = SystemObservability::ErrorContextDataFormatters.get(user.class)
    formatter.call(user)
  end

  def initialize(context:, error:, metadata:, severity:, user:)
    self.context = context
    self.error = error
    self.metadata = metadata
    self.severity = severity
    self.user = user
  end
end
