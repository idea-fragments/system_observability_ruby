RSpec.describe SystemObservability::Stats do
  let(:datadog) { instance_double(Datadog::Statsd) }
  let(:stats) { described_class.new(datadog) }
  let(:metric_name) { "test.increment" }

  it "Notifies datadog of stats" do
    expect(datadog).to receive(:increment).with(metric_name, tags: [])
    stats.increment(metric_name)
  end

  context "If tags are provided" do
    let(:tags) { { team_id: 434, type: "something" } }

    it "Sends the tags to datadog, formatted correctly" do
      expect(datadog).to receive(:increment)
        .with(metric_name, tags: ["team_id:434", "type:something"])
      stats.increment(metric_name, tags: tags)
    end
  end
end
