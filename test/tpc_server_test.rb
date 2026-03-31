require_relative 'spec_helper'
require_relative '../lib/request'

class TpcServerTest < Minitest::Test

 def test_router_add_and_find
  router = Router.new
  router.add("/hello") { "Hello" }

  route = router.find("/hello")
  assert_equal "Hello", route.call
end


end