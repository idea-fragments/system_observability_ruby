# frozen_string_literal: true

module SystemObservability::Rails::WebResponseTimer
  extend ActiveSupport::Concern

  included { around_action :time_request }

  def time_request(&block)
    SystemObservability::Stats.time(
      "web.response.time",
      tags: { controller: self.class.name, http_method: request.request_method },
      &block
    )
  end
end
