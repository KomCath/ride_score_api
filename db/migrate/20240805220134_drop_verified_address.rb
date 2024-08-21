class DropVerifiedAddress < ActiveRecord::Migration[7.0]
  def change
    drop_table :verified_addresses
  end
end
