# == Schema Information
#
# Table name: verified_addresses
#
#  id          :bigint           not null, primary key
#  line1       :string           not null
#  line2       :string
#  city        :string           not null
#  state       :string           not null
#  zip_code    :string           not null
#  country     :string
#  coordinates :string           not null
#  address_id  :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class VerifiedAddress < ApplicationRecord
  belongs_to :address

  validates_presence_of :line1, :city, :state, :zip_code, :coordinates
end
