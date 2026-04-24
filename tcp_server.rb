require 'socket'
require_relative 'lib/request'
require_relative 'lib/router.rb'
require 'cgi'

class App
  attr_reader :params, :response

  def initialize(params)
    @params = params
  end

  def redirect(path)
    @response = {redirect: path}
  end
end

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
      #p request
      
      p request.method
      p request.resource 
      p request.version
      #p request.header
      p request.params


      route = @router.find(request.resource, request.method)



      if route
        merge_params = request.params.merge(route[:params])
        context = App.new(merge_params)
        result = context.instance_eval(&route[:block])

        p context

        if context.response && context.response[:redirect]
          session.print "HTTP/1.1 302 Found\r\n"
          session.print "Location: #{context.response[:redirect]}\r\n"
          session.print "\r\n"
          session.close
          next
        end
        if result.is_a?(Hash)
          content_type = route[:content_type]
          body = result[:body]
        else
          content_type = "text/html; charset=utf-8"
          body = result
        end
        status = "HTTP/1.1 200 OK\r\n"
        
      else
        file_path = File.join("public", request.resource.sub(/^\//,""))

          unless File.exist?(file_path)
            html_path = file_path + ".html"
            if File.exist?(html_path)
              file_path = html_path
            end
          end

          if File.exist?(file_path) && !File.directory?(file_path)
            ext = File.extname(file_path)
            content_type = case ext
                              when ".css" then "text/css"
                              when ".html" then "text/html"
                              when ".js"  then "application/javascript"
                              when ".png" then "image/png"
                              when ".jpg", ".jpeg" then "image/jpeg"
                              else "text/plain"
                              end
            body = File.binread(file_path)
            status = "HTTP/1.1 200 OK\r\n"
          else
            body = "<h1>ERROR 404</h1>"
            content_type = "text/html; charset=utf-8"
            status = "HTTP/1.1 404 Not Found\r\n"
          end

      end
          session.print status
          session.print "Content-Type: #{content_type}\r\n"
          session.print "Content-Length: #{body.bytesize}\r\n"
          session.print "\r\n"
          session.print body
          session.close
    end
  end
end



