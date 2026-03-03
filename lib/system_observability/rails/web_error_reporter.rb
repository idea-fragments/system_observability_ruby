# frozen_string_literal: true

module SystemObservability::Rails::WebErrorReporter
  extend ActiveSupport::Concern

  included do
    case SystemObservability.configuration.error_reporter_adapter.name
    when "SystemObservability::ErrorReporter::BugsnagAdapter"
      include SystemObservability::Rails::WebErrorReporter::BugsnagAdapter
    when "SystemObservability::ErrorReporter::SentryAdapter"
      include SystemObservability::Rails::WebErrorReporter::SentryAdapter
    else
      raise ArgumentError, "Unknown error reporter adapter: #{SystemObservability.configuration.error_reporter_adapter}"
    end
  end
end
