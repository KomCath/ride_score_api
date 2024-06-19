RSpec.describe VerifiedAddress, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to :address }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:line1) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_presence_of(:coordinates) }
  end
end
