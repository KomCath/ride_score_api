class CreateVerifiedAddress < ActiveRecord::Migration[7.0]
  def change
    create_table :verified_addresses do |t|
      t.string :line1, null: false
      t.string :line2
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip_code, null: false
      t.string :country
      t.string :coordinates, null: false

      t.references :address, null: false, foreign_key: true

      t.timestamps
    end
  end
end
