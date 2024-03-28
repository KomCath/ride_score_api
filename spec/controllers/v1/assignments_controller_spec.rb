RSpec.describe V1::AssignmentsController, type: :controller do
  describe "GET #index" do
    context "when driver exists" do
      let(:driver) { create(:driver) }
      let(:num_assignments) { 5 }
      let(:json_response) { JSON.parse(response.body) }
      let!(:expected_data) do
        create_list(:ride, num_assignments, ride_duration: 1.2, ride_earnings: 5).map do |ride|
          create(:assignment, driver: driver, ride: ride, score: 35, commute_duration: 0.5)
        end
      end

      before do
        create_list(:ride, 10, ride_duration: 1.2, ride_earnings: 5).map do |ride|
          create(:assignment, ride: ride, score: 35, commute_duration: 0.5)
        end
        get :index, params: { driver_id: driver.id }
      end

      it "returns a successful response" do
        expect(response).to have_http_status(:success)
      end

      context "when returning assignments" do
        it "returns the correct number of assignments associated with the driver" do
          expect(json_response.count).to eq(expected_data.count)
        end

        it "returns assignments associated ONLY with the driver" do
          response_scores = json_response.map { |item| item["score"] }
          expected_scores = expected_data.map(&:score)

          expect(response_scores).to include(*expected_scores)
        end

        context "when there are more assignments than the per-page limit" do
          let(:num_assignments) { 20 }

          it "return the allowed paginated value 10" do
            expect(json_response.count).to eq(V1::AssignmentsController::DEFAULT_PER_PAGE_SIZE)
          end
        end

      end
    end

    context "when driver does NOT exist" do
      before do
        get :index, params: { driver_id: "invalid_id" }
      end

      it "returns not_found response" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(response.body).to eq({ error: "Driver not found" }.to_json)
      end
    end
  end
end
