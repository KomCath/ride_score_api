class GoogleMapsMetricsService
  BASE_URL = "https://maps.googleapis.com/maps/api/distancematrix/json".freeze

  def initialize(origin, destination)
    @origin = origin.join("%2C")
    @destination = destination.join("%2C")
  end

  def fetch_distance_and_duration
    response = make_api_request
    handle_response(response)
  rescue StandardError => e
    { error: "An unexpected error occurred: #{e.message}" }
  end

  private

  def make_api_request
    url = "#{BASE_URL}?"
    url << "units=imperial"
    url << "&origins=#{@origin}"
    url << "&destinations=#{@destination}"
    url << "&key=#{ENV["GOOGLE_MAPS_API_KEY"]}"

    HTTParty.get(url)
  end

  def handle_response(response)
    if response["status"] == "OK"
      if response["rows"][0]["elements"][0]["status"] == "OK"
        parse_response(response)
      else
      { error: response["rows"][0]["elements"][0]["status"] }
      end
    else
      { error: response["error_message"] || "Failed to fetch data from the Google Maps API" }
    end
  end

  def parse_response(response)
    { 
      distance: response["rows"][0]["elements"][0]["distance"]["text"],
      duration: response["rows"][0]["elements"][0]["duration"]["text"]
    }
  end
end
