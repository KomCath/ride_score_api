class AddVerifiedAddressToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :verified_address, :string
  end
end
