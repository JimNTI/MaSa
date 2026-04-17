require_relative 'tcp_server.rb'
require_relative 'lib/request'
require_relative 'lib/router'

#app class senare?
router = Router.new

#params <= request.params



router.get("/home") do |request|
  "<h1>Welcome to the Front Page</h1>"
end

router.get("/secret/:secretmessage") do |request|
  secretmessage = request.params[:secretmessage].to_s

  "<h1>Secret info: #{secretmessage}</h1>"
end

router.get("/add/:num1/with/:num2") do |request|
  num1 = request.params[:num1].to_i
  num2 = request.params[:num2].to_i
  
  "<h1>Answer: #{num1} + #{num2} = #{num1 + num2}</h1><h1>#{num1}</h1>"

end

router.post("/posting") do |request|
  "<h1> #{request.params}</h1>"
end


#sida med fungerande html och image -> ska göra att den skrivs "utanför servern" #med en form jag har lagt till för att kunna posta till "posting"

router.get("/fruits/:fruit_type/:amount") do |request|
  amount = request.params[:amount].to_i
  fruit_type = request.params[:fruit_type].to_s
  price = amount * fruit_type
  "<h1>Buy #{amount} #{fruit_type}s för #{price} Kroner</h1>"
end


server = HTTPServer.new(4567, router)
server.start