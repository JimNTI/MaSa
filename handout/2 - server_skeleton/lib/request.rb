class Request
  attr_reader :method, :resource, :version, :headers, :params
  def initialize(request_string)
    @request_string = request_string
    @params = {}

    parse_request_line
    parse_headers
    parse_params
  end

  private

  def parse_request_line
    lines = @request_string.split(/\r?\n/)
    request_line = lines.first
    @method, @resource, @version = request_line.split(" ")
  end

  def parse_headers
    @headers = {}
    lines = @request_string.split(/\r?\n/)
    request_line, *header_lines = lines #divide up the first row with the rest
    header_lines.each do |line|
      if line.strip.empty?
        break
        else
          key, value = line.split(": ", 2)
          @headers[key] = value
      end
    end
  end

  def parse_params
    parse_get_params
    parse_post_params
  end

  def parse_get_params
      if @resource.include?("?")
        path, query_string = @resource.split("?", 2)
        @resource = path
        query_string.split("&").each do |pair| #key-value pair
          key, value = pair.split("=", 2)
          @params[key] = value
        end
    end
  end

  def parse_post_params
    if @method == "POST"
      body = @request_string.split(/\r?\n\r?\n/, 2)[1]
      body.split("&").each do |pair|
        key, value = pair.split("=", 2)
        @params[key] = value.strip
      end
    else return
    end

  end
  
  


end