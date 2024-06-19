module V1
  class AddressesController < ApplicationController
    before_action :find_address, only: [:show, :update]

    # curl -X GET http://localhost:3000/v1/addresses
    def index
      render json: Address.all.order(updated_at: :desc)
    end

    # curl -X GET http://localhost:3000/v1/addresses/:id
    def show
      render json: @address
    end

    # curl -H "Content-Type: application/json" 
    #      -X POST 
    #      -d '{"address": 
    #            {"line1": "line1",
    #             "city": "city",
    #             "state": "state",
    #             "zip_code": "zip_code"
    #    }
    # }' 
    #  http://localhost:3000/v1/addresses -v
    def create
      address = Address.new(address_params)
      
      if address.save
        render json: address, status: :created
      else
        render json: { error: address.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # curl -H "Content-Type: application/json" 
    #      -X PATCH 
    #      -d '{"address": 
    #            {"line1": "line1",
    #             "city": "city",
    #             "state": "state",
    #             "zip_code": "zip_code"
    #    }
    # }' 
    #  http://localhost:3000/v1/addresses/:id -v
    def update
      if @address.update(address_params)
        render json: @address, status: :ok
      else
        render json: { error: @address.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def find_address
      @address = Address.find_by(id: params[:id])

      render json: { error: "Address not found" }, status: :not_found unless @address
    end

    def address_params
      params.require(:address).permit(:line1, :line2, :city, :state, :zip_code)
    end
  end
end
