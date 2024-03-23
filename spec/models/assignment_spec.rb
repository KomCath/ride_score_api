RSpec.describe Assignment, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to :ride }
    it { is_expected.to belong_to :driver }
  end
end
