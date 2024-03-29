RSpec.describe Ride, type: :model do
  describe "Associations" do
    it { is_expected.to have_many :assignments }
    it { is_expected.to have_many(:drivers).through(:assignments) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:start_address) }
    it { is_expected.to validate_presence_of(:destination_address) }
  end

  describe "Callbacks" do
    describe ".set_attributes before_save" do
      shared_examples "triggers set_attributes before_save" do
        it "triggers" do
          ride = create(:ride, ride_duration: ride_duration, ride_earnings: ride_earnings)
          allow(ride).to receive(:set_attributes)
          ride.save
          expect(ride).to have_received(:set_attributes)
        end
      end

      context "when ride_duration is nil" do
        let(:ride_duration) { nil }
        let(:ride_earnings) { 15.3 }
        include_examples "triggers set_attributes before_save"
      end

      context "when ride_earnings is nil" do
        let(:ride_duration) { 15.3 }
        let(:ride_earnings) { nil }
        include_examples "triggers set_attributes before_save"
      end

      context "when necessary attributes are NOT nil" do
        let(:ride_duration) { 12.5 }
        let(:ride_earnings) { 15.3 }

        it "does not trigger set_attributes" do
          ride = create(:ride, ride_duration: ride_duration, ride_earnings: ride_earnings)
          allow(ride).to receive(:set_attributes)
          ride.save
          expect(ride).not_to have_received(:set_attributes)
        end
      end
    end
  end
end
