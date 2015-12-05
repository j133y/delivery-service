json.array!(@maps) do |map|
  json.extract! map, :id, :name

  json.routes map.routes do |route|
    json.id route.id
    json.origin route.origin
    json.destination route.destination
    json.distance route.distance
    json.url api_route_url(route)
  end

  json.url api_map_url(map, format: :json)
end
