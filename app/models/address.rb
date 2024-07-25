# == Schema Information
#
# Table name: addresses
#
#  id                  :bigint           not null, primary key
#  line1               :string           not null
#  line2               :string
#  city                :string           not null
#  state               :string           not null
#  zip_code            :string           not null
#  country             :string           default("US")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  verification_status :string
#
class Address < ApplicationRecord
  include AASM

  has_one :verified_address, dependent: :destroy

  validates_presence_of :line1, :city, :state, :zip_code

  aasm column: :verification_status do
    # default verification_status for `new` records
    state :verification_not_attempted, initial: true

    # the address verification was attempted but failed for a system reason (could not connect?)
    state :unable_to_perform_verification

    # the address was not verified and the data needs to be confirmed
    state :verification_pending

    # the address has been verified successfully
    state :verification_successful

    event :mark_unable_to_perform_verification do
      transitions from: %i[verification_not_attempted verification_pending],
        to: :unable_to_perform_verification
    end

    event :mark_verification_pending do
      transitions from: %i[verification_not_attempted unable_to_perform_verification],
        to: :verification_pending
    end

    event :mark_verification_successful do
      transitions from: %i[verification_not_attempted unable_to_perform_verification verification_pending],
        to: :verification_successful
    end
  end
end
