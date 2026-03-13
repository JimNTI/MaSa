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



  def find(request_path, method)
      if method == "GET"
        routes = @get_routes
      else 
        routes = @post_routes
      end
      
      routes.each do |route|
        if route[:path] == request_path
          return route
        end
      end
      return nil
  end



end