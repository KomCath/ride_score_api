# == Schema Information
#
# Table name: assignments
#
#  id               :bigint           not null, primary key
#  commute_duration :float
#  score            :float
#  driver_id        :bigint           not null
#  ride_id          :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null

class Assignment < ApplicationRecord
  belongs_to :driver
  belongs_to :ride
end
