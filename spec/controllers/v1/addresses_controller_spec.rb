RSpec.describe V1::AddressesController, type: :controller do
  shared_context "when address does NOT exist" do
    let(:address_id) { "invalid_id" }

    it "returns not_found response" do
      expect(response).to have_http_status(:not_found)
    end

    it "returns an error message" do
      expect(json_response).to eq({ error: "Address not found" }.as_json)
    end
  end

  describe "GET #index" do
    subject(:get_index) { get :index }
    let(:json_response) { JSON.parse(response.body) }
    let(:num_addresses) { 5 }

    before do
      create_list(:address, num_addresses)
      get_index
    end

    it "returns a success response" do
      expect(response).to have_http_status(:success)
    end

    it "returns all addresses" do
      expect(json_response.length).to eq(num_addresses)
    end
  end

  describe "GET #show" do
    subject(:get_show) { get :show, params: { id: address_id } }
    let(:json_response) { JSON.parse(response.body) }

    before { get_show }

    include_context "when address does NOT exist"

    context "when address exists" do
      let(:address) { create(:address) }
      let(:address_id) { address.id }

      it "returns a success response" do
        expect(response).to have_http_status(:success)
      end

      it "returns the address" do
        expect(json_response).to eq(address.as_json)
      end
    end
  end
end
