require_relative 'spec_helper'
require_relative '../lib/request'

class RequestTest < Minitest::Test

  def test_parses_http_method_from_simple_get
    request_string = File.read('../get-index.request.txt')
    request = Request.new(request_string)

    assert_equal 'GET', request.method
  end

  def test_parses_resource_from_simple_get
    request_string = File.read('../get-index.request.txt')
    request = Request.new(request_string)

    assert_equal '/', request.resource
  end

  def test_parses_version_from_simple_get
    request_string = File.read('../get-index.request.txt')
    request = Request.new(request_string)

    assert_equal 'HTTP/1.1', request.version
  end

  def test_parses_headers_from_simple_get
    request_string = File.read('./getindex.request.txt')
    request = Request.new(request_string)

    assert_equal "{'Host' => 'developer.mozilla.org', 'Accept-Language' => 'fr'}", request.headers

  end




  

end