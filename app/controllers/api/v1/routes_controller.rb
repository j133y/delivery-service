class Api::V1::RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]

  def show
  end

  private

  def set_route
    @route = Route.find(params[:id])
  end
end
