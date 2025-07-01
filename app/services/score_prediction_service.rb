require "pycall/import"
include PyCall::Import

class ScorePredictionService
  MODEL_PATH = Rails.root.join("ml_models", "assignment_model.pkl").to_s

  def initialize(ride_duration:, ride_earnings:, commute_duration:)
    @ride_duration = ride_duration
    @ride_earnings = ride_earnings
    @commute_duration = commute_duration
  end

  def predict
    pyimport "numpy", as: "np"
    pyimport "joblib"

    load_score_model
    calculate_prediction

  rescue StandardError => e
    Rails.logger.error("ScorePredictionService failed: #{e.message}"); nil
  end

  private

  def load_score_model
    raise IOError, "Model file not found at #{MODEL_PATH}" unless File.exist?(MODEL_PATH)
    @model = joblib.load(MODEL_PATH)
  end

  def calculate_prediction
    prediction = @model.predict(input_data)

    prediction[0].round(2).to_f
  end

  def input_data
    np.array([[@ride_duration, @ride_earnings, @commute_duration]])
  end
end
