class MlDataExporterService
  EXPORT_PATH = Rails.root.join("ml_models", "assignment_data.csv")
  CSV_HEADERS = %w[ride_duration ride_earnings commute_duration score].freeze

  def self.export
    new.export
  end

  def export
    begin
      tempfile = Tempfile.new(["ml_assignment_data", ".csv"])

      raise "No assignments found to export." if assignments.empty?

      write_csv(tempfile)
      FileUtils.mv(tempfile.path, EXPORT_PATH)

      Rails.logger.info("MlDataExporterService.export Success")
    rescue StandardError => e
      Rails.logger.error("MlDataExporterService Unexpected error: #{e.message}")
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  private

  def assignments
    @assignments ||= Assignment.includes(:ride)
  end

  def write_csv(file)
    CSV.open(file.path, "w") do |csv|
      csv << CSV_HEADERS

      assignments.each do |assignment|
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
