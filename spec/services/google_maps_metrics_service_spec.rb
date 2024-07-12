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
    let(:result) { VCR.use_cassette(cassette_path) { service.fetch_distance_and_duration } }
    let(:cache_key) { "distance_metrics:#{coordinates.join("%2C")}_to_#{coordinates.join("%2C")}" }
    let(:error_message) { Faker::Lorem.word }

    shared_examples "calls the external API" do
      it { expect(HTTParty).to have_received(:get).with(a_string_including(GoogleMapsMetricsService::BASE_URL)) }
    end

    before { allow(Rails.cache).to receive(:fetch).and_call_original }

    context "when an unexpected error occurs" do
      before { allow(service).to receive(:make_api_request).and_raise(StandardError, error_message) }

      it "returns an error message" do
        expect(service.fetch_distance_and_duration).
          to include(message: a_string_including("#{error_message}"))
      end

      it "does NOT call the external API" do
        expect(HTTParty).not_to receive(:get).
          with(a_string_including(GoogleMapsMetricsService::BASE_URL))
      end

      it "checks the cache" do
        service.fetch_distance_and_duration
        expect(Rails.cache).to have_received(:fetch).
          with(a_string_including("#{coordinates.join("%2C")}"), a_hash_including(:expires_in))
      end
    end

    context "when a cached response is available" do
      let(:cache_response) { Faker::ChuckNorris.fact }

      before do
        Rails.cache.write(cache_key, cache_response)
        allow(HTTParty).to receive(:get)
        service.fetch_distance_and_duration
      end

      it "checks the cache" do
        expect(Rails.cache).to have_received(:fetch).
          with(a_string_including("#{coordinates.join("%2C")}"), a_hash_including(:expires_in))
      end

      it "retrieves the cached response" do
        expect(service.fetch_distance_and_duration).to eq(cache_response)
      end

      it "does NOT call the external API" do
        expect(HTTParty).not_to have_received(:get).
          with(a_string_including(GoogleMapsMetricsService::BASE_URL))
      end
    end

    context "when a cached response is NOT available" do
      before { Rails.cache.delete(cache_key) }

      context "when the response is successful" do
        let(:cassette_path) { "successful_api_request" }
        let(:expected_response) { instance_double(HTTParty::Response, success?: true, body: response_body) }

        before do
          allow(HTTParty).to receive(:get).and_return(expected_response)
          result
        end

        context "when the response status is OK" do
          let(:response_body) do
            {
              "status" => "OK",
              "rows" => [{
                "elements" => [{
                  "status" => "OK",
                  "distance" => { "text" => "10 miles" },
                  "duration" => { "text" => "30 mins" }
                }]
              }]
            }.to_json
          end

          it_behaves_like "calls the external API"

          it "caches the API response" do
            expect(Rails.cache.read(cache_key)).to eq(result)
          end

          it "returns distance and duration" do
            expect(result).to include(distance: "10 miles", duration: "30 mins")
          end
        end

        context "when the response status is NOT OK" do
          let(:response_body) do
            {
              "status" => "REQUEST_DENIED",
              "error_message" => "Invalid API key",
            }.to_json
          end

          it_behaves_like "calls the external API"

          it "does NOT cache the API response" do
            expect(Rails.cache.read(cache_key)).to be_nil
          end

          it "returns an ERROR status with a message" do
            expect(result).to include(status: "ERROR", message: a_string_including("REQUEST_DENIED", "Invalid API key"))
          end
        end
      end

      context "when the response is NOT successful" do
        let(:cassette_path) { "failed_api_request" }
        let(:http_code) { Faker::Number.number(digits: 3) }
        let(:error_message) { Faker::Lorem.word }
        let(:expected_response) { instance_double(HTTParty::Response, success?: false, code: http_code) }

        before do
          allow(expected_response).to receive(:parsed_response).
            and_return({ "error" => { "message" => error_message } })
          allow(HTTParty).to receive(:get).and_return(expected_response)
          result
        end

        it_behaves_like "calls the external API"

        it "does NOT cache the API response" do
          expect(Rails.cache.read(cache_key)).to be_nil
        end

        it "returns an ERROR status with a message" do
          expect(result).to include(status: "ERROR", message: a_string_including(http_code.to_s, error_message))
        end
      end
    end
  end
end
