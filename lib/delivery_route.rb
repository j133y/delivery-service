class DeliveryRoute
  Vertex = Struct.new(:name, :neighbours, :distance, :previous)

  def initialize(routes)
    @vertices = {}
    @edges = {}

    routes.each do |(origin, destination, distance)|
      @vertices[origin] ||= Vertex.new(origin, [], Float::INFINITY)
      @vertices[origin].neighbours << destination

      @vertices[destination] ||= Vertex.new(destination, [], Float::INFINITY)

      @edges[[origin, destination]] = distance
      @edges[[destination, origin]] = distance
    end
  end

  def economic_path(delivery_info)
    origin = delivery_info.fetch(:origin)
    destination = delivery_info.fetch(:destination)

    return {} if @vertices.blank? || @vertices[origin].blank? || @vertices[destination].blank?

    estimate_vertices_distance(origin)

    route = []

    vertex = destination

    while vertex
      route.unshift(vertex)
      vertex = @vertices[vertex].previous
    end

    liter_price = delivery_info.fetch(:liter_price, 0).to_f
    autonomy = delivery_info.fetch(:autonomy, 0).to_f

    cost = (@vertices[destination].distance * liter_price) / autonomy

    { route: route, cost: cost}
  end

  private

  def estimate_vertices_distance(origin)
    vertexes = @vertices.values

    @vertices[origin].distance = 0

    until vertexes.empty?
      vertex = vertexes.min_by(&:distance)

      break if vertex.distance == Float::INFINITY

      vertexes.delete(vertex)

      vertex.neighbours.each do |neighbour|
        neighbour_vertex = @vertices[neighbour]

        if vertexes.include?(neighbour_vertex)
          origin_destination_distance = vertex.distance + @edges[[vertex.name, neighbour]]

          if origin_destination_distance < neighbour_vertex.distance
            neighbour_vertex.distance = origin_destination_distance
            neighbour_vertex.previous = vertex.name
          end
        end
      end
    end
  end
end

#class DeliveryRoute
  #Vertex = Struct.new(:name, :neighbours, :dist, :prev)
 
  #def initialize(routes)

    #@vertices = {}
    #@edges = {}

    #routes.each do |(origin, destination, distance)|
      #@vertices[origin] ||= Vertex.new(origin, [], Float::INFINITY)
      #@vertices[origin].neighbours << destination

      #@vertices[destination] ||= Vertex.new(destination, [], Float::INFINITY)

      #@edges[[origin, destination]] = distance
      #@edges[[destination, origin]] = distance
    #end

    ##@vertices = Hash.new{|h,k| h[k]=Vertex.new(k,[],Float::INFINITY)}
    ##@edges = {}
    ##graph.each do |(v1, v2, dist)|
      ##@vertices[v1].neighbours << v2
      ##@vertices[v2]
      ##@edges[[v1, v2]] = @edges[[v2, v1]] = dist
    ##end
    ##@dijkstra_source = nil
  #end
 
  #def dijkstra(source)
    #return  if @dijkstra_source == source
    #q = @vertices.values
    #q.each do |v|
      #v.dist = Float::INFINITY
      #v.prev = nil
    #end
    #@vertices[source].dist = 0
    #until q.empty?
      #u = q.min_by {|vertex| vertex.dist}
      #break if u.dist == Float::INFINITY
      #q.delete(u)
      #u.neighbours.each do |v|
        #vv = @vertices[v]
        #if q.include?(vv)
          #alt = u.dist + @edges[[u.name, v]]
          #if alt < vv.dist
            #vv.dist = alt
            #vv.prev = u.name
          #end
        #end
      #end
    #end
    #@dijkstra_source = source
  #end
 
  #def economic_path(source, target)
    #dijkstra(source)
    #path = []
    #u = target
    #while u
      #path.unshift(u)
      #u = @vertices[u].prev
    #end
    #return path, @vertices[target].dist
  #end
 
  #def to_s
    #"#<%s vertices=%p edges=%p>" % [self.class.name, @vertices.values, @edges] 
  #end
#end
