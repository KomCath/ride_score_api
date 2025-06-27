require "pycall/import"
include PyCall::Import

class ScorePredictionService
  MODEL_PATH = Rails.root.join("ml_models", "score_predictor.pkl").to_s

  def initialize(ride_duration, ride_earnings, commute_duration)
    @ride_duration = ride_duration
    @ride_earnings = ride_earnings
    @commute_duration = commute_duration
  end

  def predict
    pyimport "joblib"
    pyimport "numpy", as: "np"

    model = joblib.load(MODEL_PATH)
    input_data = np.array([[@ride_duration, @ride_earnings, @commute_duration]])
    prediction = model.predict(input_data)

    prediction.first.round(2)
  end
end
