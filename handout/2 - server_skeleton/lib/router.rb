class Router
  def initialize
    @routes = {}
  end

  def get(path, &blk)
    @routes[path] = blk
  end

  def find(path)
    @routes[path]
  end



end