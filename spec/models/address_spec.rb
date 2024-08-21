RSpec.describe Address, type: :model do
  describe "Validations" do
    it { is_expected.to validate_presence_of(:line1) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zip_code) }

    it { is_expected.to validate_length_of(:line1).is_at_least(2) }
    it { is_expected.to validate_length_of(:city).is_at_least(2) }

    it { is_expected.to validate_inclusion_of(:state).in_array(Address::VALID_STATES).with_message("must be a valid 2-digit US state") }
  end

  describe "Callbacks" do
    describe ".normalize_attributes before_validation" do
      let(:address) { build(:address, line1: "  AbCdE  ", city: "  Long  Beach  ", state: "ca") }

      before { address.save }

      it { expect(address).to be_valid }

      it "normalizes line1" do
        expect(address.line1).to eq "ABCDE"
      end

      it "normalizes city" do
        expect(address.city).to eq "LONG BEACH"
      end

      it "normalizes state" do
        expect(address.state).to eq "CA"
      end

      it "does not change line2 if not present" do
        expect(address.line2).to be_nil
      end

      it "does not normalize attributes if they are not changed" do
        address.update!(zip_code: "10002")
        expect(address).to_not receive(:normalize_attributes)
      end
    end
  end

  describe "State Machine" do
    let(:states) do
      %i[
        verification_not_attempted
        unable_to_perform_verification
        verification_pending
        verification_successful
      ]
    end

    it { is_expected.to_not allow_transition_to(:verification_not_attempted) }

    it "has initial verification_status of 'verification_not_attempted'" do
      expect(described_class.new).to be_verification_not_attempted
    end

    it "has expected states" do
      expect(described_class.aasm.states.map(&:name)).to match_array states
    end

    describe "Events" do
      describe ".mark_unable_to_perform_verification" do
        it { is_expected.to transition_from(:verification_not_attempted).
          to(:unable_to_perform_verification).on_event(:mark_unable_to_perform_verification) }

        it { is_expected.to transition_from(:verification_pending).
          to(:unable_to_perform_verification).on_event(:mark_unable_to_perform_verification) }

        it { is_expected.to_not transition_from(:verification_successful).
          to(:unable_to_perform_verification).on_event(:mark_unable_to_perform_verification) }
      end

      describe ".mark_verification_pending" do
        it { is_expected.to transition_from(:verification_not_attempted).
          to(:verification_pending).on_event(:mark_verification_pending) }

        it { is_expected.to transition_from(:unable_to_perform_verification).
          to(:verification_pending).on_event(:mark_verification_pending) }

        it { is_expected.to_not transition_from(:verification_successful).
          to(:verification_pending).on_event(:mark_verification_pending) }
      end

      describe ".mark_verification_successful" do
        it { is_expected.to transition_from(:verification_not_attempted).
          to(:verification_successful).on_event(:mark_verification_successful) }

        it { is_expected.to transition_from(:unable_to_perform_verification).
          to(:verification_successful).on_event(:mark_verification_successful) }

        it { is_expected.to transition_from(:verification_pending).
          to(:verification_successful).on_event(:mark_verification_successful) }
      end
    end
  end
end
