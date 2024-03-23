class CreateDrivers < ActiveRecord::Migration[7.0]
  def change
    create_table :drivers do |t|
      t.json "home_address"

      t.timestamps
    end
  end
end
