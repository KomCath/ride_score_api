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

    context "when a cached response is available" do
     let(:cached_response) { "banana" }

      before do
        allow(Rails.cache).to receive(:fetch).and_call_original
        result
      end

      it "retrieves the cached response" do
        expect(Rails.cache).to have_received(:fetch).with(
          a_string_including("#{coordinates.join("%2C")}"), a_hash_including(:expires_in)
        )
      end

      it "doesn't call the external API" do
        expect(HTTParty).not_to receive(:get)
      end
    end

    context "when a cached response is NOT available" do
      before do
        allow(Rails.cache).to receive(:fetch).and_call_original
        allow(HTTParty).to receive(:get)
        result
      end

      it "caches the API response" do
        expect(Rails.cache).to have_received(:fetch).with(
          a_string_including("#{coordinates.join("%2C")}"), a_hash_including(:expires_in)
        )
      end

      it "calls the external API" do
        expect(HTTParty).to have_received(:get)
      end
    end

    context "when the request to the API happens" do
      let(:call_with_vcr) { VCR.use_cassette(cassette_path) { result } }

      before do
        allow(HTTParty).to receive(:get).and_return(expected_response)
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
          expect(call_with_vcr).to include(distance: "10 miles", duration: "30 mins")
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
          expect(call_with_vcr).to include(error: error_message)
        end
      end

      context "when the API is down" do
        let(:cassette_path) { nil }
        let(:expected_response) { RuntimeError }

        before { allow(HTTParty).to receive(:get).and_raise(RuntimeError)}

        it "returns an error message" do
          expect(call_with_vcr).to include(error: a_string_including("#{expected_response}"))
        end
      end
    end

    context "when an unexpected error occurs" do
      let(:error_message) { Faker::Lorem.word }

      before { allow(service).to receive(:make_api_request).and_raise(StandardError, error_message)}

      it "returns an error message" do
        expect(result).to include(error: a_string_including("#{error_message}"))
      end
    end
  end
end
