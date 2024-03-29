addresses = [
  {
    start_address: "624 N Anaheim Blvd, Anaheim, CA",
    destination_address: "1313 Disneyland Dr, Anaheim, CA",
  },
  {
    start_address: "4017 E 6th St, Long Beach, CA",
    destination_address: "8039 Beach Blvd, Buena Park, CA",
  },
  {
    start_address: "17424 Sherman Way, Van Nuys, CA",
    destination_address: "26101 Magic Mountain Pkwy, Valencia, CA",
  },
  {
    start_address: "5856 Belgrave Ave, Garden Grove, CA",
    destination_address: "12681 Harbor Blvd, Garden Grove, CA",
  },
  {
    start_address: "624 N Anaheim Blvd, Anaheim, CA",
    destination_address: "7662 Beach Blvd, Buena Park, CA",
  },
  {
    start_address: "17424 Sherman Way, Van Nuys, CA",
    destination_address: "1200 Getty Center Dr, Los Angeles, CA",
  },
  {
    start_address: "1128 N Orange Grove Ave, West Hollywood, CA",
    destination_address: "900 Exposition Blvd, Los Angeles, CA",
  },
  {
    start_address: "4017 E 6th St, Long Beach, CA",
    destination_address: "100 Aquarium Way, Long Beach, CA",
  },
  {
    start_address: "17424 Sherman Way, Van Nuys, CA",
    destination_address: "2800 E Observatory Rd, Los Angeles, CA",
  },
  {
    start_address: "4017 E 6th St, Long Beach, CA",
    destination_address: "7550 E Spring St, Long Beach, CA",
  },
  {
    start_address: "1128 N Orange Grove Ave, West Hollywood, CA",
    destination_address: "1000 Vin Scully Ave, Los Angeles, CA",
  },
  {
    start_address: "624 N Anaheim Blvd, Anaheim, CA",
    destination_address: "4017 E 6th St, Long Beach, CA",
  },
  {
    start_address: "4017 E 6th St, Long Beach, CA",
    destination_address: "624 N Anaheim Blvd, Anaheim, CA",
  },
  {
    start_address: "624 N Anaheim Blvd, Anaheim, CA",
    destination_address: "17424 Sherman Way, Van Nuys, CA",
  },
]

addresses.each do |address|
  ActiveRecord::Base.transaction do
    start_address = Geocoder.search(*address[:start_address]).first.coordinates
    destination_address = Geocoder.search(*address[:destination_address]).first.coordinates
    Ride.create!(start_address: start_address, destination_address: destination_address)
  end
end

puts "\nFinished Rides 🌳\n\n"
