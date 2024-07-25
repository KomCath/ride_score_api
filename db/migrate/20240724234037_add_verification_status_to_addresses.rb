class AddVerificationStatusToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :verification_status, :string
  end
end
