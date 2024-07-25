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
