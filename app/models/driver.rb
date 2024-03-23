class Driver < ApplicationRecord
  has_many :assignments
  has_many :rides, through: :assignments
end
