RSpec.describe SystemObservability::SidekiqErrorContextMiddleware do
  let(:middleware) { described_class.new }
  let(:thread_key) { SystemObservability::ErrorContextSetter::BugsnagAdapter::THREAD_KEY }

  after { SystemObservability::ErrorContextSetter::BugsnagAdapter.clear }

  it "Yields to the job block" do
    expect do |probe|
      middleware.call(double, {}, "default", &probe)
    end.to yield_control
  end

  it "Clears error context after a successful job" do
    SystemObservability::ErrorContextSetter.call(receipt_id: "abc-123")

    middleware.call(double, {}, "default") {}

    expect(Thread.current[thread_key]).to be_nil
  end

  it "Clears error context after a job that raises" do
    SystemObservability::ErrorContextSetter.call(receipt_id: "abc-123")

    expect do
      middleware.call(double, {}, "default") { raise StandardError, "job failed" }
    end.to raise_error(StandardError, "job failed")

    expect(Thread.current[thread_key]).to be_nil
  end
end
