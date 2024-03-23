RSpec.describe Ride, type: :model do
  describe "Associations" do
    it { is_expected.to have_many :assignments }
    it { is_expected.to have_many(:drivers).through(:assignments) }
  end
end
