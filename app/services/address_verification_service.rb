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
        { status: "VERIFIED", verified_address_params: @verified_address_params }
      end
    else
      error_message = @response.parsed_response&.dig("error", "message") || "Unknown error"
      raise "Code: #{@response.code} - #{error_message}"
    end
  end

  def parse_api_response
    data = JSON.parse(@response.body)

    @verified_address_params = {
      coordinates: data.dig("result", "geocode", "location"),
      verified_address: data.dig("result","address","formattedAddress")
    }

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
end
