require_relative 'tcp_server.rb'
require_relative 'lib/request'
require_relative 'lib/router'

router = Router.new

router.instance_eval do

  get ("/home") do
    
    "<form action='/add' method='post'>
      <input type='number' name='num1' placeholder='First number'>
      <input type='number' name='num2' placeholder='Second number'>
      <button type='submit'>ADD!</button>
    </form>"
  end

  post ("/add") do
    num1 = params[:num1].to_i
    num2 = params[:num2].to_i

    if num1 == 6 && num2 == 7
        redirect ("/secret_formula")
    else     
      "<h1>Answer: #{num1} + #{num2} = #{num1 + num2}</h1><h1>#{num1}</h1>"
    end
  end

  get ("/secret/:secretmessage") do
    secretmessage = params[:secretmessage].to_s

    "<h1>Secret info: #{secretmessage}</h1>"
  end

  get ("/add/:num1/with/:num2") do
    num1 = params[:num1].to_i
    num2 = params[:num2].to_i

    if num1 == 6 && num2 == 7
        redirect ("/secret_formula")
    else     
      "<h1>Answer: #{num1} + #{num2} = #{num1 + num2}</h1><h1>#{num1}</h1>"

    end
  end



  post ("/posting") do
    "<h1> #{params}</h1>"
  end


  #sida med fungerande html och image -> ska göra att den skrivs "utanför servern" #med en form jag har lagt till för att kunna posta till "posting"

  get ("/fruits/:fruit_type/:amount") do
    amount = params[:amount].to_i
    fruit_type = params[:fruit_type].to_s
    price = amount * fruit_type
    "<h1>Buy #{amount} #{fruit_type}s för #{price} Kroner</h1>"
  end
end


server = HTTPServer.new(4567, router)
server.start