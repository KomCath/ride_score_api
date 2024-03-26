# == Schema Information
#
# Table name: drivers
#
#  id           :bigint           not null, primary key
#  home_address :json
#  created_at   :datetime         not null
#  updated_at   :datetime         not null

class Driver < ApplicationRecord
  has_many :assignments
  has_many :rides, through: :assignments
end
