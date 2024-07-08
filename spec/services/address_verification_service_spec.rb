RSpec.describe AddressVerificationService, type: :service do
  describe ".initialize" do
    it "requires address" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  describe "#verify_address" do
    let(:service) { described_class.new(address) }
    let(:address) { instance_double(Address) }
    let(:result) { VCR.use_cassette(cassette_path) { service.verify_address } }
    let(:error_message) { Faker::Lorem.word }

    context "when an unexpected error occurs" do

      before do
        allow(HTTParty).to receive(:post)
        allow(service).to receive(:make_api_request).and_raise(StandardError, error_message)
      end

      it "does NOT call the external API" do
        expect(HTTParty).not_to have_received(:post).
            with(AddressVerificationService::BASE_URL, { headers: AddressVerificationService::HEADERS, body: { "address": address }.to_json })
      end

      it "returns an error message" do
        expect(service.verify_address).to include(message: a_string_including("#{error_message}"))
      end
    end

    context "when the response is successful" do
      let(:cassette_path) { "successful_api_request" }
      let(:expected_response) { instance_double(HTTParty::Response, success?: true, body: response_body) }
      let(:response_body) do
        {
          "result" => {
            "geocode" => { "location" => Faker::Address.latitude },
            "address" => { "formattedAddress" => Faker::Address.full_address },
          }
        }.to_json
      end

      before do
        allow(HTTParty).to receive(:post).and_return(expected_response)
        result
      end

      it "calls the external API" do
        expect(HTTParty).
          to have_received(:post).
          with(AddressVerificationService::BASE_URL, { headers: AddressVerificationService::HEADERS, body: { "address": address }.to_json })
      end
      
      it "returns a VERIFIED status" do
        expect(result).to include(status: "VERIFIED")
      end

      it "returns a verified_address" do
        expect(result).to include(:verified_address)
      end

      it "returns coordinates" do
        expect(result).to include(:coordinates)
      end

      context "when the response has_fixable_components" do
        let(:response_body) do
          {
            "result" => {
              "verdict" => { "hasReplacedComponents" => true }
            }
          }.to_json
        end

        it "returns a CONFIRM status" do
          expect(result).to include(status: "CONFIRM")
        end

      end

      context "when has_confirmable_components" do
        let(:response_body) do
          {
            "result" => {
              "verdict" => { "hasUnconfirmedComponents" => true }
            }
          }.to_json
        end

        it "returns a FIX status" do
          expect(result).to include(status: "FIX")
        end
      end
    end

    context "when the response is NOT successful" do
      let(:cassette_path) { "failed_api_request" }
      let(:expected_response) { instance_double(HTTParty::Response, success?: false, code: http_code) }
      let(:http_code) { Faker::Number.number(digits: 3) }

      before do
        allow(expected_response).to receive(:parsed_response).and_return({ "error" => { "message" => error_message } })
        allow(HTTParty).to receive(:post).and_return(expected_response)
        result
      end

      it "calls the external API" do
        expect(HTTParty).
          to have_received(:post).
          with(AddressVerificationService::BASE_URL, { headers: AddressVerificationService::HEADERS, body: { "address": address }.to_json })
      end

      it "returns a ERROR status" do
        expect(result).to include(message: a_string_including(http_code.to_s, error_message))
      end
    end
  end
end
