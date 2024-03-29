# == Schema Information
#
# Table name: rides
#
#  id                  :bigint           not null, primary key
#  start_address       :json
#  destination_address :json
#  ride_duration       :float
#  ride_earnings       :float
#  created_at          :datetime         not null
#  updated_at          :datetime         not null

class Ride < ApplicationRecord
  RATES = {
    base: 12.0,
    per_mile: 1.50,
    per_minute: 0.70,
    additional_distance_threshold: 5.0,
    additional_duration_threshold: 15.0,
  }.freeze

  has_many :assignments
  has_many :drivers, through: :assignments

  validates_presence_of :start_address, :destination_address

  before_save :set_attributes, if: -> { ride_duration.nil? || ride_earnings.nil? }

  private

  def set_attributes
    call = fetch_metrics_from_service(start_address, destination_address)
    if call[:error]
      errors.add(:base, "Error fetching ride metrics: #{call[:error]}")
    else
      self.ride_duration = call[:duration].to_f / 60.0
      self.ride_earnings = calculate_ride_earnings(call[:distance].to_f)
    end
  end

  def calculate_ride_earnings(ride_distance)
    additional_distance_earnings = [(ride_distance - RATES[:additional_distance_threshold]) * RATES[:per_mile], 0].max
    additional_duration_earnings = [(ride_duration - RATES[:additional_duration_threshold]) * RATES[:per_minute], 0].max
    sprintf('%.2f', (RATES[:base] + additional_distance_earnings + additional_duration_earnings))
  end

  def fetch_metrics_from_service(origin, destination)
    GoogleMapsMetricsService.new(origin, destination).fetch_distance_and_duration
  rescue StandardError => e
    { error: e.message }
  end
end
