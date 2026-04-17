class Router
  def initialize
    @get_routes = []
    @post_routes = []
  end

    def post(path, &blk)
      @post_routes << {path: path, block: blk, parts: path.split("/")}
      #"/users/:id"
      #{path: [{part: "users", dynamic: false}, {part: "id", dynamic: true}]}

    end

  def get(path, &blk)
      @post_routes << {path: path, block: blk, parts: path.split("/")}
  end



  def find(path, method)
      if method == "GET"
        routes = @get_routes
      else 
        routes = @post_routes
      end
      path_parts = path.split("/")

      routes.each do |route|
        route_parts = route[:parts] #path.split("/")

      if route_parts.length == path_parts.length
        params = {}
        matching = true
        
        route_parts.each_with_index do |part, i|

          if part.start_with?(":")
            key = part[1..]
            params[key] = path_parts[i]
          elsif part != path_parts[i]
            matching = false
            break
          end
        end
        if matching
          return {block: route[:block], params: params}
        end
      end
    end

    return nil
  end



end