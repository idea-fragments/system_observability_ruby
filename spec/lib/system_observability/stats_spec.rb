RSpec.describe SystemObservability::Stats do
  let(:datadog) { instance_double(Datadog::Statsd) }
  let(:metric_name) { "test.increment" }
  let(:stats) { described_class }

  before { described_class.instance = described_class.new(datadog) }

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

    context "For stats that require a code block" do
      it "Passes the block and stat details to datadog" do
        expect do |probe|
          expect(datadog).to receive(:time).with(
            metric_name, tags: ["team_id:434", "type:something"]
          )
          stats.time(metric_name, tags: tags, &probe)
        end
      end
    end
  end
end
