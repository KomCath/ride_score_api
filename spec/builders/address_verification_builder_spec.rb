RSpec.describe AddressVerificationBuilder, type: :builder do
  describe "#initialize" do
    it "requires address" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it "address can NOT be nil" do
      expect { described_class.new(nil) }.to raise_error(ArgumentError, "Address cannot be nil")
    end

    it "requires an Address object" do
      expect { described_class.new("NOT an Address") }.to raise_error(ArgumentError, "Expected an Address object")
    end
  end

  describe ".build" do
    let(:result) { described_class.build(address) }
    let (:address) { create(:address, line1:, line2:) }
    let(:line1) { Faker::Address.street_address }
    let(:line2) { Faker::Address.secondary_address }

    before { result }

    it "returns a hash with the correct keys" do
      expect(result).to include("regionCode", "addressLines", "locality", "administrativeArea", "postalCode")
    end

    it "formats the addressLines correctly" do
      expect(result["addressLines"]).to eq(["#{line1} #{line2}"])
    end

    it "sets the correct regionCode" do
      expect(result["regionCode"]).to eq(address.country)
    end

    it "sets the correct locality" do
      expect(result["locality"]).to eq(address.city)
    end

    it "sets the correct administrativeArea" do
      expect(result["administrativeArea"]).to eq(address.state)
    end

    it "sets the correct postalCode" do
      expect(result["postalCode"]).to eq(address.zip_code)
    end

    context "when line2 is NOT present" do
      let(:line2) { nil }

      it "formats the addressLines correctly" do
        expect(result["addressLines"]).to eq([line1])
      end
    end
  end
end
