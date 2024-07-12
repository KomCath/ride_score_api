class GoogleMapsMetricsService
  BASE_URL = "https://maps.googleapis.com/maps/api/distancematrix/json".freeze

  def initialize(origin, destination)
    @origin = origin.join("%2C")
    @destination = destination.join("%2C")
  end

  def fetch_distance_and_duration
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      make_api_request
      handle_api_response
    end
  rescue StandardError => e
    { status: "ERROR", origin: @origin, destination: @destination, message: e.message }
  end

  private

  def make_api_request
    url = "#{BASE_URL}?"
    url << "units=imperial"
    url << "&origins=#{@origin}"
    url << "&destinations=#{@destination}"
    url << "&key=#{ENV["GOOGLE_MAPS_API_KEY"]}"

    @response = HTTParty.get(url)
  end

  def handle_api_response
    if @response.success?
      parse_api_response
      if @request_status == "OK" && @element_status == "OK"
        { status: "SUCCESS", distance: @distance, duration: @duration }
      else
        error_message = @element_status.nil? ? "#{@request_status}: #{@request_status_error}" : @element_status
        raise error_message
      end
    else
      error_message = @response.parsed_response&.dig("error", "message") || "Unknown error"
      raise "Code: #{@response.code} - #{error_message}"
    end
  end

  def parse_api_response
    data = JSON.parse(@response.body)

    @request_status = data["status"]
    @request_status_error = data["error_message"]
    @element_status = data.dig("rows", 0, "elements", 0, "status")
    @distance = data.dig("rows", 0, "elements", 0, "distance", "text")
    @duration = data.dig("rows", 0, "elements", 0, "duration", "text")
  end

  def cache_key
    "distance_metrics:#{@origin}_to_#{@destination}"
  end
end
