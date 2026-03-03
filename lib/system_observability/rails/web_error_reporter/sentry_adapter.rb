# frozen_string_literal: true

module SystemObservability::Rails::WebErrorReporter::SentryAdapter
  extend ActiveSupport::Concern

  included { before_action :add_user_info_to_sentry }

  def add_user_info_to_sentry
    formatter = SystemObservability::ErrorContextDataFormatters.get(current_user.class)
    user_data = formatter.call(current_user)

    Sentry.configure_scope do |scope|
      scope.set_user(user_data)
    end
  end
end
