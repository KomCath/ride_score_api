ActiveRecord::Base.transaction do
  driver_id = Driver.first.id
  Ride.all.each do |ride|
    Assignment.create!(ride_id: ride.id, driver_id: driver_id)
  end
end

ActiveRecord::Base.transaction do
  driver_id = Driver.last.id
  rides = Ride.order(ride_earnings: :asc).limit(5)
  rides.each do |ride|
    Assignment.create!(ride_id: ride.id, driver_id: driver_id)
  end
end

puts "\nFinished Assingments 🌳\n\n"
