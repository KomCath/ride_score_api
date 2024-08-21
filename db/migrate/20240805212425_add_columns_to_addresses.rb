class AddColumnsToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :coordinates, :json
    add_column :addresses, :verification_status_message, :string
  end
end
