require "csv"

class MlDataExporterService
  EXPORT_PATH = Rails.root.join("ml_models", "ride_data.csv")

  def self.export
    CSV.open(EXPORT_PATH, "w") do |csv|
      csv << ["ride_duration", "ride_earnings", "commute_duration", "score"]

      Assignment.includes(:ride).find_each do |assignment|
        csv << [
          assignment.ride.ride_duration,
          assignment.ride.ride_earnings,
          assignment.commute_duration,
          assignment.score
        ]
      end
    end
  end
end
