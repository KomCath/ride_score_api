# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_07_24_234037) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "line1", null: false
    t.string "line2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip_code", null: false
    t.string "country", default: "US"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "verification_status"
  end

  create_table "assignments", force: :cascade do |t|
    t.float "commute_duration"
    t.float "score"
    t.bigint "driver_id", null: false
    t.bigint "ride_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_assignments_on_driver_id"
    t.index ["ride_id"], name: "index_assignments_on_ride_id"
  end

  create_table "drivers", force: :cascade do |t|
    t.json "home_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rides", force: :cascade do |t|
    t.json "start_address"
    t.json "destination_address"
    t.float "ride_duration"
    t.float "ride_earnings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "assignments", "drivers"
  add_foreign_key "assignments", "rides"
end
