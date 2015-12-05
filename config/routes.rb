require 'api_constraints'

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :maps do
        get 'estimate_delivery', on: :collection
      end

      resources :routes
    end
  end
end
