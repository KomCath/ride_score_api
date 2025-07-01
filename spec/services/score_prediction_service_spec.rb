RSpec.describe ScorePredictionService, type: :service do
  let(:ride_duration) { rand(5.1..15.9) }
  let(:ride_earnings) { rand(5.9..15.1) }
  let(:commute_duration) { rand(10.1..15.9) }

  describe "#initialize" do
    it "requires ride_duration" do
      expect { described_class.new(ride_earnings: ,commute_duration: ) }.
        to raise_error(ArgumentError)
    end

    it "requires ride_earnings" do
      expect { described_class.new(ride_duration: , commute_duration:) }.
        to raise_error(ArgumentError)
    end

    it "requires commute_duration" do
      expect { described_class.new(ride_duration: ,ride_earnings:) }.
        to raise_error(ArgumentError)
    end
  end

  describe "#predict" do
    subject(:predict) { described_class.new(**args).predict }
    let(:args) { { ride_duration:, ride_earnings:, commute_duration: } }

    context "when success" do
      before do
        pyimport "numpy", as: "np"
        pyimport "joblib"
        allow(joblib).to receive(:load).and_return(double(predict: [np.float64(12.34)]))
      end

      it "returns a score as a Float" do
        expect(predict).to be_a(Float)
      end

      it "roundes the prediction to 2 decimals" do
        expect(predict).to eq(predict.round(2))
      end
    end

    context "when an error occurs" do
      let(:logger) { instance_double(Logger, error: nil) }
      let(:commute_duration) { nil }

      before do
        allow(Rails).to receive(:logger).and_return(logger)
        predict
      end

      it "creates a log" do
        expect(logger).to have_received(:error).
          with(a_string_including("ScorePredictionService failed:"))
      end

      it "does NOT return a score" do
        expect(predict).to be_nil
      end
    end
  end
end
