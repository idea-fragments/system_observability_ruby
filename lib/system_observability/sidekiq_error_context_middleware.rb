# frozen_string_literal: true

class SystemObservability::SidekiqErrorContextMiddleware
  include Sidekiq::ServerMiddleware

  def call(_worker, _msg, _queue)
    yield
  ensure
    SystemObservability::ErrorContextSetter::BugsnagAdapter.clear
  end
end
