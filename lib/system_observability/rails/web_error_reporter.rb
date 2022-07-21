# frozen_string_literal: true

module SystemObservability::Rails::WebErrorReporter
  extend ActiveSupport::Concern

  included { before_bugsnag_notify :add_user_info_to_bugsnag }

  def add_user_info_to_bugsnag(report)
    formatter = SystemObservability::ErrorContextDataFormatters.get(current_user.class)
    report.user = formatter.call(current_user)
  end
end
