class Api::V1::MapsController < ApplicationController
  before_action :set_map, only: [:show, :edit, :update, :destroy]

  def index
    @maps = Map.all
  end

  def show
  end

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

  def update
    respond_to do |format|
      if @map.update(update_map_params)
        format.json { render :show, status: :ok, location: api_map_url(@map) }
      else
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @map.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def estimate_delivery
    @map = Map.find_by_name(estimate_delivery_params[:name])

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
