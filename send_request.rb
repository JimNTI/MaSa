require 'socket'

socket = TCPSocket.new('localhost', 4567)
socket.print File.read('../1 - example_requests/get-index.request.txt')
socket.close_write
puts socket.read
socket.close