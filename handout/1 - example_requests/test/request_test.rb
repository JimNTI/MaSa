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

end