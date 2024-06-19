RSpec.describe Address, type: :model do
  describe "Associations" do
    it { is_expected.to have_one(:verified_address).dependent(:destroy) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:line1) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zip_code) }
  end
end