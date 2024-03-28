module V1
  class AssignmentsController < ApplicationController
    before_action :find_driver, only: [:index]

    def index
      paginated_assignments = sorted_assignments.page(params[:page]).per(DEFAULT_PER_PAGE_SIZE)
      render json: paginated_assignments.map { |assignment| serialize_assignment(assignment) }
    end

    private

    DEFAULT_PER_PAGE_SIZE = 10

    def find_driver
      @driver = Driver.find_by(id: params[:driver_id])

      render json: { error: "Driver not found" }, status: :not_found unless @driver
    end

    def sorted_assignments
      return [ ] unless @driver

      @driver.assignments.where.not(score: nil).includes(:ride).order(score: :desc)
    end

    def serialize_assignment(assignment)
      {
        score: assignment.score,
        commute_duration: format_duration(assignment.commute_duration),
        ride_duration: format_duration(assignment.ride.ride_duration),
        ride_earnings: "$#{assignment.ride.ride_earnings}"
      }
    end

    def format_duration(duration)
      total_minutes = (duration * 60).to_i
      hours = total_minutes / 60
      minutes = total_minutes % 60

      hour_string = hours == 1 ? "hour" : "hours"
      minute_string = minutes == 1 ? "minute" : "minutes"

      if hours.positive? && minutes.positive?
        "#{hours} #{hour_string} and #{minutes} #{minute_string}"
      elsif hours.positive?
        "#{hours} #{hour_string}"
      elsif minutes.positive?
        "#{minutes} #{minute_string}"
      else
        "0 minutes"
      end
    end
  end
end
