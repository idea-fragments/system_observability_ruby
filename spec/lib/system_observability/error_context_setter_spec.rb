RSpec.describe SystemObservability::ErrorContextSetter do
  let(:metadata) { { my: "object" } }
  let(:thread_key) { SystemObservability::ErrorContextSetter::BugsnagAdapter::THREAD_KEY }

  after { SystemObservability::ErrorContextSetter::BugsnagAdapter.clear }

  it "Stores metadata on the current thread" do
    described_class.call(**metadata)
    expect(Thread.current[thread_key]).to eq(metadata)
  end

  it "Sends provided context to Bugsnag when an error occurs" do
    described_class.call(**metadata)

    captured_metadata = nil
    Bugsnag.add_on_error(lambda do |report|
      captured_metadata = report.metadata[:context]
    end)

    Bugsnag.notify(StandardError.new("Test error"))

    expect(captured_metadata).to eq(metadata)
  end

  it "Does not leak metadata to other threads" do
    described_class.call(receipt_id: "thread-1-receipt")

    other_thread_metadata = nil
    thread = Thread.new do
      other_thread_metadata = Thread.current[thread_key]
    end
    thread.join

    expect(other_thread_metadata).to be_nil
  end

  it "Does not leak metadata between sequential jobs on the same thread" do
    described_class.call(receipt_id: "job-1-receipt")
    SystemObservability::ErrorContextSetter::BugsnagAdapter.clear

    captured_metadata = nil
    Bugsnag.add_on_error(lambda do |report|
      captured_metadata = report.metadata[:context]
    end)

    Bugsnag.notify(StandardError.new("Job 2 crash"))

    expect(captured_metadata).to be_nil
  end

  context "When an object is mapped to a context key" do
    let(:team) { Team.new(id: (1..10).to_a.sample, name: Faker::Company.name) }
    let(:team_formatter) { ->(t) { t.to_h.slice(:id, :name) } }
    let(:user) do
      User.new(
        id: (1..10).to_a.sample,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
      )
    end
    let(:user_formatter) { ->(u) { u.to_h.slice(:id, :first_name) } }

    before do
      stub_const("User", Class.new(OpenStruct))
      stub_const("Team", Class.new(OpenStruct))
      SystemObservability::ErrorContextDataFormatters.add(User, user_formatter)
      SystemObservability::ErrorContextDataFormatters.add(Team, team_formatter)
    end

    it "Sends the formatted object data to Bugsnag when an error occurs" do
      expect(team_formatter).to receive(:call).with(team).and_call_original
      expect(user_formatter).to receive(:call).with(user).and_call_original

      described_class.call(**metadata, team: team, user: user)

      captured_metadata = nil
      Bugsnag.add_on_error(lambda do |report|
        captured_metadata = report.metadata[:context]
      end)

      Bugsnag.notify(StandardError.new("Test error"))

      expect(captured_metadata).to eq({
        **metadata,
        team: team.to_h.slice(:id, :name),
        user: user.to_h.slice(:id, :first_name)
      })
    end
  end
end
