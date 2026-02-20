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

      headers = data.split(/\r?\n/)
      content_length = nil
      headers.each do |line|
        if line =~ /^Content-Length:/i
          content_length = line.split(":", 2)[1].strip.to_i
          break
        end
      end

      if content_length
        body = session.read(content_length)
        data += "\r\n" + body
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

router.get("/public/*") do |request|

  path = request.resource.sub("/public/", "")

  file_path = File.join("public", path) #ext står för extension

  if File.exist?(file_path) && !File.directory?(file_path)
      ext = File.extname(file_path)
      content_type = case ext
                      when ".css" then "text/css"
                      when ".html" then "text/html"
                      when ".js"  then "application/javascript"
                      when ".png" then "image/png"
                      when ".jpg", ".jpeg" then "image/jpeg"
                      end

      {content_type: content_type, body: File.binread(file_path)}
    else
      "<h1>404 NOT FOUND</h1>"
    end
end

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

#hämtar en bild (jpeg)
router.get("/george_image") do |request|
  
  {
    content_type: "image/jpeg",
    body: File.binread("images/george.jpg")
  }
end

#sida med fungerande html och image -> ska göra att den skrivs "utanför servern" #med en form jag har lagt till för att kunna posta till "posting"
router.get("/george") do |request|
  {
    content_type: "text/html",
    #html kod från chatGPT
    body: <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <title>George</title>
          <link rel="stylesheet" href="/public/style.css">
          <style>
            .container {
              display: flex;
              align-items: center;
              gap: 20px;
            }
            img {
              max-width: 300px;
            }
          </style>
        </head>
        <form action="/posting" method="post">
          <input type="text" name="message" >
          <button type="submit">Send POST</button>
        </form>
        <body>
          <div class="container">
            <div>
              <h1>This is George</h1>
              <p>
                George is a very important image served directly
                from a TCP socket. No frameworks were harmed.
              </p>
            </div>
            <img src="/george_image" alt="George">
          </div>
        </body>
      </html>
    HTML
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
