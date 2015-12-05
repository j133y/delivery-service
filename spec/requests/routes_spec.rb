require 'rails_helper'

RSpec.describe "Routes", :type => :request do
  describe "GET /routes/:id" do
    context 'when route exists' do
      let(:route) { create(:route) }

      it 'returns the route' do
        get api_route_path(id: route.id)

        route_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_ok
        expect_body_to_include_route(route_response, route)
      end
    end

    context 'when route does not exist' do
      it 'returns not found' do
        get api_route_path(id: 1231231)

        expect(response).to be_not_found
      end
    end
  end

  def expect_body_to_include_route(route_response, route)
    expect(route_response[:id]).to eq route.id
    expect(route_response[:origin]).to eq route.origin
    expect(route_response[:destination]).to eq route.destination
    expect(route_response[:distance]).to eq route.distance
  end
end
