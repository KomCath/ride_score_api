RSpec.describe AddressVerificationService, type: :service do
  describe "#initialize" do
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
        allow(service).to receive(:make_api_request).and_raise(StandardError, error_message)
      end


      it "returns an ERROR status" do
        expect(service.verify_address).to include(status: "ERROR")
      end

      it "returns an error message" do
        expect(service.verify_address).to include(message: a_string_including("#{error_message}"))
      end
    end

    context "when the response is successful" do
      let(:cassette_path) { "successful_api_request" }
      let(:expected_response) { instance_double(HTTParty::Response, success?: true, body: response_body) }
      let(:response_body) { { "result" => nil }.to_json }

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

      it "returns a verified_address_params" do
        expect(result).to include(:verified_address_params)
      end

      context "when the response has_confirmable_components" do
        let(:response_body) do
          {
            "result" => {
              "verdict" => { "hasReplacedComponents" => true },
              "address" => {
                "addressComponents" => [
                  {
                    "componentType" => "locality",
                    "componentName" => { "text" => "San Francisco" },
                    "replaced" => true
                  }
                ]
              }
            }
          }.to_json
        end

        it "returns a CONFIRM status" do
          expect(result).to include(status: "CONFIRM")
        end

        it "returns a message with comfirmable_components" do
          expect(result).to include(message: array_including({ "locality" => "San Francisco" }))
        end
      end

      context "when the response has_fixable_components" do
        let(:response_body) do
          {
            "result" => {
              "verdict" => { "hasUnconfirmedComponents" => true },
              "address" => {
                "unconfirmedComponentTypes" => ["street_number"],
                "addressComponents" => [
                  {
                    "componentType" => "street_number",
                    "componentName" => { "text" => "123" }
                  }
                ]
              }
            }
          }.to_json
        end

        it "returns a FIX status" do
          expect(result).to include(status: "FIX")
        end

        it "returns a message with fixable_components" do
          expect(result).to include(message: array_including({ "street_number" => "123" }))
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
        expect(result).to include(status: "ERROR")
      end

      it "returns an error message with information from external API" do
        expect(result).to include(message: a_string_including(http_code.to_s, error_message))
      end
    end
  end
end
