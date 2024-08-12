class AddressVerificationService
  BASE_URL = "https://addressvalidation.googleapis.com/v1:validateAddress?key=#{ENV["GOOGLE_MAPS_API_KEY"]}"
  HEADERS = { "Content-Type" => "application/json" }

  def initialize(address)
    @address = address
  end

  def verify_address
    make_api_request
    handle_api_response
  rescue StandardError => e
    { status: "ERROR", message: e.message }
  end

  private

  def make_api_request
    @response = HTTParty.post(BASE_URL, body: { "address": @address }.to_json, headers: HEADERS)
  end

  def handle_api_response
    if @response.success?
      parse_api_response
      if @has_fixable_components
        { status: "FIX", message: @fixable_components }
      elsif @has_confirmable_components
        { status: "CONFIRM", message: @confirmable_components }
      else
        { status: "VERIFIED", verified_address_params: build_verified_address_params }
      end
    else
      error_message = @response.parsed_response&.dig("error", "message") || "Unknown error"
      raise "Code: #{@response.code} - #{error_message}"
    end
  end

  def parse_api_response
    data = JSON.parse(@response.body)

    @verified_address_params = { coordinates: data.dig("result", "geocode", "location") }
    @address_components = data.dig("result", "address", "addressComponents") || []

    @has_fixable_components = data.dig("result", "verdict", "hasUnconfirmedComponents")
    unconfirmed_components = data.dig("result", "address", "unconfirmedComponentTypes") || []
    @fixable_components = unconfirmed_components.map do |unconfirmed_component|
      component = @address_components.find { |c| c["componentType"] == unconfirmed_component }
      { unconfirmed_component => component.dig("componentName", "text") }
    end.compact

    @has_confirmable_components = data.dig("result", "verdict", "hasReplacedComponents")
    @confirmable_components = @address_components.map do |component|
      if component.keys.any? { |key| ["spellCorrected", "replaced"].include?(key) }
        { component["componentType"] => component.dig("componentName", "text") }
      end
    end.compact
  end

  def build_verified_address_params
    @address_components.each do |component|
      value = component.dig("componentName", "text")

      case component["componentType"]
      when "street_number"
        @verified_address_params[:line1] = "#{value} "
      when "route"
        @verified_address_params[:line1] << value
      when "locality"
        @verified_address_params[:city] = value
      when "postal_code"
        @verified_address_params[:zip_code] = "#{value}-"
      when "postal_code_suffix"
        @verified_address_params[:zip_code] << value
      end
    end
    @verified_address_params
  end
end
