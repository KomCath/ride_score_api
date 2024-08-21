module V1
  class AddressesController < ApplicationController
    before_action :find_address, only: :show

    # curl -X GET http://localhost:3000/v1/addresses
    def index
      render json: Address.all.order(updated_at: :desc)
    end

    # curl -X GET http://localhost:3000/v1/addresses/:id
    def show
      render json: @address
    end

    private

    def find_address
      @address = Address.find_by(id: params[:id])

      render json: { error: "Address not found" }, status: :not_found unless @address
    end
  end
end
