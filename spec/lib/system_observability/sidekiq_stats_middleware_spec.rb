RSpec.describe SystemObservability::SidekiqStatsMiddleware do
  let(:middleware) { described_class.new }

  before do
    allow(SystemObservability::Stats).to receive(:distribution)
    allow(SystemObservability::Stats).to receive(:time)
  end

  it "logs the correct message datadog" do
    expect(SystemObservability::Stats).to receive(:time)
      .with("sidekiq.jobs.time", tags: { job: "RSpec::Mocks::Double" })

    middleware.call(double, { "msg" => "fake news" }, "queue_name") {}
  end

  it "calculates the latency" do
    Timecop.freeze
    seconds_latency = 10
    enqueued_time = (Time.now - seconds_latency).to_f

    expect(SystemObservability::Stats).to receive(:distribution).with(
      "sidekiq.jobs.latency",
      seconds_latency * 1000.0,
      tags: { job: "RSpec::Mocks::Double" }
    )

    middleware.call(double, { "enqueued_at" => enqueued_time }, "queue_name") {}
  end

  it "yields to the block given" do
    SystemObservability::Stats.instance = SystemObservability::Stats::NullInstance.new
    expect(SystemObservability::Stats).to receive(:time).and_call_original

    expect do |probe|
      middleware.call(double, { "msg" => "fake news" }, "queue_name", &probe)
    end.to yield_control
  end
end
