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

  after_save :set_attributes, if: :should_set_attributes?

  private

  def should_set_attributes?
    (commute_duration.nil? || score.nil?) &&
      (ride.ride_earnings.present? || ride.ride_duration.present?)
  end

  def set_attributes
    call = fetch_commute_metrics(driver.home_address, ride.start_address)
    if call[:error]
      errors.add(:base, "Error fetching commute metrics: #{call[:error]}")
    else
      self.commute_duration = call[:duration].to_f / 60.0
      self.score = calculate_score
    end
  end

  def calculate_score
    (ride.ride_earnings / (commute_duration + ride.ride_duration)).to_f
  end

  def fetch_commute_metrics(origin, destination)
    GoogleMapsMetricsService.new(origin, destination).fetch_distance_and_duration
  rescue StandardError => e
    { error: e.message }
  end
end
