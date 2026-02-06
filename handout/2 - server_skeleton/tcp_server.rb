require 'socket'
require_relative 'lib/request'
require_relative 'lib/router'

class HTTPServer
  def initialize(port, router)
    @port = port
    @router = router
  end

  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"

    while session = server.accept
      data = ''
      while line = session.gets and line !~ /^\s*$/
        data += line
      end

      puts "RECEIVED REQUEST"
      puts '-' * 40
      puts data
      puts '-' * 40

      request = Request.new(data)
      p request

      route = @router.find(request.resource, request.method)

      if route
        result = route.call(request)

        if result.is_a?(Hash)
          content_type = result[:content_type]
          body = result[:body]
        else
          content_type = "text/html; charset=utf-8"
          body = result
        end

        session.print "HTTP/1.1 200 OK\r\n"
      else
        body = "<h1>ERROR 404</h1>"
        content_type = "text/html; charset=utf-8"
        session.print "HTTP/1.1 404 Not Found\r\n"
      end

      session.print "Content-Type: #{content_type}\r\n"
      session.print "Content-Length: #{body.bytesize}\r\n"
      session.print "\r\n"
      session.print body
      session.close
    end
  end
end

router = Router.new

router.get("/") do |request|
  "<h1>Hello I'm Alive -> Method: #{request.method}</h1>"
end

router.get("/home") do |request|
  "<h1>Welcome to the Front Page</h1>"
end

router.get("/secret") do |request|
  "<h1>Secret info: #{request.params}</h1>"
end

router.post("/posting") do |request|
  "<h1>Posted data: #{request.params}</h1>"
end

router.get("/george_image") do |request|
  {
    content_type: "image/jpeg",
    body: File.binread("images/george.jpg")
  }
end

router.get("/fruits") do |request|
  amount = request.params["amount"]
  fruit_type = request.params["fruit_type"]
  price = request.params["price"]
  "<h1>Buy #{amount} #{fruit_type}s för #{price} Kroner</h1>"
end

server = HTTPServer.new(4567, router)
server.start
