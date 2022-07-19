RSpec.describe SystemObservability::ErrorContextSetter do
  let(:expect_context_added) do
    ->(ctx) do
      call_made = false
      Bugsnag.add_on_error(
        ->(report) do
          expect(report.metadata).to include({ context: ctx })
          call_made = true
        end
      )

      Bugsnag.notify(StandardError.new("Test error"))
      expect(call_made).to be true
    end
  end
  let(:metadata) { { my: "object" } }

  it "Sends provided context to Bugsnag when an error occurs" do
    described_class.call(**metadata)
    expect_context_added.call(metadata)
  end

  context "If an object is mapped to a context key" do
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
      expect_context_added.call({
        **metadata,
        team: team.to_h.slice(:id, :name),
        user: user.to_h.slice(:id, :first_name)
      })
    end
  end
end
