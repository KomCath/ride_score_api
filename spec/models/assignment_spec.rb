RSpec.describe Assignment, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to :ride }
    it { is_expected.to belong_to :driver }
  end

  describe "Callbacks" do
    describe ".set_attributes before_save" do
      let(:driver) { create(:driver) }
      let(:ride) { create(:ride, ride_duration: rand(1.1..3.5), ride_earnings: rand(12.0..25.0))}

      shared_examples "triggers set_attributes before_save" do
        it "triggers" do
          assignment = create(:assignment, ride:ride, driver: driver,
                              commute_duration: commute_duration, score: score)
          allow(assignment).to receive(:set_attributes)
          assignment.save
          expect(assignment).to have_received(:set_attributes)
        end
      end

      context "when commute_duration is nil" do
        let(:commute_duration) { nil }
        let(:score) { rand(10.0..30.0) }
        include_examples "triggers set_attributes before_save"
      end

      context "when score is nil" do
        let(:commute_duration) { rand(1.1..3.5) }
        let(:score) { nil }
        include_examples "triggers set_attributes before_save"
      end

      context "when necessary attributes are NOT nil" do
        it "does not trigger set_attributes" do
          assignment = create(:assignment, ride:ride, driver: driver,
                              commute_duration: rand(1.1..3.5), score: rand(10.0..30.0))
          allow(assignment).to receive(:set_attributes)
          assignment.save
          expect(assignment).not_to have_received(:set_attributes)
        end
      end

      context "when necessary references are NOT present" do
        let(:ride) { create(:ride) }
        it "does not trigger set_attributes" do
          assignment = create(:assignment, ride: ride)
          allow(assignment).to receive(:set_attributes)
          assignment.save
          expect(assignment).not_to have_received(:set_attributes)
        end
      end
    end
  end
end
