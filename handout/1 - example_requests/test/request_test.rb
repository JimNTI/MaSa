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
    request_string = File.read('../get-index.request.txt')
    request = Request.new(request_string)
    expected_headers =
      {'Host' => 'developer.mozilla.org', 
      'Accept-Language' => 'fr'}
    
  

    assert_equal expected_headers, request.headers

  end

  def test_parses_params_from_simple_get
    request_string = File.read('../get-fruits-with-filter.request.txt')
    request = Request.new(request_string)
    expected_params = {
      'type' => 'bananas', 'minrating' => '4'
    }
    assert_equal expected_params, request.params
  end

  def test_parses_params_from_simple_post
    request_string = File.read('../post-login.request.txt')
    request = Request.new(request_string)
    expected_params = {
      'username' => 'grillkorv', 'password' => 'verys3cret!'
    }
    assert_equal expected_params, request.params
  end
  

end