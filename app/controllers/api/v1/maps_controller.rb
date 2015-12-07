class Api::V1::MapsController < ApplicationController
  before_action :set_map, only: [:show, :edit, :update, :destroy]

  # Public: Action to list all the maps registered.
  #
  # Examples:
  #   GET /maps
  #
  # Returns a json with a list of all maps with routes.
  def index
    @maps = Map.all
  end

  # Public: Action to retrieve a map for a given id.
  #
  # id - Integer value corresponding to map id.
  #
  # Examples:
  #   GET /maps/1
  #
  # Returns a json with a list of all maps with routes.
  def show
  end

  # Public: Action to create a map with given parameters.
  #
  # map - Hash with map parameters.
  #        :name - String for the map name.
  #        :route_attributes - An Array of route objects.
  #              :origin - String with the origin route name.
  #              :destination - String with the destination route name.
  #              :distance - Integer with the distante between origin and destination.
  #
  # Examples:
  #   POST /maps
  #   Body:
  #   {
  #     "name": "Mapa SP",
  #     "routes": [
  #       {
  #         "origin": "Barueri",
  #         "destination": "Sao Paulo",
  #         "distance": 50
  #       },
  #       {
  #         "origin": "Osasco",
  #         "destination": "Sao Paulo",
  #         "distance": 30
  #       },
  #       {
  #         "origin": "Sao Paulo",
  #         "destination": "Santos",
  #         "distance": 100
  #       }
  #     ]
  #   }
  #
  # Returns a json with the representation of the given map if created.
  # Returns a exception json with status 422 if the map was not created.
  def create
    @map = Map.new(map_params)

    respond_to do |format|
      if @map.save
        format.json { render :show, status: :created, location: api_map_url(@map) }
      else
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # Public: Action to update a map with given parameters.
  #
  # map - Hash with map parameters.
  #        :id - Integer with the map id to be updated.
  #        :name - String for the map name.
  #        :route_attributes - An Array of route objects.
  #              :id - Integr with the route id to be updated.
  #              :origin - String with the origin route name.
  #              :destination - String with the destination route name.
  #              :distance - Integer with the distante between origin and destination.
  #
  # Examples:
  #   POST /maps
  #   Body:
  #   {
  #     "id": 1,
  #     "name": "Mapa SP",
  #     "routes": [
  #       {
  #         "id": 1,
  #         "origin": "Barueri",
  #         "destination": "Sao Paulo",
  #         "distance": 50
  #       },
  #       {
  #         "id": 2,
  #         "origin": "Osasco",
  #         "destination": "Sao Paulo",
  #         "distance": 30
  #       },
  #       {
  #         "id": 3,
  #         "origin": "Sao Paulo",
  #         "destination": "Santos",
  #         "distance": 100
  #       }
  #     ]
  #   }
  #
  # Returns a json with the representation of the given map if updated.
  # Returns a exception json with status 404 if the map was not found.
  # Returns a exception json with status 422 if the map was not updated.
  def update
    respond_to do |format|
      if @map.update(update_map_params)
        format.json { render :show, status: :ok, location: api_map_url(@map) }
      else
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # Public: Action to delete an existing map.
  #
  # id - Integer with the map id to be deleted.
  #
  # Examples:
  #   DELETE /maps/:id
  #
  # Returns nothing if success.
  # Returns a exception json with status 404 if the map was not found.
  def destroy
    @map.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # Public: Action to find the most economical path for a given delivery.
  #
  # map - Hash with map parameters.
  #        :name - String for the map name.
  #        :origin - String for the delivery origin.
  #        :destination - String for the delivery destination.
  #        :liter_price - String for the fuel price per liter.
  #        :autonomy - String for the autonomy of the transportation.
  #
  # Examples:
  #   POST /maps/estimate_delivery
  #   Body:
  #   {
  #     "name": "Mapa SP",
  #     "origin": "Barueri",
  #     "destination": "Sao Paulo",
  #     "liter_price": 2.50,
  #     "autonomy": 10
  #   }
  #
  # Returns a json with the representation of the delivery route path with cost.
  # Returns a exception json with status 404 if the map was not found.
  def estimate_delivery
    @map = Map.where('lower(name) = ?', estimate_delivery_params[:name].try(:downcase)).first

    if @map
      delivery_route = DeliveryRoute.new(@map.routes.map { |route| [route.origin, route.destination, route.distance] })
      @estimated_delivery = delivery_route.economic_path(estimate_delivery_params.except(:name))
    else
      render text: 'Map does not exist', status: :not_found
    end
  end

  private

  def set_map
    @map = Map.find(params[:id])
  end

  def map_params
    params.require(:map).permit(:name, routes_attributes: [:origin, :destination, :distance])
  end

  def update_map_params
    params.require(:map).permit(:name, routes_attributes: [:id, :origin, :destination, :distance])
  end

  def estimate_delivery_params
    params.permit(:name, :origin, :destination, :autonomy, :liter_price)
  end
end
