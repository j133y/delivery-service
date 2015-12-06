require 'rails_helper'

RSpec.describe Route, :type => :model do
  describe 'validations' do
    let(:map) { create(:map) }

    subject { build(:route, map: map) }

    context 'when origin and destination are the same' do
      let(:route) { build(:route, origin: 'A', destination: 'A', distance: 10) }

      it 'returns the error for the the invalid registry' do
        expect(route).to be_invalid
        expect(route.errors.messages).to eq({ destination: ["can't be equals to origin"] })
      end
    end

    context 'when there is a origin with the same value for destination and map id' do
      let(:route) { build(:route, origin: 'A', destination: 'B', distance: 10, map: map) }

      before { create(:route, origin: 'a', destination: 'b', distance: 10, map: map) }

      it 'returns the error for the the invalid registry' do
        expect(route).to be_invalid
        expect(route.errors.messages).to eq({ origin: ["can't be duplicated by destination and map"] })
      end
    end
  end
end
