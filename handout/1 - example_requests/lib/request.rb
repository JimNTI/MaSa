class Request
  attr_reader :method, :resource, :version
  def initialize(request_string)
    @request_string = request_string
    parse_request_line
    parse_headers

  end

  def parse_request_line
    lines = @request_string.split(/\r?\n/)
    request_line = lines.first
    @method, @resource, @version = request_line.split(" ")
  end

  def parse_headers
    @headers = {}
    lines = @request_string.split(/\r?\n/)
    header_lines = lines[1]
    header_lines.each do |line|
    if line.strip.empty?
      break
    end


end