require 'rails_helper'

RSpec.describe Route, :type => :model do
  describe 'validations' do
    let(:map) { create(:map) }

    subject { build(:route, map: map) }

    it { expect(subject).to validate_uniqueness_of(:origin).scoped_to(:destination, :map_id) }

    context 'when origin and destination are the same' do
      let(:route) { build(:route, origin: 'A', destination: 'A', distance: 10) }

      it 'returns the error for the the invalid registry' do
        expect(route).to be_invalid
        expect(route.errors.messages).to eq({ destination: ["can't be equals to origin"] })
      end
    end
  end
end
