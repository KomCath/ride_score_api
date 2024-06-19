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

  describe "POST #create" do
    subject(:post_create) { post :create, params: { address: address_params } }
    let(:json_response) { JSON.parse(response.body) }

    context "with invalid parameters" do
      let(:address_params) { attributes_for(:address).except(:line1) }

      it "returns unprocessable_entity response" do
        post_create
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does NOT create a new address" do
        expect { post_create }.not_to change(Address, :count)
      end

      it "returns an error message" do
        post_create
        expect(json_response).to include("error")
      end
    end

    context "with valid parameters" do
      let(:address_params) do
        {
          line1: Faker::Address.street_address,
          city: Faker::Address.city,
          state: Faker::Address.state_abbr,
          zip_code: Faker::Address.zip_code.first(5),
        }
      end

      it "returns a created response" do
        post_create
        expect(response).to have_http_status(:created)
      end

      it "creates a new address" do
        expect { post_create }.to change(Address, :count).by(1)
      end

      it "returns the created address" do
        post_create
        expect(json_response).to include(address_params.as_json)
      end
    end
  end

  describe "PATCH #update" do
    subject(:patch_update) { patch :update, params: { id: address_id, address: address_params } }
    let(:json_response) { JSON.parse(response.body) }
    let(:address) { create(:address) }

    context "with invalid parameters" do
      let(:address_params) { { line1: nil } }

      context "when address_id" do

        before { patch_update }

        include_context "when address does NOT exist"
      end

      context "when address_params" do
        let(:address_id) { address.id }

        it "returns unprocessable_entity response" do
          patch_update
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns an error message" do
          patch_update
          expect(json_response).to include("error")
        end

        it "does NOT update the address" do
          expect { patch_update }.not_to change { address.reload.updated_at }
        end
      end
    end

    context "with valid parameters" do
      let(:address_id) { address.id }
      let(:address_params) { { line2: Faker::Address.secondary_address } }

      it "returns a success response" do
        patch_update
        expect(response).to have_http_status(:ok)
      end

      it "returns the address" do
        patch_update
        expect(json_response).to include(address_params.as_json)
      end

      it "does update the address" do
        expect { patch_update }.to change { address.reload.updated_at }
      end
    end
  end
end
