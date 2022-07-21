# RSpec.describe SystemObservability::WebResponseTimer do
#   let(:response_duration) { 10.seconds }
#
#   before do
#     Timecop.freeze
#
#     stub_const(
#       "SystemObservability::WebResponseTimer::TestsController",
#       Class.new(ActionController::API) do
#         include SystemObservability::WebResponseTimer
#
#         def index
#         end
#       end
#     )
#   end
#
#   it "Sends timer metric for web response to the stats service" do
#     expect(SystemObservability::Stats).to receive(:time)
#       .with(
#         "web.response.time",
#         tags: {
#           controller: "SystemObservability::WebResponseTimer::TestsController",
#           http_method: "get"
#         }
#       )
#
#     SystemObservability::WebResponseTimer::TestsController.new.index
#   end
# end
