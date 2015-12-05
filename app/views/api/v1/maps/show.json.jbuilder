json.(@map, :id, :name, :created_at, :updated_at)

json.routes @map.routes do |route|
  json.id route.id
  json.origin route.origin
  json.destination route.destination
  json.distance route.distance
  json.url api_route_url(route)
end
