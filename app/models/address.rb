# == Schema Information
#
# Table name: addresses
#
#  id                          :bigint           not null, primary key
#  line1                       :string           not null
#  line2                       :string
#  city                        :string           not null
#  state                       :string           not null
#  zip_code                    :string           not null
#  country                     :string           default("US")
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  verification_status         :string
#  coordinates                 :json
#  verification_status_message :string
#
class Address < ApplicationRecord
  include AASM

  VALID_STATES = %w[AL AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS
              KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC
              ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY].freeze

  UNVERIFIED_STATUSES = %w[
    verification_not_attempted
    unable_to_perform_verification
    verification_pending
  ].freeze

  before_validation :normalize_attributes, if: :address_changed?

  validates_presence_of :line1, :city, :state, :zip_code

  validates :line1,
            length: { minimum: 2 }
  validates :city,
            length: { minimum: 2 }
  validates :state,
            inclusion: {
              in: VALID_STATES,
              message: "must be a valid 2-digit US state",
            }

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

  def is_verified?
    !UNVERIFIED_STATUSES.include?(verification_status)
  end

  private

  def address_changed?
    line1_changed? || line2_changed? || city_changed? || state_changed?
  end

  def normalize_attributes
    [:line1, :line2, :city, :state].each do |attr|
      self[attr] = self[attr].upcase.squish if self[attr]
    end
  end
end
