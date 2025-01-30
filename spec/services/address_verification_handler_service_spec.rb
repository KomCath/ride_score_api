RSpec.describe AddressVerificationHandlerService, type: :service do
  describe "#initialize" do
    it "requires address_params" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  describe "#call" do
    let(:service) { described_class.new(address_params) }
    let(:result) { service.call }
    let(:address_verification_service) { instance_double(AddressVerificationService) }
    let(:address_params) do
      {
        line1: Faker::Address.street_address,
        city: Faker::Address.city,
        state: Faker::Address.state_abbr,
        zip_code: Faker::Address.zip_code.first(5)
      }
    end

    before do
      allow(AddressVerificationService).
        to receive(:new).
        and_return(address_verification_service)
    end

    context "when an address exist" do
      let!(:address) { create(:address, address_params) }

      it "does NOT call AddressVerificationService" do
        result
        expect(AddressVerificationService).not_to have_received(:new)
      end

      context "when address is verified" do

        before do
          address.mark_verification_successful!
        end

        it "returns a verified_address" do
          expect(result).to eq address.verified_address
        end
      end

      context "when address is NOT verified" do

        before do
          address.mark_verification_pending!
        end

        it "returns a status" do
          expect(result).to include(status: "verification_pending")
        end

        it "returns a message" do
          expect(result).to include(message: address.verification_status_message)
        end

        it "returns an address_id" do
          expect(result).to include(address_id: address.id)
        end
      end
    end

    context "when an address does NOT exist" do
      let(:address_verification_result) { { } }
      let(:new_address) { Address.where(address_params.transform_values { |v| v.upcase.squish }).first }

      before do
        allow(address_verification_service).
          to receive(:verify_address).and_return(address_verification_result)
      end

      it "creates a new_address" do
        expect { result }.to change { Address.count }.by(1)
      end

      it "calls AddressVerificationService" do
        result
        expect(address_verification_service).to have_received(:verify_address)
      end

      context "when new_address saves" do
        before { result }

        shared_examples "a verification result" do |status|
          it "returns a status" do
            expect(result).to include(status: status)
          end

          it "returns a message" do
            expect(result).to include(message: new_address.verification_status_message)
          end

          it "returns an address_id" do
            expect(result).to include(address_id: new_address.id)
          end
        end

        context "when address_verification_result ERROR" do
          let(:address_verification_result) { { status: "ERROR", message: Faker::Lorem.sentence } }

          it "updates the new_address verification_status as unable_to_perform_verification" do
            expect(new_address.reload.verification_status).to eq("unable_to_perform_verification")
          end

          it_behaves_like "a verification result", "unable_to_perform_verification"
        end

        context "when address_verification_result FIX/CONFIRM" do
          let(:address_verification_result) { { status: ["FIX", "CONFIRM"].sample, message: Faker::Lorem.sentence } }

          it "updates the new_address verification_status as verification_pending" do
            expect(new_address.reload.verification_status).to eq("verification_pending")
          end

          it_behaves_like "a verification result", "verification_pending"
        end

        context "when address_verification_result VERIFIED" do
          let(:address_verification_result) do
            {
              status: "VERIFIED",
              verified_address_params: {
                verified_address: Faker::Address.full_address
              }
            }
          end

          it "returns a verified_address" do
            expect(result).to eq new_address.verified_address
          end
        end
      end

      context "when new_address does NOT save" do
        let(:address_params) do
          {
            city: Faker::Address.city,
            state: Faker::Address.state_abbr,
            zip_code: Faker::Address.zip_code.first(5)
          }
        end

        it "does NOT create a new_address" do
          expect { result }.not_to change { Address.count }
        end

        it "does NOT call AddressVerificationService" do
          result
          expect(address_verification_service).not_to have_received(:verify_address)
        end

        it "returns an error status" do
          expect(result).to include(status: :error)
        end

        it "returns a message" do
          expect(result).to include(:message)
        end
      end
    end
  end
end
