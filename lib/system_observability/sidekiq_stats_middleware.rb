# frozen_string_literal: true

class SystemObservability::SidekiqStatsMiddleware
  def call(worker, msg, _queue, &block)
    job_name = worker.class.name
    latency = calculate_latency(msg)
    tags = { job: job_name }
    Rails.logger.info "running SystemObservability::SidekiqStatsMiddleware"
    SystemObservability::Stats.distribution("sidekiq.jobs.latency", latency, tags: tags)
    SystemObservability::Stats.time("sidekiq.jobs.time", tags: tags, &block)
  end

  def calculate_latency(msg)
    if msg["enqueued_at"]
      (Time.now.to_f - msg["enqueued_at"]) * 1000
    else
      0
    end
  end
end
