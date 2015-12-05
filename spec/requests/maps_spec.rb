require 'rails_helper'

RSpec.describe "Maps", :type => :request do

  describe "GET /estimate_delivery" do
    context 'when params are valid' do
      let(:map) { create(:map) }
      let!(:routes) { [ create(:route, map: map, origin: 'A', destination: 'B', distance: 10),
                        create(:route, map: map, origin: 'B', destination: 'C', distance: 5),
                        create(:route, map: map, origin: 'B', destination: 'D', distance: 1),
                        create(:route, map: map, origin: 'D', destination: 'E', distance: 2),
                        create(:route, map: map, origin: 'E', destination: 'C', distance: 1) ] }

      context 'when there is a route for delivery' do
        let(:params) { { name: map.name, origin: 'A', destination: 'C', autonomy: 10, liter_price: 2.5 } }

        it 'returns the best route and its cost' do
          get estimate_delivery_api_maps_path(params)

          body = JSON.parse(response.body, symbolize_names: true)

          expect(response).to be_ok
          expect(body).to eq({ route: ["a", "b", "d", "e", "c"], cost: 3.5 })
        end
      end

      context 'when there is a route for delivery' do
        let(:params) { { name: map.name, origin: 'Z', destination: 'C', autonomy: 10, liter_price: 2.5 } }

        it 'returns the best route and its cost' do
          get estimate_delivery_api_maps_path(params)

          body = JSON.parse(response.body, symbolize_names: true)

          expect(response).to be_ok
          expect(body).to eq({ route: [], cost: 0.0 })
        end
      end
    end

    context 'when map does not exist' do
      it 'returns not found' do
        get estimate_delivery_api_maps_path(name: '123123', origin: 'A',
                                            destination: 'C', autonomy: 10, liter_price: 2.5)
        expect(response).to be_not_found
        expect(response.body).to eq 'Map does not exist' 
      end
    end
  end

  describe "GET /maps" do
    let(:map) { create(:map) }
    let!(:routes) { [ create(:route, map: map, origin: 'A', destination: 'B'),
                      create(:route, map: map, origin: 'B', destination: 'C') ] }

    it 'returns a list of maps with routes' do
      get api_maps_path

      maps_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_ok
      expect_body_to_include_map(maps_response.first, map)
    end
  end

  describe "GET /map/:id" do
    context 'when map exists' do
      let(:map) { create(:map) }
      let!(:routes) { [ create(:route, map: map, origin: 'A', destination: 'B'),
                        create(:route, map: map, origin: 'B', destination: 'C') ] }

      it 'returns the map' do
        get api_map_path(id: map.id)

        map_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_ok
        expect_body_to_include_map(map_response, map)
      end
    end

    context 'when map does not exist' do
      it 'returns not found' do
        get api_map_path(id: 1231231)

        expect(response).to be_not_found
      end
    end
  end

  describe "POST /map" do
    context 'when params are valid' do
      let(:routes_attributes) { [ { origin: 'A', destination: 'B', distance: 10 } ] }

      it 'creates the given map with routes' do
        expect { post api_maps_path({ map: { name: 'Mapa SP', routes_attributes: routes_attributes } }) }.to change(Map, :count).by(1)

        expect(Route.first.origin).to eq routes_attributes.first[:origin]
        expect(Route.first.destination).to eq routes_attributes.first[:destination]
        expect(Route.first.distance).to eq routes_attributes.first[:distance]
      end
    end

    context 'when params are not valid' do
      let(:routes_attributes) { [ { distance: 10 } ] }

      it 'returns errors' do
        post api_maps_path({ map: { routes_attributes: routes_attributes } })

        body = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(422)
        expect(body).to eq({
          :"routes.origin" => ["can't be blank"], 
          :"routes.destination" => ["can't be blank"], 
          :name => ["can't be blank"]
        })
      end
    end
  end

  describe "PUT /map/:id" do
    context 'when the map exists' do
      let(:map) { create(:map) }
      let!(:routes) { [ create(:route, map: map, origin: 'A', destination: 'B'),
                        create(:route, map: map, origin: 'B', destination: 'C') ] }

      context 'when params are valid' do
        it 'updates the given map' do
          put api_map_path(id: map.id, map: { name: 'Mapa RJ', routes_attributes: [{ id: routes.first.id, origin: 'Sao Caetano' }] })

          map_response = JSON.parse(response.body, symbolize_names: true)

          expect(response).to be_ok
          expect(map_response[:name]).to eq 'Mapa RJ'
          expect(map_response[:routes].first[:origin]).to eq 'Sao Caetano'
        end
      end

      context 'when params are not valid' do
        it 'updates the given map' do
          put api_map_path(id: map.id, map: { name: '' })

          body = JSON.parse(response.body, symbolize_names: true)

          expect(response.status).to eq(422)
          expect(body).to eq(name: ["can't be blank"])
        end
      end
    end

    context 'when the map does not exist' do
      it 'returns not found' do
        put api_map_path(id: 123, map: { name: 'Mapa RJ' })

        expect(response).to be_not_found
      end
    end
  end

  describe "DELETE /map/:id" do
    context 'when map exists' do
      let(:map) { create(:map) }
      let!(:routes) { [ create(:route, map: map, origin: 'A', destination: 'B'),
                        create(:route, map: map, origin: 'B', destination: 'C') ] }

      it 'returns the map' do
        delete api_map_path(id: map.id)

        expect(response.status).to eq 204
      end
    end

    context 'when map does not exist' do
      it 'returns not found' do
        delete api_map_path(id: 1231231)

        expect(response).to be_not_found
      end
    end
  end

  def expect_body_to_include_map(body, map)
    expect(body[:id]).to eq map.id
    expect(body[:name]).to eq map.name

    map.routes do |route|
      route_body = body[:routes].detect { |route_response| route_response[:id] == route.id }
      expect_body_to_include_route(route_body, route)
    end
  end

  def expect_body_to_include_route(route_response, route)
    expect(route_response[:id]).to eq route.id
    expect(route_response[:origin]).to eq route.origin
    expect(route_response[:destination]).to eq route.destination
    expect(route_response[:distance]).to eq route.distance
    expect(route_response[:url]).to eq api_route_url(route)
  end
end
