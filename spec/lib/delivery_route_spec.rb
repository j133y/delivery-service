require 'rails_helper'

describe DeliveryRoute do
  describe '#economic_path' do
    subject(:delivery_route) { described_class.new(routes) }

    context 'when route exists on map' do
      let(:routes) { [
        [:a, :b, 10],
        [:b, :c, 5],
        [:b, :d, 1],
        [:d, :e, 2],
        [:e, :c, 1],
      ] }

      it 'calculates the most economic path' do
        expect(delivery_route.economic_path(origin: :a, destination: :c, autonomy: 10, liter_price: 2.5)).to eq(
          route: [:a, :b, :d, :e, :c], cost: 3.5
        )
      end
    end

    context 'when the map does not have routes' do
      let(:routes) { [] }

      it 'returns blank' do
        expect(delivery_route.economic_path(origin: :a, destination: :c)).to be_blank
      end
    end

    context 'when route does not exists on map' do
      let(:routes) { [
        [:a, :b, 10],
        [:b, :c, 5],
        [:b, :d, 1],
        [:d, :e, 2],
        [:e, :c, 1],
      ] }

      it 'returns blank for invalid origin' do
        expect(delivery_route.economic_path(origin: :z, destination: :b)).to be_blank
      end

      it 'returns blank for invalid destination' do
        expect(delivery_route.economic_path(origin: :a, destination: :x)).to be_blank
      end
    end
  end
end
