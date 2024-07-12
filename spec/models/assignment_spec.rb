RSpec.describe Assignment, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to :ride }
    it { is_expected.to belong_to :driver }
  end

  describe "Callbacks" do
    describe ".set_attributes before_save" do
      let(:driver) { create(:driver) }
      let(:ride) { create(:ride, ride_duration: rand(1.1..3.5), ride_earnings: rand(12.0..25.0))}

      shared_context "assignment builder" do
        let(:assignment) do
          build(:assignment, ride:ride, driver: driver, commute_duration: commute_duration, score: score)
        end

        before do
          allow(assignment).to receive(:set_attributes)
          assignment.save
        end
      end

      context "when commute_duration is nil" do
        let(:commute_duration) { nil }
        let(:score) { rand(10.0..30.0) }

        include_context "assignment builder"

        it "does not trigger set_attributes" do
          expect(assignment).to have_received(:set_attributes)
        end
      end

      context "when score is nil" do
        let(:commute_duration) { rand(1.1..3.5) }
        let(:score) { nil }

        include_context "assignment builder"

        it "does not trigger set_attributes" do
          expect(assignment).to have_received(:set_attributes)
        end
      end

      context "when necessary attributes are NOT nil" do
        let(:commute_duration) { rand(1.1..3.5) }
        let(:score) { rand(10.0..30.0) }

        include_context "assignment builder"

        it "does not trigger set_attributes" do
          expect(assignment).not_to have_received(:set_attributes)
        end
      end

      context "when necessary references are NOT present" do
        let(:driver) { nil }
        let(:commute_duration) { rand(1.1..3.5) }
        let(:score) { rand(10.0..30.0) }

        include_context "assignment builder"

        it "does not trigger set_attributes" do
          expect(assignment).not_to have_received(:set_attributes)
        end
      end
    end
  end
end
