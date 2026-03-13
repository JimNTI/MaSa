class Router
  def initialize
    @get_routes = []
    @post_routes = []
  end

    def post(path, &blk)
      @post_routes << {path: path, block: blk}
    end

  def get(path, &blk)
    @get_routes << {path: path, block: blk}
  end



  def find(path, method)
      if method == "GET"
        routes = @get_routes
      else 
        routes = @post_routes
      end
  
      path_parts = path.split("/")

      routes.each do |route|
        route_parts = route[:path].split("/")

        params = {}
        matching = true
        
        route_parts.each_with_index do |part, i|

          if part.start_with?(":")
            key = part[1..]
            params[key] = path.parts[i]
          elsif i != path_parts[i]
            matching = false
            break
          end
        end

        if matching
          return [routes[:block], params]
        end
      end
    end



end