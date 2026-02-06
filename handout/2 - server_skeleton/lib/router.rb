class Router
  def initialize
    @get_routes = {}
    @post_routes = {}
  end

    def post(path, &blk)
      @post_routes[path] = blk
    end

  def get(path, &blk)
    @get_routes[path] = blk
  end



  def find(path, method)
    case method
    when "GET"
      @get_routes[path]
    when "POST"
      @post_routes[path]
    end
  end



end