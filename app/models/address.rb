# == Schema Information
#
# Table name: addresses
#
#  id         :bigint           not null, primary key
#  line1      :string           not null
#  line2      :string
#  city       :string           not null
#  state      :string           not null
#  zip_code   :string           not null
#  country    :string           default("US")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Address < ApplicationRecord
  has_one :verified_address, dependent: :destroy

  validates_presence_of :line1, :city, :state, :zip_code
end
