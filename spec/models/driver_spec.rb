RSpec.describe Driver, type: :model do
  describe "Associations" do
    it { is_expected.to have_many :assignments }
    it { is_expected.to have_many(:rides).through(:assignments) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:home_address) }
  end
end
