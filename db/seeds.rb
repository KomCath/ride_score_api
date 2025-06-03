# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ORDERED_SEED_FILES = {
  "driver" => "🚗",
  "ride" => "🧌",
  "assignment" => "📝",
}

puts "\n 🌱 Seeding..."

ORDERED_SEED_FILES.each do |model, emoji|
  puts "\nNow seeding #{model.camelize.pluralize} #{emoji}\n"
  load "db/seeds/#{model}_seed.rb"
end

puts "\nFinished Seeding 🌳\n\n"
