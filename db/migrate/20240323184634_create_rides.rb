class CreateRides < ActiveRecord::Migration[7.0]
  def change
    create_table :rides do |t|
      t.json "start_address"
      t.json "destination_address"
      t.float "ride_duration"
      t.float "ride_earnings"

      t.timestamps
    end
  end
end
