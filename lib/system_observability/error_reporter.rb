# frozen_string_literal: true

class SystemObservability::ErrorReporter < SystemObservability::Service
  def self.call(error:, context: nil, metadata: {}, severity: nil, user: nil)
    new(context:, error:, metadata:, severity:, user:).call
  end

  def call
    adapter.call(context:, error:, metadata:, severity:, user:)
  end

  private

  attr_accessor :context, :error, :metadata, :severity, :user

  def adapter
    @adapter ||= SystemObservability.configuration.error_reporter_adapter
  end

  def initialize(context:, error:, metadata:, severity:, user:)
    self.context = context
    self.error = error
    self.metadata = metadata
    self.severity = severity
    self.user = user
  end
end
