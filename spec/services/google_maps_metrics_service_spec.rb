RSpec.describe GoogleMapsMetricsService, type: :service do
  let(:coordinates) { [Faker::Address.latitude, Faker::Address.longitude] }

  describe ".initialize" do
    it "requires origin" do
      expect { described_class.new(coordinates) }.to raise_error(ArgumentError)
    end

    it "requires destination" do
      expect { described_class.new(coordinates) }.to raise_error(ArgumentError)
    end
  end

  describe "#fetch_distance_and_duration" do
    let(:service) { described_class.new(coordinates, coordinates) }
    let(:result) { service.fetch_distance_and_duration }

    context "when the request to the API happens" do
      let(:call_with_vcr) { VCR.use_cassette(cassette_path) { result } }

      before do
        allow(HTTParty).to receive(:get).and_return(expected_response)
        call_with_vcr
      end

      context "when the request is successful" do
        let(:cassette_path) { "successful_api_request" }
        let(:expected_response) do
          {
            "status" => "OK",
            "rows" => [{
              "elements" => [{
                "status" => "OK",
                "distance" => { "text" => "10 miles" },
                "duration" => { "text" => "30 mins" }
              }]
            }]
          }
        end

        it "returns distance and duration" do
          expect(result).to include(distance: "10 miles", duration: "30 mins")
        end
      end

      context "when the request fails" do
        let(:cassette_path) { "failed_api_request" }
        let(:error_message) { Faker::Lorem.word }
        let(:expected_response) do
          {
            "status" => "OK",
            "rows" => [{
              "elements" => [{
                "status" => error_message
              }]
            }]
          }
        end

        it "returns an error message" do
          expect(result).to include(error: error_message)
        end
      end

      context "when the API is down" do
        let(:cassette_path) { nil }
        let(:expected_response) { "Failed to fetch data from the Google Maps API" }

        before { allow(HTTParty).to receive(:get).and_raise(RuntimeError)}
        it "returns an error message" do
          expect(result).to include(error: expected_response)
        end
      end
    end

    context "when an unexpected error occurs" do
      let(:error_message) { Faker::Lorem.word }
      before { allow(service).to receive(:make_api_request).and_raise(StandardError, error_message)}
      it "returns an error message" do
        expect(result).to include(error: "An unexpected error occurred: #{error_message}")
      end
    end
  end
end
