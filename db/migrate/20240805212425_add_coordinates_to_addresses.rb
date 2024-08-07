class AddCoordinatesToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :coordinates, :json
  end
end
