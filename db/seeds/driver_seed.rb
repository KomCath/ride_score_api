home_addresses = [
  "2045 East Bermuda Street, Long Beach, CA",
  "204 Nieto Ave, Long Beach, CA",
  "12509 Jersey Ave, Norwalk, CA",
  "600 W 7th St, Los Angeles, CA"
]

home_addresses.each do |home_address|
  Driver.create!(home_address: home_address)
end

puts "\nFinished Drivers 🌳"