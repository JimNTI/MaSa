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

      #html = "<h1>Hello, World!</h1>"

      route = @router.find(request.resource)
      html

      session.print "HTTP/1.1 200\r\n"
      session.print "Content-Type: text/html\r\n"
      session.print "\r\n"
      session.print html
      session.close
    end
  end
end

server = HTTPServer.new(4567)
server.start
